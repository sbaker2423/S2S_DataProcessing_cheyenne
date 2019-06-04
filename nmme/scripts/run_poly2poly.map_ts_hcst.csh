#!/bin/csh
# S. Baker, Jul 2017
# average forecasts to HUC4 scale using poly2poly.map_timeseries.py
# input a year as the argument.

set Var = $1

# on yellowstone need
module load python
module load netcdf4python
module load numpy
module load nco

# ------ settings --------
set NCDir = /glade2/scratch2/sabaker/nmme/nc_CONUS
set HucDir = /glade2/scratch2/sabaker/nmme/HUC_avg
set splitDir = /glade2/scratch2/sabaker/nmme/nc_CONUS_split
set scripts = /glade/u/home/sabaker/nmme/scripts

# ------------------------

# loop through variables and get data for year supplied

# split files by issue date
foreach File ($NCDir/$Var/*)
  set ITDim = `ncks -m $File | grep "issue_time dimension" | cut -d" " -f7`

  # save split files to new directory
  set i = 0
  while ( $i != $ITDim )
     echo $splitDir/$Var/$File:t:r.ITDIM-$i.nc
     ncks -d tn,$i $File $splitDir/$Var/$File:t:r.ITDIM-$i.nc
     @ i = $i + 1
  end
end


# loop over each file in the raw year directory
foreach File ($splitDir/$Var/*)    
  python $scripts/poly2poly.map_timeseries_$Var.py $scripts/mapping.nmme_to_NHDPlusHUC4.nc $File $HucDir/$Var/$File:t:r.nc
end


