*&---------------------------------------------------------------------*
*&  Include           ZMM_CARGA_OC_SERVICIOS_TOP
*&---------------------------------------------------------------------*
    DATA: temp_xls  TYPE TABLE OF alsmex_tabline.

    CLASS lcl_report DEFINITION.
      PUBLIC SECTION.

        CONSTANTS : c_x  TYPE c VALUE 'X',
                    c_up TYPE meins VALUE 'UP',
                    c_clp type waers VALUE 'CLP'.

        TYPES : BEGIN OF ty_file,
                  llave     type char3,      "Indicador de OC
                  bukrs     TYPE ekko-bukrs, "Sociedad
                  bsart     TYPE ekko-bsart, "Clase pedido
                  lifnr     TYPE ekko-lifnr, "Proveedor
                  aedat(10) TYPE c,          "Fecha doc.
                  zterm     TYPE ekko-zterm, "Cond.pago
                  ekorg     TYPE ekko-ekorg, "Org.compra
                  ekgrp     TYPE ekko-ekgrp, "Grp.compra
                  waers     TYPE ekko-waers, "Moneda
                  knttp     TYPE ekpo-knttp, "Tipo Imputación
                  pstyp     TYPE ekpo-pstyp, "Tipo posición
                  ebelp     TYPE ekpo-ebelp, "Posicion de pedido
                  txz01     TYPE ekpo-txz01, "Texto breve
                  menge     TYPE ekpo-menge, "Cantidad pedido
                  eindt(10) TYPE c,          "Fecha entrega
                  matkl     TYPE ekpo-matkl, "Grp.artículo
                  werks     TYPE ekpo-werks, "Centro
                  afnam     TYPE ekpo-afnam, "solicitante
                  mwskz     TYPE ekpo-mwskz, "Indicador impuesto
                  kschl     TYPE konv-kschl, "Clase condición ZIVA
                  kbetr     TYPE konv-kbetr, "Importe condición 19%
                  introw    TYPE esll-introw, "Linea de servicio
                  srvpos    TYPE esll-srvpos, "Servicio
                  menge_srv TYPE esll-menge,  "Cantidad
                  precio    TYPE char20,      "Precio
                  kostl     TYPE ekkn-kostl,  "Ceco
                  sakto     TYPE ekkn-sakto,  "Cuenta mayor
                  texto     TYPE char255,      "Texto cabecera
                END OF ty_file.

        TYPES : BEGIN OF ty_data,
                  llave     TYPE char3, "Llave para identificar el corte de cada pedido
                  bukrs     TYPE ekko-bukrs, "Sociedad
                  bsart     TYPE ekko-bsart, "Clase pedido
                  lifnr     TYPE ekko-lifnr, "Proveedor
                  aedat     TYPE ekko-aedat, "Fecha doc.
                  zterm     TYPE ekko-zterm, "Cond.pago
                  ekorg     TYPE ekko-ekorg, "Org.compra
                  ekgrp     TYPE ekko-ekgrp, "Grp.compra
                  waers     TYPE ekko-waers, "Moneda
                  knttp     TYPE ekpo-knttp, "Tipo Imputación
                  pstyp     TYPE ekpo-pstyp, "Tipo posición
                  ebelp     TYPE ekpo-ebelp, "Posicion de pedido
                  txz01     TYPE ekpo-txz01, "Texto breve
                  menge     TYPE ekpo-menge, "Cantidad pedido
                  eindt     TYPE eindt,      "Fecha entrega
                  matkl     TYPE ekpo-matkl, "Grp.artículo
                  werks     TYPE ekpo-werks, "Centro
                  afnam     TYPE ekpo-afnam, "solicitante
                  mwskz     TYPE ekpo-mwskz, "Indicador impuesto
                  kschl     TYPE konv-kschl, "Clase condición ZIVA
                  kbetr     TYPE konv-kbetr, "Importe condición 19%
                  introw    TYPE esll-introw, "Linea de servicio
                  srvpos    TYPE esll-srvpos, "Servicio
                  menge_srv TYPE esll-menge,  "Cantidad
                  brtwr     TYPE esll-brtwr,  "Precio bruto
                  kostl     TYPE ekkn-kostl,  "Ceco
                  sakto     TYPE ekkn-sakto,  "Cuenta mayor
                  texto     TYPE char255,      "Texto cabecera
                  ebeln     TYPE ekko-ebeln,  "Pedido creado
                  message   TYPE bapi_msg,    "Mensaje de error
                END OF ty_data.

        TYPES : BEGIN OF ty_pos,
                  llave     TYPE string, "Llave para identificar el corte de cada pedido
                  ebelp     TYPE ekpo-ebelp, "Posicion de pedido
                  introw    TYPE esll-introw, "Linea de servicio
                  txz01     TYPE ekpo-txz01, "Texto breve
                  menge     TYPE ekpo-menge, "Cantidad pedido
                  knttp     TYPE ekpo-knttp, "Tipo Imputación
                  pstyp     TYPE ekpo-pstyp, "Tipo posición
                  eindt     TYPE eindt,      "Fecha entrega
                  matkl     TYPE ekpo-matkl, "Grp.artículo
                  werks     TYPE ekpo-werks, "Centro
                  afnam     TYPE ekpo-afnam, "solicitante
                  mwskz     TYPE ekpo-mwskz, "Indicador impuesto
                  kschl     TYPE konv-kschl, "Clase condición ZIVA
                  kbetr     TYPE konv-kbetr, "Importe condición 19%
                  srvpos    TYPE esll-srvpos, "Servicio
                  menge_srv TYPE esll-menge,  "Cantidad
                  brtwr     TYPE esll-brtwr,      "Precio
                  kostl     TYPE ekkn-kostl,  "Ceco
                  sakto     TYPE ekkn-sakto,  "Cuenta mayor
                END OF ty_pos.

        DATA: ti_data TYPE TABLE OF ty_data,
              ti_aux type TABLE OF ty_data,
              ti_pos  TYPE TABLE OF ty_pos,
              wa_pos  TYPE ty_pos,
              ti_file TYPE TABLE OF ty_file,
              wa_file TYPE ty_file,
              wa_data TYPE ty_data.
        DATA: o_alv_r TYPE REF TO cl_salv_table.

        METHODS:
          cargar_archivo,
          procesar_archivo,
          formatear_csv,
          generate_out.

        METHODS:
          on_link_click
              FOR EVENT link_click OF cl_salv_events_table
            IMPORTING
              row
              column  .

      PRIVATE SECTION.
        METHODS:
          set_pf_status
            CHANGING
              co_alv TYPE REF TO cl_salv_table.

        METHODS:
          set_columns
            CHANGING
              co_alv TYPE REF TO cl_salv_table.
*
*    METHODS:
*      set_aggregations
*        CHANGING
*          co_alv TYPE REF TO cl_salv_table.

        METHODS:
          set_display_setting
            CHANGING
              co_alv TYPE REF TO cl_salv_table.
    ENDCLASS.                    "lcl_report DEFINITION
