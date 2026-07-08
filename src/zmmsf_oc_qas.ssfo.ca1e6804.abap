CLEAR: gs_adrc, gv_text_pos.

IF gs_ekpo-adrnr IS INITIAL.
SELECT SINGLE adrnr INTO gs_ekpo-adrnr FROM t001w
WHERE werks = gs_ekpo-werks.
ENDIF.

SELECT SINGLE name1 street city1 house_num1 country
sort1 tel_number
INTO gs_adrc FROM adrc
WHERE addrnumber = gs_ekpo-adrnr.

CONCATENATE is_ekko-ebeln gs_ekpo-ebelp INTO gv_text_pos.




















