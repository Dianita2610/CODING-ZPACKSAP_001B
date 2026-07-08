CLEAR: gv_kbetr, gv_maktx.

IF gs_ekpo-matnr IS NOT INITIAL.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE maktx FROM makt INTO (gv_maktx)
*    WHERE matnr = gs_ekpo-matnr
*      AND spras = 'S'.
*
* NEW CODE
  SELECT maktx
  UP TO 1 ROWS  FROM makt INTO (gv_maktx)
    WHERE matnr = gs_ekpo-matnr
      AND spras = 'S' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
ELSE.
  gv_maktx = gs_ekpo-txz01.
ENDIF.

READ TABLE it_tkomv INTO gs_komv WITH KEY knumv = is_ekko-knumv
                                          kposn = gs_ekpo-ebelp
                                          kschl = 'RL01'.
  IF sy-subrc EQ 0.
    gv_kbetr = gs_komv-kbetr * -1.
  ENDIF.

READ TABLE it_tkomv INTO gs_komv WITH KEY knumv = is_ekko-knumv
                                          kposn = gs_ekpo-ebelp
                                          kschl = 'ZIVA'.
  IF sy-subrc EQ 0.
    IF is_ekko-waers = 'CLP'.
      gv_iva = gv_iva + gs_komv-kwert * 100.
    ELSE.
      gv_iva = gv_iva + gs_komv-kwert.
    ENDIF.
  ENDIF.
IF is_ekko-waers = 'CLP'.
  gv_netwr = gs_ekpo-netwr * 100.
  gv_netpr = gs_ekpo-netpr * 100.
  gv_neto  = gv_neto + gs_ekpo-netwr * 100.
ELSE.
  gv_netwr = gs_ekpo-netwr.
  gv_netpr = gs_ekpo-netpr.
  gv_neto  = gv_neto + gs_ekpo-netwr.
ENDIF.

gv_kbetr = gv_kbetr / 10.













