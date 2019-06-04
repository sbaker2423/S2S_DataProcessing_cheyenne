#!/bin/csh
# S. Baker, Jan 2018
# cut data to XCONUS domain and keep subdaily timestep


set Year = $1  # 2009

# load modules
module load cdo
module load nco

# ------ settings --------
set TmpDir = /glade2/scratch2/sabaker/cfsv2/files/tmp
set logDir = /glade2/scratch2/sabaker/cfsv2/files/log
set inputDir = /glade2/scratch2/sabaker/cfsv2/files/raw_nc
set outputDir = /glade2/scratch2/sabaker/cfsv2/files/XCONUS

# ------------------------

# loop through variables and get data for year supplied
foreach Var (ocnsst_h)

  # make the output directory if it doesn't exist
  if ( ! -d $outputDir/$Var/$Year ) then
    mkdir -p $outputDir/$Var/$Year
  endif

  # cut to XCONUS domain and rename
  foreach File ($inputDir/$Var/$Year/*)
        
        set outFile = $outputDir/$Var/$Year/$File:t:r.nc

	# check if file exists
	if(! -e $outFile) then
        
		# CONUS domain - 5,75N 185,305E
	        ncea -d lat,190,329 -d lon,370,609 $File $outFile

        	# rename variables
	        ncrename -O -d lat,y -d lon,x -d time,t $outFile
	else
       		echo skipping $outFile
     	endif

  end

end   # end of variable loop
