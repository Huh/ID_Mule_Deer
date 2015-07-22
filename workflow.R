		#  Hurley et al Hierarchal Mule Deer Survival Plotting Workflow
		#  Josh Nowak
		#  07/2015
		#  Only work with this script directly, it will create all plots and 
		#  perform data/file manipulation
#################################################################################
		#  Load packages
		require(dplyr)
		require(sp)
		require(mcmcplots)
		require(ggplot)
#################################################################################
		#  Load common data
		shape <- readOGR()
		cross_ref <- gmuDau
#################################################################################
		#  Source plotting functions
		source("https://raw.githubusercontent.com/Huh/ID_Mule_Deer/master/Plotting_Functions/std_plots.R")
		source("https://raw.githubusercontent.com/Huh/ID_Mule_Deer/master/Plotting_Functions/maps.R")
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
		source("https://raw.githubusercontent.com/Huh/ID_Mule_Deer/master/workflow.R")
#################################################################################
		#  Create plots...