*&---------------------------------------------------------------------*
*&  Include           ZMMRP_PPTO_VTA_MANT_TOP
*&---------------------------------------------------------------------*

TABLES: zmm_ppto_vta.

CLASS: lcl_event_receiver DEFINITION DEFERRED,
       lcl_maintainer     DEFINITION DEFERRED.

DATA: ps_ucomm LIKE sy-ucomm.

DATA: go_maintainer       TYPE REF TO lcl_maintainer,
      go_receiver         TYPE REF TO lcl_event_receiver,
      go_custom_container TYPE REF TO cl_gui_custom_container,
      go_grid             TYPE REF TO cl_gui_alv_grid.

DATA:   gt_zmm_ppto_vta TYPE zmm_ppto_vta OCCURS 0,
        wa_zmm_ppto_vta TYPE zmm_ppto_vta,
        gs_zmm_ppto_vta TYPE zmm_ppto_vta,
        gt_fieldcat     TYPE lvc_t_fcat WITH HEADER LINE,
        gs_layout       TYPE lvc_s_layo,
        wreg            TYPE zmm_ppto_vta.

DATA: sw,
      zeile     LIKE mesg-zeile,
      pzeile(4) TYPE p DECIMALS 0,
      view      TYPE c LENGTH 2.

DATA: g_selected_row LIKE lvc_s_row,
      ind            TYPE lvc_index.
