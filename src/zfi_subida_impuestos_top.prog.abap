*&---------------------------------------------------------------------*
*&  Include           ZFI_SUBIDA_IMPUESTOS_TOP
*&---------------------------------------------------------------------*

tables: bkpf.

TYPE-POOLS : slis.

CONSTANTS : c_j TYPE c VALUE 'J',
            c_k TYPE c VALUE 'K',
            c_h TYPE c VALUE 'H',
            c_c TYPE c VALUE 'C',
            c_x TYPE c VALUE 'X'.

DATA: BEGIN OF ti_entrada OCCURS 0,
         blart TYPE bkpf-blart,
         xblnr TYPE bkpf-xblnr,
         stcd1 TYPE lfa1-stcd1,
         budat TYPE bkpf-budat,
         mandt  TYPE  mandt ,
bukrs TYPE  bukrs ,
belnr TYPE  belnr_d ,
gjahr TYPE  gjahr ,
buzei TYPE  buzei ,
mwskz TYPE  mwskz ,
hkont TYPE  hkont ,
txgrp TYPE  txgrp ,
shkzg TYPE  shkzg ,
hwbas TYPE  c LENGTH 16 ,
fwbas TYPE  c LENGTH 16 ,
hwste TYPE  c LENGTH 16 ,
fwste TYPE  c LENGTH 16 ,
ktosl TYPE  ktosl ,
knumh TYPE  knumh ,
stceg TYPE  stceg ,
egbld TYPE  egbld ,
eglld TYPE  eglld ,
txjcd TYPE  txjcd ,
h2ste TYPE  c LENGTH 16 ,
h3ste TYPE  c LENGTH 16 ,
h2bas TYPE  c LENGTH 16 ,
h3bas TYPE  c LENGTH 16 ,
kschl TYPE  kschl ,
stmdt TYPE  stmdt_bset  ,
stmti TYPE  stmti_bset  ,
mlddt TYPE  mlddt_bset  ,
kbetr TYPE  c LENGTH 16 ,
stbkz TYPE  stbkz_007b  ,
lstml TYPE  land1_stml  ,
lwste TYPE  c LENGTH 16 ,
lwbas TYPE  c LENGTH 16 ,
txdat TYPE  txdat ,
bupla TYPE  bupla ,
txjdp TYPE  txjcd_deep  ,
txjlv TYPE  txjcd_level ,
taxps TYPE  tax_posnr ,
txmod TYPE  C LENGTH 3 ,
lifnr type  lfa1-lifnr,
      END OF ti_entrada.

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

DATA: ti_bset TYPE TABLE OF bset,
      wa_bset TYPE bset.
