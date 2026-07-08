*&---------------------------------------------------------------------*
*& Report  ZFITR0031
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfitr0031.

TABLES: payr, zmot_emis, bsad, bkpf, t100.

TYPE-POOLS: slis.

TYPES: BEGIN OF ty_salida, "tabla de salida.
         flag        TYPE c,                   "Flag para ejecutar la funcion
         lifnr       LIKE bsik-lifnr,          "Acreedor
         bukrs       LIKE bsis-bukrs,          "Sociedad
         hkont       LIKE bsis-hkont,          "Cuenta de mayor de la contabilidad principal
*  zuonr        LIKE bsis-zuonr,          "Número de asignación
         gjahr       LIKE bsis-gjahr,          "Ejercicio
         belnr       LIKE bsis-belnr,          "Número de un documento contable
*  BUZEI        LIKE bsis-BUZEI,          "Número del apunte contable dentro del documento contable
         budat       LIKE bsis-budat,          "Fecha de contabilización en el documento
         bldat       LIKE bsis-bldat,          "Fecha de documento en documento
         xblnr       LIKE bsik-xblnr,           "Referencia
*  blart        LIKE bsis-blart,          "Clase de documento
*  SHKZG        LIKE bsis-SHKZG,          "Indicador debe/haber
         wrbtr       LIKE bsis-wrbtr,          "Importe en la moneda del documento
         zlsch       LIKE bsik-zlsch,          "via de pago
         waers       LIKE bsis-waers,          "Clave de moneda
         hbkid       LIKE bsik-hbkid,          "Clave breve para banco propio
         hktid       TYPE bsik-hktid,          "Clave breve para un banco/cuenta
         chect       LIKE payr-chect,          "Nº de cheque
         field_style TYPE lvc_t_styl,          "FOR DISABLE cell
*  ESTADO       TYPE C LENGTH 10,         "segun la cuenta de mayor: emitido, revalidado, caduco,etc.
         zzmot_emis  LIKE bseg-zzmot_emis,     "Motivos de emisión
         xref3       LIKE bsik-xref3,          "doc origen
         sgtxt       LIKE bsik-sgtxt,          "texto
         xref1       LIKE bseg-xref1,          "Lote
         xref2       LIKE bseg-xref2,          "Correlativo
*  Multi        TYPE C                 ,"si es multisociedad que se marque el flag
       END OF ty_salida.

TYPES: BEGIN OF ty_return,                    "tabla de retorno de mensaje de la funcion
         bukrs      LIKE bsik-bukrs               , "alv de salida 2
         belnr      LIKE bsik-belnr,
         gjahr      LIKE bsik-gjahr,
         type       LIKE bapiret2-type,
         id         LIKE bapiret2-id,
         number     LIKE bapiret2-number,
         message_v1 LIKE bapiret2-message_v1,
         message_v2 LIKE bapiret2-message_v2,
         message_v3 LIKE bapiret2-message_v3,
         message_v4 LIKE bapiret2-message_v4,
         message    TYPE c LENGTH 150,
       END OF ty_return.

DATA: ti_return         TYPE TABLE OF ty_return WITH HEADER LINE.

DATA: ti_zmot_emis TYPE TABLE OF zmot_emis,
      ti_salida    TYPE TABLE OF ty_salida,
      t_itab       TYPE TABLE OF ty_salida,
      wa_salida    TYPE ty_salida,
      wa_itab      TYPE ty_salida,
      ti_bsik      TYPE TABLE OF bsik,
      wa_bsik      TYPE bsik.

************************************************************************
*     Estructura de parámetros:   ALV
************************************************************************
DATA: it_fieldcat  TYPE lvc_t_fcat,
      wa_fieldcat  TYPE lvc_s_fcat,
      gd_tab_group TYPE slis_t_sp_group_alv,
      gd_layout    TYPE lvc_s_layo,
      gd_repid     LIKE sy-repid.

DATA: ref_grid      TYPE REF TO cl_gui_alv_grid.
*--------------------------------------------------------------------*
*   variables para funcion
*--------------------------------------------------------------------*
DATA: tabname       TYPE c LENGTH 4.
DATA: l_clase_doc   TYPE blart.
DATA: l_nom_proceso TYPE string.
DATA: l_texto       TYPE string.
DATA: l_cta_cadf    TYPE hkont.
DATA: l_fecha       TYPE budat.

DATA: l_t_blntab    TYPE blntab OCCURS 0 WITH HEADER LINE.
DATA: l_t_ftpost    TYPE ftpost OCCURS 0 WITH HEADER LINE.
DATA: l_t_ftclear   TYPE ftclear OCCURS 0 WITH HEADER LINE.
DATA: l_t_fttax     TYPE fttax OCCURS 0 WITH HEADER LINE.

DATA: l_group       LIKE apqi-groupid,
      l_tproceso(5) TYPE c.

DATA: flag_ini TYPE c.

DATA l_ver_batch TYPE c.
DATA c_fipi_trans_compensacion    LIKE sy-tcode VALUE 'FB05'.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t00.
SELECT-OPTIONS :s_bukrs       FOR bkpf-bukrs MEMORY ID buk NO-EXTENSION NO INTERVALS,
                s_emis        FOR zmot_emis-zzmot_emis NO INTERVALS NO-EXTENSION.
PARAMETERS      p_budat       TYPE bsad-budat.
SELECT-OPTIONS  s_chect       FOR payr-chect.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t00.
PARAMETERS       : p_xref11 LIKE bseg-xref1.
SELECTION-SCREEN END OF BLOCK b2.

START-OF-SELECTION.

  IF p_budat IS INITIAL.
    p_budat = sy-datum.
  ENDIF.

  PERFORM buscar_datos.
  PERFORM alv_report.
  PERFORM job.
*&---------------------------------------------------------------------*
*&      Form  BUSCAR_DATOS
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM buscar_datos .
  DATA: lv_correlativo TYPE n LENGTH 12.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT cta_cade zzmot_emis
*  INTO CORRESPONDING FIELDS OF TABLE ti_zmot_emis
*  FROM zmot_emis
*  WHERE bukrs      = s_bukrs-low
*  AND zzmot_emis   IN s_emis.
*
* NEW CODE
  SELECT cta_cade zzmot_emis

  INTO CORRESPONDING FIELDS OF TABLE ti_zmot_emis
  FROM zmot_emis
  WHERE bukrs      = s_bukrs-low
  AND zzmot_emis   IN s_emis ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

  IF ti_zmot_emis[] IS NOT INITIAL. "agregado 08.05.2020
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT *
*    INTO CORRESPONDING FIELDS OF TABLE ti_bsik
*    FROM bsik FOR ALL ENTRIES IN ti_zmot_emis
*    WHERE  hkont      = ti_zmot_emis-cta_cade
** ini Waldo Alarcón - Visionone - 06-05-2020
**  AND    zzmot_emis in s_emis
*     AND  zzmot_emis  = ti_zmot_emis-zzmot_emis
** fin Waldo Alarcón - Visionone - 06-05-2020
*    AND    bukrs = s_bukrs-low
*    AND    xblnr IN s_chect
*    AND    budat <= p_budat.                                                
*
* NEW CODE
    SELECT *

    INTO CORRESPONDING FIELDS OF TABLE ti_bsik
    FROM bsik FOR ALL ENTRIES IN ti_zmot_emis
    WHERE  hkont      = ti_zmot_emis-cta_cade
* ini Waldo Alarcón - Visionone - 06-05-2020
*  AND    zzmot_emis in s_emis
     AND  zzmot_emis  = ti_zmot_emis-zzmot_emis
* fin Waldo Alarcón - Visionone - 06-05-2020
    AND    bukrs = s_bukrs-low
    AND    xblnr IN s_chect
    AND    budat <= p_budat ORDER BY PRIMARY KEY.                                                

* END. 08-07-2026 - ATC - ATC-03"agregado 04.02.2015
  ENDIF.                              "agregado 08.05.2020

  IF sy-subrc NE 0.
    MESSAGE: 'No se encontraron datos' TYPE 'I'DISPLAY LIKE 'E'.
*    leave SCREEN .
  ENDIF.

  CLEAR lv_correlativo.
  LOOP AT ti_bsik INTO wa_bsik .

    ADD 1 TO lv_correlativo.

    MOVE-CORRESPONDING wa_bsik TO wa_salida.
    wa_salida-xref1 = p_xref11.
    wa_salida-xref2 = lv_correlativo.
    wa_salida-chect = wa_salida-xblnr.
    APPEND wa_salida TO ti_salida.

  ENDLOOP.


ENDFORM.                    " BUSCAR_DATOS
*&---------------------------------------------------------------------*
*&      Form  ALV_REPORT
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM alv_report .

  PERFORM set_specific_field_attributes.
  PERFORM alv_ini_fieldcat.
  PERFORM layout_build .
  PERFORM alv_listado.

ENDFORM.                    " ALV_REPORT
*&---------------------------------------------------------------------*
*&      Form  SET_SPECIFIC_FIELD_ATTRIBUTES
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM set_specific_field_attributes .

  DATA ls_stylerow TYPE lvc_s_styl .
  DATA lt_styletab TYPE lvc_t_styl .

  "deshabilito el check box de la linea si la emision viene vacia
  LOOP AT ti_salida INTO wa_salida.
    IF wa_salida-zzmot_emis IS INITIAL.
      ls_stylerow-fieldname = 'FLAG'.
      ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
      INSERT ls_stylerow INTO TABLE wa_salida-field_style.
      MODIFY ti_salida FROM wa_salida INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " SET_SPECIFIC_FIELD_ATTRIBUTES
*&---------------------------------------------------------------------*
*&      Form  ALV_INI_FIELDCAT
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM alv_ini_fieldcat .

  wa_fieldcat-fieldname = 'FLAG'.
  wa_fieldcat-scrtext_m = 'Flag'.
  wa_fieldcat-edit = 'X'.
  wa_fieldcat-checkbox = 'X'.
  wa_fieldcat-outputlen = 1.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*LIFNR
  wa_fieldcat-fieldname = 'LIFNR'.
  wa_fieldcat-scrtext_m = 'Acreedor'.
  wa_fieldcat-outputlen = 4.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*BUKRS
  wa_fieldcat-fieldname = 'BUKRS'.
  wa_fieldcat-scrtext_m = 'Sociedad'.
  wa_fieldcat-outputlen = 4.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
**HKONT
  wa_fieldcat-fieldname = 'HKONT'.
  wa_fieldcat-scrtext_m = 'Libro Mayor'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
**GJaHR
  wa_fieldcat-fieldname = 'GJAHR'.
  wa_fieldcat-scrtext_m = 'Periodo'.
  wa_fieldcat-outputlen = 4.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

*BELNR
  wa_fieldcat-fieldname = 'BELNR'.
  wa_fieldcat-scrtext_m = 'Nº documento'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

*BUDAT
  wa_fieldcat-fieldname = 'BUDAT'.
  wa_fieldcat-scrtext_m = 'Fecha contab.'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*  bsis-BLDAT
  wa_fieldcat-fieldname = 'BLDAT'.
  wa_fieldcat-scrtext_m = 'Fecha doc.'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'XBLNR'.
  wa_fieldcat-scrtext_m = 'Referencia.'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

*WRBTR
  wa_fieldcat-fieldname = 'WRBTR'.
  wa_fieldcat-scrtext_m = 'Importe'.
  wa_fieldcat-do_sum     = 'X'.
  wa_fieldcat-tabname    = 'TI_SALIDA'.
  wa_fieldcat-cfieldname  = 'WAERS'.
  wa_fieldcat-outputlen = 15.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

*zlsch
  wa_fieldcat-fieldname = 'ZLSCH'.
  wa_fieldcat-scrtext_m = 'Via de Pago'.
  wa_fieldcat-outputlen = 15.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*ZZMOT_EMIS
  wa_fieldcat-fieldname = 'ZZMOT_EMIS'.
  wa_fieldcat-scrtext_m = 'Emisión'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*HBKID
  wa_fieldcat-fieldname = 'HBKID'.
  wa_fieldcat-scrtext_m = 'Banco propio'.
  wa_fieldcat-outputlen = 5.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*CHECT
  wa_fieldcat-fieldname = 'CHECT'.
  wa_fieldcat-scrtext_m = 'Nº cheque'.
  wa_fieldcat-outputlen = 13.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'XREF3'.
  wa_fieldcat-scrtext_m = 'Doc Origen'.
  wa_fieldcat-outputlen = 12.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*  sgtxt
  wa_fieldcat-fieldname = 'SGTXT'.
  wa_fieldcat-scrtext_m = 'Texto'.
  wa_fieldcat-outputlen = 25.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*lote
  wa_fieldcat-fieldname = 'XREF1'.
  wa_fieldcat-scrtext_m = 'Lote'.
  wa_fieldcat-outputlen = 12.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*correlativo
  wa_fieldcat-fieldname = 'XREF2'.
  wa_fieldcat-scrtext_m = 'Correlativo'.
  wa_fieldcat-outputlen = 12.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.


  DATA: nfilas(5) TYPE c.
  DATA: nfilas1 TYPE i.
  DESCRIBE TABLE ti_salida LINES  nfilas1.
  MOVE nfilas1 TO nfilas.
  DATA: vl_texto(25) TYPE c.
  CONCATENATE 'Número de filas' nfilas INTO vl_texto SEPARATED BY space.
  MESSAGE vl_texto TYPE 'S'.

ENDFORM.                    " ALV_INI_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_BUILD
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM layout_build .

  gd_layout-stylefname = 'FIELD_STYLE'.
  gd_layout-zebra             = 'X'.
  gd_layout-cwidth_opt = 'X'.

ENDFORM.                    " LAYOUT_BUILD
*&---------------------------------------------------------------------*
*&      Form  ALV_LISTADO
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM alv_listado .

  gd_repid = sy-repid.
  IF sy-batch IS INITIAL.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
      EXPORTING
        i_callback_program       = gd_repid
        i_callback_pf_status_set = 'FRM_PF_STATUS'
        i_callback_user_command  = 'USER_COMMAND'
        is_layout_lvc            = gd_layout
        it_fieldcat_lvc          = it_fieldcat
        i_save                   = 'X'
      TABLES
        t_outtab                 = ti_salida
      EXCEPTIONS
        program_error            = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.
ENDFORM.                    " ALV_LISTADO

*&---------------------------------------------------------------------*
*&      Form  frm_pf_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM frm_pf_status USING rt_extab TYPE slis_t_extab.
*  First i copy PF-STATUS SAPLKKBL STANDARD_FULLSCREEN
  SET PF-STATUS 'STANDARD2' .
ENDFORM.                    "FRM_PF_STATUS.

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       User_command del alv principal
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
      rs_selfield TYPE slis_selfield.
  "marca el checkbox si fue seleccionado
  IF ref_grid IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ref_grid.
  ENDIF.

  IF NOT ref_grid IS INITIAL.
    CALL METHOD ref_grid->check_changed_data.
  ENDIF.

  CASE r_ucomm.
    WHEN 'PICK' OR '&IC1'."click sobre el alv
      IF rs_selfield-fieldname = 'BELNR'.
        READ TABLE ti_salida INTO wa_salida WITH KEY belnr = rs_selfield-value.
        SET PARAMETER ID 'BLN' FIELD rs_selfield-value.
        SET PARAMETER ID 'BUK' FIELD wa_salida-bukrs.
        SET PARAMETER ID 'GJR' FIELD wa_salida-gjahr.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.
      IF rs_selfield-fieldname = 'FLAG'."deseleccion o selecciona
        READ TABLE ti_salida INTO wa_salida INDEX rs_selfield-tabindex.
        IF wa_salida-flag = 'X'.
          CLEAR wa_salida-flag.
        ELSEIF wa_salida-flag IS INITIAL AND wa_salida-zzmot_emis IS NOT INITIAL.
          wa_salida-flag = 'X'.
        ENDIF.
        MODIFY ti_salida FROM wa_salida INDEX rs_selfield-tabindex.
        rs_selfield-refresh = 'X'.
      ENDIF.

    WHEN '&ALL2'. "marca todos
      LOOP AT ti_salida INTO wa_salida.
        IF wa_salida-zzmot_emis IS NOT INITIAL.
          wa_salida-flag = 'X'.
          MODIFY ti_salida FROM wa_salida INDEX sy-tabix.
        ENDIF.
      ENDLOOP.
      rs_selfield-refresh = 'X'.

    WHEN '&SAL2'. "deselecciona todos
      LOOP AT ti_salida INTO wa_salida.
        CLEAR wa_salida-flag.
        MODIFY ti_salida FROM wa_salida INDEX sy-tabix.
      ENDLOOP.
      rs_selfield-refresh = 'X'.

    WHEN '&CONTA'. "ejecuta funcion sobre los que esten seleccionados
      REFRESH ti_return.
      LOOP AT ti_salida INTO wa_salida WHERE flag = 'X'.
        MOVE-CORRESPONDING wa_salida TO wa_itab.
        APPEND wa_itab TO t_itab.
        PERFORM carga_datos.
        PERFORM carga_tablas.
        PERFORM ejecuta_funcion.
      ENDLOOP.
      PERFORM display_messages .

  ENDCASE.
ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  CARGA_DATOS
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM carga_datos .

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE clase_doc cambio_estado
*  INTO (l_clase_doc, l_nom_proceso)
*  FROM zfitr020_t03
*  WHERE id_proceso = '1004'. 
*
* NEW CODE
  SELECT clase_doc cambio_estado
  UP TO 1 ROWS 
  INTO (l_clase_doc, l_nom_proceso)
  FROM zfitr020_t03
  WHERE id_proceso = '1004' ORDER BY PRIMARY KEY. 

  ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01"XB; CADUCA FISICO

  l_fecha = p_budat.

  "se busca la cuenta de la contrapartida
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE cta_cadf INTO l_cta_cadf
*  FROM zmot_emis
*  WHERE bukrs = wa_itab-bukrs
*  AND zzmot_emis = wa_itab-zzmot_emis.
*
* NEW CODE
  SELECT cta_cadf
  UP TO 1 ROWS  INTO l_cta_cadf
  FROM zmot_emis
  WHERE bukrs = wa_itab-bukrs
  AND zzmot_emis = wa_itab-zzmot_emis ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01


ENDFORM.                    " CARGA_DATOS
*&---------------------------------------------------------------------*
*&      Form  CARGA_TABLAS
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM carga_tablas .

  REFRESH l_t_ftclear.  CLEAR l_t_ftclear.
  REFRESH l_t_ftpost.   CLEAR l_t_ftpost.

  l_t_ftclear-agkoa = 'K'.          "CONSTANTE
  l_t_ftclear-agkon = wa_itab-lifnr. "HKONT ALV
  l_t_ftclear-agbuk = wa_itab-bukrs. "SOCIEDAD ALV
  l_t_ftclear-xnops = 'X'.          "CONSTANTE
  l_t_ftclear-selfd = 'BELNR'.      "CONSTANTE
  CONCATENATE wa_itab-belnr wa_itab-gjahr INTO l_t_ftclear-selvon ."= t_itab-belnr."BELNR ALV
*    l_t_ftclear-selbis = ' '.
  APPEND l_t_ftclear.
**---------------------------------------------------------------------
*  BLDAT ALV
**---------------------------------------------------------------------
  l_t_ftpost-stype = 'K'.
  l_t_ftpost-count = '1'.
  l_t_ftpost-fnam = 'BKPF-BLDAT'.
  CONCATENATE wa_itab-bldat+6(2) wa_itab-bldat+4(2) wa_itab-bldat(4) INTO l_t_ftpost-fval. CONDENSE l_t_ftpost-fval.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  Fe.contabilización DATO DE ENTRADA
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-BUDAT'.
  CONCATENATE l_fecha+6(2) l_fecha+4(2) l_fecha(4) INTO l_t_ftpost-fval . CONDENSE l_t_ftpost-fval.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  MES FECHA DE CONTB DE ENTRADA
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-MONAT'.
  l_t_ftpost-fval = l_fecha+4(2).
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  SOCIEDAD ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-BUKRS'. "Sociedad Pantalla de entrada
  l_t_ftpost-fval = wa_itab-bukrs.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  TABLA ZFITR020_T03 CLASE_DOC 1004
*  lo lleno en una subrutina dependiendo del proceso
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-BLART'. "Clase de documento
  l_t_ftpost-fval = l_clase_doc.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  CONSTANTE
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-WAERS'. "Tipo de moneda
  l_t_ftpost-fval = 'CLP'.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  SI EL HKONT ES 2 CAMPO CHECT - SI ES 5 BELNR+GJHAR - SI ES 7 ZOUNR
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-XBLNR'.
  l_t_ftpost-fval = wa_itab-xblnr.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  CONSTANTE
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-BKTXT'. "Nombre de proceso
  l_t_ftpost-fval = 'CADUCO FISICO'."l_nom_proceso.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  CONCATENA "CADUCO FISICO"+ BANCO ALV+ ID DE CTA ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'RF05A-AUGTX'. "Nombre de proceso
*  CONCATENATE 'CADUCO FISICO' ' - ' wa_itab-hbkid ' - ' wa_itab-hktid INTO l_texto SEPARATED BY space.
  REPLACE 'ELECTRONICO' WITH 'FISICO' INTO wa_itab-sgtxt.
  l_t_ftpost-fval = wa_itab-sgtxt."l_texto.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*   CONSTANTE
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'RF05A-NEWBS'.
  l_t_ftpost-fval = '31'.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  CONSULTAR TABLA ZFITR020_T04 CAMPO CTA_CDCO_F CON SOCIEDAD ALV - BANCO PROPIO ALV - ID CTA ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'RF05A-NEWKO'.
  l_t_ftpost-fval = wa_itab-lifnr.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  CONSULTAR TABLA ZMOT_EMI Y SELCCIOANA EL CAMPO DE LA COLUMNA CTA_CADF
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-HKONT'.
  l_t_ftpost-fval = l_cta_cadf.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  IMPORTE ALV
**---------------------------------------------------------------------
  DATA: l_monto(15) TYPE c.
  l_t_ftpost-fnam = 'BSEG-WRBTR'. "monto
  WRITE wa_itab-wrbtr TO l_monto CURRENCY 'CLP'.
  CONDENSE l_monto NO-GAPS.
  l_t_ftpost-fval = l_monto.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  SI EL HKONT ES 2 CAMPO CHECT - SI ES 5 BELNR+GJHAR - SI ES 7 ZOUNR
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-ZUONR'.
  l_t_ftpost-fval = wa_itab-xblnr.
  APPEND l_t_ftpost.

**---------------------------------------------------------------------
*  CONCATENA "CADUCO FISICO"+ BANCO ALV+ ID DE CTA ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-SGTXT'.
*  CONCATENATE 'CADUCO FISICO' ' - ' wa_itab-hbkid ' - ' wa_itab-hktid INTO l_texto SEPARATED BY space.
  REPLACE 'ELECTRONICO' WITH 'FISICO' INTO wa_itab-sgtxt.
  l_t_ftpost-fval = wa_itab-sgtxt."l_texto.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
**---------------------------------------------------------------------
*  MOTIVO EMISION ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-ZZMOT_EMIS'.
  l_t_ftpost-fval = wa_itab-zzmot_emis.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  BANCO
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-HBKID'.
  l_t_ftpost-fval = wa_itab-hbkid.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  Lote
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-XREF3'.
  l_t_ftpost-fval = wa_itab-xref3.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  Lote
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-XREF1'.
  l_t_ftpost-fval = wa_itab-xref1.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  Correlativo
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-XREF2'.
  l_t_ftpost-fval = wa_itab-xref2.
  APPEND l_t_ftpost.


ENDFORM.                    " CARGA_TABLAS  " CARGA_TABLAS
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_MESSAGES
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM display_messages .

  DATA: t_fieldcat      TYPE slis_t_fieldcat_alv.
  DATA: t_events        TYPE slis_alv_event OCCURS 0.
  DATA: g_repid LIKE sy-cprog.

  PERFORM fieldcat_init_salida USING t_fieldcat[].

  DATA event TYPE slis_alv_event.

  event-name = slis_ev_user_command.
  event-form = 'USER_COMMAND2'.
  APPEND event TO t_events.

*------------------------------------------------------------------
* resultado funcion en alv de Salida tipo lista
*------------------------------------------------------------------
  g_repid = sy-cprog.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program = g_repid
*     i_callback_pf_status_set = 'FRM_PF_STATUS2'
      it_fieldcat        = t_fieldcat[]
      it_events          = t_events
    TABLES
      t_outtab           = ti_return.

ENDFORM.                    " DISPLAY_MESSAGES
*&---------------------------------------------------------------------*
*&      Form  EJECUTA_FUNCION
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM ejecuta_funcion .

  l_group = 'ZFITR0031'."sy-tcode.
*********************************
*Cambiar modo de visualizacion
* A	Visual.pant.(todas)
* E	Visualizar sólo errores
* N	Sin visualización

  l_ver_batch = 'N'.
*********************************
*--- Posting interface start
  CALL FUNCTION 'POSTING_INTERFACE_START'
    EXPORTING
      i_function         = 'C'    " Using Call Transaction
      i_group            = l_group
      i_mode             = l_ver_batch
      i_update           = 'S'
      i_user             = sy-uname
      i_xbdcc            = 'X'
    EXCEPTIONS
      client_incorrect   = 1
      function_invalid   = 2
      group_name_missing = 3
      mode_invalid       = 4
      update_invalid     = 5
      OTHERS             = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'POSTING_INTERFACE_CLEARING'
    EXPORTING
      i_auglv                    = 'UMBUCHNG'
      i_tcode                    = 'FB05'
      i_sgfunct                  = 'C'
      i_no_auth                  = ' '
    IMPORTING
      e_msgid                    = sy-msgid
      e_msgno                    = sy-msgno
      e_msgty                    = sy-msgty
      e_msgv1                    = sy-msgv1
      e_msgv2                    = sy-msgv2
      e_msgv3                    = sy-msgv3
      e_msgv4                    = sy-msgv4
*     e_subrc                    = sy-subrc
    TABLES
      t_blntab                   = l_t_blntab
      t_ftclear                  = l_t_ftclear
      t_ftpost                   = l_t_ftpost
      t_fttax                    = l_t_fttax
    EXCEPTIONS
      clearing_procedure_invalid = 1
      clearing_procedure_missing = 2
      table_t041a_empty          = 3
      transaction_code_invalid   = 4
      amount_format_error        = 5
      too_many_line_items        = 6
      company_code_invalid       = 7
      screen_not_found           = 8
      no_authorization           = 9
      OTHERS                     = 10.

  COMMIT WORK.

*  message id sy-msgid type sy-msgty number sy-msgno
*       with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  "lleno la tabla de salida del proceso con el mensaje
  "de la interfaz mas algunos datos adicinales
  CLEAR ti_return.
  ti_return-type        = sy-msgty.
  ti_return-id          = sy-msgid.
  ti_return-number      = sy-msgno.
  ti_return-belnr       = wa_itab-belnr.
  ti_return-bukrs       = wa_itab-bukrs.
  ti_return-gjahr       = wa_itab-gjahr.

  "mensaje estandar a string
  PERFORM convierte_mensaje USING sy-msgid sy-msgno CHANGING ti_return-message.
  ti_return-message_v1  = sy-msgv1.
  APPEND ti_return.

  CALL FUNCTION 'POSTING_INTERFACE_END'
* EXPORTING
*   I_BDCIMMED                    = ' '
*   I_BDCSTRTDT                   = NO_DATE
*   I_BDCSTRTTM                   = NO_TIME
    EXCEPTIONS
      session_not_processable = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " EJECUTA_FUNCION
*&---------------------------------------------------------------------*
*&      Form  CONVIERTE_MENSAJE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_MSGID  text
*      -->P_SY_MSGNO  text
*      <--P_TI_RETURN_MESSAGE  text
*----------------------------------------------------------------------*
FORM convierte_mensaje  USING    p_sy_msgid
                                 p_sy_msgno
                        CHANGING return_message.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t100 WHERE sprsl = 'S'
*                            AND   arbgb = sy-msgid
*                            AND   msgnr = sy-msgno.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t100 WHERE sprsl = 'S'
                            AND   arbgb = sy-msgid
                            AND   msgnr = sy-msgno ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
  IF sy-subrc = 0.
    return_message = t100-text.
    IF return_message CS '&1'.
      REPLACE '&1' WITH sy-msgv1 INTO return_message.
      REPLACE '&2' WITH sy-msgv2 INTO return_message.
      REPLACE '&3' WITH sy-msgv3 INTO return_message.
      REPLACE '&4' WITH sy-msgv4 INTO return_message.
    ELSE.
      REPLACE '&' WITH sy-msgv1 INTO return_message.
      REPLACE '&' WITH sy-msgv2 INTO return_message.
      REPLACE '&' WITH sy-msgv3 INTO return_message.
      REPLACE '&' WITH sy-msgv4 INTO return_message.
    ENDIF.
    CONDENSE return_message.
  ENDIF.


ENDFORM.                    " CONVIERTE_MENSAJE
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT_SALIDA
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM fieldcat_init_salida  USING   rt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
  DATA: pos TYPE i VALUE 1.

  CLEAR  : rt_fieldcat.
  REFRESH: rt_fieldcat.

  CLEAR ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'BUKRS'.
  ls_fieldcat-seltext_s     = 'Sociedad'.
  ls_fieldcat-seltext_l     = 'Sociedad'.
  ls_fieldcat-outputlen     = '12'.
  ls_fieldcat-just          = 'R'.
  APPEND ls_fieldcat TO  rt_fieldcat.

  CLEAR ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'BELNR'.
  ls_fieldcat-seltext_s     = 'Documento'.
  ls_fieldcat-seltext_l     = 'Documento'.
  ls_fieldcat-outputlen     = '15'.
  ls_fieldcat-just          = 'R'.
  APPEND ls_fieldcat TO  rt_fieldcat.

  CLEAR ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'MESSAGE_V1'.
  ls_fieldcat-seltext_s     = 'MESSAGE_V1'.
  ls_fieldcat-seltext_l     = 'MESSAGE_V1'.
  ls_fieldcat-outputlen     = '10'.
  ls_fieldcat-just          = 'R'.
  APPEND ls_fieldcat TO  rt_fieldcat.

  CLEAR ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'MESSAGE'.
  ls_fieldcat-seltext_s     = 'MESSAGE'.
  ls_fieldcat-seltext_l     = 'MESSAGE'.
  ls_fieldcat-outputlen     = '120'.
  ls_fieldcat-just          = 'L'.
  APPEND ls_fieldcat TO  rt_fieldcat.
ENDFORM.                    " FIELDCAT_INIT_SALIDA
*&---------------------------------------------------------------------*
*&      Form  user_command2
*&---------------------------------------------------------------------*
*       user_command del alv de resultado de la funcion
*----------------------------------------------------------------------*
FORM user_command2 USING r_ucomm LIKE sy-ucomm
      rs_selfield TYPE slis_selfield.

  CASE r_ucomm.
    WHEN 'PICK' OR '&IC1'."doble click en alv
      IF rs_selfield-fieldname = 'MESSAGE_V1'.
        IF rs_selfield-value IS NOT INITIAL.
          READ TABLE ti_return WITH KEY belnr = rs_selfield-value.
          SET PARAMETER ID 'BLN' FIELD rs_selfield-value.
          SET PARAMETER ID 'BUK' FIELD ti_return-bukrs.
          SET PARAMETER ID 'GJR' FIELD ti_return-gjahr.
          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  JOB
*&---------------------------------------------------------------------*
*  ---------------------------------------------*
FORM job .
  DATA: rs_selfield TYPE slis_selfield.

*  IF REF_GRID IS INITIAL.
*    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
*    IMPORTING
*      E_GRID = REF_GRID.
*  ENDIF.
*
*  IF NOT REF_GRID IS INITIAL.
*    CALL METHOD REF_GRID->CHECK_CHANGED_DATA.
*  ENDIF.

  IF sy-batch IS NOT INITIAL.
    LOOP AT ti_salida INTO wa_salida.
      IF wa_salida-zzmot_emis IS NOT INITIAL.
        wa_salida-flag = 'X'.
        MODIFY ti_salida FROM wa_salida INDEX sy-tabix.
      ENDIF.
    ENDLOOP.
    rs_selfield-refresh = 'X'.

    REFRESH ti_return.
    LOOP AT ti_salida INTO wa_salida WHERE flag = 'X'.
      MOVE-CORRESPONDING wa_salida TO wa_itab.
      APPEND wa_itab TO t_itab.
      PERFORM carga_datos.
      PERFORM carga_tablas.
      PERFORM ejecuta_funcion.
    ENDLOOP.
    PERFORM display_messages .

  ENDIF.
ENDFORM.                    " JOB
