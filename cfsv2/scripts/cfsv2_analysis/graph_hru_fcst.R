# ===========================================
# Plot annual statistics
# S. Baker, April 2017
# ===========================================
rm(list=ls())

## Load libraries
library(dplyr)
library(plyr)
library(ggplot2)
library(lubridate)

## Directories
base_dir = '/home/sabaker/s2s/analysis/scripts/cfsv2_analysis/'
dir_data= '/home/sabaker/s2s/analysis/files/cfsv2_files/2wk_analysis/'
dir_plots = '/home/sabaker/s2s/analysis/files/plots/'
setwd(dir_data)

## huc4 id function
source(paste0(base_dir, 'huc4_id.R'))
source(paste0(base_dir, 'hru4dig.R'))

yr= 2000

df = readRDS('QM_cfsv2.nldas.rds')
df$year = year(df$date)
df_hru = filter(df, var == 'tmp2m' & hru == '1304' & lead == '8.21' & year == yr)
df_mean = df_hru %>% group_by(date) %>% summarise_each(funs(mean))
df_mean  = df_mean[,c(1,4,6,9,12)]
colnames(df_mean) <- c('date', 'doy', 'NLDAS', 'CFSv2', 'QM')

### ==== plot timeseries
library(reshape2)
df_plot = melt(df_mean, id = c('date', 'doy'))
df_plot$value_F = df_plot$value *1.8 +32
df_plot$date = as.Date(df_plot$date)
# test2 = rbind.data.frame(
#              cbind(date = test[,1], value = test[,9], fcst = 'CFSv2'),
#              cbind.data.frame(date = test[,1], value = test[,6], fcst = 'NLDAS'),
#              cbind.data.frame(date = test[,1], value = test[,12], fcst = 'QM'))

ggplot(df_plot, aes(x = date, y = value_F, group = variable, colour = variable)) +
  geom_line() +
  xlab('') +
  ylab('Temperature (F)') + 
  scale_color_manual(values=c("grey10", "royalblue2",  'springgreen3')) +
  theme_bw()+
  scale_x_date(limits = c(as.Date('2000-01-01'),as.Date('2000-12-31')), date_labels = '%b %Y', 
               expand = c(1/365, 1/365), date_minor_breaks ='1 month')+
  scale_y_continuous(limits = c(40,85), expand = c(0, 0)) +
  theme(legend.title = element_blank(), legend.position = c(0.9,0.78),
        legend.background = element_rect(color = "black", 
                                         fill = "white", size = 0.25, linetype = "solid"),
        axis.text.x = element_text(angle = 45, hjust = 1)) 

setwd(dir_plots)
ggsave('ex_fcst.png', height = 6/1.85, width = 10/1.85, dpi = 400)


## scatter plot
df_mean$NLDAS = df_mean$NLDAS *1.8 +32
df_mean$CFSv2 = df_mean$CFSv2 *1.8 +32
df_mean$QM = df_mean$QM *1.8 +32
p1 <-ggplot(df_mean, aes(x = NLDAS, y = CFSv2)) +
  geom_abline(colour = 'red') +
  geom_point(size = 0.5) +
  scale_x_continuous(limits = c(40,85), expand = c(0, 0)) +
  scale_y_continuous(limits = c(40,85), expand = c(0, 0)) +
  xlab('NLDAS Temperature (F)') +
  ylab('CFSv2 Temperature (F)') + 
  theme_bw()+
  coord_equal()
p2 <-ggplot(df_mean, aes(x = NLDAS, y = QM)) +
  geom_abline(colour = 'red') +
  geom_point(size = 0.5) +
  scale_x_continuous(limits = c(40,85), expand = c(0, 0)) +
  scale_y_continuous(limits = c(40,85), expand = c(0, 0)) +
  xlab('NLDAS Temperature (F)') +
  ylab('QM Temperature (F)') + 
  theme_bw() +
  coord_equal()
library(gridExtra)
g1 <- grid.arrange(p1,p2, nrow = 1)
setwd(dir_plots)
ggsave('ex_fcst_scatter.png', plot = g1, height = 6/1.85, width = 10/1.85, dpi = 400)
  

  

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

## read hru ids
hru_id = hru4dig(read.table(paste0(base_dir, 'huc4_id.txt')))
colnames(hru_id) <- c('hru', 'name')
hru_vec = unique(cfs_pr.anom_1.14$hru)
hru_vec = subset(hru_id, hru %in% hru_vec) #0904 doesnt exist...

##### ===== Mean of each day's forecasts ===== #####
cfs_pr.anom_1.14 = cfs_pr.anom_1.14 %>% group_by(fcst_date,hru) %>% summarise_each(funs(mean))
cfs_pr.anom_8.21 = cfs_pr.anom_8.21 %>% group_by(fcst_date,hru) %>% summarise_each(funs(mean))
cfs_pr.anom_15.28 = cfs_pr.anom_15.28 %>% group_by(fcst_date,hru) %>% summarise_each(funs(mean))

cfs_tm.anom_1.14 = cfs_tm.anom_1.14 %>% group_by(fcst_date,hru) %>% summarise_each(funs(mean))
cfs_tm.anom_8.21 = cfs_tm.anom_8.21 %>% group_by(fcst_date,hru) %>% summarise_each(funs(mean))
cfs_tm.anom_15.28 = cfs_tm.anom_15.28 %>% group_by(fcst_date,hru) %>% summarise_each(funs(mean))

##### ===== Subset for a year ===== #####
## need to set up for leap years when 12-30&31 are doy 365
yr = 2001

cfs_yr_pr.anom_1.14 = subset(cfs_pr.anom_1.14, format(fcst_date, '%Y') == yr)
cfs_yr_pr.anom_8.21 = subset(cfs_pr.anom_8.21, format(fcst_date, '%Y') == yr)
cfs_yr_pr.anom_15.28 = subset(cfs_pr.anom_15.28, format(fcst_date, '%Y') == yr)

cfs_yr_tm.anom_1.14 = subset(cfs_tm.anom_1.14, format(fcst_date, '%Y') == yr)
cfs_yr_tm.anom_8.21 = subset(cfs_tm.anom_8.21, format(fcst_date, '%Y') == yr)
cfs_yr_tm.anom_15.28 = subset(cfs_tm.anom_15.28, format(fcst_date, '%Y') == yr)

nld_yr_pr.anom = subset(nld_pr.anom, format(date, '%Y') == yr)
nld_yr_tm.anom = subset(nld_tm.anom, format(date, '%Y') == yr)
nld_yr_tm.anom$date <- nld_yr_pr.anom$date <- NULL

## merge for ggplot
df1 = left_join(nld_yr_pr.anom, cfs_yr_pr.anom_1.14, by = c('doy', 'hru'), 
                suffix = c('.nld', '.cfs_1.14'))
df2 = left_join(cfs_yr_pr.anom_8.21, cfs_yr_pr.anom_15.28, by = c('doy', 'hru'), 
                suffix = c('.cfs_8.21', '.cfs_15.28'))
df_pr_yr = left_join(df1, df2, by = c('doy', 'hru'))

df1 = left_join(nld_yr_tm.anom, cfs_yr_tm.anom_1.14, by = c('doy', 'hru'), 
                suffix = c('.nld', '.cfs_1.14'))
df2 = left_join(cfs_yr_tm.anom_8.21, cfs_yr_tm.anom_15.28, by = c('doy', 'hru'), 
                suffix = c('.cfs_8.21', '.cfs_15.28'))
df_tm_yr = left_join(df1, df2, by = c('doy', 'hru'))

##### ===== Mean of doy fcst for 11 yrs ===== #####
cfs_pr.anom_1.14 = cfs_pr.anom_1.14 %>% group_by(doy,hru) %>% summarise_each(funs(mean))
cfs_pr.anom_8.21 = cfs_pr.anom_8.21 %>% group_by(doy,hru) %>% summarise_each(funs(mean))
cfs_pr.anom_15.28 = cfs_pr.anom_15.28 %>% group_by(doy,hru) %>% summarise_each(funs(mean))

cfs_tm.anom_1.14 = cfs_tm.anom_1.14 %>% group_by(doy,hru) %>% summarise_each(funs(mean))
cfs_tm.anom_8.21 = cfs_tm.anom_8.21 %>% group_by(doy,hru) %>% summarise_each(funs(mean))
cfs_tm.anom_15.28 = cfs_tm.anom_15.28 %>% group_by(doy,hru) %>% summarise_each(funs(mean))
# cfs_tm.anom_1.14$fcst_date <- cfs_tm.anom_8.21$fcst_date <- cfs_tm.anom_15.28$fcst_date <- NULL

nld_pr.anom = nld_pr.anom %>% group_by(hru,doy) %>% summarise_each(funs(mean))
nld_tm.anom = nld_tm.anom %>% group_by(hru,doy) %>% summarise_each(funs(mean))

## merge for ggplot
df1 = left_join(nld_pr.anom, cfs_pr.anom_1.14, by = c('doy', 'hru'), 
                 suffix = c('.nld', '.cfs_1.14'))
df2 = left_join(cfs_pr.anom_8.21, cfs_pr.anom_15.28, by = c('doy', 'hru'), 
                 suffix = c('.cfs_8.21', '.cfs_15.28'))
df_pr = left_join(df1, df2, by = c('doy', 'hru'))

df1 = left_join(nld_tm.anom, cfs_tm.anom_1.14, by = c('doy', 'hru'), 
                suffix = c('.nld', '.cfs_1.14'))
df2 = left_join(cfs_tm.anom_8.21, cfs_tm.anom_15.28, by = c('doy', 'hru'), 
                suffix = c('.cfs_8.21', '.cfs_15.28'))
df_tm = left_join(df1, df2, by = c('doy', 'hru'))
# df_tm$date.nld <- df_pr$date.nld <- NULL

hru_i = 158
hru_name = hru_vec[hru_i, 2]
hru_pr_df_yr = dplyr::filter(df_pr_yr,hru == hru_vec[hru_i, 1])
hru_tm_df_yr = dplyr::filter(df_tm_yr,hru == hru_vec[hru_i, 1])
hru_pr_df = dplyr::filter(df_pr,hru == hru_vec[hru_i, 1])
hru_tm_df = dplyr::filter(df_tm,hru == hru_vec[hru_i, 1])

plot_ls = list(hru_pr_df, hru_tm_df, hru_pr_df_yr, hru_tm_df_yr)
var = c('pr', 'tm', 'pr', 'tm')
lab = c(rep('1999-2010 DOY Average', times = 2), rep(paste0(yr, ' DOY'), times =2))

library(ggplot2)
library(gridExtra)
library(grid)

## function for plotting
grid_arrange_shared_legend <- function(..., ncol = length(list(...)), nrow = 1, position = c("bottom", "right")) {
  plots <- list(...)
  position <- match.arg(position)
  g <- ggplotGrob(plots[[1]] + theme(legend.position = position))$grobs
  legend <- g[[which(sapply(g, function(x) x$name) == "guide-box")]]
  lheight <- sum(legend$height)
  lwidth <- sum(legend$width)
  gl <- lapply(plots, function(x) x + theme(legend.position="none"))
  gl <- c(gl, ncol = ncol, nrow = nrow)
  
  combined <- switch(position,
                     "bottom" = arrangeGrob(do.call(arrangeGrob, gl),
                                            legend,
                                            ncol = 1,
                                            heights = unit.c(unit(1, "npc") - lheight, lheight)),
                     "right" = arrangeGrob(do.call(arrangeGrob, gl),
                                           legend,
                                           ncol = 2,
                                           widths = unit.c(unit(1, "npc") - lwidth, lwidth)))
  
  grid.newpage()
  grid.draw(combined)
  
  # return gtable invisibly
  invisible(combined)
}

setwd(dir_plots)
#pdf(paste0("timeseries_hru_analysis.pdf"), width=11, height=7)
##### ===== Variable Plot figures ===== #####
for (i in 1:length(var)) {
  if (var[i] == 'pr') {
#     print(ggplot(plot_ls[[i]], aes(doy)) +
#             geom_line(aes(y = var.mmPerD.cfs_15.28, colour = 'CFSv2 - 3-4 wk fcst'), size = 1) +
#             geom_line(aes(y = var.mmPerD.cfs_8.21, colour = 'CFSv2 - 2-3 wk fcst'), size = 1) +
#             geom_line(aes(y = var.mmPerD.cfs_1.14, colour = 'CFSv2 - 1-2 wk fcst'), size = 1) +
#             geom_line(aes(y = var.mmPerD.nld, colour = 'NLDAS - Observations'), size = 0.8) +
#             geom_line(data = hru_pr_df, aes(y = avgDoy.mmPerD.nld, colour = 'NLDAS - DOY Average'), size = 1.5, linetype = 'twodash') +
#             ylab('Precipitation (mm/day)') +
#             scale_linetype_manual(breaks = c('CFSv2 - 3-4 wk fcst', 'CFSv2 - 2-3 wk fcst', 
#                                              'CFSv2 - 1-2 wk fcst', 'NLDAS - Observations',
#                                              'NLDAS - DOY Average'),
#                                   values = c(rep("solid", 4), rep("dashed", 1))) +
#             scale_color_manual(hru_name, 
#                                breaks = c('CFSv2 - 3-4 wk fcst', 'CFSv2 - 2-3 wk fcst', 
#                                           'CFSv2 - 1-2 wk fcst', 'NLDAS - Observations',
#                                           'NLDAS - DOY Average'),
#                                values = c('#1f78b4', '#4daf4a', '#cab2d6','#636363','#000000')) +
#             ggtitle(paste0('Bi-weekly CFSv2 Forecast at Different Lead Times - ',lab[i],' Precipitation')) +
#             theme(plot.title = element_text(size = 12, hjust = 0.5)))
    
    hru_name = paste0('Colorado Headwaters ',lab[i])
    a= ggplot(plot_ls[[i]], aes(doy)) +
      geom_line(aes(y = var.mmPerD.cfs_1.14, colour = 'CFSv2 Fcst'), size = 1) +
      geom_line(aes(y = var.mmPerD.nld, colour = 'NLDAS - Observations'), size = 0.8) +
      geom_line(data = hru_pr_df, aes(y = avgDoy.mmPerD.nld, colour = 'NLDAS - DOY Average'), size = 1.5, linetype = 'dotted') +
      labs(y = 'Precipitation (mm/day)', x = '', title = 'CFSv2 - 1-2 wk Fcst') +
      scale_color_manual(hru_name, 
                         breaks = c('CFSv2 Fcst', 'NLDAS - Observations', 'NLDAS - DOY Average'),
                         values = c('#5aae61','#636363','#000000')) +
      theme(plot.title = element_text(size = 12, hjust = 0.5))
    b= ggplot(plot_ls[[i]], aes(doy)) +
      geom_line(aes(y = var.mmPerD.cfs_8.21, colour = 'CFSv2 - 2-3 wk fcst'), size = 1) +
      geom_line(aes(y = var.mmPerD.nld, colour = 'NLDAS - Observations'), size = 0.8) +
      geom_line(data = hru_pr_df, aes(y = avgDoy.mmPerD.nld, colour = 'NLDAS - DOY Average'), size = 1.5, linetype = 'dotted') +
      labs(y = '', x = 'Day of Year', title = 'CFSv2 - 2-3 wk Fcst') +
      scale_color_manual(hru_name, 
                         breaks = c('CFSv2 Fcst', 'NLDAS - Observations', 'NLDAS - DOY Average'),
                         values = c('#5aae61','#636363','#000000')) +
      theme(plot.title = element_text(size = 12, hjust = 0.5))
    c= ggplot(plot_ls[[i]], aes(doy)) +
      geom_line(aes(y = var.mmPerD.cfs_15.28, colour = 'CFSv2 - 3-4 wk fcst'), size = 1) +
      geom_line(aes(y = var.mmPerD.nld, colour = 'NLDAS - Observations'), size = 0.8) +
      geom_line(data = hru_pr_df, aes(y = avgDoy.mmPerD.nld, colour = 'NLDAS - DOY Average'), size = 1.5, linetype = 'dotted') +
      labs(y = '', x = '', title = 'CFSv2 - 3-4 wk Fcst') +
      scale_color_manual(hru_name, 
                         breaks = c('CFSv2 Fcst', 'NLDAS - Observations', 'NLDAS - DOY Average'),
                         values = c('#5aae61','#636363','#000000')) +
      theme(plot.title = element_text(size = 12, hjust = 0.5))

     grid_arrange_shared_legend(a, b, c, ncol = 3, nrow = 1)
  }
  
  if (var[i] == 'tm') {
#     print(ggplot(plot_ls[[i]], aes(doy)) + 
#             geom_line(aes(y = var.degC.cfs_15.28, colour = 'CFSv2 - 3-4 wk fcst'), size = 1) +
#             geom_line(aes(y = var.degC.cfs_8.21, colour = 'CFSv2 - 2-3 wk fcst'), size = 1) +
#             geom_line(aes(y = var.degC.cfs_1.14, colour = 'CFSv2 - 1-2 wk fcst'), size = 1) +
#             geom_line(aes(y = var.degC.nld, colour = 'NLDAS - Observations'), size = 0.8) +
#             geom_line(data = hru_tm_df, aes(y = avgDoy.degC.nld, colour = 'NLDAS - DOY Average'), size = 1.5, linetype = 'twodash') +
#             
#             ylab('Temperature (C)') +
#             scale_color_manual(hru_name, 
#                                breaks = c('CFSv2 - 3-4 wk fcst', 'CFSv2 - 2-3 wk fcst', 
#                                           'CFSv2 - 1-2 wk fcst', 'NLDAS - Observations',
#                                           'NLDAS - DOY Average'),
#                                values = c('#1f78b4', '#4daf4a', '#cab2d6','#636363','#000000')) +
#             ggtitle(paste0('Bi-weekly CFSv2 Forecast at Different Lead Times - ',lab[i],' Temperature')) +
#             theme(plot.title = element_text(size = 12, hjust = 0.5)))
    
    hru_name = paste0('Colorado Headwaters ',lab[i])
    a= ggplot(plot_ls[[i]], aes(doy)) +
      geom_line(aes(y = var.degC.nld, colour = 'NLDAS - Observations'), size = 0.8) +
      geom_line(data = hru_tm_df, aes(y = avgDoy.degC.nld, colour = 'NLDAS - DOY Average'), size = 1.5, linetype = 'dotted') +
      geom_line(aes(y = var.degC.cfs_1.14, colour = 'CFSv2 Fcst'), size = 1) +
      labs(y = 'Temperature (C)', x = '', title = 'CFSv2 - 1-2 wk Fcst') +
      scale_color_manual(hru_name, 
                         breaks = c('CFSv2 Fcst', 'NLDAS - Observations', 'NLDAS - DOY Average'),
                         values = c('#5aae61','#636363','#000000')) +
      theme(plot.title = element_text(size = 12, hjust = 0.5))
    b= ggplot(plot_ls[[i]], aes(doy)) +
      geom_line(aes(y = var.degC.nld, colour = 'NLDAS - Observations'), size = 0.8) +
      geom_line(data = hru_tm_df, aes(y = avgDoy.degC.nld, colour = 'NLDAS - DOY Average'), size = 1.5, linetype = 'dotted') +
      geom_line(aes(y = var.degC.cfs_8.21, colour = 'CFSv2 Fcst'), size = 1) +
      labs(y = '', x = 'Day of Year', title = 'CFSv2 - 2-3 wk Fcst') +
      scale_color_manual(hru_name, 
                         breaks = c('CFSv2 Fcst', 'NLDAS - Observations', 'NLDAS - DOY Average'),
                         values = c('#5aae61','#636363','#000000')) +
      theme(plot.title = element_text(size = 12, hjust = 0.5))
    c= ggplot(plot_ls[[i]], aes(doy)) +
      geom_line(aes(y = var.degC.nld, colour = 'NLDAS - Observations'), size = 0.8) +
      geom_line(data = hru_tm_df, aes(y = avgDoy.degC.nld, colour = 'NLDAS - DOY Average'), size = 1.5, linetype = 'dotted') +
      geom_line(aes(y = var.degC.cfs_15.28, colour = 'CFSv2 Fcst'), size = 1) +
      labs(y = '', x = '', title = 'CFSv2 - 3-4 wk Fcst') +
      scale_color_manual(hru_name, 
                         breaks = c('CFSv2 Fcst', 'NLDAS - Observations', 'NLDAS - DOY Average'),
                         values = c('#5aae61','#636363','#000000')) +
      theme(plot.title = element_text(size = 12, hjust = 0.5))
    
    grid_arrange_shared_legend(a, b, c, ncol = 3, nrow = 1)
    
  }
}

##### ===== Anomaly Plot figures ===== #####
for (i in 1:length(var)) {
  if (var[i] == 'pr') {
#     print(ggplot(plot_ls[[i]], aes(doy)) +
#             geom_line(aes(y = anom.mmPerD.cfs_15.28, colour = 'CFSv2 - 3-4 wk fcst'), size = 1) +
#             geom_line(aes(y = anom.mmPerD.cfs_8.21, colour = 'CFSv2 - 2-3 wk fcst'), size = 1) +
#             geom_line(aes(y = anom.mmPerD.cfs_1.14, colour = 'CFSv2 - 1-2 wk fcst'), size = 1) +
#             geom_line(aes(y = anom.mmPerD.nld, colour = 'NLDAS - Observations'), size = 0.8) +
#             geom_hline(yintercept=0, col="azure4", linetype="dashed", size = 1.1) +
#             ylab('Precipitation Anomaly(mm/day)') +
#             scale_color_manual(hru_name, 
#                                breaks = c('CFSv2 - 3-4 wk fcst', 'CFSv2 - 2-3 wk fcst', 
#                                           'CFSv2 - 1-2 wk fcst', 'NLDAS - Observations'),
#                                values = c('#1f78b4', '#4daf4a', '#cab2d6','#000000')) +
#             ggtitle(paste0('Bi-weekly CFSv2 Forecast at Different Lead Times - ',lab[i],' Precipitation Anomaly')) +
#             theme(plot.title = element_text(size = 12, hjust = 0.5)))
    
    hru_name = paste0('Colorado Headwaters ',lab[i])
    a= ggplot(plot_ls[[i]], aes(doy)) +
      geom_line(aes(y = anom.mmPerD.cfs_1.14, colour = 'CFSv2 Fcst'), size = 1) +
      geom_line(aes(y = anom.mmPerD.nld, colour = 'NLDAS - Observations'), size = 0.8) +
      labs(y = 'Precipitation Anomaly (mm/day)', x = '', title = 'CFSv2 - 1-2 wk Fcst') +
      scale_color_manual(hru_name, 
                         breaks = c('CFSv2 Fcst', 'NLDAS - Observations', 'NLDAS - DOY Average'),
                         values = c('#5aae61','#000000','#000000')) +
      theme(plot.title = element_text(size = 12, hjust = 0.5))
    b= ggplot(plot_ls[[i]], aes(doy)) +
      geom_line(aes(y = anom.mmPerD.cfs_8.21, colour = 'CFSv2 Fcst'), size = 1) +
      geom_line(aes(y = anom.mmPerD.nld, colour = 'NLDAS - Observations'), size = 0.8) +
      labs(y = '', x = 'Day of Year', title = 'CFSv2 - 2-3 wk Fcst') +
      scale_color_manual(hru_name, 
                         breaks = c('CFSv2 Fcst', 'NLDAS - Observations', 'NLDAS - DOY Average'),
                         values = c('#5aae61','#000000','#000000')) +
      theme(plot.title = element_text(size = 12, hjust = 0.5))
    c= ggplot(plot_ls[[i]], aes(doy)) +
      geom_line(aes(y = anom.mmPerD.cfs_15.28, colour = 'CFSv2 Fcst'), size = 1) +
      geom_line(aes(y = anom.mmPerD.nld, colour = 'NLDAS - Observations'), size = 0.8) +
      labs(y = '', x = '', title = 'CFSv2 - 3-4 wk Fcst') +
      scale_color_manual(hru_name, 
                         breaks = c('CFSv2 Fcst', 'NLDAS - Observations', 'NLDAS - DOY Average'),
                         values = c('#5aae61','#000000','#000000')) +
      theme(plot.title = element_text(size = 12, hjust = 0.5))
    
    grid_arrange_shared_legend(a, b, c, ncol = 3, nrow = 1)
  }
  
  if (var[i] == 'tm') {
#     print(ggplot(plot_ls[[i]], aes(doy)) + 
#             geom_line(aes(y = anom.degC.cfs_15.28, colour = 'CFSv2 - 3-4 wk fcst'), size = 1) +
#             geom_line(aes(y = anom.degC.cfs_8.21, colour = 'CFSv2 - 2-3 wk fcst'), size = 1) +
#             geom_line(aes(y = anom.degC.cfs_1.14, colour = 'CFSv2 - 1-2 wk fcst'), size = 1) +
#             geom_line(aes(y = anom.degC.nld, colour = 'NLDAS - Observations'), size = 0.8) +
#             geom_hline(yintercept=0, col="azure4", linetype="dashed", size = 1.1) +
#             ylab('Temperature Anomaly (C)') +
#             scale_color_manual(hru_name, 
#                                breaks = c('CFSv2 - 3-4 wk fcst', 'CFSv2 - 2-3 wk fcst', 
#                                           'CFSv2 - 1-2 wk fcst', 'NLDAS - Observations'),
#                                values = c('#1f78b4', '#4daf4a', '#cab2d6','#000000')) +
#             ggtitle(paste0('Bi-weekly CFSv2 Forecast at Different Lead Times - ',lab[i],' Temperature Anomaly')) +
#             theme(plot.title = element_text(size = 12, hjust = 0.5)))
    
    hru_name = paste0('Colorado Headwaters ',lab[i])
    a= ggplot(plot_ls[[i]], aes(doy)) +
      geom_line(aes(y = anom.degC.cfs_1.14, colour = 'CFSv2 Fcst'), size = 1) +
      geom_line(aes(y = anom.degC.nld, colour = 'NLDAS - Observations'), size = 0.8) +
      labs(y = 'Temperature Anomaly (C)', x = '', title = 'CFSv2 - 1-2 wk Fcst') +
      scale_color_manual(hru_name, 
                         breaks = c('CFSv2 Fcst', 'NLDAS - Observations', 'NLDAS - DOY Average'),
                         values = c('#5aae61','#000000','#000000')) +
      theme(plot.title = element_text(size = 12, hjust = 0.5))
    b= ggplot(plot_ls[[i]], aes(doy)) +
      geom_line(aes(y = anom.degC.cfs_8.21, colour = 'CFSv2 Fcst'), size = 1) +
      geom_line(aes(y = anom.degC.nld, colour = 'NLDAS - Observations'), size = 0.8) +
      labs(y = '', x = 'Day of Year', title = 'CFSv2 - 2-3 wk Fcst') +
      scale_color_manual(hru_name, 
                         breaks = c('CFSv2 Fcst', 'NLDAS - Observations', 'NLDAS - DOY Average'),
                         values = c('#5aae61','#000000','#000000')) +
      theme(plot.title = element_text(size = 12, hjust = 0.5))
    c= ggplot(plot_ls[[i]], aes(doy)) +
      geom_line(aes(y = anom.degC.cfs_15.28, colour = 'CFSv2 Fcst'), size = 1) +
      geom_line(aes(y = anom.degC.nld, colour = 'NLDAS - Observations'), size = 0.8) +
      labs(y = '', x = '', title = 'CFSv2 - 3-4 wk Fcst') +
      scale_color_manual(hru_name, 
                         breaks = c('CFSv2 Fcst', 'NLDAS - Observations', 'NLDAS - DOY Average'),
                         values = c('#5aae61','#000000','#000000')) +
      theme(plot.title = element_text(size = 12, hjust = 0.5))
    
    grid_arrange_shared_legend(a, b, c, ncol = 3, nrow = 1)
  }
}
dev.off()
