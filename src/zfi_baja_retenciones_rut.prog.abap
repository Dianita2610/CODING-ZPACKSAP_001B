*&---------------------------------------------------------------------*
*&  Include           ZFI_BAJA_RETENCIONES_RUT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  OBTENER_DATOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM obtener_datos .

  SELECT bukrs belnr gjahr xblnr blart budat
    INTO TABLE ti_bkpf
    FROM bkpf
    WHERE bukrs IN s_bukrs
      AND belnr IN s_belnr
      AND gjahr IN s_gjahr
      AND budat IN s_budat
      AND blart IN s_blart.
  IF sy-subrc EQ 0.
    SELECT *
      INTO TABLE ti_with_item
      FROM with_item
      FOR ALL ENTRIES IN ti_bkpf
      WHERE bukrs EQ ti_bkpf-bukrs
        AND belnr EQ ti_bkpf-belnr
        AND gjahr EQ ti_bkpf-gjahr
        AND koart EQ 'K'.
    IF sy-subrc EQ 0.
      SELECT lifnr stcd1
        INTO TABLE ti_lfa1
        FROM lfa1
        FOR ALL ENTRIES IN ti_with_item
        WHERE lifnr EQ ti_with_item-wt_acco.
      IF sy-subrc EQ 0.
        SORT ti_lfa1 BY lifnr.
        LOOP AT ti_bkpf INTO wa_bkpf.
          LOOP AT ti_with_item INTO wa_with_item
            WHERE bukrs = wa_bkpf-bukrs
              AND belnr = wa_bkpf-belnr
              AND gjahr = wa_bkpf-gjahr.
            MOVE-CORRESPONDING wa_bkpf TO wa_salida.
            MOVE-CORRESPONDING wa_with_item TO wa_salida.

            READ TABLE ti_lfa1 INTO wa_lfa1
            WITH KEY lifnr = wa_with_item-wt_acco BINARY SEARCH.
            IF sy-subrc EQ 0.
              wa_salida-stcd1 = wa_lfa1-stcd1.
            ENDIF.
            APPEND wa_salida TO ti_salida.
            CLEAR wa_salida.
          ENDLOOP.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " OBTENER_DATOS
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
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command = 'USER_COMMAND'
      is_layout               = gs_layout
      it_fieldcat             = gt_fieldcat[]
      i_default               = 'X'
      i_save                  = 'A'
      it_events               = gt_events[]
    TABLES
      t_outtab                = ti_salida[]
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
      i_internal_tabname     = 'T_SALIDA'
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
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.
  CASE r_ucomm.
    WHEN '&IC1'.
      CHECK NOT rs_selfield-value IS INITIAL.
* Determinar la linea elegida
      CLEAR wa_salida.
      READ TABLE ti_salida INDEX rs_selfield-tabindex INTO wa_salida.

      IF sy-subrc EQ 0.
        SET PARAMETER ID 'BLN' FIELD wa_salida-belnr.
        SET PARAMETER ID 'BUK' FIELD wa_salida-bukrs.
        SET PARAMETER ID 'GJR' FIELD wa_salida-gjahr.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'FC01'.
      PERFORM bajar_archivo.
    WHEN OTHERS.

  ENDCASE.
ENDFORM.                    "USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  pf_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->CE_FUNC_EXCLUDE  text
*----------------------------------------------------------------------*
FORM pf_status USING ce_func_exclude TYPE slis_t_extab.
  DATA : fcode_attrib_tab LIKE smp_dyntxt OCCURS 4 WITH HEADER LINE.
*
  CLEAR: fcode_attrib_tab, fcode_attrib_tab[].
*
  fcode_attrib_tab-text      = 'Baja datos'.
  fcode_attrib_tab-icon_id   = '@01@'.
  fcode_attrib_tab-icon_text = 'Baja datos'.
  fcode_attrib_tab-quickinfo = space.
  fcode_attrib_tab-path      = space.
  APPEND fcode_attrib_tab.

  PERFORM dynamic_report_fcodes(rhteiln0) TABLES fcode_attrib_tab
                                          USING  ce_func_exclude
                                                 ' ' ' '.
  SET PF-STATUS 'ALVLIST' EXCLUDING ce_func_exclude
                                              OF PROGRAM 'RHTEILN0'.
ENDFORM.                    "PF_STATUS
*&---------------------------------------------------------------------*
*&      Form  BAJAR_ARCHIVO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bajar_archivo .
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                        = fichero
*     FILETYPE                        = 'ASC'
      write_field_separator           = 'X'
*   IMPORTING
*     FILELENGTH                      =
    TABLES
      data_tab                        = ti_salida
   EXCEPTIONS
     file_write_error                = 1
     no_batch                        = 2
     gui_refuse_filetransfer         = 3
     invalid_type                    = 4
     no_authority                    = 5
     unknown_error                   = 6
     header_not_allowed              = 7
     separator_not_allowed           = 8
     filesize_not_allowed            = 9
     header_too_long                 = 10
     dp_error_create                 = 11
     dp_error_send                   = 12
     dp_error_write                  = 13
     unknown_dp_error                = 14
     access_denied                   = 15
     dp_out_of_memory                = 16
     disk_full                       = 17
     dp_timeout                      = 18
     file_not_found                  = 19
     dataprovider_exception          = 20
     control_flush_error             = 21
     OTHERS                          = 22 .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " BAJAR_ARCHIVO
