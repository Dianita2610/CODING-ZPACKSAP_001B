*&---------------------------------------------------------------------*
*& Report  ZMMRP_STOCK_SEG
*&
*&---------------------------------------------------------------------*
*& Creado por:  SCL Consultores
*& Fecha:       30.08.2017
*& Descripción: Reporte Stock de Seguridad con MD04
*&---------------------------------------------------------------------*

REPORT zmmrp_stock_seg NO STANDARD PAGE HEADING.

TABLES: mara, t001w, t024d, marc.

*-- definicion tipos de pools (librerias dinamicas)
TYPE-POOLS: slis, icon.

*-- definicion tablas internas para ALV
DATA: it_fieldcat_alv  TYPE slis_t_fieldcat_alv,
      it_fieldcat_det  TYPE slis_t_fieldcat_alv,
      it_events        TYPE slis_t_event,
      it_event_exit    TYPE slis_t_event_exit,
      it_list_comments TYPE slis_t_listheader,
      it_excluding     TYPE slis_t_extab,
      it_excluding_det TYPE slis_t_extab.

*-- definicion variables de paso para ALV
DATA: wa_variant             LIKE disvariant,
      wx_variant             LIKE disvariant,
      wa_variant_save(1)     TYPE c,
      wa_exit(1)             TYPE c,
      wa_valid               TYPE c,
      wa_cancel              TYPE c,
      wa_repid               LIKE sy-repid,
      wa_user_specific(1)    TYPE c,
      wa_texto               TYPE string,
      wa_callback_ucomm      TYPE slis_formname,
      wa_print               TYPE slis_print_alv,
      wa_layout              TYPE slis_layout_alv,
      wa_layout_det          TYPE slis_layout_alv,
      wa_grid_settings       TYPE lvc_s_glay,
      wa_exit_caused_by_caller,
      wa_exit_caused_by_user TYPE slis_exit_by_user,
      wa_html_top_of_page    TYPE slis_formname,
      wa_sort                TYPE slis_t_sortinfo_alv,
      wa_status_set          TYPE slis_formname VALUE 'STAT_LO',
      wa_fieldcat_alv        LIKE LINE OF it_fieldcat_alv,
      wa_excluding           LIKE LINE OF it_excluding,
      wa_events              LIKE LINE OF it_events,
      wa_event_exit          LIKE LINE OF it_event_exit,
      wa_list_comments       LIKE LINE OF it_list_comments,
      wa_fieldcat            TYPE slis_t_fieldcat_alv WITH HEADER LINE.

*-- definicion tabla interna salida para ALV
DATA: BEGIN OF it_alv OCCURS 0,
         werks             LIKE t024d-werks, "  Centro
         mtart             LIKE mara-mtart,  "  Tipo Material
         dispo             LIKE marc-dispo,  "  Planificador Necesidade
*         MATNR             like MARC-MATNR,  "  Material
         matnr(18)             TYPE c,  "  Material
         maktx             LIKE makt-maktx,  "  Denominación
         stock_centro      LIKE mard-labst,  "  Stock Centro
         salk3             LIKE mbew-salk3,  "  Valor---> nuevo en ALV
         stock_seg         LIKE marc-eisbe,  "  Stock Seguridad
         stock_saldo       LIKE mard-labst,  "  Stock Saldo
         ubase             LIKE mara-meins,  "  Unidad de medida
         status(4)  TYPE c,
         box        TYPE c,
         waers             LIKE t001-waers,  "  Moneda
      END OF it_alv.


*-- definicion datos globales
DATA: wa_stock_libre       LIKE mard-labst,
      wa_stock_calidad     LIKE mard-insme,
      wa_stock_seg         LIKE marc-eisbe,
      wa_des_centro        LIKE t001w-name1,
      wa_des_dispo         LIKE t024d-dsnam,
      wa_flag              TYPE c.

*-- Tablas internas
DATA: it_marc     TYPE marc     OCCURS 0 WITH HEADER LINE.

DATA: regs      TYPE i.
DATA: cont_reg  TYPE i.
DATA: percentage  TYPE i.        " percentage
DATA: v_errcode(7), v_errdesc(255).
DATA: rc LIKE sy-subrc.

DATA : diaant  TYPE d.
DATA : diahoy  TYPE d.
DATA : vl_bukrs LIKE t001-bukrs. "Variable para rescatar la bukrs

* Pantallas de Principal
SELECTION-SCREEN BEGIN OF SCREEN 1100 AS SUBSCREEN.
SELECTION-SCREEN SKIP 2.
SELECTION-SCREEN BEGIN OF BLOCK block01 WITH FRAME TITLE text-001.
SELECTION-SCREEN SKIP 2.

*    select-options: s_auart for vbak-auart obligatory no intervals,
*                    s_vbeln for vbak-vbeln modif id sc3
*                      matchcode object vmva,
*               s_zuen  for zsd007-zuen obligatory no intervals,
*                    s_fecha for vbkd-fkdat obligatory modif id sc1.

*PARAMETERS:  p_werks LIKE t024d-werks OBLIGATORY,
*             p_dispo LIKE t024d-dispo OBLIGATORY
*             MATCHCODE OBJECT hs_t024d.
*             p_matnr LIKE mara-matnr.
SELECT-OPTIONS:  s_werks    FOR  t024d-werks NO INTERVALS
                                 NO-EXTENSION OBLIGATORY.
SELECT-OPTIONS:  s_dispo    FOR  t024d-dispo NO INTERVALS
                                 NO-EXTENSION OBLIGATORY.
SELECT-OPTIONS:  s_matnr FOR mara-matnr.

*    VALUE-REQUEST.
*    *                   s_vbeln for vbak-vbeln OBLIGATORY.


SELECTION-SCREEN END OF BLOCK block01.
SELECTION-SCREEN END OF SCREEN 1100.

SELECTION-SCREEN BEGIN OF TABBED BLOCK tabs FOR 10 LINES.
SELECTION-SCREEN TAB (46) tabs1 USER-COMMAND ucomm1
DEFAULT SCREEN 1100.
SELECTION-SCREEN END OF BLOCK tabs.

*at selection-screen on value-request for s_auart-low.
*  call function 'RV_HELP'
*    exporting
*      key            = space
*      key2           = space
*      key3           = space
*      key4           = '0'
*      number         = '008'
*      trtyp          = 'H'
*      field_in       = s_auart-low
*      description_in = space
*    importing
*      field          = s_auart-low.

INITIALIZATION.

  SET TITLEBAR 'T01'.
  tabs1 = text-p01.


* SET PF-STATUS 'STS01'.

AT SELECTION-SCREEN.

  CHECK sy-tfill GT 0.
  CASE sy-ucomm.
    WHEN 'ONLI'.
      PERFORM authority.
      PERFORM selecciona_nv.
    WHEN OTHERS.
*
  ENDCASE.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'SC1'.
        screen-required  = '1'.
        screen-input     = '1'.
        screen-invisible = '0'.
      WHEN 'SC2'.
        screen-input = '0'.
      WHEN 'SC3'.
        screen-required  = '1'.
        screen-input     = '1'.
        screen-invisible = '0'.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

START-OF-SELECTION.
  PERFORM fieldcat_build.
  PERFORM event_build.
  PERFORM event_exit_build.
  PERFORM exclude_build.
  PERFORM print_build.
  PERFORM layout_build.
  PERFORM sort_build USING wa_sort[].
  PERFORM display_data.

END-OF-SELECTION.

*
*--------------------------------------------------------------------*
*      Form  Proceso Materiales
*--------------------------------------------------------------------*
FORM envio_urgente_nv.

ENDFORM.  "ENVIO_URGENTE_NV.

*--------------------------------------------------------------------*
*      Form  SELECCIONA INFORMACIÓN
*--------------------------------------------------------------------*
FORM selecciona_nv.
*      SET PF-STATUS 'STS01'.
  FREE: it_marc, it_alv.

  DATA : wa_icon(4) TYPE c.
  DATA : ex_resultado(1) TYPE c.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE name1
*  INTO wa_des_centro
*  FROM t001w
*  WHERE werks = s_werks-low.
*
* NEW CODE
  SELECT name1
  UP TO 1 ROWS 
  INTO wa_des_centro
  FROM t001w
  WHERE werks = s_werks-low ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE dsnam
*  INTO wa_des_dispo
*  FROM t024d
*  WHERE werks = s_werks-low
*  AND dispo   = s_dispo-low.
*
* NEW CODE
  SELECT dsnam
  UP TO 1 ROWS 
  INTO wa_des_dispo
  FROM t024d
  WHERE werks = s_werks-low
  AND dispo   = s_dispo-low ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

*  IF s_matnr IS INITIAL.
*    SELECT *
*    FROM marc
*    INTO CORRESPONDING FIELDS OF TABLE it_marc
*    WHERE   werks  EQ  p_werks
*    AND   dispo  EQ p_dispo.
*  ELSE.
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *
*FROM marc
*INTO CORRESPONDING FIELDS OF TABLE it_marc
*WHERE matnr  IN  s_matnr
*AND   werks  IN  s_werks
*AND   dispo  IN  s_dispo.
*
* NEW CODE
  SELECT *

FROM marc
INTO CORRESPONDING FIELDS OF TABLE it_marc
WHERE matnr  IN  s_matnr
AND   werks  IN  s_werks
AND   dispo  IN  s_dispo ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03
*  ENDIF.
  LOOP AT it_marc.

    CLEAR it_alv.

    it_alv-werks = it_marc-werks.    "  Centro

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = it_marc-matnr
      IMPORTING
        output = it_alv-matnr.

    it_alv-dispo = s_dispo-low.    "  Material

*     IT_ALV-MTART = it_MARC-MTART.    "  Tipo Material
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE mtart meins
*    INTO (it_alv-mtart,  it_alv-ubase)
*    FROM mara
*    WHERE matnr = it_marc-matnr.
*
* NEW CODE
    SELECT mtart meins
    UP TO 1 ROWS 
    INTO (it_alv-mtart,  it_alv-ubase)
    FROM mara
    WHERE matnr = it_marc-matnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

*     IT_ALV-MAKTX = it_MARC-MAKTX.    "  Denominación
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE maktx
*    INTO it_alv-maktx
*    FROM makt
*    WHERE matnr = it_marc-matnr
*    AND   spras = 'S'.
*
* NEW CODE
    SELECT maktx
    UP TO 1 ROWS 
    INTO it_alv-maktx
    FROM makt
    WHERE matnr = it_marc-matnr
    AND   spras = 'S' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01


    wa_stock_libre   = 0.
    wa_stock_calidad = 0.
    SELECT SUM( labst ) SUM( insme )
    INTO (wa_stock_libre, wa_stock_calidad)
    FROM mard
    WHERE matnr = it_marc-matnr
    AND   werks = it_marc-werks.
    it_alv-stock_centro = wa_stock_libre + wa_stock_calidad.

*    IT_ALV-STOCK_SEG    =  0.    "  Stock Seguridad

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE eisbe
*    INTO wa_stock_seg
*    FROM marc
*    WHERE matnr = it_marc-matnr
*    AND   werks = it_marc-werks.
*
* NEW CODE
    SELECT eisbe
    UP TO 1 ROWS 
    INTO wa_stock_seg
    FROM marc
    WHERE matnr = it_marc-matnr
    AND   werks = it_marc-werks ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
    it_alv-stock_seg = wa_stock_seg.
    it_alv-stock_saldo  =  it_alv-stock_centro - it_alv-stock_seg.
*     IT_ALV-UBASE = 'KG'.             "  Unidad de medida
*     status(4)  type c,
*     box        type c,
    IF it_alv-stock_saldo > 0.
      WRITE icon_green_light AS ICON TO  wa_icon.
    ELSE.
      WRITE icon_red_light AS ICON TO  wa_icon.
    ENDIF.
    it_alv-status    = wa_icon.

*****Consulta valor moneda***
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE salk3
*    INTO it_alv-salk3
*    FROM mbew
*    WHERE matnr = it_marc-matnr
*    AND bwkey = it_alv-werks.
*
* NEW CODE
    SELECT salk3
    UP TO 1 ROWS 
    INTO it_alv-salk3
    FROM mbew
    WHERE matnr = it_marc-matnr
    AND bwkey = it_alv-werks ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
*****Rescata la sociedad para buscar el campo waers en la tabla t001
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE bukrs
*    INTO vl_bukrs
*    FROM t001k
*    WHERE bwkey = it_alv-werks.
*
* NEW CODE
    SELECT bukrs
    UP TO 1 ROWS 
    INTO vl_bukrs
    FROM t001k
    WHERE bwkey = it_alv-werks ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
*****Rescata el campo moneda segun la sociedad traida desde la t001k
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE waers
*    INTO it_alv-waers
*    FROM t001
*    WHERE bukrs = vl_bukrs.
*
* NEW CODE
    SELECT waers
    UP TO 1 ROWS 
    INTO it_alv-waers
    FROM t001
    WHERE bukrs = vl_bukrs ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

    APPEND it_alv.

  ENDLOOP.
  DESCRIBE TABLE it_alv.


ENDFORM.  "SELECCIONA_NV*


*&--------------------------------------------------------------------*
*&      Form  display_data
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM display_data.
  wa_callback_ucomm = 'CALLBACK_UCOMM'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_interface_check        = ' '
      i_buffer_active          = ' '
      i_callback_program       = wa_repid
      i_callback_pf_status_set = '' "SET_PF_STATUS'
*      i_grid_settings          = wa_grid_settings
      i_default                = ' '
      i_save                   = 'A'
      is_variant               = wa_variant
      is_layout                = wa_layout
      i_callback_user_command  = wa_callback_ucomm
      it_sort                  = wa_sort
      it_fieldcat              = it_fieldcat_alv
      it_events                = it_events
      it_event_exit            = it_event_exit
      it_excluding             = it_excluding
      is_print                 = wa_print
    IMPORTING
      e_exit_caused_by_caller  = wa_exit_caused_by_caller
      es_exit_caused_by_user   = wa_exit_caused_by_user
    TABLES
      t_outtab                 = it_alv
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

  IF sy-subrc = 0.
    IF wa_exit_caused_by_caller = 'X'.
      LEAVE PROGRAM.
    ELSE.
*"  User left list via F3
      IF wa_exit_caused_by_user-back = 'X'.
        EXIT.
      ENDIF.
    ENDIF.
  ELSE.
*-- Fatal error callin ALV
    MESSAGE text-008 TYPE 'E'.
  ENDIF.
ENDFORM.                    "display_data

*&---------------------------------------------------------------------*
*&      Form  event_build
*&---------------------------------------------------------------------*
FORM event_build.
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = it_events.

  READ TABLE it_events
       WITH KEY name = slis_ev_top_of_page
       INTO wa_events.
  IF sy-subrc = 0.
    MOVE 'ALV_TOP_OF_PAGE' TO wa_events-form.
    MODIFY it_events FROM wa_events INDEX sy-tabix.
  ENDIF.

  READ TABLE it_events
       WITH KEY name = slis_ev_end_of_page
       INTO wa_events.
  IF sy-subrc = 0.
    MOVE 'ALV_END_OF_PAGE' TO wa_events-form.
    MODIFY it_events FROM wa_events INDEX sy-tabix.
  ENDIF.
ENDFORM.                    "event_build

*&--------------------------------------------------------------------*
*&      Form  event_exit_build
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM event_exit_build.
  CLEAR: it_event_exit[].
*-- Pick
  wa_event_exit-ucomm     = '&ETA'.
  wa_event_exit-before    = ' '.
  wa_event_exit-after     = 'X'.
  APPEND wa_event_exit TO it_event_exit.
ENDFORM.                    "event_exit_build

*&---------------------------------------------------------------------*
*&      Form  exclude_build
*&---------------------------------------------------------------------*
FORM exclude_build.
  wa_excluding = '&GRAPH'.  "Graphic
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '&INFO'.   "Info
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '&UMC'.    "Umc
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '&SUM'.    "Sum
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '&ABC'.    "Abc
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '&REFRESH'."Refresh
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '&CRB'.    "Crb
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '&CRL'.    "Crl
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '&CRR'.    "Crr
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '&CRE'.    "Cre
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '&SAVE'. "Save
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '&AUTH'. "Auth
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '&ISSUE'. "Issue
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '&EB9'.   "EB9
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '&ALL'.   "All
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '&SAL'.   "Sal
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '&VEXCEL'. "Vexcel
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '&AQW'.   " Aqw
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '%PC'.    " Pc
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '%SL'.    " Sl
  APPEND wa_excluding TO it_excluding.
  wa_excluding = '&STATUS'.
  APPEND wa_excluding TO it_excluding.
ENDFORM.                    " exclude_build

*&---------------------------------------------------------------------*
*&      Form  fieldcat_build
*&---------------------------------------------------------------------*
FORM fieldcat_build.
  wa_repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name     = wa_repid
      i_internal_tabname = 'IT_ALV'
      i_inclname         = wa_repid
    CHANGING
      ct_fieldcat        = it_fieldcat_alv.
*--
  LOOP AT it_fieldcat_alv INTO wa_fieldcat_alv.
    CASE wa_fieldcat_alv-fieldname.
      WHEN 'MATNR'.
        wa_fieldcat_alv-seltext_l = 'Material'.
        wa_fieldcat_alv-seltext_m = 'Material'.
        wa_fieldcat_alv-seltext_s = 'Material'.
        wa_fieldcat_alv-reptext_ddic = 'Material'.
        wa_fieldcat_alv-hotspot   = 'X'.
      WHEN 'WERKS'.
        wa_fieldcat_alv-seltext_l = 'Centro'.
        wa_fieldcat_alv-seltext_m = 'Centro'.
        wa_fieldcat_alv-seltext_s = 'Centro'.
        wa_fieldcat_alv-outputlen = 15.
      WHEN 'DISPO'.
        wa_fieldcat_alv-seltext_l = 'Planif'.
        wa_fieldcat_alv-seltext_m = 'Planif'.
        wa_fieldcat_alv-seltext_s = 'Planif'.
        wa_fieldcat_alv-reptext_ddic = 'Planif'.
      WHEN 'MTART'.
        wa_fieldcat_alv-seltext_l = 'Tipo Material'.
        wa_fieldcat_alv-seltext_m = 'Tipo Material'.
        wa_fieldcat_alv-seltext_s = 'Tipo Material'.
        wa_fieldcat_alv-reptext_ddic = 'TipoMat'.
      WHEN 'MAKTX'.
        wa_fieldcat_alv-seltext_l = 'Denominación'.
        wa_fieldcat_alv-seltext_m = 'Denominación'.
        wa_fieldcat_alv-seltext_s = 'Denominación'.
        wa_fieldcat_alv-reptext_ddic = 'Denominación'.
      WHEN 'STOCK_CENTRO'.
        wa_fieldcat_alv-seltext_l = 'Stock Centro'.
        wa_fieldcat_alv-seltext_m = 'Stock Centro'.
        wa_fieldcat_alv-seltext_s = 'Stock Centro'.
        wa_fieldcat_alv-reptext_ddic = 'Stock Centro'.
**********Campo de Referencia valor moneda*********
      WHEN 'SALK3'.
        wa_fieldcat_alv-seltext_l = 'Valor'.
        wa_fieldcat_alv-seltext_m = 'Valor'.
        wa_fieldcat_alv-seltext_s = 'Valor'.
        wa_fieldcat_alv-reptext_ddic = 'Valor'.
        wa_fieldcat-cfieldname    = 'WAERS'.
      WHEN 'STOCK_SEG'.
        wa_fieldcat_alv-seltext_l = 'Stock Seguridad'.
        wa_fieldcat_alv-seltext_m = 'Stock Seguridad'.
        wa_fieldcat_alv-seltext_s = 'Stock Seguridad'.
        wa_fieldcat_alv-reptext_ddic = 'Stock Seg'.
      WHEN 'STOCK_SALDO'.
        wa_fieldcat_alv-seltext_l = 'Stock Saldo'.
        wa_fieldcat_alv-seltext_m = 'Stock Saldo'.
        wa_fieldcat_alv-seltext_s = 'Stock Saldo'.
        wa_fieldcat_alv-reptext_ddic = 'Stock Saldo'.
      WHEN 'UBASE'.
        wa_fieldcat_alv-seltext_l = 'UBase'.
        wa_fieldcat_alv-seltext_m = 'UBase'.
        wa_fieldcat_alv-seltext_s = 'UBase'.
*        wa_fieldcat_alv-TEXT_FIELDNAME = 'UBase'.
        wa_fieldcat_alv-reptext_ddic = 'UBase'.
      WHEN 'STATUS'.
        wa_fieldcat_alv-seltext_l = 'Status'.
        wa_fieldcat_alv-seltext_m = 'Status'.
        wa_fieldcat_alv-seltext_s = 'Status'.
        wa_fieldcat_alv-reptext_ddic = 'Status'.
***Oculta el campo moneda, la cual formatea el campo SALK3***
      WHEN 'WAERS'.
        wa_fieldcat_alv-seltext_l = 'Moneda'.
        wa_fieldcat_alv-seltext_m = 'Moneda'.
        wa_fieldcat_alv-seltext_s = 'Moneda'.
        wa_fieldcat_alv-reptext_ddic = 'Moneda'.
        wa_fieldcat_alv-no_out    = 'X'.

*      'WAERK'  " Ocultar Columnas
*        or 'BUKRS_VF'
*        or 'PS_PSP_PNR'
*        or 'NETWR'
*        or 'VKGRP'.
*        wa_fieldcat_alv-no_out = 'X'.
    ENDCASE.

    MODIFY it_fieldcat_alv FROM wa_fieldcat_alv.
    CLEAR wa_fieldcat_alv.
  ENDLOOP.
ENDFORM.                    "fieldcat_build

*&---------------------------------------------------------------------*
*&      Form  layout_build
*&---------------------------------------------------------------------*
FORM layout_build.
  wa_grid_settings-top_p_only   = 'X'.
*-- definition layout
  wa_layout-zebra               = 'X'.
  wa_layout-colwidth_optimize   = 'X'.
  wa_layout-cell_merge          = 'X'.
  wa_layout-detail_popup        = 'X'.
  wa_layout-get_selinfos        = 'X'.
  wa_layout-box_fieldname       = 'BOX'.
  wa_layout-info_fieldname      = 'COLOR'.
ENDFORM.                    "layout_build

*&---------------------------------------------------------------------*
*&      Form  layout_build_det
*&---------------------------------------------------------------------*
FORM layout_build_det.
  wa_grid_settings-top_p_only       = 'X'.
*-- definition layout
  wa_layout_det-zebra               = 'X'.
  wa_layout_det-colwidth_optimize   = 'X'.
  wa_layout_det-detail_popup        = 'X'.
  wa_layout_det-get_selinfos        = 'X'.
  wa_layout_det-box_fieldname       = 'MARCA'.
  wa_layout_det-info_fieldname      = 'COLOR'.
ENDFORM.                    "layout_build

*&---------------------------------------------------------------------*
*&      Form  print_build
*&---------------------------------------------------------------------*
FORM print_build.
  wa_print-no_print_listinfos = 'X'.
ENDFORM.                    "print_build

*&--------------------------------------------------------------------*
*&      Form  sort_build
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->E99_SORT   text
*---------------------------------------------------------------------*
FORM sort_build USING e99_sort TYPE slis_t_sortinfo_alv.
  DATA: ls_sort  TYPE slis_sortinfo_alv.

  CLEAR ls_sort.
  ls_sort-fieldname = 'MATNR'.
  ls_sort-up = 'X'.
  ls_sort-down = ' '.
  APPEND ls_sort TO e99_sort.
ENDFORM.                    "sort_build

*&--------------------------------------------------------------------*
*&      Form  alv_top_of_page
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM alv_top_of_page.
  DATA: wa_texto TYPE string.
  CLEAR: it_list_comments[].

  wa_list_comments-typ  = 'H'.
  wa_list_comments-key  = ''.
  wa_list_comments-info = text-ca0.
  APPEND wa_list_comments TO it_list_comments.

  wa_list_comments-typ  = 'A'.
  wa_list_comments-key  = ''.
  wa_texto = text-ca1.
  CONCATENATE wa_texto s_werks-low wa_des_centro
             INTO wa_texto SEPARATED BY space.
  wa_list_comments-info = wa_texto.
  APPEND wa_list_comments TO it_list_comments.

  wa_list_comments-typ  = 'A'.
  wa_list_comments-key  = ''.
  wa_texto = text-ca2.
  CONCATENATE wa_texto s_dispo-low wa_des_dispo
             INTO wa_texto SEPARATED BY space.
  wa_list_comments-info = wa_texto.
  APPEND wa_list_comments TO it_list_comments.

*  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
*    EXPORTING
*      i_logo             = 'LOGO_AS'
*      it_list_commentary = it_list_comments.
ENDFORM.                    "alv_top_of_page

*---------------------------------------------------------------------*
*       FORM alv_end_of_page                                          *
*---------------------------------------------------------------------*
FORM alv_end_of_page.

ENDFORM.                    "alv_end_of_page

*---------------------------------------------------------------------*
*       FORM set_pf_status                                            *
*---------------------------------------------------------------------*
FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS wa_status_set EXCLUDING it_excluding.
ENDFORM.                    "set_pf_status

*&---------------------------------------------------------------------*
*&      Form  exclude_build_det
*&---------------------------------------------------------------------*
FORM exclude_build_det.
  wa_excluding = '&ENVBASIS'.
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&GRAPH'.  "Graphic
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&INFO'.   "Info
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&UMC'.    "Umc
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&SUM'.    "Sum
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&ABC'.    "Abc
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&REFRESH'."Refresh
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&CRB'.    "Crb
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&CRL'.    "Crl
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&CRR'.    "Crr
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&CRE'.    "Cre
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&SAVE'. "Save
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&AUTH'. "Auth
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&ISSUE'. "Issue
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&EB9'.   "EB9
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&VEXCEL'. "Vexcel
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&AQW'.   " Aqw
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '%PC'.    " Pc
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '%SL'.    " Sl
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&OUP'.
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&ODN'.
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&ILT'.
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&OL0'.
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&OAD'.
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&AVE'.
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&ILD'.
  APPEND wa_excluding TO it_excluding_det.
  wa_excluding = '&RNT_PREV'.
  APPEND wa_excluding TO it_excluding_det.
ENDFORM.                    " exclude_build

*---------------------------------------------------------------------*
*       FORM user_command                                             *
*---------------------------------------------------------------------*
FORM callback_ucomm  USING r_ucomm LIKE sy-ucomm
                           rs_selfield TYPE slis_selfield.

  CASE r_ucomm.
    WHEN '&IC1'.
      IF rs_selfield-sel_tab_field = 'IT_ALV-MATNR'.
        IF  rs_selfield-tabindex > 0.
          SET PARAMETER : ID 'MAT' FIELD rs_selfield-value,
                          ID 'WRK' FIELD s_werks-low.
          CALL TRANSACTION 'MD04' AND  SKIP FIRST SCREEN.
        ENDIF.
      ENDIF.

    WHEN '&ENVBASIS'.
      CLEAR wa_flag.
      LOOP AT it_alv.
        CHECK it_alv-box EQ 'X'.
        wa_flag = 'X'.

      ENDLOOP.
      IF wa_flag IS INITIAL.
        MESSAGE text-007 TYPE 'E'.
      ELSE.
        PERFORM  envio_urgente_nv.
        rs_selfield-refresh = 'X'.
      ENDIF.
*      Refrech tabla.

    WHEN '&ANULAR'.


    WHEN '&STATUS'.

  ENDCASE.
ENDFORM.                    "callback_ucomm

**********************************************************************
FORM authority.
*-- Clase Documento de Venta

*-- Fin Clase Documento de Venta --*
ENDFORM.                    "authority

*&---------------------------------------------------------------------*
*&      Form  progress
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM progress.
  DATA: temp(50).

  percentage = 100 * cont_reg / regs.

  WRITE  percentage TO temp.
  CONDENSE temp.

  CONCATENATE text-008 temp INTO temp SEPARATED BY space.
  CONCATENATE temp '% realizado' INTO temp.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = percentage
      text       = temp.

ENDFORM.                               " PROGRESS
