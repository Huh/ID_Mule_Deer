		#  Script to produce manuscript plots
		#  Josh Nowak
		#  08/2015
################################################################################
		#  Load packages
		require(proto)
		require(plyr)
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
		require(dplyr)
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
    source_url("https://raw.githubusercontent.com/jaredlander/coefplot/master/R/position.r", prompt = F)
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
		# file_key <- sha_url("https://raw.githubusercontent.com/Huh/ID_Mule_Deer/master/Data_Creation/file_manip.R", 
							# cmd = F)
		# source_url("https://raw.githubusercontent.com/Huh/ID_Mule_Deer/master/Data_Creation/file_manip.R",
					# sha = file_key)
		# rm(file_key)
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
							pmu_border = "gray50",
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
    
    #  Save for publication
    png(file="plots/maps_highres.png", width = 5844, height = 4024, 
      res = 450)   
    multiplot(sa, ri, rs, layout = lay)
    dev.off()
    
    png(file="plots/study_area_highres.png", width = 3600, height = 3600, 
      res = 420)   
    plot(sa)
    dev.off()
    
    png(file = "plots/rand_gmus_highres.png", width = 2400, height = 3600, 
      res = 420)   
    multiplot(ri, rs, layout = matrix(c(1, 2), ncol = 1))
    dev.off()    
    
    
#################################################################################
#  																				#	
#								Coefficient plots								#
#																				#		
#################################################################################
		#  Create coefficient plots - Figure 4
		#  One model
		# fe <- get_fixedeff(model_nm = "fullrandwinternomass_825", 
							# model_labs = "Model Name Here", 
							# param_nm = "alpha4", 
							# param_labs = "Parameter Name Here")
		
		# #  Print table of values
		# print(fe)
		
		#  Plot it
		# plot_fixedeff(fe)
		
		#  Create lists of names of models to plot in catepillar plot
		conifer_models <- c("conifer3cov_722.RData",
							"conifer4cov.RData",
							"conifer5cov.RData",
							"conifer6cov_722.RData",      
							"fullconifer_722.RData",
							"fullconifernomass_722.RData")
		conifer_labs <- c("5", "4", "2", "3", "6", "1")					
		
		aspen_models <- c("2covaspen.RData",
							"3covaspen.RData",        
							"4covaspen.RData",
							"5covaspen.RData",        
							"fullaspennomass.RData",  
							"fullaspenwithmass.RData")
		aspen_labs <- c("5", "4", "7", "3", "2", "1")
		
		shrub_models <- c("3covshrub_722.RData",
							"fullshrub_722.RData",      
							"fullshrubnomass_722.RData",
							"shrub3cov456_722.RData",   
							"shrub4cov3_4_5_6.RData",   
							"shrub5cov_722.RData")
		shrub_labs <- c("7", "2", "3", "7", "6", "5")
		
		full_models <- c("apfull3cov.RData",
						 "apfullmodelnomass_723.Rdata",
						 "ap6cov_722.RData",           
						 "ap5cov_722.RData",						 
						 "apfullmodel.RData"              
						)
		full_labs <- c("2", "4", "5", "6", "11")

		full_rand <- c("ap3covfallPCrandnomass.RData",
						"ap3covrandwinter_825.RData",      
						"apfullmodelrandomfallweeks.RData",
						"apfullrandomFPC.RData",
						"apfullrandwinternomass_825.RData",
						"apfullwinterrandomwithmass.RData")
		rand_labs <- c("8", "1", "7", "10", "3", "9")
		
		#  Multiple model plot
		full_fe <- get_fixedeff(model_nm = full_models, 
							model_labs = full_labs)
		full_rand <- get_fixedeff(model_nm = full_rand, 
							model_labs = rand_labs) 
		
		con_fe <- get_fixedeff(model_nm = conifer_models, 
							model_labs = conifer_labs)		

		asp_fe <- get_fixedeff(model_nm = aspen_models, 
							model_labs = aspen_labs)		

		shrub_fe <- get_fixedeff(model_nm = shrub_models, 
							model_labs = shrub_labs)		
		
		#  Plot on a 2x2 grid
		full <- plot_fixedeff(full_fe, Title = "Full Fixed Effects", 0.7)
		fullr <- plot_fixedeff(full_rand, Title = "Full Random Effects", 0.7)
		con <- plot_fixedeff(con_fe, Title = "Conifer Fixed Effects", 0.7) 
		asp <- plot_fixedeff(asp_fe, Title = "Aspen Fixed Effects", 0.7) 
		shrub <- plot_fixedeff(shrub_fe, Title = "Shrub Fixed Effects", 0.7) 
		
		lay <- matrix(c(1, 2, 3, 4), ncol = 2, byrow = T)
		multiplot(full, con, asp, shrub, layout = lay)
    
    #  Save for publication
    png(file="plots/fixedeff_highres.png", width = 3700, height = 4000, 
      res = 450)   
		multiplot(full, con, asp, shrub, layout = lay)
    dev.off()
		
		#  Add in full rand
		lay <- matrix(c(1, 2, 3, 4, 5, 6), ncol = 2, byrow = T)
		multiplot(full, fullr, con, asp, shrub, layout = lay)	

    png(file="plots/randeff_highres.png", width = 3700, height = 4000, 
      res = 450)   
		multiplot(full, fullr, con, asp, shrub, layout = lay)
    dev.off()

################################################################################
		#  R2 plots - Figure 3
    png(file="plots/Model_KM_comparison_alldata_highres.png", width = 3700, 
      height = 4000, res = 450)   
		par(mfrow = c(3, 2))
		pred_plot("apfullwinterrandomwithmass", 
					pmus = NULL, 
					main_txt = "Random winter with mass",
					add_var = T, 
					highlight_pmu = NULL)
		pred_plot("apfullrandwinternomass_825", 
					pmus = NULL, 
					main_txt = "Random winter without mass",
					add_var = T, 
					highlight_pmu = NULL)
		pred_plot("ap6cov_722", 
					pmus = NULL, 
					main_txt = "6 Covariate",
					add_var = T, 
					highlight_pmu = NULL)
		pred_plot("ap5cov_722", 
					pmus = NULL, 
					main_txt = "5 Covariate",
					add_var = T, 
					highlight_pmu = NULL)
		pred_plot("ap3covrandwinter_825", 
					pmus = NULL, 
					main_txt = "3 Covariate random winter",
					add_var = T, 
					highlight_pmu = NULL)
		pred_plot("apfull3cov", 
					pmus = NULL, 
					main_txt = "3 Covariate",
					add_var = T, 
					highlight_pmu = NULL)
    dev.off()
		par(mfrow = c(1, 1))


################################################################################		
		##Additional Plots for new R2##########		
		#  R2 plots
		
		
		
		#####  Not used in manuscript  !!!!!!!!!!!!!!!!!!!!!!!
		
		
		
		
		par(mfrow = c(3, 2))
		pred_plot("ap3covfallPCrandnomass", 
					pmus = NULL, 
					main_txt = "3covfallPCrand",
					add_var = T, 
					highlight_pmu = NULL)
		pred_plot("apfullwinterrandomwithmass", 
					pmus = NULL, 
					main_txt = "Random winter mass",
					add_var = T, 
					highlight_pmu = NULL)
		pred_plot("apfullrandomFPC", 
					pmus = NULL, 
					main_txt = "fullrandFPC",
					add_var = T, 
					highlight_pmu = NULL)
		pred_plot("apfullmodelrandomfallweeks", 
					pmus = NULL, 
					main_txt = "randfallweeks",
					add_var = T, 
					highlight_pmu = NULL)
		pred_plot("apfullmodelnomass_723", 
					pmus = NULL, 
					main_txt = "Full model no mass",
					add_var = T, 
					highlight_pmu = NULL)
		pred_plot("apfullmodel", 
					pmus = NULL, 
					main_txt = "Full Model",
					add_var = T, 
					highlight_pmu = NULL)
		par(mfrow = c(1, 1))
		
		
################################################################################
		#  Prediction plots - Figure 6
    png(file="plots/Prediction_highres.png", width = 3700, 
      height = 4000, res = 450)   
		par(mfrow = c(3, 2))
		#  Example prediction plot with Palisades highlighted
#		pred_plot("PredictionReduced_052315",
#					pmus = NULL,
#					main_txt = "3 Covariate Prediction",
#					add_var = T,
#					highlight_pmu = "Palisades")
#										
		pred_plot("PredictfullmodelRandWinterNoMass_052315",
					pmus = NULL,
					main_txt = "Full Model with Rand Winter",
					add_var = T,
					highlight_pmu = NULL)	
		pred_plot("Predict6cov",
					pmus = NULL,
					main_txt = "6 covariate Prediction",
					add_var = T,
					highlight_pmu = NULL)	
		pred_plot("Prediction5cov_052315",
					pmus = NULL,
					main_txt = "5 Covariate Prediction",
					add_var = T,
					highlight_pmu = NULL)	
		pred_plot("Prediction3covrandwint",
					pmus = NULL,
					main_txt = "3 Covariate rand winter",
					add_var = T,
					highlight_pmu = NULL)
		pred_plot("PredictionReduced_052315",
					pmus = NULL,
					main_txt = "3 Covariate Prediction",
					add_var = T,
					highlight_pmu = NULL)	
    dev.off()
		par(mfrow = c(1, 1))		
					
################################################################################
		#  Ecotype R2 - Figure 5
    png(file="plots/Prediction_ecotype_highres.png", width = 3700, 
      height = 4000, res = 450)   
		par(mfrow = c(3, 2))
		# pred_plot("fullaspenwithmass", 
					# pmus = c(1,3,8), 
					# main_txt = "Aspen Full with Mass",
					# add_var = T, 
					# highlight_pmu = NULL)
					
		#  This could be 5covaspen or 5cov_722
		pred_plot("5covaspen", 
					pmus = c(1, 3, 8), 
					main_txt = "Aspen 5 covariate",
					add_var = T, 
					highlight_pmu = NULL)
					
		pred_plot("fullconifernomass_722", 
					pmus = c(2, 4, 5, 6, 7, 9, 11), 
					main_txt = "Conifer full no mass",
					add_var = T, 
					highlight_pmu = NULL)
		pred_plot(mod = "conifer5cov", 
					pmus = c(2, 4, 5, 6, 7, 9, 11), 
					main_txt = "Conifer 5 Covariates",
					add_var = T, 
					highlight_pmu = NULL)
					
		pred_plot("shrub6cov_722", 
					pmus = c(7,10), 
					main_txt = "3 Covariate random winter",
					add_var = T, 
					highlight_pmu = NULL)
		pred_plot(mod = "fullshrub_722", 
					pmus = c(7,10), 
					main_txt = "Shrub full with mass",
					add_var = T, 
					highlight_pmu = NULL)
    dev.off()
		par(mfrow = c(1, 1))		
						
						
		
		
		
		
		
		
		
		
		