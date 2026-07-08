

*DATA: ti_salida TYPE TABLE OF ty_salida.


v_ebeln = zxekko-ebeln.

SELECT *
INTO CORRESPONDING FIELDS OF TABLE ti_salida
FROM ekpo
WHERE ebeln EQ v_ebeln
  and LOEKZ eq ''.




















