# ======= Process NMME ======= #
c
## Regrid, rename, and cut to XCONUS domain
  files here /glade/p/work/flehner/nmme/hcst/
  regridregrid_name_cut.csh

### === Create correspondence (mapping) file to average to hucs

# Need netcdf to contain only one timestep and one variable on a long lat grid
ncks -v longitude,latitude,fcst_time,issue_time,tmp2m -d t,2 -d tn,2 tmp2m.120100.ensmean.NASA.fcst.198201-201612.1x1.nc nmme_grid.nc

# Convert netcdf to geoTIFF
module unload netcdf
module load gdal
** dimentions and variables must be named lon/lat (ncrename -v longitude,lon -v latitude,lat nmme_grid2.nc nmme_grid3.nc) **
gdalwarp -t_srs EPSG:4326 nmme_grid.nc nmme_grid.tif
gdal_translate -a_srs EPSG:4326 nmme_grid.tif nmme_grid2.tif 

# === in the sequence of commands below, the following are soft links (eg, ln -s /dir/):
Commands are executed from hydro-c1:  /home/andywood/proj/overtheloop/scripts/ens_forc/grid2poly/mapping/poly2poly-serial

python grid2gpkg.py ~/s2s/nmme/nmme_grid2.tif ~/s2s/nmme/nmme_grid.gpkg


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
> ogrinfo -al /home/sabaker/s2s/cfsv2/files/CorrespondenceTable/HUC4/NHDPlusv2_HUC4.gpkg | more
...
OGRFeature(NHDPlusv2_HUC4):1
  HUC4 (String) = 0101     <-- it is "HUC4", since HUC2 is same for all p'gons
  HUC2 (Integer) = 1
  POLYGON ((-68.455535407999946 48.09
  ...

# === now run the command to make the correspondence file (and cross fingers)
ln -s /home/sabaker/s2s/cfsv2/files/CorrespondenceTable/ CorrTbl (make link)
python map_andy/poly2poly.py CorrTbl/HUC4/NHDPlusv2_HUC4.gpkg HUC4 ./nmme_grid.gpkg id GRID ./mapping.nmme_to_NHDPlusHUC4.nc

-- or (?) --
python poly2poly.py /home/sabaker/s2s/cfsv2/files/CorrespondenceTable/HUC4/NHDPlusv2_HUC4.gpkg HUC4 \
  /home/sabaker/s2s/nldas/NLDAS_grid2.gpkg id GRID /home/sabaker/s2s/nldas/mapping.NLDAS_to_NHDPlusHUC4_2.nc

(it worked!)

# === check the resulting file
ncdump  mapping.nmme_to_NHDPlusHUC4.nc | more

# I note that each polygon has a decent # of grid cell overlaps, so that's good:
...
 overlaps = 92, 36, 39, 37, 16, 46, 22, 53, 31, 50, 31, 25, 37, 36, 40, 35,
    23, 25, 35, 19, 41, 18, 20, 23, 23, 18, 91, 99, 63, 63, 65, 68, 56, 19,


### HUC average
bsub < run_poly2poly.map_ts.lsf


## zip and copy to hydro-c1
zip -r huc_avg *
scp huc_avg.zip sabaker@hydro-c1.rap.ucar.edu:/home/sabaker/s2s/nmme/files/

## unzip on hydro-c1
unzip huc_avg.zip

## now process in r


####### ======== Process forecasts - Realtime ======== #######

##### ------ download - dwnld_nmme_fcsts.csh

# ------ settings --------
set OutDir = /glade2/scratch2/sabaker/nmme/fcst/rawData
set TmpDir = /glade2/scratch2/sabaker/nmme/fcst/tmp  
set NMMEarchive = "ftp://ftp.cpc.ncep.noaa.gov/NMME/realtime_anom/ENSMEAN" 

module load ncl

## download grb file
foreach Year (2017)
  foreach Var (tmp2m prate)
    foreach Mon (01 02 03 04 05 06 07 08)
      foreach model (CFSv2 CMC1 CMC2 GFDL GFDL_FLOR NASA NCAR_CCMS4)
        wget --directory-prefix=$TmpDir/ -nc $NMMEarchive/$Year$Mon'0800'/$Var.$Year$Mon'0800'.$model.ensmean.fcst.1x1.grb
      end
    end
  end
end

## convert to netcdf
foreach File ($TmpDir/*)
  ncl_convert2nc $File -o $OutDir/
end


##### ------ process - process_nmme_fcst.csh

#!/bin/csh
# S. Baker, Aug 2017
# script to regrid NMME timeseries forecast
# file to 0.5x0.5 degree; rename dimensions
# and variables; cut to CONUS domain

# load modules
module load nco
module load cdo
module load python
module load netcdf4python
module load numpy

# ------ settings --------
set rawDir = /glade2/scratch2/sabaker/nmme/fcst/rawData
set gridDir = /glade2/scratch2/sabaker/nmme/fcst/regrid
set TmpDir = /glade2/scratch2/sabaker/nmme/fcst/tmp1
set renameDir = /glade2/scratch2/sabaker/nmme/fcst/rename
set cutDir = /glade2/scratch2/sabaker/nmme/fcst/nc_CONUS
set HucDir = /glade2/scratch2/sabaker/nmme/fcst/HUC_avg
set scripts = /glade/u/home/sabaker/nmme/scripts


# loop through variables and get data for year supplied
foreach Var (tmp2m prate)

  # rename GFDL and GFDL_FLOR files to regrid with cdo
  foreach File ($rawDir/$Var.*1x1.nc) 
        set output = $gridDir/$File:t:r.nc
        ncrename -d lat_3,lat -d lon_3,lon -d forecast_time0,time -v lat_3,lat -v lon_3,lon -v forecast_time0,time $File $TmpDir/$File:t:r.nc
        cdo remapbil,r720x360 $TmpDir/$File:t:r.nc $output
  end

  # rename files and cut
  foreach File ($gridDir/$Var.*1x1.nc)
        set nm_out = $renameDir/$File:t:r.nc
        set output = $cutDir/$File:t:r.nc

        # rename variables and dimensions - need to check this works
        if ($Var == tmp2m) then
          ncrename -d time,t -v TMP_3_HTGL_ave1m,tmp2m -v time,fcst_time -v lat,latitude -v lon,longitude $File $nm_out
        else
          ncrename -d time,t -v PRATE_3_SFC_ave1m,prate -v time,fcst_time -v lat,latitude -v lon,longitude $File $nm_out
        endif

        # CONUS domain - 5,75N 185,305E
        ncea -d lat,190,329 -d lon,370,609 $nm_out $output
  end

  # loop over each file in the raw year directory
  foreach File ($cutDir/$Var.*1x1.nc)
    python $scripts/poly2poly.map_timeseries_$Var'_fcst.py' $scripts/mapping.nmme_to_NHDPlusHUC4.nc $File $HucDir/$File:t:r.nc
  end

end



