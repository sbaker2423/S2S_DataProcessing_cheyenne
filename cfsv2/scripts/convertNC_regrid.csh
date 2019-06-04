#!/bin/csh
# S. Baker, Nov 2016
# script to convert raw CFSv2 timeseries forecast files from grib2 to ncdf,
# regrid the file to 0.5x0.5 degree. This file takes the year as
# argument so that this can be parallelized by year.

set Year = $1  # 2009

# load NCL module - may not be necessary
module load ncl
module load grib-bins
module load grib-libs
module load cdo

# ------ settings --------
set GribDir = /glade2/scratch2/sabaker/cfsv2/files/rawdata
set TmpDir = /glade2/scratch2/sabaker/cfsv2/files/tmp
set logDir = /glade2/scratch2/sabaker/cfsv2/files/log
set NCDir = /glade2/scratch2/sabaker/cfsv2/files/raw_nc

# ------------------------

# loop through variables and get data for year supplied
foreach Var (ocnsst_h)

  # make the temp directory if it doesn't exist
  if ( ! -d $TmpDir/$Var/$Year ) then
    mkdir -p $TmpDir/$Var/$Year
  endif

  # make the output directory if it doesn't exist
  if ( ! -d $NCDir/$Var/$Year ) then
    mkdir -p $NCDir/$Var/$Year
  endif

  #goto MARK

  # loop over each file in the raw year directory
  touch $logDir/log.$Year
  foreach File ($GribDir/$Var/$Year/*)

    set outFile = $TmpDir/$Var/$Year/$File:t:r.nc

    # check if file exists, then convert
    if ( ! -f $outFile ) then     
      echo converting $File
      wgrib2 $File -netcdf $outFile >>& $logDir/log.$Year
    endif

  end

  #MARK:

  # map and regrid - (old used ncl)
  foreach File ($TmpDir/$Var/$Year/*)
        set output = $NCDir/$Var/$Year/$File:t:r.nc
	cdo remapbil,r720x360 $File $output
        # ncl 'in_file="'${File}'"' 'var_in="'${Var}'"' 'out_file="'${output}'"' cfsv2_regrid.ncl
  end

end   # end of variable loop
