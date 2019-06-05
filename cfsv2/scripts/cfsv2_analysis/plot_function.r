plot_map <- function(var_name, matrix, var_col, lim_max = NA, lim_min = NA, 
                     legend_title = NA, lab = NA, type = 'discrete',
                     cust_pal = NA) {
  # var_name = 'tmp_2m' or 'prate'; matrix = data frame; var_col = column with the variable;
  # lim_max = colorbar max limit; lim_min = colorbar min limit
  
  # TEST
  # var_name = 'prate'
  # matrix = cor
  # var_col = 'inc_cor'
  # type = 'discrete'
  # lab = lab
  # legend_title = 'Anomaly Correlation'
  # cust_pal = cust_pal
  # lim_max = NA
  # lim_min = NA
  
  
  ##### ===== Load Libraries ===== #####
  library(PBSmapping)
  library(maps)
  # library(tidyverse)
  library(ggplot2)
  # library(dplyr) 
  library(data.table)
  library(PBSmapping)
  library(maps)
  
  ##### ===== Read HUC4 data and combine with forecast ===== #####
  
  ## Read in huc4_dt rstudio file for use
  #setwd(dir_HUCmatrix)
  load('/home/sabaker/s2s/analysis/files/plots/HUC4_df.RData')
  huc4_dt$hru = huc4_dt$HUC4
  huc4_dt$hru = as.numeric(as.character(huc4_dt$hru))
  
  ## get variable column
  if (is.numeric(var_col)) {
    matrix$var = matrix[,var_col]
  } else if (is.character(var_col)) {
    matrix$var = matrix[[var_col]]
  } else {
    print('Variable column not in correct format. Either col number or name.')
  }
  ## change data type of hru column based on matrix
  if (!is.numeric(matrix$var)) {
    matrix$var = as.numeric(as.character(matrix$var))
  }
  
  ## change data type of hru column based on matrix
  if (!is.numeric(matrix$hru)) {
    matrix$hru = as.numeric(as.character(matrix$hru))
  }
  
  ## join matricies by HUC4 id 
  var_huc = left_join(huc4_dt, matrix, by = "hru")

  # scale limits
  if (is.na(lim_max)) { lim_max = max(na.omit(matrix$var)) }
  if (is.na(lim_min)) { lim_min = min(na.omit(matrix$var)) }
  
  ##### ====== Plotting ====== #####
  
  ## commands for making pretty spatial Lon / Lat labels
  ewbrks = seq(-180, 180, 10)
  nsbrks = seq(-50, 50, 10)
  ewlbls = unlist(lapply(ewbrks, function(x) ifelse(x > 0, paste0(x, '°E'), 	ifelse(x < 0, paste0(abs(x), '°W'), x))))
  nslbls = unlist(lapply(nsbrks, function(x) ifelse(x < 0, paste0(abs(x), 	'°S'), ifelse(x > 0, paste0(x, '°N') ,x))))
  
  ## Color palettes and labels for temp vs. prate
  #if (!exists('cust_pal')) 
  if (var_name == 'tmp_2m' | var_name == 'tmp2m') {
    ## continuous
    if (type == 'continuous' & anyNA(cust_pal)) {
      cust_pal = c('#053061','#0e4482','#1e63b2','#f7f7f7','#d11f35','#d73027','#9e0142')
    }
    ## discrete
    if (type == 'discrete' & anyNA(cust_pal)) {
      color_test <- colorRampPalette(c('#2166ac','#f7f7f7', '#b2182b'),space = "rgb") #for discrete
      cust_pal = color_test(nlevels(var_huc$bins))
    }
    
    ## legend
    if (is.na(legend_title)) { legend_title = 'Temperature (°C)' }
  
  } else if (var_name == 'prate') {
    ## continuous
    if (type == 'continuous' & anyNA(cust_pal)) {
      cust_pal = c('#a50026','#d73027','#ffffbf','#1a9850','#006837')
    }
    ## discrete
    if (type == 'discrete' & anyNA(cust_pal)) {
      color_test <- colorRampPalette(c('#a50026','#ffffbf', '#006837'),space = "rgb") #for discrete
      cust_pal = color_test(nlevels(var_huc$bins))
    }
    ## legend
    if (is.na(legend_title)) { legend_title = 'Precipitation \nRate (mm/d)' }
  
  } else {
    print('variable unknown -- use tmp_2m or prate')
  }
  
  ## cut border polygon from world map to CONUS domain
  worldmap = map_data('world') # doesnt work in tidyverse
  # world_map <- maps::map("world", ".", exact = FALSE, plot = FALSE, fill = TRUE) %>% fortify()
  # world_map <- ggplot(world_map)
  setnames(worldmap, c('X','Y', 'PID', 'POS', 'region', 'subregoin'))
  worldmap = clipPolys(worldmap, xlim = c(-126, -66), ylim = c(24, 54))
  
  
  ## plot
  if (type == 'discrete') {
    #cust_pal = color_test(nlevels(var_huc$bins))
    p = ggplot(data = var_huc, aes(x = long, y = lat, group = hru, fill = bins)) + 
      # add boarders
      geom_polygon(data = worldmap, aes(X,Y,group=PID), color = NA, size = 0.5, fill = 'grey85') + 
      # HUC4 polygon setup
      geom_polygon() + 
      # fill color scale, legend appearance and title
      scale_fill_manual(values = cust_pal, name = legend_title, drop = F, labels = lab,
                        guide = guide_legend(ncol = 1, label.position = 'right', label.hjust = 0,
                                             title.position = 'top', title.hjust = 0.5, reverse = T,
                                             keywidth = 1, keyheight = 1)) + 
      # Draw HUC polygons
      geom_path(color = 'gray73', size = 0.15) + #grey60
      # ggplot has built-in themes
      theme_bw() + 
      # legend location...theme can take in other appearance / layout arguments - NOTE, if used with a built-in theme, e.g. theme_bw() it needs to be called after to not get overridden
      theme(legend.position = 'right') +
      # ratio of x and y...coord equal preserves the relative sizes of each
      coord_equal() +
      # label on the x axis
      xlab('') +  
      # label on the y axis
      ylab('') + 
      # state borders
      geom_polygon(data=map_data("state"), aes(x=long, y=lat, group=group), color="grey42", size = 0.3, fill=NA, linetype = 'dashed')+
      # tic mark locations and labels on the x axis
      scale_x_continuous(breaks = ewbrks, labels = ewlbls, expand = c(0, 0)) +
      # tic mark locations and labels on the y axis 
      scale_y_continuous(breaks = nsbrks, labels = nslbls, expand = c(0, 0)) #+ 
      # # set margins (wider on right)
      # theme(plot.margin=unit(c(0.15,0.5,0.15,0.05),'cm')) #top, right, bottom, left 
  }
  
  if (type == 'continuous') {
   p = ggplot(data = var_huc, aes(x = long, y = lat, group = hru, fill = var)) + 
    # add boarders
    geom_polygon(data = worldmap, aes(X,Y,group=PID), color = NA, size = 0.5, fill = 'grey85') + 
    # HUC4 polygon setup
    geom_polygon() + 
    # fill color scale, legend appearance and title
    #scale_fill_gradient2(low = low, mid = mid, high = high, na.value = 'NA', midpoint = mid_test, name = legend_title, limits = c(lim_min, lim_max), 
    #                     guide = guide_colorbar(title.position = 'bottom', barwidth = 20, barheight = 0.5, title.hjust = 0.5)) + 
    scale_fill_gradientn(colours = cust_pal, na.value = 'NA', name = legend_title, limits = c(lim_min, lim_max), guide = guide_colorbar(title.position = 'bottom', barwidth = 20, barheight = 0.5, title.hjust = 0.5)) + 
    # Draw HUC polygons
    geom_path(color = 'gray73', size = 0.15) +
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
    # state borders
    geom_polygon(data=map_data("state"), aes(x=long, y=lat, group=group), color="grey42", size = 0.3, fill=NA, linetype = 'dashed')+
    # tic mark locations and labels on the x axis
    scale_x_continuous(breaks = ewbrks, labels = ewlbls, expand = c(0, 0)) +
    # tic mark locations and labels on the y axis 
    scale_y_continuous(breaks = nsbrks, labels = nslbls, expand = c(0, 0)) + 
    # set margins (wider on right)
    theme(plot.margin=unit(c(0.15,0.5,0.15,0.05),'cm')) #top, right, bottom, left 
  }
  
  return(p)
}
