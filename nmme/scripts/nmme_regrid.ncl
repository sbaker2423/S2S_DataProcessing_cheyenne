;*************************************************************
; nmme_regird.ncl
;
; Concepts illustrated:
;   - Reading a variable off a file and updating its meta data
;   - Interpolating from a global GAUSSIAN grid to a lower resolution
;   - Creating a netCDF file
;
; Usage    : 'in_file=$File' 'var_in=$Var' 'out_file=$NCDir/$Var/$Year/$File:t:r.nc' nmme_regrid.ncl
; TEST
;	in_file = "/glade/p/work/flehner/nmme/hcst/tmp2m.020100.ensmean.NASA.fcst.198201-201612.1x1.nc"
;	in_file = "/glade/p/work/flehner/nmme/hcst/tmp2m.010100.ensmean.GFDL.fcst.198201-201612.1x1.nc"
;	var_in = "tmp2m"
;	out_file = "tmp2m.test.nc"
;
;*************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

begin
;*************************************************************
; read 
;*************************************************************
   f = addfile(in_file, "r") ;
   
  ; x = f->tmp_2m
  ; x@units = "K"
   
   if ( var_in .eq. "tmp2m" ) then
                x = f->tmp2m
                x@units = "K"
   else if ( var_in .eq. "prate" ) then
                x = f->prate
                x@units = "mm/d"
   else
                print( "... variable not found (eg. tmp2m_f or prate_f)")
                exit
        end if
        end if

  ;printVarSummary(x)
  ;printMinMax(x, True)
;*************************************************************
; perform conservative remapping to two different grid resolutions
;*************************************************************
   opt = False

   NLAT05x05  =  360      ; RES   = "0.5x.05"    
   MLON05x05  =  720                             
   LAT05x05   = latGlobeFo(NLAT05x05, "lat", "latitude" , "degrees_north")
   LON05x05   = lonGlobeFo(MLON05x05, "lon", "longitude", "degrees_east" )  ; 1.0E->359.0E
  ; x&lat = x&lat(::-1) ; reverse direction
   x = x(:,:,::-1,:) ; reverse variable direction
   
   X05x05     = area_conserve_remap_Wrap (x&lon, x&lat, x ,LON05x05, LAT05x05, opt)
  ; X05x05&lat = X05x05&lat(::-1) ; reverse direction

   ;printVarSummary(X05x05)
   printMinMax(X05x05, True)
;************************************************
; Create netCDF
; Create a 'time' dimension 
;************************************************
globeAtt              = 1
globeAtt@title        = "tmp_2m: T126 interpolated to a 0.5x0.5 degree grid"    
globeAtt@source_file  = in_file
globeAtt@creation_date= systemfunc ("date")
     
system ("/bin/rm -f " +  out_file)    ; remove any pre-exist file 
           
ncdf   = addfile(out_file,"c")     
fileattdef( ncdf, globeAtt )        ; create the global [file] attributes

; filedimdef(ncdf,"time",-1,True)     ; make time and UNLIMITED dimension      

   if ( var_in .eq. "tmp2m" ) then
                ncdf->tmp2m = X05x05
   else if ( var_in .eq. "prate" ) then
                ncdf->prate = X05x05
   else
                print( "... variable not found (eg. tmp2m_f or prate_f)")
                exit
        end if
        end if

;ncdf->tmp2m = X05x05

end
