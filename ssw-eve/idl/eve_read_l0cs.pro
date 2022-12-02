;+
; NAME:
;  read_l0cs
;
; PURPOSE:
;  reads an ASCII level 0CS file and returns an array of structures
;
; CATEGORY:
; L0CS
;
; CALLING SEQUENCE:
;  data = eve_read_l0cs( filename, status )
;
; INPUTS:
;  filename: the filename as a string to be read
;
; OPTIONAL INPUTS:
;  none
;
; KEYWORD PARAMETERS:
;  None
;
; OUTPUTS:
;  status: 0 is good, not 0 is bad
;  return varable is the array of structures
;
; OPTIONAL OUTPUTS:
;  none
;
; COMMON BLOCKS:
;  none
;
; SIDE EFFECTS:
;  none
;
; RESTRICTIONS:
;
; PROCEDURE:
;
;
; EXAMPLE:
;  IDL> data = eve_read_l0cs( filename, status )
;
; MODIFICATION HISTORY:
;  02/19/10 DLW Original file creation
;  08/26/10 DLW Added MP_dark back in.
;  10/07/22 DLW Modified to parse using whitespace, added p_xrs_cool
;  and p_oldxrs
;
;-
function eve_read_l0cs, filename, status

status=0

if file_test(filename) eq 0 then begin
   print,'file not found : '+filename
   status = -1
   return,-1
endif

;
; define output record format
;
data_rec = { yyyydoy:0L, mmdd:0L, hhmm:0L, minuteofday:0L, $
             p_xrslong:0., p_xrsshort:0., p_sem304:0., $
             esp_0_7:0., esp_17:0., esp_25:0., esp_30:0., esp_36:0., $
             esp_dark:0., mp_lya:0., mp_dark:0., $
             esp_q0:0., esp_q1:0., esp_q2:0., esp_q3:0., $
             esp_cm_lat:0., esp_cm_lon:0., p_xrs_cool:0., p_oldxrs:0. }

; perform all I/O
;
; open the file for reading
;
s=';'
openr, lun, filename, /GET_LUN
cnt=0L
while strmid(s,0,1) eq ';' do begin
   readf,lun,s
   cnt++
endwhile
; now read/retain the date string
datestr = s

n_minutes=file_lines(filename) - cnt
; read each line
sarr = strarr(n_minutes)        ; one string for each minute
for i=0,n_elements(sarr)-1 do begin
   readf,lun,s
   sarr[i] = s
endfor
close,lun
free_lun,lun
; I/O complete

; create return array of structures
data = replicate( data_rec, n_minutes )

; extract date information
datestrarr = strsplit(datestr,' ',/extract)

; assign date to all structures
data.yyyydoy = long(datestrarr[0])*1000L + long(datestrarr[1])

month = long(datestrarr[2])
dayofmonth = long(datestrarr[3])
data.mmdd = month*100L + dayofmonth

; parse data lines into variables
for lineindex=0,n_elements(sarr)-1 do begin
   ; split line into an array of strings
   thisarr=strsplit(sarr[lineindex],' ',/extract)
   data[lineindex].hhmm = long(thisarr[0])

   ; calculate minute of day
   longhhmm = long(thisarr[0])
   minuteofday = longhhmm mod 100L           ; minutes in hour
   minuteofday += 60L * long(longhhmm / 100L) ; minute in hour portion (int div)
   data[lineindex].minuteofday = minuteofday

   ; single precision floating point only
   data[lineindex].p_xrslong = float(thisarr[1])
   data[lineindex].p_xrsshort = float(thisarr[2])
   data[lineindex].p_sem304 = float(thisarr[3])
   data[lineindex].esp_0_7 = float(thisarr[4])
   data[lineindex].esp_17 = float(thisarr[5])
   data[lineindex].esp_25 = float(thisarr[6])
   data[lineindex].esp_30 = float(thisarr[7])
   data[lineindex].esp_36 = float(thisarr[8])
   data[lineindex].esp_dark = float(thisarr[9])
   data[lineindex].mp_lya = float(thisarr[10])
   data[lineindex].mp_dark = float(thisarr[11])
   data[lineindex].esp_q0 = float(thisarr[12])
   data[lineindex].esp_q1 = float(thisarr[13])
   data[lineindex].esp_q2 = float(thisarr[14])
   data[lineindex].esp_q3 = float(thisarr[15])
   data[lineindex].esp_cm_lat = float(thisarr[16])
   data[lineindex].esp_cm_lon = float(thisarr[17])
   data[lineindex].p_xrs_cool = float(thisarr[18])
   data[lineindex].p_oldxrs = float(thisarr[19])
endfor

return, data
end