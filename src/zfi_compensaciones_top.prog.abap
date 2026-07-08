*&---------------------------------------------------------------------*
*&  Include           ZFI_COMPENSACIONES_TOP.
*&---------------------------------------------------------------------*
TABLES : bkpf, reguh.

DATA: ti_reguh TYPE TABLE OF reguh,
      wa_reguh TYPE reguh,
      ti_regup TYPE TABLE OF regup,
      wa_regup TYPE regup.


TYPES : BEGIN OF t_bkpf,
          bukrs TYPE bkpf-bukrs,
          belnr TYPE bkpf-belnr,
          gjahr TYPE bkpf-gjahr,
        END OF t_bkpf.

DATA: ti_bkpf TYPE TABLE OF t_bkpf,
      wa_bkpf TYPE t_bkpf.

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

DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
*       messages of call transaction
DATA:   messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
*       error session opened (' ' or 'X')
DATA:   e_group_opened.

*DATA: ctumode TYPE c VALUE 'N',
DATA:  cupdate TYPE c VALUE 'L'.


TYPE-POOLS : slis.

CONSTANTS : c_j TYPE c VALUE 'J',
            c_k TYPE c VALUE 'K',
            c_h TYPE c VALUE 'H',
            c_c TYPE c VALUE 'C',
            c_x TYPE c VALUE 'X'.

* Catálogo de campos: contiene la descripción de los campos de salida
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv, "WITH HEADER LINE,
      gt_sort     TYPE slis_t_sortinfo_alv WITH HEADER LINE,

* Especificaciones de la disposición de la lista: descripción de la
* estructura de salida
      gs_layout            TYPE slis_layout_alv,
      gt_list_top_of_page  TYPE slis_t_listheader,
      gt_events            TYPE slis_t_event,
*     gt_sort              type slis_t_sortinfo_alv,
      ls_vari              TYPE disvariant,
*
      g_repid              LIKE sy-repid.
