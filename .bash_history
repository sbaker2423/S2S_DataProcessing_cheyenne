load ncl
ncl
cd
ls
csh
data = '/glade/scratch/sabaker/nldas/NLDAS_HUC4/tmp_2m/NLDAS_1999_2
011.nc'
more 2wk_avg.sh 
data = '/glade/scratch/sabaker/nldas/NLDAS_HUC4/tmp_2m/NLDAS_1999_2011.nc'
csh
data = '/glade/scratch/sabaker/nldas/NLDAS_HUC4/tmp_2m/NLDAS_1999_2011.nc'
csh
echo $SHELL
pico ensAverage_byDate.bash 
module load nco
Year=1999
module load nco
module load cdo
Var=z500
inputDir=/glade2/scratch2/sabaker/cfsv2/files/daily_ts
outputDir=/glade2/scratch2/sabaker/cfsv2/files/ensAvg
TmpDir=/glade2/scratch2/sabaker/cfsv2/files/tmp
logDir=/glade2/scratch2/sabaker/cfsv2/files/log
year=1999
start=${Year}0101
end=${Year}1231
if [ ! -d "$TmpDir/$Var/$Year" ];       then mkdir "$TmpDir/$Var/$Year";     fi
Var=z500_f
if [ ! -d "$TmpDir/$Var/$Year" ];       then mkdir "$TmpDir/$Var/$Year";     fi
if [ ! -d "$outputDir/$Var/$Year" ];       then mkdir "$output/$Var/$Year";     fi
# make the temp directory if it doesn't exist
echo $outputDir
echo $outputDir/$Var/
echo "$outputDir/$Var/"
if [ ! -d "${outputDir}/${Var}/" ];       then mkdir "${outputDir}/${Var}/";     fi
if [ ! -d "${outputDir}/${Var}/${Year}" ];       then mkdir "${outputDir}/${Var}/${Year}";     fi
echo $start
echo $inputDir/$Var/$Year/*$start*
echo $outputDir/$Var/$Year/$Var.$start.nc
ncea $inputDir/$Var/$Year/*$start* $outputDir/$Var/$Year/$Var.$start.nc
cnf ncea
nco ncea $inputDir/$Var/$Year/*$start* $outputDir/$Var/$Year/$Var.$start.nc
info nco
module list
module load nco
cnf module
cnf nco
cnf ncea
info module
import nco
info module
module av
echo $SHELL
bash
Var=z500_f
year=1999
exit
Year=1999
inputDir=/glade2/scratch2/sabaker/cfsv2/files/daily_ts
outputDir=/glade2/scratch2/sabaker/cfsv2/files/ensAvg
TmpDir=/glade2/scratch2/sabaker/cfsv2/files/tmp
logDir=/glade2/scratch2/sabaker/cfsv2/files/log
biwkDir=/glade2/scratch2/sabaker/cfsv2/files/biwk_ensAvg
start=${Year}0101
end=${Year}0103
## loop through biweekly periods
start_ls=(0 7 14)
end_ls=(13 20 27)
name_ls=(1_2 2_3 3_4)
echo "${name_ls[$index]}"
Var=z500_f
# make the temp directory if it doesn't exist
echo $start
ncea -d time,"${start_ls[$index]}","${end_ls[$index]}" ${inputDir}/${Var}/${Year}/*${start}* ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
start=$(date -d "$start + 1 day" +%Y%m%d)
echo $start
pico ensAverage_byDate.bash 
exit
start_ls=(0 7 14)
end_ls=(13 20 27)
name_ls=(1_2 2_3 3_4)
for index in ${!array[*]}; do  echo "${start_ls[$index]}"; echo "${end_ls[$index]}"; echo "${name_ls[$index]}"; done
start_ls=(0 7 14)
end_ls=(13 20 27)
name_ls=(1_2 2_3 3_4)
for index in ${!array[*]}; do  echo "${start_ls[$index]}"; echo "${end_ls[$index]}"; echo "${name_ls[$index]}"; done
echo "${start_ls[$index]}"
echo "${start_ls[1]}"
echo "${start_ls[2]}"
echo "${name_ls[$index]}"
pico ensAverage_byDate.bash 
exit
ensAverage_byDate.bash 
ensAverage_byDate.bash 1999
cd
cd cfsv2/files/files/biwk_ensAvg/
cd z500_f/
ls
module load ncview
exit
Year=1999
start_ls=(0 7 14)
end_ls=(13 20 27)
name_ls=(1_2 2_3 3_4)
Var=z500_f
for index in `seq 0 2`; do echo "${name_ls[$index]}"; done
bash
cd
cd cfsv2/files/files/biwk_ensAvg/z500_f/
module load ncview
cist
exit
for index in `seq 0 2`; do echo $index; done
cd
cd cfsv2/files/files/ensAvg/z500_f/
rm -rf *
cd ..
cd biwk_ensAvg/z500_f/
rm -rf *
cd
exit
inputDir=/glade2/scratch2/sabaker/cfsv2/files/daily_ts
outputDir=/glade2/scratch2/sabaker/cfsv2/files/ensAvg
TmpDir=/glade2/scratch2/sabaker/cfsv2/files/tmp
logDir=/glade2/scratch2/sabaker/cfsv2/files/log
biwkDir=/glade2/scratch2/sabaker/cfsv2/files/biwk_ensAvg
## loop through biweekly periods
start_ls=(0 7 14)
end_ls=(13 20 27)
name_ls=(1_2 2_3 3_4)
for index in `seq 0 2`; do echo "${name_ls[$index]}"; done
Year=2000
Var=z500_f
cdo mergetime ${biwkDir}/${Var}/${Year}/*."${name_ls[$index]}".nc ${biwkDir}/${Var}/cfsv2.${Year}."${name_ls[$index]}".${Var}.nc
index=0
cdo mergetime ${biwkDir}/${Var}/${Year}/*."${name_ls[$index]}".nc ${biwkDir}/${Var}/cfsv2.${Year}."${name_ls[$index]}".${Var}.nc
for index in `seq 0 2`; do     start=${Year}0101;     end=${Year}1231;      echo "${name_ls[$index]}";      if [ ! -d "${outputDir}/${Var}/" ];       then mkdir "${outputDir}/${Var}/";     fi;     if [ ! -d "${outputDir}/${Var}/${Year}" ];       then mkdir "${outputDir}/${Var}/${Year}";     fi;     if [ ! -d "${biwkDir}/${Var}/" ];       then mkdir "${biwkDir}/${Var}/";     fi;     if [ ! -d "${biwkDir}/${Var}/${Year}" ];       then mkdir "${biwkDir}/${Var}/${Year}";     fi;      while ! [[ $start > $end ]]; do       echo $start;        ncea -d time,"${start_ls[$index]}","${end_ls[$index]}" ${inputDir}/${Var}/${Year}/*${start}* ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc;        cdo timselmean,14 ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc ${biwkDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc;        start=$(date -d "$start + 1 day" +%Y%m%d);     done;      cdo mergetime ${biwkDir}/${Var}/${Year}/*."${name_ls[$index]}".nc ${biwkDir}/${Var}/cfsv2.${Year}."${name_ls[$index]}".${Var}.nc;  done
cd 
cd cfsv2/files/files/ensAvg/z500_f/
rm -rf 1999/
cd ../..
cd biwk_ensAvg/z500_f/
rm -rf 1999/
rm -rf cfsv2.1999.1_2.z500_f.nc 
cd
cd 
exit
more ensAverage_byDate.bash 
Year=2010
module load nco
module load cdo
# ------ settings --------
inputDir=/glade2/scratch2/sabaker/cfsv2/files/daily_ts
outputDir=/glade2/scratch2/sabaker/cfsv2/files/ensAvg
TmpDir=/glade2/scratch2/sabaker/cfsv2/files/tmp
logDir=/glade2/scratch2/sabaker/cfsv2/files/log
biwkDir=/glade2/scratch2/sabaker/cfsv2/files/biwk_ensAvg
## loop through biweekly periods
start_ls=(0 7 14)
end_ls=(13 20 27)
name_ls=(1_2 2_3 3_4)
Var=z500_f
for index in `seq 0 2`; do     start=${Year}0101;     end=${Year}1231;      echo "${name_ls[$index]}";      if [ ! -d "${outputDir}/${Var}/" ];       then mkdir "${outputDir}/${Var}/";     fi;     if [ ! -d "${outputDir}/${Var}/${Year}" ];       then mkdir "${outputDir}/${Var}/${Year}";     fi;     if [ ! -d "${biwkDir}/${Var}/" ];       then mkdir "${biwkDir}/${Var}/";     fi;     if [ ! -d "${biwkDir}/${Var}/${Year}" ];       then mkdir "${biwkDir}/${Var}/${Year}";     fi;      while ! [[ $start > $end ]]; do       echo $start;        ncea -d time,"${start_ls[$index]}","${end_ls[$index]}" ${inputDir}/${Var}/${Year}/*${start}* ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc;        cdo timselmean,14 ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc ${biwkDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc;        start=$(date -d "$start + 1 day" +%Y%m%d);     done;      cdo mergetime ${biwkDir}/${Var}/${Year}/*."${name_ls[$index]}".nc ${biwkDir}/${Var}/cfsv2.${Year}."${name_ls[$index]}".${Var}.nc;  done
exit 
Year=1999
module load nco
module load cdo
# ------ settings --------
inputDir=/glade2/scratch2/sabaker/cfsv2/files/daily_ts
outputDir=/glade2/scratch2/sabaker/cfsv2/files/ensAvg
TmpDir=/glade2/scratch2/sabaker/cfsv2/files/tmp
logDir=/glade2/scratch2/sabaker/cfsv2/files/log
biwkDir=/glade2/scratch2/sabaker/cfsv2/files/biwk_ensAvg
## loop through biweekly periods
start_ls=(0 7 14)
end_ls=(13 20 27)
name_ls=(1_2 2_3 3_4)
# ------------------------
# loop through variables and get data for year supplied
Var=z500_f
for index in `seq 0 2`; do     start=${Year}0101;     end=${Year}1231;      echo "${name_ls[$index]}";      if [ ! -d "${outputDir}/${Var}/" ];       then mkdir "${outputDir}/${Var}/";     fi;     if [ ! -d "${outputDir}/${Var}/${Year}" ];       then mkdir "${outputDir}/${Var}/${Year}";     fi;     if [ ! -d "${biwkDir}/${Var}/" ];       then mkdir "${biwkDir}/${Var}/";     fi;     if [ ! -d "${biwkDir}/${Var}/${Year}" ];       then mkdir "${biwkDir}/${Var}/${Year}";     fi;      while ! [[ $start > $end ]]; do       echo $start;        ncea -d time,"${start_ls[$index]}","${end_ls[$index]}" ${inputDir}/${Var}/${Year}/*${start}* ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc;        cdo timselmean,14 ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc ${biwkDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc;        start=$(date -d "$start + 1 day" +%Y%m%d);     done;      cdo mergetime ${biwkDir}/${Var}/${Year}/*."${name_ls[$index]}".nc ${biwkDir}/${Var}/cfsv2.${Year}."${name_ls[$index]}".${Var}.nc;  done
ensAverage_byDate.bash 2000
ensAverage_byDate.bash 2004
ensAverage_byDate.bash 2007
exit
echo $Year
more ensAverage_byDate.bash 
Year=2010
# ------ settings --------
inputDir=/glade2/scratch2/sabaker/cfsv2/files/daily_ts
outputDir=/glade2/scratch2/sabaker/cfsv2/files/ensAvg
TmpDir=/glade2/scratch2/sabaker/cfsv2/files/tmp
logDir=/glade2/scratch2/sabaker/cfsv2/files/log
biwkDir=/glade2/scratch2/sabaker/cfsv2/files/biwk_ensAvg
## loop through biweekly periods
start_ls=(0 7 14)
end_ls=(13 20 27)
name_ls=(1_2 2_3 3_4)
# ------------------------
# loop through variables and get data for year supplied
Var=z500_f
for index in `seq 0 2`; do     start=${Year}0101;     end=${Year}1231;      echo "${name_ls[$index]}";      if [ ! -d "${outputDir}/${Var}/" ];       then mkdir "${outputDir}/${Var}/";     fi;     if [ ! -d "${outputDir}/${Var}/${Year}" ];       then mkdir "${outputDir}/${Var}/${Year}";     fi;     if [ ! -d "${biwkDir}/${Var}/" ];       then mkdir "${biwkDir}/${Var}/";     fi;     if [ ! -d "${biwkDir}/${Var}/${Year}" ];       then mkdir "${biwkDir}/${Var}/${Year}";     fi;      while ! [[ $start > $end ]]; do       echo $start;        ncea -d time,"${start_ls[$index]}","${end_ls[$index]}" ${inputDir}/${Var}/${Year}/*${start}* ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc;        cdo timselmean,14 ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc ${biwkDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc;        start=$(date -d "$start + 1 day" +%Y%m%d);     done;      cdo mergetime ${biwkDir}/${Var}/${Year}/*."${name_ls[$index]}".nc ${biwkDir}/${Var}/cfsv2.${Year}."${name_ls[$index]}".${Var}.nc;  done
pico ensAverage_byDate.bash 
ensAverage_byDate.bash 2001
ensAverage_byDate.bash 2003
ensAverage_byDate.bash 2006
cd
cd cfsv2/files/files/biwk_ensAvg/
ls
cd z500_f/
ls
#!/bin/bash
# S. Baker, Feb 2018
# Average Ensemble
Year=$1  # 2009
module load nco
module load cdo
# ------ settings --------
inputDir=/glade2/scratch2/sabaker/cfsv2/files/daily_ts
outputDir=/glade2/scratch2/sabaker/cfsv2/files/ensAvg
TmpDir=/glade2/scratch2/sabaker/cfsv2/files/tmp
logDir=/glade2/scratch2/sabaker/cfsv2/files/log
biwkDir=/glade2/scratch2/sabaker/cfsv2/files/biwk_ensAvg
## loop through biweekly periods
start_ls=(0 7 14)
end_ls=(13 20 27)
name_ls=(1_2 2_3 3_4)
# ------------------------
# loop through variables and get data for year supplied
Var=z500_f
for index in `seq 0 2`; do     start=${Year}0101;     end=${Year}1231;      echo "${name_ls[$index]}";      if [ ! -d "${outputDir}/${Var}/" ];       then mkdir "${outputDir}/${Var}/";     fi;     if [ ! -d "${outputDir}/${Var}/${Year}" ];       then mkdir "${outputDir}/${Var}/${Year}";     fi;     if [ ! -d "${biwkDir}/${Var}/" ];       then mkdir "${biwkDir}/${Var}/";     fi;     if [ ! -d "${biwkDir}/${Var}/${Year}" ];       then mkdir "${biwkDir}/${Var}/${Year}";     fi;      while ! [[ $start > $end ]]; do       echo $start;        ncea -d time,"${start_ls[$index]}","${end_ls[$index]}" ${inputDir}/${Var}/${Year}/*${start}* ${outputDir}/; ${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc;        cdo timselmean,14 ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc ${biwkDir}/${Var}/${; Year}/${Var}.${start}."${name_ls[$index]}".nc;        start=$(date -d "$start + 1 day" +%Y%m%d);     done;      cdo mergetime ${biwkDir}/${Var}/${Year}/*."${name_ls[$index]}".nc ${biwkDir}/${Var}/cfsv2.${Year}."${name_ls
[$index]}".${Var}.nc;     ncatted -O -a history,global,o,c,"Averaged first 14 days with /glade/u/home/sabaker/cfsv2/scripts/ensAvg_byD
ate.bash" ${biwkDir}/${Var}/cfsv2.${Year}."${name_ls[$index]}".${Var}.nc; done
## for combining and spearating into monthly fiels
# in cshell
#foreach wk (1_2 2_3 3_4)
#   cdo mergetime cfsv2.*.$wk.z500_f.nc cfsv2.$wk.z500_f.nc
#   foreach mon (1 2 3 4 5 6 7 8 9 10 11 12)
#    cdo selmon,$mon cfsv2.$wk.z500_f.nc cfsv2.$wk.z500_f.$mon.nc
#   end
# end
module load nco
module load cdo
# ------ settings --------
inputDir=/glade2/scratch2/sabaker/cfsv2/files/daily_ts
outputDir=/glade2/scratch2/sabaker/cfsv2/files/ensAvg
TmpDir=/glade2/scratch2/sabaker/cfsv2/files/tmp
logDir=/glade2/scratch2/sabaker/cfsv2/files/log
biwkDir=/glade2/scratch2/sabaker/cfsv2/files/biwk_ensAvg
## loop through biweekly periods
start_ls=(0 7 14)
end_ls=(13 20 27)
name_ls=(1_2 2_3 3_4)
Var=z500_f
Year=2000
index=0
start=${Year}0101
end=${Year}1231
echo "${name_ls[$index]}"
echo $start
echo echo $start
"${start_ls[$index]}","${end_ls[$index]}"
echo "${start_ls[$index]}","${end_ls[$index]}"
echo ${inputDir}/${Var}/${Year}/*${start}*
${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
ncview ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
start=${Year}1230
ncea -d time,"${start_ls[$index]}","${end_ls[$index]}" ${inputDir}/${Var}/${Year}/*${start}* ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
ncview ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
ncview ${inputDir}/${Var}/${Year}/*${start}*
echo ${inputDir}/${Var}/${Year}/*${start}*
echo ${start}
${inputDir}/${Var}/${Year}/*f.01.*${start}*
echo ${inputDir}/${Var}/${Year}/*f.01.*${start}*
echo 
echo ${inputDir}/${Var}/${Year}/*f.01.${start}*
module load pico
exit
Year=1999
index=-
index=0
module load nco
module load cdo
# ------ settings --------
inputDir=/glade2/scratch2/sabaker/cfsv2/files/daily_ts
outputDir=/glade2/scratch2/sabaker/cfsv2/files/ensAvg
TmpDir=/glade2/scratch2/sabaker/cfsv2/files/tmp
logDir=/glade2/scratch2/sabaker/cfsv2/files/log
biwkDir=/glade2/scratch2/sabaker/cfsv2/files/biwk_ensAvg
## loop through biweekly periods
start_ls=(0 7 14)
end_ls=(13 20 27)
name_ls=(1_2 2_3 3_4)
pico ensAverage_byDate.bash 
exit
Year=1999
## loop through biweekly periods
start_ls=(0 7 14)
end_ls=(13 20 27)
name_ls=(1_2 2_3 3_4)
# ------------------------
# loop through variables and get data for year supplied
Var=ocnsst_h
endVal=h
inputDir=/glade2/scratch2/sabaker/cfsv2/files/daily_ts
outputDir=/glade2/scratch2/sabaker/cfsv2/files/ensAvg
TmpDir=/glade2/scratch2/sabaker/cfsv2/files/tmp
logDir=/glade2/scratch2/sabaker/cfsv2/files/log
biwkDir=/glade2/scratch2/sabaker/cfsv2/files/biwk_ensAvg
index=0
start=${Year}0505
echo "${name_ls[$index]}"
echo ${inputDir}/${Var}/${Year}/*${endVal}.01.${start}*
qsub ensAverage_byDate.lsf 
cd
exit
# ------ settings --------
inputDir=/glade2/scratch2/sabaker/cfsv2/files/daily_ts
outputDir=/glade2/scratch2/sabaker/cfsv2/files/ensAvg
TmpDir=/glade2/scratch2/sabaker/cfsv2/files/tmp
logDir=/glade2/scratch2/sabaker/cfsv2/files/log
biwkDir=/glade2/scratch2/sabaker/cfsv2/files/biwk_ensAvg
## loop through biweekly periods
start_ls=(0 7 14)
end_ls=(13 20 27)
name_ls=(1_2 2_3 3_4)
# ------------------------
# loop through variables and get data for year supplied
Var=ocnsst_h
endVal=h
Year=1999
start=${Year}0101
echo "${name_ls[$index]}"
echo $start
pico ensAverage_byDate.bash 
exit 
ls
nano ~/.bashrc
source ~/.bashrc
ls
nano ~/.bashrc
source ~/.bashrc
ls
exit
echo Year
echo $Year
Year=1999
echo $Year
module load nco
module load cdo
# ------ settings --------
inputDir=/glade/scratch/sabaker/cfsv2/files/daily_cut
outputDir=/glade/scratch/sabaker/cfsv2/files/ensAvg
TmpDir=/glade/scratch/sabaker/cfsv2/files/tmp
logDir=/glade/scratch/sabaker/cfsv2/files/log
biwkDir=/glade/scratch/sabaker/cfsv2/files/biwk_ensAvg
start_ls=(0 7 14)
end_ls=(13 20 27)
name_ls=(1_2 2_3 3_4)
index=0
echo "${name_ls[$index]}"
if [ ! -d "${outputDir}/${Var}/" ];       then mkdir "${outputDir}/${Var}/";     fi
echo $start
echo ${o utputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
echo ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
ncview /glade/scratch/sabaker/cfsv2/files/ensAvg//1999/.19990101.1_2.nc
ncea -d time,"${start_ls[$index]}","${end_ls[$index]}" ${inputDir}/${Var}/${Year}/*${endVal}.01.${start}* ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
echo ${inputDir}/${Var}/${Year}/*${endVal}.01.${start}*
echo ${inputDir}/${Var}${Year}/*${endVal}.01.${start}*
ncea -d time,"${start_ls[$index]}","${end_ls[$index]}" ${inputDir}/${Var}${Year}/*${endVal}.01.${start}* ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
ls /glade/scratch/sabaker/cfsv2/files/daily_cut/1999/*.01.19990101*
ls /glade/scratch/sabaker/cfsv2/files/daily_cut/1999/
echo $outputDir/$Var/$Year/$File:t:r.nc
ls \$inputDir 
ls $inputDir 
Var=q2m_f
ls 
q2m_f
ls ${inputDir}/${Var}/${Year}/*${endVal}.01.${start}*
ncview ${inputDir}/${Var}/${Year}/*${endVal}.01.${start}*
cdo timselmean,14 ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc ${biwkDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
ncea -d time,"${start_ls[$index]}","${end_ls[$index]}" ${inputDir}/${Var}/${Year}/*${endVal}.01.${start}* ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
ls ensAvg/
if [ ! -d "${outputDir}/${Var}/" ];       then mkdir "${outputDir}/${Var}/";     fi
ncea -d time,"${start_ls[$index]}","${end_ls[$index]}" ${inputDir}/${Var}/${Year}/*${endVal}.01.${start}* ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
ncview ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
cdo timselmean,14 ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc ${biwkDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
ncview ${biwkDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
index=1
echo "${name_ls[$index]}"
ncea -d time,"${start_ls[$index]}","${end_ls[$index]}" ${inputDir}/${Var}/${Year}/*${endVal}.01.${start}* ${outputDir}/${Va; r}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
ncea -d time,"${start_ls[$index]}","${end_ls[$index]}" ${inputDir}/${Var}/${Year}/*${endVal}.01.${start}* ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
cdo timselmean,14 ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc ${biwkDir}/${Var}/${Year}/${Var}.${st; art}."${name_ls[$index]}".nc
cdo timselmean,14 ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc ${biwkDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
ncview ${biwkDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
index=2
if [ ! -d "${outputDir}/${Var}/" ];       then mkdir "${outputDir}/${Var}/";     fi
ncea -d time,"${start_ls[$index]}","${end_ls[$index]}" ${inputDir}/${Var}/${Year}/*${endVal}.01.${start}* ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
cdo timselmean,14 ${outputDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc ${biwkDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
ncview ${biwkDir}/${Var}/${Year}/${Var}.${start}."${name_ls[$index]}".nc
exit
