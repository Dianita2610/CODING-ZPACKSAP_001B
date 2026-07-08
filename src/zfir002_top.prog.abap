*&---------------------------------------------------------------------*
*&  Include           ZFIR002_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS: slis.
TABLES : bkpf, bseg.
DATA : it_bdcdata    LIKE bdcdata OCCURS 0 WITH HEADER LINE,
       it_bdcmsgcoll LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.

DATA : cuenta_pago TYPE bseg-hkont VALUE '0000112620',
       c_x         TYPE c VALUE 'X',
       c_n         TYPE c VALUE 'N',
       c_s         TYPE c VALUE 'S'.

DATA messtab TYPE STANDARD TABLE OF bdcmsgcoll.
DATA ls_messtab LIKE LINE OF messtab.
DATA l_message TYPE string.
DATA t_log TYPE STANDARD TABLE OF bdcmsgcoll.
TYPES : BEGIN OF t_bsid,
          id      TYPE i,
          bukrs   TYPE bsid-bukrs,
          kunnr   TYPE bsid-kunnr,
          zuonr   TYPE bsid-zuonr,
          hkont   TYPE bsid-hkont,
          umskz   TYPE bsid-umskz,
          vertn   TYPE bsid-vertn,
*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
          xref1   TYPE xref1,
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP
          vertt   TYPE bsid-vertt,
          xblnr   TYPE bsid-xblnr,
          belnr   TYPE bsid-belnr,
          gjahr   TYPE bsid-gjahr,
          blart   TYPE bsid-blart,
          bldat   TYPE bsid-bldat,
          zfbdt   TYPE bsid-zfbdt,
          wrbtr   TYPE bsid-wrbtr,
          waers   TYPE bsid-waers,
          shkzg   TYPE bsid-shkzg,
          mensaje TYPE char50,
        END OF t_bsid.

TYPES: gtt_bsid TYPE STANDARD TABLE OF t_bsid.

DATA : ti_anticipos   TYPE TABLE OF t_bsid,
       ti_docs        TYPE TABLE OF t_bsid,
       wa_docs        TYPE t_bsid,
       wa_anticipos   TYPE t_bsid.

* Catálogo de campos: contiene la descripción de los campos de salida
DATA: gt_fieldcat         TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gt_sort             TYPE slis_t_sortinfo_alv WITH HEADER LINE,

* Especificaciones de la disposición de la lista: descripción de la
* estructura de salida
      gs_layout           TYPE slis_layout_alv,
      gt_list_top_of_page TYPE slis_t_listheader,
      gt_events           TYPE slis_t_event,
*     gt_sort              type slis_t_sortinfo_alv,
      ls_vari             TYPE disvariant,
*
      g_repid             LIKE sy-repid.

DATA : ti_salida TYPE TABLE OF t_bsid,
       wa_salida TYPE t_bsid.

FIELD-SYMBOLS : <fs_bsid>   TYPE t_bsid,
                <fs_pago>   TYPE t_bsid,
                <fs_salida> TYPE t_bsid.

DATA: v_contrato1 TYPE bsid-vertn,
      v_contrato2 TYPE bsid-vertn.
