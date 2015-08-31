		#  Script to produce manuscript plots
		#  Josh Nowak
		#  08/2015
################################################################################
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
		ri <- rand_map(model_nm = "fullrandwinternomass_825",
						lower = "red",
						upper = "green",
						pmu_alpha = 0.7,
						pmu_line = "gray",
						phi_txt = "black",
						phi_size = 3,
						intercept = T)
						
		#  Plot of pmu specific winter slope estimates
		rs <- rand_map(model_nm = "fullrandwinternomass_825",
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
		
#################################################################################
#  																				#	
#								Coefficient plots								#
#																				#		
#################################################################################
		#  Create coefficient plots
		#  One model
		fe <- get_fixedeff(model_nm = "fullrandwinternomass_825", 
							model_labs = "Model Name Here", 
							param_nm = "alpha4", 
							param_labs = "Parameter Name Here")
		
		#  Print table of values
		print(fe)
		
		#  Plot it
		plot_fixedeff(fe)
		
		#  Create lists of names of models to plot in catepillar plot
		conifer_models <- list.files(file.path(getwd(), "plot_in"), 
										pattern = "conifer")
		aspen_models <- list.files(file.path(getwd(), "plot_in"), 
										pattern = "aspen")
		shrub_models <- list.files(file.path(getwd(), "plot_in"), 
										pattern = "shrub")
		full_models <- list.files(file.path(getwd(), "plot_in"), 
										pattern = "^ap")	
		
		#  Multiple model plot
		full_fe <- get_fixedeff(model_nm = full_models, 
							model_labs = full_models)		
		plot_fixedeff(full_fe)
		
		con_fe <- get_fixedeff(model_nm = conifer_models, 
							model_labs = conifer_models)		
		plot_fixedeff(con_fe)

		asp_fe <- get_fixedeff(model_nm = aspen_models, 
							model_labs = aspen_models)		
		plot_fixedeff(asp_fe)

		shrub_fe <- get_fixedeff(model_nm = shrub_models, 
							model_labs = shrub_models)		
		plot_fixedeff(shrub_fe)		
		
		#  Plot on a 2x2 grid
		full <- plot_fixedeff(full_fe) 		
		con <- plot_fixedeff(con_fe) 
		asp <- plot_fixedeff(asp_fe) 
		shrub <- plot_fixedeff(shrub_fe) 
		
		lay <- matrix(c(1, 2, 3, 4), ncol = 2, byrow = T)
		multiplot(full, con, asp, shrub, layout = lay)
		
################################################################################
		#  R2 plots
		par(mfrow = c(3, 2))
		pred_plot("fullrandwintermass_825", 
					pmus = NULL, 
					main_txt = "Random winter with mass",
					add_var = T)
		pred_plot("fullrandwinternomass_825", 
					pmus = NULL, 
					main_txt = "Random winter without mass",
					add_var = T)
		pred_plot("6cov", 
					pmus = NULL, 
					main_txt = "6 Covariate",
					add_var = T)
		pred_plot("5cov", 
					pmus = NULL, 
					main_txt = "5 Covariate",
					add_var = T)
		pred_plot("3cov", 
					pmus = NULL, 
					main_txt = "3 Covariate",
					add_var = T)
		par(mfrow = c(1, 1))
		
################################################################################
		
		pred_plot("PredictionReduced_052315",
					pmus = NULL,
					main_txt = "3 Covariate Prediction",
					add_var = T,
					highlight_pmu = "Palisades")
					
		
						
						
		
		
		
		
		
		
		
		
		