		#  Hurley et al Hierarchal Mule Deer Survival Plotting Functions
		#  Standard plotting functions
		#  Josh Nowak
		#  07/2015
#################################################################################
		get_fixedeff <- function(model_nm, model_labs, param_nm, param_labs){
			#  The function will fail if random effects are included, the intent
			#  of this function is to extract fixed effects across models
			#  Takes -
			#  model_nm a character vector of the model name(s)
			#  model_labs the name(s) of the model you want to appear on the plot
			#  param_nm the name(s) of the parameters to extract
			#  param_labs the name(s) to appear in the plot for the parameters
			#  Returns a data frame
			#  Get jags object
			stopifnot(length(model_nm) == length(model_labs))
			stopifnot(length(param_nm) == length(param_labs))
						
			#  Check model name
			if(any(!grepl(".RData", model_nm))){
				model_nm <- gsub(".RData", "", model_nm, ignore.case = T)
				model_nm <- paste(model_nm, "RData", sep = ".")
			}
			
			#  Load models - ugly
			mods <- lapply(model_nm, function(x){
				print(x)
				load(file.path(getwd(), "plot_in", x))
				sims <- surv.res$BUGS$sims.list[param_nm]
				out <- bind_cols(lapply(1:length(param_nm), function(i){
					if(is.null(sims[[i]])){					
						out <- data.frame(rep(NA, surv.res$BUGS$n.sims),
											stringsAsFactors = F)
						colnames(out) <- param_labs[i]
					}else{
						out <- data.frame(sims[[i]],
											stringsAsFactors = F)
						colnames(out) <- param_labs[i]
					}
				return(out)
				}))
			out
			})
			
			#  Extract useful bits
			df_in <- bind_rows(lapply(1:length(mods), function(i){
					lohi <- apply(mods[[i]], 2, quantile, 
									c(0.025, 0.25, 0.75, 0.975), na.rm = T)
					out <- data.frame(Model = model_labs[i],
									Parameter = param_labs,
									Mean = apply(mods[[i]], 2, mean, na.rm = T),
									SD = apply(mods[[i]], 2, sd, na.rm = T),
									lo95 = lohi[1,],
									lo50 = lohi[2,],
									hi50 = lohi[3,],
									hi95 = lohi[4,])
			out
			}))
		
		return(df_in)
		}
		plot_fixedeff <- function(x, v_spacing = 0.5){
			#  A function to create plots of fixed effects in a catepillar like
			#  style
			#  Takes output of get_fixedeff
			#  Returns a plot
			ggplot(x, aes(x = Mean, y = Parameter, shape = Model)) +
				geom_point(position = position_dodgev(height = v_spacing)) +
				geom_errorbarh(aes(xmin = lo95, xmax = hi95), 
								height = 0, 
								lwd = 0, 
								position = position_dodgev(height = v_spacing)) +
				geom_errorbarh(aes(xmin = lo50, xmax = hi50),
								height = 0,
								lwd = 1,
								position = position_dodgev(height = v_spacing)) +
				geom_vline(xintercept = 0, linetype = 2, colour = "gray") +
				theme_bw() +
				theme(panel.grid.major = element_blank(),
						panel.grid.minor = element_blank(),
						panel.background = element_blank(),
						panel.border = element_blank(),
						axis.line = element_line(color = "black"))
		
		}
#################################################################################
		#  Helpers
		collidev <- function(data, height = NULL, name, strategy, check.height = TRUE) {
			if (!is.null(height)) {
				if (!(all(c("ymin", "ymax") %in% names(data)))) {
					data <- within(data, {
						ymin <- y - height/2
						ymax <- y + height/2
					})
				}
			} else {
				if (!(all(c("ymin", "ymax") %in% names(data)))) {
					data$ymin <- data$y
					data$ymax <- data$y
				}
				heights <- unique(with(data, ymax - ymin))
				heights <- heights[!is.na(heights)]
				if (!zero_range(range(heights))) {
					warning(name, " requires constant height: output may be incorrect", 
						call. = FALSE)
				}
				height <- heights[1]
			}
			data <- data[order(data$ymin), ]
			intervals <- as.numeric(t(unique(data[c("ymin", "ymax")])))
			intervals <- intervals[!is.na(intervals)]
			if (length(unique(intervals)) > 1 & any(diff(scale(intervals)) < -1e-06)) {
				warning(name, " requires non-overlapping y intervals", call. = FALSE)
			}
			if (!is.null(data$xmax)) {
				ddply(data, .(ymin), strategy, height = height)
			} else if (!is.null(data$x)) {
				message("xmax not defined: adjusting position using x instead")
				transform(ddply(transform(data, xmax = x), .(ymin), strategy, height = height), 
					x = xmax)
			} else {
				stop("Neither x nor xmax defined")
			}
		}

		pos_dodgev <- function(df, height) {
			n <- length(unique(df$group))
			if (n == 1) 
				return(df)
			if (!all(c("ymin", "ymax") %in% names(df))) {
				df$ymin <- df$y
				df$ymax <- df$y
			}
			d_width <- max(df$ymax - df$ymin)
			diff <- height - d_width
			groupidx <- match(df$group, sort(unique(df$group)))
			df$y <- df$y + height * ((groupidx - 0.5)/n - 0.5)
			df$ymin <- df$y - d_width/n/2
			df$ymax <- df$y + d_width/n/2
			df
		}

		position_dodgev <- function(width = NULL, height = NULL) {
			PositionDodgev$new(width = width, height = height)
		}

		PositionDodgev <- proto(ggplot2:::Position, {
			objname <- "dodgev"

			adjust <- function(., data) {
				if (empty(data)) 
					return(data.frame())
				check_required_aesthetics("y", names(data), "position_dodgev")

				collidev(data, .$height, .$my_name(), pos_dodgev, check.height = TRUE)
			}

		})
		
		