

*DATA: ti_salida TYPE TABLE OF ty_salida.


v_ebeln = zxekko-ebeln.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT *
*INTO CORRESPONDING FIELDS OF TABLE ti_salida
*FROM ekpo
*WHERE ebeln EQ v_ebeln
*  and LOEKZ eq ''.
*
* NEW CODE
SELECT *

INTO CORRESPONDING FIELDS OF TABLE ti_salida
FROM ekpo
WHERE ebeln EQ v_ebeln
  and LOEKZ eq '' ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03




















