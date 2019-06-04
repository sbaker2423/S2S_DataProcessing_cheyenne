# ================================================
# Functions for CFSv2 Analysis - 
#   - Read netCDF with HRU
#   - Read netCDF with grid
# S. Baker, Feb 2018
# ================================================

## libraries
library(ncdf4)
source('/glade/u/home/sabaker/cfsv2/scripts/hru4dig.R')

#### ============== Read NetCDF with HRU variable ============== #### 
readNChru <- function(fileName, varName, fcst = 'cfsv2', avg_fcst_day, daily_avg = TRUE, hruFilter = NA) {
  nc_temp = nc_open(fileName) 
  #print(nc_temp)
  
  ## read variables
  var_raw = ncvar_get(nc_temp, varName) # [hru (x), timestep (y)]
  time_bnds = ncvar_get(nc_temp, 'time_bnds')
  time_vec = time_bnds[1,] #starting date is first in time_bnds
  fcst_date_vec = ncvar_get(nc_temp, 'time')
  hru_vec = ncvar_get(nc_temp, 'hru') # ncvar_get works on dimensions as well as variables

  
  ## convert date - different for cfsv2 and nldas
  if (fcst == 'nldas') {
    date_vec = as.POSIXct(time_vec*86400, origin = '1980-01-01', tz = 'utc') #timeseries of day 1 in fcst
    fcst_date = as.POSIXct((fcst_date_vec - avg_fcst_day)*86400, origin = '1980-01-01', tz = 'utc') #timeseries of forecast date
  }
  if (fcst == 'cfsv2') {
    date_vec = as.POSIXct(as.Date(as.POSIXct(time_vec, origin = '1970-01-01', tz = 'utc'))) #timeseries of day 1 in fcst (fcsted date)
    fcst_date = as.POSIXct(as.Date(as.POSIXct(fcst_date_vec, origin = '1970-01-01', tz = 'utc') - (avg_fcst_day - 1) * 86400)) #timeseries of forecast date
  }
  
  
  ### === convert variable units 
  ## convert temp K ot C
  if (varName == 'tmp2m') {
    var_raw = var_raw -273.15
  }
  
  ## convert mm/hr to mm/d
  if (varName == 'prate' & fcst == 'nldas') {
    var_raw = var_raw * 24
  }
  
  ## CFSv2: convert prate kg/m^2/s to mm/d
  if (varName == 'prate' & fcst == 'cfsv2') {
    var_raw = var_raw * 86400
  }
  
  ## edit HUC4 to add leading zero if three digit number
  # hru_vec = hru4dig(as.matrix(hru_vec))
  
  ## data table of data
  df = data.table(date = rep(date_vec, each = length(hru_vec)),
                  fcst_date = rep(fcst_date, each = length(hru_vec)),
                  hru = rep(hru_vec, times = length(date_vec)), 
                  var = as.vector(var_raw))
  
  ## keep only data for 1999 - 2010
  df = dplyr::filter(df, date < as.POSIXct('2011-01-01', tz = "utc"))
  
  ## filter for a specific hru
  if (!is.na(hruFilter)) {
    df = filter(df, hru == hruFilter)
  }
  
  ## average the daily fcst ensemble
  if (daily_avg) {
    df = df %>% group_by(date, fcst_date, hru) %>% summarise(var= mean(var))
  }
  
  ## get month
  df$mon = as.numeric(strftime(df$fcst_date, format = '%m')) # doy of fcsted day 1 of bi-weekly period
  
  
  return(df)
}

#### ============== Read NetCDF with gridded variable ============== #### 
readNCgrid <- function(fileName, varName, avg_fcst_day = 0, array = FALSE, daily_avg = FALSE) {
  
  nc_temp = nc_open(fileName)
  
  var_raw = ncvar_get(nc_temp, varName) # defaults to an array of n-dimensions (whatever the data is in the netCDF file)
  lon_vec = ncvar_get(nc_temp, 'lon') # ncvar_get works on dimensions as well as variables
  lat_vec = ncvar_get(nc_temp, 'lat')
  time_vec = ncvar_get(nc_temp, 'time')
  time_vec = as.POSIXct(as.Date(as.POSIXct(time_vec, origin = '1970-01-01', tz = 'utc') - (avg_fcst_day - 1+7) * 86400)) #timeseries of forecasted date (day 1)
  
  ## create data.table
  nlon = length(lon_vec)
  nlat = length(lat_vec)
  ntime = length(time_vec)
  
  if(array) {
    var_dt <- array(var_raw, dim=c(nlon,nlat,ntime))
  } else {
    var_dt = data.table(lon = lon_vec, lat = rep(lat_vec, each = nlon), 
                        dateraw = rep(time_vec, each = nlon * nlat), var = as.numeric(var_raw))
  }
  
  ## average the daily fcst ensemble
  if (daily_avg & !(array)) {
    var_dt = var_dt %>% group_by(dateraw, lon, lat) %>% summarise(var= mean(var))
  }
  
  return(var_dt)
}


### get mean variable with heighst and lowest correlations
areaMinMaxCor <- function(var_short, var_long, biwk, mon, hru, min_bound = 0.1, max_bound = 0.1, 
                          thin_n = 0,
                          var_y = 'prate',
                          plot = FALSE,
                          process_full = TRUE,
                          dir_in = '/home/sabaker/s2s/analysis/files/cfsv2_files/cfs_monthly/', 
                          dir_out = '/home/sabaker/s2s/analysis/files/cfsv2_files/corGrids/') {
  
  
  #var_short = c('prmsl_f'); var_long = c('PRMSL_meansealevel'); biwk = biwk_in[k]; mon = m
  setwd(paste0(dir_in, var_short, '/'))
  df_var = readNCgrid(fileName = paste0('cfsv2.', biwk, '.', var_short, '.mon.', mon, '.nc'), 
                       varName = var_long) # date is day 1 of fcsted period
  
  ## read correlation matrix
  setwd(dir_out)
  df_cor_var = readRDS(paste0(var_short, '.', hru, '.' ,var_y, '.thinned.', thin_n, '.rds'))
  df_cor_var = df_cor_var[[paste0(var_short, '.',biwk, '.', mon)]]
  if (plot) { df_cor_map = df_cor_var }
  
  #### === get locations of highest abs correlation
  ## see figure
  # ggplot() + geom_raster(data = df_cor_var, aes(x = lon, y = lat, fill = cor)) +
  #   scale_fill_gradient2(low="navy", mid="white", high="red", midpoint=0, limits=c(-0.8,0.8))
  
  ## == MIN area
  if (var_short != 'z500_f') {
    min_loc = df_cor_var[which.min(df_cor_var$cor),] #$cor
    min_loc_area = df_cor_var[df_cor_var$cor < min_loc$cor + min_bound,]
  } else {
    df_cor_var = filter(df_cor_var, lat >= 10)
    min_loc = df_cor_var[which.min(df_cor_var$cor),] #$cor
    min_loc_area = df_cor_var[df_cor_var$cor < min_loc$cor + min_bound,]
  }
  
  ## check for connected areas
  uniq_min_lat = sort(unique(min_loc_area$lat))
  uniq_min_lon = sort(unique(min_loc_area$lon))
  if (any(abs(c(NA, uniq_min_lat) - c(uniq_min_lat, NA)) > 0.5, na.rm = T) | 
      any(abs(c(NA, uniq_min_lon) - c(uniq_min_lon, NA)) > 0.5, na.rm = T)) {
    
    #get lats closest to highest correlation - check if any need to be removed
    split_lat = as.numeric(which(abs(c(NA, uniq_min_lat) - c(uniq_min_lat, NA)) > 0.5))
    if( length(split_lat) > 0 ) {
      if (length(split_lat > 1)) {print('More than 1 minimum region selected -> lower min_bound')}
      
      v1 = abs(uniq_min_lat[(split_lat - 1)] - min_loc$lat)
      v2 = abs(uniq_min_lat[(split_lat + 1)] - min_loc$lat)
      if (v1 < v2) {
        new_lat = uniq_min_lat[1:(split_lat-1)]
      } else {
        new_lat = uniq_min_lat[split_lat:length(uniq_min_lat)]
      }
    } else {
      new_lat = uniq_min_lat
    }
    
    
    #get lats closest to highest correlation
    split_lon = as.numeric(which(abs(c(NA, uniq_min_lon) - c(uniq_min_lon, NA)) > 0.5))
    if( length(split_lon) > 0 ) {
      if (length(split_lat > 1)) {print('More than 1 minimum region selected -> lower min_bound')}
      
      v1 = abs(uniq_min_lon[(split_lon - 1)] - min_loc$lon)
      v2 = abs(uniq_min_lon[(split_lon + 1)] - min_loc$lon)
      if (v1 < v2) {
        new_lon = uniq_min_lon[1:(split_lon-1)]
      } else {
        new_lon = uniq_min_lon[split_lon:length(uniq_min_lon)]
      }
    } else {
      new_lon = uniq_min_lon
    }
    
    ## assign new area
    min_loc_area = subset(min_loc_area, lon %in% new_lon & lat %in% new_lat)
  }
  
  
  ## print range and unique values
  print('=============================')
  print(paste(c('Minimum correlation is', round(min_loc$cor, digits = 3)), collapse = " ")) 
  print(paste(c('Range of lat for min cor is', range(min_loc_area$lat)), collapse = " ")) 
  print(paste(c('Range of lon for min cor is', range(min_loc_area$lon)), collapse = " ")) 
  print(paste(c('Unique values of lat for min cor are', unique(min_loc_area$lat)), collapse = " "))
  print(paste(c('Unique values of lon for min cor are', unique(min_loc_area$lon)), collapse = " "))
  
  min_loc_area$cor <- NULL
  
  ## == MAX area
  if (var_short != 'z500_f') {
    max_loc = df_cor_var[which.max(df_cor_var$cor),] #$cor
    max_loc_area = df_cor_var[df_cor_var$cor > max_loc$cor - max_bound,]
  } else {
    max_loc = df_cor_var[which.max(df_cor_var$cor),] #$cor
    max_loc_area = df_cor_var[df_cor_var$cor > max_loc$cor - max_bound,]
  }
  
  ## check for connected areas
  uniq_max_lat = sort(unique(max_loc_area$lat))
  uniq_max_lon = sort(unique(max_loc_area$lon))
  if (any(abs(c(NA, uniq_max_lat) - c(uniq_max_lat, NA)) > 0.5, na.rm = T) | 
      any(abs(c(NA, uniq_max_lon) - c(uniq_max_lon, NA)) > 0.5, na.rm = T)) {
    
    #get lats closest to highest correlation - check if any need to be removed
    split_lat = as.numeric(which(abs(c(NA, uniq_max_lat) - c(uniq_max_lat, NA)) > 0.5))
    if( length(split_lat) > 0 ) {
      if (length(split_lat > 1)) {print('More than 1 maximum region selected -> lower max_bound')}
      v1 = abs(uniq_max_lat[(split_lat - 1)] - max_loc$lat)
      v2 = abs(uniq_max_lat[(split_lat + 1)] - max_loc$lat)
      if (v1 < v2) {
        new_lat = uniq_max_lat[1:(split_lat-1)]
      } else {
        new_lat = uniq_max_lat[split_lat:length(uniq_max_lat)]
      }
    } else {
      new_lat = uniq_max_lat
    }
    
    
    #get lats closest to highest correlation
    split_lon = as.numeric(which(abs(c(NA, uniq_max_lon) - c(uniq_max_lon, NA)) > 0.5))
    if( length(split_lon) > 0 ) {
      if (length(split_lat > 1)) {print('More than 1 maximum region selected -> lower max_bound')}
      v1 = abs(uniq_max_lon[(split_lon - 1)] - max_loc$lon)
      v2 = abs(uniq_max_lon[(split_lon + 1)] - max_loc$lon)
      if (v1 < v2) {
        new_lon = uniq_max_lon[1:(split_lon-1)]
      } else {
        new_lon = uniq_max_lon[split_lon:length(uniq_max_lon)]
      }
    } else {
      new_lon = uniq_max_lon
    }
    
    ## assign new area
    max_loc_area = subset(max_loc_area, lon %in% new_lon & lat %in% new_lat)
  }

  ## print range and unique values
  print('=============================')
  print(paste(c('Maximum correlation is', round(max_loc$cor, digits = 3)), collapse = " ")) 
  print(paste(c('Range of lat for max cor is', range(max_loc_area$lat)), collapse = " ")) 
  print(paste(c('Range of lon for max cor is', range(max_loc_area$lon)), collapse = " ")) 
  print(paste(c('Unique values of lat for max cor are', unique(max_loc_area$lat)), collapse = " "))
  print(paste(c('Unique values of lon for max cor are', unique(max_loc_area$lon)), collapse = " "))
  print('=============================')
  
  max_loc_area$cor <- NULL
  
  ## allow for not processing variables to save time while testing
  if (process_full) {
    ## filter var fcsts by lat and long
    dt.result <- merge(data.table(df_var), min_loc_area[, c("lat", "lon")], by.x=c("lat", "lon"), by.y=c("lat", "lon"))
    df_var_minavg = dt.result %>% group_by(dateraw) %>% summarise(varmin = mean(var))
    
    dt.result <- merge(data.table(df_var), max_loc_area[, c("lat", "lon")], by.x=c("lat", "lon"), by.y=c("lat", "lon"))
    df_var_maxavg = dt.result %>% group_by(dateraw) %>% summarise(varmax = mean(var))
    
    ## combine
    df_var = left_join(df_var_maxavg, df_var_minavg, by = "dateraw")
    
    return(df_var)
  }
  
  ## plot figure
  if (plot) {
    cor_area = cbind.data.frame(rbind(max_loc_area, min_loc_area), dot = 1)
    
    p <- plotCor(df = df_cor_map, var_short = var_short, var_y = var_y, 
                 biwk = biwk, mon = mon, corArea = TRUE, cor_df = cor_area)
    
    print(p)
  }
  
}


### plot correlation
plotCor <- function(df, x = 'lon', y = 'lat', fill = 'cor', var_short = '', var_y = '', 
                    biwk = '', mon = '', corArea = FALSE, cor_df = NA) {
  require(ggplot2)
  require(RColorBrewer)
  require(data.table)
  
  ### === plotting things
  # Lon / Lat labels
  ewbrks = seq(0, 360, 20)
  nsbrks = seq(-90, 90, 15)
  ewlbls = unlist(lapply(ewbrks, function(x) ifelse(x > 0, paste0(x, 'ºE'), 	ifelse(x < 0, paste0(abs(x), 'ºW'), x))))
  nslbls = unlist(lapply(nsbrks, function(x) ifelse(x < 0, paste0(abs(x), 	'ºS'), ifelse(x > 0, paste0(x, 'ºN') ,x))))
  
  ## MAP - correct projection, contries
  worldmap = map_data('world2')
  setnames(worldmap, c('X','Y', 'PID', 'POS', 'region', 'subregoin'))
  
  ## bins
  bin_v <- c(-1, -0.6, -0.5, -0.4, -0.3, -0.2, 0.2, 0.3, 0.4, 0.5, 0.6, 1) 
  suppressWarnings(cust_pal <- rev(brewer.pal(n=length(bin_v), name="RdYlBu")))
  
  ## get df
  df_i = cbind.data.frame(lon_i = df[[x]], lat_i = df[[y]], cor = df[[fill]])
  
  
  ## set up bins and color palette
  df_i$bins = cut(df_i$cor, breaks = bin_v)
  labs = levels(df_i$bins)
  
  ## plot figure
  g <- ggplot() + geom_raster(data = df_i, aes(x = lon_i, y = lat_i, fill = bins)) +
    scale_fill_manual(values = cust_pal, name = 'Correlation', drop = F, labels = labs,
                      guide = guide_legend(ncol = 1, label.position = 'right', label.hjust = 0,
                                           title.position = 'top', title.hjust = 0.5, reverse = T,
                                           keywidth = 1, keyheight = 1)) +
    theme_bw() +
    coord_equal() + # ratio of x and y...coord equal preserves the relative sizes of each
    geom_polygon(data = worldmap, aes(X,Y,group=PID), color = 'grey70', size = 0.4, fill = NA) +
    xlab('') +  ylab('') +
    scale_x_continuous(breaks = ewbrks, labels = ewlbls, expand = c(0, 0)) +
    scale_y_continuous(breaks = nsbrks, labels = nslbls, expand = c(0, 0)) + 
    ggtitle(paste0('Correlation Coefficient of ', var_short, 
                   ' & ', var_y, ' - ', month.abb[mon], ' ', biwk, ' bi-weekly period '))
  
  if (corArea) {
    g <- g + 
      geom_point(aes(x = lon, y = lat), data = cor_df, size = 0.05, color = 'grey30')  
  }
  
  return(g)
}



### ===== graph model analysis
residPlots <- function(df, yhat, yres, y, var_nm) {
  require(grid)
  require(gridExtra)
  
  ## get df
  df_fit = cbind.data.frame(y_hat = df[[yhat]], y_res = df[[yres]], y_act = df[[y]])
  
  bins = round(sqrt(nrow(df_fit)))
  
  #Plot vs. Modeled y
  p1 = ggplot(data=df_fit, aes(x = y_act, y = y_hat)) + 
    coord_equal() +
    geom_point() +
    geom_abline(colour = "red") +
    xlab(paste("Observed", var_nm)) +
    ylab(paste("Modeled", var_nm)) +
    ggtitle(paste("Actual vs. Modeled Y")) +
    theme_bw()+
    theme(axis.title = element_text(size=8), plot.title = element_text(size=10))
  
  
  #Histogram of residuals
  p2 = ggplot(df_fit, aes(x = y_res)) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white", bins = bins) + # binwidth = 7
    ylab('Density') +
    xlab('Residual') +
    geom_density(colour = "red") +
    geom_hline(yintercept = 0) + 
    ggtitle("Histogram of Residuals") +
    theme_bw()+
    theme(axis.title = element_text(size=8), plot.title = element_text(size=10))
  
  
  # qqplot
  y <- quantile(df_fit$y_res[!is.na(df_fit$y_res)], c(0.25, 0.75))
  x <- qnorm(c(0.25, 0.75))
  slope <- diff(y)/diff(x)
  int <- y[1L] - slope * x[1L]
  
  #d <- data.frame(resids = df_fit$y_res)
  
  p3 = ggplot(df_fit, aes(sample = y_res)) + 
    stat_qq() + 
    geom_abline(slope = slope, intercept = int, colour = "red") +
    ylab('Sample') +
    xlab('Theoretical') +
    ggtitle("Normal Q-Q Plot")+
    theme_bw()+
    theme(axis.title = element_text(size=8), plot.title = element_text(size=10))
  
  # ACF on residula
  z1=acf(df_fit$y_res, plot = F)
  bacfdf <- with(z1, data.frame(lag, acf))
  p4 = ggplot(data = bacfdf, mapping = aes(x = lag, y = acf)) +
    geom_hline(aes(yintercept = 0.135), colour = "red", linetype = 2) +
    geom_hline(aes(yintercept = -0.135), colour = "red", linetype = 2) +
    geom_segment(mapping = aes(xend = lag, yend = 0)) +
    ylab('ACF') +
    xlab('Lag') +
    ggtitle("Autocorrelation of Residual") +
    geom_hline(yintercept = 0) + 
    theme_bw()+
    theme(axis.title = element_text(size=8), plot.title = element_text(size=10))
  
  #Plot Y estimates against residuals - for constant variance or homoskedasticity..
  p5 = ggplot(data = df_fit, aes(x = y_hat, y = y_res)) + 
    geom_point() +
    xlab(paste("Modeled", var_nm)) +
    ylab(paste("Modeled" , var_nm, "Residuals")) +
    ggtitle(paste("Modeled Y vs. Residuals")) +
    geom_hline(yintercept = 0, colour = "red") + 
    theme_bw() +
    theme(axis.title = element_text(size=8), plot.title = element_text(size=10))
  

  figs = grid.arrange(p1,p2,p3,p4,p5, ncol = 3)
  
  return(print(figs))
}
