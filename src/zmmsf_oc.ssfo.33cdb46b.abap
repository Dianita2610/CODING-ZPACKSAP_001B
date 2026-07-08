DATA: lv_frgco TYPE frgco.

DATA: lt_tline TYPE STANDARD TABLE OF tline,
      ls_tline LIKE LINE OF lt_tline,
      lv_tdname TYPE thead-tdname.

DATA: lv_frgst TYPE eban-frgst,
      lv_frggr TYPE eban-frggr.

gv_total = gv_neto + gv_iva.

SELECT * FROM cdhdr INTO TABLE gt_cdhdr
  WHERE objectclas EQ 'EINKBELEG'
    AND objectid   EQ is_ekko-ebeln
    AND tcode      IN ('ME29N', 'ME28').
*    ORDER BY changenr DESCENDING.

  SORT gt_cdhdr BY changenr DESCENDING.

  READ TABLE gt_cdhdr INDEX 1 INTO gs_cdhdr.

  IF gs_cdhdr IS NOT INITIAL.
    SELECT SINGLE * FROM cdpos INTO gs_cdpos
        WHERE objectclas = gs_cdhdr-objectclas
          AND objectid   = gs_cdhdr-objectid
          AND changenr   = gs_cdhdr-changenr
          AND tabname    = 'EKKO'
          AND fname      = 'FRGZU'
          AND chngind    = 'U'.
    IF sy-subrc EQ 0.
      SELECT SINGLE *
        INTO gs_t16fs
        FROM t16fs
       WHERE frggr EQ is_ekko-frggr
         AND frgsx EQ is_ekko-frgsx.

    CASE gs_cdpos-value_new.
      WHEN 'X'.
        lv_frgco = gs_t16fs-frgc1.
      WHEN 'XX'.
        lv_frgco = gs_t16fs-frgc2.
      WHEN 'XXX'.
        lv_frgco = gs_t16fs-frgc3.
      WHEN 'XXXX'.
        lv_frgco = gs_t16fs-frgc4.
      WHEN 'XXXXX'.
        lv_frgco = gs_t16fs-frgc5.
      WHEN 'XXXXXX'.
        lv_frgco = gs_t16fs-frgc6.
      WHEN 'XXXXXXX'.
        lv_frgco = gs_t16fs-frgc7.
      WHEN 'XXXXXXXX'.
        lv_frgco = gs_t16fs-frgc8.
    ENDCASE.

      IF lv_frgco IS NOT INITIAL.
        SELECT SINGLE frgct FROM t16fd INTO gv_frgct
          WHERE spras = 'S'
            AND frggr = is_ekko-frggr
            AND frgco = lv_frgco.
      ENDIF.
    ENDIF.
  ENDIF.

*   / Texto de Cabecera
  lv_tdname = is_ekko-ebeln.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
*     client                        = SY-MANDT
      id                            = 'F17'
      language                      = 'S'
      name                          = lv_tdname
      object                        = 'EKKO'
*     ARCHIVE_HANDLE                = 0
*     LOCAL_CAT                     = ' '
*   IMPORTING
*     HEADER                        =
    TABLES
      lines                         = lt_tline
   EXCEPTIONS
     ID                            = 1
     LANGUAGE                      = 2
     NAME                          = 3
     NOT_FOUND                     = 4
     OBJECT                        = 5
     REFERENCE_CHECK               = 6
     WRONG_ACCESS_TO_ARCHIVE       = 7
     OTHERS                        = 8
            .
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  READ TABLE lt_tline INTO ls_tline INDEX 1.
    IF sy-subrc EQ 0.
      gv_atencion = ls_tline-tdline.
    ENDIF.

READ TABLE it_ekpo INTO gs_ekpo index 1.
    IF sy-subrc EQ 0.
      SELECT SINGLE frgst frggr FROM eban INTO (lv_frgst, lv_frggr)
        WHERE banfn = gs_ekpo-banfn
          AND bnfpo = 00010.
    ENDIF.

SELECT * FROM cdhdr INTO TABLE gt_cdhdr
  WHERE objectclas EQ 'BANF'
    AND objectid   EQ gs_ekpo-banfn
    AND tcode      IN ('ME54N', 'ME55').
*    ORDER BY changenr DESCENDING.

  SORT gt_cdhdr BY changenr DESCENDING.
  CLEAR gs_cdhdr.
  READ TABLE gt_cdhdr INDEX 1 INTO gs_cdhdr.

  IF gs_cdhdr IS NOT INITIAL.

    SELECT SINGLE * FROM cdpos INTO gs_cdpos
        WHERE objectclas = gs_cdhdr-objectclas
          AND objectid   = gs_cdhdr-objectid
          AND changenr   = gs_cdhdr-changenr
          AND tabname    = 'EBAN'
          AND fname      = 'FRGZU'
          AND chngind    = 'U'.
    IF sy-subrc EQ 0.
      SELECT SINGLE *
        INTO gs_t16fs
        FROM t16fs
       WHERE frggr EQ lv_frggr
         AND frgsx EQ lv_frgst.
CLEAR lv_frgco.
    CASE gs_cdpos-value_new.
      WHEN 'X'.
        lv_frgco = gs_t16fs-frgc1.
      WHEN 'XX'.
        lv_frgco = gs_t16fs-frgc2.
      WHEN 'XXX'.
        lv_frgco = gs_t16fs-frgc3.
      WHEN 'XXXX'.
        lv_frgco = gs_t16fs-frgc4.
      WHEN 'XXXXX'.
        lv_frgco = gs_t16fs-frgc5.
      WHEN 'XXXXXX'.
        lv_frgco = gs_t16fs-frgc6.
      WHEN 'XXXXXXX'.
        lv_frgco = gs_t16fs-frgc7.
      WHEN 'XXXXXXXX'.
        lv_frgco = gs_t16fs-frgc8.
    ENDCASE.

      IF lv_frgco IS NOT INITIAL.
        SELECT SINGLE frgct FROM t16fd INTO gv_frgct0
          WHERE spras = 'S'
            AND frggr = lv_frggr
            AND frgco = lv_frgco.
      ENDIF.
    ENDIF.
    ENDIF.

















