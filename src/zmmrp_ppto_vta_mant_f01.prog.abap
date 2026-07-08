*&---------------------------------------------------------------------*
*&  Include           ZMMRP_PPTO_VTA_MANT_F01
*&---------------------------------------------------------------------*

FORM carga_datos_tabla.

  SELECT * INTO TABLE gt_zmm_ppto_vta FROM zmm_ppto_vta.

  CLEAR zmm_ppto_vta.

ENDFORM.                    " carga_datos_tabla

*&---------------------------------------------------------------------*
*&      Form  fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fieldcat.

  CLEAR gt_fieldcat.
  gt_fieldcat-tabname    = 'GT_ZMM_PPTO_VTA'.
  gt_fieldcat-fieldname  = 'MATNR'.
  gt_fieldcat-coltext    = 'Material'.
  gt_fieldcat-outputlen  = '12'.
  APPEND gt_fieldcat.

  CLEAR gt_fieldcat.
  gt_fieldcat-tabname    = 'GT_ZMM_PPTO_VTA'.
  gt_fieldcat-fieldname  = 'ZVERSION'.
  gt_fieldcat-coltext    = 'Versión'.
  gt_fieldcat-outputlen  = '8'.
  APPEND gt_fieldcat.

  CLEAR gt_fieldcat.
  gt_fieldcat-tabname    = 'GT_ZMM_PPTO_VTA'.
  gt_fieldcat-fieldname  = 'WERKS'.
  gt_fieldcat-coltext    = 'Centro'.
  gt_fieldcat-outputlen  = '8'.
  APPEND gt_fieldcat.

  CLEAR gt_fieldcat.
  gt_fieldcat-tabname    = 'GT_ZMM_PPTO_VTA'.
  gt_fieldcat-fieldname  = 'GJAHR'.
  gt_fieldcat-coltext    = 'Ejercicio'.
  gt_fieldcat-outputlen  = '6'.
  APPEND gt_fieldcat.

  CLEAR gt_fieldcat.
  gt_fieldcat-tabname    = 'GT_ZMM_PPTO_VTA'.
  gt_fieldcat-fieldname  = 'MONTH01'.
  gt_fieldcat-coltext    = 'Enero'.
  gt_fieldcat-outputlen  = '17'.
  APPEND gt_fieldcat.

  CLEAR gt_fieldcat.
  gt_fieldcat-tabname    = 'GT_ZMM_PPTO_VTA'.
  gt_fieldcat-fieldname  = 'MONTH02'.
  gt_fieldcat-coltext    = 'Febrero'.
  gt_fieldcat-outputlen  = '17'.
  APPEND gt_fieldcat.

  CLEAR gt_fieldcat.
  gt_fieldcat-tabname    = 'GT_ZMM_PPTO_VTA'.
  gt_fieldcat-fieldname  = 'MONTH03'.
  gt_fieldcat-coltext    = 'Marzo'.
  gt_fieldcat-outputlen  = '17'.
  APPEND gt_fieldcat.

  CLEAR gt_fieldcat.
  gt_fieldcat-tabname    = 'GT_ZMM_PPTO_VTA'.
  gt_fieldcat-fieldname  = 'MONTH04'.
  gt_fieldcat-coltext    = 'Abril'.
  gt_fieldcat-outputlen  = '17'.
  APPEND gt_fieldcat.

  CLEAR gt_fieldcat.
  gt_fieldcat-tabname    = 'GT_ZMM_PPTO_VTA'.
  gt_fieldcat-fieldname  = 'MONTH05'.
  gt_fieldcat-coltext    = 'Mayo'.
  gt_fieldcat-outputlen  = '17'.
  APPEND gt_fieldcat.

  CLEAR gt_fieldcat.
  gt_fieldcat-tabname    = 'GT_ZMM_PPTO_VTA'.
  gt_fieldcat-fieldname  = 'MONTH06'.
  gt_fieldcat-coltext    = 'Junio'.
  gt_fieldcat-outputlen  = '17'.
  APPEND gt_fieldcat.

  CLEAR gt_fieldcat.
  gt_fieldcat-tabname    = 'GT_ZMM_PPTO_VTA'.
  gt_fieldcat-fieldname  = 'MONTH07'.
  gt_fieldcat-coltext    = 'Julio'.
  gt_fieldcat-outputlen  = '17'.
  APPEND gt_fieldcat.

  CLEAR gt_fieldcat.
  gt_fieldcat-tabname    = 'GT_ZMM_PPTO_VTA'.
  gt_fieldcat-fieldname  = 'MONTH08'.
  gt_fieldcat-coltext    = 'Agosto'.
  gt_fieldcat-outputlen  = '17'.
  APPEND gt_fieldcat.

  CLEAR gt_fieldcat.
  gt_fieldcat-tabname    = 'GT_ZMM_PPTO_VTA'.
  gt_fieldcat-fieldname  = 'MONTH09'.
  gt_fieldcat-coltext    = 'Septiembre'.
  gt_fieldcat-outputlen  = '17'.
  APPEND gt_fieldcat.

  CLEAR gt_fieldcat.
  gt_fieldcat-tabname    = 'GT_ZMM_PPTO_VTA'.
  gt_fieldcat-fieldname  = 'MONTH10'.
  gt_fieldcat-coltext    = 'Octubre'.
  gt_fieldcat-outputlen  = '17'.
  APPEND gt_fieldcat.

  CLEAR gt_fieldcat.
  gt_fieldcat-tabname    = 'GT_ZMM_PPTO_VTA'.
  gt_fieldcat-fieldname  = 'MONTH11'.
  gt_fieldcat-coltext    = 'Noviembre'.
  gt_fieldcat-outputlen  = '17'.
  APPEND gt_fieldcat.

  CLEAR gt_fieldcat.
  gt_fieldcat-tabname    = 'GT_ZMM_PPTO_VTA'.
  gt_fieldcat-fieldname  = 'MONTH12'.
  gt_fieldcat-coltext    = 'Diciembre'.
  gt_fieldcat-outputlen  = '17'.
  APPEND gt_fieldcat.

ENDFORM.                    " carga_especificaciones_campos

*&---------------------------------------------------------------------*
*&      Form  layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM layout.
  gs_layout-grid_title     =
              'Mantención Presupuesto de Ventas'.
  gs_layout-sel_mode       = 'D'.
  gs_layout-numc_total     = 'X'.
  gs_layout-info_fname     = 'COLOR'.
ENDFORM.                    "layout

*&---------------------------------------------------------------------*
*&      Form  built_container
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM built_container.
  IF go_custom_container IS INITIAL.

    CREATE OBJECT go_custom_container
      EXPORTING
        container_name = 'CONTAINER'.

    CREATE OBJECT go_grid
      EXPORTING
        i_parent = go_custom_container.
  ELSE.
    CALL METHOD go_grid->refresh_table_display.
  ENDIF.
ENDFORM.                    "built_container

*&---------------------------------------------------------------------*
*&      Form  set_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_table.

  CALL METHOD go_grid->set_table_for_first_display
    EXPORTING
      i_structure_name = 'GT_ZMM_PPTO_VTA'
      is_layout        = gs_layout
      i_save           = 'X'
    CHANGING
      it_fieldcatalog  = gt_fieldcat[]
      it_outtab        = gt_zmm_ppto_vta.

ENDFORM.                    "set_table

*&---------------------------------------------------------------------*
*&      Form  load_toolbar
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM load_toolbar.
  IF go_receiver IS INITIAL.
    CREATE OBJECT go_receiver.

    SET HANDLER go_receiver->handle_user_command FOR go_grid.

    SET HANDLER go_receiver->handle_toolbar      FOR go_grid.
    CALL METHOD go_grid->set_toolbar_interactive.
    CALL METHOD cl_gui_control=>set_focus
      EXPORTING
        control = go_grid.
  ENDIF.
ENDFORM.                    "load_toolbar
*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_input .
  IF zmm_ppto_vta-matnr IS INITIAL.
    PERFORM agrega_mensaje USING 'Ingrese Material' 'E'. MOVE '1' TO sw.
  ENDIF.
  IF zmm_ppto_vta-zversion IS INITIAL.
    PERFORM agrega_mensaje USING 'Ingrese Versión' 'E'. MOVE '1' TO sw.
  ENDIF.
  IF zmm_ppto_vta-werks IS INITIAL.
    PERFORM agrega_mensaje USING 'Ingrese Centro' 'E'. MOVE '1' TO sw.
  ENDIF.
  IF zmm_ppto_vta-gjahr IS INITIAL.
    PERFORM agrega_mensaje USING 'Ingrese Ejercicio' 'E'. MOVE '1' TO sw.
  ENDIF.
ENDFORM.                    " CHECK_INPUT

*&---------------------------------------------------------------------*
*&      Form  agrega_mensaje
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->VALUE(P_0445)  text
*      -->VALUE(TY)      text
*----------------------------------------------------------------------*
FORM agrega_mensaje USING value(p_0445) value(ty).

  pzeile = pzeile + 1.
  zeile = pzeile.
  CALL FUNCTION 'MESSAGE_STORE'
    EXPORTING
      arbgb                  = 'ZALL'
      msgty                  = ty
      msgv1                  = p_0445
      txtnr                  = '000'
      zeile                  = zeile
    EXCEPTIONS
      message_type_not_valid = 1
      not_active             = 2
      OTHERS                 = 3.

ENDFORM.                    " agrega_mensaje
*&---------------------------------------------------------------------*
*&      Form  SHOW_MESSAGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_messages .

  CALL FUNCTION 'MESSAGES_SHOW'
    EXCEPTIONS
      inconsistent_range = 1
      no_messages        = 2
      OTHERS             = 3.


  CALL FUNCTION 'MESSAGES_INITIALIZE'.
  CLEAR pzeile.

ENDFORM.                    " SHOW_MESSAGES
*&---------------------------------------------------------------------*
*&      Form  PROCESS_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form PROCESS_LINE .

  CASE ps_ucomm.
    WHEN 'MODIFI'.

  MOVE: wreg-matnr   TO zmm_ppto_vta-matnr,
        wreg-zversion TO zmm_ppto_vta-zversion,
        wreg-werks   TO zmm_ppto_vta-werks,
        wreg-gjahr   TO zmm_ppto_vta-gjahr,
        wreg-month01 TO zmm_ppto_vta-month01,
        wreg-month02 TO zmm_ppto_vta-month02,
        wreg-month03 TO zmm_ppto_vta-month03,
        wreg-month04 TO zmm_ppto_vta-month04,
        wreg-month05 TO zmm_ppto_vta-month05,
        wreg-month06 TO zmm_ppto_vta-month06,
        wreg-month07 TO zmm_ppto_vta-month07,
        wreg-month08 TO zmm_ppto_vta-month08,
        wreg-month09 TO zmm_ppto_vta-month09,
        wreg-month10 TO zmm_ppto_vta-month10,
        wreg-month11 TO zmm_ppto_vta-month11,
        wreg-month12 TO zmm_ppto_vta-month12.
      view = 'SI'.

    WHEN 'ELIMIN'.
      READ TABLE gt_zmm_ppto_vta INTO wa_zmm_ppto_vta
           WITH KEY matnr   = wreg-matnr
                  zversion   = wreg-zversion
                    werks   = wreg-werks
                    gjahr   = wreg-gjahr.

      IF sy-subrc EQ 0.
        DELETE gt_zmm_ppto_vta INDEX sy-tabix.
        IF sy-subrc = 0.
          PERFORM agrega_mensaje USING 'Tabla Visualización Eliminada' 'I'.
        ENDIF.

        DELETE FROM zmm_ppto_vta
               WHERE matnr     = wreg-matnr
                  AND zversion = wreg-zversion
                  AND werks    = wreg-werks
                  AND gjahr    = wreg-gjahr.
        COMMIT WORK.

        IF sy-subrc = 0.
          PERFORM agrega_mensaje USING 'Registro Eliminada de SAP' 'I'.
        ENDIF.
      ELSE.
        PERFORM agrega_mensaje USING 'No pudo eliminar Registro' 'E'.
      ENDIF.
      PERFORM show_messages.

    WHEN 'CLEAR'.

      CLEAR: zmm_ppto_vta.

  ENDCASE.
endform.                    " PROCESS_LINE
