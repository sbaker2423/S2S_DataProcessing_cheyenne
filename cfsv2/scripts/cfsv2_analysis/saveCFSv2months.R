# ================================================
# 1 - Save monthly CFSv2 Variables
# - used in xx script
# S. Baker, Feb 2018
# ================================================
rm(list=ls())

## Load libraries
library(ncdf4)
library(dplyr)
library(data.table)
library(lubridate)
library(ggplot2)
source('/home/sabaker/s2s/analysis/scripts/cfsv2_analysis/analysisFunctions.R')

## Directories
dir_in = '/home/sabaker/s2s/analysis/files/cfsv2_files/cfs_allVars/'
dir_out = '/home/sabaker/s2s/analysis/files/cfsv2_files/cfs_monthly/'

#yrs_in = c(1999:2010)
biwk_in = c('1_2', '2_3', '3_4')
var_in = c('z500_f')
var_nm = c('HGT_500mb')

## loop through each var, yr, biweekly period 
i=j=k=m=1
for (i in 1:length(var_in)) {
  for (k in 1:length(biwk_in)) {

    ## read in var for a lead
    setwd(dir_in)
    df = readNCgrid(fileName = paste0('cfsv2.', biwk_in[k], '.', var_in[i], '.nc'), 
                    varName = var_nm[i], avg_fcst_day = 0,
                    array = FALSE)
    
    df = as.data.table(df)
    
    ## filter for a month
    for (m in 1:12) {
      print(paste0('Filter m=', m, ' from ', 'cfsv2.', biwk_in[k], '.', var_in[i], '.nc') )
      
      #test = df[df[, .I[month(dateraw) == m]]]
      df_m = df %>% filter(month(dateraw) == m)
      
      ## save monthly data
      setwd(dir_out)
      saveRDS(df_m, file = paste0('cfsv2.', var_in[i], '.', biwk_in[k], '.mon.', m, '.nc'))
      print(paste0('SAVED m=', m, ' from ', 'cfsv2.', biwk_in[k], '.', var_in[i], '.nc') )
      
    }
  }
}
