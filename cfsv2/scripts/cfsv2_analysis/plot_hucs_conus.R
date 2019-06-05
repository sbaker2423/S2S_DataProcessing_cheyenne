## maybe delete?
dir_HUCshapefile = '/home/sabaker/s2s/cfsv2/files/CorrespondenceTable/HUC4/' #NHDPlusv2_HUC4
dir_HUCmatrix = '/home/sabaker/s2s/cfsv2/files/plotting/'
dir_plots = '/home/sabaker/s2s/analysis/files/plots/'
source('~/s2s/analysis/scripts/cfsv2_analysis/plot_function.r', echo=TRUE)

library(rgdal)
library(rgeos)
library(ggplot2)
library(dplyr)

#### ===== Shapefile Setup ===== #####
#--> *only needs to be done when setting up a new HUC shapefile*

## Read in HUC4 basins
setwd(dir_HUCshapefile)
huc4 = readOGR(dsn = '.', layer = 'NHDPlusv2_HUC4')

# commands for making pretty spatial Lon / Lat labels
ewbrks = seq(-180, 180, 10)
nsbrks = seq(-50, 50, 10)
ewlbls = unlist(lapply(ewbrks, function(x) ifelse(x > 0, paste0(x, '°E'), 	ifelse(x < 0, paste0(abs(x), '°W'), x))))
nslbls = unlist(lapply(nsbrks, function(x) ifelse(x < 0, paste0(abs(x), 	'°S'), ifelse(x > 0, paste0(x, '°N') ,x))))


## cut border polygon from world map to CONUS domain
worldmap = map_data('world')
setnames(worldmap, c('X','Y', 'PID', 'POS', 'region', 'subregoin'))
worldmap = PBSmapping::clipPolys(worldmap, xlim = c(-126, -66), ylim = c(24, 54))

# p = ggplot(data = var_huc, aes(x = long, y = lat, group = hru, fill = bins)) + 
#   # add boarders
#   geom_polygon(data = worldmap, aes(X,Y,group=PID), color = NA, size = 0.5, fill = 'grey85') + 
#   # HUC4 polygon setup
#   geom_polygon() + 

# plot(huc4, col="cyan1", border="black", lwd=3,
#      main="AOI Boundary Plot")

# creates a 'id' column in the data attribute table
huc4@data$id = rownames(huc4@data)
# pulls out the attribute table into a data frame
huc4_attr = huc4@data
# simplifies the shapefile to speed up plotting
huc4_simp = gSimplify(huc4, tol = .086, topologyPreserve = F) #.065 F
# turns R spatial object into a data frame for plotting
huc4_dt = fortify(huc4_simp, polyid = 'id')
# adds attributes to the data_frame
huc4_dt = left_join(huc4_dt, huc4_attr)

cols = rainbow(232, s=.8, v=0.9)[sample(1:232,232)]

ggplot()  +
  # add boarders
  geom_polygon(data = worldmap, aes(X,Y,group=PID), color = NA, size = 0.5, fill = 'grey90') + 
  # state borders
  geom_polygon(data=map_data("state"), aes(x=long, y=lat, group=group), color="grey42", size = 0.3, fill=NA, linetype = 'dashed')+
  # tic mark locations and labels on the x axis
  geom_polygon(data = huc4_dt, aes(long,lat, group=group, fill = group), color = 'gray60', alpha = 0.23, size = 0.15) + #'gray73'fill = NA,
  #scale_color_brewer(pallette = "Set2") +
  scale_fill_manual(values=cols) +
  #geom_path(color="black", fill = NA) +
  geom_path(color = 'gray73', size = 0.15) + #grey60
  # ggplot has built-in themes
  theme_bw() + 
  coord_equal() +
  # label on the x axis
  xlab('') +  
  # label on the y axis
  ylab('') + 
    scale_x_continuous(breaks = ewbrks, labels = ewlbls, expand = c(0, 0)) +
  # tic mark locations and labels on the y axis 
  scale_y_continuous(breaks = nsbrks, labels = nslbls, expand = c(0, 0)) + 
  # set margins (wider on right)
  theme(plot.margin=unit(c(0.15,0.5,0.15,0.05),'cm'), legend.position = 'none') #top, right, bottom, left 
   # scale_fill_brewer("Utah Ecoregion")
  
setwd(dir_plots)
ggsave('hucs_conus.png', height = 6/1.5, width = 10/1.5, dpi = 400)

## Save huc4_dt
#setwd(dir_HUCmatrix)
#save(huc4_dt, file = 'HUC4_df.RData')

