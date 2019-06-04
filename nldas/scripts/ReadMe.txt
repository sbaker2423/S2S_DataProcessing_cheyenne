### === NLDAS - data setup - hydro-c1

set raw_Dir = /d5/common/forcingData/nldas/daily_utc
set raw_Dir = /home/sabaker/s2s/nldas/files/raw_nldas (?) same
set var_Dir = /d1/sabaker/s2s/NLDAS/files/cut_rename_vars
set script_Dir = /home/sabaker/s2s/cfsv2/scripts

# extract, rename variables (hydro-c1)
foreach File ($raw_Dir/*)

  # extract variable
  ncks -v lon_110,lat_110,time,prcp_avg $File $var_Dir/prate/$File:t:r.nc
  ncks -v lon_110,lat_110,time,tair_avg $File $var_Dir/tmp_2m/$File:t:r.nc

  # rename dimensions and variables
  ncrename -v lat_110,latitude -v lon_110,longitude -v prcp_avg,prate -d lat_110,lat -d lon_110,lon 
$var_Dir/prate/$File:t:r.nc
  ncrename -v lat_110,latitude -v lon_110,longitude -v tair_avg,tmp_2m -d lat_110,lat -d lon_110,lon 
$var_Dir/tmp_2m/$File:t:r.nc

  # edit units
 # ncatted -a units,prate,c,"kg/m^2/hr" $var_Dir/prate/$File:t:r.nc

end

# looks like I didnt regrid nldas data with ncl (already on 1/8 degree grid)

## merge into one file
cdo mergetime $var_Dir/prate/* $var_Dir/NLDAS_prate_1980-2016_raw.nc
cdo mergetime $var_Dir/tmp_2m/* $var_Dir/NLDAS_tmp2m_1980-2016_raw.nc

## New - copy to Cheyenne to process
scp NLDAS_*_1980-2016_raw.nc cheyenne.ucar.edu:/glade2/scratch2/sabaker/nldas/raw_data/


### === Create correspondence (mapping) file to average to hucs (hydro-c1)
# see cfsv2_readme.txt! The same process is used for both cfsv2 and nldas


# HUC average (takes 40 mins for ~ 30 years)
set HUC_avg = ~/s2s/nldas/files/HUC_avg
set Var = prate
foreach File ($var_Dir/$Var/*)
  python $script_Dir/poly2poly.map_timeseries_$Var.py 
~/s2s/nldas/scripts/mapping.NLDAS_to_NHDPlusHUC4_2.nc $File $HUC_avg/$Var/$File:t:r.nc
end


## Average 14 days of NLDAS (1-2 wk, 2-3 wk, 3-4wk) <- can remember if before or after mergin files
# change start and end day in script
/glade/u/home/sabaker/nldas/scripts/avg_2wk.csh
bsub < avg_2wk.lsf

## edit the history
ncatted -a history,global,o,c,"Averaged first 14 days with 
/glade/u/home/sabaker/nldas/scripts/avg_days_1to14.csh" NLDAS_2wk_avg.nc out.nc

## change variable name - sometimes need to do...
ncrename -v tmp_2m,tmp2m NLDAS_1to14day_tmp2m.nc
ncatted -a units,prate,c,"kg/m^2/hr" NLDAS_2wk_avg.nc

## merge into one file ($var_Dir/$Var) and add back in hru var
cdo mergetime $var_Dir/prate/* $var_Dir/prate/NLDAS_prate_1980-2011.nc
ncks -A -M -v hru NLDAS_1999.nc NLDAS_prate_1980-2011.nc
cdo mergetime * NLDAS_tmp2m_1980-2011.nc
ncks -A -M -v hru NLDAS_1999.nc NLDAS_tmp2m_1980-2011.nc

## copy over
cp /home/sabaker/s2s/nldas/files/HUC_avg/prate/NLDAS_prate_1980-2011.nc NLDAS_prate_1980-2011.nc
cp /home/sabaker/s2s/nldas/files/HUC_avg/tmp_2m/NLDAS_tmp2m_1980-2011.nc NLDAS_tmp_2m_1980-2011.nc

/d1/sabaker/s2s/NLDAS/files/HUC_avg/raw_new
