		require(ggmap)
		
		#  Transform projection of data
		id2 <- spTransform(id, CRS("+proj=longlat +datum=WGS84"))
		map_zoom <- bbox(id2) + c(-0.01, -0.01, 0.01, 0.01)
		pmu2 <- spTransform(pmus, CRS("+proj=longlat +datum=WGS84"))
		eco2 <- spTransform(eco, CRS("+proj=longlat +datum=WGS84"))
		
		#  Create layers that ggplot can interpret
		id_fort<- fortify(id2, region = "GMU") %>%
					group_by(id) %>%
					mutate(PMU = cross$PMU[match(id, cross$GMU)],
							Ecotype = cross$Ecotype[match(id, cross$GMU)])
		pmu_fort <- fortify(pmu2)
		gmu_labs <- as.data.frame(gCentroid(id2, byid = T)) %>%
					mutate(GMU = id2$GMU)
		pmu_labs <- as.data.frame(gCentroid(pmu2, byid = T)) %>%
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

		#  Get background map
		#  All options listed under ?get_map
		bckgrd <- get_map(location = map_zoom, 
					source = "stamen",
					maptype = "terrain-background",
					color= "bw")
		
		
		ggmap(bckgrd) +
			geom_polygon(data = id_fort, 
							aes(x = long, y = lat, group = group),
							fill = NA, colour = "gray25", size = 1.1) +
			geom_text(data = gmu_labs, aes(x=x, y=y, label = GMU, hjust = 0.5,
						vjust = 0.5), size = 2.5, 
						colour = "gray25") +
			geom_polygon(data = id_fort[!is.na(id_fort$PMU),], 
							aes(x = long, y = lat, group = group, fill = Ecotype),
							alpha = 0.7) +
			geom_polygon(data = pmu_fort,
							aes(x = long, y = lat, group = group),
							fill = NA, colour = "gray90", size = 1.7) +
			geom_text(data = pmu_labs, aes(x=x, y=y, label = PMU, hjust = 0.5,
						vjust = 0.5, fontface = "bold"), size = 3.4,
						colour = "white") +
			xlab("Latitude") +
			ylab("Longitude") +
			scale_fill_manual(values = c("green3", "darkgreen", 
								"navajowhite4"))
			
			