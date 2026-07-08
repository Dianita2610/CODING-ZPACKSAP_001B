*&---------------------------------------------------------------------*
*& Report  ZMM_CARGA_OC
*&
*&---------------------------------------------------------------------*
*& Creado por: BADI CONSULTORES
*& Consultor : Maria JosÃ© Morice - MJM@BADI.CL
*& www.BADI.cl
*&---------------------------------------------------------------------*

REPORT  zmm_carga_oc.

TABLES ekko.

TYPE-POOLS: slis.

TYPES : BEGIN OF t_tabla,        "Original
          bukrs     TYPE ekko-bukrs,
          bstyp     TYPE ekko-bstyp,
          bsart     TYPE ekko-bsart,
          lifnr     TYPE ekko-lifnr,
          aedat(10) TYPE c, "ekko-aedat,
          zterm     TYPE ekko-zterm,
          ekorg     TYPE ekko-ekorg,
          ekgro     TYPE ekko-ekgrp,
          waers     TYPE ekko-waers,
          knttp     TYPE ekpo-knttp,
          pstyp     TYPE ekpo-pstyp, "Inicio posiciÃ³n
          ebelp     TYPE ekpo-ebelp,
          matnr     TYPE ekpo-matnr,
          menge     TYPE ekpo-menge,
          meins     TYPE ekpo-meins,
          netpr(15) TYPE c, "ekpo-netpr,
          peinh     TYPE ekpo-peinh,
          eeind     TYPE rm06e-eeind,
          werks     TYPE ekpo-werks,
          lgort     TYPE ekpo-lgort,
          afnam     TYPE ekpo-afnam,
          bednr     TYPE ekpo-bednr,
          mwskz     TYPE ekpo-mwskz,
          sakto     TYPE ekkn-sakto,
          kostl     TYPE ekkn-kostl,
          ltex1     TYPE rm06e-ltex1,
          kschl     TYPE komv-kschl, "mj cond cab.
          kwert     TYPE char9,  "type komv-kwert, "mj valor cab.
          kschlp    TYPE komv-kschl, "mj cond pos.
          kbetr     TYPE char13, "komv-kbetr,"mj valor pos
          ltex2     TYPE rm06e-ltex1,  "WAJ - 16-11-2021 - texto Atención
          regis     TYPE i,

        END OF t_tabla.

TYPES : BEGIN OF t_cabe,
          bukrs     TYPE ekko-bukrs,
          bstyp     TYPE ekko-bstyp,
          bsart     TYPE ekko-bsart,
          lifnr     TYPE ekko-lifnr,
          aedat(10) TYPE c, "ekko-aedat,
          zterm     TYPE ekko-zterm,
          ekorg     TYPE ekko-ekorg,
          ekgro     TYPE ekko-ekgrp,
          waers     TYPE ekko-waers,
          knttp     TYPE ekpo-knttp,
          pstyp     TYPE ekpo-pstyp,
          ebelp     TYPE ekpo-ebelp,
          ltex1     TYPE rm06e-ltex1,
          kschl     TYPE komv-kschl, "mj cond cab.
          kwert     TYPE char9,  "type komv-kwert, "mj valor cab.
          ltex2     TYPE rm06e-ltex1,  "WAJ - 16-11-2021 - texto Atención
          "  kschl type komv-kschl,"mj2
        END OF t_cabe.

TYPES : BEGIN OF t_log,
          icon(4)  TYPE c,
          msj(200) TYPE c,
        END OF t_log.

TYPES: BEGIN OF ty_return,
         message TYPE char100,
         linea   TYPE i,
       END OF ty_return.

DATA : lt_tabla   TYPE STANDARD TABLE OF t_tabla,
       ls_tabla   TYPE t_tabla,

       lt_cabe    TYPE STANDARD TABLE OF t_cabe,
       ls_cabe    TYPE t_cabe,

       lt_log     TYPE STANDARD TABLE OF t_log,
       ls_log     TYPE t_log,

       ti_return2 TYPE STANDARD TABLE OF ty_return,
       wa_return2 TYPE ty_return.

DATA: p_file_name TYPE string,
      p_fullpath  TYPE string,
      error(255).


SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME.
PARAMETERS  p_file  LIKE rlgrap-filename OBLIGATORY.
SELECTION-SCREEN END OF BLOCK blk1.

*---------------------------------------------------------------------------
*AT SELECTION-SCREEN
*---------------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
*ESTA FUNCIÃ“N NOS AYUDA A UBICAR EL ARCHIVO COMO LO HARÃAMOS EN WINDOWS
  CALL FUNCTION 'GUI_FILE_LOAD_DIALOG'
    EXPORTING
      window_title = 'Selecciona el archivo a cargar#'
      file_filter  = ',*.XLS,*.xls.'
    IMPORTING
      filename     = p_file_name
      fullpath     = p_fullpath.
  IF sy-subrc = 0.
    p_file = p_fullpath.
  ENDIF.

*----------------------------------------------------------------------------
*STAR OF SELECTION
*----------------------------------------------------------------------------
START-OF-SELECTION.

*validacion de archivo de entrada
  IF p_file NS '.xls' .
    MESSAGE: 'debe ingresar un archivo formato excel' TYPE 'I'.
    EXIT.
  ENDIF.

  PERFORM transformar_excel.
  IF NOT lt_tabla[] IS INITIAL.
    PERFORM cargar_tablas.
    PERFORM mostrar_log.
  ELSE.
    MESSAGE: 'archivo: sin registro para cargar' TYPE 'I'.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  TRANSFORMAR_EXCEL
*&---------------------------------------------------------------------*
*       Objetivo: transformar archivo excel en tabla interna
*----------------------------------------------------------------------*
FORM transformar_excel.

  DATA: lt_excel TYPE TABLE OF alsmex_tabline,
        l_index  TYPE i.

  DATA: l_cont(2)   TYPE c,
        l_cadena    TYPE string,
        l_start_col TYPE i VALUE 1,
        l_start_row TYPE i VALUE 2,
        l_end_col   TYPE i VALUE 31, "26,   " Numero columna
        l_end_row   TYPE i VALUE 65536.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_file
      i_begin_col             = l_start_col
      i_begin_row             = l_start_row
      i_end_col               = l_end_col
      i_end_row               = l_end_row
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CHECK NOT lt_excel[] IS INITIAL.

  FIELD-SYMBOLS: <fs_excel> LIKE LINE OF lt_excel,
                 <fs>.

  LOOP AT lt_excel ASSIGNING <fs_excel>.
    IF <fs_excel>-col = '0001'.
      l_cont = strlen( <fs_excel>-value ).
      IF l_cont EQ '31'.  " numero de columna
        EXIT.
      ENDIF.
    ENDIF.
    MOVE <fs_excel>-col TO l_index.
    ASSIGN COMPONENT l_index OF STRUCTURE ls_tabla TO <fs>.
    MOVE <fs_excel>-value TO <fs>.
    AT END OF row.
      APPEND ls_tabla TO lt_tabla.
      CLEAR ls_tabla.
    ENDAT.
  ENDLOOP.

  CLEAR l_index.
  l_index = 2.
  LOOP AT lt_tabla INTO ls_tabla.
    ls_tabla-regis = l_index.
    l_index = l_index + 1.
    MODIFY lt_tabla FROM ls_tabla.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CARGAR_TABLAS
*&---------------------------------------------------------------------*
*       Objetivo: llena tablas para la bapi
*----------------------------------------------------------------------*
FORM cargar_tablas.

  TYPES : BEGIN OF t_ebelp,
            ebelp(5) TYPE c, "ekpo-ebelp,
            veces    TYPE i,
          END OF t_ebelp.

  DATA : lt_ebelp TYPE STANDARD TABLE OF t_ebelp,
         ls_ebelp TYPE t_ebelp,
         lv_veces TYPE i.

  DATA : ls_poheader         LIKE  bapimepoheader,
         ls_poheaderx        LIKE  bapimepoheaderx,

         lt_poitem           TYPE STANDARD TABLE OF bapimepoitem,
         ls_poitem           TYPE bapimepoitem,

         lt_poitem_a         TYPE STANDARD TABLE OF bapimepoitem,
         ls_poitem_a         TYPE bapimepoitem,

         lt_poitemx	         TYPE STANDARD TABLE OF bapimepoitemx,
         ls_poitemx          TYPE bapimepoitemx,

         lt_poitemx_a	       TYPE STANDARD TABLE OF bapimepoitemx,
         ls_poitemx_a        TYPE bapimepoitemx,

         lt_poschedule       TYPE STANDARD TABLE OF bapimeposchedule,
         ls_poschedule       TYPE bapimeposchedule,
         lt_poschedulex	     TYPE STANDARD TABLE OF bapimeposchedulx,
         ls_poschedulex      TYPE bapimeposchedulx,
         lt_poaccount	       TYPE STANDARD TABLE OF bapimepoaccount,
         ls_poaccount        TYPE bapimepoaccount,
         lt_poaccountx       TYPE STANDARD TABLE OF bapimepoaccountx,
         ls_poaccountx       TYPE bapimepoaccountx,
         lt_pocond           TYPE STANDARD TABLE OF bapimepocond, "mj
         ls_pocond           TYPE bapimepocond, "mj
         lt_pocondx          TYPE STANDARD TABLE OF bapimepocondx, "mj
         ls_pocondx          TYPE bapimepocondx, "mj
         ls_pocondheader     TYPE bapimepocondheader, "mj2
         lt_pocondheader     TYPE STANDARD TABLE OF bapimepocondheader, "mj2
         ls_pocondheaderx    TYPE bapimepocondheaderx,
         lt_pocondheaderx    TYPE STANDARD TABLE OF bapimepocondheaderx, "mj2
         lt_potextheader     TYPE STANDARD TABLE OF bapimepotextheader, "mj
         ls_potextheader     TYPE bapimepotextheader,                   "mj
         "       lt_potextitem  type standard table of bapimepotext, "mj
         "       ls_potextitem  type bapimepotext,                   "mj
         lt_return           TYPE STANDARD TABLE OF bapiret2,
         ls_return           TYPE bapiret2,

         lt_return_a         TYPE STANDARD TABLE OF bapiret2,
         ls_return_a         TYPE bapiret2,

         lv_exppurchaseorder LIKE bapimepoheader-po_number,
         lv_item             TYPE ebelp,

         lv_amount_external  LIKE  bapicurr-bapicurr,
         cont                TYPE i VALUE 2,

         lt_t685a            TYPE STANDARD TABLE OF t685a,
         ls_t685a            TYPE t685a.

  FREE lt_cabe.
  LOOP AT lt_tabla INTO ls_tabla.
    CLEAR ls_cabe.
    MOVE-CORRESPONDING ls_tabla TO ls_cabe.
    COLLECT ls_cabe INTO lt_cabe.

    ls_ebelp-ebelp = ls_tabla-ebelp.
    COLLECT ls_ebelp INTO lt_ebelp.
  ENDLOOP.

  LOOP AT lt_ebelp INTO ls_ebelp.
    CLEAR lv_veces.
    LOOP AT lt_cabe INTO ls_cabe WHERE ebelp = ls_ebelp-ebelp.
      lv_veces = lv_veces + 1.
    ENDLOOP.
    ls_ebelp-veces = lv_veces.
    MODIFY lt_ebelp FROM ls_ebelp.
  ENDLOOP.

  DELETE lt_ebelp WHERE veces = 1.
  IF NOT lt_ebelp[] IS INITIAL.
    FREE lt_log.
    LOOP AT lt_ebelp INTO ls_ebelp.
      CLEAR ls_log.
      "ls_log-icon =
      CONCATENATE 'Cabecera no concuerda para indicador:' ls_ebelp-ebelp
      INTO ls_log-msj
      SEPARATED BY space.
      APPEND ls_log TO lt_log.
    ENDLOOP.
    PERFORM message.
  ENDIF.

  IF NOT lt_tabla[] IS INITIAL.

    SELECT *
      INTO TABLE lt_t685a
      FROM t685a
      FOR ALL ENTRIES IN lt_tabla
      WHERE kappl = 'M'
        AND kschl = lt_tabla-kschlp
        AND kposi = 'X'.

    SORT lt_t685a BY kschl ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_t685a.

  ENDIF.


  CHECK lt_ebelp[] IS INITIAL.

  LOOP AT lt_cabe INTO ls_cabe.

    CLEAR ls_poheader.
    ls_poheader-comp_code  = ls_cabe-bukrs.
    ls_poheader-doc_type   = ls_cabe-bsart.
    CONCATENATE ls_cabe-aedat+6(4) ls_cabe-aedat+3(2) ls_cabe-aedat+0(2) INTO ls_poheader-creat_date.
    "ls_poheader-creat_date = ls_cabe-aedat.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_cabe-lifnr
      IMPORTING
        output = ls_poheader-vendor.
    "ls_poheader-vendor     = ls_cabe-lifnr.
    ls_poheader-pmnttrms   = ls_cabe-zterm.
    ls_poheader-purch_org  = ls_cabe-ekorg.
    ls_poheader-pur_group  = ls_cabe-ekgro.
    ls_poheader-currency   = ls_cabe-waers.
    ls_poheader-currency_iso   = ls_cabe-waers.

    CLEAR ls_poheaderx.
    ls_poheaderx-comp_code     = 'X'.
    ls_poheaderx-doc_type      = 'X'.
    ls_poheaderx-creat_date    = 'X'.
    ls_poheaderx-vendor        = 'X'.
    ls_poheaderx-pmnttrms      = 'X'.
    ls_poheaderx-purch_org     = 'X'.
    ls_poheaderx-pur_group     = 'X'.
    ls_poheaderx-currency      = 'X'.
    ls_poheaderx-currency_iso  = 'X'.


    FREE: lt_pocondheader,"mj2
          lt_pocondheaderx,"mj2
          lt_potextheader.


    ""mj cond cab.
    IF NOT ls_cabe-kschl IS INITIAL.

      IF ls_cabe-waers = 'CLP'.
        REPLACE ALL OCCURRENCES OF '.' IN ls_cabe-kwert WITH ' '.
        CONDENSE ls_tabla-netpr.
      ELSE.
        REPLACE ALL OCCURRENCES OF ',' IN ls_cabe-kwert WITH '.'.
        CONDENSE ls_tabla-netpr.
      ENDIF.

      CLEAR ls_pocondheader.
      ls_pocondheader-cond_type = ls_cabe-kschl.
      ls_pocondheader-cond_value = ls_cabe-kwert.
      CLEAR ls_pocondheader-currency.
      IF ls_cabe-kschl = 'HB01'.
        ls_pocondheader-currency = ls_cabe-waers.
      ENDIF.
      ls_pocondheader-change_id = 'I'.
      APPEND ls_pocondheader TO lt_pocondheader.


      CLEAR ls_pocondheaderx.
      ls_pocondheaderx-cond_type = 'X'.
      ls_pocondheaderx-cond_value = 'X'.
      ls_pocondheaderx-currency = 'X'.
      ls_pocondheaderx-change_id = 'X'.
      APPEND ls_pocondheaderx TO lt_pocondheaderx.
    ENDIF.

    CLEAR ls_potextheader.
    " ls_potextheader-po_item  = lv_item.
    ls_potextheader-text_id  = 'F01'.
* ini - waldo alarcon - visionone
*    ls_potextheader-text_line = ls_tabla-ltex1.  "error
    ls_potextheader-text_form = '*'.
    ls_potextheader-text_line = ls_cabe-ltex1.
* fin - waldo alarcon - visionone
    APPEND ls_potextheader TO lt_potextheader.

* ini - Waldo Alarcón - Visionone - 16-11-2021
    CLEAR ls_potextheader.
    ls_potextheader-text_id    = 'F17'.
    ls_potextheader-text_form  = '*'.
    ls_potextheader-text_line  = ls_cabe-ltex2.
    APPEND ls_potextheader TO lt_potextheader.
* fin - Waldo Alarcón - Visionone - 16-11-2021

    lv_item = 10.
    FREE: lt_poitem,
          lt_poitem_a,
          lt_poitemx,
          lt_poitemx_a,
          lt_poschedule,
          lt_poschedulex,
          lt_poaccount,
          "lt_pocondheader,"mj 5
          "lt_pocondheaderx,"mj5
          lt_pocond,
          lt_pocondx,
          "lt_potextheader,"mj
    "     lt_potextitem,"mj
          lt_poaccountx.


    LOOP AT lt_tabla INTO ls_tabla WHERE ebelp = ls_cabe-ebelp.

      CLEAR : ls_poitem,
              ls_poitem.

      ls_poitem-po_item      = lv_item.
      ls_poitem_a-po_item    = lv_item.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_tabla-matnr
        IMPORTING
          output = ls_poitem-material.
      "ls_poitem-material     = ls_tabla-matnr.
      ls_poitem-plant        = ls_tabla-werks.
      ls_poitem-stge_loc     = ls_tabla-lgort.
      ls_poitem-trackingno   = ls_tabla-bednr.
      ls_poitem-quantity     = ls_tabla-menge.

      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          input          = ls_tabla-meins
          language       = sy-langu
        IMPORTING
          output         = ls_poitem-po_unit
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.

      "ls_poitem-po_unit      = ls_tabla-meins.
      IF ls_cabe-waers = 'CLP'.
        REPLACE ALL OCCURRENCES OF '.' IN ls_tabla-netpr WITH ' '.
        CONDENSE ls_tabla-netpr.
      ELSE.
        REPLACE ALL OCCURRENCES OF ',' IN ls_tabla-netpr WITH '.'.
        CONDENSE ls_tabla-netpr.
      ENDIF.

      "lv_amount_external  = ls_tabla-netpr.
      "     call function 'BAPI_CURRENCY_CONV_TO_INTERNAL'
      "       exporting
      "         currency                   = ls_cabe-waers
      "         amount_external            = lv_amount_external "ls_tabla-netpr
      "         max_number_of_digits       = '9'
      "       importing
      "         amount_internal            = ls_poitem-net_price
      "*        RETURN                     =
      "               .

      ls_poitem-net_price    = ls_tabla-netpr.
      ls_poitem-price_unit   = ls_tabla-peinh.
      ls_poitem-tax_code     = ls_tabla-mwskz.
      ls_poitem-item_cat     = ls_tabla-pstyp.
      ls_poitem-po_price     = '1'.
      ls_poitem-acctasscat   = ls_tabla-knttp.
      ls_poitem-preq_name    = ls_tabla-afnam.
      APPEND ls_poitem TO lt_poitem.

      ls_poitem_a-tax_code   = ls_tabla-mwskz.
      APPEND ls_poitem_a TO lt_poitem_a.

      CLEAR ls_poitemx.
      ls_poitemx-po_item     = lv_item.
      ls_poitemx-material    = 'X'.
      ls_poitemx-plant       = 'X'.
      ls_poitemx-stge_loc    = 'X'.
      ls_poitemx-trackingno  = 'X'.
      ls_poitemx-quantity    = 'X'.
      ls_poitemx-po_unit     = 'X'.
      ls_poitemx-net_price   = 'X'.
      ls_poitemx-price_unit  = 'X'.
      ls_poitemx-tax_code    = 'X'.
      ls_poitemx-item_cat    = 'X'.
      ls_poitemx-po_price    = 'X'.
      ls_poitemx-acctasscat  = 'X'.
      ls_poitemx-preq_name   = 'X'.
      APPEND ls_poitemx TO lt_poitemx.

      CLEAR ls_poitemx_a.
      ls_poitemx_a-po_item   = lv_item.
      ls_poitemx_a-tax_code  = 'X'.
      APPEND ls_poitemx_a TO lt_poitemx_a.

      CLEAR ls_poschedule.
      ls_poschedule-po_item        = lv_item.
      ls_poschedule-delivery_date  = ls_tabla-eeind.
      APPEND ls_poschedule TO lt_poschedule.

      CLEAR ls_poschedulex.
      ls_poschedulex-po_item       = lv_item.
      ls_poschedulex-delivery_date = 'X'.
      APPEND ls_poschedulex TO lt_poschedulex.

      CLEAR ls_poaccount.
      ls_poaccount-po_item      = lv_item.
      ls_poaccount-gl_account  = ls_tabla-sakto.
      ls_poaccount-costcenter  = ls_tabla-kostl.
      APPEND ls_poaccount TO lt_poaccount.

      CLEAR ls_poaccountx.
      ls_poaccountx-po_item    = lv_item.
      ls_poaccountx-gl_account = 'X'.
      ls_poaccountx-costcenter = 'X'.
      APPEND ls_poaccountx TO lt_poaccountx.

      ""mj cond pos.
      IF NOT ls_tabla-kschlp IS INITIAL.

        CLEAR ls_t685a.
        READ TABLE lt_t685a INTO ls_t685a WITH KEY kschl = ls_tabla-kschlp.
        IF ls_t685a-knega = 'X'.
          ls_tabla-kbetr = ls_tabla-kbetr * -1.
        ENDIF.

        IF ls_cabe-waers = 'CLP'.
          REPLACE ALL OCCURRENCES OF '.' IN ls_tabla-kbetr WITH ' '.
          CONDENSE ls_tabla-netpr.
        ELSE.
          REPLACE ALL OCCURRENCES OF ',' IN ls_tabla-kbetr WITH '.'.
          CONDENSE ls_tabla-netpr.
        ENDIF.

        CLEAR ls_pocond.
        ls_pocond-itm_number = lv_item.
        ls_pocond-cond_type = ls_tabla-kschlp.
        ls_pocond-cond_value = ls_tabla-kbetr.
        CLEAR ls_pocond-currency.
        IF ls_tabla-kschlp = 'RC00' OR
           ls_tabla-kschlp = 'RB00'.
          ls_pocond-currency = ls_cabe-waers.
        ENDIF.
        ls_pocond-change_id = 'I'.
        APPEND ls_pocond TO lt_pocond.

        CLEAR ls_pocondx.
        ls_pocondx-itm_number = lv_item.
        ls_pocondx-cond_type = 'X'.
        ls_pocondx-cond_value = 'X'.
        ls_pocondx-currency = 'X'.
        ls_pocondx-change_id = 'X'.
        APPEND ls_pocondx TO lt_pocondx.
      ENDIF.

      "mj
      lv_item = lv_item + 10.

    ENDLOOP.

    CLEAR lv_exppurchaseorder.
    FREE lt_return.
    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        poheader         = ls_poheader
        poheaderx        = ls_poheaderx
*       POADDRVENDOR     =
*       TESTRUN          =
*       MEMORY_UNCOMPLETE            =
*       MEMORY_COMPLETE  =
*       POEXPIMPHEADER   =
*       POEXPIMPHEADERX  =
*       VERSIONS         =
*       NO_MESSAGING     =
*       NO_MESSAGE_REQ   =
*       NO_AUTHORITY     =
*       NO_PRICE_FROM_PO =
      IMPORTING
        exppurchaseorder = lv_exppurchaseorder
*       EXPHEADER        =
*       EXPPOEXPIMPHEADER            =
      TABLES
        return           = lt_return
        poitem           = lt_poitem
        poitemx          = lt_poitemx
*       POADDRDELIVERY   =
        poschedule       = lt_poschedule
        poschedulex      = lt_poschedulex
        poaccount        = lt_poaccount
*       POACCOUNTPROFITSEGMENT       =
        poaccountx       = lt_poaccountx
        pocondheader     = lt_pocondheader "mj2
        pocondheaderx    = lt_pocondheaderx "mj2
        pocond           = lt_pocond
        pocondx          = lt_pocondx
*       POLIMITS         =
*       POCONTRACTLIMITS =
*       POSERVICES       =
*       POSRVACCESSVALUES            =
*       POSERVICESTEXT   =
*       EXTENSIONIN      =
*       EXTENSIONOUT     =
*       POEXPIMPITEM     =
*       POEXPIMPITEMX    =
        potextheader     = lt_potextheader "mj
*       potextitem       = lt_potextitem mj
*       ALLVERSIONS      =
*       POPARTNER        =
*       POCOMPONENTS     =
*       POCOMPONENTSX    =
*       POSHIPPING       =
*       POSHIPPINGX      =
*       POSHIPPINGEXP    =
      .

    IF NOT lv_exppurchaseorder IS INITIAL.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      DO 5 TIMES.
        SELECT SINGLE *
          FROM ekko
          WHERE ebeln = lv_exppurchaseorder.
        IF sy-subrc = 0.
          EXIT.
        ELSE.
          WAIT UP TO 1 SECONDS.
        ENDIF.
      ENDDO.

      FREE lt_return_a.
      CALL FUNCTION 'BAPI_PO_CHANGE'
        EXPORTING
          purchaseorder = lv_exppurchaseorder
*       IMPORTING
*         EXPHEADER     =
*         EXPPOEXPIMPHEADER            =
        TABLES
          return        = lt_return_a
          poitem        = lt_poitem_a
          poitemx       = lt_poitemx_a.

    ENDIF.

    READ TABLE lt_return_a INTO ls_return_a WITH KEY type    = 'S'
                                                     id      = '06'
                                                     number  = '023'.
    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
    ENDIF.

    DELETE lt_return WHERE type = 'E' AND ( id = 'BAPI' OR id = 'MEPO' ).
    DELETE lt_return WHERE type = 'W'.

    READ TABLE lt_return INTO ls_return INDEX 1.
    IF ls_return-type = 'E' AND ls_return-id = 'BAPI' AND ls_return-number = '001'.
      wa_return2-message = 'Error en el archivo, verifique datos'.
      cont = 1.
      LOOP AT lt_tabla INTO ls_tabla WHERE ebelp = ls_cabe-ebelp.
        IF cont = ls_return-row.
          wa_return2-linea = ls_tabla-regis.
        ENDIF.
        cont = cont + 1.
      ENDLOOP.
      "wa_return2-linea   = cont + 1.
      APPEND wa_return2 TO ti_return2.
    ELSE.
      cont = 1.
      LOOP AT lt_tabla INTO ls_tabla WHERE ebelp = ls_cabe-ebelp.
        IF cont = ls_return-row.
          wa_return2-linea = ls_tabla-regis.
        ENDIF.
        cont = cont + 1.
      ENDLOOP.
      wa_return2-message = ls_return-message.
      "wa_return2-linea   = cont + 1.
      APPEND wa_return2 TO ti_return2.
    ENDIF.

    "cont = cont + 1.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MOSTRAR_LOG
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM mostrar_log .

  "ESTRUCTURA ALV
  DATA: ti_catalogo TYPE slis_t_fieldcat_alv,
        st_catalogo TYPE slis_fieldcat_alv,

*Estructura para la configuracion de la salida
        st_layout   TYPE slis_layout_alv,

*Variable con el nombre del programa
        v_repid     LIKE sy-repid.

  CLEAR st_catalogo.
  st_catalogo-fieldname = 'MESSAGE'.        "Nombre del campo
  st_catalogo-tabname   = 'TI_RETURN2'.     "Nombre tabla
  st_catalogo-seltext_s = 'MENSAJE'.     "Descripcion corta Cabecera
  st_catalogo-outputlen = 100.             "Ancho de la columna
  st_catalogo-just      = 'C'.            "Alineacion
  APPEND st_catalogo TO ti_catalogo.

  CLEAR st_catalogo.
  st_catalogo-fieldname = 'LINEA'.        "Nombre del campo
  st_catalogo-tabname   = 'TI_RETURN2'.     "Nombre tabla
  st_catalogo-seltext_s = 'LineaExcel'.        "Descripcion corta Cabecera
  st_catalogo-outputlen = 16.             "Ancho de la columna
  st_catalogo-just      = 'L'.            "Alineacion
  APPEND st_catalogo TO ti_catalogo.

  v_repid = sy-repid.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program = v_repid
      it_fieldcat        = ti_catalogo[]
      is_layout          = st_layout
*     IT_EVENTS          = gt_events
    TABLES
      t_outtab           = ti_return2.




ENDFORM.                    " MOSTRAR_LOG

FORM message.

  DATA obj_alv_table TYPE REF TO cl_salv_table.

* instanciamos la clase con la tabla que contiene los datos
  cl_salv_table=>factory( IMPORTING r_salv_table = obj_alv_table
                          CHANGING t_table       = lt_log ).

* Caracteristicas del POPUP
  obj_alv_table->set_screen_popup(
  start_column = 1
  end_column   = 60
  start_line   = 1
  end_line     = 20 ).

* Lanzamos el ALV
  obj_alv_table->display( ).

ENDFORM.
