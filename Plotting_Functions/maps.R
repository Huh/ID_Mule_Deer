		#  Hurley et al Hierarchal Mule Deer Survival Plotting Functions
		#  Maps functions
		#  Josh Nowak
		#  07/2015
#################################################################################
		study_area <- function(gmu_border = "gray25", gmu_txt = "gray25",
								pmu_border = "gray90", pmu_txt = "white",
								pmu_fill = c("green3", "darkgreen", 
												"navajowhite4"),
								bground = "terrain-background"){
			#  A function to create a map of the study area with arguments to
			#  control text_color at the gmu and pmu levels, shading color of
			#  pmu's and bground or background map.  The background map that is 
			#  desired and can be any of the ?get_map options under the stamen 
			#  dataset.
			#  Requires an internet connection to run!!!
			#  The function returns nothing, but creates a plot
			load(file.path(getwd(), "data", "gmu_labs.RData"))
			load(file.path(getwd(), "data", "pmu_labs.RData"))
			load(file.path(getwd(), "data", "id_fort.RData"))
			load(file.path(getwd(), "data", "pmu_fort.RData"))			
			load(file.path(getwd(), "data", "map_zoom.RData"))
			
			#  Get background map
			#  All options listed under ?get_map
			bckgrd <- get_map(location = map_zoom, 
						source = "stamen",
						maptype = bground,
						color= "bw")
			
			#  Create plot
			ggmap(bckgrd) +
				geom_polygon(data = id_fort, 
								aes(x = long, y = lat, group = group),
								fill = NA, colour = gmu_border, size = 1.1) +
				geom_text(data = gmu_labs, aes(x=x, y=y, label = GMU, 
							hjust = 0.5, vjust = 0.5), size = 2.5, 
							colour = gmu_txt) +
				geom_polygon(data = id_fort[!is.na(id_fort$PMU),], 
								aes(x = long, y = lat, group = group, 
									fill = Ecotype),
								alpha = 0.7) +
				geom_polygon(data = pmu_fort,
								aes(x = long, y = lat, group = group),
								fill = NA, colour = pmu_border, size = 1.7) +
				geom_text(data = pmu_labs, aes(x=x, y=y, label = PMU, 
							hjust = 0.5, vjust = 0.5, fontface = "bold"), 
							size = 3.4,	colour = pmu_txt) +
				xlab("Latitude") +
				ylab("Longitude") +
				scale_fill_manual(values = pmu_fill)		
		}
#################################################################################
		rand_map <- function(){
		
		
		}

		