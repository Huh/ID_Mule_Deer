		#  Hurley et al Hierarchal Mule Deer Survival Input Organization
		#  Josh Nowak
		#  07/2015
		#  This script is intended to be used prior to running plotting functions
		#  The primary purpose is to move jags model objects to a common 
		#  directory to make their use easier and more programmatic
#################################################################################
		#  Load required packages
		require(dplyr)
#################################################################################		
		#  Set working directory, works on windows for sure, other OS?

#################################################################################
		#  Get model names from model_out folder, this assumes that old model
		#  names are the same as the new model names and old versions or new are
		#  in the MarkSurv/model_out folder
		mn <- list.files(file.path(getwd(), "model_out"))
		
		#  If required move new files from MarkSurv to MarkSurv/model_out
		lapply(mn, function(x){
			file.copy(file.path(wd, x), file.path(wd, "model_out", x), 
						copy.date = T)
		})
		
		#  With model names in hand load each workspace, extract model and save 
		#  new copy in plot_in this step
		#  is slow!!!
		lapply(mn, function(x){
			#  Load workspace
			load(file.path(wd, "model_out", x))
			#  All model objects are called the same thing, extract it
			save(surv.res, file = file.path(wd, "plot_in", x))
			rm(list = ls())[ls() != "mn"]
			gc()		
		})
		
		#  Copy km estimates to plot_in
		km <- read.table(file.path(wd, "kmsurvival.txt"), 
							sep = "\t",
							na.strings = c(" ", ""), 
							header = T, 
							as.is = T)
		save(km, file = file.path(wd, "plot_in", "km.RData"))
#################################################################################
		#  End
		

		