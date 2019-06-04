#!/bin/csh
# S. Baker, Jan 2018
# average files to daily timestep


set Year = $1  # 2009

# load modules
module load cdo
module load nco

# ------ settings --------
set TmpDir = /glade/scratch/sabaker/cfsv2/files/tmp
set logDir = /glade/scratch/sabaker/cfsv2/files/log
#set inputDir = /glade/p/ral/RHAP/s2s/cfsv2/XCONUS
set inputDir = /glade/scratch/sabaker/cfsv2/files/raw_nc
set outputDir = /glade/scratch/sabaker/cfsv2/files/daily_cut

# ------------------------

# loop through variables and get data for year supplied
foreach Var (ulwtoa_f)

  # make the output directory if it doesn't exist
  if ( ! -d $outputDir/$Var/$Year ) then
    mkdir -p $outputDir/$Var/$Year
  endif

  # average to daily timestep
  foreach File ($inputDir/$Var/$Year/*)
        cdo daymean $File $outputDir/$Var/$Year/$File:t:r.nc
  end

end   # end of variable loop
