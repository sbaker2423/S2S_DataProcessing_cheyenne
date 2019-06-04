#!/bin/csh
# S. Baker, Mar 2018
# extract wind vectors into separate files
# input year

set Year = $1  # 2009

module load nco
module load cdo

## extract wind
set raw_Dir = /glade2/scratch2/sabaker/cfsv2/files/daily_cut/wnd850_f
set varU_Dir = /glade2/scratch2/sabaker/cfsv2/files/daily_cut/U_wnd850_f
set varV_Dir = /glade2/scratch2/sabaker/cfsv2/files/daily_cut/V_wnd850_f


# extract, rename variables (hydro-c1)
foreach File ($raw_Dir/$Year/*)

  #make the temp directory if it doesn't exist
  if ( ! -d $varU_Dir/$Year ) then
    mkdir -p $varU_Dir/$Year
  endif

  # make the temp directory if it doesn't exist
  if ( ! -d $varV_Dir/$Year ) then
    mkdir -p $varV_Dir/$Year
  endif


  # extract variable
  ncks -v longitude,latitude,time,time_bnds,VGRD_850mb $File $varV_Dir/$Year/v_$File:t:r.nc
  ncks -v longitude,latitude,time,time_bnds,UGRD_850mb $File $varU_Dir/$Year/u_$File:t:r.nc

end
