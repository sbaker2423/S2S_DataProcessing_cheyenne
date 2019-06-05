# ================================================
# Step 1 - 
# NLDAS & CFSv2 +/- 5 doy average and anomalies
# 1-2 wk avg, 2-3 wk avg, 3-4 wk avg
# S. Baker, March 2017
# ================================================

rm(list=ls())

## Load libraries
library(ncdf4)
library(dplyr)
library(data.table)
library(lubridate)
source('/home/sabaker/s2s/analysis/scripts/cfsv2_analysis/hru4dig.R')

## Directories
dir_in = '/home/sabaker/s2s/analysis/files/cfsv2_files/2wk_avg/'
dir_out = '/home/sabaker/s2s/analysis/files/cfsv2_files/2wk_analysis/'


## Input data
in_data = matrix(c('nldas','prate','NLDAS_1to14day_prate.nc', '1to14day', 7,
                   'nldas','tmp2m','NLDAS_1to14day_tmp2m.nc', '1to14day', 7,
                   'cfsv2','prate','cfsv2_1to14day_prate.nc', '1to14day', 7,
                   'cfsv2','tmp2m','cfsv2_1to14day_tmp2m.nc', '1to14day', 7,
                   
                   'cfsv2','prate','cfsv2_8to21day_prate.nc', '8to21day', 14,
                   'cfsv2','tmp2m','cfsv2_8to21day_tmp2m.nc', '8to21day', 14,
                   
                   'cfsv2','prate','cfsv2_15to28day_prate.nc', '15to28day', 21,
                   'cfsv2','tmp2m','cfsv2_15to28day_tmp2m.nc', '15to28day', 21),
                 nrow = 8, byrow = TRUE)

##### ===== loop through each forecast and variable ===== #####
for (k in 1:nrow(in_data)) {
  fcst = in_data[k,1]
  var_name = in_data[k,2]
  nc_file = in_data[k,3]
  dayavg =  in_data[k,4]
  avg_fcst_d = as.numeric(in_data[k,5])
  
  ##### ===== load and read in netCDF files ===== ##### 
  setwd(dir_in) # set directory
  nc_temp = nc_open(nc_file) 
  
  ## read variables
  var_raw = ncvar_get(nc_temp, var_name) # [hru (x), timestep (y)]
  hru_vec = ncvar_get(nc_temp, 'hru') # ncvar_get works on dimensions as well as variables
  time_bnds = ncvar_get(nc_temp, 'time_bnds')
  time_vec = time_bnds[1,] #starting date is first in time_bnds
  fcst_date_vec = ncvar_get(nc_temp, 'time')
  
  ## convert date - different for cfsv2 and nldas
  if (fcst == 'nldas') {
    date_vec = as.POSIXct(time_vec*86400, origin = '1980-01-01', tz = 'utc') #timeseries of day 1 in fcst
    fcst_date = as.POSIXct((fcst_date_vec - avg_fcst_d)*86400, origin = '1980-01-01', tz = 'utc') #timeseries of forecast date
  }
  if (fcst == 'cfsv2') {
    date_vec = as.POSIXct(as.Date(as.POSIXct(time_vec, origin = '1970-01-01', tz = 'utc'))) #timeseries of day 1 in fcst (fcsted date)
    fcst_date = as.POSIXct(as.Date(as.POSIXct(fcst_date_vec, origin = '1970-01-01', tz = 'utc') - (avg_fcst_d - 1) * 86400)) #timeseries of forecast date
  }
  
  ## get DOY
  doy_vec = as.numeric(strftime(date_vec, format = '%j')) # doy of fcsted day 1 of bi-weekly period
  
  ##### ===== convert variable units ===== ##### 
  ## convert temp K ot C
  if (var_name == 'tmp2m') {
    var_raw = var_raw -273.15
  }
  
  ## convert mm/hr to mm/d
  if (var_name == 'prate' & fcst == 'nldas') {
    var_raw = var_raw * 24
  }
  
  ## CFSv2: convert prate kg/m^2/s to mm/d
  if (var_name == 'prate' & fcst == 'cfsv2') {
    var_raw = var_raw * 86400
  }
  
  ## edit HUC4 to add leading zero if three digit number
  hru_vec = hru4dig(as.matrix(hru_vec))
  
  ## data table of data
  df = data.table(date = rep(date_vec, each = length(hru_vec)),
                  fcst_date = rep(fcst_date, each = length(hru_vec)),
                  doy = rep(doy_vec, each = length(hru_vec)), 
                  hru = rep(hru_vec, times = length(date_vec)), 
                  var = as.vector(var_raw))
  
  ## keep only data for 1999 - 2010
  df_11yr = dplyr::filter(df,date < as.Date('2011-01-01')) %>% group_by(date)
  
  
  ##### ===== +/- 5 doy average ===== ##### 
  doy1_11Dayavg = matrix(as.numeric(0), nrow = 365 * length(hru_vec), ncol = 3)
  for (i in 1:length(hru_vec)) {
    df_hru = dplyr::filter(df_11yr,hru == hru_vec[i]) %>% group_by(date)
    
    for (j in 1:365) {
      # average accounting for beginning and end date wrap 1999 - 2010
      if (j <= 5 ) {
        avg = with(df_hru, mean(var[doy >= (365 + j - 5)  | doy <= (j + 5) ]))
      } else if (j >= 360) {
        avg = with(df_hru, mean(var[doy >= (j - 5)  | doy <= (j - 365 + 5) ]))
      } else {
        avg = with(df_hru, mean(var[doy >= (j - 5) & doy <= (j + 5) ]))
      }
      
      doy1_11Dayavg[(365 * (i - 1) + j),1] = as.numeric(hru_vec[i])
      doy1_11Dayavg[(365 * (i - 1) + j),2] = j
      doy1_11Dayavg[(365 * (i - 1) + j),3] = as.double(avg)
    }
  }
  
  ## create data frame & edit hru
  if (var_name == 'tmp2m') {
    tmp2m_11DoyAVG = data.frame(hru = doy1_11Dayavg[,1], doy = doy1_11Dayavg[,2], var.degC = doy1_11Dayavg[,3])
    doy_avg = hru4dig(tmp2m_11DoyAVG)
  }
  
  if (var_name == 'prate') {
    ## create dataframe and edit hru
    prate_11DoyAVG = data.frame(hru = doy1_11Dayavg[,1], doy = doy1_11Dayavg[,2], var.mmPerDay = doy1_11Dayavg[,3])
    doy_avg = hru4dig(prate_11DoyAVG)
  }
  
  
  ##### ===== Create anomaly timeseries ===== ##### 
  colnames(doy_avg) <- c('hru', 'doy', 'var')
  
  ## change doy 366 to 365
  df_11yr$doy[df_11yr$doy == 366 ] = 365
  
  ## join and calculate anomalies
  df_merg = left_join(df_11yr, doy_avg, by = c("hru","doy"))
  df_merg$anom = df_merg$var.x - df_merg$var.y # x=data, y = doy
  
  ## create data frame
  if (var_name == 'tmp2m') {
    colnames(df_merg)  <- c('date','fcst_date', 'doy', 'hru', 'var.degC', 'avgDoy.degC', 'anom.degC') 
  }
  if (var_name == 'prate') {
    colnames(df_merg)  <- c('date','fcst_date', 'doy', 'hru', 'var.mmPerD', 'avgDoy.mmPerD', 'anom.mmPerD') 
  }
  
  ## save
  setwd(dir_out) # set directory
  saveRDS(doy_avg, file = paste0(fcst,'_',var_name,'_doyAVG_',dayavg,'.rds'))
  saveRDS(df_merg, file = paste0(fcst,'_',var_name,'_anom_',dayavg,'.rds'))
}


##### ===== load and save combined data ===== #####
setwd(dir_out)

## == cfsv2 - doy is fcsted

## cfsv2 data -- prate
prate_doyAVG_1.14 = readRDS('cfsv2_prate_doyAVG_1to14day.rds')
prate_doyAVG_8.21 = readRDS('cfsv2_prate_doyAVG_8to21day.rds')
prate_doyAVG_15.28 = readRDS('cfsv2_prate_doyAVG_15to28day.rds')
prate_doy = rbind(cbind(prate_doyAVG_1.14, lead = '1_2'), cbind(prate_doyAVG_8.21, lead = '2_3'), cbind(prate_doyAVG_15.28, lead = '3_4'))
# saveRDS(prate_doy, 'cfsv2_prate_doyAVG.rds')

## cfsv2 data -- tmp2m
tmp2m_doyAVG_1.14 = readRDS('cfsv2_tmp2m_doyAVG_1to14day.rds')
tmp2m_doyAVG_8.21 = readRDS('cfsv2_tmp2m_doyAVG_8to21day.rds')
tmp2m_doyAVG_15.28 = readRDS('cfsv2_tmp2m_doyAVG_15to28day.rds')
tmp2m_doy = rbind(cbind(tmp2m_doyAVG_1.14, lead = '1_2'), cbind(tmp2m_doyAVG_8.21, lead = '2_3'), cbind(tmp2m_doyAVG_15.28, lead = '3_4'))
# saveRDS(tmp2m_doy, 'cfsv2_tmp2m_doyAVG.rds')

# combined and save
doy_avg = rbind.data.frame(cbind(prate_doy, var_name = 'prate'), cbind(tmp2m_doy, var_name = 'tmp2m'))
saveRDS(doy_avg, 'cfsv2_doyAVG.rds')

## == nldas - doy is fcsted
prate_doyAVG_1.14 = readRDS('nldas_prate_doyAVG_1to14day.rds')
tmp2m_doyAVG_1.14 = readRDS('nldas_tmp2m_doyAVG_1to14day.rds')

# repeat so there is data for each lead
prate_doy = rbind(cbind(prate_doyAVG_1.14, lead = '1_2'), cbind(prate_doyAVG_1.14, lead = '2_3'), cbind(prate_doyAVG_1.14, lead = '3_4'))
tmp2m_doy = rbind(cbind(tmp2m_doyAVG_1.14, lead = '1_2'), cbind(tmp2m_doyAVG_1.14, lead = '2_3'), cbind(tmp2m_doyAVG_1.14, lead = '3_4'))

# combine data
doy_avg = rbind.data.frame(cbind(prate_doy, var_name = 'prate'), cbind(tmp2m_doy, var_name = 'tmp2m'))
saveRDS(doy_avg, 'nldas_doyAVG.rds')
