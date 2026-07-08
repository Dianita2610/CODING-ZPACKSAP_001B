*&---------------------------------------------------------------------*
*&  Include           ZMMR_PO_RELEASE_CD1
*&---------------------------------------------------------------------*
CLASS lcl_event_alv DEFINITION.
  PUBLIC SECTION.
    METHODS:
      user_command FOR EVENT added_function OF cl_salv_events_table
        IMPORTING e_salv_function,

      call_transaction FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.

ENDCLASS.                    "lcl_event_alv DEFINITION

CLASS lcl_report DEFINITION.
  PUBLIC SECTION.
    METHODS:

      constructor
        IMPORTING iv_tabnam TYPE char20,

      get_data, " EXPORTING ev_detail TYPE STANDARD TABLE,

      process_data EXPORTING ev_detail TYPE STANDARD TABLE,

      modify_title
        IMPORTING io_column TYPE REF TO cl_salv_columns_table
                  iv_fields TYPE string,

      modify_column
        IMPORTING io_column TYPE REF TO cl_salv_columns_table
                  iv_fields TYPE string,

      add_aggregation
        IMPORTING io_agg  TYPE REF TO cl_salv_aggregations
                  iv_fields TYPE string,

      set_hospot
        IMPORTING io_column TYPE REF TO cl_salv_columns_table
                  iv_fields TYPE string,

      built_alv,

      bapi_release.

  PRIVATE SECTION.
    DATA: mv_tabnam TYPE char20,
          mr_table TYPE REF TO cl_salv_table,
          mv_detail TYPE TABLE OF ty_detail.

ENDCLASS.                    "lcl_report DEFINITION
