#!/bin/csh
# S. Baker, Mar 2018
# script to convert raw CFSv2 var files from grib2 to ncdf,
# cut to desired grid
# argument so that this can be parallelized by year.

set Year = $1  # 2009

# load NCL module - may not be necessary
module load ncl
module load grib-bins
module load grib-libs
module load cdo
module load nco

# ------ settings --------
set GribDir = /glade/scratch/sabaker/cfsv2/files/rawdata
set TmpDir = /glade/scratch/sabaker/cfsv2/files/tmp
set logDir = /glade/scratch/sabaker/cfsv2/files/log
set NCDir = /glade/scratch/sabaker/cfsv2/files/raw_nc

# ------------------------

# loop through variables and get data for year supplied
foreach Var (ulwtoa_f)

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

	# normal variables - cut domain - 30S to 90N; 70E to 360
	#ncea -d latitude,29,179 -d longitude,69,359 $File $output
	# q2m, pressfd, pwat - different domain...
	ncea -d latitude,29,189 -d longitude,73,383 $File $output
	# sst is at 0.5 degree - (x2 to index) -1 (index starts at 0)
	#ncea -d latitude,59,359 -d longitude,139,719 $File $output
  end

end   # end of variable loop
