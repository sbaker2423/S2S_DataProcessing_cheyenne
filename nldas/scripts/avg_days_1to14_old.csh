#!/bin/csh
# Average first 14 days of observed data for each day
# 1999 through 2011 in one file

module load nco
module load cdo

set out_dir = /glade/scratch/sabaker/nldas/NLDAS_HUC4

# Temporal aggregation - first 14 days ( 0 to 13 )
set start_day = 0
set end_day = 13
set num_days = 14

# For precip & temp
foreach Var (prate tmp_2m)

	# for the first timestep to create initial netcdf
	ncks -O -d time,$start_day,$end_day $out_dir/$Var/NLDAS_1999_2011.nc $out_dir/$Var/temp_2wk.nc
	cdo timselmean,14 $out_dir/$Var/temp_2wk.nc $out_dir/$Var/NLDAS_2wk_avg.nc

	# create two week average (first 14 days)
	set i = 1
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
