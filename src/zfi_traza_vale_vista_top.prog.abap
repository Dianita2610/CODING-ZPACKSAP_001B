*&---------------------------------------------------------------------*
*&  Include           ZFI_TRAZA_VALE_VISTA_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS slis.
************************************************************************
**    Types
************************************************************************
TYPES: BEGIN OF ty_alv,
     TRAZA(6),
     orden         TYPE i, " orden _Alv
     ordencon      TYPE i,
     flag_fin(1), " si el flag esta en X ya no sigo procesando el registro, si esta vacio si. "OCULTO
     TYPE(1), " PARA SABER SI ES REGISTRO HISTORICO O POSTERIOR ( Historico (vacio) O Posterior (P)) "MODO
     bukrs_clr     TYPE bse_clr-bukrs_clr, " sociedad
     belnr_clr     TYPE bse_clr-belnr_clr, " n_doc_comp
     gjahr_clr     TYPE bse_clr-gjahr_clr, " anio_comp
     agzei         TYPE bse_clr-agzei,  " pos_Comp
     bukrs         TYPE bse_clr-bukrs,  " soc_ini
     belnr         TYPE bse_clr-belnr,  " doc_ini
     gjahr         TYPE bse_clr-gjahr,  " fch_ini
     buzei         TYPE bse_clr-buzei,  " pos_ini
     shkzg         TYPE bse_clr-shkzg,  " s/h
     dmbtr         TYPE pad_amt7s,  " importe
     chectno       TYPE payr-chect,
     vvistid       TYPE reguh-IDENTIF_PAGO, " "cambiar elem.datos
     waers         TYPE bse_clr-waers,  " para formateo importe
 	   bvorg         TYPE bkpf-bvorg,     " id_multisociedad
     zuonr         TYPE bseg-zuonr,      "  asignacion
     hkont         TYPE bseg-hkont,      " cuenta
     lifnr         TYPE bseg-lifnr,     " acreedor
     xref1         TYPE bseg-xref1,     " claveref_1
     xref2         TYPE bseg-xref2,     " claveref_2
     xref3         TYPE bseg-xref3,     " claveref_3
     zzmot_emis    TYPE bseg-zzmot_emis, "
     augbl         TYPE bseg-augbl,
     augdt         TYPE bsas-augdt,      "fch_Comp
     budat         TYPE bsas-budat,    "   fecha_cont
     bldat         TYPE bsas-bldat, " fch_docm
     xblnr         TYPE bsas-xblnr,  "REFERENCIA
     blart         TYPE bsas-blart,  " CLASE DOC
     ltext         TYPE ltext_003t, "t003-ltext, " Nombre_doc
     txt50         TYPE skat-txt50, " nombre cuenta
     sgtxt         TYPE bsas-sgtxt,  " TEXTO POSICION
     hbkid         TYPE payr-hbkid, " banco
     hktid         TYPE payr-hktid, " idcta
     rzawe         TYPE payr-rzawe, " via_pago
     chect         TYPE payr-chect, " num_cheque " BORRAR
     laufd         TYPE payr-laufd, " ppago_fch
     laufi         TYPE payr-laufi, " ppago_id
     zaldt         TYPE payr-zaldt, "ppago_fhp
     xbanc         TYPE payr-xbanc, " chq_cob
     bancd         TYPE payr-bancd, " fch_cobro
     xbukr         TYPE payr-xbukr, " chq_multisoc
     voidr         TYPE payr-voidr, " anul_chq
     voidd         TYPE payr-voidd, " anula fh_chq
     voidu         TYPE payr-voidu, "anula_chq_usu
    VV_FechaEnvio	 TYPE reguh-FECHA_ENVIO,
    VV_Usuario     TYPE reguh-USUARIO_ENVIO,
    VV_IndPago     TYPE reguh-IND_PAGO,
    VV_FechaPago   TYPE reguh-FECHA_PAGO,
    VV_IndDev      TYPE reguh-IND_DEVUELTO,
    VV_FechaDev    TYPE reguh-FECHA_DEVUELTO,
    VV_IndRech     TYPE reguh-IND_RECHAZO,
    VV_FechaRech   TYPE reguh-FECHA_RECHAZO,
    VV_BelnrDev    TYPE reguh-BELNR_DEV,
    VV_AnioDev     TYPE reguh-GJAHR_DEV,
    VV_IndCust     TYPE reguh-IND_CUSTODIA,
    VV_FechaCust   TYPE reguh-FECHA_CUSTODIA,
    VV_MotRech     TYPE reguh-MOTIVO_RECHAZO,
    VV_IndEnt      TYPE reguh-IND_ENTREGADO,
    VV_FchEntreg   TYPE reguh-FECHA_ENTREGADO,
    VV_IndREsct    TYPE reguh-IND_RESCATADO,
    VV_FchREsct    TYPE reguh-FECHA_RESCATADO,
END OF ty_alv.

TYPES: BEGIN OF ty_hist,
  ordencon   TYPE i,
  bukrs_clr	 TYPE bse_clr-bukrs_clr,
  belnr_clr  TYPE bse_clr-belnr_clr,
 	gjahr_clr  TYPE bse_clr-gjahr_clr,
  bukrs	     TYPE bse_clr-bukrs,
  belnr      TYPE bse_clr-belnr,
 	gjahr      TYPE bse_clr-gjahr,
  buzei      TYPE bse_clr-buzei,
  agzei      TYPE bse_clr-agzei,
  shkzg      TYPE bse_clr-shkzg,
  dmbtr      TYPE bse_clr-dmbtr,
  waers      TYPE bse_Clr-waers,

END OF ty_hist.

TYPES: BEGIN OF ty_bkpf,
  BUKRS TYPE bkpf-bukrs,
  BELNR TYPE bkpf-belnr,
  GJAHR TYPE bkpf-gjahr,
  BLART TYPE bkpf-blart,
  BUDAT TYPE bkpf-budat,
  bvorg TYPE bkpf-bvorg,
END OF ty_bkpf.

TYPES: BEGIN OF ty_bseg,
  BUKRS TYPE bseg-bukrs,
  BELNR	TYPE bseg-belnr,
  GJAHR	TYPE bseg-gjahr,
  BUZEI TYPE bseg-buzei,
  AUGDT TYPE bseg-AUGDT,
  AUGCP	TYPE bseg-augcp,
  AUGBL	TYPE bseg-augbl,
  WRBTR	TYPE bseg-wrbtr,
  LIFNR	TYPE bseg-LIFNR,
  zuonr TYPE bseg-zuonr,
  hkont TYPE bseg-hkont,
  xref1 TYPE bseg-xref1,
  xref2(10), "bseg-xref2,
  xref3 TYPE bseg-xref3,
  zzmot_emis TYPE	bseg-zzmot_emis,
END OF ty_bseg.

TYPES: BEGIN OF ty_bsas,
  bukrs	TYPE bse_clr-bukrs,
  belnr TYPE bse_clr-belnr,
  gjahr TYPE bse_clr-gjahr,
  buzei TYPE bse_clr-buzei,
  augdt TYPE bsas-augdt,
  augbl TYPE bseg-augbl,
  budat TYPE bsas-budat,
  bldat TYPE bsas-bldat,
  xblnr TYPE bsas-xblnr,
  blart TYPE bsas-blart,
  sgtxt TYPE bsas-sgtxt,
END OF ty_bsas.

TYPES: BEGIN OF ty_skat,
  txt50 TYPE skat-txt50,
END OF ty_skat.

TYPES: BEGIN OF ty_t003,
   ltext    TYPE ltext_003t,
END OF ty_t003.

TYPES: BEGIN OF ty_payr,
    hbkid TYPE payr-hbkid,
    hktid TYPE payr-hktid,
    rzawe TYPE payr-rzawe,
    chect TYPE payr-chect,
    laufd TYPE payr-laufd,
    laufi TYPE payr-laufi,
    zaldt TYPE payr-zaldt,
    xbanc TYPE payr-xbanc,
    bancd TYPE payr-bancd,
    xbukr TYPE payr-xbukr,
    voidr TYPE payr-voidr,
    voidd TYPE payr-voidd,
    voidu TYPE payr-voidu,
END OF ty_payr.

TYPES: BEGIN OF ty_payr_ini,
    zbukr TYPE payr-zbukr,
    vblnr TYPE payr-vblnr,
    gjahr TYPE payr-gjahr,
    zaldt TYPE payr-zaldt,
END OF ty_payr_ini.

TYPES: BEGIN OF ty_bsak,
  ordencon   TYPE i,
  bukrs_clr	 TYPE bse_clr-bukrs_clr,
  belnr_clr  TYPE bse_clr-belnr_clr,
 	gjahr_clr  TYPE bse_clr-gjahr_clr,
  bukrs	     TYPE bse_clr-bukrs,
  belnr      TYPE bse_clr-belnr,
 	gjahr      TYPE bse_clr-gjahr,
  buzei      TYPE bse_clr-buzei,
  agzei      TYPE bse_clr-agzei,
  shkzg      TYPE bse_clr-shkzg,
  dmbtr      TYPE bse_clr-dmbtr,
  waers      TYPE bse_Clr-waers,
  AUGDT	     TYPE bsak-augdt,
  AUGBL	     TYPE bsak-augbl,
  WRBTR	     TYPE bsak-wrbtr,
  LIFNR      TYPE bsak-lifnr,
  BUDAT      TYPE bsak-budat,
END OF ty_bsak.

TYPES: BEGIN OF ty_bsik,
  buzei      TYPE bse_clr-buzei,
  shkzg      TYPE bse_clr-shkzg,
  wrbtr      TYPE bse_clr-wrbtr,
END OF ty_bsik.

TYPES: BEGIN OF ty_bse_clr,
   ordencon TYPE i,
   BUKRS TYPE bse_clr-bukrs,
   BELNR TYPE bse_clr-belnr,
   GJAHR TYPE bse_clr-gjahr,
   BUKRS_CLR TYPE  bse_clr-bukrs_CLR,  " completo parejas de reguh
   BELNR_CLR TYPE  bse_clr-belnr_CLR,
   GJAHR_CLR TYPE bse_clr-GJAHR_CLR,
   AGZEI     TYPE bse_clr-AGZEI,
   BUZEI     TYPE bse_Clr-BUZEI,
   SHKZG     TYPE bse_clr-SHKZG,
   DMBTR     TYPE bse_clr-WRBTR,
END OF ty_bse_clr.

TYPES: BEGIN OF ty_Reguh_vv,
    VV_ValeVista  TYPE reguh-IDENTIF_PAGO,
    VV_BANCO      TYPE reguh-HBKID,
    VV_IDCTA      TYPE reguh-HKTID,
    vv_VIAPAGO    TYPE reguh-RZAWE,
    vv_pagofecha  TYPE reguh-LAUFD,
    vv_pagoID     TYPE reguh-LAUFI,
    VV_PPago_Fhp  TYPE Reguh-ZALDT,
    VV_FechaEnvio	TYPE reguh-FECHA_ENVIO,
    VV_Usuario    TYPE reguh-USUARIO_ENVIO,
    VV_IndPago    TYPE reguh-IND_PAGO,
    VV_FechaPago  TYPE reguh-FECHA_PAGO,
    VV_IndDev     TYPE reguh-IND_DEVUELTO,
    VV_FechaDev   TYPE reguh-FECHA_DEVUELTO,
    VV_IndRech    TYPE reguh-IND_RECHAZO,
    VV_FechaRech  TYPE reguh-FECHA_RECHAZO,
    VV_BelnrDev   TYPE reguh-BELNR_DEV,
    VV_AnioDev     TYPE reguh-GJAHR_DEV,
    VV_IndCust    TYPE reguh-IND_CUSTODIA,
    VV_FechaCust  TYPE reguh-FECHA_CUSTODIA,
    VV_MotRech    TYPE reguh-MOTIVO_RECHAZO,
    VV_IndEnt     TYPE reguh-IND_ENTREGADO,
    VV_FchEntreg  TYPE reguh-FECHA_ENTREGADO,
    VV_IndREsct   TYPE reguh-IND_RESCATADO,
    VV_FchREsct   TYPE reguh-FECHA_RESCATADO,
END OF ty_reguh_vv.

"---------------------------------------------------------------------------------------------------------
" TABLAS
"---------------------------------------------------------------------------------------------------------
DATA: gt_hist TYPE STANDARD TABLE OF ty_hist,
      gt_hist2 TYPE STANDARD TABLE OF ty_hist,
      gs_hist TYPE ty_hist,
      gt_alv  TYPE STANDARD TABLE OF ty_alv,
      gt_alv_aux TYPE STANDARD TABLE OF ty_alv,
      gs_alv  TYPE ty_alv,
      gs_Alv_aux TYPE ty_alv,
      gs_Alv_Aux2 TYPE ty_Alv,
      gt_bkpf TYPE STANDARD TABLE OF ty_bkpf,
      gs_bkpf TYPE ty_bkpf,
      gt_bseg TYPE STANDARD TABLE OF ty_bseg,
      gs_bseg TYPE ty_bseg,
      gt_bsas TYPE STANDARD TABLE OF ty_bsas,
      gs_bsas TYPE ty_bsas,
      gt_skat TYPE STANDARD TABLE OF ty_skat,
      gs_skat TYPE ty_skat,
      gt_payr TYPE STANDARD TABLE OF ty_payr,
      gs_payr TYPE ty_payr,
      gs_payr_ini TYPE ty_payr_ini,
      gt_t003 TYPE STANDARD TABLE OF ty_t003,
      gs_t003 TYPE ty_t003,
      gt_bse_clr TYPE STANDARD TABLE OF ty_bse_clr,
      gs_bse_clr TYPE ty_bse_clr,
      gt_REGUH_PRIMERA TYPE STANDARD TABLE OF  REGUH,
      gt_REGUH TYPE STANDARD TABLE OF  REGUH,
      gs_REGUH TYPE REGUH,
      gs_reguh2 TYPE REGUH,
      gt_bsak TYPE STANDARD TABLE OF ty_bsak,
      gs_bsak TYPE ty_bsak,
      gt_reguh_vv TYPE STANDARD TABLE OF ty_reguh_vv,
      gs_Reguh_vv TYPE ty_reguh_vv,
      gs_bsik TYPE ty_bsik.
"---------------------------------------------------------------------------------------------------------
" ALV
"---------------------------------------------------------------------------------------------------------
DATA: gr_table      TYPE REF TO cl_salv_table.
DATA: gr_events     TYPE REF TO cl_salv_events_table.
DATA: gr_functions  TYPE REF TO cl_salv_functions.
DATA: gr_selections TYPE REF TO cl_salv_selections.
DATA: gr_display    TYPE REF TO cl_salv_display_settings.
DATA: gr_columns    TYPE REF TO cl_salv_columns_table.
DATA: gr_column     TYPE REF TO cl_salv_column_table.
DATA: gr_sorts      TYPE REF TO cl_salv_sorts.
DATA: gr_agg        TYPE REF TO cl_salv_aggregations.
DATA: gr_filter     TYPE REF TO cl_salv_filters.
DATA: gr_layout     TYPE REF TO cl_salv_layout.

DATA: ref_grid     TYPE REF TO cl_gui_alv_grid.

DATA: color TYPE lvc_s_colo.
DATA: key   TYPE salv_s_layout_key.

DATA: lr_column  TYPE REF TO cl_salv_column_table,
      lr_columns TYPE REF TO cl_salv_columns.

FIELD-SYMBOLS <tabla> TYPE ANY TABLE.

"VARIABLES
DATA: lv_flag(1), " indica si tiene posterior
      lv_contador_p_fin TYPE i,
      gv_lifnr TYPE bsak-lifnr.

" RANGOS
"--------------------------------------------------------------------------------------------------------------
ranges: r_zaldt for reguh-zaldt.
DATA: wa_zaldt LIKE LINE OF r_Zaldt.

" CONSTANTES
DATA: tabname TYPE i VALUE 101.
