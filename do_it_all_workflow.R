		#  Hurley et al Hierarchal Mule Deer Survival Plotting Workflow
		#  Josh Nowak
		#  07/2015
		#  Only work with this script directly, it will create all plots and 
		#  perform data/file manipulation
#################################################################################
		#  Load packages
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
		if(Sys.info()["sysname"] == "Windows"){
			wd <- file.path("C:/Users/", Sys.info()["login"], "/Dropbox/MarkSurv")
			setwd(wd)
			if(!grepl("MarkSurv", getwd())){ 
				cat("\n\n", "Failed to set working directory!", 
					"\n",
					"Please working directory to '.../Dropbox/MarkSurv' before proceeding", 
					"\n\n")
			}			
		}else{
			wd <- "~/Dropbox/MarkSurv"
			try(setwd(wd), silent = T)
			if(!grepl("MarkSurv", getwd())){ 
				cat("\n\n", "Failed to set working directory!", 
					"\n",
					"Please working directory to '.../Dropbox/MarkSurv' before proceeding", 
					"\n\n")
			}
		}
#################################################################################
		#  Manipulate files if needed
		#  Run this line if:
		#  New files have been added to MarkSurv
		# source_url("https://raw.githubusercontent.com/Huh/ID_Mule_Deer/master/Data_Creation/file_manip.R",
					# prompt = F)
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
		ri <- rand_map(model_nm = "fullwinterrandnomass_712",
						lower = "red",
						upper = "green",
						pmu_alpha = 0.7,
						pmu_line = "gray",
						phi_txt = "black",
						phi_size = 3,
						intercept = T)
		#  Plot of pmu specific winter slope estimates
		rs <- rand_map(model_nm = "fullwinterrandnomass_712",
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
		#  Create plots...all models at "once"
		#  Get model names
		mns <- list.files(file.path(getwd(), "plot_in"))
		#  Eliminate ecotype models, prediction models and km
		mns <- mns[!grepl("shrub|aspen|con|predi|km", mns, ignore.case = T)]
		cat("\n\n", "The models to be plotted include:\n", 
			paste(mns, collapse = "\n "), "\n\n")
		
		#  Click on History->Recording in plot window before proceeding to make 
		#   plots scorllable 
		plot_list <- lapply(mns, function(x){
			print(x)
			#  Uncomment if you want study area too, then change layout matrix
			#sa <- study_area()
			ri <- rand_map(x, intercept = T)
			if(grepl("rand", x)){
				rs <- rand_map(x, intercept = F)
				lay <- matrix(c(1, 2, 1, 2), ncol = 2, byrow = T)
				multiplot(ri, rs, layout = lay)			
			}else{
				print(ri)
			}

		list(ri, rs)	
		})
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
		dic_wrapper(mns, word = T, doc_name = "sweet_table")
#################################################################################
		#  Create parameter table
		
		
		
		
		
		
		
		
		
					
		
		