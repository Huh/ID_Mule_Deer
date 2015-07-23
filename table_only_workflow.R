		#  Hurley et al Hierarchal Mule Deer Survival DIC table Workflow
		#  Josh Nowak
		#  07/2015
		#  Only work with this script directly
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
		#  Source functions
		tbl_key <- sha_url("https://raw.githubusercontent.com/Huh/ID_Mule_Deer/master/Table_Functions/dic_table_funs.R",
							cmd = F)
		source_url("https://raw.githubusercontent.com/Huh/ID_Mule_Deer/master/Table_Functions/dic_table_funs.R", 
					sha = tbl_key)
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