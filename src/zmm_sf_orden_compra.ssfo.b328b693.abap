*TYPES: BEGIN OF ty_salida,
*  matnr     type ekpo-matnr,
*  txz01     TYPE ekpo-txz01,
*  menge     TYPE ekpo-menge,
*  meins     TYPE ekpo-meins,
*  netpr     TYPE ekpo-netpr,
*  netwr     TYPE ekpo-netwr,
*  END OF ty_salida.
*
*data: ti_salida type TABLE OF ty_salida.

SELECT *
  into CORRESPONDING FIELDS OF TABLE ti_salida
  from ekpo
  where ebeln eq v_ebeln
    and LOEKZ eq ''.

SELECT single waers
INTO v_waers
FROM ekko
WHERE ebeln EQ v_ebeln.

LOOP at ti_salida into wa_salida.

  WRITE  wa_salida-netpr TO wa_salida-netpr_out CURRENCY v_waers.
  WRITE  wa_salida-netwr TO wa_salida-netwr_out CURRENCY v_waers.

  MODIFY ti_salida FROM wa_salida index sy-tabix.
ENDLOOP.











