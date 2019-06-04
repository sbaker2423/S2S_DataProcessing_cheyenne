#!/bin/csh
# S. Baker, Jan 2017
# average forecasts to HUC4 scale using poly2poly.map_timeseries.py
# input a year as the argument.

set Year = $1  # 2009

#set Python = /usr/bin/python2.7

# on yellowstone need
module load python
module load netcdf4python
module load numpy

set Python  = python

# ------ settings --------
set HucDir = /glade/scratch/sabaker/cfsv2/HUC4_XCONUS
set logDir = /glade/scratch/sabaker/cfsv2/log
set NCDir = /glade/scratch/sabaker/cfsv2/XCONUS

set scripts = /glade/u/home/sabaker/cfsv2/scripts

# ------------------------

# loop through variables and get data for year supplied
#foreach Var (prate_f tmp2m_f)
foreach Var (tmp2m_f)

  # make the output directory if it doesn't exist
  if ( ! -d $HucDir/$Var/$Year ) then
    mkdir -p $HucDir/$Var/$Year
  endif

  # loop over each file in the raw year directory
  touch $logDir/log.$Year
  foreach File ($NCDir/$Var/$Year/*)
    echo HUC averaging $File
    #$Python $scripts/poly2poly.map_timeseries_prate.py $scripts/mapping.cfsv2_to_NHDPlusHUC4.nc $File $HucDir/$Var/$Year/$File:t:r.nc >>& $logDir/log.$Year
    $Python $scripts/poly2poly.map_timeseries_tmp_2m.py $scripts/mapping.cfsv2_to_NHDPlusHUC4.nc $File $HucDir/$Var/$Year/$File:t:r.nc >>& $logDir/log.$Year
  end

end   # end of variable loop
