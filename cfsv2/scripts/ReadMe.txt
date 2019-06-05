# ======= Process of downloading CFSv2 and averaging in time and space to a daily HUC4 scale forecast ======= #
## /glade/u/home/sabaker/cfsv2/scripts <-- all scripts here

**** Make sure to delete previous set of files so you dont run out of space! ****

### === Pull down data in gridded file format - in cheyenne
	# run script
	bsub < dwnld_cfsv2.lsf

	# Checking - dont think you need to do this manually...
		set NCEPArchive = "https://nomads.ncdc.noaa.gov/data/cfsr-hpr-ts45"
		set Var = prate_f
		set Year = 1999
		set TmpDir = /glade/scratch/sabaker/cfsv2
		foreach Mon (01 02 03 04 05 06 07 08 09 10 11 12)
		   # make file list in the monthly directory
		   curl -s $NCEPArchive/$Var/$Year/$Year$Mon/ | awk -F\" '{print $4}' | grep grb2 > 
$TmpDir/flist.$Year$Mon
		end


### === Convert to netcdf and regrid - in cheyenne
	# run script
	bsub < regrid_nc.lsf

		# IF above script doesnt finish....Regrid to 0.5 degree by 0.5 degree using ncl file
			/home/sabaker/cfsv2/scripts/regrid_nc.csh

### === Cut domain - keep these files - in cheyenne
	# run script
	bsub < cut_edit_cfsv2.lsf

## this is saved on hpss!
htar -xv -m -f CFSv2_XCONUS_raw.tar file_to_retrieve


### === Create correspondence (mapping) file to average to hucs - only needs to be done once === ###
# on hydro-c1 (i think) 
# same process for nldas and cfsv2

# Need netcdf to contain only one timestep and one variable on a long lat grid
ncks -v lon_110,lat_110,time,tair_avg -d time,2 NLDAS_1999.nc ~/s2s/nldas/19990102_tair.nc
# change variable name (nldas only ?) - variables have to match phython script (tmp_2m, ...)
ncrename -v tair_avg,tmp_2m NLDAS_1999.nc


# Convert netcdf to geoTIFF
gdalwarp -t_srs EPSG:4326  19990102_tair.nc 19990102_tair.tif
gdal_translate -a_srs EPSG:4326 19990102_tair.tif 19990102_tair2.tif (maybe should have just done 
this...)

# === in the sequence of commands below, the following are soft links (eg, ln -s /dir/):
Commands are executed from:  
/home/andywood/proj/overtheloop/scripts/ens_forc/grid2poly/mapping/poly2poly-serial

python grid2gpkg.py /home/sabaker/s2s/nldas/19990102_tair2.tif /home/sabaker/s2s/nldas/NLDAS_grid2.gpkg


# === now check this gpkg to see what the feature id should be:
> ogrinfo -al temp2m_grid.gpkg | more (or with NLDAS_grid.gpkg)
...
OGRFeature(temp2m_grid):1
  id (Integer) = 0              <--- it is "id"
  i_index (Integer) = 1
  j_index (Integer) = 1
  lon_cen (Real) = -174.75
  lat_cen (Real) = 74.75
  CELLVALUE (Real) = 273
  POLYGON ((-175 75 0,-174.5 75.0 0,-174.5 74.5 0,-175.0 74.5 0,-175 75 0))
  ...

# === now do the same to find a unique feature id for each target polygon
> ogrinfo -al CorrTbl/HUC4/NHDPlusv2_HUC4.gpkg | more
...
OGRFeature(NHDPlusv2_HUC4):1
  HUC4 (String) = 0101     <-- it is "HUC4", since HUC2 is same for all p'gons
  HUC2 (Integer) = 1
  POLYGON ((-68.455535407999946 48.09
  ...

# === now run the command to make the correspondence file (and cross fingers)
python mapping/poly2poly-serial/poly2poly.py CorrTbl/HUC4/NHDPlusv2_HUC4.gpkg HUC4 ./temp2m_grid.gpkg id 
GRID ./mapping.cfsv2_to_NHDPlusHUC4.nc


python poly2poly.py /home/sabaker/s2s/cfsv2/files/CorrespondenceTable/HUC4/NHDPlusv2_HUC4.gpkg HUC4 \
  /home/sabaker/s2s/nldas/NLDAS_grid2.gpkg id GRID 
/home/sabaker/s2s/nldas/mapping.NLDAS_to_NHDPlusHUC4_2.nc


(it worked!)

# === check the resulting file
ncdump  mapping.cfsv2_to_NHDPlusHUC4.nc | more

# I note that each polygon has a decent # of grid cell overlaps, so that's good:
... files
 overlaps = 92, 36, 39, 37, 16, 46, 22, 53, 31, 50, 31, 25, 37, 36, 40, 35,
    23, 25, 35, 19, 41, 18, 20, 23, 23, 18, 91, 99, 63, 63, 65, 68, 56, 19,
    27, 27, 13, 18, 33, 47, 22, 24, 65, 16, 50, 23, 36, 37, 55, 14, 35, 37,
    40, 31, 43, 18, 39, 47, 35, 31, 43, 26, 37, 16, 29, 18, 12, 14, 13, 26,
    16, 22, 7, 41, 52, 78, 34, 53, 36, 24, 19, 37, 43, 32, 30, 50, 47, 41,
    30, 22, 13, 26, 31, 18, 28, 19, 16, 16, 45, 34, 56, 31, 29, 30, 31, 27,
    30, 32, 43, 29, 16, 29, 22, 47, 28, 34, 37, 31, 30, 20, 21, 37, 15, 19,
    13, 36, 25, 32, 25, 25, 38, 29, 17, 45, 38, 39, 15, 26, 46, 51, 28, 28,
    16, 32, 34, 26, 37, 23, 89, 30, 28, 40, 14, 27, 32, 28, 23, 18, 34, 38,
    46, 31, 46, 38, 23, 28, 34, 33, 25, 40, 20, 39, 33, 43, 10, 15, 11, 24,
    28, 49, 41, 18, 20, 31, 32, 52, 26, 60, 48, 23, 25, 44, 22, 22, 29, 39,
    37, 22, 17, 25, 10, 39 ;

### === done with correspondence file creation - only needs to be done once === ###



### === Weighted average to HUC4 scale (back on cheyenne)
  # uses python scripts which are seperate for P and T
	bsub < run_poly2poly.map_ts.lsf


### === Average to daily
	bsub < daily_avg_HUC4.lsf
  # these files are saved on hpss (i think)

### === Two week average for NLDAS and CFSv2
  # Average 14 days of cfsv2 and merge to one file 
  # Change this script for each 14 day avg eg. 1-2wk,2-3wk,3-4wk
	bsub < avg_1to14Day.lsf

	## merge cfsv2 years and add hru variable back in - needs to be done mannually (i think...)
  # merge to one file
	cdo mergetime *avg.nc cfsv2_8to21day_tmp2m.nc
  # add hru var back in
	ncks -A -M -v hru 1999.CFSv2_2wk_avg.nc cfsv2_8to21day_tmp2m.nc
  # reduce length of history
	ncatted -a history_of_appended_files,global,o,c,"Averaged first 14 days with 
/glade/u/home/sabaker/cfsv2/scripts/avg_1to14Day.csh" cfsv2_8to21day_tmp2m.nc test.nc
  # change vars units
  ncatted -a units,prate,c,"kg/m^2/d"

## -- copy these to hydro-c1


### ===          SUMMARY             === ###
## download and process T and P
# download gridded data
	bsub < dwnld_cfsv2.lsf
# convert to netcdf and regrid
	bsub < convertNC_regrid.lsf #convert_grib2nc.CFSv2_hpr-ts45.lsf
# cut domain
	bsub < cut_edit_cfsv2.lsf
# weighted average to HUC4 scale
	bsub < run_poly2poly.map_ts.lsf
# average to daily
  bsub < daily_avg.lsf
# average 14 days of cfsv2 and merge to one file
	# Change this script for each 14 day avg eg. 1-2wk,2-3wk,3-4wk
	bsub < avg_biweekly.lsf

===================================================


### === Analysis scripts - hydro-c1 === ###
# /home/sabaker/s2s/analysis/scripts/cfsv2_analysis
# copied to cheyenne - cfsv2/scripts/cfsv2_analysis
## process bi-weekly average and calculate anomalies
	2wkAvg_calcAnom.R
## seasonal analysis - similar
	2wkAvg_seasonalAnalysis
## calc statistics
	2wkAvg_analysis.R



### === QM process - bias-correction === ###
# calculate historical values
	post_process_huc_QM.Rscr
# statistics 
	QM_process_plot_new.R
## create QM tables - needed for realtime processing
	/home/hydrofcst/s2s/scripts/QM_create_quantile_file.Rscr (or on hydro-c1)
## real-time scripts are here:
	/home/hydrofcst/s2s/scripts/

===================================================


##### =====  Download and process new CFSv2 Variable (cheyenne) ===== #####
## for PLSR post-processing work

# download
	sbatch < dwnld_cfsv2_caldera.lsf
# convert to netcdf and cut
	# convert and regrid
		qsub < convertNC_regrid.lsf
	# cut to XCONUS domain and rename variables
		qsub cut_XCONUS.lsf
  # --- OR convert and cut (no regrid)
		qsub < convertNC_cut.lsf
        -This is what to use!! 
# average each file to daily (from 6 hr) timestep
	qsub daily_avg.lsf
# average to biweekly for each day (ensAvg)
    #<- doesnt work. have to run separately on gy or ca (/cfsv2/scripts/)
    execca
    module load nco
    module load cdo
    ~/cfsv2/scripts/ensAverage_byDate.bash {YEAR}

# combine (doesnt work in script) -csh
    module load cdo
    module load nco
    set Var = ulwtoa_f
    set Dir = /glade/scratch/sabaker/cfsv2/files/biwk_ensAvg/$Var
    set outDir = /glade/scratch/sabaker/cfsv2/files/cfs_biwk_vars
    foreach Year (1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010)
     foreach wk (1_2 2_3 3_4)
      echo $Var $Year $wk
      cdo mergetime $Dir/$Year/*.$wk.nc $outDir/$Var.$Year.$wk.nc
      ncatted -O -a history,global,o,c,"Averaged first 14 days with 
/glade/u/home/sabaker/cfsv2/scripts/ensAvg_byDate.bash" $outDir/$Var.$Year.$wk.nc
     end
    end

# combine files for each variables/leads - csh
	# combined by midpoint of fcsted bi-wk period
	# fcst_date = time - 7 (k-1), where k = 0,1,2
 	module load cdo 
    set inDir = /glade/scratch/sabaker/cfsv2/files/cfs_biwk_vars
    set outDir = /glade/scratch/sabaker/cfsv2/files/processed_cfs_annual
    foreach Var (pressfc_f pwat_f)
     foreach wk (1_2 2_3 3_4)
      cdo mergetime $inDir/$Var.*.$wk.nc $outDir/cfsv2.$wk.$Var.nc
     end
    end
 
## copy to hydro-c1 for more processing
    cfsv2.*.$Var.nc 
sabaker@hydro-c1.rap.ucar.edu:/home/sabaker/s2s/analysis/files/cfsv2_files/cfs_annual_new/
