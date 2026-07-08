*&---------------------------------------------------------------------*
*&  Include           ZFI_ACTUALIZA_REGUH_RUT
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
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

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
          SPLIT cadena AT tab INTO ti_entrada-fecha
                                   ti_entrada-laufi
                                   ti_entrada-zbukr
                                   ti_entrada-lifnr
                                   ti_entrada-vblnr
                                   ti_entrada-id_pago.
          APPEND ti_entrada.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDIF.

  IF NOT ti_entrada[] IS INITIAL.
    LOOP AT ti_entrada.
      CLEAR wa_salida.
      MOVE-CORRESPONDING ti_entrada TO wa_salida.
      CONCATENATE ti_entrada-fecha+6(4)  "DD.Mm.yyyy
                  ti_entrada-fecha+3(2)
                  ti_entrada-fecha(2)
                  INTO wa_salida-laufd.
      APPEND wa_salida TO ti_salida.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " BAJAR_ARCHIVO
*&---------------------------------------------------------------------*
*&      Form  BUSCAR_DATOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM buscar_datos .
  SELECT *
    INTO TABLE ti_reguh
    FROM reguh
    FOR ALL ENTRIES IN ti_salida
    WHERE laufd EQ ti_salida-laufd
      AND laufi EQ ti_salida-laufi
      AND zbukr EQ ti_salida-zbukr
      AND lifnr EQ ti_salida-lifnr
      AND vblnr EQ ti_salida-vblnr.
  IF sy-subrc EQ 0.
    SORT ti_salida BY laufd laufi zbukr lifnr vblnr.
    LOOP AT ti_reguh ASSIGNING <fs>.
      READ TABLE ti_salida INTO wa_salida WITH KEY laufd = <fs>-laufd
                                                   laufi = <fs>-laufi
                                                   zbukr = <fs>-zbukr
                                                   lifnr = <fs>-lifnr
                                                   vblnr = <fs>-vblnr
                                                   BINARY SEARCH.
      IF sy-subrc EQ 0.
        <fs>-identif_pago = wa_salida-id_pago.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " BUSCAR_DATOS
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
      i_structure_name       = 'REGUH'
      i_inclname             = g_repid
    CHANGING
      ct_fieldcat            = gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
ENDFORM.                    "init_fieldcat
