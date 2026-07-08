*&---------------------------------------------------------------------*
*&  Include           ZFIBI_001_TOP
*&---------------------------------------------------------------------*
TABLES : bkpf, t100.
TYPE-POOLS : slis.
CONSTANTS: c_x TYPE c VALUE 'X'.

DATA: l_mstring(480),
      gs_params  LIKE ctu_params,
      gt_messtab TYPE TABLE OF bdcmsgcoll,
      wa_messtab TYPE bdcmsgcoll,
      gd_file    TYPE string,
      gt_intern  TYPE kcde_cells OCCURS 0 WITH HEADER LINE,
      gd_error,
      gd_fecha(10),
      gd_bstat TYPE bkpf-bstat.
DATA: t_log TYPE STANDARD TABLE OF bdcmsgcoll,
      ls_mess LIKE LINE OF gt_messtab,
      ti_bdcdata TYPE TABLE OF bdcdata,
      wa_bdcdata TYPE bdcdata.

TYPES: BEGIN OF t_bkpf,
         bukrs TYPE bkpf-bukrs,
         belnr TYPE bkpf-belnr,
         gjahr TYPE bkpf-gjahr,
         xblnr type bkpf-xblnr,
         budat TYPE bkpf-budat,
         blart TYPE bkpf-blart,
         bktxt TYPE bkpf-bktxt,
       END OF t_bkpf.

DATA: ti_bkpf TYPE TABLE OF t_bkpf,
      wa_bkpf TYPE t_bkpf.

* Catálogo de campos: contiene la descripción de los campos de salida
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv,
      gt_sort     TYPE slis_t_sortinfo_alv WITH HEADER LINE,
* Especificaciones de la disposición de la lista: descripción de la
* estructura de salida
      gs_layout            TYPE slis_layout_alv,
      gt_list_top_of_page  TYPE slis_t_listheader,
      gt_events            TYPE slis_t_event,
*     gt_sort              type slis_t_sortinfo_alv,
      ls_vari              TYPE disvariant,
      g_repid              LIKE sy-repid.
