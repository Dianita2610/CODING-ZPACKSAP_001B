*&---------------------------------------------------------------------*
*&  Include           ZMMR_PO_RELEASE_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS: slis.

TABLES: t16fv, ekko, t100.

CLASS: lcl_event_alv DEFINITION DEFERRED,
       lcl_report    DEFINITION DEFERRED.

CONSTANTS: gc_frgsx TYPE t16fv-frgsx VALUE '51'.

FIELD-SYMBOLS: <fs_tab> TYPE STANDARD TABLE.

TYPES:
       BEGIN OF ty_col,
        string TYPE char100,
       END OF ty_col,

       BEGIN OF ty_detail,
        ebeln TYPE ekko-ebeln,
        ebelp TYPE ekpo-ebelp,
        matnr TYPE ekpo-matnr,
        maktx TYPE makt-maktx,
        werks TYPE ekpo-werks,
        name1 TYPE t001w-name1,
        konts TYPE t030-konts,
        menge TYPE ekpo-menge,
        netpr TYPE ekpo-netpr,
        netwr TYPE ekpo-netwr,
        waers TYPE ekko-waers,
       END OF ty_detail.

DATA: go_event     TYPE REF TO lcl_event_alv,
      go_report    TYPE REF TO lcl_report,
      gr_events    TYPE REF TO cl_salv_events_table,
      gr_functions TYPE REF TO cl_salv_functions,
      gr_aggs      TYPE REF TO cl_salv_aggregations,
      gr_columns   TYPE REF TO cl_salv_columns_table,
      gr_column    TYPE REF TO cl_salv_column_table,
      gr_sorts     TYPE REF TO cl_salv_sorts.

DATA: gt_result TYPE STANDARD TABLE OF ty_detail,
      gs_result LIKE LINE OF gt_result,
      gs_t16fv  TYPE t16fv,
      gt_ekko   TYPE STANDARD TABLE OF ekko WITH HEADER LINE,
      gt_ekpo   TYPE STANDARD TABLE OF ekpo WITH HEADER LINE,
      gt_t030   TYPE STANDARD TABLE OF t030,
      gt_return TYPE STANDARD TABLE OF bapireturn WITH HEADER LINE.

DATA: BEGIN OF gt_t001k OCCURS 0,
        matnr TYPE mbew-matnr,
        bwkey TYPE t001k-bwkey,
        bwmod TYPE t001k-bwmod,
        bklas TYPE mbew-bklas,
      END OF gt_t001k,

      BEGIN OF gt_mbew OCCURS 0,
        matnr TYPE mbew-matnr,
        bwkey TYPE mbew-bwkey,
        bklas TYPE mbew-bklas,
      END OF gt_mbew,

      BEGIN OF gt_makt OCCURS 0,
        matnr TYPE makt-matnr,
        maktx TYPE makt-maktx,
      END OF gt_makt,

      BEGIN OF gt_t001w OCCURS 0,
        werks TYPE t001w-werks,
        name1 TYPE t001w-name1,
      END OF gt_t001w,

      BEGIN OF gt_oc OCCURS 0,
        ebeln TYPE ekko-ebeln,
      END OF gt_oc.

DATA BEGIN OF msg_tab OCCURS 1.
        INCLUDE STRUCTURE bdcmsgcoll.
DATA END OF msg_tab.

DATA: BEGIN OF t_msg OCCURS 1,
       msgtyp  LIKE msg_tab-msgtyp,
       msgnr   LIKE msg_tab-msgnr,
       icon(4) TYPE c,
       mstring(480),
       ebeln   LIKE ekko-ebeln,
      END OF t_msg.
