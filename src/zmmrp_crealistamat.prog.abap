*&---------------------------------------------------------------------*
*& Report  ZMMRP_CREALISTAMAT
*&
*&---------------------------------------------------------------------*
*& Creado por: SCL Consultores
*& Fecha: 29.08.2017
*& Descripción: Programa para Cargar Lista de Materiales desde Doc. XLS
*&---------------------------------------------------------------------*

REPORT  zmmrp_crealistamat NO STANDARD PAGE HEADING LINE-SIZE 255.

TYPES: BEGIN OF ty_data,
       material(18) TYPE c,
       centro(4)    TYPE c,
       cod_emb(18)  TYPE c,
       cantidad(18) TYPE c,
       um(3)        TYPE c,
       END OF ty_data.

TYPES: BEGIN OF ty_index,
       material(18) TYPE c,
       centro(4)    TYPE c,
       cantidad TYPE i,
       END OF ty_index.

TYPES: BEGIN OF ty_err,
       material(18) TYPE c,
       mensaje(512) TYPE c,
       END OF ty_err.

*----------------------------------------------------------------------*
*   data definition
*----------------------------------------------------------------------*
*       Batchinputdata of single transaction
DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
*       messages of call transaction
DATA:   messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
*       error session opened (' ' or 'X')
*       message texts
TABLES: t100.

DATA: it_data   TYPE TABLE OF ty_data.
DATA: it_index  TYPE TABLE OF ty_index.
DATA: it_err    TYPE TABLE OF ty_err.

PARAMETERS: pa_file TYPE rlgrap-filename.
PARAMETERS: nodata DEFAULT '/' LOWER CASE NO-DISPLAY.          "nodata

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_file.
  PERFORM fo_get_file_name.

INITIALIZATION.
  AUTHORITY-CHECK OBJECT 'S_TCODE'
         ID 'TCD' FIELD 'ZMM032'.
  IF sy-subrc NE 0.
    MESSAGE 'No tiene privilegios para ejecutar esta transacción' TYPE 'E'.
  ENDIF.

START-OF-SELECTION.

  PERFORM fo_read_file.

END-OF-SELECTION.

  PERFORM fo_process_file.
*
  IF NOT it_err[] IS INITIAL.
    PERFORM fo_log.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  FO_GET_FILE_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fo_get_file_name .

  DATA: file_table  TYPE filetable,
        lv_file     LIKE LINE OF file_table,
        rc          TYPE i.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'Abrir archivo'
    CHANGING
      file_table              = file_table
      rc                      = rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.

  ELSE.

    LOOP AT file_table INTO lv_file.
      pa_file = lv_file-filename.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " FO_GET_FILE_NAME
*&---------------------------------------------------------------------*
*&      Form  FO_READ_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fo_read_file .

  DATA: lv_file TYPE string.
  lv_file = pa_file.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_file
      filetype                = 'DAT'
    TABLES
      data_tab                = it_data
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.                                 "#EC NEEDED
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  DELETE it_data WHERE material IS INITIAL.

ENDFORM.                    " FO_READ_FILE
*&---------------------------------------------------------------------*
*&      Form  FO_PROCESS_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fo_process_file .

  DATA: lv_index LIKE LINE OF it_index.
  DATA: lv_mast TYPE mast,
        lv_mat TYPE mara-matnr,
        lv_mensaje LIKE LINE OF it_err.

  PERFORM fo_prepare_index.

  LOOP AT it_index INTO lv_index.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input              = lv_index-material
     IMPORTING
       output             = lv_mat
     EXCEPTIONS
       LENGTH_ERROR       = 1
       OTHERS             = 2
              .
    IF sy-subrc <> 0.                                 "#EC NEEDED
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.


* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM mast INTO lv_mast WHERE matnr = lv_mat AND werks = lv_index-centro AND stlan = '7'.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM mast INTO lv_mast WHERE matnr = lv_mat AND werks = lv_index-centro AND stlan = '7' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
    IF sy-subrc <> 0.

      IF lv_index-cantidad = 1.
        PERFORM fo_bi_1 USING lv_index.
      ELSEIF lv_index-cantidad = 2.
        PERFORM fo_bi_2 USING lv_index.
      ELSEIF lv_index-cantidad > 2.
        PERFORM fo_bi_multi USING lv_index.
      ENDIF.

    ELSE.

      lv_mensaje-material = lv_mat.
      lv_mensaje-mensaje  = 'Material ya tiene lista creada '.
      APPEND lv_mensaje TO it_err.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " FO_PROCESS_FILE
*&---------------------------------------------------------------------*
*&      Form  FO_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fo_log .

  DATA: lv_mensaje LIKE LINE OF it_err.


  LOOP AT it_err INTO lv_mensaje.
    AT NEW material.
      WRITE: /, 'Material ' , lv_mensaje-material, /.
    ENDAT.

    WRITE:  AT 12 lv_mensaje-mensaje, /.

  ENDLOOP.

ENDFORM.                    " FO_LOG
*&---------------------------------------------------------------------*
*&      Form  FO_PREPARE_INDEX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fo_prepare_index .

  DATA: lv_data  LIKE LINE OF it_data.
  DATA: lv_index LIKE LINE OF it_index.
  DATA: lv_cont  TYPE i.
  DATA: ls_data LIKE LINE OF it_data.
  SORT it_data BY material centro.

  LOOP AT it_data INTO lv_data.
    ls_data = lv_data.
    AT NEW material.
      lv_cont = 0.
    ENDAT.

    AT NEW centro.
      lv_cont = 0.
    ENDAT.

    ADD 1 TO lv_cont.

    AT END OF centro.
      lv_index-material = ls_data-material.
      lv_index-centro   = ls_data-centro.
      lv_index-cantidad = lv_cont.
      APPEND lv_index TO it_index.
    ENDAT.

    AT END OF material.
      lv_index-material = ls_data-material.
      lv_index-centro   = ls_data-centro.
      lv_index-cantidad = lv_cont.
      APPEND lv_index TO it_index.
    ENDAT.

  ENDLOOP.

  SORT it_index BY material centro.
  DELETE ADJACENT DUPLICATES FROM it_index COMPARING material centro.

ENDFORM.                    " FO_PREPARE_INDEX
*&---------------------------------------------------------------------*
*&      Form  FO_BI_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_INDEX  text
*----------------------------------------------------------------------*
FORM fo_bi_1  USING    u_index TYPE ty_index.

  DATA: lv_params TYPE ctu_params.
  DATA: lv_data LIKE LINE OF it_data.
  DATA: l_mstring(480).
  DATA: lv_mensaje LIKE LINE OF it_err.
  DATA: lv_cantidadf TYPE p DECIMALS 3.

  lv_params-dismode = 'N'.
  lv_params-updmode = 'S'.
  lv_params-nobinpt = 'X'.

  CLEAR bdcdata. REFRESH bdcdata.
  CLEAR messtab. REFRESH messtab.

  READ TABLE it_data INTO lv_data WITH KEY material = u_index-material centro = u_index-centro.

  CHECK sy-subrc = 0.

  PERFORM bdc_dynpro      USING 'SAPLCSDI' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'RC29N-MATNR'
                                u_index-material.
  PERFORM bdc_field       USING 'RC29N-WERKS'
                                 u_index-centro.
  PERFORM bdc_field       USING 'RC29N-STLAN'
                                '7'.
*  PERFORM bdc_field       USING 'RC29N-DATUV'
*                                '20.07.2011'.
  PERFORM bdc_dynpro      USING 'SAPLCSDI' '2150'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=FCBU'.
  PERFORM bdc_field       USING 'RC29P-POSTP(01)'
                                'L'.
  PERFORM bdc_field       USING 'RC29P-IDNRK(01)'
                                lv_data-cod_emb.
  lv_cantidadf = lv_data-cantidad.
  WRITE lv_cantidadf TO lv_data-cantidad.
  PERFORM bdc_field       USING 'RC29P-MENGE(01)'
                                lv_data-cantidad.
  PERFORM bdc_field       USING 'RC29P-MEINS(01)'
                                lv_data-um.

  CALL TRANSACTION 'CS01' USING bdcdata OPTIONS FROM lv_params MESSAGES INTO messtab.
*  PERFORM bdc_transaction USING 'CS01'.

  LOOP AT messtab.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t100 WHERE sprsl = messtab-msgspra
*                              AND   arbgb = messtab-msgid
*                              AND   msgnr = messtab-msgnr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t100 WHERE sprsl = messtab-msgspra
                              AND   arbgb = messtab-msgid
                              AND   msgnr = messtab-msgnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
      l_mstring = t100-text.
      IF l_mstring CS '&1'.
        REPLACE '&1' WITH messtab-msgv1 INTO l_mstring.
        REPLACE '&2' WITH messtab-msgv2 INTO l_mstring.
        REPLACE '&3' WITH messtab-msgv3 INTO l_mstring.
        REPLACE '&4' WITH messtab-msgv4 INTO l_mstring.
      ELSE.
        REPLACE '&' WITH messtab-msgv1 INTO l_mstring.
        REPLACE '&' WITH messtab-msgv2 INTO l_mstring.
        REPLACE '&' WITH messtab-msgv3 INTO l_mstring.
        REPLACE '&' WITH messtab-msgv4 INTO l_mstring.
      ENDIF.
      CONDENSE l_mstring.
      CONCATENATE messtab-msgtyp ': ' l_mstring(250) INTO lv_mensaje-mensaje SEPARATED BY space.
    ELSE.
      CONCATENATE messtab-msgtyp ': ' l_mstring(250) INTO lv_mensaje-mensaje SEPARATED BY space.
    ENDIF.
    lv_mensaje-material = u_index-material.
    APPEND lv_mensaje TO it_err.
  ENDLOOP.

ENDFORM.                                                    " FO_BI_1
*&---------------------------------------------------------------------*
*&      Form  FO_BI_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_INDEX  text
*----------------------------------------------------------------------*
FORM fo_bi_2  USING    u_index TYPE ty_index.


  DATA: lv_params TYPE ctu_params.
  DATA: lv_data LIKE LINE OF it_data.
  DATA: lv_data_aux LIKE LINE OF it_data.
  DATA: lv_data2 LIKE LINE OF it_data.
  DATA: l_mstring(480).
  DATA: lv_mensaje LIKE LINE OF it_err.
  DATA: lv_cantidadf TYPE p DECIMALS 3.
  DATA: lv_count TYPE i.

  lv_params-dismode = 'N'.
  lv_params-updmode = 'S'.
  lv_params-nobinpt = 'X'.

  CLEAR bdcdata. REFRESH bdcdata.
  CLEAR messtab. REFRESH messtab.
  lv_count = 0.
  LOOP AT it_data INTO lv_data_aux WHERE material = u_index-material AND centro = u_index-centro.
    ADD 1 TO lv_count.
    CASE lv_count.
      WHEN 1.
        lv_data = lv_data_aux.
      WHEN 2.
        lv_data2 = lv_data_aux.
    ENDCASE.
  ENDLOOP.

  CHECK sy-subrc = 0.

  PERFORM bdc_dynpro      USING 'SAPLCSDI' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'RC29N-MATNR'
                                u_index-material.
  PERFORM bdc_field       USING 'RC29N-WERKS'
                                u_index-centro.
  PERFORM bdc_field       USING 'RC29N-STLAN'
                                '7'.
*  PERFORM bdc_field       USING 'RC29N-DATUV'
*                                '20.07.2011'.
  PERFORM bdc_dynpro      USING 'SAPLCSDI' '2150'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=FCBU'.
  PERFORM bdc_field       USING 'RC29P-POSTP(01)'
                                'L'.
  PERFORM bdc_field       USING 'RC29P-POSTP(02)'
                                'L'.
  PERFORM bdc_field       USING 'RC29P-IDNRK(01)'
                                lv_data-cod_emb.
  PERFORM bdc_field       USING 'RC29P-IDNRK(02)'
                                lv_data2-cod_emb.
  lv_cantidadf = lv_data-cantidad.
  WRITE lv_cantidadf TO lv_data-cantidad.
  PERFORM bdc_field       USING 'RC29P-MENGE(01)'
                                lv_data-cantidad.
  lv_cantidadf = lv_data2-cantidad.
  WRITE lv_cantidadf TO lv_data2-cantidad.
  PERFORM bdc_field       USING 'RC29P-MENGE(02)'
                                lv_data2-cantidad.
  PERFORM bdc_field       USING 'RC29P-MEINS(01)'
                                lv_data-um.
  PERFORM bdc_field       USING 'RC29P-MEINS(02)'
                                lv_data2-um.

  CALL TRANSACTION 'CS01' USING bdcdata OPTIONS FROM lv_params MESSAGES INTO messtab.
*  PERFORM bdc_transaction USING 'CS01'.

  LOOP AT messtab.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t100 WHERE sprsl = messtab-msgspra
*                              AND   arbgb = messtab-msgid
*                              AND   msgnr = messtab-msgnr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t100 WHERE sprsl = messtab-msgspra
                              AND   arbgb = messtab-msgid
                              AND   msgnr = messtab-msgnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
      l_mstring = t100-text.
      IF l_mstring CS '&1'.
        REPLACE '&1' WITH messtab-msgv1 INTO l_mstring.
        REPLACE '&2' WITH messtab-msgv2 INTO l_mstring.
        REPLACE '&3' WITH messtab-msgv3 INTO l_mstring.
        REPLACE '&4' WITH messtab-msgv4 INTO l_mstring.
      ELSE.
        REPLACE '&' WITH messtab-msgv1 INTO l_mstring.
        REPLACE '&' WITH messtab-msgv2 INTO l_mstring.
        REPLACE '&' WITH messtab-msgv3 INTO l_mstring.
        REPLACE '&' WITH messtab-msgv4 INTO l_mstring.
      ENDIF.
      CONDENSE l_mstring.
      CONCATENATE messtab-msgtyp ': ' l_mstring(250) INTO lv_mensaje-mensaje SEPARATED BY space.
    ELSE.
      CONCATENATE messtab-msgtyp ': ' l_mstring(250) INTO lv_mensaje-mensaje SEPARATED BY space.
    ENDIF.
    lv_mensaje-material = u_index-material.
    APPEND lv_mensaje TO it_err.
  ENDLOOP.

ENDFORM.                                                    " FO_BI_2
*&---------------------------------------------------------------------*
*&      Form  FO_BI_MULTI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_INDEX  text
*----------------------------------------------------------------------*
FORM fo_bi_multi  USING    u_index TYPE ty_index.


  DATA: lv_params TYPE ctu_params.
  DATA: lv_data LIKE LINE OF it_data.
  DATA: lv_data_aux LIKE LINE OF it_data.
  DATA: lv_data2 LIKE LINE OF it_data.
  DATA: l_mstring(480).
  DATA: lv_mensaje LIKE LINE OF it_err.
  DATA: lv_cantidadf TYPE p DECIMALS 3.
  DATA: lv_count TYPE i.

  lv_count = 0.
  LOOP AT it_data INTO lv_data_aux WHERE material = u_index-material AND centro = u_index-centro.
    ADD 1 TO lv_count.
    CASE lv_count .
      WHEN 1.
        lv_data = lv_data_aux.
      WHEN 2.
        lv_data2 = lv_data_aux.
    ENDCASE.
  ENDLOOP.

  lv_params-dismode = 'N'.
  lv_params-updmode = 'S'.
  lv_params-nobinpt = 'X'.

  CLEAR bdcdata. REFRESH bdcdata.
  CLEAR messtab. REFRESH messtab.


  PERFORM bdc_dynpro      USING 'SAPLCSDI' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'RC29N-MATNR'
                                u_index-material.
  PERFORM bdc_field       USING 'RC29N-WERKS'
                                u_index-centro.
  PERFORM bdc_field       USING 'RC29N-STLAN'
                                '7'.
*  PERFORM bdc_field       USING 'RC29N-DATUV'
*                                '20.07.2011'.
  PERFORM bdc_dynpro      USING 'SAPLCSDI' '2150'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ERFA'.
  PERFORM bdc_field       USING 'RC29P-POSTP(01)'
                                'L'.
  PERFORM bdc_field       USING 'RC29P-POSTP(02)'
                                'L'.
  PERFORM bdc_field       USING 'RC29P-IDNRK(01)'
                                lv_data-cod_emb.
  PERFORM bdc_field       USING 'RC29P-IDNRK(02)'
                                lv_data2-cod_emb.
  lv_cantidadf = lv_data-cantidad.
  WRITE lv_cantidadf TO lv_data-cantidad.
  PERFORM bdc_field       USING 'RC29P-MENGE(01)'
                                lv_data-cantidad.
  lv_cantidadf = lv_data2-cantidad.
  WRITE lv_cantidadf TO lv_data2-cantidad.
  PERFORM bdc_field       USING 'RC29P-MENGE(02)'
                                lv_data2-cantidad.
  PERFORM bdc_field       USING 'RC29P-MEINS(01)'
                                lv_data-um.
  PERFORM bdc_field       USING 'RC29P-MEINS(02)'
                                lv_data2-um.
  lv_count = 0.
  LOOP AT it_data INTO lv_data_aux WHERE material = u_index-material AND centro = u_index-centro.
    ADD 1 TO lv_count.
    IF lv_count <> 1 AND lv_count <> 2.

      IF lv_count <> u_index-cantidad.
        PERFORM bdc_dynpro      USING 'SAPLCSDI' '2150'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=ERFA'.
      ELSE.
        PERFORM bdc_dynpro      USING 'SAPLCSDI' '2150'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=FCBU'.
      ENDIF.

      PERFORM bdc_field       USING 'RC29P-POSTP(02)'
                                    'L'.
      PERFORM bdc_field       USING 'RC29P-IDNRK(02)'
                                    lv_data_aux-cod_emb.
      lv_cantidadf = lv_data_aux-cantidad.
      WRITE lv_cantidadf TO lv_data_aux-cantidad.
      PERFORM bdc_field       USING 'RC29P-MENGE(02)'
                                    lv_data_aux-cantidad.
      PERFORM bdc_field       USING 'RC29P-MEINS(02)'
                                    lv_data_aux-um.
    ENDIF.
  ENDLOOP.

  CALL TRANSACTION 'CS01' USING bdcdata OPTIONS FROM lv_params MESSAGES INTO messtab.
*  PERFORM bdc_transaction USING 'CS01'.

  LOOP AT messtab.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t100 WHERE sprsl = messtab-msgspra
*                              AND   arbgb = messtab-msgid
*                              AND   msgnr = messtab-msgnr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t100 WHERE sprsl = messtab-msgspra
                              AND   arbgb = messtab-msgid
                              AND   msgnr = messtab-msgnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
      l_mstring = t100-text.
      IF l_mstring CS '&1'.
        REPLACE '&1' WITH messtab-msgv1 INTO l_mstring.
        REPLACE '&2' WITH messtab-msgv2 INTO l_mstring.
        REPLACE '&3' WITH messtab-msgv3 INTO l_mstring.
        REPLACE '&4' WITH messtab-msgv4 INTO l_mstring.
      ELSE.
        REPLACE '&' WITH messtab-msgv1 INTO l_mstring.
        REPLACE '&' WITH messtab-msgv2 INTO l_mstring.
        REPLACE '&' WITH messtab-msgv3 INTO l_mstring.
        REPLACE '&' WITH messtab-msgv4 INTO l_mstring.
      ENDIF.
      CONDENSE l_mstring.
      CONCATENATE messtab-msgtyp ': ' l_mstring(250) INTO lv_mensaje-mensaje SEPARATED BY space.
    ELSE.
      CONCATENATE messtab-msgtyp ': ' l_mstring(250) INTO lv_mensaje-mensaje SEPARATED BY space.
    ENDIF.
    lv_mensaje-material = u_index-material.

    APPEND lv_mensaje TO it_err.
  ENDLOOP.

ENDFORM.                    " FO_BI_MULTI


*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.                    "bdc_dynpro

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  IF fval <> nodata.
    CLEAR bdcdata.
    bdcdata-fnam = fnam.
    bdcdata-fval = fval.
    APPEND bdcdata.
  ENDIF.
ENDFORM.                    "bdc_field
