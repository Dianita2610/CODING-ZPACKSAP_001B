*----------------------------------------------------------------------*
***INCLUDE ZMMR_PO_RELEASE_F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_SALV_FUNCTION  text
*----------------------------------------------------------------------*
FORM release_po USING p_e_salv_function.
  IF p_e_salv_function EQ '&REL'.
    DATA: ls_oc LIKE LINE OF gt_oc.

    DATA: lv_commit TYPE bapimmpara-selection,
          lv_status TYPE bapimmpara-rel_status,
          lv_rel_ind TYPE bapimmpara-po_rel_ind,
          lv_ret_cod TYPE sy-subrc,
          lv_answer(1) TYPE c.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      exporting
        text_question         = 'Desea liberar las Ordenes de Compra?'
        display_cancel_button = 'X'
      importing
        answer                = lv_answer.
    IF lv_answer EQ '1'.

      LOOP AT gt_oc INTO ls_oc.

        CALL FUNCTION 'BAPI_PO_RELEASE'
          EXPORTING
            purchaseorder                = ls_oc-ebeln
            po_rel_code                  = pa_frgco
*     USE_EXCEPTIONS               = 'X'
            no_commit                    = lv_commit
          IMPORTING
            rel_status_new               = lv_status
            rel_indicator_new            = lv_rel_ind
            ret_code                     = lv_ret_cod
          TABLES
            return                       = gt_return[]
          EXCEPTIONS
            authority_check_fail         = 1
            document_not_found           = 2
            enqueue_fail                 = 3
            prerequisite_fail            = 4
            release_already_posted       = 5
            responsibility_fail          = 6
            OTHERS                       = 7
                  .
        IF sy-subrc <> 0.
*   / Valida y asigna semáforo E:ROJO W:AMARILLO S:VERDE
          t_msg-icon = '@0A@'.
          t_msg-mstring = gt_return-message.
          t_msg-msgtyp = gt_return-type.
          t_msg-msgnr = gt_return-code.
          t_msg-ebeln = ls_oc-ebeln.
          APPEND t_msg.
        ELSEIF sy-subrc = 0.
          t_msg-icon = '@08@'.
          t_msg-mstring = 'OC liberada exitosamente'.
          t_msg-msgtyp = 'S'.
          t_msg-msgnr = '001'.
          t_msg-ebeln = ls_oc-ebeln.
          APPEND t_msg.
        ENDIF.
      ENDLOOP.
      PERFORM show_log.
    ENDIF.
  ENDIF.
ENDFORM.                    " USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  show_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM show_log.

  IF t_msg[] IS NOT INITIAL.
********* Mostrar resultados de mensaje en ALV *********
    DATA: ifc TYPE slis_t_fieldcat_alv,
          xfc TYPE slis_fieldcat_alv.
    REFRESH ifc.

    CLEAR xfc.
    xfc-col_pos      = 1.
    xfc-reptext_ddic = 'Status'.
    xfc-fieldname    = 'ICON'.
    xfc-icon         = 'X'.
    xfc-tabname      = 'T_MSG'.
    APPEND xfc TO ifc.

    CLEAR xfc.
    xfc-col_pos      = 2.
    xfc-reptext_ddic = 'Tipo Mensaje'.
    xfc-fieldname    = 'MSGTYP'.
    xfc-tabname      = 'T_MSG'.
    xfc-outputlen    = '12'.
    APPEND xfc TO ifc.

    CLEAR xfc.
    xfc-col_pos      = 3.
    xfc-reptext_ddic = 'Número Mensaje'.
    xfc-fieldname    = 'MSGNR'.
    xfc-tabname      = 'T_MSG'.
    xfc-outputlen    = '14'.
    APPEND xfc TO ifc.

    CLEAR xfc.
    xfc-col_pos      = 4.
    xfc-reptext_ddic = 'Mensaje'.
    xfc-fieldname    = 'MSTRING'.
    xfc-tabname      = 'T_MSG'.
    xfc-outputlen    = '80'.
    APPEND xfc TO ifc.

    CLEAR xfc.
    xfc-col_pos      = 5.
    xfc-reptext_ddic = 'Doc. Compra'.
    xfc-fieldname    = 'EBELN'.
    xfc-tabname      = 'T_MSG'.
    xfc-outputlen    = '80'.
    APPEND xfc TO ifc.

    APPEND xfc TO ifc.

***************** Llama Función ALV *****************
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        it_fieldcat        = ifc
      TABLES
        t_outtab           = t_msg.

  ENDIF.
ENDFORM.                    "show_log
