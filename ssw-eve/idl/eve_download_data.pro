; docformat = 'rst' 

;+ 
; :Author: 
;   Don Woodraska
; 
; :Copyright: 
;   Copyright 2015 The Regents of the University of Colorado. 
;   All rights reserved. This software was developed at the 
;   University of Colorado's Laboratory for Atmospheric and 
;   Space Physics, SDO EVE Science Processing Operations Center.
; 
; :Version: 
;   $Id: eve_download_data.pro 66720 2015-04-01 17:52:40Z dlwoodra $
; 
;- 

;+
;  This function downloads all SDO EVE data products of a specified
;  type for the specified 7-digit year and day of year. The default
;  data product type is the EVE Level 2 Spectrum (/evS_L2). Other 
;  options include /evL_L2, /esp_L1, /level3, /high_res_merged,
;  /angstrom_merged, and /nanometer_merged.
;
;  All EVE data products from level 1, 2, and 3 are calibrated.
;
;  This software requires IDL 6.4 or greater.
;
; :Params: 
;   yyyydoy: in, required, type=long or lonarr
;     7-digit year and day of year (2010365)
;
; :Keywords:
;    evS_L2: in, optional, type=boolean
;      Set this keyword to download FITS files matching EVS_L2_*fit.gz
;      These are the routine level 2 spectra products. They contain high
;      resolution, high cadence spectra files. 
;      This is the DEFAULT option if no other is specified.
;    evL_L2: in, optional, type=boolean
;      Set this keyword to download FITS files matching EVL_L2_*fit.gz
;      These are the routine level 2 extracted lines, integrated
;      bands, and broadband diodes integrated to match the 10-second
;      spectrum cadence. These data have high cadence lines, bands,
;      and  diodes. 
;    esp_L1: in, optional, type=boolean
;      Set this keyword to download FITS files matching esp_L1_* These
;      are the routine level 1 ESP products at native 4 Hz integration
;      rates. These are highest cadence ESP broadband diode data
;      files. 
;    level3: in, optional, type=boolean
;      Set this keyword to download FITS files matching EVE_L3_*
;      These are the routine level 3 data products and contain the
;      daily averages of EVE measurements. These daily data files
;      contain the high resolution spectrum plus daily averages of all
;      the lines, bands, and diodes from the level 2 products.
;    high_res_merged: in, optional, type=boolean
;      Set this keyword to download the current mission merged SAV file
;      This contains the highest resolution daily average spectra from
;      level 3 merged into one mission-length file. FITS and NetCDF
;      versions are also available from the web site.
;    angstrom_merged: in, optional, type=boolean
;      Set this keyword to download the current mission merged SAV file
;      These are daily averages from the high_res_merged integrated
;      onto 1 angstrom bins. FITS and NetCDF versions are also
;      available from the web site.
;    nanometer_merged: in, optional, type=boolean
;      Set this keyword to download the current mission merged SAV file
;      These are daily averages from the angstrom_merged integrated
;      onto 1 nanometer bins. FITS and NetCDF versions are also
;      available from the web site. 
;    output_directory: in, optional, type=string
;      Provide a string indicating where the data files will be
;      placed on your computer. If the direcory does not exist, a
;      prompt will be issued to create the directory.
;
; :Examples:
;    Normal usage would be to define an array of 7-digit YYYYDOY for
;    the individual dates to request.::
;      IDL> ydlist = long(2015000) + [1, 2, 3]
;      IDL> status = eve_download_data( ydlist, /evs_L2 )
; 
;    Normally, you would want to place the data files into a directory
;    for later analysis.::
;      IDL> mydir = './data'
;      IDL> status = eve_download_data( 2015001, /evs_L2, output_directory=mydir )
;   
;    Any routine EVE data products can be downloaded for the list of
;    days provided.
;    To download the level 2 lines/bands/diodes files::
;      IDL> status = eve_download_data( yyyydoy, /evl_L2 )
;
;    To download the level 3 daily average files (one per day)::
;      IDL> status = eve_download_data( yyyydoy, /level3 )
; 
;    To download the ESP level 1 4 Hz diode measurements::
;      IDL> status = eve_download_data( yyyydoy, /esp_L1)
;
;    To download the high resolution mission merged IDL SAV file::
;      IDL> status = eve_download_data( /high_res_merged )
;
;    To download the 1 angstrom integrated mission merged IDL SAV file::
;      IDL> status = eve_download_data( /angstrom_merged )
;
;    To download the 1 nm integrated mission merged IDL SAV file::
;      IDL> status = eve_download_data( /nanometer_merged )
;
;    Note that only one product type can be downloaded with one call
;    to this function. Specifying multiple product types will only
;    download one, the last one that is checked. Consider them
;    mutually exclusive. 
;
;-
function eve_download_data, yyyydoy, $
                                evS_L2=evS_L2, $
                                evL_L2=evL_L2, $
                                esp_L1=esp_L1, $
                                level3=level3, $
                                high_res_merged=high_res_merged, $
                                angstrom_merged=angstrom_merged, $
                                nanometer_merged=nanometer_merged, $
                                output_directory=output_directory

if float(!version.release) lt 6.4 then begin
   print,'ERROR: eve_download_data - required IDL version 6.4 or greater'
   print,'This version of IDL is '+!version.release
   return,-1
endif

produrl = 'http://lasp.colorado.edu/eve/data_access/evewebdataproducts/'

; if output_directory was not passed, set it to the current directory
if size(output_directory,/type) eq 0 then begin
   ; the only way to get the current directory is to try to change it
   ;cd,current=output_directory, '.'+path_sep()
   level = 'level3'
   if size(esp_L1, /type) NE 0 THEN level = 'level1'
   if size(evS_L2, /type) NE 0 THEN level = 'level2'
   if size(evL_L2, /type) NE 0 THEN level = 'level2'
   year = FIX( yyyydoy / 1000L )
   
   output_directory = string(format='(%"%s%1s%s%1s%04d%1s")',getenv('EVE_DATA'), path_sep(), level, path_sep(), year, path_sep())
   PRINT, "Saving data to: " + output_directory
   dirInfo = FILE_INFO( output_directory )
   IF dirInfo.EXISTS EQ 0 THEN FILE_MKDIR, output_directory
endif

; append a path separator if needed
if strmid(output_directory,strlen(output_directory)-1,1) ne path_sep() then $
   output_directory += path_sep()

; create local directory if it does not exist
if file_test(output_directory,/directory,/write) eq 0 then begin
   result = dialog_message('The output directory does not exist. Create directory?',/question)
   if strmatch(result,'Yes') eq 0 then begin
      print,'ERROR: eve_download_data - User aborted. Output directory not created.'
      return,-1
   endif
   file_mkdir, output_directory
endif

if size(yyyydoy,/type) eq 0 and $
   (keyword_set(high_res_merged) eq 0 and $
    keyword_set(angstrom_merged) eq 0 and $
    keyword_set(nanometer_merged) eq 0) then begin
   print,'ERROR: eve_download_data - no date specified. This function requires a yyyydoy formed date, or an array of yyyydoy dates'
   return,-1
endif

if keyword_set(evS_L2) eq 0 and $
   keyword_set(evL_L2) eq 0 and $
   keyword_set(esp_l1) eq 0 and $
   keyword_set(level3) eq 0 and $
   keyword_set(high_res_merged) eq 0 and $
   keyword_set(angstrom_merged) eq 0 and $
   keyword_set(nanometer_merged) eq 0 then begin
   print,'WARNING: eve_download_data - no product specified, assuming level 2 spectrum products are needed'
   evs_l2=1 ; define a default selected option
endif

;
; loop over each yyyydoy element
;
for i=0L,n_elements(yyyydoy)-1 do begin

   if yyyydoy[i] lt 2010120 then begin
      if keyword_set(high_res_merged) eq 0 and $
         keyword_set(angstrom_merged) eq 0 and $
         keyword_set(nanometer_merged) eq 0 then begin
         print,'ERROR: eve_download_data - received yyyydoy < 2010120'
         print,'EVE normal operations began 2010120, setting to 2010120'
      endif
      ; always prevent invalid dates
      ; do it quietly for merged files since it does not matter for those
      yyyydoy[i]=2010120L
   endif

   stryyyy    = string(yyyydoy[i]  /  1000L, form='(i4.4)') ; 2010-...
   strdoy     = string(yyyydoy[i] mod 1000L, form='(i3.3)') ; 001-366
   stryyyydoy = stryyyy + strdoy

   if keyword_set(evS_L2) then begin
      urlbase = produrl + 'level2/'  ; yyyy + ddd + '/EVS_L2_yyyydoy_hh_vvv_rr.fit.gz'
      urlbase = urlbase + stryyyy + '/' + strdoy + '/'
      filepattmatch = '*EVS_L2_' + stryyyydoy + '*.fit.gz*'
      fileregexmatch = 'EVS_L2_' + stryyyydoy + '_[0-2][0-9]_[0-9]{3}_[0-9]{2}\.fit\.gz'
   endif
   if keyword_set(evL_L2) then begin
      urlbase = produrl + 'level2/' ; yyyy + ddd + '/EVL_L2_yyyydoy_hh_vvv_rr.fit.gz'
      urlbase = urlbase + stryyyy + '/' + strdoy + '/'
      filepattmatch = '*EVL_L2_' + stryyyydoy + '*.fit.gz*'
      fileregexmatch = 'EVL_L2_' + stryyyydoy + '_[0-2][0-9]_[0-9]{3}_[0-9]{2}\.fit\.gz'
   endif
   if keyword_set(esp_L1) then begin
      urlbase = produrl + 'level1/esp/' ; yyyy + '/esp_L1_yyyydoy_vvv.fit'
      urlbase = urlbase + stryyyy + '/'
      filepattmatch = '*esp_L1_' + stryyyydoy + '*.fit*'
      fileregexmatch = 'esp_L1_' + stryyyydoy + '_[0-9]{3}\.fit'
   endif
   if keyword_set(level3) then begin
      urlbase = produrl + 'level3/' ; yyyy +'/EVE_L3_yyyydoy_vvv.fit'
      urlbase = urlbase + stryyyy + '/'
      filepattmatch = '*EVE_L3_' + stryyyydoy + '*.fit*'
      fileregexmatch = 'EVE_L3_' + stryyyydoy + '_[0-9]{3}_[0-9]{2}\.fit'
   endif
   if keyword_set(high_res_merged) then begin
      urlbase = produrl + 'merged/' ; '/EVE_L3_merged_yyyydoy_vvv.sav'
      filepattmatch = '*EVE_L3_merged_???????_???.sav*'
      fileregexmatch = 'EVE_L3_merged_[0-9]{7}_[0-9]{3}\.sav'
   endif
   if keyword_set(angstrom_merged) then begin
      urlbase = produrl + 'merged/' ; '/EVE_L3_merged_yyyydoy_vvv.sav'
      filepattmatch = '*EVE_L3_merged_1a_???????_???.sav*'
      fileregexmatch = 'EVE_L3_merged_1a_[0-9]{7}_[0-9]{3}\.sav'
   endif
   if keyword_set(nanometer_merged) then begin
      urlbase = produrl + 'merged/' ; '/EVE_L3_merged_yyyydoy_vvv.sav'
      filepattmatch = '*EVE_L3_merged_1nm_???????_???.sav*'
      fileregexmatch = 'EVE_L3_merged_1nm_[0-9]{7}_[0-9]{3}\.sav'
   endif

   ;
   ; Gracefully retry if any error occurs with catch
   ;
   CATCH, errorStatus
   if (errorStatus ne 0) then begin
      ;CATCH,/CANCEL ; disable future error handling

      ; get whatever info you can
      oUrl->GetProperty, RESPONSE_CODE=response, RESPONSE_HEADER=rspHdr

      ; display the error info to the user
      ; note that 200 means OK connection, any 2xx code is success
      ; 4xx codes mean there is a client error of some kind
      ; 5xx codes mean there is a server error
      print,''
      print,'ERROR: eve_download_data - code=',strtrim(response,2)
      print,'ERROR: eve_download_data - rspHdr=',rspHdr

      ; cleanup
      OBJ_DESTROY, oUrl

      ; ask to try again
      result = dialog_message('The EVE file download did not work. Try again?',/question)
      if strmatch(result,'Yes') eq 0 then begin
         print,'ERROR: eve_download_data -aborted by user request'
         return,-1
      endif
   endif

   ;
   ; try to connect to URL to get latest merged file
   ;
   oUrl = OBJ_NEW('IDLnetUrl')

   ; try to get directory listing
   thehtml = oUrl->Get(url=urlbase,/string_array)

   ; parse the html for the latest save file
   htmlline = where(strmatch(thehtml,filepattmatch) eq 1, n_files )
   if n_files eq 0 then begin
      print,'ERROR: eve_download_data - no product file found on EVE web site'
      stop
   endif

   ;
   ; extract the returned filename string buried in the html line
   ;
   for j=0L,n_files-1 do begin
      thefile   = stregex( thehtml[htmlline[j]], fileregexmatch, /extract )
      url       = urlbase + thefile
      localfile = output_directory+thefile

      ; attempt to download one file
      print,'Downloading EVE data product file -> ',url
      result = oUrl->Get( URL=url, file=localfile )

   endfor

   ; cleanup
   oUrl->CloseConnections
   OBJ_DESTROY, oUrl

endfor

;
;  return
;
return, 1
end
