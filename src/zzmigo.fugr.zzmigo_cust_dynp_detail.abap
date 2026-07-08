FUNCTION zzmigo_cust_dynp_detail.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_LINE_ID) TYPE  MB_LINE_ID
*"     VALUE(I_AUFNR) TYPE  AUFNR OPTIONAL
*"     VALUE(I_MATNR) TYPE  MATNR
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     VALUE(ZUNID_PRO) TYPE  ZZUNID_PRO
*"----------------------------------------------------------------------
*  w_aufnr = i_aufnr.
  DATA : v_mtart TYPE mara-mtart.
  DATA : mensaje(30).
  CLEAR: v_mtart.

  IF i_line_id IS NOT INITIAL.
    w_line_id = i_line_id.
    "Consutamos si el registro fue guardado previamente, si es así se carga al dato global
    READ TABLE gt_mseg INTO gs_mseg WITH KEY line_id = i_line_id.
    IF sy-subrc EQ 0 .
      zzunid_pro = gs_mseg-zzunid_pro.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE mtart INTO v_mtart
*                          FROM mara
*                          WHERE matnr EQ i_matnr.
*
* NEW CODE
      SELECT mtart
      UP TO 1 ROWS  INTO v_mtart
                          FROM mara
                          WHERE matnr EQ i_matnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
      IF v_mtart EQ 'ZSSV' OR v_mtart EQ 'ZREA' OR
         v_mtart EQ 'ZPRO' OR v_mtart EQ 'ZAFI'.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM zunid_prod
*                     WHERE bukrs = i_bukrs
*                     AND  zzcod_unidad = zzunid_pro.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM zunid_prod
                     WHERE bukrs = i_bukrs
                     AND  zzcod_unidad = zzunid_pro ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
        IF sy-subrc <> 0.
          MESSAGE w016(z1) WITH 'EL CAMPO UNID/PRO' 'NO EXSITE  LINEA' i_line_id.
        ENDIF.
      ENDIF.
    ELSE.
      "Si no se encuentra la posición guardada se inserta en la tabla temporal y se limpia el dato global
      CLEAR: gs_mseg, zzunid_pro.
      gs_mseg-line_id  = i_line_id.
      APPEND gs_mseg TO gt_mseg.
    ENDIF.
  ENDIF.
*if zzunid_pro is INITIAL.
*  SELECT SINGLE zzunid_pro INTO (zzunid_pro)
*  FROM mseg
*  WHERE line_id = w_line_id.
*ENDIF.

ENDFUNCTION.
