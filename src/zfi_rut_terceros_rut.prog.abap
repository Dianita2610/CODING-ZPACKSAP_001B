*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFI_RUT_TERCEROS_RUT
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

  TYPES: BEGIN OF t_bkpf,
           bukrs TYPE bkpf-bukrs,
           belnr TYPE bkpf-belnr,
           gjahr TYPE bkpf-gjahr,
           budat TYPE bkpf-budat,
           cpudt TYPE bkpf-cpudt,
           blart TYPE bkpf-blart,
           xblnr TYPE bkpf-xblnr,
           waers TYPE bkpf-waers,
         END OF t_bkpf.

  TYPES : BEGIN OF t_bseg,
            bukrs TYPE bseg-bukrs,
            belnr TYPE bseg-belnr,
            gjahr TYPE bseg-gjahr,
            buzei TYPE bseg-buzei,
            bschl TYPE bseg-bschl,
            hkont TYPE bseg-hkont,
            wrbtr TYPE bseg-wrbtr,
            zzrut_terc TYPE bseg-zzrut_terc,
            lifnr TYPE bseg-lifnr,
          END OF t_bseg.

  DATA: ti_bkpf TYPE TABLE OF t_bkpf,
        ti_bseg TYPE TABLE OF t_bseg,
        ti_aux  TYPE TABLE OF t_bseg,
        wa_aux  TYPE t_bseg,
        wa_bseg TYPE t_bseg,
        wa_bkpf TYPE t_bkpf.

  SELECT bukrs belnr gjahr budat cpudt blart xblnr waers
    INTO TABLE ti_bkpf
    FROM bkpf
    WHERE bukrs IN s_bukrs
      AND belnr IN s_belnr
      AND budat IN s_budat
      AND cpudt IN s_cpudt.
  IF sy-subrc EQ 0.
SELECT bukrs belnr gjahr buzei bschl
hkont wrbtr zzrut_terc lifnr
INTO TABLE ti_bseg
FROM bseg
FOR ALL ENTRIES IN ti_bkpf
WHERE bukrs EQ ti_bkpf-bukrs
AND belnr EQ ti_bkpf-belnr
AND gjahr EQ ti_bkpf-gjahr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*AND buzid EQ space.
AND BUZID EQ SPACE ORDER BY PRIMARY KEY .
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
    IF sy-subrc EQ 0.
      ti_aux[] = ti_bseg[].
***Borramos aquellas con cuenta acreedor y solo conservamos aquellas
***con la cuenta mayor ingresada al inicio y que tengan rut de terceros
      DELETE ti_aux WHERE NOT hkont IN s_hkont.
      DELETE ti_aux WHERE zzrut_terc IS INITIAL.
      DELETE ti_aux WHERE NOT lifnr IS INITIAL.

***Nos quedamos con solo las cuentas acreedores.
      DELETE ti_bseg WHERE lifnr IS INITIAL.
      SORT ti_bseg BY bukrs belnr gjahr.

*Begin of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 24/12/2019 EY_DES02 ECDK917080 *
SORT TI_BKPF BY BUKRS BELNR GJAHR .
*End of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 24/12/2019 EY_DES02 ECDK917080 *
      LOOP AT ti_aux INTO wa_aux.
        CLEAR wa_salida.
        READ TABLE ti_bseg INTO wa_bseg WITH KEY bukrs = wa_aux-bukrs
                                                 belnr = wa_aux-belnr
                                                 gjahr = wa_aux-gjahr
                                                 BINARY SEARCH.
        IF sy-subrc EQ 0.
          IF wa_aux-zzrut_terc NE wa_bseg-lifnr.
            wa_salida-zzrut_terc = wa_aux-zzrut_terc. "Rut terceros
            wa_salida-lifnr = wa_bseg-lifnr. "Acreedor
            wa_salida-hkont = wa_aux-hkont.  "Cta mayor
            wa_salida-bschl = wa_aux-bschl.  "Clave contab.
            wa_salida-bukrs = wa_aux-bukrs.  "Sociedad
            wa_salida-belnr = wa_aux-belnr.  "Documento
            wa_salida-gjahr = wa_aux-gjahr.  "Ejercicio
            wa_salida-buzei = wa_aux-buzei.  "Posición
            wa_salida-wrbtr = wa_aux-wrbtr.  "Monto
            READ TABLE ti_bkpf INTO wa_bkpf
            WITH KEY bukrs = wa_aux-bukrs
                     belnr = wa_aux-belnr
                     gjahr = wa_aux-gjahr
                     BINARY SEARCH.
            IF sy-subrc EQ 0.
              wa_salida-budat = wa_bkpf-budat. "Fecha contab.
              wa_salida-cpudt = wa_bkpf-cpudt. "Fecha registro
              wa_salida-blart = wa_bkpf-blart. "Clase doc.
              wa_salida-xblnr = wa_bkpf-xblnr. "Referencia
              wa_salida-waers = wa_bkpf-waers. "Moneda
              APPEND wa_salida TO ti_salida.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " OBTENER_DATOS
*&---------------------------------------------------------------------*
*&      Form  EJECUTAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ejecutar .
  DATA: ti_bkdf TYPE TABLE OF bkdf,
        ti_bkpf TYPE TABLE OF bkpf,
        wa_bkpf TYPE bkpf,
        ti_bkpf_aux TYPE TABLE OF bkpf,
        ti_bseg TYPE TABLE OF bseg,
        ti_bsed TYPE TABLE OF bsed,
        ti_bsec TYPE TABLE OF bsec,
        ti_bset TYPE TABLE OF bset.

  FIELD-SYMBOLS: <fs> TYPE bseg.
  DATA: conta(2) TYPE n.
  DATA: campo(16) TYPE c.

  SORT ti_salida BY bukrs belnr gjahr buzei.

  SELECT *
  INTO TABLE ti_bkpf
  FROM bkpf
  FOR ALL ENTRIES IN ti_salida
  WHERE belnr  EQ ti_salida-belnr
     AND bukrs EQ ti_salida-bukrs
     AND gjahr EQ ti_salida-gjahr.

  LOOP AT ti_bkpf INTO wa_bkpf.
    REFRESH : ti_bkdf, ti_bseg, ti_bsec, ti_bsed, ti_bset, ti_bkpf_aux.

    APPEND wa_bkpf TO ti_bkpf_aux.

    SELECT *
      INTO TABLE ti_bkdf
      FROM bkdf
      WHERE bukrs  EQ wa_bkpf-bukrs
        AND belnr  EQ wa_bkpf-belnr
        AND gjahr  EQ wa_bkpf-gjahr.

SELECT *
INTO TABLE ti_bseg
FROM bseg
WHERE bukrs EQ wa_bkpf-bukrs
AND belnr EQ wa_bkpf-belnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*AND gjahr EQ wa_bkpf-gjahr.
AND GJAHR EQ WA_BKPF-GJAHR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
    IF sy-subrc EQ 0.
      LOOP AT ti_bseg ASSIGNING <fs>.
        READ TABLE ti_salida INTO wa_salida
         WITH KEY bukrs = <fs>-bukrs
                  belnr = <fs>-belnr
                  gjahr = <fs>-gjahr
                  buzei = <fs>-buzei BINARY SEARCH.
        IF sy-subrc EQ 0.
          <fs>-zzrut_terc = wa_salida-lifnr.
        ENDIF.
      ENDLOOP.
    ENDIF.

SELECT *
INTO TABLE ti_bsec
FROM bsec
WHERE bukrs EQ wa_bkpf-bukrs
AND belnr EQ wa_bkpf-belnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*AND gjahr EQ wa_bkpf-gjahr.
AND GJAHR EQ WA_BKPF-GJAHR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *

SELECT *
INTO TABLE ti_bset
FROM bset
WHERE bukrs EQ wa_bkpf-bukrs
AND belnr EQ wa_bkpf-belnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*AND gjahr EQ wa_bkpf-gjahr.
AND GJAHR EQ WA_BKPF-GJAHR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *

SELECT *
INTO TABLE ti_bsed
FROM bsed
WHERE bukrs EQ wa_bkpf-bukrs
AND belnr EQ wa_bkpf-belnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*AND gjahr EQ wa_bkpf-gjahr.
AND GJAHR EQ WA_BKPF-GJAHR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *

    CALL FUNCTION 'CHANGE_DOCUMENT'
      TABLES
        t_bkdf = ti_bkdf
        t_bkpf = ti_bkpf_aux
        t_bsec = ti_bsec
        t_bsed = ti_bsed
        t_bseg = ti_bseg
        t_bset = ti_bset.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDLOOP.
ENDFORM.                    " EJECUTAR
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
      t_outtab                = ti_salida[]
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
  ls_line-info = sy-title.
  APPEND ls_line TO lt_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key  = 'Modo:'.
  IF p_test IS INITIAL.
    ls_line-info = 'Real'.
  ELSE.
    ls_line-info = 'Test'.
  ENDIF.
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
**Sociedad
  CLEAR gt_fieldcat.
  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'BUKRS'.
  gt_fieldcat-ref_tabname   = 'BKPF'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

**Documento
  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'BELNR'.
  gt_fieldcat-ref_tabname   = 'BKPF'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

**Ejercicio
  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'GJAHR'.
  gt_fieldcat-ref_tabname   = 'BKPF'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

***Posición
  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'BUZEI'.
  gt_fieldcat-ref_tabname   = 'BSEG'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

**Fecha contable
  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'BUDAT'.
  gt_fieldcat-ref_tabname   = 'BKPF'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

**Fecha registro
  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'CPUDT'.
  gt_fieldcat-ref_tabname   = 'BKPF'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

**Clase documento
  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'BLART'.
  gt_fieldcat-ref_tabname   = 'BKPF'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

***Referencia
  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'XBLNR'.
  gt_fieldcat-ref_tabname   = 'BKPF'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

***Clave contable.
  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'BSCHL'.
  gt_fieldcat-ref_tabname   = 'BSEG'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

**Cta mayor
  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'HKONT'.
  gt_fieldcat-ref_tabname   = 'BSEG'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

**rut de terceros
  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'ZZRUT_TERC'.
  gt_fieldcat-seltext_s     = text-003.
  gt_fieldcat-seltext_m     = text-003.
  gt_fieldcat-seltext_l     = text-003.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

***Proveedor
  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'LIFNR'.
  gt_fieldcat-ref_tabname   = 'BSEG'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

***Moneda
  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'WAERS'.
  gt_fieldcat-ref_tabname   = 'BKPF'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

***Importe
  gt_fieldcat-tabname       = 'TI_SALIDA'.
  gt_fieldcat-fieldname     = 'WRBTR'.
  gt_fieldcat-cfieldname    = 'WAERS'.
  gt_fieldcat-ref_tabname   = 'BSEG'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

ENDFORM.                    " INIT_FIELDCAT

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
ENDFORM.                    "bdc_field

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
    WHEN OTHERS.

  ENDCASE.
ENDFORM.                    "USER_COMMAND
