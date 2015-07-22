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
#################################################################################
		#  Load common data
		shape <- readOGR()
		cross_ref <- gmuDau
#################################################################################
		#  Source plotting functions
		source_url("https://raw.githubusercontent.com/Huh/ID_Mule_Deer/master/Plotting_Functions/std_plots.R",
					prompt = F)
		source_url("https://raw.githubusercontent.com/Huh/ID_Mule_Deer/master/Plotting_Functions/maps.R",
					prompt = F)
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
		#  Create plots...
		#  Study area map with default colors broken out so user can see them
		study_area(gmu_border = "gray25", 
					gmu_txt = "gray25",
					pmu_border = "gray90", 
					pmu_txt = "white",
					pmu_fill = c("green3", "darkgreen", "navajowhite4"),
					bground = "terrain-background")
		#  Plot of pmu specific intercept estimates
		rand_map(model_nm = "fullwinterrandnomass_712",
					lower = "red",
					upper = "green",
					pmu_alpha = 0.7,
					pmu_line = "gray",
					phi_txt = "black",
					phi_size = 3,
					intercept = T)
		#  Plot of pmu specific winter slope estimates
		rand_map(model_nm = "fullwinterrandnomass_712",
					lower = "red",
					upper = "green",
					pmu_alpha = 0.7,
					pmu_line = "gray",
					phi_txt = "black",
					phi_size = 3,
					intercept = F)
		
					
		
		