#!/bin/csh
# S. Baker, July 2017
# script to regrid NMME timeseries forecast
# file to 0.5x0.5 degree; rename dimensions
# and variables; cut to CONUS domain

# load NCL module
module load ncl
module load nco

# ------ settings --------
set rawDir = /glade/p/work/flehner/nmme/hcst
set TmpGFDLDir = /glade2/scratch2/sabaker/nmme/hcst/tmpGFDL
set TmpDir = /glade2/scratch2/sabaker/nmme/hcst/tmp
set logDir = /glade2/scratch2/sabaker/nmme/hcst/log
set renameDir = /glade2/scratch2/sabaker/nmme/hcst/tmp_rename
set NCDir = /glade2/scratch2/sabaker/nmme/hcst/nc_CONUS

# ------------------------

# loop through variables and get data for year supplied
#foreach Var (tmp2m prate)
foreach Var (tmp2m)

  # evaluate ncl script; input: file with dir, variable
  foreach File ($rawDir/$Var*198201-201612*1x1.nc)
        set output = $TmpDir/$Var/$File:t:r.nc
        ncl 'in_file="'${File}'"' 'var_in="'${Var}'"' 'out_file="'${output}'"' nmme_regrid.ncl
  end

  # remove GFDL files from tmp folder since they are bad
  rm -rf $TmpDir/$Var/*GFDL*

  # rename GFDL and GFDL_FLOR files to regrid with cdo
  foreach File ($rawDir/$Var*GFDL*198201-201612*1x1.nc)
	set output2 = $TmpDir/$Var/$File:t:r.nc
	set output1 = $TmpGFDLDir/$Var/$File:t:r.nc
	ncrename -O -d issue_time,time -v issue_time,time $File $output1
	cdo remapbil,r720x360 $output1 $output2
	ncrename -O -d time,issue_time -v time,issue_time $output2
  end

  # rename files and cut
  foreach File ($TmpDir/$Var/*)
	set nm_out = $renameDir/$Var/$File:t:r.nc
        set output = $NCDir/$Var/$File:t:r.nc
        
	# rename variables and dimensions
	ncrename -d fcst_time,t -d issue_time,tn -v lat,latitude -v lon,longitude $File $nm_out

        # CONUS domain - 5,75N 185,305E
        ncea -d lat,190,329 -d lon,370,609 $nm_out $output
  end

end   # end of variable loop
