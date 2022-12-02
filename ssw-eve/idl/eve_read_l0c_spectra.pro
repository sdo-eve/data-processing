;docformat = 'rst'
;+
; :Description:
;    Integrate the given spectrum over the min/max wavelengths.
;
; :Params:
;    wave_min - the minimum wavelength (nm) to integrate over 
;    wave_max - the maximum wavelength (nm) to integrate over
;    irradiance_in  - The input spectra
;    wavelengths    - the associated wavelengths
;
;
; :Author: Brian Templeman
;-
FUNCTION eve_integrate_line_local, wave_min, wave_max, irradiance_in, wavelengths

    ; for integration, replace all fill values with NAN
    ; work with a copy of the data
    irradiance = irradiance_in
    
    ; replace fill values
    x=WHERE(irradiance LT 0.0, n_x)
    IF n_x GT 0 THEN irradiance[x] = !VALUES.F_NAN
    
    bin_min = WHERE( wavelengths GE wave_min -0.01 AND wavelengths LT wave_min + 0.01 )
    IF bin_min[0] EQ -1 THEN bin_min = WHERE( wavelengths GE wave_min -0.011 AND wavelengths LT wave_min + 0.01 )
    
    bin_max = WHERE( wavelengths GT wave_max -0.01 AND wavelengths LE wave_max + 0.01 )
    IF bin_max[0] EQ -1 THEN bin_max = WHERE( wavelengths GT wave_max -0.01 AND wavelengths LE wave_max + 0.011 )
    
    delta_lambda = 0.02
    RETURN, delta_lambda * TOTAL(irradiance[bin_min[0]:bin_max[0]], /DOUBLE, /NAN)
    
END

;+
; :Description:
;   This function defines lines and bands to extract from the spectra.
;   Required elements include:
;   low_wave  - the minimum wavelength (nm) of the band/line
;   high_wave - the maximum wavelength (nm) of the band/line
;   All other elements are optional and are used for reference.
;
; :Params:
;   None
;-
FUNCTION load_line_definitions
    ; 5 columns: wavelength (nm), Low_wave (nm), High_wave (nm), log(temp), Ion
    line_struct = {line_struct_a, wavelength:0.0, Low_wave:0.0, High_wave:0.0, log_temp:0.0, Ion:""}
    line_struct_arr = REPLICATE(line_struct, 30)
    line_struct_arr[0]  = {line_struct_a, 9.3926,  9.33,     9.43,  6.81,  "Fe XVIII"}
    line_struct_arr[1]  = {line_struct_a, 13.1240, 13.04,   13.17,  5.57,   "Fe VIII"}
    line_struct_arr[2]  = {line_struct_a, 13.2850, 13.23,   13.32,  6.97,     "Fe XX"}
    line_struct_arr[3]  = {line_struct_a, 17.1070, 17.02,   17.24,  5.81,     "Fe IX"}
    line_struct_arr[4]  = {line_struct_a, 17.7243, 17.63,   17.83,  5.99,      "Fe X"}
    line_struct_arr[5]  = {line_struct_a, 18.0407, 17.96,   18.15,  6.07,     "Fe XI"}
    line_struct_arr[6]  = {line_struct_a, 19.5120, 19.43,   19.61,  6.13,    "Fe XII"}
    line_struct_arr[7]  = {line_struct_a, 20.2044, 20.14,   20.32,  6.19,   "Fe XIII"}
    line_struct_arr[8]  = {line_struct_a, 21.1331, 21.07,   21.20,  6.27,    "Fe XIV"}
    line_struct_arr[9]  = {line_struct_a, 25.6317, 25.55,   25.68,  4.75,     "He II"}
    line_struct_arr[10] = {line_struct_a, 28.4150, 28.30,   28.50,  6.30,     "Fe XV"}
    line_struct_arr[11] = {line_struct_a, 30.3783, 30.25,   30.50,  4.70,     "He II"}
    line_struct_arr[12] = {line_struct_a, 33.5410, 33.47,   33.61,  6.43,    "Fe XVI"}
    line_struct_arr[13] = {line_struct_a, 36.0758, 36.02,   36.20,  6.43,    "Fe XVI"}
    line_struct_arr[14] = {line_struct_a, 36.8076, 36.71,   36.89,  5.99,     "Mg IX"}
    line_struct_arr[15] = {line_struct_a, 46.5221, 46.32,   46.74,  5.71,    "Ne VII"}
    line_struct_arr[16] = {line_struct_a, 49.9406, 49.84,   50.04,  6.29,    "Si XII"}
    line_struct_arr[17] = {line_struct_a, 52.5795, 52.42,   52.72,  4.92,     "O III"}
    line_struct_arr[18] = {line_struct_a, 55.437,  55.20,   55.64,  5.19,      "O IV"}
    line_struct_arr[19] = {line_struct_a, 58.4334, 58.22,   58.68,  4.16,      "He I"}
    line_struct_arr[20] = {line_struct_a, 59.9598, 59.84,   60.14,  4.92,     "O III"}
    line_struct_arr[21] = {line_struct_a, 62.4943, 62.28,   62.68,  6.05,      "Mg X"}
    line_struct_arr[22] = {line_struct_a, 62.9730, 62.74,   63.18,  5.37,       "O V"}
    line_struct_arr[23] = {line_struct_a, 71.8535, 71.72,   72.00,  4.48,      "O II"}
    line_struct_arr[24] = {line_struct_a, 77.0409, 76.90,   77.18,  5.81,   "Ne VIII"}
    line_struct_arr[25] = {line_struct_a, 79.0199, 78.90,   79.14,  5.19,      "O IV"}
    line_struct_arr[26] = {line_struct_a, 97.2537, 97.08,   97.44,  3.84,       "H I"}
    line_struct_arr[27] = {line_struct_a, 97.7030, 97.56,   97.86,  4.84,     "C III"}
    line_struct_arr[28] = {line_struct_a, 102.5720, 102.42, 102.70, 3.84,       "H I"}
    line_struct_arr[29] = {line_struct_a, 103.190,  103.10, 103.32, 5.47,      "O VI"}
    RETURN, line_struct_arr
END

;+
; :Description:
;  Reads an ASCII level 0C file and returns an array of structures.
;
; CALLING SEQUENCE:
;  data = eve_read_l0c_spectra( filename, /LINES )
;
; EXAMPLE:
;  IDL> data = eve_read_l0c_spectra( filename, /LINES )
;
; OUTPUTS:
;  status: 0 is good, not 0 is bad
;  return varable is the array of structures
;
; :Params:
;  filename: the filename as a string to be read
;
; :Keywords:
;  LINES - Returns a series of integrated lines for MEGSA and MEGSB
;  LATEST - The input file is a latest_EVS_l0c.txt file containg 15 minutes worth of data
;
; :History:
;  05/15/13 BDT Original file creation
;
;-
FUNCTION eve_read_l0c_spectra, filename, lines=lines, latest=latest

    IF NOT FILE_TEST( filename ) THEN BEGIN
        PRINT, "File: " + filename + " was nout found"
        RETURN, -1
    ENDIF
    
    the_file = filename
    
    ; If compressed then add the COMPRESS keyword
    extension = STRMID( the_file, 1, 2, /REVERSE_OFFSET )
    IF extension EQ 'gz' THEN BEGIN
        num_lines = FILE_LINES( the_file, /COMPRESS )
        OPENR, Unit, the_file, /GET_LUN, /COMPRESS
    ENDIF ELSE BEGIN
        num_lines = FILE_LINES( the_file )
        OPENR, Unit, the_file, /GET_LUN
    ENDELSE
    
    num_wavelengths = 5019  ; The total number of wavelengths in spectrum
    
    VarS = ";"
    counter = 0L
    WHILE STRMID(VarS,0,1) EQ ';' DO BEGIN
    READF, Unit, VarS, FORMAT='(%"%s")'
    counter ++
ENDWHILE

num_obs = num_lines - counter

; read in the Date
IF KEYWORD_SET( latest ) THEN BEGIN
    num_obs ++
    year  = INTARR( num_obs )
    doy   = INTARR( num_obs )
    month = INTARR( num_obs )
    dom   = INTARR( num_obs )
ENDIF ELSE BEGIN
    date_info = strsplit( varS, ' ', COUNT=num_var, /EXTRACT )
    month = FIX(date_info[2])
    dom   = FIX(date_info[3])
    year  = FIX(date_info[0])
    doy   = FIX(date_info[1])
ENDELSE
spectrum = FLTARR( num_obs, num_wavelengths )
hhmm = INTARR( num_obs )
minute_of_day = INTARR( num_obs )

FOR x = 0, num_obs - 1 DO BEGIN

    IF KEYWORD_SET( latest ) THEN BEGIN
        valuesS = strsplit( varS, ' ', COUNT=num_var, /EXTRACT )
        year[x] = FIX( valuesS[0] )
        doy[x] = FIX( valuesS[1] )
        hhmm[x] = FIX( valuesS[2] )
        yd_to_ymd, year[x] * 1000L + doy[x], the_year, the_month, the_dom
        month[x] = the_month
        dom[x]  = the_dom
        FOR i = 3, num_wavelengths + 2 DO BEGIN
            spectrum[x, i-3] = FLOAT( valuesS[i] )
        ENDFOR
        ; Read in the irradiance values
        IF x LT num_obs - 1 THEN READF, Unit, VarS, FORMAT='(%"%s")'
    ENDIF ELSE BEGIN
        ; Read in the irradiance values
        READF, Unit, VarS, FORMAT='(%"%s")'
        valuesS = strsplit( varS, ' ', COUNT=num_var, /EXTRACT )
        hhmm[x] = FIX( valuesS[0] )
        FOR i = 1, num_wavelengths DO BEGIN
            spectrum[x, i-1] = FLOAT( valuesS[i] )
        ENDFOR
    ENDELSE
    this_hour = FIX(hhmm[x] / 100)
    this_minute = hhmm[x] - ( this_hour * 100 )
    minute_of_day[x] = this_hour * 60 + this_minute
    
ENDFOR
CLOSE, Unit
FREE_LUN, Unit

;-----------------------------------------
; Sort array and remove any replicated dat
;-----------------------------------------
sorted_index = SORT( hhmm )
hhmm = hhmm[sorted_index]
spectra = spectrum[sorted_index, *]
minute_of_day = minute_of_day[sorted_index]
; If there are duplicate entries - remove them
uniq_index = uniq( hhmm )
IF N_ELEMENTS( uniq_index ) NE N_ELEMENTS( hhmm ) THEN BEGIN
    hhmm = hhmm[uniq_index]
    spectra = spectrum[uniq_index, *]
    minute_of_day = minute_of_day[uniq_index]
ENDIF

;----------------------------
; Set Spectrum wavelengths
;----------------------------
wave_spec = FLTARR(num_wavelengths)
counter = 0L
FOR i = 5.81D, 106.17D, 0.02D DO BEGIN
    wave_spec[counter ++] = i
ENDFOR

IF KEYWORD_SET( lines ) THEN BEGIN
    line_def = load_line_definitions()
    num_lines = N_ELEMENTS( line_def )
    line_irr = FLTARR( num_obs, num_lines )
    FOR x = 0, num_obs - 1 DO BEGIN
        FOR i = 0, num_lines - 1 DO BEGIN
            line_irr[x, i] = eve_integrate_line_local( line_def[i].low_wave, line_def[i].high_wave, REFORM( spectrum[x, * ] ), wave_spec )
        ENDFOR
    ENDFOR
    RETURN, {year:year, doy:doy, month:month, dom:dom, hhmm:hhmm, wavelength:wave_spec, spectra:spectrum, line_irradiance:line_irr, line_definitions:line_def}
ENDIF

RETURN, {year:year, doy:doy, month:month, dom:dom, hhmm:hhmm, minofday:minute_of_day, wavelength:wave_spec, spectra:spectrum }

END
