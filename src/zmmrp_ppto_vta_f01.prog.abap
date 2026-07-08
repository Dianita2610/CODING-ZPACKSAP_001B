*&---------------------------------------------------------------------*
*&  Include           ZMMRP_PPTO_VTA_F01
*&---------------------------------------------------------------------*

FORM load_file.

  DATA: lt_raw_data TYPE truxs_t_text_data.

  gv_filename = pa_file.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_line_header        = 'X'
      i_tab_raw_data       = lt_raw_data
      i_filename           = gv_filename
    TABLES
      i_tab_converted_data = gt_ppto[]
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    "load_file

*&---------------------------------------------------------------------*
*&      Form  insert_record
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PS_PPTO    text
*----------------------------------------------------------------------*
FORM insert_record USING ps_ppto TYPE zmm_ppto_vta
                         pa_pos.

  INSERT into zmm_ppto_vta values ps_ppto.

  IF sy-subrc EQ 0.
    COMMIT WORK.
    PERFORM add_msg USING 'S' 'Registro guardado existosamente' pa_pos.
  ELSE.
    ROLLBACK WORK.
    PERFORM add_msg USING 'E' 'Registro no se actualizó' pa_pos.
  ENDIF.

ENDFORM.                    "insert_record

*&---------------------------------------------------------------------*
*&      Form  update_record
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PS_PPTO    text
*----------------------------------------------------------------------*
FORM update_record USING ps_ppto TYPE zmm_ppto_vta
                         pa_pos.

  UPDATE zmm_ppto_vta FROM ps_ppto.

  IF sy-subrc EQ 0.
    COMMIT WORK.
    PERFORM add_msg USING 'S' 'Registro actualizado existosamente' pa_pos.
  ELSE.
    ROLLBACK WORK.
    PERFORM add_msg USING 'E' 'Registro no se actualizó' pa_pos.
  ENDIF.
ENDFORM.                    "update_record

*&---------------------------------------------------------------------*
*&      Form  valid_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PS_PPTO    text
*----------------------------------------------------------------------*
FORM valid_data USING ps_ppto TYPE zmm_ppto_vta
                      pa_pos
                CHANGING c_return.

  c_return = 0.

* / Valid field IS NOT INITIAL
  IF ps_ppto-matnr IS INITIAL.
    PERFORM add_msg USING 'E' 'Valor inválido en Material' pa_pos.
    c_return = 4.
  ELSE.
* / Check Material Number exits
**add ini
    SELECT matnr FROM mara
    INTO TABLE gt_mara
    WHERE matnr = ps_ppto-matnr.
*comment
*    READ TABLE gt_mara TRANSPORTING NO FIELDS
*      WITH KEY matnr = ps_ppto-matnr.
**add fin
    IF sy-subrc <> 0.
      PERFORM add_msg USING 'E' 'Material no existe' pa_pos.
      c_return = 4.
    ENDIF.
  ENDIF.

  IF ps_ppto-werks IS INITIAL.
    PERFORM add_msg USING 'E' 'Valor inválido en Material' pa_pos.
    c_return = 4.
  ELSE.
* / Check Plant exits
    READ TABLE gt_t001w TRANSPORTING NO FIELDS
      WITH KEY werks = ps_ppto-werks.

    IF sy-subrc <> 0.
      PERFORM add_msg USING 'E' 'Centro no existe' pa_pos.
      c_return = 4.
    ENDIF.
  ENDIF.

ENDFORM.                    "valid_data

*&---------------------------------------------------------------------*
*&      Form  add_msg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->MSGTYP     text
*      -->MSTRING    text
*      -->ROW        text
*----------------------------------------------------------------------*
FORM add_msg USING msgtyp  TYPE bdcmsgcoll-msgtyp
                   mstring
                   row.

  CLEAR: gs_msg.
  IF msgtyp = 'E'.
    gs_msg-icon = '@0A@'.
  ELSEIF msgtyp = 'S'.
    gs_msg-icon = '@08@'.
  ENDIF.

  gs_msg-msgtyp  = msgtyp.
  gs_msg-mstring = mstring.
  gs_msg-row     = row.

  APPEND gs_msg TO gt_msg.

ENDFORM.                    "add_msg

*&---------------------------------------------------------------------*
*&      Form  show_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM show_log.

  IF gt_msg[] IS NOT INITIAL.
********* Mostrar resultados de mensaje en ALV *********
    DATA: ifc TYPE slis_t_fieldcat_alv,
          xfc TYPE slis_fieldcat_alv.
    REFRESH ifc.

    CLEAR xfc.
    xfc-col_pos      = 1.
    xfc-reptext_ddic = 'Status'.
    xfc-fieldname    = 'ICON'.
    xfc-icon         = 'X'.
    xfc-tabname      = 'GT_MSG'.
    APPEND xfc TO ifc.

    CLEAR xfc.
    xfc-col_pos      = 2.
    xfc-reptext_ddic = 'Tipo Mensaje'.
    xfc-fieldname    = 'MSGTYP'.
    xfc-tabname      = 'GT_MSG'.
    xfc-outputlen    = '12'.
    APPEND xfc TO ifc.

    CLEAR xfc.
    xfc-col_pos      = 3.
    xfc-reptext_ddic = 'Mensaje'.
    xfc-fieldname    = 'MSTRING'.
    xfc-tabname      = 'GT_MSG'.
    xfc-outputlen    = '80'.
    APPEND xfc TO ifc.

    CLEAR xfc.
    xfc-col_pos      = 4.
    xfc-reptext_ddic = 'Linea Excel'.
    xfc-fieldname    = 'ROW'.
    xfc-tabname      = 'T_MSG'.
    xfc-outputlen    = '10'.
    APPEND xfc TO ifc.

***************** Llama Función ALV *****************
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        it_fieldcat        = ifc
      TABLES
        t_outtab           = gt_msg.

  ENDIF.
ENDFORM. "show_log
