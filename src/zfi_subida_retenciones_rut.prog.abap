*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <27-12-2019> *
*& Transport Number: < ECDK917004 > *
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
    DATA: tab TYPE c,
          gato TYPE fist-searchw.
    DATA: cadena TYPE string.
    tab = cl_abap_char_utilities=>horizontal_tab.
    OPEN DATASET strarq FOR INPUT IN TEXT MODE ENCODING NON-UNICODE.
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
                                   ti_entrada-witht
                                   ti_entrada-wt_withcd
                                   ti_entrada-wt_qsshh
                                   ti_entrada-wt_qsshb
                                   ti_entrada-wt_qssh2
                                   ti_entrada-wt_qssh3
                                   ti_entrada-wt_basman
                                   ti_entrada-wt_qsshhc
                                   ti_entrada-wt_qsshbc
                                   ti_entrada-wt_qssh2c
                                   ti_entrada-wt_qssh3c
                                   ti_entrada-wt_qbshh
                                   ti_entrada-wt_qbshb
                                   ti_entrada-wt_qbsh2
                                   ti_entrada-wt_qbsh3
                                   ti_entrada-wt_amnman
                                   ti_entrada-wt_qbshha
                                   ti_entrada-wt_qbshhb
                                   ti_entrada-wt_stat
                                   ti_entrada-wt_qsfhh
                                   ti_entrada-wt_qsfhb
                                   ti_entrada-wt_qsfh2
                                   ti_entrada-wt_qsfh3
                                   ti_entrada-wt_wtexmn
                                   ti_entrada-koart
                                   ti_entrada-wt_acco
                                   ti_entrada-hkont
                                   ti_entrada-hkont_opp
                                   ti_entrada-qsrec
                                   ti_entrada-augbl
                                   ti_entrada-augdt
                                   ti_entrada-wt_qszrt
                                   ti_entrada-wt_wdmbtr
                                   ti_entrada-wt_wwrbtr
                                   ti_entrada-wt_wdmbt2
                                   ti_entrada-wt_wdmbt3
                                   ti_entrada-text15
                                   ti_entrada-wt_qbuihh
                                   ti_entrada-wt_qbuihb
                                   ti_entrada-wt_qbuih2
                                   ti_entrada-wt_qbuih3
                                   ti_entrada-wt_accbs
                                   ti_entrada-wt_accwt
                                   ti_entrada-wt_accwta
                                   ti_entrada-wt_accwtha
                                   ti_entrada-wt_accbs1
                                   ti_entrada-wt_accwt1
                                   ti_entrada-wt_accwta1
                                   ti_entrada-wt_accwtha1
                                   ti_entrada-wt_accbs2
                                   ti_entrada-wt_accwt2
                                   ti_entrada-wt_accwta2
                                   ti_entrada-wt_accwtha2
                                   ti_entrada-qsatz
                                   ti_entrada-wt_slfwtpd
                                   ti_entrada-wt_gruwtpd
                                   ti_entrada-wt_opowtpd
                                   ti_entrada-wt_givenpd
                                   ti_entrada-ctnumber
                                   ti_entrada-wt_downc
                                   ti_entrada-wt_resitem
                                   ti_entrada-ctissuedate
                                   ti_entrada-j_1bwhtcollcode
                                   ti_entrada-j_1bwhtrate
                                   ti_entrada-j_1bwht_bs
                                   ti_entrada-j_1bwhtaccbs
                                   ti_entrada-j_1bwhtaccbs1
                                   ti_entrada-j_1bwhtaccbs2
                                   ti_entrada-j_1iintchln
                                   ti_entrada-j_1iintchdt
                                   ti_entrada-j_1iewtrec
                                   ti_entrada-j_1ibuzei
                                   ti_entrada-j_1icertdt
                                   ti_entrada-j_1iclramt
                                   ti_entrada-j_1irebzg
                                   ti_entrada-j_1isuramt.

*          gato = ti_entrada-j_1isuramt.
*          CALL function 'SF_SPECIALCHAR_DELETE'
*            exporting
*              WITH_SPECIALCHAR    = GATO
*            importing
*              WITHOUT_SPECIALCHAR = GATO.
*          ti_entrada-j_1isuramt = gato.
          CLEAR ti_entrada-j_1isuramt.
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
         END OF t_bseg.

  TYPES: BEGIN OF t_lfa1,
            lifnr TYPE lfa1-lifnr,
            stcd1 TYPE lfa1-stcd1,
         END OF t_lfa1.

  DATA: ti_lfa1 TYPE TABLE OF t_lfa1,
        ti_bkpf TYPE TABLE OF t_bkpf,
        ti_bseg TYPE TABLE OF t_bseg,
        wa_bseg TYPE t_bseg,
        wa_bkpf TYPE t_bkpf,
        wa_lfa1 TYPE t_lfa1.

  SELECT lifnr stcd1
    INTO TABLE ti_lfa1
    FROM lfa1
    FOR ALL ENTRIES IN ti_entrada
    WHERE stcd1 EQ ti_entrada-stcd1.
  IF sy-subrc EQ 0.
    SORT ti_lfa1 BY stcd1.
    LOOP AT ti_entrada.
      READ TABLE ti_lfa1 INTO wa_lfa1 WITH KEY stcd1 = ti_entrada-stcd1
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        ti_entrada-wt_acco = wa_lfa1-lifnr.
        MODIFY ti_entrada.
      ENDIF.
    ENDLOOP.
  ENDIF.

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
  IF sy-subrc EQ 0.
    SELECT bukrs belnr gjahr buzei lifnr
      INTO TABLE ti_bseg
      FROM bseg
      FOR ALL ENTRIES IN ti_bkpf
      WHERE bukrs EQ ti_bkpf-bukrs
        AND belnr EQ ti_bkpf-belnr
        AND gjahr EQ ti_bkpf-gjahr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK917004*
*        AND koart EQ 'K'.
        AND koart EQ 'K' ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK917004*
    IF sy-subrc EQ 0.
      SORT ti_lfa1 BY lifnr.
      LOOP AT ti_bkpf INTO wa_bkpf.
        LOOP AT ti_bseg INTO wa_bseg WHERE bukrs EQ wa_bkpf-bukrs
                                       AND belnr EQ wa_bkpf-belnr
                                       AND gjahr EQ wa_bkpf-gjahr.
          READ TABLE ti_lfa1 INTO wa_lfa1
          WITH KEY lifnr = wa_bseg-lifnr BINARY SEARCH.
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
                                 AND wt_acco = wa_bseg-lifnr.
              ti_entrada-belnr = wa_bkpf-belnr.
              ti_entrada-gjahr = wa_bkpf-gjahr.
              ti_entrada-bukrs = wa_bkpf-bukrs.
              CLEAR wa_with_item.
              MOVE-CORRESPONDING ti_entrada TO wa_with_item.
              wa_with_item-mandt = sy-mandt.
              APPEND wa_with_item TO ti_with_item.
            ENDLOOP.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
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
      t_outtab                = ti_with_item[]
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
      i_structure_name       = 'WITH_ITEM'
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
