
clear: v_neto, v_iva, v_total.

LOOP AT ti_salida into wa_salida.

v_neto = v_neto + wa_salida-netwr .

ENDLOOP.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT single *
*  into CORRESPONDING FIELDS OF wa_ekpo
*  from ekpo
*  where ebeln = v_ebeln.
*
* NEW CODE
SELECT *
UP TO 1 ROWS 
  into CORRESPONDING FIELDS OF wa_ekpo
  from ekpo
  where ebeln = v_ebeln ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

IF wa_ekpo-MWSKZ eq 'C1'.
v_iva = ( v_neto * 19 ) / 100.
ENDIF.

v_total = v_neto + v_iva.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE waers
*INTO v_waers
*FROM ekko
*WHERE ebeln EQ v_ebeln.
*
* NEW CODE
SELECT waers
UP TO 1 ROWS 
INTO v_waers
FROM ekko
WHERE ebeln EQ v_ebeln ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

WRITE  v_neto  TO v_neto_out CURRENCY v_waers.
WRITE  v_iva   TO v_iva_out CURRENCY v_waers.
WRITE  v_total TO v_total_out CURRENCY v_waers.










