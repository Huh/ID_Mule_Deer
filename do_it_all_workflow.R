		#  Hurley et al Hierarchal Mule Deer Survival Plotting Workflow
		#  Josh Nowak
		#  07/2015
		#  Only work with this script directly, it will create all plots and 
		#  perform data/file manipulation
#################################################################################
		#  Load packages
		require(proto)
		require(plyr)
		require(dplyr)
		require(sp)
		require(rgdal)
		require(mcmcplots)
		require(grid)
		require(ggplot2)
		require(ggmap)
		require(ggthemes)
		require(R2jags)
		require(downloader)
		require(knitr)
		require(rmarkdown)
#################################################################################
		#  Source plotting functions
		std_key <- sha_url("https://raw.githubusercontent.com/Huh/ID_Mule_Deer/master/Plotting_Functions/std_plots.R",
							cmd = F)
		source_url("https://raw.githubusercontent.com/Huh/ID_Mule_Deer/master/Plotting_Functions/std_plots.R", 
					sha = std_key)
		maps_key <- sha_url("https://raw.githubusercontent.com/Huh/ID_Mule_Deer/master/Plotting_Functions/maps.R",
						cmd = F)
		source_url("https://raw.githubusercontent.com/Huh/ID_Mule_Deer/master/Plotting_Functions/maps.R", 
					sha = maps_key)
		tbl_key <- sha_url("https://raw.githubusercontent.com/Huh/ID_Mule_Deer/master/Table_Functions/dic_table_funs.R",
							cmd = F)
		source_url("https://raw.githubusercontent.com/Huh/ID_Mule_Deer/master/Table_Functions/dic_table_funs.R", 
					sha = tbl_key)
		rm(list = c("maps_key", "std_key", "tbl_key"))
#################################################################################
		#  Establish working directory..user may have to set it manually, R will
		#  tell you what to do.  This is the top directory containing the gmu
		#  and plot_in folders
		#  Windows
		
		#  Change to the location of MarkSurv on your computer!!!!!!!!!!!
		setwd("C:/Users/josh.nowak/Google Drive/MarkSurv")
		
#################################################################################
		#  Manipulate files if needed
		#  Run this line if:
		#  New files have been added to MarkSurv
		file_key <- sha_url("https://raw.githubusercontent.com/Huh/ID_Mule_Deer/master/Data_Creation/file_manip.R", 
							cmd = F)
		source_url("https://raw.githubusercontent.com/Huh/ID_Mule_Deer/master/Data_Creation/file_manip.R",
					sha = file_key)
		rm(file_key)
#################################################################################
#																				#	
#										Maps									#
#																				#	
#################################################################################

		#  Create plots...for one model
		#  Study area map with defaults broken out so user can see them
		sa <- study_area(gmu_border = "gray25",
							gmu_line = 1.1,
							gmu_txt = "gray25",
							gmu_size = 2.5,
							pmu_border = "gray90",
							pmu_line = 1.1,
							pmu_size = 3.4,
							pmu_txt = "white",
							eco_fill = c("green3", "darkgreen", 
											"navajowhite4"),
							bground = "terrain-background")
							
		#  Plot of pmu specific intercept estimates
		ri <- rand_map(model_nm = "fullmodelRandWinterNoMass_052315",
						lower = "red",
						upper = "green",
						pmu_alpha = 0.7,
						pmu_line = "gray",
						phi_txt = "black",
						phi_size = 3,
						intercept = T)
						
		#  Plot of pmu specific winter slope estimates
		rs <- rand_map(model_nm = "fullmodelRandWinterNoMass_052315",
						lower = "red",
						upper = "green",
						pmu_alpha = 0.7,
						pmu_line = "gray",
						phi_txt = "black",
						phi_size = 3,
						intercept = F)
						
		#  All of the maps at once, visually the grid on which you plot is...
		#	1	2
		#	1	3
		lay <- matrix(c(1, 2, 1, 3), ncol = 2, byrow = T)
		multiplot(sa, ri, rs, layout = lay)
		
		#  To plot the individual maps try...
		print(ri)
		print(rs)
		print(sa)
		
#################################################################################
		#  Create plots...maps of all models at "once"
		#  Get model names
		# mns <- list.files(file.path(getwd(), "plot_in"))
		# #  Eliminate ecotype models, prediction models and km
		# mns <- mns[!grepl("shrub|aspen|con|predi|km", mns, ignore.case = T)]
		# cat("\n\n", "The models to be plotted include:\n", 
			# paste(mns, collapse = "\n "), "\n\n")
		
		# #  Click on History->Recording in plot window before proceeding to make 
		# #   plots scorllable 
		# plot_list <- lapply(mns, function(x){
			# print(x)
			# #  Uncomment if you want study area too, then change layout matrix
			# #sa <- study_area()
			# ri <- rand_map(x, intercept = T)
			# if(grepl("rand", x)){
				# rs <- rand_map(x, intercept = F)
				# lay <- matrix(c(1, 2, 1, 2), ncol = 2, byrow = T)
				# multiplot(ri, rs, layout = lay)			
			# }else{
				# print(ri)
			# }

		# list(ri, rs)	
		# })
		
#################################################################################
#  																				#	
#								Coefficient plots								#
#																				#		
#################################################################################
		#  Create coefficient plots
		#  One model
		fe <- get_fixedeff(model_nm = "3cov_713", 
							model_labs = "Model Name Here", 
							param_nm = "alpha4", 
							param_labs = "Parameter Name Here")
		
		#  Print table of values
		print(fe)
		
		#  Plot it
		plot_fixedeff(fe)
		
		conifer_models <- list.files(file.path(getwd(), "plot_in"), 
										pattern = "conifer")
		aspen_models <- list.files(file.path(getwd(), "plot_in"), 
										pattern = "aspen")
		shrub_models <- list.files(file.path(getwd(), "plot_in"), 
										pattern = "shrub")
		full_models <- c("5cov_722", "6cov_722", 
							list.files(file.path(getwd(), "plot_in"), 
										pattern = "fullm"))	
		
		#  Multiple model plot
		full_fe <- get_fixedeff(model_nm = full_models, 
							model_labs = full_models, 
							param_nm = paste("alpha", c(1, 3:7), sep = ""),
							param_labs = paste("param", c(1, 3:7), sep = " "))		
		plot_fixedeff(full_fe)
		
		con_fe <- get_fixedeff(model_nm = conifer_models, 
							model_labs = conifer_models, 
							param_nm = paste("alpha", c(1, 3:7), sep = ""),
							param_labs = paste("param", c(1, 3:7), sep = " "))		
		plot_fixedeff(con_fe)

		asp_fe <- get_fixedeff(model_nm = aspen_models, 
							model_labs = aspen_models, 
							param_nm = paste("alpha", c(1, 3:7), sep = ""),
							param_labs = paste("param", c(1, 3:7), sep = " "))		
		plot_fixedeff(asp_fe)

		shrub_fe <- get_fixedeff(model_nm = shrub_models, 
							model_labs = shrub_models, 
							param_nm = paste("alpha", c(1, 3:7), sep = ""),
							param_labs = paste("param", c(1, 3:7), sep = " "))		
		plot_fixedeff(shrub_fe)		

#################################################################################
#  																				#	
#								DIC Tables										#
#																				#		
#################################################################################
		#  Create DIC table
		#  Get model names - repeated in case you jump around in the script
		mns <- list.files(file.path(getwd(), "plot_in"))
		#  Eliminate ecotype models, prediction models and km
		mns <- mns[!grepl("shrub|aspen|con|predi|km", mns, ignore.case = T)]
		cat("\n\n", "The models to be included in table:\n", 
			paste(mns, collapse = "\n "), "\n\n")
			
		#  DIC table in R, all models
		dic_wrapper(mns)
		
		#  DIC for one model
		dic_wrapper("3cov57.RData")
		#  OR
		extract_dic("3cov_713.RData")
		
		#  Create word table - no file extension on doc_name
		dic_wrapper(mns, word = T, doc_name = "tables/full_dic")
		dic_wrapper(aspen_models, word = T, doc_name = "tables/aspen_dic")
		dic_wrapper(conifer_models, word = T, doc_name = "tables/conifer_dic")
		dic_wrapper(shrub_models, word = T, doc_name = "tables/shrub_dic")		
		
#################################################################################
#  																				#	
#							Coefficient Tables									#
#																				#		
#################################################################################
		#  Creat coefficient table 
		#  Step 1, call get_fixedeff
		#  Step 2, make table - relies on fe objects from above
		coef_report(full_fe, "tables/full_coef_table")
		coef_report(asp_fe, "tables/aspen_coef_table")
		coef_report(con_fe, "tables/conifer_coef_table")
		coef_report(shrub_fe, "tables/shrub_coef_table")
#################################################################################
	#  End
		
		
		
		
		
		
		
		
		
					
		
		