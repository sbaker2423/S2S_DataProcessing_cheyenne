#!/bin/csh
# Average first 14 days of observed data for each day
# 1999 through 2011 in one file

module load nco
module load cdo

set out_dir = /glade/scratch/sabaker/nldas/NLDAS_HUC4

# Temporal aggregation - 14 days avg (0 to 13, 7 to 20, 14 to 27)
set start_day = 14
set end_day = 27
set num_days = 14

# For precip & temp
foreach Var (prate tmp_2m)

	# for the first timestep to create initial netcdf
	ncks -O -d time,$start_day,$end_day $out_dir/$Var/NLDAS_1999_2011.nc $out_dir/$Var/temp_2wk.nc
	cdo timselmean,14 $out_dir/$Var/temp_2wk.nc $out_dir/$Var/NLDAS_2wk_avg.nc

	# create two week average (14 days) -
	#   change NOT -  while loop ($i <= 4746 - end_day, eg. 4733, 4726, 4719)
	#   change - i = 1, 8, 15
	set i = 15
	while ($i <= 4733)
		set j = `echo $i | awk '{print $i+13}' `
		ncks -O -d time,$i,$j $out_dir/$Var/NLDAS_1999_2011.nc $out_dir/$Var/temp_2wk.nc
		cdo timselmean,14 $out_dir/$Var/temp_2wk.nc $out_dir/$Var/temp_2wk_avg.nc
		ncrcat -O $out_dir/$Var/NLDAS_2wk_avg.nc $out_dir/$Var/temp_2wk_avg.nc $out_dir/$Var/NLDAS_2wk_avg.nc
		@ i ++
	end
	
	# add back hru variable - need to check that this works!
	ncks -A -M -v hru $out_dir/$Var/NLDAS_1999_2011.nc $out_dir/$Var/NLDAS_2wk_avg.nc	

end

# this could be done once and then fcst dates could be changed instead of running for each time period
