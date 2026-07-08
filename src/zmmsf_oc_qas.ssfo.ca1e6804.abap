CLEAR: gs_adrc, gv_text_pos.

IF gs_ekpo-adrnr IS INITIAL.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE adrnr INTO gs_ekpo-adrnr FROM t001w
*WHERE werks = gs_ekpo-werks.
*
* NEW CODE
SELECT adrnr
UP TO 1 ROWS  INTO gs_ekpo-adrnr FROM t001w
WHERE werks = gs_ekpo-werks ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
ENDIF.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE name1 street city1 house_num1 country
*sort1 tel_number
*INTO gs_adrc FROM adrc
*WHERE addrnumber = gs_ekpo-adrnr.
*
* NEW CODE
SELECT name1 street city1 house_num1 country
sort1 tel_number
UP TO 1 ROWS 
INTO gs_adrc FROM adrc
WHERE addrnumber = gs_ekpo-adrnr ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

CONCATENATE is_ekko-ebeln gs_ekpo-ebelp INTO gv_text_pos.




















