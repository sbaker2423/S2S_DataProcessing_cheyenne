# ===========================================
# Plot bi-weekly time periods
# S. Baker, April 2017
# ===========================================
rm(list=ls())

## Load libraries
#library(dplyr)
#library(hydroGOF)
library(RColorBrewer)

## Directories
dir_in = '/home/sabaker/s2s/analysis/files/2wk_analysis/'
dir_plots = '/home/sabaker/s2s/analysis/plots/Seasonal/'

## Load function
source('/home/sabaker/s2s/analysis/scripts/plot_function.r')

##### ===== Load statistics ===== #####
setwd(dir_in)
tmp2m_stats = readRDS('tmp2m_SeasonAnalysis.rds')
prate_stats = readRDS('prate_SeasonAnalysis.rds')

#####  ============== Graph Seasonal Statistics ==============  #####
setwd(dir_plots)
seasons = c('JFM','FMA','MAM','AMJ','MJJ','JJA','JAS','ASO','SON','OND','NDJ','DJF')

for (i in 1:12) {
  ##set up matricies
  prate_1season = dplyr::filter(prate_stats, seas == i)
  tmp2m_1season = dplyr::filter(tmp2m_stats, seas == i)
  
  #### ---------------- Mean Error ---------------- ####
  
  ##### Precipitation Rate #####
  cust_pal = rev(colorRampPalette(brewer.pal(11,"Spectral"))(13))
  ## 1-2wk - PRECIP RATE
  prate_1season$bins = cut(prate_1season$`meanErr.1-2wk`, breaks = seq(from = -3.5, to = 3, by = 0.5)) #[-3.1,2.27]
  lab = levels(prate_1season$bins)
  p = plot_map('prate', prate_1season, 3, type = 'discrete', lab = lab, cust_pal = cust_pal)
  p + ggtitle(paste0(seasons[i],' Bias - CFSv2 1-2 Week Avg. Precipitation (1999-2010)'))
  ggsave(paste0(seasons[i],'_bias_prate_1-2wk.png'), height = 6, width = 10, dpi = 100)
  
  ## 2-3wk - PRECIP RATE
  prate_1season$bins = cut(prate_1season$`meanErr.2-3wk`, breaks = seq(from = -3.5, to = 3, by = 0.5)) #[-3,2.63]
  lab = levels(prate_1season$bins)
  p = plot_map('prate', prate_1season, 8, type = 'discrete', lab = lab, cust_pal = cust_pal)
  p + ggtitle(paste0(seasons[i],' Bias - CFSv2 2-3 Week Avg. Precipitation (1999-2010)'))
  ggsave(paste0(seasons[i],'_bias_prate_2-3wk.png'), height = 6, width = 10, dpi = 100)
  
  ## 3-4wk - PRECIP RATE
  prate_1season$bins = cut(prate_1season$`meanErr.3-4wk`, breaks = seq(from = -3.5, to = 3, by = 0.5)) #[-2.96,2.5]
  lab = levels(prate_1season$bins)
  p = plot_map('prate', prate_1season, 13, type = 'discrete', lab = lab, cust_pal = cust_pal)
  p + ggtitle(paste0(seasons[i],' Bias - CFSv2 3-4 Week Avg. Precipitation (1999-2010)'))
  ggsave(paste0(seasons[i],'_bias_prate_3-4wk.png'), height = 6, width = 10, dpi = 100)
  
  ##### Temperature #####
  cust_pal = rev(colorRampPalette(brewer.pal(11,"Spectral"))(15))
  ## 1-2wk - TEMPERATURE
  tmp2m_1season$bins = cut(tmp2m_1season$`meanErr.1-2wk`, breaks = seq(from = -3.5, to = 4, by = 0.5)) #[-3.05,3.63]
  lab = levels(tmp2m_1season$bins)
  p = plot_map('tmp_2m', tmp2m_1season, 3, type = 'discrete', lab = lab, cust_pal = cust_pal)
  p + ggtitle(paste0(seasons[i],' Bias - CFSv2 1-2 Week Avg. Temperature (1999-2010)'))
  ggsave(paste0(seasons[i],'_bias_tmp2m_1-2wk.png'), height = 6, width = 10, dpi = 100)
  
  ## 2-3wk - TEMPERATURE
  tmp2m_1season$bins = cut(tmp2m_1season$`meanErr.2-3wk`, breaks = seq(from = -3.5, to = 4, by = 0.5)) #[-3.2,3.1]
  lab = levels(tmp2m_1season$bins)
  p = plot_map('tmp_2m', tmp2m_1season, 8, type = 'discrete', lab = lab, cust_pal = cust_pal)
  p + ggtitle(paste0(seasons[i],' Bias - CFSv2 2-3 Week Avg. Temperature (1999-2010)'))
  ggsave(paste0(seasons[i],'_bias_tmp2m_2-3wk.png'), height = 6, width = 10, dpi = 100)
  
  ## 3-4wk - TEMPERATURE
  tmp2m_1season$bins = cut(tmp2m_1season$`meanErr.3-4wk`, breaks = seq(from = -3.5, to = 4, by = 0.5)) #[-3.4,2.46]
  lab = levels(tmp2m_1season$bins)
  p = plot_map('tmp_2m', tmp2m_1season, 13, type = 'discrete', lab = lab, cust_pal = cust_pal)
  p + ggtitle(paste0(seasons[i],' Bias - CFSv2 3-4 Week Avg. Temperature (1999-2010)'))
  ggsave(paste0(seasons[i],'_bias_tmp2m_3-4wk.png'), height = 6, width = 10, dpi = 100)
  
  
  #### ---------------- Absolute Mean Error ---------------- ####
  
  ##### Precipitation Rate #####
  cust_pal = rev(colorRampPalette(brewer.pal(11,"Spectral"))(26)[1:13])
  ## 1-2wk - PRECIP RATE
  prate_1season$bins = cut(prate_1season$`absmeanErr.1-2wk`, breaks = seq(from = 0, to = 3.25, by = 0.25)) #[0,3.1]
  lab = levels(prate_1season$bins)
  p = plot_map('prate', prate_1season, 4, type = 'discrete', lab = lab, cust_pal = cust_pal)
  p + ggtitle(paste0(seasons[i],' MAE - CFSv2 1-2 Week Avg. Precipitation (1999-2010)'))
  ggsave(paste0(seasons[i],'_MAE_prate_1-2wk.png'), height = 6, width = 10, dpi = 100)
  
  ## 2-3wk - PRECIP RATE
  prate_1season$bins = cut(prate_1season$`absmeanErr.2-3wk`, breaks = seq(from = 0, to = 3.25, by = 0.25)) #[0,3.2]
  lab = levels(prate_1season$bins)
  p = plot_map('prate', prate_1season, 9, type = 'discrete', lab = lab, cust_pal = cust_pal)
  p + ggtitle(paste0(seasons[i],' MAE - CFSv2 2-3 Week Avg. Precipitation (1999-2010)'))
  ggsave(paste0(seasons[i],'_MAE_prate_2-3wk.png'), height = 6, width = 10, dpi = 100)
  
  ## 3-4wk - PRECIP RATE
  prate_1season$bins = cut(prate_1season$`absmeanErr.3-4wk`, breaks = seq(from = 0, to = 3.25, by = 0.25)) #[0,3]
  lab = levels(prate_1season$bins)
  p = plot_map('prate', prate_1season, 14, type = 'discrete', lab = lab, cust_pal = cust_pal)
  p + ggtitle(paste0(seasons[i],'MAE - CFSv2 3-4 Week Avg. Precipitation (1999-2010)'))
  ggsave(paste0(seasons[i],'_MAE_prate_3-4wk.png'), height = 6, width = 10, dpi = 100)
  
  ##### Temperature #####
  cust_pal = rev(colorRampPalette(brewer.pal(11,"Spectral"))(30)[1:15])
  ## 1-2wk - TEMPERATURE
  tmp2m_1season$bins = cut(tmp2m_1season$`absmeanErr.1-2wk`, breaks = seq(from = 0, to = 3.75, by = 0.25)) #[0,3.7]
  lab = levels(tmp2m_1season$bins)
  p = plot_map('tmp_2m', tmp2m_1season, 4, type = 'discrete', lab = lab, cust_pal = cust_pal)
  p + ggtitle(paste0(seasons[i],' MAE - CFSv2 1-2 Week Avg. Temperature (1999-2010)'))
  ggsave(paste0(seasons[i],'_MAE_tmp2m_1-2wk.png'), height = 6, width = 10, dpi = 100)
  
  ## 2-3wk - TEMPERATURE
  tmp2m_1season$bins = cut(tmp2m_1season$`absmeanErr.2-3wk`, breaks = seq(from = 0, to = 3.75, by = 0.25)) #[0,3.2]
  lab = levels(tmp2m_1season$bins)
  p = plot_map('tmp_2m', tmp2m_1season, 9, type = 'discrete', lab = lab, cust_pal = cust_pal)
  p + ggtitle(paste0(seasons[i],' MAE - CFSv2 2-3 Week Avg. Temperature (1999-2010)'))
  ggsave(paste0(seasons[i],'_MAE_tmp2m_2-3wk.png'), height = 6, width = 10, dpi = 100)
  
  ## 3-4wk - TEMPERATURE
  tmp2m_1season$bins = cut(tmp2m_1season$`absmeanErr.3-4wk`, breaks = seq(from = 0, to = 3.75, by = 0.25)) #[0,3.2]
  lab = levels(tmp2m_1season$bins)
  p = plot_map('tmp_2m', tmp2m_1season, 14, type = 'discrete', lab = lab, cust_pal = cust_pal)
  p + ggtitle(paste0(seasons[i],' MAE - CFSv2 3-4 Week Avg. Temperature (1999-2010)'))
  ggsave(paste0(seasons[i],'_MAE_tmp2m_3-4wk.png'), height = 6, width = 10, dpi = 100)
  
  
  #### ---------------- Percent Bias ---------------- ####
  
  ##### Precipitation Rate #####
  cust_pal = (colorRampPalette(brewer.pal(11,"Spectral"))(24)[9:24])
  ## 1-2wk - PRECIP RATE
  prate_1season$bins = cut(prate_1season$`pbias.1-2wk`, breaks = seq(from = -100, to = 300, by = 25)) #[-75,290]
  lab = levels(prate_1season$bins)
  p = plot_map('prate', prate_1season, 5, type = 'discrete', lab = lab,  legend_title = 'Percent (%)', cust_pal = cust_pal)
  p + ggtitle(paste0(seasons[i],' Percent Bias - CFSv2 1-2 Week Avg. Precipitation (1999-2010)'))
  ggsave(paste0(seasons[i],'_pbias_prate_1-2wk.png'), height = 6, width = 10, dpi = 100)
  
  ## 2-3wk - PRECIP RATE
  prate_1season$bins = cut(prate_1season$`pbias.2-3wk`, breaks = seq(from = -100, to = 300, by = 25)) #[-80,300]
  lab = levels(prate_1season$bins)
  p = plot_map('prate', prate_1season, 10, type = 'discrete',lab = lab,  legend_title = 'Percent (%)', cust_pal = cust_pal)
  p + ggtitle(paste0(seasons[i],' Percent Bias - CFSv2 2-3 Week Avg. Precipitation (1999-2010)'))
  ggsave(paste0(seasons[i],'_pbias_prate_2-3wk.png'), height = 6, width = 10, dpi = 100)
  
  ## 3-4wk - PRECIP RATE
  prate_1season$bins = cut(prate_1season$`pbias.3-4wk`, breaks = seq(from = -100, to = 300, by = 25)) #[-81,312]
  lab = levels(prate_1season$bins)
  p = plot_map('prate', prate_1season, 15, type = 'discrete',lab = lab,  legend_title = 'Percent (%)', cust_pal = cust_pal)
  p + ggtitle(paste0(seasons[i],' Percent Bias - CFSv2 3-4 Week Avg. Precipitation (1999-2010)'))
  ggsave(paste0(seasons[i],'_pbias_prate_3-4wk.png'), height = 6, width = 10, dpi = 100)
  
  
  #### ---------------- Correlation ---------------- ####
  
  ##### Precipitation Rate #####
  cust_pal = rev(colorRampPalette(brewer.pal(11,"Spectral"))(12))
  ## 1-2wk - PRECIP RATE
  prate_1season$bins = cut(prate_1season$`cor.1-2wk`, breaks = seq(from = -0.2, to = 1, by = 0.1)) #[0,0.78]
  lab = levels(prate_1season$bins)
  p = plot_map('prate', prate_1season, 6, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
  p + ggtitle(paste0(seasons[i],' Correlation - CFSv2 1-2 Week Avg. Precipitation (1999-2010)'))
  ggsave(paste0(seasons[i],'_cor_prate_1-2wk.png'), height = 6, width = 10, dpi = 100)
  
  ## 2-3wk - PRECIP RATE
  prate_1season$bins = cut(prate_1season$`cor.2-3wk`, breaks = seq(from = -0.2, to = 1, by = 0.1)) #[-0.05,0.6]
  lab = levels(prate_1season$bins)
  p = plot_map('prate', prate_1season, 11, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
  p + ggtitle(paste0(seasons[i],' Correlation - CFSv2 2-3 Week Avg. Precipitation (1999-2010)'))
  ggsave(paste0(seasons[i],'_cor_prate_2-3wk.png'), height = 6, width = 10, dpi = 100)
  
  ## 3-4wk - PRECIP RATE
  # prate_1season$`cor.3-4wk`[prate_1season$`cor.3-4wk` < 0 ] = 0.0001
  prate_1season$bins = cut(prate_1season$`cor.3-4wk`, breaks = seq(from = -0.2, to = 1, by = 0.1)) #[-.1,0.5]
  lab = levels(prate_1season$bins)
  p = plot_map('prate', prate_1season, 16, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
  p + ggtitle(paste0(seasons[i],' Correlation - CFSv2 3-4 Week Avg. Precipitation (1999-2010)'))
  ggsave(paste0(seasons[i],'_cor_prate_3-4wk.png'), height = 6, width = 10, dpi = 100)
  
  
  
  #### ---------------- Anomaly Correlation ---------------- ####
  
  ##### Precipitation Rate #####
  cust_pal = rev(colorRampPalette(brewer.pal(11,"Spectral"))(12))
  ## 1-2wk - PRECIP RATE
  prate_1season$bins = cut(prate_1season$`acc.1-2wk`, breaks = seq(from = -0.2, to = 1, by = 0.1)) #[0,0.65]
  lab = levels(prate_1season$bins)
  p = plot_map('prate', prate_1season, 7, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
  p + ggtitle(paste0(seasons[i],' Anomaly Correlation - CFSv2 1-2 Week Avg. Precipitation (1999-2010)'))
  ggsave(paste0(seasons[i],'_AnomCor_prate_1-2wk.png'), height = 6, width = 10, dpi = 100)
  
  ## 2-3wk - PRECIP RATE
  prate_1season$bins = cut(prate_1season$`acc.2-3wk`, breaks = seq(from = -0.2, to = 1, by = 0.1)) #[0,0.25]
  lab = levels(prate_1season$bins)
  p = plot_map('prate', prate_1season, 12, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
  p + ggtitle(paste0(seasons[i],' Anomaly Correlation - CFSv2 2-3 Week Avg. Precipitation (1999-2010)'))
  ggsave(paste0(seasons[i],'_AnomCor_prate_2-3wk.png'), height = 6, width = 10, dpi = 100)
  
  ## 3-4wk - PRECIP RATE
  prate_1season$bins = cut(prate_1season$`acc.3-4wk`, breaks = seq(from = -0.2, to = 1, by = 0.1)) #[0,0.11]
  lab = levels(prate_1season$bins)
  p = plot_map('prate', prate_1season, 17, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
  p + ggtitle(paste0(seasons[i],' Anomaly Correlation - CFSv2 3-4 Week Avg. Precipitation (1999-2010)'))
  ggsave(paste0(seasons[i],'_AnomCor_prate_3-4wk.png'), height = 6, width = 10, dpi = 100)
  
  ##### Temperature #####
  ## 1-2wk - TEMPERATURE
  tmp2m_1season$bins = cut(tmp2m_1season$`acc.1-2wk`, breaks = seq(from = -0.2, to = 1, by = 0.1)) #[0.675,0.81]
  lab = levels(tmp2m_1season$bins)
  p = plot_map('tmp_2m', tmp2m_1season, 7, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
  p + ggtitle(paste0(seasons[i],' Anomaly Correlation - CFSv2 1-2 Week Avg. Temperature (1999-2010)'))
  ggsave(paste0(seasons[i],'_AnomCor_tmp2m_1-2wk.png'), height = 6, width = 10, dpi = 100)
  
  ## 2-3wk - TEMPERATURE
  tmp2m_1season$bins = cut(tmp2m_1season$`acc.2-3wk`, breaks = seq(from = -0.2, to = 1, by = 0.1)) #[0.26,0.49]
  lab = levels(tmp2m_1season$bins)
  p = plot_map('tmp_2m', tmp2m_1season, 12, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
  p + ggtitle(paste0(seasons[i],' Anomaly Correlation - CFSv2 2-3 Week Avg. Temperature (1999-2010)'))
  ggsave(paste0(seasons[i],'_AnomCor_tmp2m_2-3wk.png'), height = 6, width = 10, dpi = 100)
  
  ## 3-4wk - TEMPERATURE
  tmp2m_1season$bins = cut(tmp2m_1season$`acc.3-4wk`, breaks = seq(from = -0.2, to = 1, by = 0.1)) #[0.05,0.24]
  lab = levels(tmp2m_1season$bins)
  p = plot_map('tmp_2m', tmp2m_1season, 17, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
  p + ggtitle(paste0(seasons[i],' Anomaly Correlation - CFSv2 3-4 Week Avg. Temperature (1999-2010)'))
  ggsave(paste0(seasons[i],'_AnomCor_tmp2m_3-4wk.png'), height = 6, width = 10, dpi = 100)
  
}