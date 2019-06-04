#!/bin/bash
# S. Baker, Feb 2018
# Average Ensemble

Year=$1  # 2009

module load nco
module load cdo

# ------ settings --------
inputDir=/glade/scratch/sabaker/cfsv2/files/daily_cut
outputDir=/glade/scratch/sabaker/cfsv2/files/ensAvg
TmpDir=/glade/scratch/sabaker/cfsv2/files/tmp
logDir=/glade/scratch/sabaker/cfsv2/files/log
biwkDir=/glade/scratch/sabaker/cfsv2/files/biwk_ensAvg

## loop through biweekly periods
start_ls=(0 7 14)
end_ls=(13 20 27)
name_ls=(1_2 2_3 3_4)

# ------------------------

# loop through variables and get data for year supplied
Var=ulwtoa_f
endVal=f


for index in `seq 0 2`; 
do

    ## set start and end date
    start=${Year}0101
    end=${Year}1231
    
    echo "${name_ls[$index]}"

    # make the temp directory if it doesn't exist
    if [ ! -d "${outputDir}/${Var}/" ]
      then mkdir "${outputDir}/${Var}/"
    fi
    if [ ! -d "${outputDir}/${Var}/${Year}" ]
      then mkdir "${outputDir}/${Var}/${Year}"
    fi
    if [ ! -d "${biwkDir}/${Var}/" ]
      then mkdir "${biwkDir}/${Var}/"
    fi
    if [ ! -d "${biwkDir}/${Var}/${Year}" ]
      then mkdir "${biwkDir}/${Var}/${Year}"
    fi


    while ! [[ $start > $end ]]; do
      echo $start
    
      # average the ensemble 
      ncea -d time,"${start_ls[$index]}","${end_ls[$index]}" ${inputDir}/${Var}/${Year}/*${endVal}.01.${start}* ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc

      # average the biweekly period
      #cdo timselmean,14 ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc 
${biwkDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc

      start=$(date -d "$start + 1 day" +%Y%m%d)
    done

    # merge into one file and remove global history
    cdo mergetime ${biwkDir}/${Var}/${Year}/*."${name_ls[$index]}".nc ${biwkDir}/${Var}/cfsv2.${Year}."${name_ls[$index]}".${Var}.nc
    ncatted -O -a history,global,o,c,"Averaged first 14 days with /glade/u/home/sabaker/cfsv2/scripts/ensAvg_byDate.bash" ${biwkDir}/${Var}/cfsv2.${Year}."${name_ls[$index]}".${Var}.nc
done

## for combining and spearating into monthly fiels
# in cshell
#foreach wk (1_2 2_3 3_4)
#   cdo mergetime cfsv2.*.$wk.z500_f.nc cfsv2.$wk.z500_f.nc
#   foreach mon (1 2 3 4 5 6 7 8 9 10 11 12)
#    cdo selmon,$mon cfsv2.$wk.z500_f.nc cfsv2.$wk.z500_f.$mon.nc
#   end
# end
