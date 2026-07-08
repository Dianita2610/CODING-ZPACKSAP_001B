*&---------------------------------------------------------------------*
*&  Include           ZFI_BAJA_RETENCIONES_TOP
*&---------------------------------------------------------------------*
TABLES: bkpf.

TYPE-POOLS : slis.

CONSTANTS : c_j TYPE c VALUE 'J',
            c_k TYPE c VALUE 'K',
            c_h TYPE c VALUE 'H',
            c_c TYPE c VALUE 'C',
            c_x TYPE c VALUE 'X'.

TYPES: BEGIN OF t_lfa1,
         lifnr TYPE lfa1-lifnr,
         stcd1 TYPE lfa1-stcd1,
       END OF t_lfa1.

TYPES: BEGIN OF t_bkpf,
         bukrs TYPE bkpf-bukrs,
         belnr TYPE bkpf-belnr,
         gjahr TYPE bkpf-gjahr,
         xblnr TYPE bkpf-xblnr,
         blart TYPE bkpf-blart,
         budat TYPE bkpf-budat,
       END OF t_bkpf.

DATA: BEGIN OF t_salida,
         blart TYPE bkpf-blart,
         xblnr TYPE bkpf-xblnr,
         stcd1 TYPE lfa1-stcd1,
         budat TYPE bkpf-budat.
      INCLUDE STRUCTURE with_item.
DATA:   END OF t_salida.

DATA : ti_salida LIKE t_salida OCCURS 1000 WITH HEADER LINE,
       ti_bkpf type table of t_bkpf,
       wa_bkpf type t_bkpf,
       wa_salida LIKE t_salida.

DATA: ti_lfa1 TYPE TABLE OF t_lfa1,
      wa_lfa1 TYPE t_lfa1.

DATA: ti_with_item TYPE TABLE OF with_item,
      wa_with_item TYPE with_item.


* Catálogo de campos: contiene la descripción de los campos de salida
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv ,
      gt_sort     TYPE slis_t_sortinfo_alv WITH HEADER LINE,
* Especificaciones de la disposición de la lista: descripción de la
* estructura de salida
      gs_layout            TYPE slis_layout_alv,
      gt_list_top_of_page  TYPE slis_t_listheader,
      gt_events            TYPE slis_t_event,
*     gt_sort              type slis_t_sortinfo_alv,
      ls_vari              TYPE disvariant,
      g_repid              LIKE sy-repid.
