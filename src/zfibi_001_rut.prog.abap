*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFIBI_001_RUT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  OBTENER_DATOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR wa_bdcdata.
  wa_bdcdata-program  = program.
  wa_bdcdata-dynpro   = dynpro.
  wa_bdcdata-dynbegin = 'X'.
  APPEND wa_bdcdata TO ti_bdcdata.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  CLEAR wa_bdcdata.
  wa_bdcdata-fnam = fnam.
  wa_bdcdata-fval = fval.
  APPEND wa_bdcdata TO ti_bdcdata.
ENDFORM.                    "BDC_FIELD

*&---------------------------------------------------------------------*
*&      Form  obtener_datos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM obtener_datos .
  DATA ls_log LIKE LINE OF t_log.
  IF NOT p_budat IS INITIAL.
    CONCATENATE p_budat+6(2) p_budat+4(2) p_budat(4)
        INTO gd_fecha SEPARATED BY '.'.
  ENDIF.

  gs_params-dismode = 'N'.
  gs_params-updmode = 'S'.
  gs_params-defsize = 'X'.

  SELECT bukrs belnr gjahr xblnr
         budat blart bktxt
     INTO TABLE ti_bkpf
     FROM bkpf
     WHERE bukrs IN s_bukrs
       AND belnr IN s_belnr
       AND gjahr IN s_gjahr.
  IF sy-subrc EQ 0.
    CHECK p_test IS INITIAL.
    LOOP AT ti_bkpf INTO wa_bkpf.
      REFRESH: ti_bdcdata, gt_messtab.
      CLEAR: gd_bstat, wa_bdcdata.

      PERFORM bdc_dynpro      USING 'SAPMF05R' '0100'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=RAGL'.
      PERFORM bdc_field       USING 'RF05R-AUGBL'
                                    wa_bkpf-belnr.
      PERFORM bdc_field       USING 'RF05R-BUKRS'
                                    wa_bkpf-bukrs.
      PERFORM bdc_field       USING 'RF05R-GJAHR'
                                    wa_bkpf-gjahr.

      CALL TRANSACTION 'FBRA' USING    ti_bdcdata
                              OPTIONS  FROM gs_params
                              MESSAGES INTO gt_messtab.

      READ TABLE gt_messtab INTO wa_messtab WITH KEY msgtyp = 'E'.
      IF sy-subrc = 0.
        CLEAR ls_log.
        ls_log-msgtyp = 'S'.
        ls_log-msgspra = sy-langu.
        ls_log-msgid = '00'.
        ls_log-msgnr = '398'.
        CONCATENATE 'Documento' wa_bkpf-bukrs
        wa_bkpf-belnr wa_bkpf-gjahr INTO ls_log-msgv1
        SEPARATED BY space.

        ls_log-msgv2 = text-004.

        APPEND ls_log TO t_log.
      ELSE.
        CLEAR ls_log.
        ls_log-msgtyp = 'S'.
        ls_log-msgspra = sy-langu.
        ls_log-msgid = '00'.
        ls_log-msgnr = '398'.
        CONCATENATE 'Documento' wa_bkpf-bukrs
        wa_bkpf-belnr wa_bkpf-gjahr INTO ls_log-msgv1
        SEPARATED BY space.

        ls_log-msgv2 = text-005.

        APPEND ls_log TO t_log.
      ENDIF.

      LOOP AT gt_messtab INTO wa_messtab.
        CLEAR ls_log.
        ls_log-msgtyp = wa_messtab-msgtyp.
        ls_log-msgspra = sy-langu.
        ls_log-msgid = wa_messtab-msgid.
        ls_log-msgnr = wa_messtab-msgnr.
        ls_log-msgv1 = wa_messtab-msgv1.
        ls_log-msgv2 = wa_messtab-msgv2.
        ls_log-msgv3 = wa_messtab-msgv3.
        ls_log-msgv4 = wa_messtab-msgv4.
        APPEND ls_log TO t_log.
      ENDLOOP.

      CLEAR: gt_messtab[], l_mstring, wa_bdcdata.
      REFRESH ti_bdcdata.

      WAIT UP TO 1 SECONDS.

SELECT SINGLE bstat INTO gd_bstat
*Begin of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
*FROM bkpf BYPASSING BUFFER
FROM bkpf
*End of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
WHERE bukrs = wa_bkpf-bukrs AND
belnr = wa_bkpf-belnr AND
gjahr = wa_bkpf-gjahr.

      IF p_solode is initial.
          IF gd_bstat IS INITIAL.
            PERFORM bdc_dynpro      USING 'SAPMF05A' '0105'.
            PERFORM bdc_field       USING 'BDC_OKCODE'
                                          '=BU'.
            PERFORM bdc_field       USING 'RF05A-BELNS'
                                          wa_bkpf-belnr.
            PERFORM bdc_field       USING 'BKPF-BUKRS'
                                          wa_bkpf-bukrs.
            PERFORM bdc_field       USING 'RF05A-GJAHS'
                                          wa_bkpf-gjahr.
            PERFORM bdc_field       USING 'UF05A-STGRD'
                                          '01'.
            IF NOT gd_fecha IS INITIAL.
              PERFORM bdc_field       USING 'BSIS-BUDAT'
                                             gd_fecha.
            ENDIF.

            IF NOT p_monat IS INITIAL.
              PERFORM bdc_field       USING 'BSIS-MONAT'
                                             p_monat.
            ENDIF.

            CALL TRANSACTION 'FB08' USING    ti_bdcdata
                                    OPTIONS  FROM gs_params
                                    MESSAGES INTO gt_messtab.

            LOOP AT gt_messtab INTO wa_messtab.
              CLEAR ls_log.
              ls_log-msgtyp = wa_messtab-msgtyp.
              ls_log-msgspra = sy-langu.
              ls_log-msgid = wa_messtab-msgid.
              ls_log-msgnr = wa_messtab-msgnr.
              ls_log-msgv1 = wa_messtab-msgv1.
              ls_log-msgv2 = wa_messtab-msgv2.
              ls_log-msgv3 = wa_messtab-msgv3.
              ls_log-msgv4 = wa_messtab-msgv4.
              APPEND ls_log TO t_log.
            ENDLOOP.
          ENDIF.
       endif.
    ENDLOOP.
  ELSE.
    MESSAGE i398(00) WITH text-003.
  ENDIF.
ENDFORM.                    " OBTENER_DATOS
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_log .
  TYPES : BEGIN OF t_balmi,
        msgty TYPE balmi-msgty,
        msgid TYPE balmi-msgid,
        msgno TYPE balmi-msgno,
        msgv1 TYPE char100,
        msgv2  TYPE char100,
        msgv3  TYPE char100,
        msgv4  TYPE char100,
        altext TYPE balmi-altext,
        userexitp TYPE balmi-userexitp,
        userexitf TYPE balmi-userexitf,
        detlevel TYPE balmi-detlevel,
        probclass TYPE balmi-probclass,
        alsort TYPE balmi-alsort,
        END OF t_balmi.

  DATA: lf_obj        TYPE balobj_d,
        lf_subobj     TYPE balsubobj,
        ls_header     TYPE balhdri,
        lf_log_handle TYPE balloghndl,
        lf_log_number TYPE balognr,
        lt_msg        TYPE TABLE OF t_balmi, "balmi_tab,
        ls_msg        TYPE t_balmi,
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
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'BAL_DB_LOGNUMBER_GET' ""#EC *
    EXPORTING
      i_client                 = sy-mandt
      i_log_handle             = lf_log_handle
    IMPORTING
      e_lognumber              = lf_log_number
    EXCEPTIONS
      OTHERS                   = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.

*
    REFRESH lt_msg.
    LOOP AT t_log INTO ls_mess.
      CLEAR ls_msg.
      MOVE-CORRESPONDING  ls_mess TO ls_msg."MSGV1 MSGV1
      MOVE: ls_mess-msgtyp TO ls_msg-msgty,
            ls_mess-msgnr TO ls_msg-msgno.
      APPEND ls_msg TO lt_msg.
    ENDLOOP.

    CALL FUNCTION 'APPL_LOG_WRITE_MESSAGES'
      EXPORTING
        object              = lf_obj
        subobject           = lf_subobj
        log_handle          = lf_log_handle
      TABLES
        messages            = lt_msg
      EXCEPTIONS
        object_not_found    = 1
        subobject_not_found = 2
        OTHERS              = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    IF sy-batch = c_x.
      MOVE-CORRESPONDING ls_header TO ls_lognum.
      ls_lognum-lognumber = lf_log_number.
      APPEND ls_lognum TO lt_lognum.
*
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
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ELSE.
        WRITE / 'Use transaccion SLG1 para revisar log proceso:'(008).
        WRITE: / 'Objeto:ZFI_LOG, SubObjeto = Z01 Log.Number :'(009),
        ls_lognum-lognumber.
      ENDIF.
    ELSE.
      CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'.
    ENDIF.
  ENDIF.
  CLEAR t_log.
  FREE t_log.
ENDFORM.                    " DISPLAY_LOG
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
      i_callback_program      = g_repid
      i_callback_user_command = 'USER_COMMAND'
      is_layout               = gs_layout
      it_fieldcat             = gt_fieldcat[]
      i_default               = 'X'
      i_save                  = 'A'
      it_events               = gt_events[]
    TABLES
      t_outtab                = ti_bkpf[]
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
ENDFORM.                    " MOSTRAR_ALV
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
  CLEAR wa_fieldcat.
  wa_fieldcat-tabname     = 'TI_BKPF'.
  wa_fieldcat-fieldname   = 'BUKRS'.
  wa_fieldcat-ref_tabname = 'BKPF'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-tabname     = 'TI_BKPF'.
  wa_fieldcat-fieldname   = 'BELNR'.
  wa_fieldcat-ref_tabname = 'BKPF'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-tabname     = 'TI_BKPF'.
  wa_fieldcat-fieldname   = 'GJAHR'.
  wa_fieldcat-ref_tabname = 'BKPF'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-tabname     = 'TI_BKPF'.
  wa_fieldcat-fieldname   = 'XBLNR'.
  wa_fieldcat-ref_tabname = 'BKPF'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-tabname     = 'TI_BKPF'.
  wa_fieldcat-fieldname   = 'BUDAT'.
  wa_fieldcat-ref_tabname = 'BKPF'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-tabname     = 'TI_BKPF'.
  wa_fieldcat-fieldname   = 'BLART'.
  wa_fieldcat-ref_tabname = 'BKPF'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-tabname     = 'TI_BKPF'.
  wa_fieldcat-fieldname   = 'BKTXT'.
  wa_fieldcat-ref_tabname = 'BKPF'.
  APPEND wa_fieldcat TO gt_fieldcat.
ENDFORM.                    " INIT_FIELDCAT

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
*&      Form  eventos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PGT_EVENTS text
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
      CLEAR wa_bkpf.
      READ TABLE ti_bkpf INDEX rs_selfield-tabindex INTO wa_bkpf.
      IF sy-subrc EQ 0.
        SET PARAMETER ID 'BLN' FIELD wa_bkpf-belnr.
        SET PARAMETER ID 'BUK' FIELD wa_bkpf-bukrs.
        SET PARAMETER ID 'GJR' FIELD wa_bkpf-gjahr.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    "USER_COMMAND
