* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE maktx FROM makt INTO (gv_maktx)
*WHERE matnr = gs_ekpo-matnr
*AND spras = 'S'.
*
* NEW CODE
SELECT maktx
UP TO 1 ROWS  FROM makt INTO (gv_maktx)
WHERE matnr = gs_ekpo-matnr
AND spras = 'S' ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

gv_netwr = gs_ekpo-netwr * 100.
gv_netpr = gs_ekpo-netpr * 100.
gv_neto  = gv_neto + gs_ekpo-netwr * 100.

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
gv_iva = gv_iva + gs_komv-kwert * 100.
ENDIF.




















