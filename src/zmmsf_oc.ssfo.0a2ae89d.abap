DATA: lv_werks TYPE ekpo-werks,
      lv_adrnr TYPE ekpo-adrnr.
CLEAR gs_adrc.

* / Verificar si todas los centros son iguales

LOOP AT it_ekpo INTO gs_ekpo.
  IF sy-tabix EQ '1'.
    lv_werks = gs_ekpo-werks.
  ELSEIF gs_ekpo-werks NE lv_werks.
    CLEAR gv_deliv.
    EXIT.
  ENDIF.

  IF gs_ekpo-adrnr IS NOT INITIAL.
    lv_adrnr = gs_ekpo-adrnr.
  ENDIF.

ENDLOOP.

  IF lv_werks IS NOT INITIAL AND lv_adrnr IS INITIAL.
    SELECT SINGLE adrnr FROM t001w INTO lv_adrnr
      WHERE werks = lv_werks.
  ENDIF.

  SELECT SINGLE name1 street city1 house_num1 country
    sort1 tel_number
    INTO gs_adrc FROM adrc
      WHERE addrnumber = lv_adrnr.
