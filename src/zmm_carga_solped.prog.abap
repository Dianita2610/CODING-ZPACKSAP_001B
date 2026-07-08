*&---------------------------------------------------------------------*
*& Report  ZMM_CARGA_SOLPED
*&
*&---------------------------------------------------------------------*
*&
*&Objetivo: carga masiva para creacion de solicitudes de pedidos desde
*& archivo excel
*&---------------------------------------------------------------------*

REPORT  zmm_carga_solped.

TYPE-POOLS: slis.

TYPES: BEGIN OF ty_salida,

  bnfpo         TYPE eban-bnfpo,    "N° Posicion
  tip_doc       TYPE char10,        "tipo documentp
  ekgrp         TYPE eban-ekgrp,    "Grupo de compra
  afnam         TYPE eban-afnam,    "Solicitante
  txz01         TYPE eban-txz01,    "Texto breve (AF)
  matnr         TYPE eban-matnr,    "Material
  werks         TYPE eban-werks,    "Centro
  lgort         TYPE eban-lgort,    "Almacen
  matkl         TYPE eban-matkl,    "Grupo de articulos
  menge         TYPE eban-menge,    "Cantidad
  meins         TYPE eban-meins,    "Unidad medida base
  lfdat         TYPE eban-lfdat,    "Fecha de entrega
  preis         TYPE eban-preis,    "Precio
  knttp         TYPE eban-knttp,    "Tipo de imputacion
  lifnr         TYPE eban-lifnr,    "Proveedor
  ekorg         TYPE eban-ekorg,    "Organizacion de compras
  bmein         TYPE eban-bmein,    "Unidad de medida compra
  bnfpo2        TYPE ebkn-bnfpo,    "N° posicion
  sakto         TYPE ebkn-sakto,    "Cuenta de mayor
  kostl         TYPE ebkn-kostl,    "Centro de costo
  anln1         TYPE ebkn-anln1,    "N° activo fijo
  anln2         TYPE ebkn-anln2,    "Sub N° activo fijo
END OF ty_salida.

TYPES: BEGIN OF ty_return,
  message  type char100,
  linea    type i,

END OF ty_return.

DATA: p_file_name TYPE string,
      p_fullpath TYPE string,
      error(255),

      it_datos TYPE TABLE OF ty_salida,
      wa_datos LIKE LINE OF  it_datos,

      it_excel TYPE STANDARD TABLE OF alsmex_tabline,
      wa_excel TYPE alsmex_tabline,
      v_id     TYPE i,
      v_value(30),
      ret      like  bapiret2,
      cont     TYPE i value 1.

DATA: ti_requisition_item          TYPE TABLE OF bapiebanc,
      wa_requisition_item          TYPE bapiebanc,
      ti_requisition_account_assig TYPE TABLE OF bapiebkn,
      wa_requisition_account_assig TYPE bapiebkn,
      ti_return                    TYPE TABLE OF bapireturn,
      ti_return2                   TYPE TABLE OF ty_return,
      wa_return2                   TYPE ty_return,
      wa_return                    TYPE bapireturn.


*--------------------------------------------------------------------------
*Parametros de entrada
*--------------------------------------------------------------------------

*PEDIMOS EL ARCHIVO A SUBIR
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME.
PARAMETERS  p_file  LIKE rlgrap-filename OBLIGATORY.
SELECTION-SCREEN END OF BLOCK blk1.

*---------------------------------------------------------------------------
*AT SELECTION-SCREEN
*---------------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
*ESTA FUNCIÓN NOS AYUDA A UBICAR EL ARCHIVO COMO LO HARÍAMOS EN WINDOWS
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
  PERFORM cargar_tablas.
*  PERFORM ejecutar_bapi.
  PERFORM mostrar_log.

*&---------------------------------------------------------------------*
*&      Form  TRANSFORMAR_EXCEL
*&---------------------------------------------------------------------*
*       Objetivo: transformar archivo excel en tabla interna
*----------------------------------------------------------------------*
FORM transformar_excel .

*  PASAMOS EL ARCHIVO DE EXCEL A LA TABLA INTERNA
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
  EXPORTING
    filename                = p_file
*COLUMNA DONDE SE EMPIEZA A BUSCAR DATOS
    i_begin_col             = 1
*RENGLÓN DONDE SE EMPIEZA A BUSCAR DATOS
    i_begin_row             = 2
*COLUMNA DONDE TERMINA DE BUSCAR DATOS
    i_end_col               = 22
*RENGLÓN DONDE TERMINA DE BUSCAR DATOS
    i_end_row               = 1000000
  TABLES
*TABLA INTERNA DONDE ME REGRESA LOS DATOS
    intern                  = it_excel
  EXCEPTIONS
    inconsistent_parameters = 1
    upload_ole              = 2
    OTHERS                  = 3.
  IF sy-subrc <> 0.
    MESSAGE e010(ad) WITH 'Error en el archivo, verifique datos'.
  ELSE.
*ORDENAMOS DATOS EN TABLA FINAL.
    DO.
      v_id = v_id + 1.
      LOOP AT it_excel INTO wa_excel WHERE row = v_id.
        CASE wa_excel-col.

          WHEN '0001'.
            wa_datos-bnfpo    = wa_excel-value.
          WHEN '0002'.
            wa_datos-tip_doc  = wa_excel-value.
          WHEN '0003'.
            wa_datos-ekgrp    = wa_excel-value.
          WHEN '0004'.
            wa_datos-afnam    = wa_excel-value.
          WHEN '0005'.
            wa_datos-txz01    = wa_excel-value.
          WHEN '0006'.
            wa_datos-matnr    = wa_excel-value.
          WHEN '0007'.
            wa_datos-werks    = wa_excel-value.
          WHEN '0008'.
            wa_datos-lgort    = wa_excel-value.
          WHEN '0009'.
            wa_datos-matkl    = wa_excel-value.
          WHEN '00010'.
            wa_datos-menge    = wa_excel-value.
          WHEN '00011'.
            wa_datos-meins    = wa_excel-value.
          WHEN '00012'.
            REPLACE ALL OCCURRENCES OF '.' in wa_excel-value WITH ''. CONDENSE wa_excel-value NO-GAPS.
            CONCATENATE wa_excel-value+4(4) wa_excel-value+2(2) wa_excel-value(2) into wa_datos-lfdat.
*            wa_datos-lfdat    = wa_excel-value.
          WHEN '00013'.
            wa_datos-preis    = wa_excel-value.
          WHEN '00014'.
            wa_datos-knttp    = wa_excel-value.
          WHEN '00015'.
            wa_datos-lifnr    = wa_excel-value.
          WHEN '00016'.
            wa_datos-ekorg    = wa_excel-value.
          WHEN '00017'.
            wa_datos-bmein    = wa_excel-value.
          WHEN '00018'.
            wa_datos-bnfpo2   = wa_excel-value.
          WHEN '00019'.
            wa_datos-sakto    = wa_excel-value.
          WHEN '00020'.
            wa_datos-kostl    = wa_excel-value.
          WHEN '00021'.
            wa_datos-anln1    = wa_excel-value.
          WHEN '00022'.
            wa_datos-anln2    = wa_excel-value.
        ENDCASE.
      ENDLOOP.
      "Si se cargaron datos a la tabla interna, validamos que venga
      "información en campos que sean obligatorios
      IF sy-subrc = 0.
        IF wa_datos-ekgrp  IS INITIAL .
          MESSAGE i010(ad) WITH 'Faltan datos en el archivo' DISPLAY LIKE 'E'.
          EXIT.
        ELSE.
          APPEND wa_datos TO it_datos.
          CLEAR wa_datos.
        ENDIF.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.
    IF it_datos[] IS INITIAL.
      MESSAGE e010(ad) WITH 'Error en el archivo, verifique datos'.
      "SI TODO HA SALIDO BIEN, YA TENEMOS LOS DATOS EN NUESTRA TABLA INTERNA
      "ELSE.
      "WRITE: SY-ULINE,10 'DISTRO',40 'VERSION',70 'DIFICULTAD',SY-ULINE,/.

      WRITE sy-uline.
    ENDIF.
  ENDIF.

ENDFORM.                    " TRANSFORMAR_EXCEL
*&---------------------------------------------------------------------*
*&      Form  CARGAR_TABLAS
*&---------------------------------------------------------------------*
*       Objetivo: llena tablas para la bapi
*----------------------------------------------------------------------*
FORM cargar_tablas .

  LOOP AT it_datos INTO wa_datos.

    wa_requisition_item-preq_item   = wa_datos-bnfpo.
    wa_requisition_item-doc_type    = 'NB'.
    wa_requisition_item-pur_group   = wa_datos-ekgrp.
    wa_requisition_item-preq_name   = wa_datos-afnam.
    wa_requisition_item-short_text  = wa_datos-txz01.

*     Función que completa con ceros a la izquierda de una variable
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = wa_datos-matnr
    IMPORTING
      OUTPUT = wa_datos-matnr.


    wa_requisition_item-material    = wa_datos-matnr.
    wa_requisition_item-plant       = wa_datos-werks.
    wa_requisition_item-store_loc   = wa_datos-lgort.
    wa_requisition_item-mat_grp     = wa_datos-matkl.
    wa_requisition_item-quantity    = wa_datos-menge.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
    EXPORTING
      INPUT  = wa_datos-meins
    IMPORTING
      OUTPUT = wa_datos-meins.

    wa_requisition_item-unit        = wa_datos-meins.
    wa_requisition_item-deliv_date  = wa_datos-lfdat.
    wa_requisition_item-c_amt_bapi  = wa_datos-preis.
    wa_requisition_item-acctasscat  = wa_datos-knttp.

*     Función que completa con ceros a la izquierda de una variable
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = wa_datos-lifnr
    IMPORTING
      OUTPUT = wa_datos-lifnr.

    wa_requisition_item-des_vendor  = wa_datos-lifnr.
    wa_requisition_item-purch_org   = wa_datos-ekorg.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
    EXPORTING
      INPUT  = wa_datos-bmein
    IMPORTING
      OUTPUT = wa_datos-bmein.
*    IF wa_datos-bmein eq 'CA'.
*    wa_datos-bmein = 'KI'.
*    ENDIF.


    wa_requisition_item-po_unit     = wa_datos-bmein.
    APPEND wa_requisition_item TO ti_requisition_item.
    CLEAR wa_requisition_item.


    wa_requisition_account_assig-preq_item  = wa_datos-bnfpo2.
    wa_requisition_account_assig-g_l_acct   = wa_datos-sakto.
    wa_requisition_account_assig-cost_ctr   = wa_datos-kostl.

*     Función que completa con ceros a la izquierda de una variable
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = wa_datos-anln1
    IMPORTING
      OUTPUT = wa_datos-anln1.

    wa_requisition_account_assig-asset_no   = wa_datos-anln1.

*     Función que completa con ceros a la izquierda de una variable
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = wa_datos-anln2
    IMPORTING
      OUTPUT = wa_datos-anln2.

    wa_requisition_account_assig-sub_number = wa_datos-anln2.
    APPEND wa_requisition_account_assig TO ti_requisition_account_assig.
    CLEAR wa_requisition_account_assig.

    PERFORM ejecutar_bapi.
    refresh: ti_requisition_item, ti_requisition_account_assig.

    READ TABLE ti_return into wa_return INDEX 1.
    wa_return2-message = wa_return-message.
    wa_return2-linea   = cont + 1.
    APPEND wa_return2 to ti_return2.

    cont = cont + 1.
  ENDLOOP.

ENDFORM.                    " CARGAR_TABLAS
*&---------------------------------------------------------------------*
*&      Form  EJECUTAR_BAPI
*&---------------------------------------------------------------------*
*       Objetivo: ejecuta bapi para crear las solped
*----------------------------------------------------------------------*
FORM ejecutar_bapi .

  CALL FUNCTION 'BAPI_REQUISITION_CREATE' "#EC CI_USAGE_OK[2438131]
*EXPORTING
*  SKIP_ITEMS_WITH_ERROR                =
*  AUTOMATIC_SOURCE                     = 'X'
*IMPORTING
*  NUMBER                                = dd"W_ITAB-BANFN
  TABLES
    requisition_items                    = ti_requisition_item
    requisition_account_assignment       = ti_requisition_account_assig
    RETURN                               = ti_return.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
  EXPORTING
    WAIT   = 'X'
  IMPORTING
    RETURN = ret. "estructura para mensajes
ENDFORM.                    " EJECUTAR_BAPI
*&---------------------------------------------------------------------*
*&      Form  MOSTRAR_LOG
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
form MOSTRAR_LOG .

  "ESTRUCTURA ALV
  DATA: ti_catalogo TYPE slis_t_fieldcat_alv,
        st_catalogo TYPE slis_fieldcat_alv,

*Estructura para la configuracion de la salida
        st_layout    TYPE slis_layout_alv,

*Variable con el nombre del programa
        v_repid LIKE sy-repid.

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
*      IT_EVENTS          = gt_events
  TABLES
    t_outtab           = ti_return2.




endform.                    " MOSTRAR_LOG
