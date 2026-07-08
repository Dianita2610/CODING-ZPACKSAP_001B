*&---------------------------------------------------------------------*
*&  Include           ZFIR002_RUT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  OBTENER_DATOS
*&---------------------------------------------------------------------*
FORM obtener_datos .

  DATA: ti_aux TYPE TABLE OF t_bsid,
        wa_aux TYPE t_bsid.

  DATA : importe  TYPE wrbtr,
         wa_zuonr TYPE t_bsid-zuonr,
         conta    TYPE i,
         lv_vertt TYPE rantyp.

  RANGES : r_zuonr FOR bseg-zuonr.
  FIELD-SYMBOLS : <fs> TYPE t_bsid.

  DATA: ls_anticipos TYPE t_bsid.   "V1-CNN ECDK922573

  IF p_a = abap_true.
    lv_vertt = 'A'.
  ELSE.
    lv_vertt = 'Y'.
  ENDIF.

  REFRESH r_zuonr.
  r_zuonr-sign = 'I'.
  r_zuonr-option = 'BT'.
  r_zuonr-low  = '0000001000'.
  r_zuonr-high = '9999999999'.
  APPEND r_zuonr.

  REFRESH ti_anticipos.
  SELECT bukrs kunnr zuonr hkont umskz vertn xblnr belnr gjahr
         blart bldat zfbdt wrbtr waers shkzg
         vertt xref1
    INTO CORRESPONDING FIELDS OF TABLE ti_anticipos
    FROM bsid
    WHERE bukrs EQ p_bukrs
      AND kunnr IN s_kunnr
      AND umskz EQ 'A'                "Anticipo.
      AND bschl EQ '19'               "haber
      AND vertn NE space              "Contrato
      AND vertt EQ lv_vertt.
*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
* Se tratan por separado los que tienen VERTT = 'Y'.
  DATA: lt_anticipos_y TYPE STANDARD TABLE OF t_bsid,
        lt_anticipos_b TYPE STANDARD TABLE OF t_bsid.

  lt_anticipos_b[] = ti_anticipos[].
  lt_anticipos_y = VALUE #( FOR ls_anticipos_y IN ti_anticipos
                            WHERE ( vertt = 'Y' ) ( ls_anticipos_y ) ).

  DELETE ti_anticipos WHERE vertt = 'Y'.

  READ TABLE ti_anticipos INDEX 1 TRANSPORTING NO FIELDS.
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP

  IF sy-subrc EQ 0.
    SORT ti_anticipos BY bukrs kunnr zuonr hkont umskz vertn.
    ti_aux[] = ti_anticipos[].
    LOOP AT ti_anticipos INTO wa_anticipos.
      ls_anticipos = wa_anticipos.    "V1-CNN ECDK922573
      wa_zuonr = wa_anticipos-zuonr.
      REFRESH ti_docs.
      AT NEW vertn.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = wa_anticipos-vertn
          IMPORTING
            output = v_contrato1.
*
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_anticipos-vertn
          IMPORTING
            output = v_contrato2.

        IF wa_anticipos-zuonr IN r_zuonr.  "1000 al 99999999
          SELECT bukrs kunnr vertn hkont umskz zuonr xblnr
               belnr gjahr blart bldat zfbdt wrbtr waers
               shkzg
            APPENDING CORRESPONDING FIELDS OF TABLE ti_docs
            FROM bsid
            WHERE bukrs EQ wa_anticipos-bukrs
              AND kunnr EQ wa_anticipos-kunnr
              AND umskz EQ space
              AND blart NE 'DZ'
              AND zuonr IN r_zuonr.
        ELSE.
          SELECT bukrs kunnr vertn hkont umskz zuonr xblnr
              belnr gjahr blart bldat zfbdt wrbtr waers
              shkzg
            APPENDING CORRESPONDING FIELDS OF TABLE ti_docs
            FROM bsid
            WHERE bukrs EQ wa_anticipos-bukrs
             AND kunnr EQ wa_anticipos-kunnr
             AND ( vertn EQ v_contrato1 OR vertn EQ v_contrato2 )
             AND umskz EQ space
             AND blart NE 'DZ'
             AND NOT zuonr IN r_zuonr.
        ENDIF.
      ENDAT.

      IF NOT ti_docs[] IS INITIAL.
        LOOP AT ti_aux INTO wa_aux WHERE bukrs EQ wa_anticipos-bukrs
                                     AND kunnr EQ wa_anticipos-kunnr
                                     AND vertn EQ wa_anticipos-vertn.
          APPEND wa_aux TO ti_salida.
        ENDLOOP.
        IF sy-subrc EQ 0.
          APPEND LINES OF ti_docs TO ti_salida.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  REFRESH ti_docs.

*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
*   Se sgregan los documentos con VERTT = 'Y'
  ti_anticipos[] = lt_anticipos_y[].
  CLEAR: lt_anticipos_y[].
  READ TABLE ti_anticipos INDEX 1 TRANSPORTING NO FIELDS.
*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP

  IF sy-subrc EQ 0.
    SORT ti_anticipos BY bukrs kunnr zuonr hkont umskz vertn xref1.
    ti_aux[] = ti_anticipos[].

    LOOP AT ti_anticipos INTO wa_anticipos.
      ls_anticipos = wa_anticipos.    "V1-CNN ECDK922573
      wa_zuonr = ls_anticipos-zuonr.
      REFRESH ti_docs.
      AT NEW xref1.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = ls_anticipos-vertn
          IMPORTING
            output = v_contrato1.
*
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_anticipos-vertn
          IMPORTING
            output = v_contrato2.

        IF wa_anticipos-zuonr IN r_zuonr.  "1000 al 99999999
          SELECT bukrs kunnr vertn hkont umskz zuonr xblnr
               belnr gjahr blart bldat zfbdt wrbtr waers
               shkzg
            APPENDING CORRESPONDING FIELDS OF TABLE ti_docs
            FROM bsid
            WHERE bukrs EQ ls_anticipos-bukrs
              AND kunnr EQ ls_anticipos-kunnr
              AND umskz EQ space
              AND blart NE 'DZ'
              AND zuonr IN r_zuonr.
        ELSE.
          SELECT bukrs kunnr vertn hkont umskz zuonr xblnr
              belnr gjahr blart bldat zfbdt wrbtr waers
              shkzg vertt xref1
         APPENDING CORRESPONDING FIELDS OF TABLE ti_docs
         FROM bsid
         WHERE bukrs EQ ls_anticipos-bukrs
           AND kunnr EQ ls_anticipos-kunnr
           AND ( vertn EQ v_contrato1 OR vertn EQ v_contrato2 )
           AND umskz EQ space
           AND blart NE 'DZ'
           AND NOT zuonr IN r_zuonr
           AND xref1 EQ ls_anticipos-xref1.
        ENDIF.
      ENDAT.

      IF NOT ti_docs[] IS INITIAL.
        LOOP AT ti_aux INTO wa_aux WHERE bukrs EQ ls_anticipos-bukrs
                                     AND kunnr EQ ls_anticipos-kunnr
                                     AND vertn EQ ls_anticipos-vertn
                                     AND xref1 EQ ls_anticipos-xref1.
          APPEND wa_aux TO ti_salida.
        ENDLOOP.
        IF sy-subrc EQ 0.
          APPEND LINES OF ti_docs TO ti_salida.
        ENDIF.
      ENDIF.
    ENDLOOP.

    REFRESH ti_docs.
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP

    SORT ti_salida BY bukrs kunnr zuonr.
    LOOP AT ti_salida ASSIGNING <fs>.
      IF <fs>-shkzg EQ 'H'.
        <fs>-wrbtr =  <fs>-wrbtr * -1.
      ENDIF.
      IF <fs>-umskz NE 'A'.
        APPEND <fs> TO ti_docs.
      ENDIF.
    ENDLOOP.

  ENDIF.

  ti_anticipos[] = lt_anticipos_b[].

ENDFORM.                    " OBTENER_DATOS


*&---------------------------------------------------------------------*
*&      Form  mostra_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM mostrar_alv.
* Carga de Campos para ALV
  PERFORM init_fieldcat.
  PERFORM layout.
  PERFORM eventos CHANGING gt_events[].
  PERFORM comment_build_01 USING gt_list_top_of_page.
  PERFORM sort.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = g_repid
      i_callback_user_command = 'USER_COMMAND'
      is_layout               = gs_layout
      it_fieldcat             = gt_fieldcat[]
      it_sort                 = gt_sort[]
      i_default               = 'X'
      i_save                  = 'A'
*     IS_VARIANT              =
      it_events               = gt_events[]
    TABLES
      t_outtab                = ti_salida[]
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
ENDFORM.                    " mostra_alv

*&---------------------------------------------------------------------*
*&      Form  INIT_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_fieldcat.
  REFRESH: gt_fieldcat.

  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'ID'.
  gt_fieldcat-no_out        = 'X'.
*  gt_fieldcat-ref_tabname   = 'BSID'.
*  gt_fieldcat-ref_fieldname = 'KUNNR'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'BUKRS'.
  gt_fieldcat-ref_tabname   = 'BSID'.
  gt_fieldcat-ref_fieldname = 'BUKRS'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'KUNNR'.
  gt_fieldcat-ref_tabname   = 'BSID'.
  gt_fieldcat-ref_fieldname = 'KUNNR'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'ZUONR'.
  gt_fieldcat-ref_tabname   = 'BSID'.
  gt_fieldcat-ref_fieldname = 'ZUONR'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'VERTN'.
  gt_fieldcat-ref_tabname   = 'BSID'.
  gt_fieldcat-ref_fieldname = 'VERTN'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'VERTT'.
  gt_fieldcat-ref_tabname   = 'BSID'.
  gt_fieldcat-ref_fieldname = 'VERTT'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'XREF1'.
  gt_fieldcat-ref_tabname   = 'BSID'.
  gt_fieldcat-ref_fieldname = 'XREF1'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP

  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'UMSKZ'.
  gt_fieldcat-ref_tabname   = 'BSID'.
  gt_fieldcat-ref_fieldname = 'UMSKZ'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'HKONT'.
  gt_fieldcat-ref_tabname   = 'BSID'.
  gt_fieldcat-ref_fieldname = 'HKONT'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'XBLNR'.
  gt_fieldcat-ref_tabname   = 'BSID'.
  gt_fieldcat-ref_fieldname = 'XBLNR'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'BELNR'.
  gt_fieldcat-ref_tabname   = 'BSID'.
  gt_fieldcat-ref_fieldname = 'BELNR'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'GJAHR'.
  gt_fieldcat-ref_tabname   = 'BSID'.
  gt_fieldcat-ref_fieldname = 'GJAHR'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'BLART'.
  gt_fieldcat-ref_tabname   = 'BSID'.
  gt_fieldcat-ref_fieldname = 'BLART'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'BLDAT'.
  gt_fieldcat-ref_tabname   = 'BSID'.
  gt_fieldcat-ref_fieldname = 'BLDAT'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'WRBTR'.
  gt_fieldcat-cfieldname    = 'WAERS'.
  gt_fieldcat-do_sum        = 'X'.
  gt_fieldcat-ref_tabname   = 'BSID'.
  gt_fieldcat-ref_fieldname = 'WRBTR'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'WAERS'.
  gt_fieldcat-ref_tabname   = 'BSID'.
  gt_fieldcat-ref_fieldname = 'WAERS'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

  IF NOT p_real IS INITIAL. "Solo cuando se compensa en modo real
    gt_fieldcat-tabname       = 'TI_SALIDA'.
    gt_fieldcat-fieldname     = 'MENSAJE'.
    gt_fieldcat-seltext_s     = TEXT-003.
    gt_fieldcat-seltext_m     = TEXT-003.
    gt_fieldcat-seltext_l     = TEXT-003.
    APPEND gt_fieldcat. CLEAR gt_fieldcat.
  ENDIF.

ENDFORM.                    " INIT_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM layout .
*  gs_layout-totals_text   = 'Totales'.
  gs_layout-info_fieldname = 'COLOR'.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-zebra             = 'X'.
ENDFORM.                    " LAYOUT

*&---------------------------------------------------------------------*
*&      Form  EVENTOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_EVENTS  text
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
*---------------------------------------------------------------------*
*       FORM COMMENT_BUILD_01                                         *
*---------------------------------------------------------------------*
FORM comment_build_01 USING lt_top_of_page TYPE slis_t_listheader.

  DATA: ls_line TYPE slis_listheader,
        mes     TYPE t247-mnr,
        mes_ltx TYPE t247-ltx,
        mes_ktx TYPE t247-ktx,
        fecha   TYPE sy-datum.

  REFRESH: lt_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key  = 'Titulo :'.
  ls_line-info = 'Test de partidas a compensar'.
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
*       FORM SET_PF_STATUS_01
*&---------------------------------------------------------------------*
*FORM set_status USING lt_cua_exclude TYPE slis_t_extab.
**  SET PF-STATUS 'STANDARD'.
*ENDFORM.                    "set_pf_status_01
*&---------------------------------------------------------------------*
*&      Form  SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sort .
  DATA: pos TYPE i.
  CLEAR pos.

  ADD 1 TO pos.
  gt_sort-spos = pos.
  gt_sort-fieldname = 'KUNNR'.
  gt_sort-up        = 'X'.
  APPEND gt_sort. CLEAR gt_sort.

*  ADD 1 TO pos.
*  gt_sort-spos = pos.
*  gt_sort-fieldname = 'XBLNR'.
*  gt_sort-up        = 'X'.
*  APPEND gt_sort. CLEAR gt_sort.

  ADD 1 TO pos.
  gt_sort-spos = pos.
  gt_sort-fieldname = 'ZUONR'.
  gt_sort-up        = 'X'.
  APPEND gt_sort. CLEAR gt_sort.

*  ADD 1 TO pos.
*  gt_sort-spos = pos.
*  gt_sort-fieldname = 'WRBTR'.
**  gt_sort-subtot    = 'X'.
*  APPEND gt_sort. CLEAR gt_sort.

ENDFORM.                    " SORT
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

*  DATA: wa_alv LIKE output_table.

  CASE r_ucomm.
    WHEN '&IC1'.
* El registro que se escogió debe estar definido
      CHECK NOT rs_selfield-value IS INITIAL.
      READ TABLE ti_salida INTO wa_salida INDEX rs_selfield-tabindex.
      IF sy-subrc EQ 0.
        SET PARAMETER ID 'BLN' FIELD wa_salida-belnr.
        SET PARAMETER ID 'BUK' FIELD wa_salida-bukrs.
        SET PARAMETER ID 'GJR' FIELD wa_salida-gjahr.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.
    WHEN OTHERS.

  ENDCASE.

ENDFORM.                    "USER_COMMAND


*&---------------------------------------------------------------------*
*&      Form  COMPENSAR
*&---------------------------------------------------------------------*
FORM compensar.

  TYPES : BEGIN OF t_ref,
            belnr TYPE bsid-belnr,
            rebzg TYPE bsid-rebzg,
            wrbtr TYPE bsid-wrbtr,
          END OF t_ref.

  TYPES : BEGIN OF t_aux,
            belnr TYPE bsid-belnr,
          END OF t_aux.

  DATA: ti_ref TYPE TABLE OF t_ref,
        ti_aux TYPE TABLE OF t_aux,
        wa_aux TYPE t_aux,
        wa_ref TYPE t_ref.

  DATA: v_fecha(8)  TYPE c,
        v_conta(2)  TYPE n,
        v_campo(30) TYPE c,
        v_cliente   TYPE bseg-kunnr,
        v_contrato  TYPE bsid-vertn,
        v_importe   TYPE bseg-wrbtr,
        v_saldo     TYPE bseg-wrbtr,
        v_pos(2)    TYPE c,
        indice(2)   TYPE n.


  CONSTANTS: lc_par_max_dif TYPE rvari_val_255
                            VALUE 'ZSD_HELP_COMPENSA_MAX_DIF'.

  DATA: ls_anticipo TYPE t_bsid.

  DATA: lt_anti    TYPE TABLE OF t_bsid.

  DATA: lv_ind     TYPE sytabix,
        lv_sum_fac TYPE wrbtr,
        lv_saldo   TYPE wrbtr,
        lv_dif     TYPE wrbtr,
        lv_max_dif TYPE wrbtr.

  RANGES: r_zuonr FOR bseg-zuonr.
  REFRESH r_zuonr.
  CLEAR r_zuonr.
  r_zuonr-sign = 'I'.
  r_zuonr-option = 'BT'.
  r_zuonr-low  = '0000001000'.
  r_zuonr-high = '9999999999'.
  APPEND r_zuonr.

  CONCATENATE p_budat+6(2) p_budat+4(2) p_budat(4) INTO v_fecha.

*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
  DATA(lt_anticipos_bk) = ti_anticipos[].
  DELETE ti_anticipos WHERE vertt = 'Y'.
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP

  SORT ti_anticipos BY kunnr zuonr. "vertn.
  SORT ti_docs BY kunnr bldat.

**
  LOOP AT ti_anticipos INTO wa_anticipos.
    AT NEW zuonr.
      CLEAR: ls_messtab, l_message.
      ls_messtab-msgtyp = 'I'.
      ls_messtab-msgspra = sy-langu.
      ls_messtab-msgid = '00'.
      ls_messtab-msgnr = '001'.
      CONCATENATE 'Cliente' wa_anticipos-kunnr ' - '
                  'Asignación' wa_anticipos-zuonr
                  INTO l_message SEPARATED BY space.
      ls_messtab-msgv1 = l_message.
      APPEND ls_messtab TO t_log.
    ENDAT.
*
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = wa_anticipos-vertn
      IMPORTING
        output = v_contrato1.
*
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_anticipos-vertn
      IMPORTING
        output = v_contrato2.
*
    REFRESH: ti_docs, ti_ref.
*
    IF wa_anticipos-zuonr IN r_zuonr.

      SELECT kunnr hkont zuonr xblnr bukrs belnr gjahr
             blart bldat zfbdt wrbtr waers shkzg vertn
        INTO CORRESPONDING FIELDS OF TABLE ti_docs
        FROM bsid
        WHERE bukrs EQ wa_anticipos-bukrs
          AND kunnr EQ wa_anticipos-kunnr
          AND umskz EQ space
          AND blart NE 'DZ'
          AND zuonr IN r_zuonr.
    ELSE.
      SELECT kunnr hkont zuonr xblnr bukrs belnr gjahr
             blart bldat zfbdt wrbtr waers shkzg vertn
        INTO CORRESPONDING FIELDS OF TABLE ti_docs
        FROM bsid
        WHERE bukrs EQ wa_anticipos-bukrs
          AND kunnr EQ wa_anticipos-kunnr
          AND ( vertn EQ v_contrato1 OR
              vertn EQ v_contrato2 )
          AND umskz EQ space
          AND blart NE 'DZ'
          AND NOT zuonr IN r_zuonr.
    ENDIF.
*
    SORT ti_docs BY bldat.

    MOVE wa_anticipos-wrbtr TO v_saldo.
    LOOP AT ti_docs INTO wa_docs WHERE kunnr = wa_anticipos-kunnr.
      IF v_saldo > 0.
        PERFORM cabecera USING wa_anticipos-xblnr. "vertn.
        CLEAR v_conta.
*       Buscamos si tiene abonos la factura
        REFRESH ti_ref.
        SELECT belnr rebzg wrbtr
          INTO TABLE ti_ref
          FROM bsid
          WHERE bukrs EQ wa_docs-bukrs
            AND kunnr EQ wa_docs-kunnr
            AND rebzg EQ wa_docs-belnr.
        IF sy-subrc EQ 0.
          PERFORM ingresar_criterios USING wa_anticipos-kunnr 'X'.

          LOOP AT ti_ref INTO wa_ref.
            wa_docs-wrbtr = wa_docs-wrbtr - wa_ref-wrbtr.
            PERFORM bdc_dynpro USING 'SAPMF05A' '0731'.
            PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
            PERFORM bdc_field  USING 'RF05A-SEL01(01)'
                                     wa_ref-rebzg.  "Ref. factura
          ENDLOOP.

**        Ahora agregamos los anticipos
          PERFORM bdc_dynpro USING 'SAPMF05A' '0731'.
          PERFORM bdc_field  USING 'BDC_OKCODE'  '=SL2'.

          PERFORM bdc_dynpro USING 'SAPMF05A' '0608'.
          PERFORM bdc_field  USING 'BDC_OKCODE'  '=ENTR'.
          PERFORM bdc_field  USING 'RF05A-XPOS1(01)' space.
          PERFORM bdc_field  USING 'RF05A-XPOS1(03)' 'X'.

          PERFORM bdc_dynpro USING 'SAPMF05A' '0731'.
          PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
          PERFORM bdc_field  USING 'RF05A-SEL01(01)' wa_anticipos-belnr.

        ELSE.
          PERFORM ingresar_criterios USING wa_anticipos-kunnr space.

**        Ahora agregamos los anticipos
          PERFORM bdc_dynpro USING 'SAPMF05A' '0731'.
          PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
          PERFORM bdc_field  USING 'RF05A-SEL01(01)' wa_anticipos-belnr.

          PERFORM bdc_dynpro    USING 'SAPMF05A' '0731'.
          PERFORM bdc_field     USING 'BDC_OKCODE' '/00'.
          PERFORM bdc_field     USING 'RF05A-SEL01(01)'
                                      wa_docs-belnr. "Factura
        ENDIF.

***tratar PAS
        PERFORM bdc_dynpro USING 'SAPMF05A' '0731'.
        PERFORM bdc_field  USING 'BDC_OKCODE' '=PA'.

        IF v_saldo > wa_docs-wrbtr.

          PERFORM importe_mayor USING v_saldo
                                      wa_docs.

          v_saldo = v_saldo - wa_docs-wrbtr.
          PERFORM call_transaction USING 'F-30' 'X'
                                   CHANGING wa_anticipos-belnr.

        ELSEIF v_saldo <= wa_docs-wrbtr.
          PERFORM importe_menor USING v_saldo
                                      wa_docs.

          v_saldo = v_saldo - wa_docs-wrbtr.
          PERFORM call_transaction USING 'F-30' space
                                   CHANGING wa_anticipos-belnr.
        ENDIF.
      ELSE.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
**

*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
  DATA: lv_cuenta TYPE sytabix.

  ti_anticipos[] = lt_anticipos_bk[].
  DELETE ti_anticipos WHERE vertt <> 'Y'.
  SORT ti_anticipos BY bukrs kunnr zuonr hkont umskz vertn xref1.

* Rescatar parámetro importe máximo
  SELECT SINGLE FROM tvarvc FIELDS low
    WHERE name = @lc_par_max_dif
      AND type = 'P'
      AND numb = '0000'
    INTO @DATA(lv_low).
  IF sy-subrc = 0.
    lv_max_dif = lv_low.
  ELSE.
    lv_max_dif = 1000.
  ENDIF.

**
  LOOP AT ti_anticipos INTO wa_anticipos WHERE vertt = 'Y'.
    ls_anticipo = wa_anticipos.
    AT NEW xref1.
      CLEAR: ls_messtab, l_message.
      ls_messtab-msgtyp = 'I'.
      ls_messtab-msgspra = sy-langu.
      ls_messtab-msgid = '00'.
      ls_messtab-msgnr = '001'.
      CONCATENATE 'Cliente' ls_anticipo-kunnr ' - '
                  'Contrato' ls_anticipo-vertn ' - '
                  'Servicio' ls_anticipo-xref1
                  INTO l_message SEPARATED BY space.
      ls_messtab-msgv1 = l_message.
      APPEND ls_messtab TO t_log.
*
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = ls_anticipo-vertn
        IMPORTING
          output = v_contrato1.
*
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_anticipo-vertn
        IMPORTING
          output = v_contrato2.
*
      REFRESH: ti_docs.
*
      SELECT bukrs kunnr vertn hkont umskz zuonr xblnr
             belnr gjahr blart bldat zfbdt wrbtr waers
             shkzg vertt xref1
        APPENDING CORRESPONDING FIELDS OF TABLE ti_docs
        FROM bsid
        WHERE bukrs EQ ls_anticipo-bukrs
          AND kunnr EQ ls_anticipo-kunnr
          AND ( vertn EQ v_contrato1 OR vertn EQ v_contrato2 )
          AND umskz EQ space
          AND blart NE 'DZ'
          AND NOT zuonr IN r_zuonr
          AND xref1 EQ ls_anticipo-xref1.

      SORT ti_docs BY bldat.

      CLEAR: lv_saldo, lv_cuenta, lv_sum_fac, lt_anti.
      LOOP AT lt_anticipos_bk ASSIGNING FIELD-SYMBOL(<ls_anticipos_bk>)
        WHERE vertn = ls_anticipo-vertn
          AND xref1 = ls_anticipo-xref1.

        lv_cuenta = lv_cuenta + 1.
        IF lv_cuenta = 1.
          CLEAR: lv_ind.
          LOOP AT ti_docs INTO wa_docs WHERE vertn = v_contrato1 OR vertn = v_contrato2.
            lv_ind = lv_ind + 1.
            IF lv_ind = 1.
              PERFORM fill_cab USING ls_anticipo-vertn.
              CLEAR v_conta.
            ENDIF.
            lv_sum_fac = lv_sum_fac + wa_docs-wrbtr.
          ENDLOOP.
        ENDIF.

        lv_saldo = lv_saldo + <ls_anticipos_bk>-wrbtr.

        APPEND INITIAL LINE TO lt_anti ASSIGNING FIELD-SYMBOL(<ls_anti>).
        <ls_anti> = <ls_anticipos_bk>.
      ENDLOOP.

      CHECK NOT lt_anti[] IS INITIAL AND NOT ti_docs IS INITIAL.

      lv_dif = ( lv_saldo - lv_sum_fac ) * 100.
      IF lv_dif < 0. lv_dif = 0 - lv_dif. ENDIF.

      IF lv_dif > lv_max_dif.
        READ TABLE it_bdcdata ASSIGNING FIELD-SYMBOL(<ls_bdcdata>)
          WITH KEY fnam = 'RF05A-XPOS1(04)'.
        IF sy-subrc = 0.
          <ls_bdcdata>-fnam = 'RF05A-XPOS1(02)'.
        ENDIF.
      ENDIF.
      PERFORM fill_criteria TABLES lt_anti
                                   ti_docs.

*     Trasladar y compensar partidas abiertas
      PERFORM bdc_dynpro USING 'SAPMF05A'    '0731'.
      PERFORM bdc_field  USING 'BDC_OKCODE'  '=PA'.

*->   Los anticipos son iguales a la factura
      IF lv_saldo = lv_sum_fac.
        PERFORM fill_importe_igual.
        PERFORM call_transaction USING 'F-30' space
                                 CHANGING wa_anticipos-belnr.
*->  Los importes de anticipos y facturas son diferentes
      ELSE.
        IF lv_dif <= lv_max_dif.
          PERFORM fill_pago_dif USING lv_saldo
                                      lv_sum_fac.
        ELSE.
          IF lv_saldo > lv_sum_fac.
            PERFORM fill_pago_exceso USING wa_anticipos-kunnr.
          ELSE.
            PERFORM fill_pago_parcial.
          ENDIF.
        ENDIF.

        PERFORM call_transaction USING 'F-30' 'X'
                                 CHANGING wa_anticipos-belnr.
      ENDIF.
    ENDAT.

  ENDLOOP.
**
  ti_anticipos[] = lt_anticipos_bk[].
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP

ENDFORM.                    " COMPENSAR


*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PROG       text
*      -->SCR        text
*----------------------------------------------------------------------*
FORM bdc_dynpro USING prog scr.
  CLEAR it_bdcdata.
  it_bdcdata-program = prog.
  it_bdcdata-dynpro  = scr.
  it_bdcdata-dynbegin = 'X'.
  APPEND it_bdcdata.
ENDFORM.                    "BDC_DYNPRO

*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FNAM       text
*      -->FVAL       text
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  CLEAR it_bdcdata.
  it_bdcdata-fnam = fnam.
  it_bdcdata-fval  = fval.
  APPEND it_bdcdata.
ENDFORM.                    "BDC_F


*&---------------------------------------------------------------------*
*&      Form  CABECERA
*&---------------------------------------------------------------------*
FORM cabecera USING v_contrato.

  DATA: v_fecha(8) TYPE c,
        v_budat(8) TYPE c.

  CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum(4) INTO v_fecha.
  CONCATENATE p_budat+6(2) p_budat+4(2) p_budat(4) INTO v_budat.
  PERFORM bdc_dynpro USING 'SAPMF05A'	'0122'.
  PERFORM bdc_field  USING 'BDC_OKCODE'	'=SL'.
  PERFORM bdc_field  USING 'BKPF-BLDAT'	v_fecha.
  PERFORM bdc_field  USING 'BKPF-BLDAT'	v_budat.
* PERFORM bdc_field  USING 'BKPF-BLART'	'DZ'.
  PERFORM bdc_field  USING 'BKPF-BLART'	'DA'.
  PERFORM bdc_field  USING 'BKPF-BUKRS'	p_bukrs.
  PERFORM bdc_field  USING 'BKPF-MONAT'	v_budat+2(2).
  PERFORM bdc_field  USING 'BKPF-WAERS'	'CLP'.
  PERFORM bdc_field  USING 'BKPF-BKTXT'	v_contrato.
  PERFORM bdc_field  USING 'BKPF-XBLNR' space.

ENDFORM.                    " CABECERA

*&---------------------------------------------------------------------*
*&      Form  INGRESAR_CRITERIOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SPACE  text
*----------------------------------------------------------------------*
FORM ingresar_criterios  USING   p_kunnr p_x.
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0710'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'RF05A-AGBUK'
                                p_bukrs.
  PERFORM bdc_field       USING 'RF05A-AGKON'
                                p_kunnr.
  PERFORM bdc_field       USING 'RF05A-AGKOA'
                                'D'.
  PERFORM bdc_field       USING 'RF05A-AGUMS'
                                'A'.
  PERFORM bdc_field       USING 'RF05A-XNOPS'
                                'X'.
  IF NOT p_x IS INITIAL."Busqueda por referencia de factura
    PERFORM bdc_field      USING 'RF05A-XPOS1(01)' space.
    PERFORM bdc_field      USING 'RF05A-XPOS1(18)' 'X'.

    PERFORM bdc_dynpro      USING 'SAPMF05A'   '0608'.
    PERFORM bdc_field       USING 'BDC_OKCODE' '=P+'.

    PERFORM bdc_dynpro      USING 'SAPMF05A'   '0608'.
    PERFORM bdc_field       USING 'BDC_OKCODE'  '=ENTR'.
    PERFORM bdc_field       USING 'RF05A-XPOS1(01)' space.
    PERFORM bdc_field       USING 'RF05A-XPOS1(10)' 'X'.
  ELSE."Búsqueda por factura
    PERFORM bdc_field       USING 'RF05A-XPOS1(01)'
                                  ''.
    PERFORM bdc_field       USING 'RF05A-XPOS1(04)'
                                  'X'.
  ENDIF.
ENDFORM.                    " INGRESAR_CRITERIOS


*&---------------------------------------------------------------------*
*&      Form  IMPORTE_MAYOR
*&---------------------------------------------------------------------*
FORM importe_mayor  USING    p_saldo
                             wa LIKE wa_docs.
  DATA: c_saldo(16)   TYPE c,
        c_fec_vcto(8) TYPE c,
        c_campo(30)   TYPE c.

  WRITE p_saldo TO c_saldo CURRENCY wa_docs-waers.

**Ordenamos por importe
  PERFORM bdc_dynpro USING 'SAPDF05X'  '3100'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=OSD'.
  PERFORM bdc_field  USING 'BDC_CURSOR'  'DF05B-PSBET(01)'.
  PERFORM bdc_field  USING 'RF05A-ABPOS'  '1'.

***eliminar diferencias
  PERFORM bdc_dynpro USING 'SAPDF05X'	'3100'.
  PERFORM bdc_field  USING 'BDC_OKCODE'	'REST'.
  PERFORM bdc_field  USING 'RF05A-ABPOS'  '1'.

  PERFORM bdc_dynpro USING 'SAPDF05X'	'3100'.
  PERFORM bdc_field  USING 'BDC_OKCODE'	'=PI'.
  PERFORM bdc_field  USING 'BDC_CURSOR'  'DF05B-PSDIF(01)'. "'02
  PERFORM bdc_field  USING 'RF05A-ABPOS'  '1'.

  PERFORM bdc_dynpro USING 'SAPDF05X'	'3100'.
  PERFORM bdc_field  USING 'BDC_OKCODE'	'=BS'.
  PERFORM bdc_field  USING 'BDC_CURSOR'	'DF05B-PSDIF(01)'.
  PERFORM bdc_field  USING 'RF05A-ABPOS'  '1'.

  PERFORM bdc_dynpro USING 'SAPMF05A'	   '0700'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'RF05A-AZEI1(01)'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=PI'.
  PERFORM bdc_field  USING 'BKPF-BKTXT'  wa-xblnr. "vertn.

  CLEAR c_fec_vcto.
  CONCATENATE wa-zfbdt+6(2) wa-zfbdt+4(2)
  wa-zfbdt(4) INTO c_fec_vcto.

  PERFORM bdc_dynpro USING 'SAPMF05A'   '0304'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
  PERFORM bdc_field  USING 'BSEG-ZFBDT' c_fec_vcto.
  PERFORM bdc_field  USING 'BSEG-SGTXT' 'ANTICIPO RECAUDACIÓN'.

  PERFORM bdc_dynpro USING 'SAPMF05A'   '0304'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=AB'.
  PERFORM bdc_field  USING 'BSEG-ZFBDT' c_fec_vcto.
  PERFORM bdc_field  USING 'BSEG-SGTXT' 'ANTICIPO RECAUDACIÓN'.

  PERFORM bdc_dynpro USING 'SAPMF05A'  '0700'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=BU'.

*  PERFORM bdc_dynpro USING 'SAPMF05A'   '0301'.
*  PERFORM bdc_field  USING 'BDC_OKCODE'  '=BU'.
*  PERFORM bdc_field  USING 'BSEG-SGTXT' 'Compensación'.

ENDFORM.                    " IMPORTE_MAYOR


*&---------------------------------------------------------------------*
*&      Form  FILL_PAGO_DIF
*&---------------------------------------------------------------------*
FORM fill_pago_dif  USING iv_pagos    TYPE wrbtr
                          iv_facturas TYPE wrbtr.

  CONSTANTS: lc_par_hkont TYPE rvari_val_255 VALUE 'ZSD_HELP_COMPENSA_HKONT',
             lc_par_kostl TYPE rvari_val_255 VALUE 'ZSD_HELP_COMPENSA_KOSTL'.

  DATA: lv_importe TYPE c LENGTH 16,
        lv_fecha   TYPE c LENGTH 10,
        lv_campo   TYPE c LENGTH 30,
        lv_dif     TYPE wrbtr.

*   Rescatar parámetros: Cuenta contable
  SELECT SINGLE FROM tvarvc FIELDS low
    WHERE name = @lc_par_hkont
      AND type = 'P'
      AND numb = '0000'
    INTO @DATA(lv_hkont).
  IF sy-subrc <> 0.
    lv_hkont = '8111100099'.
  ENDIF.

*   Rescatar parámetros: Centro de costo
  SELECT SINGLE FROM tvarvc FIELDS low
    WHERE name = @lc_par_kostl
      AND type = 'P'
      AND numb = '0000'
    INTO @DATA(lv_kostl).
  IF sy-subrc <> 0.
    lv_kostl = 'CL51011201'.
  ENDIF.

  lv_dif = iv_pagos - iv_facturas.

  PERFORM bdc_dynpro USING 'SAPDF05X'    '3100'.
  PERFORM bdc_field  USING 'RF05A-ABPOS'  '1'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=KMD'.
*
  PERFORM bdc_dynpro USING 'SAPMF05A'	   '0700'.
* PERFORM bdc_field  USING 'BKPF-BKTXT'  'DIF. COMPENSACIÓN'.
  IF lv_dif > 0.
    PERFORM bdc_field  USING 'RF05A-NEWBS' '50'.
  ELSE.
    PERFORM bdc_field  USING 'RF05A-NEWBS' '40'.
  ENDIF.
  PERFORM bdc_field  USING 'RF05A-NEWKO' lv_hkont.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
*
  PERFORM bdc_dynpro USING 'SAPMF05A'    '0300'.
  PERFORM bdc_field  USING 'BSEG-WRBTR'  '*'.
  PERFORM bdc_field  USING 'BSEG-MWSKZ'  'D0'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
*
  PERFORM bdc_dynpro USING 'SAPLKACB'    '0002'.
  PERFORM bdc_field  USING 'COBL-KOSTL'  lv_kostl.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=ENTE'.
*
  PERFORM bdc_dynpro USING 'SAPMF05A'    '0330'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=BU'.

ENDFORM.                    " FILL_PAGO_DIF

*&---------------------------------------------------------------------*
*&      Form  IMPORTE_MENOR
*&---------------------------------------------------------------------*
FORM importe_menor  USING    p_importe
                             wa LIKE wa_docs.

  DATA: c_importe(16) TYPE c,
        c_fec_vcto(8) TYPE c,
        c_campo(30)   TYPE c.


  WRITE p_importe TO c_importe CURRENCY 'CLP'.

  CLEAR c_fec_vcto.
  CONCATENATE wa-zfbdt+6(2) wa-zfbdt+4(2)
  wa-zfbdt(4) INTO c_fec_vcto.

**Ordenamos por importe
  PERFORM bdc_dynpro USING 'SAPDF05X'    '3100'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=OSD'.
  PERFORM bdc_field  USING 'BDC_CURSOR'  'DF05B-PSBET(01)'.
  PERFORM bdc_field  USING 'RF05A-ABPOS'  '1'.
*
***eliminar diferencias
  PERFORM bdc_dynpro USING 'SAPDF05X'	'3100'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=PART'.
  PERFORM bdc_field  USING 'RF05A-ABPOS'  '1'.

  PERFORM bdc_dynpro USING 'SAPDF05X'	'3100'.
  PERFORM bdc_field  USING 'BDC_OKCODE'	'/00'.
  PERFORM bdc_field  USING 'RF05A-ABPOS'  '1'.
  PERFORM bdc_field  USING 'DF05B-PSZAH(01)' c_importe.

  PERFORM bdc_dynpro USING 'SAPDF05X'	'3100'.
  PERFORM bdc_field  USING 'BDC_OKCODE'	'=BS'. "Simular
  PERFORM bdc_field  USING 'RF05A-ABPOS'  '1'.

  PERFORM bdc_dynpro USING 'SAPMF05A'	'0700'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'RF05A-AZEI1(01)'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=PI'.
  PERFORM bdc_field  USING 'BKPF-BKTXT'  wa-xblnr.

  PERFORM bdc_dynpro USING 'SAPMF05A' '0301'  .
  PERFORM bdc_field  USING 'BDC_OKCODE'	'=BU'  .
  PERFORM bdc_field  USING 'BSEG-SGTXT' 'ANTICIPO RECAUDACION'.
ENDFORM.                    " IMPORTE_MENO


*&---------------------------------------------------------------------*
*&      Form  FILL_IMPORTE_IGUAL
*&---------------------------------------------------------------------*
FORM fill_importe_igual.

  PERFORM bdc_dynpro USING 'SAPDF05X'    '3100'.
  PERFORM bdc_field  USING 'RF05A-ABPOS'  '1'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=OMX'.
*
  PERFORM bdc_dynpro USING 'SAPDF05X'    '3100'.
  PERFORM bdc_field  USING 'RF05A-ABPOS'  '1'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=Z+'.

  PERFORM bdc_dynpro USING 'SAPDF05X'    '3100'.
  PERFORM bdc_field  USING 'RF05A-ABPOS'  '1'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=BU'.

ENDFORM.                    " FILL_IMPORTE_IGUAL


*&---------------------------------------------------------------------*
*&      Form  FILL_PAGO_EXCESO
*&---------------------------------------------------------------------*
FORM fill_pago_exceso USING iv_kunnr    TYPE kunnr.

  DATA: lv_fecha   TYPE c LENGTH 10.

  PERFORM bdc_dynpro USING 'SAPDF05X'    '3100'.
  PERFORM bdc_field  USING 'RF05A-ABPOS'  '1'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=KMD'.
*
  PERFORM bdc_dynpro USING 'SAPMF05A'	   '0700'.
  PERFORM bdc_field  USING 'RF05A-NEWBS' '19'.
  PERFORM bdc_field  USING 'RF05A-NEWKO'  iv_kunnr.
  PERFORM bdc_field  USING 'RF05A-NEWUM'  'A'.
  PERFORM bdc_field  USING 'BDC_OKCODE'   '/00'.
*
  PERFORM bdc_dynpro USING 'SAPMF05A'    '0304'.
  PERFORM bdc_field  USING 'BSEG-WRBTR'  '*'.
  PERFORM bdc_field  USING 'BSEG-SGTXT'  'EXCEDENTE PAGO FACTURA'.
  WRITE sy-datum TO lv_fecha.
  PERFORM bdc_field  USING 'BSEG-ZFBDT'  lv_fecha.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=ZK'.
*
  PERFORM bdc_dynpro USING 'SAPMF05A'    '0331'.
  PERFORM bdc_field  USING 'BSEG-WRBTR'  '*'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=BU'.

ENDFORM.                    " FILL_PAGO_EXCESO


*&---------------------------------------------------------------------*
*&      Form  FILL_PAGO_PARCIAL
*&---------------------------------------------------------------------*
FORM fill_pago_parcial.

  DATA: lv_fecha   TYPE c LENGTH 10.

  PERFORM bdc_dynpro USING 'SAPDF05X'    '3100'.
  PERFORM bdc_field  USING 'RF05A-ABPOS' '1'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=PART'.
*
  PERFORM bdc_dynpro USING 'SAPDF05X'    '3100'.
  PERFORM bdc_field  USING 'BDC_CURSOR'  'DF05B-PSZAH(02)'.
  PERFORM bdc_field  USING 'RF05A-ABPOS' '1'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=PI'.
*
  PERFORM bdc_dynpro USING 'SAPDF05X'    '3100'.
  PERFORM bdc_field  USING 'RF05A-ABPOS' '1'.
  PERFORM bdc_field  USING 'BDC_CURSOR'  'DF05B-PSZAH(02)'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=BU'.
*
  PERFORM bdc_dynpro USING 'SAPMF05A'    '0700'.
  PERFORM bdc_field  USING 'BDC_CURSOR'  'RF05A-AZEI1(01)'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=PI'.
*
  PERFORM bdc_dynpro USING 'SAPMF05A'    '0301'.
  PERFORM bdc_field  USING 'BSEG-SGTXT'  'ABONO A FACTURA'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=BU'.


ENDFORM.                    " FILL_PAGO_PARCIAL

*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION
*&---------------------------------------------------------------------*
FORM call_transaction USING p_transac p_flag
                      CHANGING p_doc.

  DATA: lineas TYPE i,
        desde  TYPE i.
  CALL TRANSACTION p_transac USING it_bdcdata
                   MODE   p_mode "ctumode
                   UPDATE p_update
                   MESSAGES INTO messtab.
**- verifica documento creado
  CLEAR ls_messtab.
  READ TABLE messtab INTO ls_messtab WITH KEY msgtyp = 'S'
                                              msgid = 'F5'
                                              msgnr = '312'.
  IF sy-subrc EQ 0.
    APPEND ls_messtab TO t_log.
    IF NOT p_flag IS INITIAL.
      p_doc = ls_messtab-msgv1.
    ENDIF.
  ELSE.
*    READ TABLE messtab INTO ls_messtab WITH KEY msgtyp = 'S'
*                                                msgid = 'F5'
*                                                msgnr = '413'.
*    IF sy-subrc EQ 0.
*      DESCRIBE TABLE it_bdcdata LINES lineas.
*      desde = lineas - 10.
*      DELETE it_bdcdata FROM desde TO lineas.
*      PERFORM bdc_dynpro USING 'SAPMF05A'   '0301'.
*      PERFORM bdc_field  USING 'BDC_OKCODE'  '=BU'.
*      PERFORM bdc_field  USING 'BSEG-SGTXT' 'Compensación'.
*      PERFORM call_transaction USING 'F-30' 'X'
*                               CHANGING p_doc.
*    ENDIF.

    LOOP AT  messtab INTO ls_messtab.
      CLEAR l_message.
      MESSAGE  ID  ls_messtab-msgid TYPE ls_messtab-msgtyp NUMBER
      ls_messtab-msgnr
       WITH ls_messtab-msgv1 ls_messtab-msgv2  ls_messtab-msgv3
       ls_messtab-msgv4 INTO l_message.
      CLEAR ls_messtab.
      ls_messtab-msgtyp = ls_messtab-msgtyp.
      ls_messtab-msgspra = sy-langu.
      ls_messtab-msgid = '00'.
      ls_messtab-msgnr = '001'.
      ls_messtab-msgv1 = l_message.
      APPEND ls_messtab TO t_log.
    ENDLOOP.
  ENDIF.

  FREE messtab.
  FREE it_bdcdata.
  REFRESH : it_bdcdata, messtab.
ENDFORM.                    "call_transaction

*&---------------------------------------------------------------------*
*&      Form  display_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_log .
  DATA: lf_obj        TYPE balobj_d,
        lf_subobj     TYPE balsubobj,
        ls_header     TYPE balhdri,
        lf_log_handle TYPE balloghndl,
        lf_log_number TYPE balognr,
        lt_msg        TYPE balmi_tab,
        ls_msg        TYPE balmi,
        lt_lognum     TYPE TABLE OF balnri,
        ls_lognum     TYPE balnri.

  DATA ls_mess LIKE LINE OF messtab.

  lf_obj     = 'ZFI_LOG'.
  lf_subobj  = 'Z01'.

  ls_header-object     = lf_obj.
  ls_header-subobject  = lf_subobj.
  ls_header-aldate     = sy-datum.
  ls_header-altime     = sy-uzeit.
  ls_header-aluser     = sy-uname.
  ls_header-aldate_del = sy-datum + 1.
*

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

  IF sy-batch EQ c_x. "jOB DE FONDO
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
      WRITE / 'Use transaccion SLG1 para revisar log proceso:'.
      WRITE: / 'Objeto:ZFI_LOG, SubObjeto = Z01 Log.Number :',
      ls_lognum-lognumber.
    ENDIF.
  ELSE.
    CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'.
  ENDIF.
  CLEAR t_log.
  FREE t_log.
ENDFORM.                    "display_log


*&---------------------------------------------------------------------*
*&      Form FILL_CAB
*&---------------------------------------------------------------------*
FORM fill_cab USING iv_contrato.

  DATA: lv_fecha(8) TYPE c,
        lv_budat(8) TYPE c.

  PERFORM bdc_dynpro USING 'SAPMF05A'	'0122'.

  WRITE sy-datum TO lv_fecha.
  PERFORM bdc_field  USING 'BKPF-BLDAT'	lv_fecha.
  WRITE p_budat TO lv_budat.
  PERFORM bdc_field  USING 'BKPF-BLDAT'	     lv_budat.
  PERFORM bdc_field  USING 'BKPF-BUKRS'	     p_bukrs.
  PERFORM bdc_field  USING 'BKPF-BLART'	     'DA'.
  PERFORM bdc_field  USING 'BKPF-MONAT'	     lv_budat+2(2).
  PERFORM bdc_field  USING 'BKPF-WAERS'	     'CLP'.
  PERFORM bdc_field  USING 'BKPF-BKTXT'	     iv_contrato.
  PERFORM bdc_field  USING 'BKPF-XBLNR'      TEXT-c01.
  PERFORM bdc_field  USING 'RF05A-XPOS1(04)' 'X'.
  PERFORM bdc_field  USING 'BDC_OKCODE'    	'=SL'.

ENDFORM.                    " FILL_CAB


*&---------------------------------------------------------------------*
*&      Form  FILL_CRITERIA
*&---------------------------------------------------------------------*
FORM fill_criteria TABLES it_anti TYPE gtt_bsid
                          it_docs TYPE gtt_bsid.

  DATA: lv_ind   TYPE n LENGTH 2,
        lv_field TYPE fnam_____4.

  PERFORM bdc_dynpro USING 'SAPMF05A'         '0710'.
  PERFORM bdc_field  USING 'RF05A-AGBUK'      p_bukrs.
  READ TABLE it_docs ASSIGNING FIELD-SYMBOL(<ls_docs>) INDEX 1.
  PERFORM bdc_field  USING 'RF05A-AGKON'      <ls_docs>-kunnr.
  PERFORM bdc_field  USING 'RF05A-AGKOA'      'D'.
  PERFORM bdc_field  USING 'RF05A-AGUMS'      'A'.
  PERFORM bdc_field  USING 'RF05A-XNOPS'      'X'.
  PERFORM bdc_field  USING 'RF05A-XPOS1(01)'  space.
  PERFORM bdc_field  USING 'RF05A-XPOS1(02)'  space.
  PERFORM bdc_field  USING 'RF05A-XPOS1(03)'  space.
  PERFORM bdc_field  USING 'RF05A-XPOS1(04)'  'X'.
  PERFORM bdc_field  USING 'RF05A-XPOS1(05)'  space.
  PERFORM bdc_field  USING 'RF05A-XPOS1(06)'  space.

  PERFORM bdc_field  USING 'BDC_OKCODE'       '/00'.

  PERFORM bdc_dynpro USING 'SAPMF05A'         '0731'.
* Anticipos
  CLEAR: lv_ind.
  LOOP AT it_anti ASSIGNING FIELD-SYMBOL(<ls_anti>).
    lv_ind = lv_ind + 1.
    lv_field = |RF05A-SEL01({ lv_ind })|.
    PERFORM bdc_field  USING lv_field        <ls_anti>-belnr.
  ENDLOOP.

* Facturas
  LOOP AT it_docs ASSIGNING <ls_docs>.
    lv_ind = lv_ind + 1.
    lv_field = |RF05A-SEL01({ lv_ind })|.
    PERFORM bdc_field  USING lv_field        <ls_docs>-belnr.
  ENDLOOP.
  PERFORM bdc_field  USING 'BDC_OKCODE'       '/00'.

ENDFORM.                    " FILL_CRITERIA
