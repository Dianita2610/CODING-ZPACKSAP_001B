DATA: lv_werks TYPE ekpo-werks.
CLEAR gs_adrc.

  DATA: lv_adrnr  TYPE t001-adrnr.


  SELECT SINGLE adrnr INTO lv_adrnr
    FROM t001 WHERE bukrs = is_ekko-bukrs.

  SELECT SINGLE name1 street city1 house_num1 country
    sort1 tel_number
    INTO gs_adrc FROM adrc
      WHERE addrnumber = lv_adrnr.
