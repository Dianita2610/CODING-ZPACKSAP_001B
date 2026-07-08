*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFI_TRAZA_PAGOS_CHQ
*&---------------------------------------------------------------------*
*& Report     : ZFI_TRAZA_PAGOS_CHQ
*& Autor      : Seidor Crystalis Chile - Felipe Garcia T.
*& Funcional  : Oscar Agudelo
*& Fecha      : 29.04.2015
*& Modificación:
*&---------------------------------------------------------------------

REPORT  ZFI_TRAZA_PAGOS_CHQ.

TABLES: bse_clr, payr.

"-----------------------------------------------------------------------------------------------------------
" CLASES Y EVENTOS
"-----------------------------------------------------------------------------------------------------------
TYPE-POOLS slis.
************************************************************************
**    Types
************************************************************************
TYPES: BEGIN OF ty_alv,
     TRAZA(6),
     orden        TYPE i, " orden _Alv
     ordencon     TYPE i,
     flag_fin(1), " si el flag esta en X ya no sigo procesando el registro, si esta vacio si. "OCULTO
     TYPE(1), " PARA SABER SI ES REGISTRO HISTORICO O POSTERIOR ( Historico (vacio) O Posterior (P)) "MODO
     bukrs_clr    TYPE bse_clr-bukrs_clr, " sociedad
     belnr_clr    TYPE bse_clr-belnr_clr, " n_doc_comp
     gjahr_clr    TYPE bse_clr-gjahr_clr, " anio_comp
     agzei        TYPE bse_clr-agzei,  " pos_Comp
     bukrs        TYPE bse_clr-bukrs,  " soc_ini
     belnr        TYPE bse_clr-belnr,  " doc_ini
     gjahr        TYPE bse_clr-gjahr,  " fch_ini
     buzei        TYPE bse_clr-buzei,  " pos_ini
     shkzg       TYPE bse_clr-shkzg,  " s/h
     dmbtr       TYPE pad_amt7s,  " importe
     chectno     TYPE payr-chect,
      vvistid     TYPE payr-chect, " cambiar elem.datos
      waers       TYPE bse_clr-waers,  " para formateo importe
 	    bvorg       TYPE bkpf-bvorg,     " id_multisociedad
      zuonr       TYPE bseg-zuonr,      "  asignacion
      hkont       TYPE bseg-hkont,      " cuenta
      lifnr       TYPE bseg-lifnr,     " acreedor
      xref1       TYPE bseg-xref1,     " claveref_1
      xref2       TYPE bseg-xref2,     " claveref_2
      xref3       TYPE bseg-xref3,     " claveref_3
     zzmot_emis   TYPE bseg-zzmot_emis, "
     augbl        TYPE bseg-augbl,
     augdt        TYPE bsas-augdt,      "fch_Comp
     budat        TYPE bsas-budat,    "   fecha_cont
     bldat        TYPE bsas-bldat, " fch_docm
     xblnr        TYPE bsas-xblnr,  "REFERENCIA
     blart        TYPE bsas-blart,  " CLASE DOC
     ltext        TYPE ltext_003t, "t003-ltext, " Nombre_doc
     txt50        TYPE skat-txt50, " nombre cuenta
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
  bukrs	TYPE bse_clr-bukrs,
  belnr TYPE bse_clr-belnr,
  gjahr TYPE bse_clr-gjahr,
  bvorg TYPE bkpf-bvorg,
END OF ty_bkpf.

TYPES: BEGIN OF ty_bseg,
bukrs	TYPE bse_clr-bukrs,
belnr TYPE bse_clr-belnr,
gjahr TYPE bse_clr-gjahr,
buzei TYPE bse_clr-buzei,
zuonr TYPE bseg-zuonr,
hkont TYPE bseg-hkont,
lifnr TYPE bseg-lifnr,
xref1 TYPE bseg-xref1,
xref2 TYPE bseg-xref2,
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
END OF ty_payr_ini.
"---------------------------------------------------------------------------------------------------------
" TABLAS
"---------------------------------------------------------------------------------------------------------
DATA: gt_hist TYPE STANDARD TABLE OF ty_hist,
      gs_hist TYPE ty_hist,
      gt_alv  TYPE STANDARD TABLE OF ty_alv,
      gs_alv  TYPE ty_alv,
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
      gs_t003 TYPE ty_t003.
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

DATA: tabname TYPE i VALUE 101.

"---------------------------------------------------------------------------------------------------------------
* SELECT OPTION
"----------------------------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF SCREEN 101 as subscreen.
 SELECTION-SCREEN begin of block uno WITH FRAME title text-001.
   SELECT-OPTIONS: s_bukr1 FOR bse_clr-bukrs  NO INTERVALS NO-EXTENSION. " sociedad
   SELECT-OPTIONS: s_hbkid FOR payr-hbkid  NO INTERVALS NO-EXTENSION. " banco propio
   SELECT-OPTIONS: s_hktid FOR payr-hktid  NO INTERVALS NO-EXTENSION.   " ID BANCO
   SELECT-OPTIONS  s_rzawe FOR payr-rzawe   NO INTERVALS NO-EXTENSION.  " Vida de pago
   SELECT-OPTIONS  s_chect FOR payr-chect  NO INTERVALS NO-EXTENSION.  " numero de cheque
SELECTION-SCREEN END OF BLOCK uno.
selection-screen end of screen 101.


SELECTION-SCREEN BEGIN OF SCREEN 102 as subscreen.
 SELECTION-SCREEN begin of block dos WITH FRAME title text-002.
   SELECT-OPTIONS: s_bukrs FOR bse_clr-bukrs  NO INTERVALS NO-EXTENSION. " sociedad
   SELECT-OPTIONS: s_gjahr FOR bse_clr-gjahr  NO INTERVALS NO-EXTENSION. " ejercicio
   SELECT-OPTIONS: s_belnr FOR bse_clr-belnr_clr  NO INTERVALS NO-EXTENSION.   " N° de comprobante de pago
SELECTION-SCREEN END OF BLOCK dos.
selection-screen end of screen 102.


selection-screen begin of tabbed block t1 for 20 lines.
selection-screen tab (30) name1 user-command ucomm1 default screen 101.
selection-screen tab (30) name2 user-command ucomm2 default screen 102.

selection-screen end of block t1.

AT SELECTION-SCREEN.

 case sy-dynnr.
    when 1000.
      case sy-ucomm.
        when 'UCOMM1'.
          tabname = 101.
        when 'UCOMM2'.
          tabname = 102.
      endcase.
  endcase.

INITIALIZATION.

name1 = 'CONSULTA POR CHEQUE'.
name2 = 'CONSULTA POR COMPROBANTE'.

START-OF-SELECTION.
  "Aca ordenar primer alv de historial, para que queden ordenados por ordencon de manera decreciente segun ordencon*
  PERFORM busca_historial.
   " Luego aca tan solo concatenar el resto de los registros de la busqueda posterior
  PERFORM busca_posterior.

  IF gt_alv[] IS NOT INITIAL.

  PERFORM univ_datos. " Universo de datos
  PERFORM llena_alv.  " Luego terminar de llenar el ALV
  PERFORM despliega_alv.
  ELSE.
   MESSAGE 'Documento Sin Traza.' TYPE 'S'.
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  busca_historial
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM busca_historial.
  DATA: lv_contador     TYPE i,
        lv_n  TYPE i,
        lv_sy TYPE i.

  lv_n = 10000.
  lv_contador = 1.

  DO lv_n TIMES. " itera las lv_n veces, hasta que no existan mas consultas exitosas y realiza un EXIT. del DO TIMES.
    " PRIMERA CONSULTA
    IF lv_contador EQ 1.

      CASE TABNAME.
       WHEN 101.
        SELECT SINGLE ZBUKR VBLNR GJAHR INTO CORRESPONDING FIELDS OF gs_payr_ini
          FROM PAYR
         WHERE  ZBUKR EQ s_bukr1-low
           AND HBKID EQ s_hbkid-low
           AND HKTID EQ s_hktid-low
           AND RZAWE EQ s_rzawe-low
           AND CHECT EQ s_chect-low.

         SELECT bukrs_clr belnr_clr gjahr_clr bukrs belnr gjahr buzei agzei shkzg dmbtr waers INTO CORRESPONDING FIELDS OF TABLE gt_hist
          FROM bse_clr
          WHERE bukrs_clr  EQ gs_payr_ini-ZBUKR
            AND belnr_clr  EQ gs_payr_ini-vblnr
            AND gjahr_clr  EQ gs_payr_ini-gjahr.

          CLEAR: gs_payr.

       WHEN 102.
          SELECT bukrs_clr belnr_clr gjahr_clr bukrs belnr gjahr buzei agzei shkzg dmbtr waers INTO CORRESPONDING FIELDS OF TABLE gt_hist
          FROM bse_clr
           WHERE bukrs_clr  EQ s_bukrs-low
             AND belnr_clr  EQ s_belnr-low
             AND gjahr_clr  EQ s_gjahr-low.

      ENDCASE.

    ELSE.
      SELECT bukrs_clr belnr_clr gjahr_clr bukrs belnr gjahr buzei agzei shkzg dmbtr waers INTO CORRESPONDING FIELDS OF TABLE gt_hist
        FROM bse_clr FOR ALL ENTRIES IN gt_hist
         WHERE bukrs_clr   EQ gt_hist-bukrs
           AND belnr_clr  EQ gt_hist-belnr
           AND gjahr_clr  EQ gt_hist-gjahr.

      lv_sy = sy-subrc.
    ENDIF.

    IF gt_hist[] IS NOT INITIAL AND lv_sy EQ 0 . " si es exitoso
      LOOP AT gt_hist INTO gs_hist.
        gs_hist-ordencon = lv_contador.
        MODIFY gt_hist FROM gs_hist TRANSPORTING ordencon  WHERE bukrs_clr EQ gs_hist-bukrs_clr
                                                           AND belnr_clr  EQ gs_hist-belnr_clr
                                                           AND gjahr_clr  EQ gs_hist-gjahr_clr
                                                           AND bukrs      EQ gs_hist-bukrs
                                                           AND belnr      EQ gs_hist-belnr
                                                           AND gjahr      EQ gs_hist-gjahr.

        MOVE-CORRESPONDING gs_hist TO gs_alv.
        gs_alv-TRAZA = 'CHEQUE'.
        gs_alv-TYPE  = 'H'.
        APPEND gs_alv TO gt_alv.

      ENDLOOP.
      lv_contador =  lv_contador + 1.


    ELSEIF lv_sy NE 0.
      EXIT.
    ENDIF.

  ENDDO.

  SORT gt_alv BY ordencon DESCENDING.

ENDFORM.                    "seleccion_datos
*&---------------------------------------------------------------------*
*&      Form  busca_posterior
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM busca_posterior.
  DATA: lv_contador_p TYPE i,
        lv_contador_sub TYPE i,
        lv_n TYPE i,
        lv_sy TYPE i,
        lv_flag(1), " indica si tiene posterior
        lv_lineas TYPE i.

  lv_n = 10000.
  lv_contador_p = 1.


  DO lv_n TIMES. " itera las lv_n veces, hasta que no existan mas consultas exitosas y realiza un EXIT. del DO TIMES.
    " PRIMERA CONSULTA
    IF lv_contador_p EQ 1.
      SELECT bukrs_clr belnr_clr gjahr_clr bukrs belnr gjahr buzei agzei shkzg dmbtr waers INTO CORRESPONDING FIELDS OF TABLE gt_hist
      FROM bse_clr
     WHERE bukrs  EQ s_bukrs-low
      AND belnr  EQ s_belnr-low
      AND gjahr  EQ s_gjahr-low.

      " tiene posterior
       IF sy-subrc EQ 0.
         lv_flag = 'X'.
       ENDIF.
    ELSE.
      SELECT bukrs_clr belnr_clr gjahr_clr bukrs belnr gjahr buzei agzei shkzg dmbtr waers  INTO CORRESPONDING FIELDS OF TABLE gt_hist
        FROM bse_clr FOR ALL ENTRIES IN gt_hist
         WHERE bukrs   EQ gt_hist-bukrs_clr
           AND belnr  EQ gt_hist-belnr_clr
           AND gjahr  EQ gt_hist-gjahr_clr.

      lv_sy = sy-subrc.
    ENDIF.

    IF gt_hist[] IS NOT INITIAL AND lv_sy EQ 0 . " si es exitoso
      CLEAR: lv_contador_sub.
      LOOP AT gt_hist INTO gs_hist.
        gs_hist-ordencon = lv_contador_p.
        MODIFY gt_hist FROM gs_hist TRANSPORTING ordencon WHERE bukrs_clr EQ gs_hist-bukrs_clr
                                                           AND belnr_clr  EQ gs_hist-belnr_clr
                                                           AND gjahr_clr  EQ gs_hist-gjahr_clr
                                                           AND bukrs      EQ gs_hist-bukrs
                                                           AND belnr      EQ gs_hist-belnr
                                                           AND gjahr      EQ gs_hist-gjahr.
        MOVE-CORRESPONDING gs_hist TO gs_alv.
        gs_alv-TRAZA = 'CHEQUE'.
        gs_alv-TYPE  = 'P'.
        APPEND gs_alv TO gt_alv.

      ENDLOOP.
      lv_contador_p =  lv_contador_p + 1.

    ELSEIF lv_sy NE 0.
      EXIT.
    ENDIF.

  ENDDO.

  IF lv_flag EQ 'X'.
    DESCRIBE TABLE gt_Alv LINES lv_lineas.
    READ TABLE gt_Alv INTO gs_Alv INDEX lv_lineas.
*    gs_alv-orden    = 0.
    gs_alv-ordencon = gs_alv-ordencon + 1.
    gs_alv-bukrs = gs_alv-bukrs_clr.
    gs_alv-belnr = gs_alv-belnr_clr.
    gs_alv-gjahr = gs_alv-gjahr_clr.

*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
    SELECT SINGLE buzei INTO gs_alv-buzei
    FROM  BSEG
    WHERE bukrs EQ gs_alv-bukrs_clr
      AND belnr EQ gs_alv-belnr_clr
      AND gjahr EQ gs_alv-gjahr_clr
      AND augbl EQ SPACE.

    APPEND gs_alv TO gt_alv.
  ENDIF.
ENDFORM.                    "seleccion_datos

*&---------------------------------------------------------------------*
*&      Form  univ_datos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM univ_datos.
  "------------------------------------------------------------------------------------
  " GT_BKPF
  "------------------------------------------------------------------------------------
  SELECT bukrs belnr gjahr bvorg INTO CORRESPONDING FIELDS OF TABLE gt_bkpf
    FROM bkpf FOR ALL ENTRIES IN gt_alv
    WHERE bukrs   EQ gt_alv-bukrs
      AND belnr   EQ gt_alv-belnr
      AND gjahr   EQ gt_alv-gjahr.

  SORT gt_bkpf BY bukrs belnr gjahr.
  "------------------------------------------------------------------------------------
  " GT_BSEG
  "------------------------------------------------------------------------------------
SELECT bukrs belnr gjahr buzei zuonr hkont lifnr xref1 xref2 xref2 xref3 zzmot_emis INTO CORRESPONDING FIELDS OF TABLE gt_bseg
FROM bseg FOR ALL ENTRIES IN gt_alv
WHERE bukrs EQ gt_alv-bukrs
AND belnr EQ gt_alv-belnr
AND gjahr EQ gt_alv-gjahr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*AND buzei EQ gt_alv-buzei.
AND BUZEI EQ GT_ALV-BUZEI ORDER BY PRIMARY KEY .
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *

  SORT gt_bseg BY bukrs belnr gjahr buzei.

  "------------------------------------------------------------------------------------
  " GT_BSAS
  "------------------------------------------------------------------------------------
  SELECT bukrs belnr gjahr buzei augdt augbl budat bldat xblnr blart sgtxt INTO CORRESPONDING FIELDS OF TABLE gt_bsas
   FROM bsas FOR ALL ENTRIES IN gt_alv
   WHERE bukrs  EQ gt_alv-bukrs
     AND belnr  EQ gt_alv-belnr
     AND gjahr  EQ gt_alv-gjahr
     AND buzei  EQ gt_alv-buzei.

  SORT gt_bsas BY bukrs belnr gjahr buzei.
ENDFORM.                    "univ_datos
*&---------------------------------------------------------------------*
*&      Form  llena_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM llena_alv.
  DATA: lv_contador_alv TYPE i,
        lv_pivote       TYPE i,
        gs_alv_next     TYPE ty_alv,
        lv_index        TYPE i,
        lv_lines        TYPE i,
        lv_countalv     TYPE i.
  DATA: lv_plan_cta TYPE t001-ktopl.

  lv_contador_alv = 1.

   DESCRIBE TABLE gt_Alv LINES lv_lines.

  LOOP AT gt_alv INTO gs_alv.
    lv_countalv = lv_countalv + 1.
    "------------------------------------------------------------------------------------
    " PARA ASIGNAR NUMERO AL ORDEN DEL HISTORIAL Y POSTERIORES ( CRECIENTE RESPECTIVAMENTE)
    "------------------------------------------------------------------------------------
    lv_pivote = gs_alv-ordencon.
    lv_index  = sy-tabix + 1.

    READ TABLE gt_alv INTO gs_alv_next INDEX lv_index.

    IF lv_pivote EQ gs_alv_next-ordencon.
      gs_alv-orden = lv_contador_alv.
    ELSE.
      gs_alv-orden = lv_contador_alv.
      lv_contador_alv = lv_contador_alv + 1.
    ENDIF.

    IF gs_alv-shkzg EQ 'H'.
      gs_alv-dmbtr = gs_alv-dmbtr * -1.
    ENDIF.

    "------------------------------------------------------------------------------------
    " BKPF
    "------------------------------------------------------------------------------------
    CLEAR: gs_bkpf.
*ReSQ: No Need Of Change Internal Table GT_BKPF Already Sorted
    READ TABLE gt_bkpf INTO gs_bkpf WITH KEY bukrs = gs_alv-bukrs
                                             belnr = gs_alv-belnr
                                             gjahr = gs_alv-gjahr BINARY SEARCH.

    gs_alv-bvorg = gs_bkpf-bvorg.
    "------------------------------------------------------------------------------------
    " BSEG
    "------------------------------------------------------------------------------------
    CLEAR: gs_bseg.
*ReSQ: No Need Of Change Internal Table GT_BSEG Already Sorted
    READ TABLE gt_bseg INTO gs_bseg WITH KEY bukrs = gs_alv-bukrs
                                             belnr = gs_alv-belnr
                                             gjahr = gs_alv-gjahr
                                             buzei = gs_alv-buzei BINARY SEARCH.

    MOVE-CORRESPONDING gs_bseg TO gs_alv.
    "------------------------------------------------------------------------------------
    " BSAS
    "------------------------------------------------------------------------------------
    CLEAR: gs_bsas.
*ReSQ: No Need Of Change Internal Table GT_BSAS Already Sorted
    READ TABLE gt_bsas INTO gs_bsas WITH KEY bukrs = gs_alv-bukrs
                                             belnr = gs_alv-belnr
                                             gjahr = gs_alv-gjahr
                                             buzei = gs_alv-buzei BINARY SEARCH.

    IF sy-subrc NE 0.

    SELECT SINGLE bukrs belnr gjahr buzei augdt augbl budat bldat xblnr blart sgtxt INTO  gs_bsas
    FROM bsis
    WHERE bukrs  EQ gs_alv-bukrs
      AND belnr  EQ gs_alv-belnr
      AND gjahr  EQ gs_alv-gjahr
      AND buzei  EQ gs_alv-buzei.

    ENDIF.


    IF lv_countalv EQ lv_lines. " solo para el ultimo registro.
      gs_alv-augdt = gs_bsas-augdt.
      gs_alv-augbl = gs_bsas-augbl.
      gs_alv-budat = gs_bsas-budat.
      gs_alv-bldat = gs_bsas-bldat.
      gs_alv-xblnr = gs_bsas-xblnr.
      gs_alv-blart = gs_bsas-blart.
      gs_alv-sgtxt = gs_bsas-sgtxt.
     ELSE.
       MOVE-CORRESPONDING gs_bsas TO gs_alv.
    ENDIF.

    "---------------------------------------------------------------------------------------
    " SKAT
    "---------------------------------------------------------------------------------------
                                                            " T001
    CLEAR: lv_plan_cta.
    SELECT SINGLE ktopl INTO lv_plan_cta
      FROM t001
      WHERE bukrs EQ gs_alv-bukrs.

    CLEAR: gs_alv-txt50.
    SELECT SINGLE txt50  INTO gs_alv-txt50
     FROM skat
     WHERE spras EQ sy-langu
       AND ktopl EQ lv_plan_cta
       AND saknr EQ gs_alv-hkont.

    "---------------------------------------------------------------------------------------
                                                            " T003
    "---------------------------------------------------------------------------------------
    CLEAR: gs_alv-ltext.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
    SELECT SINGLE ltext INTO gs_alv-ltext
    FROM t003t
     WHERE spras EQ sy-langu
       AND blart EQ gs_alv-blart.

    "------------------------------------------------------------------------------------
    " PAYR
    "------------------------------------------------------------------------------------
    CLEAR: gs_payr.
    SELECT SINGLE hbkid hktid rzawe chect laufd laufi zaldt  xbanc bancd xbukr voidr
           voidd voidu INTO CORRESPONDING FIELDS OF gs_payr
     FROM payr
      WHERE zbukr EQ gs_alv-bukrs
        AND vblnr EQ gs_alv-belnr
        AND gjahr EQ gs_Alv-gjahr.
*        AND zaldt EQ gs_alv-augdt
*        AND lifnr EQ gs_alv-lifnr.

    MOVE-CORRESPONDING gs_payr TO gs_alv.

    gs_alv-chectno =  gs_alv-chect. " numero de cheque.

    " AGREGA A REGISTRO ALV
    MODIFY gt_alv FROM gs_alv TRANSPORTING ORDEN
                                           DMBTR
                                           BVORG " BKPF
                                     ZUONR HKONT LIFNR XREF1 XREF2 XREF2 XREF3 ZZMOT_EMIS " BSEG
                                     AUGDT BUDAT BLDAT XBLNR BLART SGTXT " BSAS
                                     TXT50 LTEXT " t001 "SKAT
                                     HBKID HKTID RZAWE CHECT LAUFD LAUFI ZALDT  XBANC BANCD XBUKR VOIDR VOIDD VOIDU " PAYR
                                     chectno vvistid VV_FechaEnvio VV_Usuario VV_IndPago VV_FechaPago VV_IndDev  VV_FechaDev VV_IndRech
                                     VV_FechaRech  VV_BelnrDev VV_AnioDev VV_IndCust VV_FechaCust VV_MotRech VV_IndEnt
                                     VV_FchEntreg  VV_IndREsct VV_FchREsct    " REGUH VVISTA
                                                 WHERE bukrs_clr EQ gs_alv-bukrs_clr
                                                  AND belnr_clr  EQ gs_alv-belnr_clr
                                                  AND gjahr_clr  EQ gs_alv-gjahr_clr
                                                  AND bukrs      EQ gs_alv-bukrs
                                                  AND belnr      EQ gs_alv-belnr
                                                  AND gjahr      EQ gs_alv-gjahr.
  ENDLOOP.

ENDFORM.                    "llena_alv

*&---------------------------------------------------------------------*
*&      Form  frm_pf_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM frm_pf_status USING rt_extab TYPE slis_t_extab.
*  First i copy PF-STATUS SAPLKKBL STANDARD_FULLSCREEN
  SET PF-STATUS 'ZSTANDARD' .
ENDFORM.                    "FRM_PF_STATUS.
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       User_command del alv principal
*----------------------------------------------------------------------*
FORM user_command_1 USING r_ucomm LIKE sy-ucomm
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

ENDFORM.                    "USER_COMMAND

**&---------------------------------------------------------------------*
**&      Form  DESPLIEGA_ALV
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
FORM despliega_alv.

  ASSIGN gt_alv[] TO <tabla>[].

  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = gr_table
        CHANGING  t_table      = <tabla>[] ).
    CATCH cx_salv_msg.                                  "#EC NO_HANDLER
  ENDTRY.
*  "copiar status gui de function group SALV_METADATA_STATUS
*  "and copy the gui status SALV_TABLE_STANDARD into the program.
**  "se80 -> grupo de funciones -> status gui ->boton derecho copiar

  gr_table->set_screen_status(
    pfstatus      = 'ZSTANDARD'
    report        = sy-repid
    set_functions = gr_table->c_functions_all ).

**... optimize the column widths
  TRY.
      lr_columns = gr_table->get_columns( ).
      lr_columns->set_optimize( 'X' ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  gr_events = gr_table->get_event( ).

*  * Set up selections.
  gr_selections = gr_table->get_selections( ).
  "none(0) Single(1) multiple (2) cell selection(3) row_column(4)
  gr_selections->set_selection_mode( 4 ).

* Habilita las funciones del alv
  gr_functions = gr_table->get_functions( ).
  gr_functions->set_all( abap_true ).

**      &ALL
*      TRY.
*        CALL METHOD gr_functions->set_function
*          EXPORTING
*            name    = '&ALL'
*            boolean = space.
*        CATCH cx_salv_not_found .
*        CATCH cx_salv_wrong_call .
*      ENDTRY.
*
*      DATA: l_icon TYPE string.
*      DATA: l_text TYPE string.
*
**      l_icon = icon_select_all.

*      TRY.
*          l_text = 'select_all'.
*          gr_functions->add_function(
*            name     = 'SET_ROWS'
*            icon     = l_icon
**          text     = l_text
*            tooltip  = l_text
*            position = if_salv_c_function_position=>right_of_salv_functions ).
*        CATCH cx_salv_wrong_call cx_salv_existing.
*      ENDTRY.

  gr_display = gr_table->get_display_settings( ).
  gr_display->set_striped_pattern( cl_salv_display_settings=>true ).
  gr_display->set_list_header( 'Traza Por Cheque' ).

  TRY.

 gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'ORDEN' )."
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'OrdenALV' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'ORDENCON' )."
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( '#CON' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BUKRS_CLR' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Sociedad' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BELNR_CLR' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'N°Doc.Comp.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'GJAHR_CLR' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Año Comp.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'AGZEI' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Pos. Comp.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BUKRS' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Soc. Ini.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BELNR' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Doc. Ini.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'GJAHR' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Fecha Ini.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BUZEI' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Pos. Ini' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'SHKZG' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'S/H' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'DMBTR' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Importe' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BVORG' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'ID. Multisociedad' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'ZUONR' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Asignacion' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'HKONT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Cuenta' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'LIFNR' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Acreedor' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'XREF1' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'ClaveRef-1' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'XREF2' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'ClaveRef-2' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'XREF3' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'ClaveRef-3' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'ZZMOT_EMIS' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Mot. Emision' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'AUGDT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Fecha Comp.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BUDAT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Fecha Cont.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BLDAT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Fecha Docm.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'XBLNR' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Referencia' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BLART' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Clase Doc.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'LTEXT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Nombre Doc.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'LTEXT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Nombre Cta.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'SGTXT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Texto Posicion' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'HBKID' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Banco' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'HKTID' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'ID Cta.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'RZAWE' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Via Pago' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'CHECT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'No. Cheque' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'LAUFD' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'PPago Fch' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'LAUFI' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'PPago ID' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'ZALDT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'PPago Fhp' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'XBANC' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Chq. Cob.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BANCD' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Fch. Cobro' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'XBUKR' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Chq. Multisoc.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VOIDR' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Anula Chq.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VOIDD' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Anula fch. Chq.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VOIDU' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Anula Chq. Usu.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'TYPE' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Modo' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

         gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'TRAZA' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Traza' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres


        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VVISTID' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'ID-ValeVista' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'CHECTNO' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'No.Cheque' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_FECHAENVIO' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-FechaEnvio' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_USUARIO' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-Usuario' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

         gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_INDPAGO' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-IndPago' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_FECHAPAGO' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-FechaPago' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_INDDEV' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-IndDev' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_FECHADEV' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-FechaDev' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_INDRECH' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-IndRech' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_FECHARECH' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-FechaRech' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

         gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_BELNRDEV' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-BelnrDev' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_ANIODEV' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-AnioDev' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_INDCUST' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-IndCust' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_FECHACUST' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-FechaCust' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_MOTRECH' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-MotRech' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_INDENT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-INDENT' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

         gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_FCHENTREG' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-FCHENTREG' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_INDRESCT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-IndREsct' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_FCHRESCT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-FchREsct' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres
    CATCH cx_salv_not_found.
  ENDTRY.

"--------------------------------------------------------------------------------------------------------------
* OCULTA COLUMNAS
"--------------------------------------------------------------------------------------------------------------
  TRY.

            gr_column ?= gr_columns->get_column( 'FLAG_FIN'  ).
            gr_column->set_visible( abap_false ).
            gr_column ?= gr_columns->get_column( 'WAERS'  ).
            gr_column->set_visible( abap_false ).
        catch cx_salv_not_found .
 ENDTRY.

"-----------------------------------------------------------------------------------------------------------------
" FORMATEA A CLP
"------------------------------------------------------------------------------------------------------------------
  TRY.
        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'DMBTR' ).       gr_column->set_currency_column( 'WAERS' ).

    CATCH cx_salv_not_found.
  ENDTRY."SET_moneda
"-------------------------------------------------------------------------------------------------------------
" PINTA COLUMNAS
"-------------------------------------------------------------------------------------------------------------
  gr_column ?= gr_columns->get_column( 'BUKRS' ).
  color-col = '7'.color-int = '0'.color-inv = '0'.
  gr_column->set_color( color ).

  gr_column ?= gr_columns->get_column( 'BELNR' ).
  color-col = '7'.color-int = '0'.color-inv = '0'.
  gr_column->set_color( color ).

  gr_column ?= gr_columns->get_column( 'GJAHR' ).
  color-col = '7'.color-int = '0'.color-inv = '0'.
  gr_column->set_color( color ).

  gr_column ?= gr_columns->get_column( 'BUZEI' ).
  color-col = '7'.color-int = '0'.color-inv = '0'.
  gr_column->set_color( color ).
*  try.
*  gr_sorts = gr_table->get_sorts( ).
*  gr_sorts->add_sort( columnname = 'CITYTO' subtotal = abap_true ).
*  gr_agg = gr_table->get_aggregations( ).
*
*  gr_agg->add_aggregation( 'DISTANCE' ).
*  catch cx_salv_not_found cx_salv_existing cx_salv_data_error.
*  endtry.

*  gr_filter = gr_table->get_filters( ).
*  gr_filter->add_filter( columnname = 'CARRID' low = 'LH' ).
**
"-----------------------------------------------------------------------------------------------------------------
" CUENTA FILAS
"-----------------------------------------------------------------------------------------------------------------
  DATA: nfilas(10) TYPE c.
  DATA: nfilas1 TYPE i.
  DESCRIBE TABLE gt_alv LINES  nfilas1.
  MOVE nfilas1 TO nfilas.
  DATA: vl_texto(25) TYPE c.
  CONCATENATE 'Número de filas' nfilas INTO vl_texto SEPARATED BY space.
  MESSAGE vl_texto TYPE 'S'.
  gr_layout = gr_table->get_layout( ).
  key-report = sy-repid.
  gr_layout->set_key( key ).

  gr_layout->set_save_restriction( cl_salv_layout=>restrict_none ).
"-----------------------------------------------------------------------------------------------------------------
" DESPLIEGA ALV
"-----------------------------------------------------------------------------------------------------------------
  gr_table->display( ).
*  ELSE.
*    gr_table->refresh( ).
* ENDIF.

ENDFORM.                    "DESPLIEGA_ALV
