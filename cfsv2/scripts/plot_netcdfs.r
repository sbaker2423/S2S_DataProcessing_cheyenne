#!/usr/bin/env Rscript

# only for precip and temp!

# ====== Script: Plot HUC4 precip and temp forecast ======

args <- commandArgs(TRUE)

#TEST
#args = c("/glade/u/home/sabaker/cfsv2/scripts/prate_test_fcst.nc","/glade/u/home/sabaker/cfsv2/scripts/test.nc","prate","1") #test

if(length(args) < 4) {
  print("Usage: plot_HUC4_cfsv2.Rscr <input netcdf file  eg. '/glade/scratch/sabaker/cfsv2/HUC4XCONUS/prate/2010/...nc'> <output plot eg. '/glade/scratch/sabaker/cfsv2/plots/test.png'>
        <varaible eg. tmp_2m, prate> <time step eg. '1'>")
  quit(save = 'no', status = 1, runLast = FALSE)
}

# Assign variables from arguments
nc_name = args[1]
plot_loc = args[2]
var_name = args[3] #variable to read
plot_ts = args[4] #timestep number to be plotted


# graphing executable - take graphs out of process_netcdf.r and make it generic

#change how date is dealt with, paths, names of saved file, also for precipitation - change color and legend


##### ===== Load Libraries ===== #####
library(data.table)
library(dplyr)  
library(lubridate)
library(readr)
library(tidyr)
library(ncdf4)
library(ggplot2)
library(RColorBrewer)
library(rgdal)
library(rgeos)
library(raster)
library(PBSmapping)
library(stringr)


##### ===== Script Setup ===== #####

## Directories - input
#dir_nc_output = '/glade/scratch/sabaker/cfsv2/HUC4XCONUS/'
#dir_plots = '/glade/scratch/sabaker/cfsv2/plots/'
#dir_HUCshapefile = '/home/sabaker/s2s/cfsv2/files/CorrespondenceTable/HUC4/' #NHDPlusv2_HUC4
dir_HUCmatrix = '/glade/u/home/sabaker/cfsv2/scripts/'

setwd("/")

## netCDF information - input
# nc_name = 'tmp_2m_test_fcst.nc'
# var_name = 'tmp_2m' #variable to read
#nc_name = 'prate_test_fcst.nc'
#var_name = 'prate' #variable to read

#plot_ts = 1 #timestep number to be plotted

## load in your netCDF file
#setwd(dir_nc_output)
nc_temp = nc_open(nc_name)

## read variables
var_raw = ncvar_get(nc_temp, var_name) # [hru (x), timestep (y)]
time_vec = ncvar_get(nc_temp, 'time')
hru_vec = ncvar_get(nc_temp, 'hru') # ncvar_get works on dimensions as well as variables
date_vec = as.POSIXct(time_vec, origin = '1970-01-01', tz = 'utc') #timeseries of forecast

## create matrix of HUC4s with variable for desired timestep
plot_date = date_vec[plot_ts] #forecast data of plot
ts_name = str_replace_all(substr(as.character(plot_date),1,13),' ','_')
dt_1 = data.frame(tmp_2m = var_raw[,plot_ts], HUC4 = hru_vec)

## edit HUC4 to add leading zero if three digit number
for (i in 1:nrow(dt_1)) {
  if (as.numeric(dt_1[i,2]) <= 999) {
    dt_1[i,2] = paste0("0",dt_1[i,2])
  } 
}

## round variable data
#dt_1$tmp_2m = round(dt_1$tmp_2m, digits = 2)


##### ===== Shapefile Setup ===== #####
# --> *only needs to be done when setting up a new HUC shapefile*

# ## Read in HUC4 basins
# setwd(dir_HUCshapefile)
# huc4 = readOGR(dsn = '.', layer = 'NHDPlusv2_HUC4')
# 
# # creates a 'id' column in the data attribute table
# huc4@data$id = rownames(huc4@data)
# # pulls out the attribute table into a data frame
# huc4_attr = huc4@data
# # simplifies the shapefile to speed up plotting
# huc4_simp = gSimplify(huc4, tol = .065, topologyPreserve = F) #.1 F
# # turns R spatial object into a data frame for plotting
# huc4_dt = fortify(huc4_simp, polyid = 'id')
# # adds attributes to the data_frame
# huc4_dt = left_join(huc4_dt, huc4_attr)
# 
# ## Save huc4_dt
# setwd(dir_HUCmatrix)
# save(huc4_dt, file = 'HUC4_df.RData')


##### ===== Read HUC4 data and combine with forecast ===== #####

## Read in huc4_dt rstudio file for use
#setwd(dir_HUCmatrix)
load('/glade/u/home/sabaker/cfsv2/scripts/HUC4_df.RData')

# join matricies by HUC4 id
var_huc = left_join(huc4_dt, dt_1, by = "HUC4")


##### ====== Plotting ====== #####

## commands for making pretty spatial Lon / Lat labels
ewbrks = seq(-180, 180, 10)
nsbrks = seq(-50, 50, 10)
ewlbls = unlist(lapply(ewbrks, function(x) ifelse(x > 0, paste0(x, 'ºE'), 	ifelse(x < 0, paste0(abs(x), 'ºW'), x))))
nslbls = unlist(lapply(nsbrks, function(x) ifelse(x < 0, paste0(abs(x), 	'ºS'), ifelse(x > 0, paste0(x, 'ºN') ,x))))

## Color palettes and labels for temp vs. prate
if (var_name == 'tmp_2m') {
  #cust_pal = c('#67a9cf','#f7f7f7','#ef8a62')
  cust_pal = c('#0571b0','#92c5de','#f7f7f7','#f4a582','#ca0020')
  legend_title = 'Temperature (K)'
} else if (var_name == 'prate') {
  cust_pal = c('#edf8b1','#7fcdbb','#2c7fb8')
  cust_pal = c('#f0f9e8','#bae4bc','#7bccc4','#43a2ca','#0868ac')
  legend_title = 'Precipitation Rate (kg/m^2/s)'
} else {
  print('variable unknown -- use tmp_2m or prate')
}

## a custom color palette
#cust_pal = c('#A25E27', '#A25E27', '#E6D46D', '#FFFC8F', '#80A319', '#289E17', '#1D9462', '#1D0085', '#F489FF')
# temperature color scheme
# cust_pal = c('#F489FF','#1D0085', '#1D9462', '#289E17',  '#80A319', '#FFFC8F', '#E6D46D', '#A25E27','#A25E27')

## cut border polygon from world map to CONUS domain
worldmap = map_data('world')
setnames(worldmap, c('X','Y', 'PID', 'POS', 'region', 'subregoin'))
worldmap = clipPolys(worldmap, xlim = c(-130, -60), ylim = c(20, 54))

## plot
ggplot(data = var_huc, aes(x = long, y = lat, group = HUC4, fill = tmp_2m)) + 
  # add boarders
  geom_polygon(data = worldmap, aes(X,Y,group=PID), color = NA, size = 0.5, fill = 'grey92') + 
  # HUC4 polygon setup
  geom_polygon() + 
  # fill color scale, legend appearance and title
  scale_fill_gradientn(colours = cust_pal, na.value = 'NA', name = legend_title, guide = guide_colorbar(title.position = 'bottom', barwidth = 20, barheight = 0.5, title.hjust = 0.5)) + 
  # Draw HUC polygons
  geom_path(color = 'gray81', size = 0.15) +
  # ggplot has built-in themes
  theme_bw() + 
  # legend location...theme can take in other appearance / layout arguments - NOTE, if used with a built-in theme, e.g. theme_bw() it needs to be called after to not get overridden
  theme(legend.position = 'bottom') +
  # ratio of x and y...coord equal preserves the relative sizes of each
  coord_equal() +
  # label on the x axis
  xlab('') +  
  # label on the y axis
  ylab('') + 
  # tic mark locations and labels on the x axis
  scale_x_continuous(breaks = ewbrks, labels = ewlbls, expand = c(0, 0)) +
  # tic mark locations and labels on the y axis 
  scale_y_continuous(breaks = nsbrks, labels = nslbls, expand = c(0, 0)) + 
  # set margins (wider on right)
  theme(plot.margin=unit(c(0.15,0.5,0.15,0.05),'cm')) #top, right, bottom, left

## save plot
#setwd(dir_plots)
ggsave(plot_loc, height = 6, width = 10, dpi = 100)


## would be nice to plot as a raster opposed to filling in polygons
