*&---------------------------------------------------------------------*
*&  Include           ZFI_ACTUALZIA_REGUH_TOP
*&---------------------------------------------------------------------*

TABLES: bkpf.

TYPE-POOLS : slis.

CONSTANTS : c_j TYPE c VALUE 'J',
            c_k TYPE c VALUE 'K',
            c_h TYPE c VALUE 'H',
            c_c TYPE c VALUE 'C',
            c_x TYPE c VALUE 'X'.

DATA: BEGIN OF ti_entrada OCCURS 0,
        fecha(10) TYPE c,
        laufi     TYPE reguh-laufi,
        zbukr     TYPE reguh-zbukr ,
        lifnr     TYPE lfa1-lifnr,
        vblnr     TYPE reguh-vblnr,
        id_pago   TYPE reguh-identif_pago,
      END OF ti_entrada.

TYPES: BEGIN OF t_salida ,
        laufd     TYPE reguh-laufd,
        laufi     TYPE reguh-laufi,
        zbukr     TYPE reguh-zbukr,
        lifnr     TYPE lfa1-lifnr,
        vblnr     TYPE reguh-vblnr,
        id_pago   TYPE reguh-identif_pago,
      END OF t_salida.

data: ti_salida type TABLE OF t_Salida,
      ti_Reguh type TABLE OF reguh,
      wa_reguh type reguh,
      wa_salida type t_salida.

FIELD-SYMBOLS: <FS> TYPE REGUH.
* Catálogo de campos: contiene la descripción de los campos de salida
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv ,
      gt_sort     TYPE slis_t_sortinfo_alv WITH HEADER LINE,
* Especificaciones de la disposición de la lista: descripción de la
* estructura de salida
      gs_layout            TYPE slis_layout_alv,
      gt_list_top_of_page  TYPE slis_t_listheader,
      gt_events            TYPE slis_t_event,
      ls_vari              TYPE disvariant,
      g_repid              LIKE sy-repid.
