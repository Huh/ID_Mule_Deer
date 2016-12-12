		#  Hurley et al Hierarchal Mule Deer Survival 
		#  Shapefile creation 
		#  Josh Nowak
		#  07/2015
		#  This script is shared to document the workflow
		#  Data is not shared and so the script cannot be repeated on other CPU's
#################################################################################
		#  Load Packages
		require(dplyr)
		require(sp)
		require(rgdal)
		require(maptools)	
		require(rgeos)
#################################################################################
		#  Load data
		#  Start with GMU map on Josh's harddrive
		x <- readOGR(dsn = "C:/GIS/IDGMUs/gmu2", 
						layer = "Mule_Deer_Harvest_Statistics_by_GMU_2013")
		
		#  Get outline of Idaho
		outline <- readOGR(dsn = "C:/GIS/IDGMUs", layer = "IDoutline")
		
		#  Get basic GMU to PMU reference for entire state
		load("C:/Users/josh.nowak/Documents/GitHub/Idaho/gmuDau.RData")
		
		#  Get data with GMU to PMU to Ecotype reference for monitored areas
		# ref <- read.csv("C:/Users/josh.nowak/Dropbox/MarkSurv/Allfawns.csv") %>%
				# select(GMU, PMU, Ecotype) %>%
				# distinct(.) %>%
				# arrange(GMU) %>%
				# write.csv(., file = "C:/Users/josh.nowak/Dropbox/MarkSurv/ref_tmp.csv")
		
		ref <- read.csv("C:/Users/josh.nowak/Dropbox/MarkSurv/ref_tmp.csv")		
		
		#  Relate ref to x and subset x retaining only those polygons that have
		#  values for unit, pmu and ecotype
		cross <- ref[match(x$GMU, ref$GMU),]
		cross$GMU <- x$GMU
		rownames(cross) <- getSpPPolygonsIDSlots(x)

		id <- SpatialPolygonsDataFrame(x, data = cross)
		pmus <- unionSpatialPolygons(x, cross$PMU)

		#  Transform projection of data
		id <- spTransform(id, CRS("+proj=longlat +datum=WGS84"))
		map_zoom <- bbox(id) + c(-0.01, -0.01, 0.01, 0.01)
		pmus <- spTransform(pmus, CRS("+proj=longlat +datum=WGS84"))
		
		#  Create layers that ggplot can interpret
		id_fort <- fortify(id, region = "GMU") %>%
					group_by(id) %>%
					mutate(PMU = cross$PMU[match(id, cross$GMU)],
							Ecotype = cross$Ecotype[match(id, cross$GMU)])
		pmu_fort <- fortify(pmus)
		gmu_labs <- as.data.frame(gCentroid(id, byid = T)) %>%
					mutate(GMU = id$GMU)
		pmu_labs <- as.data.frame(gCentroid(pmus, byid = T)) %>%
					mutate(PMU = rownames(.))
					
		#  Manually adjust label positions...ewwww
		pmu_labs$x[2] <- -115.8
		pmu_labs$y[2] <- 43.71
		pmu_labs$x[4] <- -114.9
		pmu_labs$y[4] <- 44.27
		pmu_labs$x[7] <- -113.1		
		pmu_labs$y[7] <- 44.28
		pmu_labs$x[8] <- -111.4
		pmu_labs$y[8] <- 43.73

		#  Save output
		save(map_zoom, file = "C:/Users/josh.nowak/Dropbox/MarkSurv/data/map_zoom.RData")
		save(id_fort, file = "C:/Users/josh.nowak/Dropbox/MarkSurv/data/id_fort.RData")
		save(gmu_labs, file = "C:/Users/josh.nowak/Dropbox/MarkSurv/data/gmu_labs.RData")
		save(pmu_fort, file = "C:/Users/josh.nowak/Dropbox/MarkSurv/data/pmu_fort.RData")
		save(pmu_labs, file = "C:/Users/josh.nowak/Dropbox/MarkSurv/data/pmu_labs.RData")
#################################################################################
		#  End
				
		