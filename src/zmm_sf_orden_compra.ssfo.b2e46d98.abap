
clear: v_neto, v_iva, v_total.

LOOP AT ti_salida into wa_salida.

v_neto = v_neto + wa_salida-netwr .

ENDLOOP.

SELECT single *
  into CORRESPONDING FIELDS OF wa_ekpo
  from ekpo
  where ebeln = v_ebeln.

IF wa_ekpo-MWSKZ eq 'C1'.
v_iva = ( v_neto * 19 ) / 100.
ENDIF.

v_total = v_neto + v_iva.

SELECT SINGLE waers
INTO v_waers
FROM ekko
WHERE ebeln EQ v_ebeln.

WRITE  v_neto  TO v_neto_out CURRENCY v_waers.
WRITE  v_iva   TO v_iva_out CURRENCY v_waers.
WRITE  v_total TO v_total_out CURRENCY v_waers.










