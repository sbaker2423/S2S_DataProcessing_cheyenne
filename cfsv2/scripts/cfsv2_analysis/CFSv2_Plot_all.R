# ===========================================
# Plot bi-weekly time periods
# S. Baker, April 2017
# ===========================================
rm(list=ls())

## Load libraries
library(dplyr)
library(RColorBrewer)
library(gridExtra)

## Directories
dir_cfs = '/home/sabaker/s2s/analysis/files/cfsv2_files/2wk_analysis/'
dir_plots = '/home/sabaker/s2s/analysis/files/plots/'

## Load plotting function
source('/home/sabaker/s2s/analysis/scripts/cfsv2_analysis/plot_function.r')

##### ===== Load statistics ===== #####
setwd(dir_cfs)
# df = readRDS('t.p_stats.rds')
df = readRDS('QM_cfsv2.nldas_Stats.rds')
df = data.frame(lapply(df, as.character), stringsAsFactors=FALSE)
df$val = as.numeric(df$val)

#####  ============== Graph time_peral Statistics ==============  #####
setwd(dir_plots)
seas = cbind(c('JFM','FMA','MAM','AMJ','MJJ','JJA','JAS','ASO','SON','OND','NDJ','DJF','annual'), 
             c('JFM','FMA','MAM','AMJ','MJJ','JJA','JAS','ASO','SON','OND','NDJ','DJF','Annual'))
lead_v = cbind(c('1.14', '8.21', '15.28'), c('1-2', '2-3', '3-4'), c('1-2wk', '2-3wk', '3-4wk'))
var_v = cbind(c('tmp2m', 'prate'), c('Temperature', 'Precipitation Rate'))
type_v = cbind(c('raw', 'qm'), c('Raw', 'Bias-Corrected (QM)'))
stat_v = cbind(c('acc', 'bias'), c('Anomaly Correlation', 'Bias'))

## custom palletes
#cust_pal = rev(colorRampPalette(brewer.pal(11,"Spectral"))(12))

#t=s=v=j=i=1

##  == forecast type loop
for (t in 1:nrow(type_v)) {
  
  ##  == statistic loop
  for(s in 1:nrow(stat_v)) {
    if(stat_v[s,1] == 'acc') {
      bin_v = c(1, 0.8, 0.6, 0.5, 0.45, 0.4, 0.35, 0.3, 0.25, 
                0.2, 0.15, 0.1, 0.05, 0, -.1, -.2, -.3, -.5)
      cust_pal = (c("#5E4FA2", "#4470B1", "#3B92B8", "#59B4AA", "#7ECBA4", "#A6DBA4", "#CAE99D", "#E8F69C",
                    "#FEF5AF", "#FEE391", "#FDC877", "#FCAA5F", "#F7834D", "#EC6145", "#DA464C", "#BE2449", "#9E0142"))
      
    } else if (stat_v[s,1] == 'bias') {
      bin_v = c(4.0, 2.5, 2.0, 1.5, 1.0, 0.8, 0.5, 0.2, 0.1, 0.0, 
                   -0.1, -0.2, -0.5, -0.8, -1.0, -1.5, -2.0, -2.5, -4.0)
      cust_pal = (c("#5E4FA2", "#4470B1", "#3B92B8", "#59B4AA", "#7ECBA4", "#A6DBA4", "#CAE99D", "#E8F69C", "#F7FCB3",
                      "#FEF5AF", "#FEE391", "#FDC877", "#FCAA5F", "#F7834D", "#EC6145", "#DA464C", "#BE2449", "#9E0142"))
    }
    
    
    ##  ==  variable loop
    for (v in 1:2) {
      p_v = list()
      
      ##  ==  lead loop
      for (j in 1:3) {
        pl = list()
        
        ##  ==  season loop
        for (i in 1:12) {
          df_plot = dplyr::filter(df, fcst_type == type_v[t,1], var == var_v[v,1], 
                                  stat == stat_v[s,1], lead == lead_v[j,1], time_per == seas[i,1])
          
          ## plot
          df_plot$bins = cut(df_plot$val, breaks = bin_v)
          lab = levels(df_plot$bins)
          p = plot_map(var_v[v,1], df_plot, 6, type = 'discrete', lab = lab,  
                       cust_pal = cust_pal, legend_title = stat_v[s,2])
          pl[[i]] = p + guides(fill=FALSE)
        }
        
        ## arrange on same page and save
        g = arrangeGrob(grobs = pl, ncol = 3, top = paste0(stat_v[s,2], ' - ', type_v[t,2],' CFSv2 ', 
                                                           lead_v[j,2],' Week Avg. ', var_v[v,2],' (1999-2010)'))
        ggsave(paste0(type_v[t,1], '_CFSv2_seasons_',stat_v[s,1],'_', var_v[v,1],'_',lead_v[j,3],'.png'), 
               g, height = 5*4/2.2, width = 6*3/1.5, dpi = 300)
        
        
        ##  == plot annual 
        i = 13
        df_plot = dplyr::filter(df, fcst_type == type_v[t,1], var == var_v[v,1], 
                                stat == stat_v[s,1], lead == lead_v[j,1], time_per == seas[i,1])
        
        ## plot
        df_plot$bins = cut(df_plot$val, breaks = bin_v)
        lab = levels(df_plot$bins)
        p2 = plot_map(var_v[v,1], df_plot, 6, type = 'discrete', lab = lab,  
                      cust_pal = cust_pal, legend_title = stat_v[s,2])
        p_v[[j]] = p2 + guides(fill=FALSE)
        #ggtitle(paste0('Anomaly Correlation - CFSv2 ', lead_v[j,2],' Week Avg. ', var_v[v,2],' (1999-2010)'))
        ggsave(paste0(type_v[t,1], '_CFSv2_annual_', stat_v[s,1],'_', var_v[v,1],'_',lead_v[j,3],'.png'), 
               p2, height = 6/1.2, width = 10/1.2, dpi = 300)
      }
      g_v = arrangeGrob(grobs = p_v, ncol = 3, top = paste0(stat_v[s,2], ' - ', type_v[t,2],' CFSv2 ', 
                                                            var_v[v,2],' (1999-2010)'))
      ggsave(paste0(type_v[t,1], '_CFSv2_annual_',stat_v[s,1],'_', var_v[v,1],'_highres.png'), 
             g_v, height = 5/2.2, width = 6*3/1.5, dpi = 350)
    }
  }
}
