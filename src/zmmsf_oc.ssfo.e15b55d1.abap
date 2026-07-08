DATA: lv_werks TYPE ekpo-werks.
CLEAR gs_adrc.

  DATA: lv_adrnr  TYPE t001-adrnr.


* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE adrnr INTO lv_adrnr
*    FROM t001 WHERE bukrs = is_ekko-bukrs.
*
* NEW CODE
  SELECT adrnr
  UP TO 1 ROWS  INTO lv_adrnr
    FROM t001 WHERE bukrs = is_ekko-bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE name1 street city1 house_num1 country
*    sort1 tel_number
*    INTO gs_adrc FROM adrc
*      WHERE addrnumber = lv_adrnr.
*
* NEW CODE
  SELECT name1 street city1 house_num1 country
    sort1 tel_number
  UP TO 1 ROWS 
    INTO gs_adrc FROM adrc
      WHERE addrnumber = lv_adrnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
