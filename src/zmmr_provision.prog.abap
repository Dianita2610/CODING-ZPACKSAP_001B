*&---------------------------------------------------------------------*
*& Report  ZMMR_PROVISION
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zmmr_provision.

TYPE-POOLS: truxs.

CLASS: lcl_event_alv DEFINITION DEFERRED,
       lcl_report    DEFINITION DEFERRED.



*&---------------------------------------------------------------------*
*&  DATOS
*&---------------------------------------------------------------------*
TABLES: ekko,
        ekpo,
        eket,
        lfa1.

FIELD-SYMBOLS: <fs_tab> TYPE STANDARD TABLE.

TYPES:
       BEGIN OF ty_col,
        string TYPE char100,
       END OF ty_col,

       BEGIN OF ty_detail,
         bukrs TYPE ekko-bukrs,
         lifnr TYPE ekko-lifnr,
*         stcd1 TYPE lfa1-stcd1,
         ebeln TYPE ekko-ebeln,
         ebelp TYPE ekpo-ebelp,
         bsart TYPE ekko-bsart,
         bstyp TYPE ekko-bstyp,
         ekgrp TYPE ekko-ekgrp,
         bedat TYPE ekko-bedat,
         matnr TYPE ekpo-matnr,
         txz01 TYPE ekpo-txz01,
         matkl TYPE ekpo-matkl,
         loekz TYPE ekpo-loekz,
         pstyp TYPE ekpo-pstyp,
         knttp TYPE ekpo-knttp,
         eindt TYPE eket-eindt,
         werks TYPE ekpo-werks,
         menge TYPE ekpo-menge,
         meins TYPE ekpo-meins,
         netpr TYPE ekpo-netpr,
         netwr TYPE ekkn-netwr,
         waers TYPE ekko-waers,
         peinh TYPE ekpo-peinh,
         ktmng TYPE ekpo-ktmng,
         lgort TYPE ekpo-lgort,
         sakto TYPE ekkn-sakto,
         kostl TYPE ekkn-kostl,
         mwskz TYPE ekpo-mwskz,
         zzunid_pro  TYPE ekkn-zzunid_pro,
         zzrut_terc  TYPE mseg-zzrut_terc,
         vproz       TYPE ekkn-vproz,
         to_calc     TYPE bset-lwste, " ekpo-netpr,
         to_porc     TYPE bset-lwste,
         lwste       TYPE bset-lwste,
         to_prov     TYPE bset-lwste,
         to_delv     TYPE bset-lwste, " ekpo-netpr,
       END OF ty_detail,

       BEGIN OF ty_file,
         username	  TYPE sy-uname,
         header_txt	TYPE char70,
         comp_code  TYPE bukrs,
         doc_date   TYPE char08, " ebdat,
         pstng_date TYPE char08, " ebdat,
         doc_type   TYPE esart,
         ref_doc_no TYPE ebeln,
         area_contab TYPE char02,
         key         TYPE numc_5,
         itemno_acc  TYPE ebelp,
         vendor_no   TYPE elifn,
         customer    TYPE kunnr,
         hkont       TYPE saknr,
         sgtxt       TYPE char70,
         tax_code    TYPE mwskz,
         costcenter  TYPE kostl,
         profit_ctr  TYPE prctr,
         pmnttrms    TYPE char10,
         bline_date  TYPE char08, " ebdat,
         pymt_meth   TYPE char10,
         pmnt_block  TYPE char10,
         alloc_nmbr  TYPE char10,
         wt_type     TYPE char10,
         wt_code     TYPE char10,
         ref_key1    TYPE char10,
         ref_key2    TYPE char10,
         id_agencia  TYPE char10,
         currency    TYPE waers,
*         amt_doccur  TYPE bwert,
         amt_doccur  TYPE char13,
         amt_base    TYPE bwert,
         zzprestac   TYPE zzprestac,    " Prestación
         zzunid_prod TYPE zzunid_prod,  " Códigos de Descuento y Códigos de Estamento
         zzdesc_est  TYPE zzdesc_est,   " Códigos de Descuento y Códigos de Estamento
         zzmot_emis  TYPE zzmot_emis,   " Motivos de emisión
         zzrut_terc  TYPE zzrut_terc,   " RUT de terceros (Gestión)
         zz_agencia  TYPE zz_agencia,   " Códigos de Agencia
         fdlev       TYPE char10,
         atributo_8  TYPE char10,
         alt_payee   TYPE char10,
         iva         TYPE char10,
         bank_id     TYPE char10,
         hktid       TYPE char10,
         aufnr       TYPE aufnr,
       END OF ty_file.

DATA:
     BEGIN OF gt_ekbe_we OCCURS 0, " Historial del documento de compras
        ebeln TYPE ekbe-ebeln,
        ebelp TYPE ekbe-ebelp,
        zekkn TYPE ekbe-zekkn,
        vgabe TYPE ekbe-vgabe,
        gjahr TYPE ekbe-gjahr,
        belnr TYPE ekbe-belnr,
        buzei TYPE ekbe-buzei,
        bewtp TYPE ekbe-bewtp,
        budat TYPE ekbe-budat,
        dmbtr TYPE ekbe-dmbtr,
        arewr TYPE ekbe-arewr,
        shkzg TYPE ekbe-shkzg,
        lfgja TYPE ekbe-lfgja,
        waers TYPE ekbe-waers,
        wrbtr TYPE ekbe-wrbtr,
      END OF gt_ekbe_we,

      BEGIN OF gt_mseg OCCURS 0,
        mblnr      TYPE mseg-mblnr,
        mjahr      TYPE mseg-mjahr,
        zeile      TYPE mseg-zeile,
        line_id    TYPE mseg-line_id,
        werks      TYPE mseg-werks,
        lgort      TYPE mseg-lgort,
        kostl      TYPE mseg-kostl,
        zzunid_pro TYPE mseg-zzunid_pro,
        zzrut_terc TYPE mseg-zzrut_terc,
      END OF gt_mseg,

      BEGIN OF gt_rseg OCCURS 0,
        belnr TYPE rseg-belnr,
        gjahr TYPE rseg-gjahr,
        buzei TYPE rseg-buzei,
        budat TYPE rbkp-budat,
        waers TYPE rbkp-waers,
        ebeln TYPE rseg-ebeln,
        ebelp TYPE rseg-ebelp,
        wrbtr TYPE rseg-wrbtr,
        shkzg TYPE rseg-shkzg,
      END OF gt_rseg,

      BEGIN OF gt_imp OCCURS 0,
        mwskz TYPE a003-mwskz,
        knumh TYPE a003-knumh,
        kbetr TYPE konp-kbetr,
      END OF gt_imp,

      BEGIN OF gt_header OCCURS 0,
        value(50) TYPE c,
      END OF gt_header.

DATA: BEGIN OF gs_header,
         username(25)	  TYPE c,
         header_txt(25)	TYPE c,
         comp_code(25)  TYPE c,
         doc_date(25)   TYPE c, " ebdat,
         pstng_date(25) TYPE c, " ebdat,
         doc_type(25)   TYPE c,
         ref_doc_no(25) TYPE c,
         area_contab(25) TYPE c,
         key(25)         TYPE c,
         itemno_acc(25)  TYPE c,
         vendor_no(25)   TYPE c,
         customer(25)    TYPE c,
         hkont(25)       TYPE c,
         sgtxt(25)       TYPE c,
         tax_code(25)    TYPE c,
         costcenter(25)  TYPE c,
         profit_ctr(25)  TYPE c,
         pmnttrms(25)    TYPE c,
         bline_date(25)  TYPE c, " ebdat,
         pymt_meth(25)   TYPE c,
         pmnt_block(25)  TYPE c,
         alloc_nmbr(25)  TYPE c,
         wt_type(25)     TYPE c,
         wt_code(25)     TYPE c,
         ref_key1(25)    TYPE c,
         ref_key2(25)    TYPE c,
         id_agencia(25)  TYPE c,
         currency(25)    TYPE c,
         amt_doccur(25)  TYPE c,
         amt_base(25)    TYPE c,
         zzprestac(25)   TYPE c,    " Prestación
         zzunid_prod(25) TYPE c,  " Códigos de Descuento y Códigos de Estamento
         zzdesc_est(25)  TYPE c,   " Códigos de Descuento y Códigos de Estamento
         zzmot_emis(25)  TYPE c,   " Motivos de emisión
         zzrut_terc(25)  TYPE c,   " RUT de terceros (Gestión)
         zz_agencia(25)  TYPE c,   " Códigos de Agencia
         fdlev(25)       TYPE c,
         atributo_8(25)  TYPE c,
         alt_payee(25)   TYPE c,
         iva(25)         TYPE c,
         bank_id(25)     TYPE c,
         hktid(25)       TYPE c,
         aufnr(25)       TYPE c,
      END OF gs_header,

      gt_header_csv LIKE TABLE OF gs_header.

DATA: go_event     TYPE REF TO lcl_event_alv,
      go_report    TYPE REF TO lcl_report,
      gr_events    TYPE REF TO cl_salv_events_table,
      gr_functions TYPE REF TO cl_salv_functions,
      gr_aggs      TYPE REF TO cl_salv_aggregations,
      gr_columns   TYPE REF TO cl_salv_columns_table,
      gr_column    TYPE REF TO cl_salv_column_table,
      gr_sorts     TYPE REF TO cl_salv_sorts.

DATA: gt_result TYPE STANDARD TABLE OF ty_detail,
      gs_result LIKE LINE OF gt_result,
      gt_ekko   TYPE STANDARD TABLE OF ekko WITH HEADER LINE,
      gt_ekpo   TYPE STANDARD TABLE OF ekpo WITH HEADER LINE,
      gt_file TYPE STANDARD TABLE OF ty_file,
      gs_file LIKE LINE OF gt_file.

DATA: g_ukurs TYPE ukurs_curr,
      g_factor_local TYPE tfact_curr.

DATA: gv_def_path TYPE string,
      gv_wn_title TYPE string.

DATA: gt_head TYPE truxs_t_text_data,
      gt_data TYPE truxs_t_text_data.

FIELD-SYMBOLS: <fs_res> LIKE LINE OF gt_result.
*&---------------------------------------------------------------------*
*&  DATOS DE SELECCION
*&---------------------------------------------------------------------*
SELECTION-SCREEN  BEGIN OF BLOCK b1 WITH FRAME TITLE text-003.
SELECT-OPTIONS: so_BUKRS FOR ekko-BUKRS,"HCD FILTRO EMPRESA 29082019
                so_lifnr FOR ekko-lifnr,
                so_ekorg FOR ekko-ekorg,
                so_bsart FOR ekko-bsart,
                so_ekgrp FOR ekko-ekgrp,
                so_werks FOR ekpo-werks,
                so_pstyp FOR ekpo-pstyp,
                so_knttp FOR ekpo-knttp,
                so_eindt FOR eket-eindt NO-EXTENSION,
                so_ebeln FOR ekko-ebeln,
                so_matnr FOR ekpo-matnr,
                so_matkl FOR ekpo-matkl,
                so_bedat FOR ekko-bedat OBLIGATORY,
                so_ean11 FOR ekpo-ean11,
                so_idnlf FOR ekpo-idnlf,
                so_ltsnr FOR ekpo-ltsnr,
                so_aktnr FOR ekpo-aktnr,
                so_saiso FOR ekpo-saiso,
                so_saisj FOR ekpo-saisj,
                so_txz01 FOR ekpo-txz01 NO-EXTENSION NO INTERVALS,
                so_name1 FOR lfa1-name1 NO-EXTENSION NO INTERVALS,
                so_loekz FOR ekpo-loekz NO-EXTENSION NO INTERVALS.

SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN  BEGIN OF BLOCK b2 WITH FRAME TITLE text-004.
PARAMETERS: p_layout LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK b2.

INCLUDE zmmr_provision_cd1.

INCLUDE zmmr_provision_ci1.

*&---------------------------------------------------------------------*
*&  EVENTOS
*&---------------------------------------------------------------------*

INITIALIZATION.

  PERFORM built_csv_header.
  PERFORM built_xls_header.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_layout.
  PERFORM select_layout.

AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    IF screen-name = 'SO_BEDAT-HIGH'. " Required
      screen-required = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

START-OF-SELECTION.

  PERFORM get_data.
  PERFORM process_data.

  IF gt_result[] IS NOT INITIAL.

    CREATE OBJECT go_report
      EXPORTING
        iv_tabnam = 'GT_RESULT[]'.
    IF go_report IS BOUND.
      go_report->built_alv( ).
    ENDIF.
  ELSE.
    MESSAGE text-001 TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

*&---------------------------------------------------------------------*
*&  RUTINAS FORM
*&---------------------------------------------------------------------*

FORM get_data.

  SELECT a~bukrs a~lifnr a~ebeln b~ebelp a~bsart a~bstyp a~ekgrp a~bedat b~matnr b~txz01
    b~matkl b~loekz b~pstyp b~knttp d~eindt b~werks b~menge b~meins b~netpr e~netwr a~waers b~peinh b~ktmng
    b~lgort e~sakto e~kostl b~mwskz e~zzunid_pro c~stcd1 e~vproz
      FROM ekko AS a INNER JOIN ekpo AS b ON a~ebeln = b~ebeln
        INNER JOIN eket AS d ON b~ebeln = d~ebeln AND b~ebelp = d~ebelp
        INNER JOIN lfa1 AS c ON a~lifnr = c~lifnr
        INNER JOIN ekkn AS e ON b~ebeln = e~ebeln AND b~ebelp = e~ebelp
        INTO TABLE gt_result
        WHERE a~ebeln IN so_ebeln
          and a~bukrs  IN so_bukrs "HCD FILTRO EMPRESA 29082019
          AND a~bsart IN so_bsart
          AND a~lifnr IN so_lifnr
          AND a~ekorg IN so_ekorg
          AND a~ekgrp IN so_ekgrp
          AND a~bedat IN so_bedat
          AND b~matnr IN so_matnr
          AND b~werks IN so_werks
          AND b~txz01 IN so_txz01
          AND b~matkl IN so_matkl
          AND b~idnlf IN so_idnlf
          AND b~pstyp IN so_pstyp
          AND b~knttp IN so_knttp
          AND b~ean11 IN so_ean11
          AND b~ltsnr IN so_ltsnr
          AND b~aktnr IN so_aktnr
          AND b~saiso IN so_saiso
          AND b~saisj IN so_saisj
*          AND d~eindt IN so_eindt
          AND b~loekz IN so_loekz
          AND c~name1 IN so_name1.

  IF gt_result[] IS NOT INITIAL.

    IF so_eindt-low IS NOT INITIAL AND so_eindt-high IS NOT INITIAL.
      DELETE gt_result WHERE eindt < so_eindt-low OR eindt > so_eindt-high.
    ELSEIF so_eindt-low IS NOT INITIAL AND so_eindt-high IS INITIAL.
      DELETE gt_result WHERE eindt <> so_eindt-low.
    ELSEIF so_eindt-low IS INITIAL AND so_eindt-high IS NOT INITIAL.
      DELETE gt_result WHERE eindt <> so_eindt-high.
    ENDIF.


    SELECT b~belnr b~gjahr b~buzei a~budat a~waers b~ebeln b~ebelp b~wrbtr b~shkzg FROM rbkp AS a INNER JOIN rseg AS b
      ON a~belnr = b~belnr AND a~gjahr = b~gjahr
      INTO TABLE gt_rseg
      FOR ALL ENTRIES IN gt_result
        WHERE b~ebeln = gt_result-ebeln
          AND b~ebelp = gt_result-ebelp.

* / Get document historical data
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT ebeln ebelp zekkn vgabe gjahr belnr buzei bewtp budat dmbtr arewr shkzg lfgja waers wrbtr
*      FROM ekbe INTO TABLE gt_ekbe_we
*        FOR ALL ENTRIES IN gt_result
*          WHERE ebeln = gt_result-ebeln
*            AND ebelp = gt_result-ebelp
*            AND bewtp = 'E'. 
*
* NEW CODE
    SELECT ebeln ebelp zekkn vgabe gjahr belnr buzei bewtp budat dmbtr arewr shkzg lfgja waers wrbtr

      FROM ekbe INTO TABLE gt_ekbe_we
        FOR ALL ENTRIES IN gt_result
          WHERE ebeln = gt_result-ebeln
            AND ebelp = gt_result-ebelp
            AND bewtp = 'E' ORDER BY PRIMARY KEY. 

* END. 08-07-2026 - ATC - ATC-03" Only WE

    SELECT a~mwskz a~knumh b~kbetr INTO TABLE gt_imp FROM a003 AS a INNER JOIN konp AS b ON a~knumh = b~knumh
      FOR ALL ENTRIES IN gt_result
      WHERE a~aland = 'CL'
        AND a~mwskz = gt_result-mwskz.
  ENDIF.

  IF gt_ekbe_we[] IS NOT INITIAL.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT mblnr mjahr zeile line_id werks lgort kostl zzunid_pro zzrut_terc FROM mseg
*      INTO TABLE gt_mseg FOR ALL ENTRIES IN gt_ekbe_we
*        WHERE mblnr = gt_ekbe_we-belnr
*          AND mjahr = gt_ekbe_we-gjahr
*          AND zeile = gt_ekbe_we-buzei.
*
* NEW CODE
    SELECT mblnr mjahr zeile line_id werks lgort kostl zzunid_pro zzrut_terc
 FROM mseg
      INTO TABLE gt_mseg FOR ALL ENTRIES IN gt_ekbe_we
        WHERE mblnr = gt_ekbe_we-belnr
          AND mjahr = gt_ekbe_we-gjahr
          AND zeile = gt_ekbe_we-buzei ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

  ENDIF.


ENDFORM.                    "get_data

*&---------------------------------------------------------------------*
*&      Form  process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM process_data.

  LOOP AT gt_result ASSIGNING <fs_res>.

*    IF <fs_res>-netwr IS INITIAL.
*      <fs_res>-netwr = <fs_res>-netpr.
*    ENDIF.

    IF <fs_res>-peinh > 1.
      <fs_res>-netpr = <fs_res>-netpr.
    ELSE.
      <fs_res>-netpr = <fs_res>-netpr * <fs_res>-menge.
    ENDIF.

    <fs_res>-to_calc = <fs_res>-netpr.

    READ TABLE gt_ekbe_we WITH KEY ebeln = <fs_res>-ebeln
                                   ebelp = <fs_res>-ebelp.
    IF sy-subrc = 0.
      READ TABLE gt_mseg WITH KEY mblnr = gt_ekbe_we-belnr
                                  mjahr = gt_ekbe_we-gjahr
                                  zeile = gt_ekbe_we-buzei.
      IF sy-subrc = 0.
*        <fs_res>-lgort = gt_mseg-lgort.
*        <fs_res>-kostl = gt_mseg-kostl.
*        <fs_res>-zzunid_pro = gt_mseg-zzunid_pro.
*        <fs_res>-zzrut_terc = gt_mseg-zzrut_terc.
      ENDIF.
    ENDIF.

*    LOOP AT gt_rseg WHERE ebeln = <fs_res>-ebeln
*                      AND ebelp = <fs_res>-ebelp.
*
*      IF gt_rseg-waers <> <fs_res>-waers.
*        CALL FUNCTION 'READ_EXCHANGE_RATE'
*          EXPORTING
*            date             = gt_rseg-budat
*            foreign_currency = gt_rseg-waers
*            local_currency   = <fs_res>-waers
*            type_of_rate     = 'M'
*            exact_date       = ' '
*          IMPORTING
*            exchange_rate    = g_ukurs
*            local_factor     = g_factor_local.
*
*        gt_rseg-wrbtr = gt_rseg-wrbtr / ( g_ukurs * g_factor_local ).
*        gt_rseg-wrbtr = gt_rseg-wrbtr / 10.
*        IF gt_rseg-wrbtr < 0.
*          gt_rseg-wrbtr = gt_rseg-wrbtr * -1.
*        ENDIF.
*      ENDIF.
*
*
*      IF gt_rseg-shkzg EQ 'S'.
*        <fs_res>-to_calc = <fs_res>-to_calc - gt_rseg-wrbtr.
*        <fs_res>-to_delv = <fs_res>-to_delv + ( gt_rseg-wrbtr )." <fs_res>-netpr - <fs_res>-to_calc.
*      ELSE.
*        <fs_res>-to_calc = <fs_res>-to_calc - ( gt_rseg-wrbtr * -1 ).
*        <fs_res>-to_delv = <fs_res>-to_delv + ( gt_rseg-wrbtr * -1 ). " <fs_res>-netpr - <fs_res>-to_calc.
*      ENDIF.
*
*    ENDLOOP.


    LOOP AT gt_ekbe_we WHERE ebeln = <fs_res>-ebeln
                         AND ebelp = <fs_res>-ebelp.




      IF gt_ekbe_we-shkzg EQ 'S'.
        <fs_res>-to_calc = <fs_res>-to_calc -  gt_ekbe_we-wrbtr.
        <fs_res>-to_delv = <fs_res>-to_delv + ( gt_ekbe_we-wrbtr )." <fs_res>-netpr - <fs_res>-to_calc.
      ELSE.
        <fs_res>-to_calc = <fs_res>-to_calc - ( gt_ekbe_we-wrbtr * -1 ).
        <fs_res>-to_delv = <fs_res>-to_delv + ( gt_ekbe_we-wrbtr * -1 ). " <fs_res>-netpr - <fs_res>-to_calc.
      ENDIF.

    ENDLOOP.


    IF <fs_res>-vproz IS NOT INITIAL.
      <fs_res>-to_porc = ( <fs_res>-to_calc * <fs_res>-vproz ) / 100.
      <fs_res>-to_calc = ( <fs_res>-to_calc * <fs_res>-vproz ) / 100.
    ELSE.
      IF gt_ekbe_we[] IS NOT INITIAL.
        <fs_res>-to_porc = <fs_res>-to_calc.
      ELSE.
        <fs_res>-to_porc = <fs_res>-to_calc * 100.
      ENDIF.
    ENDIF.

    IF <fs_res>-waers <> 'CLP'.

      CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
        EXPORTING
         client                  = sy-mandt
          date                    = <fs_res>-bedat
          foreign_amount          = <fs_res>-to_calc
          foreign_currency        = <fs_res>-waers
          local_currency          = 'CLP'
*         RATE                    = 0
*         TYPE_OF_RATE            = 'M'
*         READ_TCURR              = 'X'
       IMPORTING
*         EXCHANGE_RATE           =
*         FOREIGN_FACTOR          =
         local_amount            = <fs_res>-lwste
*         LOCAL_FACTOR            =
*         EXCHANGE_RATEX          =
*         FIXED_RATE              =
*         DERIVED_RATE_TYPE       =
*       EXCEPTIONS
*         NO_RATE_FOUND           = 1
*         OVERFLOW                = 2
*         NO_FACTORS_FOUND        = 3
*         NO_SPREAD_FOUND         = 4
*         DERIVED_2_TIMES         = 5
*         OTHERS                  = 6
                .
      IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      IF <fs_res>-lwste IS NOT INITIAL.
        <fs_res>-lwste = <fs_res>-lwste * 100.
      ENDIF.

    ELSE.
      <fs_res>-lwste = <fs_res>-to_calc.
    ENDIF.

* / valor a provisionar

    IF <fs_res>-mwskz IS NOT INITIAL.
      READ TABLE gt_imp WITH KEY mwskz = <fs_res>-mwskz.
      IF gt_imp-kbetr IS NOT INITIAL.
        <fs_res>-to_prov = <fs_res>-lwste + ( <fs_res>-lwste * ( gt_imp-kbetr / 1000 ) ) .
      ELSE.
        <fs_res>-to_prov = <fs_res>-lwste.
      ENDIF.
    ENDIF.
    IF <fs_res>-waers = 'CLP'.
      <fs_res>-lwste = <fs_res>-lwste * 100.
    ENDIF.

    CLEAR: gt_ekbe_we,
           gt_mseg,
           gt_rseg,
           gt_imp.
  ENDLOOP.

*Elimino lineas con valor a provisionar en cero
  LOOP AT gt_result INTO gs_result.
    IF gs_result-to_prov <= 0.
      DELETE gt_result INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "process_data

*&---------------------------------------------------------------------*
*&      Form  create_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_SALV_FUNCTION  text
*----------------------------------------------------------------------*
FORM create_file USING p_e_salv_function.

*         hkont       TYPE saknr,

*         currency    TYPE waers,
*         amt_doccur  TYPE bwert,
*         amt_base    TYPE bwert,
*         zzprestac   TYPE zzprestac,    " Prestación
*         zzunid_prod TYPE zzunid_prod,  " Códigos de Descuento y Códigos de Estamento
*         zzdesc_est  TYPE zzdesc_est,   " Códigos de Descuento y Códigos de Estamento
*         zzmot_emis  TYPE zzmot_emis,   " Motivos de emisión
*         zzrut_terc  TYPE zzrut_terc,   " RUT de terceros (Gestión)
*         zz_agencia  TYPE zz_agencia,   " Códigos de Agencia
*         fdlev       TYPE char10,
*         atributo_8  TYPE char10,
*         alt_payee   TYPE char10,
*         iva         TYPE char10,
*         bank_id     TYPE char10,
*         hktid       TYPE char10,
*         aufnr       TYPE aufnr,

  DATA: lv_num TYPE i VALUE 1,
        lv_pos TYPE i VALUE 0,
        lv_ebeln TYPE ekko-ebeln.

  LOOP AT gt_result INTO gs_result.

    IF sy-tabix = 1.
      lv_ebeln = gs_result-ebeln.
    ENDIF.

    lv_pos = lv_pos + 1.

    IF lv_ebeln <> gs_result-ebeln.
      lv_num = lv_num + 1.
      lv_pos = 1.
    ENDIF.
    gs_file-username = sy-uname.

    CONCATENATE 'PROV_OTR_OC-' gs_result-ebeln '-' gs_result-ebelp '-' gs_result-txz01
    INTO gs_file-header_txt.
    TRANSLATE gs_file-header_txt TO UPPER CASE.
    gs_file-comp_code = gs_result-bukrs.
    gs_file-doc_date = so_bedat-high.
    gs_file-pstng_date = so_bedat-high.
    gs_file-doc_type = 'SA'.
    gs_file-ref_doc_no = gs_result-ebeln.
    gs_file-area_contab = '12'.
    gs_file-key = lv_num.
    gs_file-itemno_acc = lv_pos.
    gs_file-sgtxt = gs_file-header_txt.
    gs_file-costcenter = gs_result-kostl.
    gs_file-bline_date = so_bedat-high.
    gs_file-alloc_nmbr = gs_result-ebeln.
    gs_file-currency = 'CLP'. " gs_result-waers.
    gs_file-hkont = gs_result-sakto.
    IF gs_result-waers = 'CLP'.
      gs_file-amt_doccur =  ( gs_result-to_prov * 100 ).
    ELSE.
      data: lv_prov(13) TYPE n.
      lv_prov = gs_result-to_prov.
      gs_file-amt_doccur =  lv_prov.
    ENDIF.
    gs_file-zzunid_prod = gs_result-zzunid_pro.
    gs_file-zzrut_terc = gs_result-zzrut_terc.
    APPEND gs_file TO gt_file.


    lv_ebeln = gs_result-ebeln.
    gs_file-hkont = '2011730009'.
    lv_pos = lv_pos + 1.
    gs_file-itemno_acc = lv_pos.
    CLEAR gs_file-costcenter.
*    gs_file-amt_doccur = gs_result-to_prov * -1.
    gs_file-amt_doccur = gs_file-amt_doccur * -1.

*Cambia signo de derecha a izquierda
    CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
      CHANGING
        value = gs_file-amt_doccur.


    APPEND gs_file TO gt_file.
    CLEAR gs_file.
  ENDLOOP.

  DATA: gv_filename TYPE rlgrap-filename VALUE 'D:\Desktop\test.xls'.


  IF p_e_salv_function EQ '&FIL'.
    PERFORM get_directory USING '.xls'.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
*   BIN_FILESIZE                    =
       filename                        = gv_def_path " 'D:\Desktop\test.xls'
       filetype                        = 'DBF'
*   APPEND                          = ' '
       write_field_separator           = '#'
   header                          = '00'
*   TRUNC_TRAILING_BLANKS           = ' '
*   WRITE_LF                        = 'X'
*   COL_SELECT                      = ' '
*   COL_SELECT_MASK                 = ' '
*   DAT_MODE                        = ' '
*   CONFIRM_OVERWRITE               = ' '
*   NO_AUTH_CHECK                   = ' '
*   CODEPAGE                        = ' '
*   IGNORE_CERR                     = ABAP_TRUE
*   REPLACEMENT                     = '#'
*   WRITE_BOM                       = ' '
*   TRUNC_TRAILING_BLANKS_EOL       = 'X'
*   WK1_N_FORMAT                    = ' '
*   WK1_N_SIZE                      = ' '
*   WK1_T_FORMAT                    = ' '
*   WK1_T_SIZE                      = ' '
*   WRITE_LF_AFTER_LAST_LINE        = ABAP_TRUE
*   SHOW_TRANSFER_STATUS            = ABAP_TRUE
* IMPORTING
*   FILELENGTH                      =
      TABLES
        data_tab                        = gt_file
        fieldnames                      = gt_header[]
     EXCEPTIONS
       file_write_error                = 1
       no_batch                        = 2
       gui_refuse_filetransfer         = 3
       invalid_type                    = 4
       no_authority                    = 5
       unknown_error                   = 6
       header_not_allowed              = 7
       separator_not_allowed           = 8
       filesize_not_allowed            = 9
       header_too_long                 = 10
       dp_error_create                 = 11
       dp_error_send                   = 12
       dp_error_write                  = 13
       unknown_dp_error                = 14
       access_denied                   = 15
       dp_out_of_memory                = 16
       disk_full                       = 17
       dp_timeout                      = 18
       file_not_found                  = 19
       dataprovider_exception          = 20
       control_flush_error             = 21
       OTHERS                          = 22
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

*    CALL FUNCTION 'SAP_CONVERT_TO_XLS_FORMAT'
*      EXPORTING
*       i_field_seperator          = '#'
*       i_line_header              = 'X'
*        i_filename                 = gv_filename
**       I_APPL_KEEP                = ' '
*      TABLES
*        i_tab_sap_data             = gt_result
**     CHANGING
**       I_TAB_CONVERTED_DATA       =
**     EXCEPTIONS
**       CONVERSION_FAILED          = 1
**       OTHERS                     = 2
*              .
*    IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.

  ELSEIF p_e_salv_function EQ '&CSV'.
    PERFORM get_directory USING '.csv'.
    PERFORM generate_file.
    PERFORM crear_csv USING gv_def_path.
  ENDIF.
  CLEAR gt_file[].
ENDFORM.                    "create_file

*&---------------------------------------------------------------------*
*&      Form  generate_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM generate_file.

  CALL FUNCTION 'SAP_CONVERT_TO_TEX_FORMAT'
    EXPORTING
      i_field_seperator    = ';'
*      i_line_header        = 'X'
*     I_FILENAME           =
*     I_APPL_KEEP          = ' '
    TABLES
      i_tab_sap_data       = gt_header_csv
    CHANGING
      i_tab_converted_data = gt_head
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'SAP_CONVERT_TO_TEX_FORMAT'
    EXPORTING
      i_field_seperator    = ';'
*     I_LINE_HEADER        =
*     I_FILENAME           =
      i_appl_keep          = 'X'
    TABLES
      i_tab_sap_data       = gt_file
    CHANGING
      i_tab_converted_data = gt_data
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    "generate_file

*&---------------------------------------------------------------------*
*&      Form  crear_csv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FILE       text
*----------------------------------------------------------------------*
FORM crear_csv USING file TYPE string.

  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = file
      header                  = '00'
      write_field_separator   = 'X'
*      fieldnames              = gt_head[]
    CHANGING
      data_tab                = gt_head[]
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = file
      append                  = 'X'
    CHANGING
      data_tab                = gt_data[]
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    "crear_csv

*&---------------------------------------------------------------------*
*&      Form  built_csv_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM built_csv_header.

  gs_header-username    = 'USERNAME'.
  gs_header-header_txt = 'HEADER_TXT'.
  gs_header-comp_code  = 'COMP_CODE'.
  gs_header-doc_date   = 'DOC_DATE'.
  gs_header-pstng_date = 'PSTNG_DATE'.
  gs_header-doc_type   = 'DOC_TYPE'.
  gs_header-ref_doc_no = 'REF_DOC_NO'.
  gs_header-area_contab = 'AREA_CONTAB'.
  gs_header-key         = 'KEY'.
  gs_header-itemno_acc  = 'ITEMNO_ACC'.
  gs_header-vendor_no   = 'VENDOR_NO'.
  gs_header-customer    = 'CUSTOMER'.
  gs_header-hkont       = 'HKONT'.
  gs_header-sgtxt       = 'SGTXT'.
  gs_header-tax_code    = 'TAX_CODE'.
  gs_header-costcenter  = 'COSTCENTER'.
  gs_header-profit_ctr  = 'PROFIT_CTR'.
  gs_header-pmnttrms    = 'PMNTTRMS'.
  gs_header-bline_date  = 'BLINE_DATE'.
  gs_header-pymt_meth   = 'PYMT_METH'.
  gs_header-pmnt_block  = 'PMNT_BLOCK'.
  gs_header-alloc_nmbr  = 'ALLOC_NMBR'.
  gs_header-wt_code     = 'WT_CODE'.
  gs_header-ref_key1    = 'REF_KEY1'.
  gs_header-ref_key2    = 'REF_KEY2'.
  gs_header-id_agencia  = 'ID_AGENCIA'.
  gs_header-currency    = 'CURRENCY'.
  gs_header-amt_doccur  = 'AMT_DOCCUR'.
  gs_header-amt_base    = 'AMT_BASE'.
  gs_header-zzprestac   = 'ZZPRESTAC'.    " Prestación
  gs_header-zzunid_prod = 'ZZUNID_PROD'.  " Códigos de Descuento y Códigos de Estamento
  gs_header-zzdesc_est  = 'ZZDESC_EST'.   " Códigos de Descuento y Códigos de Estamento
  gs_header-zzmot_emis  = 'ZZMOT_EMIS'.   " Motivos de emisión
  gs_header-zzrut_terc  = 'ZZRUT_TERC'.   " RUT de terceros (Gestión)
  gs_header-zz_agencia  = 'ZZ_AGENCIA'.   " Códigos de Agencia
  gs_header-fdlev       = 'FDLEV'.
  gs_header-atributo_8  = 'ATRIBUTO_8'.
  gs_header-alt_payee   = 'ALT_PAYEE'.
  gs_header-iva         = 'IVA'.
  gs_header-bank_id     = 'BANK_ID'.
  gs_header-hktid       = 'HKTID'.
  gs_header-aufnr       = 'AUFNR'.
  APPEND gs_header TO gt_header_csv.

ENDFORM.                    "built_csv_header

*&---------------------------------------------------------------------*
*&      Form  built_xls_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM built_xls_header.
  gt_header-value = 'USERNAME'. APPEND gt_header.
  gt_header-value = 'HEADER_TXT'. APPEND gt_header.
  gt_header-value = 'COMP_CODE'. APPEND gt_header.
  gt_header-value = 'DOC_DATE'. APPEND gt_header.
  gt_header-value = 'PSTNG_DATE'. APPEND gt_header.
  gt_header-value = 'DOC_TYPE'. APPEND gt_header.
  gt_header-value = 'REF_DOC_NO'. APPEND gt_header.
  gt_header-value = 'AREA_CONTAB'. APPEND gt_header.
  gt_header-value = 'KEY'. APPEND gt_header.
  gt_header-value = 'ITEMNO_ACC'. APPEND gt_header.
  gt_header-value = 'VENDOR_NO'. APPEND gt_header.
  gt_header-value = 'CUSTOMER'. APPEND gt_header.
  gt_header-value = 'HKONT'. APPEND gt_header.
  gt_header-value = 'SGTXT'. APPEND gt_header.
  gt_header-value = 'TAX_CODE'. APPEND gt_header.
  gt_header-value = 'COSTCENTER'. APPEND gt_header.
  gt_header-value = 'PROFIT_CTR'. APPEND gt_header.
  gt_header-value = 'PMNTTRMS'. APPEND gt_header.
  gt_header-value = 'BLINE_DATE'. APPEND gt_header.
  gt_header-value = 'PYMT_METH'. APPEND gt_header.
  gt_header-value = 'PMNT_BLOCK'. APPEND gt_header.
  gt_header-value = 'ALLOC_NMBR'. APPEND gt_header.
  gt_header-value = 'WT_TYPE'. APPEND gt_header.
  gt_header-value = 'WT_CODE'. APPEND gt_header.
  gt_header-value = 'REF_KEY1'. APPEND gt_header.
  gt_header-value = 'REF_KEY2'. APPEND gt_header.
  gt_header-value = 'ID_AGENCIA'. APPEND gt_header.
  gt_header-value = 'CURRENCY'. APPEND gt_header.
  gt_header-value = 'AMT_DOCCUR'. APPEND gt_header.
  gt_header-value = 'AMT_BASE'. APPEND gt_header.
  gt_header-value = 'ZZPRESTAC'. APPEND gt_header.
  gt_header-value = 'ZZUNID_PROD'. APPEND gt_header.
  gt_header-value = 'ZZDESC_EST'. APPEND gt_header.
  gt_header-value = 'ZZMOT_EMIS'. APPEND gt_header.
  gt_header-value = 'ZZRUT_TERC'. APPEND gt_header.
  gt_header-value = 'ZZ_AGENCIA'. APPEND gt_header.
  gt_header-value = 'FDLEV'. APPEND gt_header.
  gt_header-value = 'ATRIBUTO_8'. APPEND gt_header.
  gt_header-value = 'ALT_PAYEE'. APPEND gt_header.
  gt_header-value = 'IVA'. APPEND gt_header.
  gt_header-value = 'BANK_ID'. APPEND gt_header.
  gt_header-value = 'HKTID'. APPEND gt_header.
  gt_header-value = 'AUFNR'. APPEND gt_header.
ENDFORM.                    "built_xls_header

*&---------------------------------------------------------------------*
*&      Form  get_directory
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->EXT        text
*----------------------------------------------------------------------*
FORM get_directory USING ext.
  gv_wn_title = text-002.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = gv_wn_title
      initial_folder       = gv_def_path
    CHANGING
      selected_folder      = gv_def_path
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.

  CONCATENATE gv_def_path '\archivo' ext INTO gv_def_path.
ENDFORM.                    "get_directory

*&---------------------------------------------------------------------*
*&      Form  select_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM select_layout.
  DATA: ls_layout_key  TYPE salv_s_layout_key,
        ls_layout_info TYPE salv_s_layout_info.

  ls_layout_key-report = sy-repid.
  ls_layout_info = cl_salv_layout_service=>f4_layouts( ls_layout_key ).
  p_layout = ls_layout_info-layout.
ENDFORM.                    "select_layout
