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
dir_in = '/home/sabaker/s2s/analysis/files/cfsv2_files/2wk_analysis/'
dir_plots = '/home/sabaker/s2s/analysis/plots/'

## Load function
source('/home/sabaker/s2s/analysis/scripts/cfsv2_analysis/plot_function.r')

##### ===== Load statistics ===== #####
setwd(dir_in)
tmp2m_stats = readRDS('tmp2m_analysis.rds')
prate_stats = readRDS('prate_analysis.rds')


#####  ============== Annual Graph Statistics ==============  #####
setwd(dir_plots)
# lab = gsub(pattern="\\(", replacement="", x= gsub("^(.*?),.*","\\1",levels(hru_error_pr$bins)))
# lab = sprintf("%.2f",as.numeric(lab))

#### ---------------- Mean Error ---------------- ####

##### Precipitation Rate #####
cust_pal = rev(colorRampPalette(brewer.pal(11,"Spectral"))(14))
## 1-2wk - PRECIP RATE
prate_stats$bins = cut(prate_stats$`meanErr.1-2wk`, breaks = seq(from = -1.75, to = 1.75, by = 0.25)) #[-1.59,1.17]
lab = levels(prate_stats$bins)
p = plot_map('prate', prate_stats, 2, type = 'discrete', lab = lab, cust_pal = cust_pal)
p + ggtitle('Bias - CFSv2 1-2 Week Avg. Precipitation (1999-2010)')
ggsave('bias_prate_1-2wk.png', height = 6, width = 10, dpi = 100)

## 2-3wk - PRECIP RATE
prate_stats$bins = cut(prate_stats$`meanErr.2-3wk`, breaks = seq(from = -1.75, to = 1.75, by = 0.25)) #[-1.43,1.33]
lab = levels(prate_stats$bins)
p = plot_map('prate', prate_stats, 7, type = 'discrete', lab = lab, cust_pal = cust_pal)
p + ggtitle('Bias - CFSv2 2-3 Week Avg. Precipitation (1999-2010)')
ggsave('bias_prate_2-3wk.png', height = 6, width = 10, dpi = 100)

## 3-4wk - PRECIP RATE
prate_stats$bins = cut(prate_stats$`meanErr.3-4wk`, breaks = seq(from = -1.75, to = 1.75, by = 0.25)) #[-1.37,1.34]
lab = levels(prate_stats$bins)
p = plot_map('prate', prate_stats, 12, type = 'discrete', lab = lab, cust_pal = cust_pal)
p + ggtitle('Bias - CFSv2 3-4 Week Avg. Precipitation (1999-2010)')
ggsave('bias_prate_3-4wk.png', height = 6, width = 10, dpi = 100)

##### Temperature #####
cust_pal = rev(colorRampPalette(brewer.pal(11,"Spectral"))(18))
# color_test <- colorRampPalette(c('#2166ac','#f7f7f7', '#b2182b'),space = "rgb") #for discrete
# cust_pal = color_test(nlevels(tmp2m_stats$bins))
## 1-2wk - TEMPERATURE
tmp2m_stats$bins = cut(tmp2m_stats$`meanErr.1-2wk`, breaks = seq(from = -2.25, to = 2.25, by = 0.25)) #[-1.79,1.27]
lab = levels(tmp2m_stats$bins)
p = plot_map('tmp_2m', tmp2m_stats, 2, type = 'discrete', lab = lab, cust_pal = cust_pal)
p + ggtitle('Bias - CFSv2 1-2 Week Avg. Temperature (1999-2010)')
ggsave('bias_tmp2m_1-2wk.png', height = 6, width = 10, dpi = 100)

## 2-3wk - TEMPERATURE
tmp2m_stats$bins = cut(tmp2m_stats$`meanErr.2-3wk`, breaks = seq(from = -2.25, to = 2.25, by = 0.25)) #[-2.1,1.07]
lab = levels(tmp2m_stats$bins)
p = plot_map('tmp_2m', tmp2m_stats, 7, type = 'discrete', lab = lab, cust_pal = cust_pal)
p + ggtitle('Bias - CFSv2 2-3 Week Avg. Temperature (1999-2010)')
ggsave('bias_tmp2m_2-3wk.png', height = 6, width = 10, dpi = 100)

## 3-4wk - TEMPERATURE
tmp2m_stats$bins = cut(tmp2m_stats$`meanErr.3-4wk`, breaks = seq(from = -2.25, to = 2.25, by = 0.25)) #[-2.15,0.81]
lab = levels(tmp2m_stats$bins)
p = plot_map('tmp_2m', tmp2m_stats, 12, type = 'discrete', lab = lab, cust_pal = cust_pal)
p + ggtitle('Bias - CFSv2 3-4 Week Avg. Temperature (1999-2010)')
ggsave('bias_tmp2m_3-4wk.png', height = 6, width = 10, dpi = 100)


#### ---------------- Absolute Mean Error ---------------- ####

##### Precipitation Rate #####
cust_pal = rev(colorRampPalette(brewer.pal(11,"Spectral"))(16)[1:8])
## 1-2wk - PRECIP RATE
prate_stats$bins = cut(prate_stats$`absmeanErr.1-2wk`, breaks = seq(from = 0, to = 1.6, by = 0.2)) #[0,1.59]
lab = levels(prate_stats$bins)
p = plot_map('prate', prate_stats, 3, type = 'discrete', lab = lab, cust_pal = cust_pal)
p + ggtitle('MAE - CFSv2 1-2 Week Avg. Precipitation (1999-2010)')
ggsave('MAE_prate_1-2wk.png', height = 6, width = 10, dpi = 100)

## 2-3wk - PRECIP RATE
prate_stats$bins = cut(prate_stats$`absmeanErr.2-3wk`, breaks = seq(from = 0, to = 1.6, by = 0.2)) #[0,1.43]
lab = levels(prate_stats$bins)
p = plot_map('prate', prate_stats, 8, type = 'discrete', lab = lab, cust_pal = cust_pal)
p + ggtitle('MAE - CFSv2 2-3 Week Avg. Precipitation (1999-2010)')
ggsave('MAE_prate_2-3wk.png', height = 6, width = 10, dpi = 100)

## 3-4wk - PRECIP RATE
prate_stats$bins = cut(prate_stats$`absmeanErr.3-4wk`, breaks = seq(from = 0, to = 1.6, by = 0.2)) #[0,1.37]
lab = levels(prate_stats$bins)
p = plot_map('prate', prate_stats, 13, type = 'discrete', lab = lab, cust_pal = cust_pal)
p + ggtitle('MAE - CFSv2 3-4 Week Avg. Precipitation (1999-2010)')
ggsave('MAE_prate_3-4wk.png', height = 6, width = 10, dpi = 100)

##### Temperature #####
cust_pal = rev(colorRampPalette(brewer.pal(11,"Spectral"))(22)[1:11])
## 1-2wk - TEMPERATURE
tmp2m_stats$bins = cut(tmp2m_stats$`absmeanErr.1-2wk`, breaks = seq(from = 0, to = 2.2, by = 0.2)) #[0,1.8]
lab = levels(tmp2m_stats$bins)
p = plot_map('tmp_2m', tmp2m_stats, 3, type = 'discrete', lab = lab, cust_pal = cust_pal)
p + ggtitle('MAE - CFSv2 1-2 Week Avg. Temperature (1999-2010)')
ggsave('MAE_tmp2m_1-2wk.png', height = 6, width = 10, dpi = 100)

## 2-3wk - TEMPERATURE
tmp2m_stats$bins = cut(tmp2m_stats$`absmeanErr.2-3wk`, breaks = seq(from = 0, to = 2.2, by = 0.2)) #[0,2.02]
lab = levels(tmp2m_stats$bins)
p = plot_map('tmp_2m', tmp2m_stats, 8, type = 'discrete', lab = lab, cust_pal = cust_pal)
p + ggtitle('MAE - CFSv2 2-3 Week Avg. Temperature (1999-2010)')
ggsave('MAE_tmp2m_2-3wk.png', height = 6, width = 10, dpi = 100)

## 3-4wk - TEMPERATURE
tmp2m_stats$bins = cut(tmp2m_stats$`absmeanErr.3-4wk`, breaks = seq(from = 0, to = 2.2, by = 0.2)) #[0,2.15]
lab = levels(tmp2m_stats$bins)
p = plot_map('tmp_2m', tmp2m_stats, 13, type = 'discrete', lab = lab, cust_pal = cust_pal)
p + ggtitle('MAE - CFSv2 3-4 Week Avg. Temperature (1999-2010)')
ggsave('MAE_tmp2m_3-4wk.png', height = 6, width = 10, dpi = 100)


#### ---------------- Percent Bias ---------------- ####

##### Precipitation Rate #####
cust_pal = (colorRampPalette(brewer.pal(11,"Spectral"))(15)[6:15])
## 1-2wk - PRECIP RATE
prate_stats$bins = cut(prate_stats$`pbias.1-2wk`, breaks = seq(from = -50, to = 130, by = 20)) #[-46.7,105.5]
lab = levels(prate_stats$bins)
# color_test <- colorRampPalette(c('#a50026','#ffffbf', '#006837'),space = "rgb") #for discrete
# cust_pal = color_test(15)[6:15]
p = plot_map('prate', prate_stats, 4, type = 'discrete', lab = lab,  legend_title = 'Percent (%)', cust_pal = cust_pal)
p + ggtitle('Percent Bias - CFSv2 1-2 Week Avg. Precipitation (1999-2010)')
ggsave('pbias_prate_1-2wk.png', height = 6, width = 10, dpi = 100)

## 2-3wk - PRECIP RATE
prate_stats$bins = cut(prate_stats$`pbias.2-3wk`, breaks = seq(from = -50, to = 130, by = 20)) #[-42.3,118]
lab = levels(prate_stats$bins)
p = plot_map('prate', prate_stats, 9, type = 'discrete',lab = lab,  legend_title = 'Percent (%)', cust_pal = cust_pal)
p + ggtitle('Percent Bias - CFSv2 2-3 Week Avg. Precipitation (1999-2010)')
ggsave('pbias_prate_2-3wk.png', height = 6, width = 10, dpi = 100)

## 3-4wk - PRECIP RATE
prate_stats$bins = cut(prate_stats$`pbias.3-4wk`, breaks = seq(from = -50, to = 130, by = 20)) #[-40.5,122.8]
lab = levels(prate_stats$bins)
p = plot_map('prate', prate_stats, 14, type = 'discrete',lab = lab,  legend_title = 'Percent (%)', cust_pal = cust_pal)
p + ggtitle('Percent Bias - CFSv2 3-4 Week Avg. Precipitation (1999-2010)')
ggsave('pbias_prate_3-4wk.png', height = 6, width = 10, dpi = 100)

# ##### Temperature #####
# ## 1-2wk - TEMPERATURE
# tmp2m_stats$bins = cut(tmp2m_stats$`pbias.1-2wk`, breaks = seq(from = 50, to = -50, by = -10)) #[-26.5,43.4]
# lab = levels(tmp2m_stats$bins)
# p = plot_map('tmp_2m', tmp2m_stats, 4, type = 'discrete',lab = lab,  legend_title = 'Percent (%)')
# p + ggtitle('Percent Bias - CFSv2 1-2 Week Avg. Temperature (1999-2010)')
# ggsave('pbias_tmp2m_1-2wk.png', height = 6, width = 10, dpi = 100)
# 
# ## 2-3wk - TEMPERATURE
# tmp2m_stats$bins = cut(tmp2m_stats$`pbias.2-3wk`, breaks = seq(from = 50, to = -50, by = -10)) #[-38.5,36.3]
# lab = levels(tmp2m_stats$bins)
# p = plot_map('tmp_2m', tmp2m_stats, 9, type = 'discrete',lab = lab,  legend_title = 'Percent (%)')
# p + ggtitle('Percent Bias - CFSv2 2-3 Week Avg. Temperature (1999-2010)')
# ggsave('pbias_tmp2m_2-3wk.png', height = 6, width = 10, dpi = 100)
# 
# ## 3-4wk - TEMPERATURE
# tmp2m_stats$bins = cut(tmp2m_stats$`pbias.3-4wk`, breaks = seq(from = 50, to = -50, by = -10)) #[-47.2,27.1]
# lab = levels(tmp2m_stats$bins)
# p = plot_map('tmp_2m', tmp2m_stats, 14, type = 'discrete',lab = lab,  legend_title = 'Percent (%)')
# p + ggtitle('Percent Bias - CFSv2 3-4 Week Avg. Temperature (1999-2010)')
# ggsave('pbias_tmp2m_3-4wk.png', height = 6, width = 10, dpi = 100)


#### ---------------- Correlation ---------------- ####

##### Precipitation Rate #####
cust_pal = rev(colorRampPalette(brewer.pal(11,"Spectral"))(12))
## 1-2wk - PRECIP RATE
prate_stats$bins = cut(prate_stats$`cor.1-2wk`, breaks = seq(from = -0.2, to = 1, by = 0.1)) #[0,0.82]
lab = levels(prate_stats$bins)
p = plot_map('prate', prate_stats, 5, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
p + ggtitle('Correlation - CFSv2 1-2 Week Avg. Precipitation (1999-2010)')
ggsave('cor_prate_1-2wk.png', height = 6, width = 10, dpi = 100)

## 2-3wk - PRECIP RATE
prate_stats$bins = cut(prate_stats$`cor.2-3wk`, breaks = seq(from = -0.2, to = 1, by = 0.1)) #[0,0.6]
lab = levels(prate_stats$bins)
p = plot_map('prate', prate_stats, 10, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
p + ggtitle('Correlation - CFSv2 2-3 Week Avg. Precipitation (1999-2010)')
ggsave('cor_prate_2-3wk.png', height = 6, width = 10, dpi = 100)

## 3-4wk - PRECIP RATE
# prate_stats$`cor.3-4wk`[prate_stats$`cor.3-4wk` < 0 ] = 0.0001
prate_stats$bins = cut(prate_stats$`cor.3-4wk`, breaks = seq(from = -0.2, to = 1, by = 0.1)) #[0,0.5]
lab = levels(prate_stats$bins)
p = plot_map('prate', prate_stats, 15, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
p + ggtitle('Correlation - CFSv2 3-4 Week Avg. Precipitation (1999-2010)')
ggsave('cor_prate_3-4wk.png', height = 6, width = 10, dpi = 100)

# ##### Temperature #####
# ## 1-2wk - TEMPERATURE
# tmp2m_stats$bins = cut(tmp2m_stats$`cor.1-2wk`, breaks = seq(from = 0.88, to = 1, by = 0.01)) #[0.92,1]
# lab = levels(tmp2m_stats$bins)
# color_test <- colorRampPalette(c('#ffffcc','#fd8d3c', '#800026'),space = "rgb") #for discrete
# cust_pal = color_test(nlevels(tmp2m_stats$bins))
# p = plot_map('tmp_2m', tmp2m_stats, 5, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
# p + ggtitle('Correlation - CFSv2 1-2 Week Avg. Temperature (1999-2010)')
# ggsave('cor_tmp2m_1-2wk.png', height = 6, width = 10, dpi = 100)
# 
# ## 2-3wk - TEMPERATURE
# tmp2m_stats$bins = cut(tmp2m_stats$`cor.2-3wk`, breaks = seq(from = 0.88, to = 1, by = 0.01)) #[0.92,1]
# lab = levels(tmp2m_stats$bins)
# p = plot_map('tmp_2m', tmp2m_stats, 10, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
# p + ggtitle('Correlation - CFSv2 2-3 Week Avg. Temperature (1999-2010)')
# ggsave('cor_tmp2m_2-3wk.png', height = 6, width = 10, dpi = 100)
# 
# ## 3-4wk - TEMPERATURE
# tmp2m_stats$bins = cut(tmp2m_stats$`cor.3-4wk`, breaks = seq(from = 0.88, to = 1, by = 0.01)) #[0.88,1]
# lab = levels(tmp2m_stats$bins)
# p = plot_map('tmp_2m', tmp2m_stats, 15, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
# p + ggtitle('Correlation - CFSv2 3-4 Week Avg. Temperature (1999-2010)')
# ggsave('cor_tmp2m_3-4wk.png', height = 6, width = 10, dpi = 100)


#### ---------------- Anomaly Correlation ---------------- ####

##### Precipitation Rate #####
cust_pal = rev(colorRampPalette(brewer.pal(11,"Spectral"))(12))
## 1-2wk - PRECIP RATE
prate_stats$bins = cut(prate_stats$`acc.1-2wk`, breaks = seq(from = -0.2, to = 1, by = 0.1)) #[0,0.65]
lab = levels(prate_stats$bins)
p = plot_map('prate', prate_stats, 6, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
p + ggtitle('Anomaly Correlation - CFSv2 1-2 Week Avg. Precipitation (1999-2010)')
ggsave('AnomCor_prate_1-2wk.png', height = 6, width = 10, dpi = 100)

## 2-3wk - PRECIP RATE
prate_stats$bins = cut(prate_stats$`acc.2-3wk`, breaks = seq(from = -0.2, to = 1, by = 0.1)) #[0,0.25]
lab = levels(prate_stats$bins)
p = plot_map('prate', prate_stats, 11, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
p + ggtitle('Anomaly Correlation - CFSv2 2-3 Week Avg. Precipitation (1999-2010)')
ggsave('AnomCor_prate_2-3wk.png', height = 6, width = 10, dpi = 100)

## 3-4wk - PRECIP RATE
# prate_stats$`acc.3-4wk`[prate_stats$`acc.3-4wk` < 0 ] = 0.0001
prate_stats$bins = cut(prate_stats$`acc.3-4wk`, breaks = seq(from = -0.2, to = 1, by = 0.1)) #[0,0.11]
lab = levels(prate_stats$bins)
p = plot_map('prate', prate_stats, 16, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
p + ggtitle('Anomaly Correlation - CFSv2 3-4 Week Avg. Precipitation (1999-2010)')
ggsave('AnomCor_prate_3-4wk.png', height = 6, width = 10, dpi = 100)

##### Temperature #####
## 1-2wk - TEMPERATURE
tmp2m_stats$bins = cut(tmp2m_stats$`acc.1-2wk`, breaks = seq(from = -0.2, to = 1, by = 0.1)) #[0.675,0.81]
lab = levels(tmp2m_stats$bins)
p = plot_map('tmp_2m', tmp2m_stats, 6, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
p + ggtitle('Anomaly Correlation - CFSv2 1-2 Week Avg. Temperature (1999-2010)')
ggsave('AnomCor_tmp2m_1-2wk.png', height = 6, width = 10, dpi = 100)

## 2-3wk - TEMPERATURE
tmp2m_stats$bins = cut(tmp2m_stats$`acc.2-3wk`, breaks = seq(from = -0.2, to = 1, by = 0.1)) #[0.26,0.49]
lab = levels(tmp2m_stats$bins)
p = plot_map('tmp_2m', tmp2m_stats, 11, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
p + ggtitle('Anomaly Correlation - CFSv2 2-3 Week Avg. Temperature (1999-2010)')
ggsave('AnomCor_tmp2m_2-3wk.png', height = 6, width = 10, dpi = 100)

## 3-4wk - TEMPERATURE
tmp2m_stats$bins = cut(tmp2m_stats$`acc.3-4wk`, breaks = seq(from = -0.2, to = 1, by = 0.1)) #[0.05,0.24]
lab = levels(tmp2m_stats$bins)
p = plot_map('tmp_2m', tmp2m_stats, 16, type = 'discrete',lab = lab,  cust_pal = cust_pal, legend_title = 'Correlation')
p + ggtitle('Anomaly Correlation - CFSv2 3-4 Week Avg. Temperature (1999-2010)')
ggsave('AnomCor_tmp2m_3-4wk.png', height = 6, width = 10, dpi = 100)





# ##### ===== Continuous ===== #####
# ## Mean Error
# p = plot_map('prate', hru_error_pr, 2, lim_max = 1.6, lim_min = -1.6)
# p + ggtitle('Mean Error - CFSv2 Precipitation (1999-2010)')
# ggsave('meanError_prate.png', height = 6, width = 10, dpi = 100)
# 
# p = plot_map('tmp_2m', hru_error_tm, 2, lim_max = 1.8, lim_min = -1.8)
# p + ggtitle('Mean Error - CFSv2 Temperature (1999-2010)')
# ggsave('meanError_tmp2m.png', height = 6, width = 10, dpi = 100)
# 
# ## Mean Absolute Error
# p = plot_map('prate', hru_error_pr, 3, lim_max = 1.6, lim_min = 0)
# p + ggtitle('Mean Absolute Error - CFSv2 Precipitation (1999-2010)')
# ggsave('meanAbsError_prate.png', height = 6, width = 10, dpi = 100)
# 
# p = plot_map('tmp_2m', hru_error_tm, 3, lim_max = 1.8, lim_min = 0)
# p + ggtitle('Mean Absolute Error - CFSv2 Temperature (1999-2010)')
# ggsave('meanAbsError_tmp2m.png', height = 6, width = 10, dpi = 100)
# 
# ## Precent Bias
# p = plot_map('prate', stats, 3, lim_max = 106, lim_min = -100, legend_title = 'Percent (%)')
# p + ggtitle('Percent Bias - CFSv2 Precipitation (1999-2010)')
# ggsave('pbias_prate.png', height = 6, width = 10, dpi = 100)
# 
# p = plot_map('tmp_2m', stats, 2, lim_max = 50, lim_min = -50, legend_title = 'Percent (%)')
# p + ggtitle('Percent Bias - CFSv2 Temperature (1999-2010)')
# ggsave('pbias_tmp2m.png', height = 6, width = 10, dpi = 100)
# 
# ## Correlation
# p = plot_map('prate', stats, 5, lim_max = 1, lim_min = 0, legend_title = 'Correlation')
# p + ggtitle('Correlation - CFSv2 Precipitation (1999-2010)')
# ggsave('cor_prate.png', height = 6, width = 10, dpi = 100)
# 
# p = plot_map('tmp_2m', stats, 4, lim_max = 1, lim_min = 0.965, legend_title = 'Correlation')
# p + ggtitle('Correlation - CFSv2 Temperature (1999-2010)')
# ggsave('cor_tmp2m.png', height = 6, width = 10, dpi = 100)