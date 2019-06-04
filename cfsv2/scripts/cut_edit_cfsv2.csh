#!/bin/csh
# S. Baker, Dec 2016
# script to convert rename netcdf files and cut to
# CONUS, AK, and HI domains. This file takes the year as
# argument so that this can be parallelized by year.

set Year = $1  # 2009

module load nco

# ------ settings --------
set TmpDir = /glade/scratch/sabaker/cfsv2/files/tmp
set logDir = /glade/scratch/sabaker/cfsv2/files/log
set inputDir = /glade/p_old/ral/RHAP/s2s/cfsv2/daily_ts/  #/glade/scratch/sabaker/cfsv2/raw_nc
set outputDir = /glade/scratch/sabaker/cfsv2/files/XCONUS

# ------------------------

# loop through variables and get data for year supplied
#foreach Var (prate_f tmp2m_f)
foreach Var (tmp2m_f prate_f)
  # others: (dlwsfc_f dswsfc_f prate_f q2m_f pressfc_f tmp2m_f wnd10m_f)

  # set variable name in netcdf for temperature
  if ( $Var == tmp2m_f ) then
  	set var_name = tmp_2m
        set var_nm_in = TMP_2maboveground
  endif

  # set variable name in netcdf for precipitation
  if ( $Var == prate_f ) then
  	set var_name = prate
        set var_nm_in = PRATE_surface
  endif

  # make the temp directory if it doesn't exist
  if ( ! -d $TmpDir/$Var/$Year ) then
    mkdir -p $TmpDir/$Var/$Year
  endif

  # make the output directory if it doesn't exist
  if ( ! -d $outputDir/$Var/$Year ) then
    mkdir -p $outputDir/$Var/$Year
  endif

  # loop over each file and edit att & var
  touch $logDir/log.$Year
  foreach File ($inputDir/$Var/$Year/*)
    echo editing $File
    
    # rename attributes
    ncrename -d lon,x -d lat,y -d time,t -v $var_nm_in,$var_name -v lon,longitude -v lat,latitude $File $TmpDir/$Var/$Year/$File:t:r.nc
    
  end

  # cut to XCONUS domain
  foreach File ($TmpDir/$Var/$Year/*)
        # CONUS domain - 5,75N 185,305E
	# NOTE: correct dimensions now!
        ncea -d y,190,329 -d x,370,609 $File $outputDir/$Var/$Year/$File:t:r.nc

        # remove temp file
        rm -f $File
  end

end   # end of variable loop
