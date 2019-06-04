#!/bin/bash
# S. Baker, Feb 2018
# Average bi-weekly periods
# This file takes the year as argument so that this
# can be parallelized by year.
# Change the days for the different bi-weekly periods.
# Creates a file for each year.

Year=$1  # 2009

module load nco
module load cdo

# ------ settings --------
inputDir=/glade2/scratch2/sabaker/cfsv2/files/daily_ts
outputDir=/glade2/scratch2/sabaker/cfsv2/files/biweekly_avg
TmpDir=/glade2/scratch2/sabaker/cfsv2/files/tmp
logDir=/glade2/scratch2/sabaker/cfsv2/files/log

# Temporal aggregation - first 14 days ( 0 start index )
# eg: 1_2, 0 to 13; 2_3, 7 to 20; 3_4, 14 to 27
#set start_day = 0
#set end_day = 13
#set biwk_nm = 1_2

start_ls=(0 7 14)
end_ls=(13 20 27)
name_ls=(1_2 2_3 3_4)

# ------------------------

# loop through variables and get data for year supplied
for index in ${!array[*]}; do 
  for Var in (z500_f); do
    # make the temp directory if it doesn't exist
    if [ ! -d "$TmpDir/$Var/" ]
      then mkdir "$TmpDir/$Var/"
    fi 
 
    # create two week average (first 14 days)
    i=1
    outFile=${outputDir}/${Var}.${Year}.CFSv2_biwkAvg_${name_ls[$index]}.nc

    for File in  (${inputDir}/${Var}/${Year}/*); do

      # cut file to only include 14 days
      ncks -O -d time,${start_ls[$index]},${end_ls[$index]} $File ${outputDir}/${Var}.${Year}.temp_2wk.nc

      if [ $i == 1 ] ; then
        #create file the first time through
        cdo timselmean,14 ${outputDir}/${Var}.${Year}.temp_2wk.nc $outFile
      else
        # append onto $outFile
        cdo timselmean,14 ${outputDir}/${Var}.${Year}.temp_2wk.nc ${outputDir}/${Var}.${Year}.temp_2wk_avg.nc
        ncrcat -O $outFile ${outputDir}/${Var}.${Year}.temp_2wk_avg.nc $outFile
      fi

      @ i ++
    done

    # add back in hru variable - hasnt been tested yet!
    #ncks -A -M -v hru $File $outFile

    #edit history
    ncatted -a history,global,o,c,"Averaged first 14 days with /glade/u/home/sabaker/cfsv2/scripts/avg_1to14Day.csh" $outFile $outFile
  done
done   # end of variable loop
