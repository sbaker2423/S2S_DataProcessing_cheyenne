#!/bin/csh
# S. Baker, Jan 2017
# cut time to 30 days
# input a year as the argument.

set Year = $1  # 2009
module load nco

# ------ settings --------
set HucDir = /glade/scratch/sabaker/cfsv2/files/HUC4_XCONUS
set logDir = /glade/scratch/sabaker/cfsv2/files/log
set timeDir = /glade/scratch/sabaker/cfsv2/files/timeCut

set scripts = /glade/u/home/sabaker/cfsv2/scripts

# ------------------------

# loop through variables and get data for year supplied
foreach Var (prate_f tmp2m_f)

  # make the output directory if it doesn't exist
  if ( ! -d $timeDir/$Var/$Year ) then
    mkdir -p $timeDir/$Var/$Year
  endif

  # loop over each file in the raw year directory
  foreach File ($HucDir/$Var/$Year/*)
    
    # cut time
    ncea -d time,0,30 $File $timeDir/$Var/$Year/$File:t:r.nc
  end

end   # end of variable loop
