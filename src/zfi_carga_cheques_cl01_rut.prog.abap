*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFI_CARGA_CHEQUES_RUT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  INPUT_LOCAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM input_local .
  DATA  strarq       TYPE string.
  DATA: cadena TYPE string.
  IF NOT p_local IS INITIAL.
    strarq = p_file.

    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename                = strarq
        filetype                = 'ASC'
        has_field_separator     = 'X'
      TABLES
        data_tab                = ti_entrada
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
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      DELETE ti_entrada WHERE vblnr IS INITIAL.
      LOOP AT ti_entrada INTO wa_entrada.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = wa_entrada-vblnr
          IMPORTING
            output = wa_entrada-vblnr.

        MODIFY ti_entrada FROM wa_entrada INDEX sy-tabix.
      ENDLOOP.
    ENDIF.

  ELSE.
    strarq = servidor.
    DATA: tab TYPE c.
    tab = cl_abap_char_utilities=>horizontal_tab.
    OPEN DATASET strarq FOR INPUT ENCODING DEFAULT IN TEXT MODE.
    IF sy-subrc EQ 0.
      DO.
        READ DATASET strarq INTO cadena.
        IF sy-subrc EQ 0.
          CLEAR wa_entrada.
          SPLIT cadena AT tab
                INTO wa_entrada-bukrs
                     wa_entrada-hbkid
                     wa_entrada-hktid
                     wa_entrada-chect
                     wa_entrada-vblnr
                     wa_entrada-gjahr
                     wa_entrada-belnr.
          APPEND wa_entrada TO ti_entrada.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDIF.
ENDFORM.                    " INPUT_LOCAL
*&---------------------------------------------------------------------*
*&      Form  PROCESAR_DATOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM procesar_datos .

  TYPES: BEGIN OF t_bkpf,
           bukrs TYPE bkpf-bukrs,
           belnr TYPE bkpf-belnr,
           gjahr TYPE bkpf-gjahr,
           blart TYPE bkpf-blart,
           xref1_hd TYPE bkpf-xref1_hd,
         END OF t_bkpf.

  TYPES: BEGIN OF t_bseg,
           bukrs TYPE bkpf-bukrs,
           belnr TYPE bkpf-belnr,
           gjahr TYPE bkpf-gjahr,
           lifnr TYPE bseg-lifnr,
           kunnr TYPE bseg-kunnr,
         END OF t_bseg.

  TYPES: BEGIN OF t_lfa1,
           lifnr TYPE lfa1-lifnr,
           ort01 TYPE lfa1-ort01,
         END OF t_lfa1.

  DATA: ti_bkpf TYPE TABLE OF t_bkpf,
        ti_bseg TYPE TABLE OF t_bseg,
        wa_bseg TYPE t_bseg,
        ti_lfa1 TYPE TABLE OF t_lfa1,
        wa_lfa1 TYPE t_lfa1,
        wa_bkpf TYPE t_bkpf.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 50
      text       = 'Procesando Documentos'.

SELECT bukrs belnr gjahr lifnr kunnr
INTO TABLE ti_bseg
FROM bseg
FOR ALL ENTRIES IN ti_entrada
WHERE bukrs EQ ti_entrada-bukrs
AND belnr EQ ti_entrada-belnr
AND gjahr EQ ti_entrada-gjahr
AND ( koart EQ 'K' OR
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*koart EQ 'D' ).
KOART EQ 'D' ) ORDER BY PRIMARY KEY .
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
  IF sy-subrc EQ 0.
    SORT ti_bseg BY bukrs belnr gjahr.
    SELECT lifnr ort01
      INTO TABLE ti_lfa1
      FROM lfa1
      FOR ALL ENTRIES IN ti_bseg
      WHERE lifnr EQ ti_bseg-lifnr.

    SELECT kunnr ort01
      APPENDING TABLE ti_lfa1
      FROM kna1
      FOR ALL ENTRIES IN ti_bseg
      WHERE kunnr EQ ti_bseg-kunnr.

    SORT ti_lfa1 BY lifnr.
  ENDIF.

  LOOP AT ti_entrada INTO wa_entrada.
    REFRESH: bdcdata, messtab.
    READ TABLE ti_bseg INTO wa_bseg WITH KEY bukrs = wa_entrada-bukrs
                                             belnr = wa_entrada-belnr
                                             gjahr = wa_entrada-gjahr
                                             BINARY SEARCH.
    IF sy-subrc EQ 0.
      READ TABLE ti_lfa1 INTO wa_lfa1
      WITH KEY lifnr = wa_bseg-lifnr BINARY SEARCH.
      IF sy-subrc NE 0.
        READ TABLE ti_lfa1 INTO wa_lfa1
        WITH KEY lifnr = wa_bseg-kunnr BINARY SEARCH.
      ENDIF.

      IF wa_lfa1-ort01 IS INITIAL. "Si no tiene Población
        PERFORM bdc_dynpro USING 'SAPMFCHK'    '0500'.
        PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
        PERFORM bdc_field  USING 'PAYR-VBLNR'  wa_entrada-belnr.
        PERFORM bdc_field  USING 'PAYR-ZBUKR'  wa_entrada-bukrs.
        PERFORM bdc_field  USING 'PAYR-GJAHR'  wa_entrada-gjahr.
        PERFORM bdc_field  USING 'PAYR-HBKID'  wa_entrada-hbkid.
        PERFORM bdc_field  USING 'PAYR-HKTID'  wa_entrada-hktid.
        PERFORM bdc_field  USING 'PAYR-CHECT'  wa_entrada-chect.

        PERFORM bdc_dynpro USING 'SAPMFCHK'    '0501'.
        PERFORM bdc_field  USING 'BDC_OKCODE'  '=UPDA'.
        PERFORM bdc_field  USING 'PAYR-ZORT1'  'SANTIAGO'.
      ELSE.
        PERFORM bdc_dynpro USING 'SAPMFCHK'    '0500'.
        PERFORM bdc_field  USING 'BDC_OKCODE'  '=UPDA'.
        PERFORM bdc_field  USING 'PAYR-VBLNR'  wa_entrada-belnr.
        PERFORM bdc_field  USING 'PAYR-ZBUKR'  wa_entrada-bukrs.
        PERFORM bdc_field  USING 'PAYR-GJAHR'  wa_entrada-gjahr.
        PERFORM bdc_field  USING 'PAYR-HBKID'  wa_entrada-hbkid.
        PERFORM bdc_field  USING 'PAYR-HKTID'  wa_entrada-hktid.
        PERFORM bdc_field  USING 'PAYR-CHECT'  wa_entrada-chect.
      ENDIF.

      CALL TRANSACTION 'FCH5' USING bdcdata
                      MODE ctumode
                      UPDATE cupdate
                      MESSAGES INTO messtab.

      LOOP AT messtab.
        CLEAR wa_log.
        wa_log-msgid = '00'.
        wa_log-msgno = 398.
        wa_log-msgty = messtab-msgtyp.
        MESSAGE ID messtab-msgid TYPE messtab-msgtyp
        NUMBER messtab-msgnr
        WITH messtab-msgv1 messtab-msgv2 messtab-msgv3 messtab-msgv4
        INTO wa_log-msgv1.

        CONCATENATE 'Doc' wa_entrada-bukrs wa_entrada-belnr
                    wa_entrada-gjahr  wa_log-msgv1 INTO wa_log-msgv1
                    SEPARATED BY space.
        CONDENSE wa_log-msgv1.
        APPEND wa_log TO ti_log.
      ENDLOOP.
    ELSE.
      CLEAR wa_log.
      wa_log-msgid = '00'.
      wa_log-msgno = 398.
      wa_log-msgty = 'E'.
      CONCATENATE 'Doc' wa_entrada-bukrs wa_entrada-belnr
                  wa_entrada-gjahr 'no existe' INTO wa_log-msgv1
                  SEPARATED BY space.
      APPEND wa_log TO ti_log.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " PROCESAR_DATOS

*&---------------------------------------------------------------------*
*&      Form  bdc_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PROGRAM    text
*      -->DYNPRO     text
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  CLEAR bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval.
  APPEND bdcdata.
ENDFORM.                    "BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  MOSTRAR_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mostrar_log .
  DATA: lf_obj        TYPE balobj_d,
        lf_subobj     TYPE balsubobj,
        ls_header     TYPE balhdri,
        lf_log_handle TYPE balloghndl,
        lf_log_number TYPE balognr,
        lt_lognum     TYPE TABLE OF balnri,
        ls_lognum     TYPE balnri.

  lf_obj     = 'ZFI_LOG'.
  lf_subobj  = 'Z01'.

  ls_header-object     = lf_obj.
  ls_header-subobject  = lf_subobj.
  ls_header-aldate     = sy-datum.
  ls_header-altime     = sy-uzeit.
  ls_header-aluser     = sy-uname.
  ls_header-aldate_del = sy-datum + 1.

  CALL FUNCTION 'APPL_LOG_WRITE_HEADER'
    EXPORTING
      header              = ls_header
    IMPORTING
      e_log_handle        = lf_log_handle
    EXCEPTIONS
      object_not_found    = 1
      subobject_not_found = 2
      error               = 3
      OTHERS              = 4.

  IF sy-subrc EQ 0.
    CALL FUNCTION 'BAL_DB_LOGNUMBER_GET'
      EXPORTING
        i_client                 = sy-mandt
        i_log_handle             = lf_log_handle
      IMPORTING
        e_lognumber              = lf_log_number
      EXCEPTIONS
        log_not_found            = 1
        lognumber_already_exists = 2
        numbering_error          = 3
        OTHERS                   = 4.
    IF sy-subrc EQ 0.
      CALL FUNCTION 'APPL_LOG_WRITE_MESSAGES'
        EXPORTING
          object              = lf_obj
          subobject           = lf_subobj
          log_handle          = lf_log_handle
        TABLES
          messages            = ti_log
        EXCEPTIONS
          object_not_found    = 1
          subobject_not_found = 2
          OTHERS              = 3.

      MOVE-CORRESPONDING ls_header TO ls_lognum.
      ls_lognum-lognumber = lf_log_number.
      APPEND ls_lognum TO lt_lognum.

      CALL FUNCTION 'APPL_LOG_WRITE_DB'
        EXPORTING
          object                = lf_obj
          subobject             = lf_subobj
          log_handle            = lf_log_handle
        TABLES
          object_with_lognumber = lt_lognum
        EXCEPTIONS
          object_not_found      = 1
          subobject_not_found   = 2
          internal_error        = 3
          OTHERS                = 4.

      CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'.
    ENDIF.
  ENDIF.
ENDFORM.                    " MOSTRAR_LOG
