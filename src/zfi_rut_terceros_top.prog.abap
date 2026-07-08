*&---------------------------------------------------------------------*
*&  Include           ZFI_RUT_TERCEROS_TOP
*&---------------------------------------------------------------------*
TABLES: bkpf, bseg.

TYPE-POOLS : slis.

CONSTANTS : c_j TYPE c VALUE 'J',
            c_k TYPE c VALUE 'K',
            c_h TYPE c VALUE 'H',
            c_c TYPE c VALUE 'C',
            c_x TYPE c VALUE 'X'.


TYPES: BEGIN OF t_salida,
         bukrs TYPE bseg-bukrs,
         belnr TYPE bseg-belnr,
         gjahr TYPE bseg-gjahr,
         buzei TYPE bseg-buzei,
         budat type bkpf-budat,
         cpudt type bkpf-cpudt,
         blart type bkpf-blart,
         xblnr type bkpf-xblnr,
         bschl TYPE bseg-bschl,
         waers type bkpf-waers,
         wrbtr TYPE bseg-wrbtr,
         hkont TYPE bseg-hkont,
         zzrut_terc TYPE bseg-zzrut_terc,
         lifnr TYPE bseg-lifnr,
       END OF t_salida.

data: ti_salida type TABLE OF t_salida,
      wa_Salida type t_salida.
* Catálogo de campos: contiene la descripción de los campos de salida
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gt_sort     TYPE slis_t_sortinfo_alv WITH HEADER LINE,
* Especificaciones de la disposición de la lista: descripción de la
* estructura de salida
      gs_layout            TYPE slis_layout_alv,
      gt_list_top_of_page  TYPE slis_t_listheader,
      gt_events            TYPE slis_t_event,
*     gt_sort              type slis_t_sortinfo_alv,
      ls_vari              TYPE disvariant,
      g_repid              LIKE sy-repid.

DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
*       messages of call transaction
DATA:   messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
*       error session opened (' ' or 'X')
DATA:   e_group_opened.

DATA: ctumode TYPE c VALUE 'N',
      cupdate TYPE c VALUE 'L'.
TYPES : BEGIN OF t_balmi,
      msgty TYPE balmi-msgty,
      msgid TYPE balmi-msgid,
      msgno TYPE balmi-msgno,
      msgv1 TYPE char100,
      msgv2  TYPE char100,
      msgv3  TYPE char100,
      msgv4  TYPE char100,
      altext TYPE balmi-altext,
      userexitp TYPE balmi-userexitp,
      userexitf TYPE balmi-userexitf,
      detlevel TYPE balmi-detlevel,
      probclass TYPE balmi-probclass,
      alsort TYPE balmi-alsort,
      END OF t_balmi.

DATA:  ti_log        TYPE TABLE OF t_balmi,
       wa_log        TYPE t_balmi.
