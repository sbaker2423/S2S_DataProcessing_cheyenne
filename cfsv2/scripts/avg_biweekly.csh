#!/bin/csh
# S. Baker, Feb 2018
# Average bi-weekly periods
# This file takes the year as argument so that this
# can be parallelized by year.
# Change the days for the different bi-weekly periods.
# Creates a file for each year.

set Year = $1  # 2009

module load nco
module load cdo

# ------ settings --------
set inputDir = /glade2/scratch2/sabaker/cfsv2/files/daily_ts
set outputDir = /glade2/scratch2/sabaker/cfsv2/files/biweekly_avg
set TmpDir = /glade2/scratch2/sabaker/cfsv2/files/tmp
set logDir = /glade2/scratch2/sabaker/cfsv2/files/log

# Temporal aggregation - first 14 days ( 0 start index )
# eg: 1_2, 0 to 13; 2_3, 7 to 20; 3_4, 14 to 27
set start_day = 14
set end_day = 27
set biwk_nm = 3_4


# ------------------------

# loop through variables and get data for year supplied
foreach Var (z500_f)
  # make the temp directory if it doesn't exist
  if ( ! -d $TmpDir/$Var/ ) then
    mkdir -p $TmpDir/$Var
  endif

  # create two week average (first 14 days)
  set i = 1
  set outFile = $outputDir/$Var.$Year.CFSv2_biwkAvg_$biwk_nm.nc

  foreach File ($inputDir/$Var/$Year/*)

    if ( $i == 1 ) then
      #create file the first time through
      ncks -O -d time,$start_day,$end_day $File $TmpDir/$Var/$Year.temp_2wk.nc
      cdo timselmean,14 $TmpDir/$Var/$Year.temp_2wk.nc $outFile
    else
      # append onto $Year_CFSv2_2wk_avg.nc
      ncks -O -d time,$start_day,$end_day $File $TmpDir/$Var/$Year.temp_2wk.nc
      cdo timselmean,14 $TmpDir/$Var/$Year.temp_2wk.nc $TmpDir/$Var/$Year.temp_2wk_avg.nc
      ncrcat -O $outFile $TmpDir/$Var/$Year.temp_2wk_avg.nc $outFile
    endif

    #edit history
    ncatted -O -a history,global,o,c,"Averaged first 14 days with /glade/u/home/sabaker/cfsv2/scripts/avg_1to14Day.csh" $outFile $outFile

    @ i ++
  end

  # add back in hru variable - hasnt been tested yet!
  #ncks -A -M -v hru $File $outFile

  #edit history
  #ncatted -O -a history,global,o,c,"Averaged first 14 days with /glade/u/home/sabaker/cfsv2/scripts/avg_1to14Day.csh" $outFile $outFile

end   # end of variable loop
