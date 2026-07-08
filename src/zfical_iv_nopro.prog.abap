*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFICAL_IV_NOPRO
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  zfical_iv_nopro.

TABLES: bkpf, bseg, t100.
TYPE-POOLS: slis.

TYPES: BEGIN OF ty_salida,

  bukrs           TYPE bsis-bukrs,        "sociedad
  belnr           TYPE bsis-belnr,        "doc.consumo
  blart           TYPE bsis-blart,        "clase doc
  gjahr           TYPE bseg-gjahr,        "año
  shkzg           TYPE BSEG-SHKZG,        " Indicador debe/haber
  wrbtr           TYPE bseg-wrbtr,        "importe
  hkont           TYPE bseg-hkont,        "cta gasto
  zzunid_pro      TYPE bseg-hkont,        "cta gasto
  iva             TYPE bseg-wrbtr,        "iva
  iva_no_rec      TYPE bseg-wrbtr,        "iva no recup
  waers           TYPE ekko-waers,
  kostl           TYPE bseg-kostl,

END OF ty_salida.

DATA: ti_t030         TYPE TABLE OF t030,
      wa_t030         TYPE t030,
      ti_salida       TYPE TABLE OF ty_salida,
      wa_salida       TYPE ty_salida,
      ti_bsis         TYPE TABLE OF bsis,
      wa_bsis         TYPE bsis,
      ti_bseg         TYPE TABLE OF bseg,
      wa_bseg         TYPE bseg,
      v_iva_prop      TYPE kbetr_kond,
      v_total         TYPE bseg-wrbtr,
      total           TYPE char13,
      v_import        TYPE char13,
      v_unid_pro      TYPE bseg-zzunid_pro,
      v_kostl         TYPE bseg-kostl,
      ti_agrup        TYPE TABLE OF ty_salida,
      wa_agrup        TYPE ty_salida,
      cta_aux         TYPE hkont,
      unid_pro_aux    TYPE bseg-zzunid_pro,
      kostl_aux       TYPE bseg-kostl,
      v_lineas        TYPE i,
      fecha_ini       TYPE char10,
      fecha_fin       TYPE char10,
      v_xblnr         TYPE char20,
      v_bktxt         TYPE char20,
      v_tabix         TYPE sy-tabix.

DATA: bdcdata TYPE STANDARD TABLE OF bdcdata WITH HEADER LINE.
DATA: messtab TYPE STANDARD TABLE OF bdcmsgcoll WITH HEADER LINE.
DATA: w_mode." value 'N'.
DATA: tcode TYPE c LENGTH 10.

DATA: it_fieldcat   TYPE lvc_t_fcat,
      wa_fieldcat   TYPE lvc_s_fcat,
      gd_tab_group  TYPE slis_t_sp_group_alv,
      gd_layout     TYPE lvc_s_layo,
      gd_repid      LIKE sy-repid.

DATA: ref_grid      TYPE REF TO cl_gui_alv_grid.

RANGES: r_hkont           FOR bsik-hkont .
DATA:   wa_hkont          LIKE LINE OF r_hkont .

PARAMETERS:     p_bukrs       TYPE bukrs.
SELECT-OPTIONS  s_budat       FOR bkpf-budat OBLIGATORY.
SELECT-OPTIONS  s_fecha       FOR bkpf-budat OBLIGATORY.




START-OF-SELECTION.

  PERFORM buscar_datos.
  PERFORM alv_report.
*&---------------------------------------------------------------------*
*&      Form  BUSCAR_DATOS
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM buscar_datos.

*  SELECT bklas konts
*  INTO CORRESPONDING FIELDS OF TABLE ti_t030
*  FROM t030
*  WHERE ktopl EQ 'B100'
*  AND ktosl in ('BSX','INV','VNG').


** / THIS IS THE NEW QUERY THAT YOU SENT TO ME FIRST BY WHATSAPP, I THINK THIS IS WHAT YOU WANTED... JP
SELECT bklas konts
INTO CORRESPONDING FIELDS OF TABLE ti_t030
FROM t030
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*WHERE ktosl EQ 'BSX' OR ( ktosl EQ 'GBB' AND ( komok IN ('INV','VNG' ) ) ).
WHERE KTOSL EQ 'BSX' OR ( KTOSL EQ 'GBB' AND ( KOMOK IN ( 'INV' , 'VNG' ) ) ) ORDER BY PRIMARY KEY .
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *



  LOOP AT ti_t030 INTO wa_t030.
    CLEAR wa_hkont.
    wa_hkont-low    = wa_t030-konts.
    wa_hkont-sign   = 'I'."wa_seatleaf-valsign.
    wa_hkont-option = 'EQ'.
    APPEND wa_hkont TO r_hkont.
  ENDLOOP.




*SELECT bs~bukrs
*bs~belnr
*bs~blart
*bg~gjahr
*bg~wrbtr
*bg~hkont
*bg~zzunid_pro
*INTO CORRESPONDING FIELDS OF TABLE ti_salida
*FROM bsis AS bs INNER JOIN bseg AS bg
*ON bs-belnr = bg-belnr
*
*WHERE bs~hkont IN r_hkont
*AND bs~bukrs EQ p_bukrs
*AND bs~budat IN s_budat
*AND bs~blart EQ 'WA'
*AND bg~hkont NE r_hkont
*AND bg~bukrs EQ p_bukrs.

  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE ti_bsis
  FROM bsis
  WHERE bukrs EQ p_bukrs
  AND hkont IN r_hkont
  AND budat IN s_fecha
*
** V1 RVY 12-09-2019
*  AND blart IN ('WA', 'WI').
  AND blart = 'WA'.
** V1 RVY 12-09-2019
*
  IF sy-subrc EQ 0.

SELECT * "// "comentado 10.02.2015
INTO CORRESPONDING FIELDS OF TABLE ti_salida
FROM bseg FOR ALL ENTRIES IN ti_bsis
WHERE belnr EQ ti_bsis-belnr
AND hkont NE ti_bsis-hkont
AND bukrs EQ ti_bsis-bukrs
AND zzunid_pro NE space
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*AND gjahr EQ s_budat-high(4). "agregado 10.02.2015
AND GJAHR EQ S_BUDAT-HIGH(4) ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *

*    LOOP AT ti_bsis INTO wa_bsis.                                          "agregado 10.02.2015
*      SELECT SINGLE *
*      INTO CORRESPONDING FIELDS OF wa_salida
*      FROM bseg
*      WHERE belnr EQ wa_bsis-belnr
*      AND hkont NE wa_bsis-hkont
*      AND bukrs EQ wa_bsis-bukrs
*      AND zzunid_pro NE space
*      AND gjahr EQ wa_bsis-gjahr
*      AND buzei EQ wa_bsis-buzei.
*
*      APPEND wa_salida TO ti_salida.
*    ENDLOOP.                                                                "


  ENDIF.

  CLEAR v_total.
  LOOP AT ti_salida INTO wa_salida.
    v_tabix = sy-tabix.
    IF wa_salida-shkzg = 'H'.
      wa_salida-wrbtr = wa_salida-wrbtr * -1.
    ENDIF.

    wa_salida-iva =  ( wa_salida-wrbtr * 19 ) / 100.

    SELECT SINGLE iva_prop
    INTO v_iva_prop
    FROM zfiivaprp
    WHERE bukrs     EQ p_bukrs
    AND fec_inico EQ s_budat-low
    AND fec_fin   EQ s_budat-high.

    wa_salida-iva_no_rec = wa_salida-iva * ( v_iva_prop / 100 ).

    READ TABLE ti_bsis INTO wa_bsis WITH KEY belnr = wa_salida-belnr.
      IF sy-subrc EQ 0.
        wa_salida-waers = wa_bsis-waers.

        wa_salida-blart = wa_bsis-blart.
      ENDIF.


    MODIFY ti_salida FROM wa_salida INDEX v_tabix.


  ENDLOOP.

ENDFORM.                    " BUSCAR_DATOS
*&---------------------------------------------------------------------*
*&      Form  ALV_REPORT
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM alv_report .

*  PERFORM set_specific_field_attributes.
  PERFORM alv_ini_fieldcat.
  PERFORM layout_build .
  PERFORM alv_listado.


ENDFORM.                    " ALV_REPORT
*&---------------------------------------------------------------------*
*&      Form  ALV_INI_FIELDCAT
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM alv_ini_fieldcat .

  wa_fieldcat-fieldname = 'BUKRS'.
  wa_fieldcat-scrtext_m = 'Sociedad'.
  wa_fieldcat-outputlen = 4.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

*BELNR
  wa_fieldcat-fieldname = 'BELNR'.
  wa_fieldcat-scrtext_m = 'Nº Documento'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

*BLART
  wa_fieldcat-fieldname = 'BLART'.
  wa_fieldcat-scrtext_m = 'Clase Doc'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
**GJaHR
  wa_fieldcat-fieldname = 'GJAHR'.
  wa_fieldcat-scrtext_m = 'Periodo'.
  wa_fieldcat-outputlen = 4.
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
**HKONT
  wa_fieldcat-fieldname = 'HKONT'.
  wa_fieldcat-scrtext_m = 'Cta Gasto'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
**centro de costo
  wa_fieldcat-fieldname = 'KOSTL'.
  wa_fieldcat-scrtext_m = 'Centro Costo'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
**producto
  wa_fieldcat-fieldname = 'ZZUNID_PRO'.
  wa_fieldcat-scrtext_m = 'Producto'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

*iva
  wa_fieldcat-fieldname = 'IVA'.
  wa_fieldcat-scrtext_m = 'Iva 19%'.
*  wa_fieldcat-do_sum     = 'X'.
  wa_fieldcat-tabname    = 'TI_SALIDA'.
  wa_fieldcat-cfieldname  = 'WAERS'.
  wa_fieldcat-outputlen = 15.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*iva no recup
  wa_fieldcat-fieldname = 'IVA_NO_REC'.
  wa_fieldcat-scrtext_m = 'Iva no recup'.
*  wa_fieldcat-do_sum     = 'X'.
  wa_fieldcat-tabname    = 'TI_SALIDA'.
  wa_fieldcat-cfieldname  = 'WAERS'.
  wa_fieldcat-outputlen = 15.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

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
  CASE r_ucomm.

    WHEN '&CONTA'. "ejecuta funcion sobre los que esten seleccionados

      PERFORM contabilizar.

  ENDCASE.
ENDFORM.                    "user_command

*&---------------------------------------------------------------------*
*&      Form  contabilizar
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM contabilizar.
  DATA sec(02) TYPE n.
  DATA sw_primero(1).
  DATA lineas TYPE i.
  DATA mensaje(150).
  DATA nlineas TYPE i.

  DATA xNEWBS_40 TYPE RF05A-NEWBS.
  DATA xNEWBS_50 TYPE RF05A-NEWBS.
* { SCL26122017
  DATA: BEGIN OF lt_skb1 OCCURS 0,
          bukrs TYPE skb1-bukrs,
          saknr TYPE skb1-saknr,
        END OF lt_skb1.

  DATA: rg_saknr TYPE RANGE OF skb1-saknr,
        wa_saknr LIKE LINE OF rg_saknr,
        lv_lines TYPE i,
        lv_blart TYPE char01.
* } SCL26122017

  LEAVE TO LIST-PROCESSING.
  SET PF-STATUS space.
  " SET PF-STATUS 'STANDARD3' .
  SUPPRESS DIALOG.
* { SCL26122017
  wa_saknr-sign = 'I'.
  wa_saknr-option = 'EQ'.
  wa_saknr-low = '7115100002'."'4211410500'."HCD 20190905
  APPEND wa_saknr TO rg_saknr.

  SELECT bukrs saknr FROM skb1 INTO TABLE lt_skb1
    WHERE bukrs EQ p_bukrs
      AND saknr IN rg_saknr
      AND xintb EQ 'X'.
* } SCL26122017
  SORT ti_salida  ASCENDING BY hkont zzunid_pro kostl.
  REFRESH ti_agrup.
  CLEAR : cta_aux, unid_pro_aux, kostl_aux.
  LOOP AT ti_salida INTO wa_salida.
* { SCL26122017
    IF wa_salida-blart = 'WI'.
      lv_blart = 'X'.
    ENDIF.
* } SCL26122017
    IF cta_aux IS INITIAL AND unid_pro_aux IS INITIAL.
      wa_agrup-hkont = wa_salida-hkont.
      wa_agrup-kostl      = wa_salida-kostl.
      wa_agrup-zzunid_pro = wa_salida-zzunid_pro.
      wa_agrup-iva_no_rec = wa_agrup-iva_no_rec + wa_salida-iva_no_rec.
    ELSEIF cta_aux EQ wa_salida-hkont AND unid_pro_aux EQ wa_salida-zzunid_pro AND kostl_aux EQ wa_salida-kostl.
      wa_agrup-hkont = wa_salida-hkont.
      wa_agrup-kostl = wa_salida-kostl.
      wa_agrup-zzunid_pro = wa_salida-zzunid_pro.
      wa_agrup-iva_no_rec = wa_agrup-iva_no_rec + wa_salida-iva_no_rec.
    ELSE.
      APPEND wa_agrup TO ti_agrup.
      CLEAR wa_agrup.
      wa_agrup-hkont = wa_salida-hkont.
      wa_agrup-kostl = wa_salida-kostl.
      wa_agrup-zzunid_pro = wa_salida-zzunid_pro.
      wa_agrup-iva_no_rec = wa_agrup-iva_no_rec + wa_salida-iva_no_rec.
    ENDIF.
    cta_aux      = wa_salida-hkont.
    unid_pro_aux = wa_salida-zzunid_pro.
    kostl_aux    = wa_salida-kostl.
  ENDLOOP.
  APPEND wa_agrup TO ti_agrup.

  DESCRIBE TABLE ti_agrup LINES v_lineas.
* { SCL26122017
  DESCRIBE TABLE lt_skb1 LINES lv_lines.

  IF lv_lines > 0 AND lv_blart = 'X'.
    "MESSAGE 'Existen registros que afectan la cuenta 421140500 y esta cuenta solo es posible con contabilizaciones automáticas' TYPE 'I'.
    MESSAGE 'Existen registros que afectan la cuenta 7115100002 y esta cuenta solo es posible con contabilizaciones automáticas' TYPE 'I'."HCD 20190905
  ELSE.
  CONCATENATE s_budat-low+6(2) '.' s_budat-low+4(2) '.' s_budat-low(4) INTO fecha_ini.
  CONCATENATE s_budat-high+6(2) '.' s_budat-high+4(2) '.' s_budat-high(4) INTO fecha_fin.
  CONCATENATE 'IVA NO RECUPERAB' s_budat-high+6(2) s_budat-high+4(2) s_budat-high(4) INTO v_bktxt.
  w_mode = 'E'.
  tcode = 'FB01'.

  sw_primero = 'S'.
  sec = 0.
  nlineas = 0.
  v_total = 0.

  LOOP AT ti_agrup INTO wa_agrup .



    CLEAR bdcdata.
    WRITE wa_agrup-iva_no_rec  TO v_import CURRENCY 'CLP'.
    if wa_agrup-iva_no_rec < 0.
          v_import = v_import * -1.
          xNEWBS_40 = '50'.
          xNEWBS_50 = '40'.
    else.
          xNEWBS_40 = '40'.
          xNEWBS_50 = '50'.
    endif.


    IF nlineas = 997 .
      "     cierro voucher
      WRITE v_total TO total CURRENCY 'CLP'.
      PERFORM bdc USING:
            '' 'BDC_CURSOR' 'RF05A-NEWBS'
           ,'' 'RF05A-NEWBS' '50'
           ,'' 'BDC_CURSOR' 'RF05A-NEWKO'
           ,'' 'RF05A-NEWKO' '1013310005'

           , 'X' 'SAPLKACB' '0002'
           ,'' 'BDC_CURSOR' 'COBL-KOSTL'
           ,'' 'COBL-KOSTL' v_kostl
           ,'' 'BDC_SUBSCR' 'SAPLKACB                                9999BLOCK1'
           ,'' 'BDC_CURSOR' 'COBL-ZZUNID_PRO'
           ,'' 'COBL-ZZUNID_PRO' v_unid_pro
           ,'' 'BDC_OKCODE' '/00'
           ,'' 'BDC_SUBSCR' 'SAPMF05A 1300APPL_SUB_T'
           ,'' 'BDC_SUBSCR' 'SAPLSEXM 0200APPL_SUB'
           ,'X' 'SAPMF05A' '0300'
           ,'' 'BDC_CURSOR' 'BSEG-WRBTR'
           ,'' 'BSEG-WRBTR' total  "wa_entrada-fch_pago
           ,'' 'BDC_CURSOR' 'BSEG-ZUONR'
           ,'' 'BSEG-ZUONR' v_xblnr
           ,'' 'BDC_CURSOR' 'BSEG-SGTXT'
           ,'' 'BSEG-SGTXT' v_bktxt
           ,'' 'BDC_OKCODE' '/11'.
      PERFORM bdc USING:
           'X' 'SAPLKACB' '0002'
          ,'' 'BDC_OKCODE' '=ENTE'.


      CALL TRANSACTION tcode USING bdcdata MODE w_mode MESSAGES INTO messtab.
      DESCRIBE TABLE messtab LINES lineas.
      READ TABLE messtab INDEX lineas.
      PERFORM convierte_mensaje USING messtab-msgid messtab-msgnr CHANGING mensaje .

      WRITE: /30 mensaje.
      sw_primero = 'S'.
      nlineas = 0.
      v_total = 0.
    ENDIF .

    IF sw_primero = 'S'.
      REFRESH bdcdata.
      sec = sec + 1.
      CONCATENATE 'IVAP' s_budat-high+6(2) s_budat-high+4(2) s_budat-high(4) '_' sec INTO v_xblnr.
      PERFORM bdc USING:
            'X' 'SAPMF05A' '0100'            "ingresa al programa
            ,'' 'BDC_CURSOR' 'BKPF-BLDAT'        "se posiciona en el centro
            ,'' 'BKPF-BLDAT' fecha_fin
            ,'' 'BDC_CURSOR' 'BKPF-BLART'
            ,'' 'BKPF-BLART' 'SA'
            ,'' 'BDC_CURSOR' 'BKPF-BUKRS'
            ,'' 'BKPF-BUKRS' p_bukrs
            ,'' 'BDC_CURSOR' 'BKPF-BUDAT'
            ,'' 'BKPF-BUDAT' fecha_fin
            ,'' 'BDC_CURSOR' 'BKPF-MONAT'
            ,'' 'BKPF-MONAT' fecha_fin+3(2)
            ,'' 'BDC_CURSOR' 'BKPF-WAERS'
            ,'' 'BKPF-WAERS' 'CLP'
            ,'' 'BDC_CURSOR' 'BKPF-XBLNR'
            ,'' 'BKPF-XBLNR' v_xblnr
            ,'' 'BDC_CURSOR' 'BKPF-BKTXT'
            ,'' 'BKPF-BKTXT' v_bktxt.
      PERFORM bdc USING:
        '' 'BDC_CURSOR' 'RF05A-NEWBS'
       ,'' 'RF05A-NEWBS' xNEWBS_40 " '40'
       ,'' 'BDC_CURSOR' 'RF05A-NEWKO'
       ,'' 'RF05A-NEWKO' wa_agrup-hkont
       ,'' 'BDC_OKCODE' '/00'.
      sw_primero = 'N'.
    ELSE.
      PERFORM bdc USING:
        '' 'BDC_CURSOR' 'RF05A-NEWBS'
       ,'' 'RF05A-NEWBS' xNEWBS_40 "'40'
       ,'' 'BDC_CURSOR' 'RF05A-NEWKO'
       ,'' 'RF05A-NEWKO' wa_agrup-hkont
         ,'X' 'SAPLKACB' '0002'
          ,'' 'BDC_OKCODE' '=ENTE'
          ,'' 'BDC_CURSOR' 'COBL-KOSTL'
          ,'' 'COBL-KOSTL' v_kostl
          ,'' 'BDC_SUBSCR' 'SAPLKACB                                9999BLOCK1'
          ,'' 'BDC_CURSOR' 'COBL-ZZUNID_PRO'
          ,'' 'COBL-ZZUNID_PRO' v_unid_pro
          ,'' 'BDC_OKCODE' '/00'.
    ENDIF.



    PERFORM bdc USING:
           'X' 'SAPMF05A' '0300'
          ,'' 'BDC_OKCODE' '/00'
          ,'' 'BDC_CURSOR' 'BSEG-WRBTR'
          ,'' 'BSEG-WRBTR' v_import
          ,'' 'BDC_CURSOR' 'BSEG-ZUONR'
          ,'' 'BSEG-ZUONR' v_xblnr
          ,'' 'BDC_CURSOR' 'BSEG-SGTXT'
          ,'' 'BSEG-SGTXT' v_bktxt
          ,'' 'BDC_OKCODE' '/00'.

    v_unid_pro = wa_agrup-zzunid_pro.
    v_kostl = wa_agrup-kostl.
    nlineas =   nlineas +  1.
    v_total = v_total + wa_agrup-iva_no_rec.
  ENDLOOP.



  IF nlineas > 0 .
    "     cierro voucher
    WRITE v_total TO total CURRENCY 'CLP'.
    PERFORM bdc USING:
           '' 'BDC_CURSOR' 'RF05A-NEWBS'
          ,'' 'RF05A-NEWBS' '50'
          ,'' 'BDC_CURSOR' 'RF05A-NEWKO'
          ,'' 'RF05A-NEWKO' '1013310005'

          , 'X' 'SAPLKACB' '0002'
          ,'' 'BDC_CURSOR' 'COBL-KOSTL'
          ,'' 'COBL-KOSTL' v_kostl
          ,'' 'BDC_SUBSCR' 'SAPLKACB                                9999BLOCK1'
          ,'' 'BDC_CURSOR' 'COBL-ZZUNID_PRO'
          ,'' 'COBL-ZZUNID_PRO' v_unid_pro
          ,'' 'BDC_OKCODE' '/00'
          ,'' 'BDC_SUBSCR' 'SAPMF05A 1300APPL_SUB_T'
          ,'' 'BDC_SUBSCR' 'SAPLSEXM 0200APPL_SUB'
          ,'X' 'SAPMF05A' '0300'
          ,'' 'BDC_CURSOR' 'BSEG-WRBTR'
          ,'' 'BSEG-WRBTR' total  "wa_entrada-fch_pago
          ,'' 'BDC_CURSOR' 'BSEG-ZUONR'
          ,'' 'BSEG-ZUONR' v_xblnr
          ,'' 'BDC_CURSOR' 'BSEG-SGTXT'
          ,'' 'BSEG-SGTXT' v_bktxt
          ,'' 'BDC_OKCODE' '/11'.
    PERFORM bdc USING:
               'X' 'SAPLKACB' '0002'
              ,'' 'BDC_OKCODE' '=ENTE'.
    CALL TRANSACTION tcode USING bdcdata MODE w_mode MESSAGES INTO messtab.
    DESCRIBE TABLE messtab LINES lineas.
    READ TABLE messtab INDEX lineas.
    PERFORM convierte_mensaje USING messtab-msgid messtab-msgnr CHANGING mensaje .

    WRITE: /30 mensaje.
  ENDIF.

  ENDIF.
* } SCL26122017
ENDFORM.                    "contabilizar



*form contabilizar.
*
*      SORT ti_salida  ASCENDING BY hkont zzunid_pro.
*      REFRESH ti_agrup.
*      CLEAR : cta_aux, unid_pro_aux, kostl_aux.
*      LOOP AT ti_salida INTO wa_salida.
*        IF cta_aux IS INITIAL AND unid_pro_aux IS INITIAL.
*          wa_agrup-hkont = wa_salida-hkont.
*          wa_agrup-kostl      = wa_salida-kostl.
*          wa_agrup-zzunid_pro = wa_salida-zzunid_pro.
*          wa_agrup-iva_no_rec = wa_agrup-iva_no_rec + wa_salida-iva_no_rec.
*
*
*        ELSEIF cta_aux EQ wa_salida-hkont AND unid_pro_aux EQ wa_salida-zzunid_pro AND kostl_aux EQ wa_salida-kostl.
*          wa_agrup-hkont = wa_salida-hkont.
*          wa_agrup-kostl = wa_salida-kostl.
*          wa_agrup-zzunid_pro = wa_salida-zzunid_pro.
*          wa_agrup-iva_no_rec = wa_agrup-iva_no_rec + wa_salida-iva_no_rec.
*        ELSE.
*          APPEND wa_agrup TO ti_agrup.
*          CLEAR wa_agrup.
*          wa_agrup-hkont = wa_salida-hkont.
*          wa_agrup-kostl = wa_salida-kostl.
*          wa_agrup-zzunid_pro = wa_salida-zzunid_pro.
*          wa_agrup-iva_no_rec = wa_agrup-iva_no_rec + wa_salida-iva_no_rec.
*        ENDIF.
*        cta_aux      = wa_salida-hkont.
*        unid_pro_aux = wa_salida-zzunid_pro.
*        kostl_aux    = wa_salida-kostl.
*      ENDLOOP.
*      APPEND wa_agrup TO ti_agrup.
*
*      DESCRIBE TABLE ti_agrup LINES v_lineas.
*
**--------------------------------------------------------------------*
**      batch input
**--------------------------------------------------------------------*
*     PERFORM datos_batch.
*
*
*      w_mode = 'E'.
*      tcode = 'FB01'.
*
*      REFRESH bdcdata.
*      CLEAR bdcdata.
*
*      READ TABLE ti_agrup INTO wa_agrup INDEX 1.
*      PERFORM bdc USING:
*
*            'X' 'SAPMF05A' '0100'            "ingresa al programa
*            ,'' 'BDC_CURSOR' 'BKPF-BLDAT'        "se posiciona en el centro
*            ,'' 'BKPF-BLDAT' fecha_fin
*            ,'' 'BDC_CURSOR' 'BKPF-BLART'
*            ,'' 'BKPF-BLART' 'SA'
*            ,'' 'BDC_CURSOR' 'BKPF-BUKRS'
*            ,'' 'BKPF-BUKRS' p_bukrs
*            ,'' 'BDC_CURSOR' 'BKPF-BUDAT'
*            ,'' 'BKPF-BUDAT' fecha_fin
*            ,'' 'BDC_CURSOR' 'BKPF-MONAT'
*            ,'' 'BKPF-MONAT' fecha_fin+3(2)
*            ,'' 'BDC_CURSOR' 'BKPF-WAERS'
*            ,'' 'BKPF-WAERS' 'CLP'
*            ,'' 'BDC_CURSOR' 'BKPF-XBLNR'
*            ,'' 'BKPF-XBLNR' v_xblnr
*            ,'' 'BDC_CURSOR' 'BKPF-BKTXT'
*            ,'' 'BKPF-BKTXT' v_bktxt
*            ,'' 'BDC_CURSOR' 'RF05A-NEWBS'
*            ,'' 'RF05A-NEWBS' '50'
*            ,'' 'BDC_CURSOR' 'RF05A-NEWKO'
*            ,'' 'RF05A-NEWKO' '1013310005'
*            ,'' 'BDC_SUBSCR' 'SAPMF05A 1300APPL_SUB_T'
*            ,'' 'BDC_SUBSCR' 'SAPLSEXM 0200APPL_SUB'
*            ,'' 'BDC_OKCODE' '/00'
*             ,'X' 'SAPMF05A' '0300'
*             ,'' 'BDC_CURSOR' 'BSEG-WRBTR'
*             ,'' 'BSEG-WRBTR' total  "wa_entrada-fch_pago
*             ,'' 'BDC_CURSOR' 'BSEG-ZUONR'
*             ,'' 'BSEG-ZUONR' v_xblnr
*             ,'' 'BDC_CURSOR' 'BSEG-SGTXT'
*             ,'' 'BSEG-SGTXT' v_bktxt
*             ,'' 'BDC_CURSOR' 'RF05A-NEWBS'
*             ,'' 'RF05A-NEWBS' '40'
*             ,'' 'BDC_CURSOR' 'RF05A-NEWKO'
*             ,'' 'RF05A-NEWKO' wa_agrup-hkont
*             ,'' 'BDC_SUBSCR' 'SAPLKACB                                0001BLOCK'
*             ,'' 'DKACB-FMORE' ''
**
**
**          ,'X' 'SAPLKACB' '0002'
***          ,'' 'BDC_OKCODE' '=ENTE'
**          ,'' 'BDC_CURSOR' 'COBL-KOSTL'
**          ,'' 'COBL-KOSTL' 'CL12092000'"'CL12090011'
**          ,'' 'BDC_SUBSCR' 'SAPLKACB                                9999BLOCK1'
**          ,'' 'BDC_CURSOR' 'COBL-ZZUNID_PRO'
**          ,'' 'COBL-ZZUNID_PRO' wa_agrup-zzunid_pro
**          ,'' 'BDC_OKCODE' '/00'.
*
*
*             ,'' 'BDC_OKCODE' '/00'.
*
**    v_import = wa_agrup-wrbtr.
*      WRITE wa_agrup-iva_no_rec TO v_import CURRENCY 'CLP'.
*      v_unid_pro = wa_agrup-zzunid_pro.
*      v_kostl = wa_agrup-kostl.
*      DELETE ti_agrup INDEX 1.
*
*      LOOP AT ti_agrup INTO wa_agrup.
*
*        PERFORM bdc USING:
*              'X' 'SAPMF05A' '0300'
*              ,'' 'BDC_CURSOR' 'BSEG-WRBTR'
*              ,'' 'BSEG-WRBTR' v_import
*              ,'' 'BDC_CURSOR' 'BSEG-ZUONR'
*              ,'' 'BSEG-ZUONR' v_xblnr
*              ,'' 'BDC_CURSOR' 'BSEG-SGTXT'
*              ,'' 'BSEG-SGTXT' v_bktxt
*              ,'' 'BDC_CURSOR' 'RF05A-NEWBS'
*              ,'' 'RF05A-NEWBS' '40'
*              ,'' 'BDC_CURSOR' 'RF05A-NEWKO'
*              ,'' 'RF05A-NEWKO' wa_agrup-hkont
*              ,'' 'BDC_SUBSCR' 'SAPLKACB                                0001BLOCK'
*              ,'' 'DKACB-FMORE' 'X'
*              ,'X' 'SAPLKACB' '0002'
*              ,'' 'BDC_OKCODE' '=ENTE'
*              ,'' 'BDC_CURSOR' 'COBL-KOSTL'
*              ,'' 'COBL-KOSTL' v_kostl
*              ,'' 'BDC_SUBSCR' 'SAPLKACB                                9999BLOCK1'
*              ,'' 'BDC_CURSOR' 'COBL-ZZUNID_PRO'
*              ,'' 'COBL-ZZUNID_PRO' v_unid_pro
*              ,'' 'BDC_OKCODE' '/00'.
*
**    v_import = wa_agrup-wrbtr.
*        WRITE wa_agrup-iva_no_rec TO v_import CURRENCY 'CLP'.
*        v_unid_pro = wa_agrup-zzunid_pro.
*        v_kostl = wa_agrup-kostl.
*
*      ENDLOOP.
*
*      PERFORM bdc USING:
*            'X' 'SAPMF05A' '0300'
*            ,'' 'BDC_CURSOR' 'BSEG-WRBTR'
*            ,'' 'BSEG-WRBTR' v_import
*            ,'' 'BDC_CURSOR' 'BSEG-ZUONR'
*            ,'' 'BSEG-ZUONR' v_xblnr
*            ,'' 'BDC_CURSOR' 'BSEG-SGTXT'
*            ,'' 'BSEG-SGTXT' v_bktxt
**          ,'' 'BDC_CURSOR' 'RF05A-NEWBS'
**          ,'' 'RF05A-NEWBS' ''
**          ,'' 'BDC_CURSOR' 'RF05A-NEWKO'
**          ,'' 'RF05A-NEWKO' ''
*            ,'' 'BDC_SUBSCR' 'SAPLKACB                                0001BLOCK'
*            ,'' 'DKACB-FMORE' 'X'
*            ,'X' 'SAPLKACB' '0002'
*            ,'' 'BDC_OKCODE' '=ENTE'
*            ,'' 'BDC_CURSOR' 'COBL-KOSTL'
*            ,'' 'COBL-KOSTL' v_kostl
*            ,'' 'BDC_SUBSCR' 'SAPLKACB                                9999BLOCK1'
*            ,'' 'BDC_CURSOR' 'COBL-ZZUNID_PRO'
*            ,'' 'COBL-ZZUNID_PRO' v_unid_pro
*            ,'' 'BDC_OKCODE' '/00'
*            ,'X' 'SAPMF05A' '0300'
*            ,'' 'BDC_OKCODE' '/11'.
*
*
*
*      CALL TRANSACTION tcode USING bdcdata MODE w_mode MESSAGES INTO messtab.
*
*      DATA lineas TYPE i.
*      DATA mens   TYPE char50.
*      DESCRIBE TABLE messtab LINES lineas.
*      READ TABLE messtab INDEX lineas.
*
** select single text
**   into mens
**   from t100
**   where SPRSL eq 'S'
**     and ARBGB eq messtab-msgid
**     and MSGNR eq messtab-msgnr.
*
*      PERFORM convierte_mensaje USING messtab-msgid messtab-msgnr CHANGING mens.
*      MESSAGE : mens TYPE 'S' DISPLAY LIKE 'I'.
*
**--------------------------------------------------------------------*
**--------------------------------------------------------------------*
*
*
*  ENDCASE.
*ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  BDC
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM bdc  USING    a
      b
      c.

  CLEAR bdcdata.
  IF a = 'X'.
    bdcdata-program   = b.
    bdcdata-dynpro    = c.
    bdcdata-dynbegin  = a.
  ELSE.
    bdcdata-fnam = b.
    WRITE c TO bdcdata-fval LEFT-JUSTIFIED.
  ENDIF.
  APPEND bdcdata.

ENDFORM.                    " BDC
*&---------------------------------------------------------------------*
*&      Form  DATOS_BATCH
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM datos_batch .
  WRITE v_total TO total CURRENCY 'CLP'.

  CONCATENATE s_budat-low+6(2) '.' s_budat-low+4(2) '.' s_budat-low(4) INTO fecha_ini.
  CONCATENATE s_budat-high+6(2) '.' s_budat-high+4(2) '.' s_budat-high(4) INTO fecha_fin.

  CONCATENATE 'IVAPROP' s_budat-high+6(2) s_budat-high+4(2) s_budat-high(4) INTO v_xblnr.
  CONCATENATE 'IVA NO RECUPERAB' s_budat-high+6(2) s_budat-high+4(2) s_budat-high(4) INTO v_bktxt.

ENDFORM.                    " DATOS_BATCH
*&---------------------------------------------------------------------*
*&      Form  CONVIERTE_MENSAJE
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*

FORM convierte_mensaje  USING    p_sy_msgid
      p_sy_msgno
CHANGING return_message.

  SELECT SINGLE *
   FROM t100
   WHERE sprsl EQ 'S'
     AND arbgb EQ messtab-msgid
     AND msgnr EQ messtab-msgnr.
  IF sy-subrc = 0.
    return_message = t100-text.
    IF return_message CS '&1'.
      REPLACE '&1' WITH sy-msgv1 INTO return_message.
      REPLACE '&2' WITH sy-msgv2 INTO return_message.
      REPLACE '&3' WITH sy-msgv3 INTO return_message.
      REPLACE '&4' WITH sy-msgv4 INTO return_message.
    ELSE.
      REPLACE FIRST OCCURRENCE OF '&' IN return_message WITH sy-msgv1.
      REPLACE FIRST OCCURRENCE OF '&' IN return_message WITH sy-msgv2.
      REPLACE FIRST OCCURRENCE OF '&' IN return_message WITH sy-msgv3.
      REPLACE FIRST OCCURRENCE OF '&' IN return_message WITH sy-msgv4.
*      REPLACE '&' WITH sy-msgv1 INTO return_message.
*      REPLACE '&' WITH sy-msgv2 INTO return_message.
*      REPLACE '&' WITH sy-msgv3 INTO return_message.
*      REPLACE '&' WITH sy-msgv4 INTO return_message.
    ENDIF.
    CONDENSE return_message.
  ENDIF.

ENDFORM.                    " CONVIERTE_MENSAJE

AT USER-COMMAND.

  CASE sy-ucomm.
    WHEN '&F03'.
      LEAVE TO SCREEN  0.
    WHEN '&F15'.
      LEAVE TO SCREEN  0.
    WHEN '&F12'.
      LEAVE PROGRAM.
  ENDCASE.
