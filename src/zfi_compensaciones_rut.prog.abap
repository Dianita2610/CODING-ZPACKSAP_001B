*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <27-12-2019> *
*& Transport Number: < ECDK916996 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFI_COMPENSACIONES_RUT
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
  DATA: indice TYPE sy-tabix.
***Buscamos los documnetos en la REGUH
  SELECT *
    INTO TABLE ti_reguh
    FROM reguh
    WHERE laufd IN s_laufd
      AND laufi IN s_laufi
      AND zbukr IN s_bukrs
      AND zaldt IN s_zaldt
      AND xvorl NE 'X'.
  IF sy-subrc EQ 0.
***Obtenemos los documentos que si se crearon en la BKPF
    SELECT bukrs belnr gjahr
      INTO TABLE ti_bkpf
      FROM bkpf
      FOR ALL ENTRIES IN ti_reguh
      WHERE belnr EQ ti_reguh-vblnr
        AND bukrs EQ ti_reguh-zbukr
        AND gjahr EQ ti_reguh-zaldt(4).

    SORT ti_bkpf BY bukrs belnr gjahr.
***Eliminamos de la TI_REGUH aquellos que existen en la BKPF
    LOOP AT ti_reguh INTO wa_reguh.
      indice = sy-tabix.
      READ TABLE ti_bkpf INTO wa_bkpf WITH KEY bukrs = wa_reguh-zbukr
                                              belnr = wa_reguh-vblnr
                                              gjahr = wa_reguh-zaldt(4)
                                              BINARY SEARCH.
      IF sy-subrc EQ 0.
        DELETE ti_reguh INDEX indice.
      ENDIF.
    ENDLOOP.

    IF NOT ti_reguh[] IS INITIAL.
      SELECT *
        INTO TABLE ti_regup
        FROM regup
        FOR ALL ENTRIES IN ti_reguh
        WHERE laufd EQ ti_reguh-laufd
          AND laufi EQ ti_reguh-laufi
          AND xvorl EQ ti_reguh-xvorl
          AND zbukr EQ ti_reguh-zbukr
          AND lifnr EQ ti_reguh-lifnr
          AND kunnr EQ ti_reguh-kunnr
          AND empfg EQ ti_reguh-empfg
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916996*
*          AND vblnr EQ ti_reguh-vblnr.
          AND vblnr EQ ti_reguh-vblnr ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916996*
    ENDIF.
  ENDIF.
ENDFORM.                    " OBTENER_DATOS
*&---------------------------------------------------------------------*
*&      Form  BATCH_F53
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM batch_f53 .

ENDFORM.                                                    " BATCH_F53

*&---------------------------------------------------------------------*
*&      Form  bdc_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PROGRAM    text
*      -->DYNPRO     text
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  CLEAR bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval.
  APPEND bdcdata.
ENDFORM.                    "BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  MOSTRAR_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mostrar_alv .
* Carga de Campos para ALV
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
      t_outtab                = ti_reguh[]
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
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
  ls_line-info = 'Ejecución de prueba'.
  APPEND ls_line TO lt_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key  = 'Fecha :'.
  CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum(4)
  INTO fecha SEPARATED BY '/'.
  ls_line-info = fecha.
  APPEND ls_line TO lt_top_of_page.

ENDFORM.                    "COMMENT_BUILD_01

*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE_01                                           *
*---------------------------------------------------------------------*
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
      i_client_never_display = 'X'
    CHANGING
      ct_fieldcat            = gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    "init_fieldcat
*&---------------------------------------------------------------------*
*&      Form  EJECUTAR_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ejecutar_batch .
  DATA: wa_payr TYPE payr,
        doc_anterior TYPE reguh-vblnr.

  DATA: ti_aux_regup TYPE TABLE OF regup.
***Primero desbloqueamos la factura.
 LOOP AT ti_reguh INTO wa_reguh.
    LOOP AT ti_regup INTO wa_regup WHERE laufd EQ wa_reguh-laufd
                                     AND laufi EQ wa_reguh-laufi
                                     AND xvorl EQ wa_reguh-xvorl
                                     AND zbukr EQ wa_reguh-zbukr
                                     AND lifnr EQ wa_reguh-lifnr
                                     AND kunnr EQ wa_reguh-kunnr
                                     AND empfg EQ wa_reguh-empfg.

      PERFORM batch_fb09 USING wa_regup-zbukr wa_regup-belnr
                               wa_regup-gjahr wa_regup-buzei.

    ENDLOOP.
  ENDLOOP.

***Ahora compensamos las partidas.
  LOOP AT ti_reguh INTO wa_reguh.
    REFRESH: bdcdata, messtab, ti_aux_regup.
    PERFORM cabecera.
    LOOP AT ti_regup INTO wa_regup WHERE laufd EQ wa_reguh-laufd
                                     AND laufi EQ wa_reguh-laufi
                                     AND xvorl EQ wa_reguh-xvorl
                                     AND zbukr EQ wa_reguh-zbukr
                                     AND lifnr EQ wa_reguh-lifnr
                                     AND kunnr EQ wa_reguh-kunnr
                                     AND empfg EQ wa_reguh-empfg.
      PERFORM bdc_dynpro USING 'SAPMF05A'  '0731'.
      PERFORM bdc_field USING  'BDC_OKCODE'  '/00'.
      PERFORM bdc_field USING  'RF05A-SEL01(01)' wa_regup-belnr.
      APPEND wa_regup TO ti_aux_regup.
    ENDLOOP.

    PERFORM bdc_dynpro USING 'SAPMF05A'  '0731'.
    PERFORM bdc_field  USING 'BDC_OKCODE' '=PA'.

    PERFORM bdc_dynpro USING 'SAPDF05X'	'3100'.
    PERFORM bdc_field  USING 'BDC_OKCODE' '=BU'.
    PERFORM bdc_field  USING  'RF05A-ABPOS'  '1'.

    CALL TRANSACTION 'F-53' USING bdcdata
                            MODE p_mode
                            UPDATE cupdate
                            MESSAGES INTO messtab.

    READ TABLE messtab WITH KEY msgid = 'F5'
                                msgnr = '312'.
    IF sy-subrc EQ 0.
      PERFORM agregar_log USING messtab.
      PERFORM batch_fb02 USING messtab-msgv1 "Doc.creado
                               messtab-msgv2 "Sociedad
                               sy-datum(4)   "Ejercicio
                               wa_reguh-vblnr "Doc. anterior
                               wa_reguh-rzawe "Via de pago
                               wa_reguh-hbkid "Clave banco
                               wa_reguh-hktid "Clave cuenta
                               wa_reguh-name1. "Texto posicion

***Actualizamos la reguh con el nuevo documento generado
      CLEAR doc_anterior.
      doc_anterior = wa_reguh-vblnr.
      DELETE reguh FROM wa_reguh.
      wa_reguh-vblnr = messtab-msgv1.
      INSERT reguh FROM wa_reguh.

***Actualizamos la REGUP
      CLEAR wa_regup.
      LOOP AT ti_aux_regup INTO wa_regup.
        DELETE regup FROM wa_regup.
        wa_regup-vblnr = messtab-msgv1.
        INSERT regup FROM wa_regup.
      ENDLOOP.

***Verificamos si existen cheques en la PAYR
      SELECT SINGLE *
        INTO wa_payr
        FROM payr
        WHERE zbukr EQ wa_reguh-zbukr
          AND hbkid EQ wa_reguh-hbkid
          AND hktid EQ wa_reguh-hktid
          AND lifnr EQ wa_reguh-lifnr
          AND vblnr EQ doc_anterior
          AND gjahr EQ wa_reguh-zaldt(4)
          AND zaldt EQ wa_reguh-zaldt.
      IF sy-subrc EQ 0.
        wa_payr-vblnr = messtab-msgv1.
        wa_payr-gjahr = sy-datum(4).
        UPDATE payr FROM wa_payr.
        IF sy-subrc EQ 0.
          CLEAR wa_log.
          wa_log-msgid = '00'.
          wa_log-msgno = 398.
          wa_log-msgty = 'S'.
          wa_log-msgv1 = 'Datos de cheque actualizado'.
          CONCATENATE wa_reguh-laufd
                      wa_reguh-laufi
                      wa_reguh-vblnr
                      '-'
                      wa_log-msgv1 INTO wa_log-msgv1 SEPARATED BY space.
          APPEND wa_log TO ti_log.
        ELSE.
          CLEAR wa_log.
          wa_log-msgid = '00'.
          wa_log-msgno = 398.
          wa_log-msgty = 'E'.
          wa_log-msgv1 = 'Error al actualizar datos de cheque'.
          CONCATENATE wa_reguh-laufd
                      wa_reguh-laufi
                      wa_reguh-vblnr
                      '-'
                      wa_log-msgv1 INTO wa_log-msgv1 SEPARATED BY space.
          APPEND wa_log TO ti_log.
        ENDIF.
      ELSE.
        CLEAR wa_log.
        wa_log-msgid = '00'.
        wa_log-msgno = 398.
        wa_log-msgty = 'S'.
        wa_log-msgv1 = 'No existen datos de cheques'.
        CONCATENATE wa_reguh-laufd
                    wa_reguh-laufi
                    wa_reguh-vblnr
                    '-'
                    wa_log-msgv1 INTO wa_log-msgv1 SEPARATED BY space.
        APPEND wa_log TO ti_log.
      ENDIF.
    ELSE.
      LOOP AT messtab.
        PERFORM agregar_log USING messtab.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " EJECUTAR_BATCH
*&---------------------------------------------------------------------*
*&      Form  CABECERA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cabecera .
  DATA: fecha(8) TYPE c,
        monto(15) TYPE c.
  CLEAR fecha.
  CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum(4) INTO fecha.
  wa_reguh-rbetr = ABS( wa_reguh-rbetr ).
  WRITE wa_reguh-rbetr TO monto CURRENCY wa_reguh-waers.
  REPLACE ALL OCCURRENCES OF '.' IN monto WITH space.
  CONDENSE monto.

  PERFORM bdc_dynpro USING 'SAPMF05A'	   '0103'.
  PERFORM bdc_field  USING 'BDC_OKCODE'	 '/00'.
  PERFORM bdc_field  USING 'BKPF-BLDAT'  fecha.
  PERFORM bdc_field  USING 'BKPF-BLART'	 'ZP'.
  PERFORM bdc_field  USING 'BKPF-BUKRS'	 wa_reguh-zbukr.
  PERFORM bdc_field  USING 'BKPF-BUDAT'  fecha.
  PERFORM bdc_field  USING 'BKPF-MONAT'	 sy-datum+4(2).
  PERFORM bdc_field  USING 'BKPF-WAERS'  wa_reguh-waers.
  PERFORM bdc_field  USING 'RF05A-KONTO' wa_reguh-ubhkt.
  PERFORM bdc_field  USING 'BSEG-WRBTR'	 monto.
  PERFORM bdc_field  USING 'BSEG-VALUT'	 fecha.
  PERFORM bdc_field  USING 'RF05A-AGKON' wa_reguh-lifnr.
  PERFORM bdc_field  USING 'RF05A-AGKOA' 'K'.
  PERFORM bdc_field  USING 'RF05A-XNOPS' c_x.
  PERFORM bdc_field  USING 'RF05A-XPOS1(01)' space.
  PERFORM bdc_field  USING 'RF05A-XPOS1(04)' c_x.
ENDFORM.                    " CABECERA
*&---------------------------------------------------------------------*
*&      Form  BATCH_FB02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM batch_fb02 USING p_belnr
                      p_bukrs
                      p_gjahr
                      p_anterior
                      p_via_pago
                      p_banco
                      p_cta
                      p_name.

  REFRESH : bdcdata, messtab.
  PERFORM bdc_dynpro      USING 'SAPMF05L' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'RF05L-BELNR'
                                p_belnr.
  PERFORM bdc_field       USING 'RF05L-BUKRS'
                                p_bukrs.
  PERFORM bdc_field       USING 'RF05L-GJAHR'
                                p_gjahr.

  PERFORM bdc_dynpro      USING 'SAPMF05L' '0700'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=VK'.
  PERFORM bdc_dynpro      USING 'SAPMF05L' '1710'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'BKPF-XREF1_HD'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTR'.
  PERFORM bdc_field       USING 'BKPF-XREF1_HD'
                                p_anterior.

  TYPES: BEGIN OF t_bseg,
            bukrs TYPE bseg-bukrs,
            belnr TYPE bseg-belnr,
            gjahr TYPE bseg-gjahr,
            buzei TYPE bseg-buzei,
         END OF t_bseg.

  DATA: ti_bseg TYPE TABLE OF t_bseg,
        wa_bseg TYPE t_bseg,
        contador(2) TYPE n,
        campo(16) TYPE c.

  SELECT bukrs belnr gjahr buzei
    INTO TABLE ti_bseg
    FROM bseg
    WHERE bukrs EQ p_bukrs
      AND belnr EQ p_belnr
      AND gjahr EQ p_gjahr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916996*
*      AND koart EQ 'K'.
      AND koart EQ 'K' ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916996*

  LOOP AT ti_bseg INTO wa_bseg.
    CLEAR: campo, contador.
    contador = wa_bseg-buzei.
    CONCATENATE 'RF05L-ANZDT(' contador ')' INTO campo.
    PERFORM bdc_dynpro USING 'SAPMF05L' '0700'.
    PERFORM bdc_field  USING 'BDC_CURSOR' campo.
    PERFORM bdc_field  USING 'BDC_OKCODE'	'=PK'.

    PERFORM bdc_dynpro USING 'SAPMF05L'   '0302'.
    PERFORM bdc_field  USING 'BDC_OKCODE' '=ZK'.
    PERFORM bdc_field  USING 'BSEG-ZLSCH'  p_via_pago.
    PERFORM bdc_field  USING 'BSEG-SGTXT'	 p_name.

    PERFORM bdc_dynpro USING  'SAPMF05L'   '1302'.
    PERFORM bdc_field  USING  'BDC_OKCODE' '=ENTR'.
    PERFORM bdc_field  USING  'BSEG-HBKID'  p_banco.
    PERFORM bdc_field  USING  'BSEG-HKTID'   p_cta.

    PERFORM bdc_dynpro USING 'SAPMF05L' '0302'.
    PERFORM bdc_field  USING 'BDC_OKCODE' '=AB'.
    PERFORM bdc_field  USING 'BSEG-ZLSCH'  p_via_pago.
    PERFORM bdc_field  USING 'BSEG-SGTXT'	 p_name.
  ENDLOOP.

  PERFORM bdc_dynpro USING 'SAPMF05L' '0700'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=AE'.

  CALL TRANSACTION 'FB02' USING bdcdata
                 MODE   p_mode
                 UPDATE cupdate
                 MESSAGES INTO messtab.
ENDFORM.                    " BATCH_FB02
*&---------------------------------------------------------------------*
*&      Form  AGREGAR_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MESSTAB  text
*----------------------------------------------------------------------*
FORM agregar_log  USING   messtab STRUCTURE bdcmsgcoll.
  CLEAR wa_log.
  wa_log-msgid = '00'. "messtab-msgid.
  wa_log-msgno = '398'."messtab-msgnr.
  wa_log-msgty = messtab-msgtyp.
  MESSAGE ID messtab-msgid TYPE messtab-msgtyp
  NUMBER messtab-msgnr
  WITH messtab-msgv1 messtab-msgv2 messtab-msgv3 messtab-msgv4
  INTO wa_log-msgv1.

  CONCATENATE wa_reguh-laufd
              wa_reguh-laufi
              wa_reguh-vblnr
              '-'
              wa_log-msgv1 INTO wa_log-msgv1 SEPARATED BY space.
  APPEND wa_log TO ti_log.
ENDFORM.                    " AGREGAR_LOG
*&---------------------------------------------------------------------*
*&      Form  MOSTRAR_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mostrar_log .
  DATA: lf_obj        TYPE balobj_d,
         lf_subobj     TYPE balsubobj,
         ls_header     TYPE balhdri,
         lf_log_handle TYPE balloghndl,
         lf_log_number TYPE balognr,
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

  IF sy-subrc EQ 0.
    CALL FUNCTION 'BAL_DB_LOGNUMBER_GET'
      EXPORTING
        i_client                 = sy-mandt
        i_log_handle             = lf_log_handle
      IMPORTING
        e_lognumber              = lf_log_number
      EXCEPTIONS
        log_not_found            = 1
        lognumber_already_exists = 2
        numbering_error          = 3
        OTHERS                   = 4.
    IF sy-subrc EQ 0.
      CALL FUNCTION 'APPL_LOG_WRITE_MESSAGES'
        EXPORTING
          object              = lf_obj
          subobject           = lf_subobj
          log_handle          = lf_log_handle
        TABLES
          messages            = ti_log
        EXCEPTIONS
          object_not_found    = 1
          subobject_not_found = 2
          OTHERS              = 3.

      MOVE-CORRESPONDING ls_header TO ls_lognum.
      ls_lognum-lognumber = lf_log_number.
      APPEND ls_lognum TO lt_lognum.

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
      CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'.
    ENDIF.
  ENDIF.
ENDFORM.                    " MOSTRAR_LOG
*&---------------------------------------------------------------------*
*&      Form  BATCH_FB09
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_REGUP_ZBUKR  text
*      -->P_WA_REGUP_BELNR  text
*      -->P_WA_REGUP_GJAHR  text
*      -->P_WA_REGUP_BUZEI  text
*----------------------------------------------------------------------*
FORM batch_fb09  USING    p_zbukr
                          p_belnr
                          p_gjahr
                          p_buzei.

  REFRESH: bdcdata, messtab.
  PERFORM bdc_dynpro USING 'SAPMF05L'	'0102'.
  PERFORM bdc_field  USING 'BDC_CURSOR'	'RF05L-XKKRE'.
  PERFORM bdc_field  USING 'BDC_OKCODE'	'/00'.
  PERFORM bdc_field  USING 'RF05L-BELNR'  p_belnr.
  PERFORM bdc_field  USING 'RF05L-BUKRS'  p_zbukr.
  PERFORM bdc_field  USING 'RF05L-GJAHR' p_gjahr.
  PERFORM bdc_field  USING 'RF05L-BUZEI' p_buzei.
  PERFORM bdc_field  USING 'RF05L-XKKRE'  'X'.

  PERFORM bdc_dynpro USING 'SAPMF05L'	'0302'.
  PERFORM bdc_field USING 'BDC_OKCODE'  '=AE'.
  PERFORM bdc_field USING 'BSEG-ZLSPR' space.


  CALL TRANSACTION 'FB09' USING bdcdata
                          MODE p_mode
                          UPDATE cupdate
                          MESSAGES INTO messtab.
ENDFORM.                    " BATCH_FB09
