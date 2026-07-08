*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFI_SUBIDA_IMPUESTOS_RUT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFI_SUBIDA_RETENCIONES_RUT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  BAJAR_ARCHIVO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bajar_archivo .
  DATA: strarq       TYPE string.
  IF NOT p_local IS INITIAL.
    strarq = fichero.

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
  ELSE.
    strarq = servidor.
    DATA: tab TYPE c.
    DATA: cadena TYPE string.
    tab = cl_abap_char_utilities=>horizontal_tab.
    OPEN DATASET strarq FOR INPUT ENCODING DEFAULT IN TEXT MODE.
    IF sy-subrc EQ 0.
      DO.
        READ DATASET strarq INTO cadena.
        IF sy-subrc EQ 0.
          CLEAR ti_entrada.
          SPLIT cadena AT tab INTO ti_entrada-blart
                                   ti_entrada-xblnr
                                   ti_entrada-stcd1
                                   ti_entrada-budat
                                   ti_entrada-mandt
                                   ti_entrada-bukrs
                                   ti_entrada-belnr
                                   ti_entrada-gjahr
                                   ti_entrada-buzei
                                   ti_entrada-mwskz
                                   ti_entrada-hkont
                                   ti_entrada-txgrp
                                   ti_entrada-shkzg
                                   ti_entrada-hwbas
                                   ti_entrada-fwbas
                                   ti_entrada-hwste
                                   ti_entrada-fwste
                                   ti_entrada-ktosl
                                   ti_entrada-knumh
                                   ti_entrada-stceg
                                   ti_entrada-egbld
                                   ti_entrada-eglld
                                   ti_entrada-txjcd
                                   ti_entrada-h2ste
                                   ti_entrada-h3ste
                                   ti_entrada-h2bas
                                   ti_entrada-h3bas
                                   ti_entrada-kschl
                                   ti_entrada-stmdt
                                   ti_entrada-stmti
                                   ti_entrada-mlddt
                                   ti_entrada-kbetr
                                   ti_entrada-stbkz
                                   ti_entrada-lstml
                                   ti_entrada-lwste
                                   ti_entrada-lwbas
                                   ti_entrada-txdat
                                   ti_entrada-bupla
                                   ti_entrada-txjdp
                                   ti_entrada-txjlv
                                   ti_entrada-taxps
                                   ti_entrada-txmod.

          CLEAR ti_entrada-txmod.
          APPEND ti_entrada.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDIF.
ENDFORM.                    " BAJAR_ARCHIVO
*&---------------------------------------------------------------------*
*&      Form  LLENAR_TABLA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM llenar_tabla .
  TYPES: BEGIN OF t_bkpf,
           bukrs TYPE bkpf-bukrs,
           belnr TYPE bkpf-belnr,
           gjahr TYPE bkpf-gjahr,
           blart TYPE bkpf-blart,
           budat TYPE bkpf-budat,
           xblnr TYPE bkpf-xblnr,
         END OF t_bkpf.

  TYPES: BEGIN OF t_bseg,
          bukrs TYPE bseg-bukrs,
          belnr TYPE bseg-belnr,
          gjahr TYPE bseg-gjahr,
          buzei TYPE bseg-buzei,
          lifnr TYPE bseg-lifnr,
          kunnr TYPE bseg-kunnr,
         END OF t_bseg.

  TYPES: BEGIN OF t_lfa1,
            lifnr TYPE lfa1-lifnr,
            stcd1 TYPE lfa1-stcd1,
            koart TYPE bseg-koart,
         END OF t_lfa1.

  DATA: ti_lfa1 TYPE TABLE OF t_lfa1,
        ti_bkpf TYPE TABLE OF t_bkpf,
        ti_bseg TYPE TABLE OF t_bseg,
        wa_bseg TYPE t_bseg,
        wa_bkpf TYPE t_bkpf,
        wa_lfa1 TYPE t_lfa1.
  DATA: v_doc TYPE lfa1-lifnr.

  SELECT lifnr stcd1
    INTO TABLE ti_lfa1
    FROM lfa1
    FOR ALL ENTRIES IN ti_entrada
    WHERE stcd1 EQ ti_entrada-stcd1.

  LOOP AT ti_lfa1 INTO wa_lfa1.
    wa_lfa1-koart = 'K'.
    MODIFY ti_lfa1 FROM wa_lfa1 INDEX sy-tabix.
  ENDLOOP.

  SELECT kunnr stcd1
    APPENDING TABLE ti_lfa1
    FROM kna1
    FOR ALL ENTRIES IN ti_entrada
    WHERE stcd1 EQ ti_entrada-stcd1.

  SORT ti_lfa1 BY stcd1 koart.
  LOOP AT ti_entrada.
    READ TABLE ti_lfa1 INTO wa_lfa1 WITH KEY stcd1 = ti_entrada-stcd1
                                             koart = 'K'
                                             BINARY SEARCH.
    IF sy-subrc NE 0.
      READ TABLE ti_lfa1 INTO wa_lfa1 WITH KEY stcd1 = ti_entrada-stcd1
                                             koart = space
                                             BINARY SEARCH.
    ENDIF.
    IF sy-subrc EQ 0.
      ti_entrada-lifnr = wa_lfa1-lifnr.
      MODIFY ti_entrada.
    ENDIF.
  ENDLOOP.

  IF s_belnr IS INITIAL AND
     s_bukrs IS INITIAL AND
     s_gjahr IS INITIAL.
    SELECT bukrs belnr gjahr blart budat xblnr
   INTO TABLE ti_bkpf
   FROM bkpf
   FOR ALL ENTRIES IN ti_entrada
   WHERE bukrs EQ ti_entrada-bukrs
     AND gjahr EQ ti_entrada-gjahr
     AND xblnr EQ ti_entrada-xblnr
     AND blart EQ ti_entrada-blart
     AND budat EQ ti_entrada-budat
     AND stblg EQ space.
  ELSE.
    SELECT bukrs belnr gjahr blart budat xblnr
      INTO TABLE ti_bkpf
      FROM bkpf
      WHERE bukrs IN s_bukrs
        AND belnr IN s_belnr
        AND gjahr IN s_gjahr
        AND stblg EQ space.
    IF sy-subrc EQ 0.
***Borramos los que no corresponden al archivo.
      LOOP AT ti_bkpf INTO wa_bkpf.
        READ TABLE ti_entrada WITH KEY bukrs = wa_bkpf-bukrs
                                       gjahr = wa_bkpf-gjahr
                                       xblnr = wa_bkpf-xblnr
                                       budat = wa_bkpf-budat
                                       blart = wa_bkpf-blart.
        IF sy-subrc NE 0.
          DELETE ti_bkpf WHERE bukrs = wa_bkpf-bukrs
                           AND belnr = wa_bkpf-belnr
                           AND gjahr = wa_bkpf-gjahr.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.


  CHECK NOT ti_bkpf[] IS INITIAL.
SELECT bukrs belnr gjahr buzei lifnr kunnr
INTO TABLE ti_bseg
FROM bseg
FOR ALL ENTRIES IN ti_bkpf
WHERE bukrs EQ ti_bkpf-bukrs
AND belnr EQ ti_bkpf-belnr
AND gjahr EQ ti_bkpf-gjahr
AND ( koart EQ 'K' OR
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*koart EQ 'D' ).
KOART EQ 'D' ) ORDER BY PRIMARY KEY .
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
  IF sy-subrc EQ 0.
    SORT ti_lfa1 BY lifnr.
    LOOP AT ti_bkpf INTO wa_bkpf.
      LOOP AT ti_bseg INTO wa_bseg WHERE bukrs EQ wa_bkpf-bukrs
                                     AND belnr EQ wa_bkpf-belnr
                                     AND gjahr EQ wa_bkpf-gjahr.
        CLEAR wa_lfa1.
        READ TABLE ti_lfa1 INTO wa_lfa1
        WITH KEY lifnr = wa_bseg-lifnr BINARY SEARCH.
        IF sy-subrc NE 0.
          READ TABLE ti_lfa1 INTO wa_lfa1
                    WITH KEY lifnr = wa_bseg-kunnr BINARY SEARCH.
        ENDIF.

        IF sy-subrc NE 0.
          DELETE ti_bseg WHERE bukrs EQ wa_bkpf-bukrs
                           AND belnr EQ wa_bkpf-belnr
                           AND gjahr EQ wa_bkpf-gjahr.

          DELETE ti_bkpf WHERE bukrs EQ wa_bkpf-bukrs
                           AND belnr EQ wa_bkpf-belnr
                           AND gjahr EQ wa_bkpf-gjahr.
        ELSE.
          CLEAR ti_entrada.
          LOOP AT ti_entrada WHERE bukrs = wa_bkpf-bukrs
                               AND gjahr = wa_bkpf-gjahr
                               AND blart = wa_bkpf-blart
                               AND budat = wa_bkpf-budat
                               AND xblnr = wa_bkpf-xblnr
                               AND lifnr = wa_lfa1-lifnr.
            ti_entrada-belnr = wa_bkpf-belnr.
            ti_entrada-gjahr = wa_bkpf-gjahr.
            ti_entrada-bukrs = wa_bkpf-bukrs.
            CLEAR wa_bset.
            MOVE-CORRESPONDING ti_entrada TO wa_bset.
            wa_bset-mandt = sy-mandt.
            APPEND wa_bset TO ti_bset.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " LLENAR_TABLA
*&---------------------------------------------------------------------*
*&      Form  MOSTRAR_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mostrar_alv .
  PERFORM init_fieldcat.
  PERFORM layout.
  PERFORM eventos CHANGING gt_events[].
  PERFORM comment_build_01 USING gt_list_top_of_page.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = g_repid
*      i_callback_pf_status_set = 'PF_STATUS'
*      i_callback_user_command = 'USER_COMMAND'
      is_layout               = gs_layout
      it_fieldcat             = gt_fieldcat[]
      i_default               = 'X'
      i_save                  = 'A'
      it_events               = gt_events[]
    TABLES
      t_outtab                = ti_bset[]
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
ENDFORM.                    " MOSTRAR_ALV

*----------------------------------------------------------------------*
FORM layout .
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-zebra             = 'X'.
ENDFORM.                    " LAYOUT
*&---------------------------------------------------------------------*
*&      Form  EVENTOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
FORM eventos  CHANGING pgt_events TYPE slis_t_event.
  CONSTANTS:
    gc_formname_top_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE_01'.

  DATA: ls_event TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = pgt_events.

  READ TABLE pgt_events WITH KEY name = slis_ev_top_of_page
             INTO ls_event.

  IF sy-subrc = 0.
    MOVE gc_formname_top_of_page TO ls_event-form.
    APPEND ls_event TO pgt_events.
  ENDIF.
ENDFORM.                    " EVENTOS
*&---------------------------------------------------------------------*
*&      Form  comment_build_01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LT_TOP_OF_PAGE  text
*----------------------------------------------------------------------*
FORM comment_build_01 USING lt_top_of_page TYPE slis_t_listheader.

  DATA: ls_line TYPE slis_listheader,
        fecha(10) TYPE c.

  REFRESH: lt_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key  = 'Titulo :'.
  ls_line-info = sy-title.
  APPEND ls_line TO lt_top_of_page.

  IF p_test IS INITIAL.
    CLEAR ls_line.
    ls_line-typ  = 'S'.
    ls_line-key  = 'Modo :'.
    ls_line-info = 'Real'.
    APPEND ls_line TO lt_top_of_page.
  ELSE.
    CLEAR ls_line.
    ls_line-typ  = 'S'.
    ls_line-key  = 'Modo :'.
    ls_line-info = 'Test'.
    APPEND ls_line TO lt_top_of_page.
  ENDIF.
ENDFORM.                    "comment_build_01
*&---------------------------------------------------------------------*
*&      Form  top_of_page_01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM top_of_page_01.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_list_top_of_page.
ENDFORM.                    "TOP_OF_PAGE_01
*&---------------------------------------------------------------------*
*&      Form  INIT_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_fieldcat .
  REFRESH gt_fieldcat.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = g_repid
      i_structure_name       = 'BSET'
*      i_internal_tabname     = 'T_SALIDA'
      i_inclname             = g_repid
    CHANGING
      ct_fieldcat            = gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
ENDFORM.                    "init_fieldcat

*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
*FORM user_command USING r_ucomm     LIKE sy-ucomm
*                        rs_selfield TYPE slis_selfield.
*  CASE r_ucomm.
*    WHEN '&IC1'.
*      CHECK NOT rs_selfield-value IS INITIAL.
** Determinar la linea elegida
*      CLEAR wa_salida.
*      READ TABLE ti_salida INDEX rs_selfield-tabindex INTO wa_salida.
*
*      IF sy-subrc EQ 0.
*        SET PARAMETER ID 'BLN' FIELD wa_salida-belnr.
*        SET PARAMETER ID 'BUK' FIELD wa_salida-bukrs.
*        SET PARAMETER ID 'GJR' FIELD wa_salida-gjahr.
*        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
*      ENDIF.
*
*    WHEN 'FC01'.
*      PERFORM bajar_archivo.
*    WHEN OTHERS.
*
*  ENDCASE.
*ENDFORM.                    "USER_COMMAND
