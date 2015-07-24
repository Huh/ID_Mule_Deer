		#  Hurley et al Hierarchal Mule Deer Survival Input Organization
		#  Josh Nowak
		#  07/2015
		#  This script is intended to be used prior to running plotting functions
		#  The primary purpose is to move jags model objects to a common 
		#  directory to make their use easier and more programmatic
#################################################################################
		#  Get model names from model_out folder, this assumes that old model
		#  names are the same as the new model names and old versions or new are
		#  in the MarkSurv/model_out folder
		mn <- list.files(file.path(getwd(), "model_out"))
		mn <- mn[!grepl("desktop", mn)]
		
		#  With model names in hand load each workspace, extract model and save 
		#  new copy in plot_in this step
		#  is slow!!!
		lapply(mn, function(x){
			print(x)
			#  Load workspace
			load(file.path(getwd(), "model_out", x))
			#  All model objects are called the same thing, extract it
			save(surv.res, file = file.path(getwd(), "plot_in", x))
			rm(list = ls())[ls() != "mn"]
			gc()		
		})
		
		# Copy km estimates to data, this was a one time step and won't be 
		#  performed again
		# km <- read.table(file.path(getwd(), "kmsurvival.txt"), 
							# sep = "\t",
							# na.strings = c(" ", ""), 
							# header = T, 
							# as.is = T)
		# save(km, file = file.path(getwd(), "data", "km.RData"))
#################################################################################
		#  End
		

		