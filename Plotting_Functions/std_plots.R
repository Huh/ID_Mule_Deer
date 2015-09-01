		#  Hurley et al Hierarchal Mule Deer Survival Plotting Functions
		#  Standard plotting functions
		#  Josh Nowak
		#  07/2015
################################################################################
		pred_plot <- function(mod, 
								pmus = NULL, 
								main_txt = "Random winter without mass",
								add_var = FALSE,
								highlight_pmu = NULL){
			#  A function to create prediction plots, R2 like
			#  Takes a model name
			#  Returns a plot
			
			if(grepl(".RData", mod)){
				load(file.path(getwd(), "model_out", mod))
			}else{
				load(file.path(getwd(), "model_out", 
					paste(mod, ".RData", sep = "")))
			}
			
			strt_yr <- as.numeric(format(min(startdate), "%Y")) + 1
			end_yr <- as.numeric(format(max(enddate), "%Y"))
			yrs <- length(strt_yr:end_yr)
			
			load(file.path(getwd(), "data", "km.RData"))
			km <- km[km$Year %in% strt_yr:end_yr,]
			if(!is.null(pmus)){
				km <- km[km$PMU %in% pmus]
			}
			
			
			pmu_index <- sdata %>% 
				select(GMU, PMU) %>%
				distinct() %>%
				arrange(GMU) %>%
				select(PMU) %>%
				mutate(index = as.numeric(as.factor(PMU)))
				
			sdata <- sdata %>% 
				mutate(PMU = pmu_index$index[match(PMU, pmu_index$PMU)])			
				
			if(!is.null(pmus)){
				sdata <- sdata %>% 
					filter(PMU %in% pmus)
			}
			
			ssize <- sdata %>%
				group_by(PMU, Cohort) %>%
				summarise(ss = n()) %>%
				tidyr::spread(Cohort, ss)
			
			ss_index <- apply(ssize, 2, function(x) which(!is.na(x)) )
			
			if(is.null(pmus)){
				npmu <- 11
			}else{
				npmu <- length(pmus)
			}
			kmest <- matrix(km$Survival, ncol = npmu, nrow = yrs)
			
			## Predicted survival with environmental variables at the GMU level
			surv.PMU <- surv.res$BUGSoutput$mean$phiPMU
			surv.PMU[surv.PMU < .001] <- NA
			
			if(add_var){
				lo <- apply(surv.res$BUGS$sims.list$phiPMU, c(2, 3), quantile, 
					0.025)
				hi <- apply(surv.res$BUGS$sims.list$phiPMU, c(2, 3), quantile, 
					0.975)					
			}
			
			if(grepl("pred", mod, ignore.case = T)){
				ssize[5:6,] <- 1
			}
			
			par(bty = "L")
			plot(kmest, surv.PMU,
					type = "n",
					col = "darkgray",
					ylim = c(0.05, 1), 
					xlim = c(0.05, 1), 
					ylab = ("Modeled Fawn Survival"), 
					xlab = ("Kaplan-Meier Fawn Survival"))
			abline(c(0, 1), lwd = 0.5)
			o <- order(kmest)
			lines(kmest[o], 
					predict(loess(as.vector(surv.PMU) ~ as.vector(kmest), 
						na.action = "na.exclude"))[o],
					lwd = 2, 
					col ="blue")

			pt_cols <- terrain.colors(11)
					
			for(i in 1:npmu){
				if(add_var){
					segments(x0 = kmest[,i], y0 = lo[,i], x1 = kmest[,i], 
						y1 = hi[,i], col = "gray80")
				}				
				
				points(kmest[,i], surv.PMU[,i], pch = 19, col = "gray40", 
					cex = as.numeric(unlist(ssize[ss_index[[i+1]],i+1]/50)))

				if(grepl("pred", mod, ignore.case = T)){
					points(kmest[5:6,i], surv.PMU[5:6,i], pch = 1, 
						col = "green", cex = 2.5)
				}				
				
				if(!is.null(highlight_pmu)){
					if(i == pmu_index$index[pmu_index$PMU == highlight_pmu][1]){
						
					points(kmest[,i], surv.PMU[,i], pch = 19, col = "red", 
						cex = as.numeric(unlist(ssize[ss_index[[i+1]],i+1]/50)))
						
					}
				}
				
			
			}

			title(main = paste(main_txt, "R^2 =", 
					round(cor(as.vector(kmest), as.vector(surv.PMU),
						use = "pairwise.complete.obs")^2, 3)))	
			
			qss <- round(hist(unlist(ssize[,2:12]), breaks = 5, plot = F)$mids)
			legend("bottomright",  
				legend = qss,
				title = "Sample Size",
				pch = 19,
				pt.cex = qss/50,
				col = "gray40",
				bty = "n")
			if(grepl("pred", mod, ignore.case = T)){
				if(!is.null(highlight_pmu)){
					legend("topleft", 
						legend = c("Estimate", "Prediction", highlight_pmu),
						pch = c(19, 1, 19),
						col = c("gray40", "green", "red"),
						pt.cex = c(1, 2.5, 1),
						bty = "n")
				}else{
					legend("topleft", 
						legend = c("Estimate", "Prediction"),
						title = "",
						pch = c(19, 1),
						col = c("gray40", "green"),
						pt.cex = c(1, 2.5),
						bty = "n")				
				}
			}else{
				if(!is.null(highlight_pmu)){			
					legend(0.85, 0.17, 
							legend = highlight_pmu,
							title = "",
							pch = 19,
							col = c("red"),
							bty = "n")
				}
			}
		}
		
		
		#dev.new()
		#plot(1:11, 1:11, col = (1:11) + 1, pch = 1:11, cex = 2)
		#pmu_index

################################################################################
		get_fixedeff <- function(model_nm, model_labs){
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
			
			param_labs <- data.frame(param = paste("alpha", 0:7, sep = ""),
										lab = c("GMU_intercept",
												"ND%snow",
												"W%snow",
												"A%snow",
												"FPC",
												"SPC",
												"FWeeks",
												"Depth"))
						
			#  Check model name
			if(any(!grepl(".RData", model_nm))){
				model_nm <- gsub(".RData", "", model_nm, ignore.case = T)
				model_nm <- paste(model_nm, "RData", sep = ".")
			}
			
			#  Load models - ugly
			mods <- lapply(model_nm, function(x){
				print(x)
				
				load(file.path(getwd(), "plot_in", x))
				
				param_nm <- surv.res$parameters.to.save[grepl("alpha", 
					surv.res$parameters.to.save)]
				param_len <- as.numeric(lapply(surv.res$BUGS$mean[param_nm], length))
				param_nm <- param_nm[param_len == 1]
				
				sims <- surv.res$BUGS$sims.list[param_nm]
				
				out <- bind_cols(lapply(1:length(param_nm), function(i){
					if(is.null(sims[[i]])){					
						out <- data.frame(rep(NA, surv.res$BUGS$n.sims),
											stringsAsFactors = F)
						colnames(out) <- as.character(param_labs$lab[param_labs$param == names(sims)[i]])
					}else{
						out <- data.frame(sims[[i]],
											stringsAsFactors = F)
						colnames(out) <- as.character(param_labs$lab[param_labs$param == names(sims)[i]])
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
									Parameter = colnames(mods[[i]]),
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
################################################################################
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
		
		