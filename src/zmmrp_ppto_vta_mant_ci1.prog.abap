*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZMMRP_PPTO_VTA_MANT_CI1
*&---------------------------------------------------------------------*

  CLASS lcl_event_receiver IMPLEMENTATION.
*---------------------------------------*BO
    METHOD handle_toolbar.
      DATA: ls_toolbar  TYPE stb_button.

      CLEAR ls_toolbar.
      MOVE 0 TO ls_toolbar-butn_type.
      MOVE 0 TO ls_toolbar-butn_type.
      MOVE 'MODIFI'                    TO ls_toolbar-function.
      MOVE icon_select_detail          TO ls_toolbar-icon.
      MOVE 'Modificar'                 TO ls_toolbar-text.
      MOVE ' ' TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.

      CLEAR ls_toolbar.
      MOVE 0 TO ls_toolbar-butn_type.
      MOVE 0 TO ls_toolbar-butn_type.
      MOVE 'ELIMIN'                     TO ls_toolbar-function.
      MOVE icon_delete_row              TO ls_toolbar-icon.
      MOVE 'Eliminar'                   TO ls_toolbar-text.
      MOVE ' ' TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.

    ENDMETHOD.                    "handle_toolbar

**
*OPCIONES GRILLA

*---------------------------------*
    METHOD handle_user_command.
*---------------------------------*
      DATA: lt_rows TYPE lvc_t_row.
      MOVE e_ucomm TO ps_ucomm.
      CASE e_ucomm.
        WHEN 'MODIFI'
          OR 'ELIMIN'.
          CALL METHOD go_grid->get_selected_rows
            IMPORTING
              et_index_rows = lt_rows.
          CALL METHOD cl_gui_cfw=>flush.
          IF sy-subrc NE 0.
            CALL FUNCTION 'POPUP_TO_INFORM'
              EXPORTING
                titel = 'NO ACCESS'
                txt2  = sy-subrc
                txt1  = 'Error in Flush'.
          ELSE.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
SORT GT_ZMM_PPTO_VTA .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
            LOOP AT lt_rows INTO g_selected_row.
              IF sy-subrc = 0.
                MOVE g_selected_row-index TO ind.
                READ TABLE gt_zmm_ppto_vta INTO wa_zmm_ppto_vta
                   INDEX g_selected_row-index.
                IF sy-subrc = 0.
                  MOVE wa_zmm_ppto_vta TO wreg.
                  PERFORM process_line.
                ENDIF.
              ENDIF.
            ENDLOOP.
            CALL METHOD go_grid->refresh_table_display.
            CALL SCREEN '0100'.
          ENDIF.
      ENDCASE.
    ENDMETHOD.                    "handle_user_command

  ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION

  CLASS lcl_maintainer IMPLEMENTATION.

    METHOD: begin.
* Limpia estructuras
      REFRESH: gt_zmm_ppto_vta.
      CLEAR:   gt_zmm_ppto_vta,
               wa_zmm_ppto_vta.
*
** Carga datos en tabla auxiliar
      PERFORM carga_datos_tabla.
*
** Actualiza estructuras y carga inicial de datos
      PERFORM fieldcat.
*
** Carga Layout
      PERFORM layout.
*
** Crea contenedor
      PERFORM built_container.
*
** Setea tabla a desplegar
      PERFORM set_table.
*
** Carga barra de ALV
      PERFORM load_toolbar.

    ENDMETHOD.                    "inicio

    METHOD: update.
      SET SCREEN 100.
    ENDMETHOD.                    "actualiza


    METHOD revisa_numero.

      DATA v1   TYPE char20.
      DATA v2   TYPE char20.
      DATA tipo TYPE char4.

*      SPLIT numero AT ',' INTO v1 v2.
*      REPLACE ALL OCCURRENCES OF '.' IN v1 WITH ''.
*
**3 que sea numerico. period
*      CALL FUNCTION 'NUMERIC_CHECK'
*        EXPORTING
*          string_in = v1
*        IMPORTING
*          htype     = tipo.
*
*      IF tipo NE 'NUMC'.
*        sino = 'N'. RETURN.
*      ENDIF.
*
*      CALL FUNCTION 'NUMERIC_CHECK'
*        EXPORTING
*          string_in = v2
*        IMPORTING
*          htype     = tipo.
*
*      IF tipo NE 'NUMC'.
*        sino = 'N'. RETURN.
*      ENDIF.
*
*      sino = 'S'.

    ENDMETHOD.                    "revisa_numero

  ENDCLASS.
