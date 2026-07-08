*&---------------------------------------------------------------------*
*&  Include           ZFI_ACTUALIZA_REGUH_REGUP_RUT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CARGAR_ARCHIVO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cargar_archivo .
  DATA: strarq       TYPE string.
  IF p_regup IS INITIAL.
    strarq = fichero.
    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename                = strarq
        filetype                = 'ASC'
        has_field_separator     = 'X'
      TABLES
        data_tab                = ti_aux_reguh
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
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      LOOP AT ti_aux_reguh INTO wa_aux_reguh.
        MOVE-CORRESPONDING wa_aux_reguh TO wa_reguh.
        wa_reguh-mandt = sy-mandt.
        CLEAR : wa_reguh-laufd, wa_reguh-zaldt, wa_reguh-valut,
                wa_reguh-ausfd, wa_reguh-fecha_envio,
                wa_reguh-fecha_pago, wa_reguh-fecha_devuelto,
                wa_reguh-fecha_rechazo, wa_reguh-fecha_custodia,
                wa_reguh-fecha_entregado, wa_reguh-fecha_rescatado.

        PERFORM formato_fecha USING wa_aux_reguh-laufd
                              CHANGING wa_reguh-laufd.

        PERFORM formato_fecha USING wa_aux_reguh-zaldt
                              CHANGING wa_reguh-zaldt.

        PERFORM formato_fecha USING wa_aux_reguh-valut
                      CHANGING wa_reguh-valut.

        PERFORM formato_fecha USING wa_aux_reguh-anfae
                              CHANGING wa_reguh-anfae.

        PERFORM formato_fecha USING wa_aux_reguh-wefae
                              CHANGING wa_reguh-wefae.

        PERFORM formato_fecha USING wa_aux_reguh-ausfd
                      CHANGING wa_reguh-ausfd.

        PERFORM formato_fecha USING wa_aux_reguh-fecha_envio
                      CHANGING wa_reguh-fecha_envio.

        PERFORM formato_fecha USING wa_aux_reguh-fecha_pago
                      CHANGING wa_reguh-fecha_pago.

        PERFORM formato_fecha USING wa_aux_reguh-fecha_devuelto
                      CHANGING wa_reguh-fecha_devuelto.

        PERFORM formato_fecha USING wa_aux_reguh-fecha_rechazo
                      CHANGING wa_reguh-fecha_rechazo.

        PERFORM formato_fecha USING wa_aux_reguh-fecha_custodia
                      CHANGING wa_reguh-fecha_custodia.

        PERFORM formato_fecha USING wa_aux_reguh-fecha_entregado
                      CHANGING wa_reguh-fecha_entregado.

        PERFORM formato_fecha USING wa_aux_reguh-fecha_rescatado
              CHANGING wa_reguh-fecha_rescatado.

        APPEND wa_reguh TO ti_reguh.
      ENDLOOP.
    ENDIF.
  ELSE.
    strarq = fichero.
    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename                = strarq
        filetype                = 'ASC'
        has_field_separator     = 'X'
      TABLES
        data_tab                = ti_aux_regup
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
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      LOOP AT ti_aux_regup INTO wa_aux_regup.
        MOVE-CORRESPONDING wa_aux_regup TO wa_regup.
        CLEAR: wa_regup-laufd, wa_regup-zfbdt, wa_regup-bldat,
               wa_regup-budat.

        PERFORM formato_fecha USING wa_aux_regup-laufd
                              CHANGING wa_regup-laufd.

        PERFORM formato_fecha USING wa_aux_regup-budat
                              CHANGING wa_regup-budat.

        PERFORM formato_fecha USING wa_aux_regup-bldat
                      CHANGING wa_regup-bldat.

        PERFORM formato_fecha USING wa_aux_regup-zfbdt
                      CHANGING wa_regup-zfbdt.

        wa_regup-mandt = sy-mandt.

        APPEND wa_regup TO ti_regup.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " CARGAR_ARCHIVO
*&---------------------------------------------------------------------*
*&      Form  FORMATO_FECHA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_AUX_REGUH_LAUFD  text
*      <--P_WA_REGUH_LAUFD  text
*----------------------------------------------------------------------*
FORM formato_fecha  USING    p_fecha_ini
                    CHANGING p_fecha_fin.

  CHECK NOT p_fecha_ini IS INITIAL.
  CONCATENATE p_fecha_ini+6(4)
              p_fecha_ini+3(2)
              p_fecha_ini(2)
              INTO p_fecha_fin.

ENDFORM.                    " FORMATO_FECHA
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

  IF NOT p_reguh IS INITIAL.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program = g_repid
        is_layout          = gs_layout
        it_fieldcat        = gt_fieldcat[]
        i_default          = 'X'
        i_save             = 'A'
        it_events          = gt_events[]
      TABLES
        t_outtab           = ti_reguh[]
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
  ELSE.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program = g_repid
        is_layout          = gs_layout
        it_fieldcat        = gt_fieldcat[]
        i_default          = 'X'
        i_save             = 'A'
        it_events          = gt_events[]
      TABLES
        t_outtab           = ti_regup[]
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
  ENDIF.
ENDFORM.                    " MOSTRAR_ALV


*&---------------------------------------------------------------------*
*&      Form  layout
*&---------------------------------------------------------------------*
*       text
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
  ls_line-typ  = 'H'.
  ls_line-key  = 'Titulo :'.
  ls_line-info = sy-title.
  APPEND ls_line TO lt_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key  = 'Tabla :'.
  IF NOT p_reguh IS INITIAL.
    ls_line-info = 'REGUH'.
  ELSE.
    ls_line-info = 'REGUP'.
  ENDIF.
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
  IF NOT p_reguh IS INITIAL.
    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        i_program_name         = g_repid
        i_structure_name       = 'REGUH'
        i_inclname             = g_repid
      CHANGING
        ct_fieldcat            = gt_fieldcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
  ELSE.
    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        i_program_name         = g_repid
        i_structure_name       = 'REGUP'
        i_inclname             = g_repid
      CHANGING
        ct_fieldcat            = gt_fieldcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
  ENDIF.
ENDFORM.                    "init_fieldcat
