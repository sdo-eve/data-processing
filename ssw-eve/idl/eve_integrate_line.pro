;docformat = 'rst'

;+
;Integrate an irradiance from wave_min to wave_max, using the MEGS-A, MEGS-B, 
;or Level 2 wavelength scale
;
;You should set exactly one of /megsa, /megsb, and /l2. If none are set,
;the function will break. If more than one is set, the first one
;in the priority list /megsa, /megsb, /l2 is chosen.
;
;This does an integration of a wavelength range with no instrument 
;sensitivity weighting. This is a "line". If you need instrument 
;sensitivity, use integrate_band().
;
;This uses the Midpoint rule to integrate - Each bin is considered to be 
;centered at its wavelength, and the measurement is considered to be the 
;mean measurement over the bin.
;
;:Params:
;  wave_min: in, required
;    minimum wavelength of the line in question, in nanometers
;  wave_max: in, required
;    maximum wavelength
;  irradiance_in: in, required
;    measurement, (W/m^2)/nm
;:Keywords:
;  neg: in, optional
;    if set, ignore negative values. Treat them as
;    zero in the integration. If not set, return -1 if any bins
;    are negative.
;  megsa: in, optional
;    if set, input wavelength scale is MEGS-A
;  megsb: in, optional
;    if set, input wavelength scale is MEGS-B
;  l2: in, optional
;    if set, input wavelength scale is Level 2
;:returns:
;  integrated measurement between the given wavelength 
;  Since input is in (W/m^2)/nm, output is in W/m^2
;:Categories:
;  user
;-
function eve_integrate_line,wave_min,wave_max,irradiance_in,megsa=megsa,megsb=megsb,l2=l2,neg=neg

  ; for integration, replace all fill values with zero
  ; work with a copy of the data
  irradiance = irradiance_in

  ; replace fill values
  x=where(irradiance lt -0.9,n_x)
  if n_x gt 0 then irradiance[x]=-1.

  bin_min=eve_get_wave_bin(wave_min,megsa=megsa,megsb=megsb,l2=l2)
  bin_max=eve_get_wave_bin(wave_max,megsa=megsa,megsb=megsb,l2=l2)
  if bin_min lt 0 or bin_max lt 0 then return, -1.0
  if bin_min eq bin_max then return,-1.0
;  print,bin_min,bin_max
  delta_lambda=eve_get_wave_bin(/inv,megsa=megsa,megsb=megsb,l2=l2,bin_min+1)- $
               eve_get_wave_bin(/inv,megsa=megsa,megsb=megsb,l2=l2,bin_min)

  ;Check if any negative values are included, if so we can't integrate
  ;so return a fill value
  ig=indgen(n_elements(irradiance))
  w=where(irradiance lt 0 and ig ge bin_min and ig le bin_max,count)
  if count gt 0 then begin
    if keyword_set(neg) then begin
      irradiance[w]=0
    end else begin
      if ~keyword_set(unc) then message,/info,"Bad data in EVE line "+string(wave_min)
      return,-1
    end
  end

  if keyword_set(unc) then begin
    return,delta_lambda*sqrt(total(irradiance[bin_min:bin_max]^2))
  end else begin
    return,delta_lambda*total(irradiance[bin_min:bin_max])
  end
end

