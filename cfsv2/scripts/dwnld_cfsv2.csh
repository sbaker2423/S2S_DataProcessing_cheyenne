#!/bin/csh
# A. Wood, Nov 2016
# script to batch download the raw CFSv2 timeseries forecast files from NCEP
# takes the year as an argument so that this can be parallelized by year

set Year = $1  # 2009

# ------ settings --------
set OutDir = /glade/scratch/sabaker/cfsv2/files/rawdata
set TmpDir = /glade/scratch/sabaker/cfsv2/files/log   # for log/error files
set NCEPArchive = "https://nomads.ncdc.noaa.gov/data/cfsr-hpr-ts45"  # time series site
# ------------------------

# loop through variables and get data for year supplied
foreach Var (ulwtoa_f)
#foreach Var (q2m_f prmsl_f wnd850_f pwat_f z500_f)
  # others: (z500_f[gph500] q2m_f[SpecificHumid2m]
	# pressfc_f[surface pressure] prmsl_f[meanSLP]
	# pwat_f[preciptableWater] wnd850_f[wind850]) 
	# http://www.nco.ncep.noaa.gov/pmb/products/cfs/

  if ( ! -d $OutDir/$Var/$Year ) then
    mkdir -p $OutDir/$Var/$Year
  endif

 foreach Mon (01 02 03 04 05 06 07 08 09 10 11 12)

   # make file list in the monthly directory
   curl -s $NCEPArchive/$Var/$Year/$Year$Mon/ | awk -F\" '{print $4}' | grep grb2 > $TmpDir/flist.$Year
   foreach File (`cat $TmpDir/flist.$Year`)
     # check if file exists first
     if(! -e $File) then
       time wget --directory-prefix=$OutDir/$Var/$Year -nc $NCEPArchive/$Var/$Year/$Year$Mon/$File
     else
       echo skipping $File
     endif
   end
 end
end
