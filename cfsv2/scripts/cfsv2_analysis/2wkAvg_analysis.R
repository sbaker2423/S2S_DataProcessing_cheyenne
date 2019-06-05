# ===========================================
# Step 2 - 
# Statistics Calculation
# takes in data from '2wkAvg_calcAnom.R'
# S. Baker, March 2017
# ===========================================
rm(list=ls())

## Load libraries
library(dplyr)
library(hydroGOF) #pbias
source('/home/sabaker/s2s/analysis/scripts/hru4dig.R')

## Directories
dir_in = '/home/sabaker/s2s/analysis/files/2wk_analysis/'

## Set working directory
setwd(dir_in)

##### ===== load data ===== #####
## cfsv2 data -- prate
cfs_pr.anom_1.14 = readRDS('cfsv2_prate_anom_1to14day.rds')
cfs_pr.anom_8.21 = readRDS('cfsv2_prate_anom_8to21day.rds')
cfs_pr.anom_15.28 = readRDS('cfsv2_prate_anom_15to28day.rds')
## cfsv2 data -- tmp2m
cfs_tm.anom_1.14 = readRDS('cfsv2_tmp2m_anom_1to14day.rds')
cfs_tm.anom_8.21 = readRDS('cfsv2_tmp2m_anom_8to21day.rds')
cfs_tm.anom_15.28 = readRDS('cfsv2_tmp2m_anom_15to28day.rds')
## nldas data -- prate
nld_pr.anom = readRDS('nldas_prate_anom_1to14day.rds')
nld_pr.anom$fcst_date <- NULL
## nldas data -- tmp2m
nld_tm.anom = readRDS('nldas_tmp2m_anom_1to14day.rds')
nld_tm.anom$fcst_date <- NULL

## hru vec
hru_vec = unique(cfs_pr.anom_1.14$hru)

##### ===== Mean of each day's forecasts ===== #####
cfs_pr.anom_1.14 = cfs_pr.anom_1.14 %>% group_by(fcst_date,hru) %>% summarise_each(funs(mean))
cfs_pr.anom_8.21 = cfs_pr.anom_8.21 %>% group_by(fcst_date,hru) %>% summarise_each(funs(mean))
cfs_pr.anom_15.28 = cfs_pr.anom_15.28 %>% group_by(fcst_date,hru) %>% summarise_each(funs(mean))

cfs_tm.anom_1.14 = cfs_tm.anom_1.14 %>% group_by(fcst_date,hru) %>% summarise_each(funs(mean))
cfs_tm.anom_8.21 = cfs_tm.anom_8.21 %>% group_by(fcst_date,hru) %>% summarise_each(funs(mean))
cfs_tm.anom_15.28 = cfs_tm.anom_15.28 %>% group_by(fcst_date,hru) %>% summarise_each(funs(mean))

##### ===== Mean Error, Mean Absolute Error, Correlation & Bias ===== #####

### Calculate mean error and mean absolute error - join by date (begin 2 wk period)

## Temperature -
# 1-2 week avg
tmp2m_1.14 = left_join(cfs_tm.anom_1.14, nld_tm.anom, by = c("hru","date", "doy"), suffix = c('.cfs', '.nld')) 
tmp2m_1.14$error = tmp2m_1.14$var.degC.nld - tmp2m_1.14$var.degC.cfs
# 2-3 week avg
tmp2m_8.21 = left_join(cfs_tm.anom_8.21, nld_tm.anom, by = c("hru","date", "doy"), suffix = c('.cfs', '.nld')) 
tmp2m_8.21$error = tmp2m_8.21$var.degC.nld - tmp2m_8.21$var.degC.cfs
# 3-4 week avg
tmp2m_15.28 = left_join(cfs_tm.anom_15.28, nld_tm.anom, by = c("hru","date", "doy"), suffix = c('.cfs', '.nld')) 
tmp2m_15.28$error = tmp2m_15.28$var.degC.nld - tmp2m_15.28$var.degC.cfs
# list of differenet time periods
tmp2m_list = list(tmp2m_1.14, tmp2m_8.21, tmp2m_15.28)

## Precip. Rate -
# 1-2 week avg
prate_1.14 = left_join(cfs_pr.anom_1.14, nld_pr.anom, by = c("hru","date", "doy"), suffix = c('.cfs', '.nld')) 
prate_1.14$error = prate_1.14$var.mmPerD.nld - prate_1.14$var.mmPerD.cfs
# 2-3 week avg
prate_8.21 = left_join(cfs_pr.anom_8.21, nld_pr.anom, by = c("hru","date", "doy"), suffix = c('.cfs', '.nld')) 
prate_8.21$error = prate_8.21$var.mmPerD.nld - prate_8.21$var.mmPerD.cfs
# 3-4 week avg
prate_15.28 = left_join(cfs_pr.anom_15.28, nld_pr.anom, by = c("hru","date", "doy"), suffix = c('.cfs', '.nld')) 
prate_15.28$error = prate_15.28$var.mmPerD.nld - prate_15.28$var.mmPerD.cfs
# list of differenet time periods
prate_list = list(prate_1.14, prate_8.21, prate_15.28)

## calculate percent bias and correlation
tmp2m_stats = matrix(as.numeric(0), nrow = length(hru_vec), ncol = 15)
prate_stats = matrix(as.numeric(0), nrow = length(hru_vec), ncol = 15)

# for each lead time
for (j in 1:3) {
  tmp2m_df = tmp2m_list[[j]]
  prate_df = prate_list[[j]]
  
  # calc stats for each hru
  for (i in 1:length(hru_vec)) {
    hru_prate = dplyr::filter(prate_df,hru == hru_vec[i])
    hru_tmp2m = dplyr::filter(tmp2m_df,hru == hru_vec[i])
    
    # calculate prate stats for given time period
    prate_stats[i,(1 +(j-1)*5)] = mean(hru_prate$error)
    prate_stats[i,(2 +(j-1)*5)] = abs(mean(hru_prate$error))
    prate_stats[i,(3 +(j-1)*5)] = pbias(hru_prate$var.mmPerD.cfs, hru_prate$var.mmPerD.nld)
    prate_stats[i,(4 +(j-1)*5)] = cor(hru_prate$var.mmPerD.cfs, hru_prate$var.mmPerD.nld)
    prate_stats[i,(5 +(j-1)*5)] = cor(hru_prate$anom.mmPerD.cfs, hru_prate$anom.mmPerD.nld)
    
    # calculate prate stats for given time period
    tmp2m_stats[i,(1 +(j-1)*5)] = mean(hru_tmp2m$error)
    tmp2m_stats[i,(2 +(j-1)*5)] = abs(mean(hru_tmp2m$error))
    tmp2m_stats[i,(3 +(j-1)*5)] = pbias(hru_tmp2m$var.degC.cfs, hru_tmp2m$var.degC.nld)
    tmp2m_stats[i,(4 +(j-1)*5)] = cor(hru_tmp2m$var.degC.cfs, hru_tmp2m$var.degC.nld)
    tmp2m_stats[i,(5 +(j-1)*5)] = cor(hru_tmp2m$anom.degC.cfs, hru_tmp2m$anom.degC.nld)
  }
}

# add hru vec
tmp2m_stats = cbind.data.frame(hru_vec,tmp2m_stats)
prate_stats = cbind.data.frame(hru_vec,prate_stats)

# label columns
colnames(tmp2m_stats) <- c('hru', 'meanErr.1-2wk', 'absmeanErr.1-2wk' ,'pbias.1-2wk', 'cor.1-2wk','acc.1-2wk',
                           'meanErr.2-3wk', 'absmeanErr.2-3wk' ,'pbias.2-3wk', 'cor.2-3wk','acc.2-3wk',
                           'meanErr.3-4wk', 'absmeanErr.3-4wk' ,'pbias.3-4wk', 'cor.3-4wk','acc.3-4wk')
colnames(prate_stats) <- c('hru', 'meanErr.1-2wk', 'absmeanErr.1-2wk' ,'pbias.1-2wk', 'cor.1-2wk','acc.1-2wk',
                           'meanErr.2-3wk', 'absmeanErr.2-3wk' ,'pbias.2-3wk', 'cor.2-3wk','acc.2-3wk',
                           'meanErr.3-4wk', 'absmeanErr.3-4wk' ,'pbias.3-4wk', 'cor.3-4wk','acc.3-4wk')

## Save statistics
saveRDS(tmp2m_stats, file = c('tmp2m_analysis.rds'))
saveRDS(prate_stats, file = c('prate_analysis.rds'))
