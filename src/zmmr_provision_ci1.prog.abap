*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZMMR_PROVISION_CI1
*&---------------------------------------------------------------------*
CLASS lcl_event_alv IMPLEMENTATION.

  METHOD user_command.
    PERFORM create_file USING e_salv_function.
  ENDMETHOD.                    "user_command

  METHOD call_transaction.
* / CALL OC
    IF column EQ 'EBELN'.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
SORT GT_RESULT .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
      READ TABLE gt_result INTO gs_result INDEX row.
      IF sy-subrc = 0.
        IF gs_result-ebeln IS NOT INITIAL.
          SET PARAMETER ID 'BES' FIELD gs_result-ebeln.
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "call_transaction
ENDCLASS.                    "lcl_event_alv IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS lcl_report IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_report IMPLEMENTATION.
  METHOD constructor.
    mv_tabnam   = iv_tabnam.
  ENDMETHOD.                    "constructor

  METHOD modify_title.

    DATA: name_col   TYPE lvc_fname,
          text_s(10),
          text_m(20),
          text_l(40),
          text_c(30),
          text TYPE string.

    DATA: lr_column TYPE REF TO cl_salv_column_table.

    DATA: it_col TYPE STANDARD TABLE OF ty_col,
          wa_col LIKE LINE OF it_col.

    SPLIT iv_fields AT ';' INTO TABLE it_col.

    LOOP AT it_col INTO wa_col.

      SPLIT wa_col AT '|' INTO name_col text.
      TRANSLATE name_col TO UPPER CASE.                  "#EC TRANSLANG

      TRY.
          IF name_col IS NOT INITIAL AND text IS NOT INITIAL.
            lr_column ?= io_column->get_column( name_col ).
            MOVE text TO: text_s, text_m, text_l, text_c.

            lr_column->set_long_text( text_l ).
            lr_column->set_short_text( text_s ).
            lr_column->set_medium_text( text_m ).
          ENDIF.

        CATCH cx_salv_not_found cx_salv_existing cx_salv_data_error.
      ENDTRY.

    ENDLOOP.
  ENDMETHOD.                    "modify_title

  METHOD modify_column.

    DATA: name_col TYPE lvc_fname,
          length   TYPE lvc_outlen.

    DATA: lr_column TYPE REF TO cl_salv_column_table.

    DATA: it_col TYPE STANDARD TABLE OF ty_col,
          wa_col LIKE LINE OF it_col.

    SPLIT iv_fields AT ';' INTO TABLE it_col.

    LOOP AT it_col INTO wa_col.

      SPLIT wa_col AT '|' INTO name_col length.
      TRANSLATE name_col TO UPPER CASE.                  "#EC TRANSLANG

      TRY.
          IF name_col IS NOT INITIAL AND length IS NOT INITIAL.
            lr_column ?= io_column->get_column( name_col ).
            lr_column->set_output_length( length ).
          ENDIF.

        CATCH cx_salv_not_found cx_salv_existing cx_salv_data_error.
      ENDTRY.

    ENDLOOP.
  ENDMETHOD.                    "modify_column

  METHOD add_aggregation.

    DATA: name_col TYPE lvc_fname,
          opt      TYPE char01,
          aggr_typ TYPE salv_de_aggregation.

    DATA: it_col TYPE STANDARD TABLE OF ty_col,
          wa_col LIKE LINE OF it_col.

    SPLIT iv_fields AT ';' INTO TABLE it_col.

    LOOP AT it_col INTO wa_col.

      SPLIT wa_col AT '|' INTO name_col opt.
      TRANSLATE name_col TO UPPER CASE.                  "#EC TRANSLANG

      CASE opt.
        WHEN '1'.
          aggr_typ = if_salv_c_aggregation=>total.
        WHEN '2'.
          aggr_typ = if_salv_c_aggregation=>minimum.
        WHEN '3'.
          aggr_typ = if_salv_c_aggregation=>maximum.
        WHEN '4'.
          aggr_typ = if_salv_c_aggregation=>average.
        WHEN OTHERS.
          aggr_typ = 0.
      ENDCASE.

      TRY.
          io_agg->add_aggregation(
            EXPORTING
              columnname  = name_col
              aggregation = aggr_typ ).

        CATCH cx_salv_data_error.                       "#EC NO_HANDLER
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
        CATCH cx_salv_existing.                         "#EC NO_HANDLER
      ENDTRY.

    ENDLOOP.
  ENDMETHOD.                    "add_aggregation

  METHOD set_hospot.

    DATA: name_col TYPE lvc_fname.

    DATA: lr_column TYPE REF TO cl_salv_column_table.

    DATA: it_col TYPE STANDARD TABLE OF ty_col,
          wa_col LIKE LINE OF it_col.

    SPLIT iv_fields AT ';' INTO TABLE it_col.

    LOOP AT it_col INTO wa_col.

      MOVE wa_col TO name_col.
      TRANSLATE name_col TO UPPER CASE.                  "#EC TRANSLANG

      TRY.
          lr_column ?= io_column->get_column( name_col ).
          lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
      ENDTRY.

    ENDLOOP.
  ENDMETHOD.                    "set_hospot

  METHOD built_alv.

    DATA: lv_fields TYPE string.

    DATA: lr_layout TYPE REF TO cl_salv_layout,
          ls_key    TYPE salv_s_layout_key.

    ASSIGN (mv_tabnam) TO <fs_tab>.
    IF mr_table IS INITIAL.

      TRY.

          CALL METHOD cl_salv_table=>factory
            IMPORTING
              r_salv_table = mr_table
            CHANGING
              t_table      = <fs_tab>.

        CATCH cx_salv_msg.

      ENDTRY.

      mr_table->set_screen_status(
      pfstatus = 'STANDARD'
      report = sy-repid
      set_functions = mr_table->c_functions_all ).

      lr_layout = mr_table->get_layout(  ).
      ls_key-report = sy-repid.
      lr_layout->set_key( ls_key ).

      lr_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
      lr_layout->set_initial_layout( p_layout ).

      CREATE OBJECT go_event.
      gr_events = mr_table->get_event( ).

      SET HANDLER: go_event->user_command FOR gr_events,
                   go_event->call_transaction FOR gr_events.

      gr_functions = mr_table->get_functions( ).
      gr_functions->set_all( abap_true ).
      gr_columns = mr_table->get_columns( ).

* / Set fields as a hospot
      CLEAR lv_fields.
      lv_fields = 'EBELN;'.                     "#EC NOTEXT
      go_report->set_hospot( EXPORTING io_column = gr_columns iv_fields = lv_fields ).

      TRY.
          gr_column ?= gr_columns->get_column( 'NETPR' ).
          IF gr_column IS BOUND.
            gr_column->set_currency_column( 'WAERS' ).
          ENDIF.
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
        CATCH cx_salv_data_error.                       "#EC NO_HANDLER
      ENDTRY.

      TRY.
          gr_column ?= gr_columns->get_column( 'NETWR' ).
          IF gr_column IS BOUND.
            gr_column->set_currency_column( 'WAERS' ).
          ENDIF.
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
        CATCH cx_salv_data_error.                       "#EC NO_HANDLER
      ENDTRY.

      TRY.
          gr_column ?= gr_columns->get_column( 'TO_CALC' ).
          IF gr_column IS BOUND.
            gr_column->set_currency_column( 'WAERS' ).
          ENDIF.
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
        CATCH cx_salv_data_error.                       "#EC NO_HANDLER
      ENDTRY.

      TRY.
          gr_column ?= gr_columns->get_column( 'TO_PORC' ).
          IF gr_column IS BOUND.
            gr_column->set_currency_column( 'WAERS' ).
          ENDIF.
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
        CATCH cx_salv_data_error.                       "#EC NO_HANDLER
      ENDTRY.

      TRY.
          gr_column ?= gr_columns->get_column( 'TO_PROV' ).
          IF gr_column IS BOUND.
            gr_column->set_currency_column( 'WAERS' ).
            gr_column->set_decimals( '0' ).
          ENDIF.
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
        CATCH cx_salv_data_error.                       "#EC NO_HANDLER
      ENDTRY.

      TRY.
          gr_column ?= gr_columns->get_column( 'TO_DELV' ).
          IF gr_column IS BOUND.
            gr_column->set_currency_column( 'WAERS' ).
          ENDIF.
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
        CATCH cx_salv_data_error.                       "#EC NO_HANDLER
      ENDTRY.

      TRY.
          gr_column ?= gr_columns->get_column( 'MENGE' ).
          IF gr_column IS BOUND.
            gr_column->set_quantity_column( 'MEINS' ).
          ENDIF.
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
        CATCH cx_salv_data_error.                       "#EC NO_HANDLER
      ENDTRY.

      TRY.
          gr_column ?= gr_columns->get_column( 'PEINH' ).
          IF gr_column IS BOUND.
            gr_column->set_quantity_column( 'MEINS' ).
          ENDIF.
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
        CATCH cx_salv_data_error.                       "#EC NO_HANDLER
      ENDTRY.

      TRY.
          gr_column ?= gr_columns->get_column( 'KTMNG' ).
          IF gr_column IS BOUND.
            gr_column->set_quantity_column( 'MEINS' ).
          ENDIF.
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
        CATCH cx_salv_data_error.                       "#EC NO_HANDLER
      ENDTRY.

      TRY.
          gr_sorts = mr_table->get_sorts( ).
          IF gr_sorts IS BOUND.
            gr_sorts->add_sort( columnname = 'LIFNR'
                                sequence   = if_salv_c_sort=>sort_up
                                subtotal   = if_salv_c_bool_sap=>true ).

            gr_sorts->add_sort( columnname = 'EBELN'
                                sequence   = if_salv_c_sort=>sort_up ).

            gr_sorts->add_sort( columnname = 'EBELP'
                                sequence   = if_salv_c_sort=>sort_up ).

*            gr_sorts->add_sort( columnname = 'KONTS'
*                                sequence   = if_salv_c_sort=>sort_up
*                                subtotal   = if_salv_c_bool_sap=>true ).

          ENDIF.
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
        CATCH cx_salv_existing.                         "#EC NO_HANDLER
        CATCH cx_salv_data_error.                       "#EC NO_HANDLER
      ENDTRY.

      gr_aggs = mr_table->get_aggregations( ).
* / Set aggregations
      CLEAR lv_fields.
* / Total = 1; Minimum = 2; Maximum = 3; Average = 4; No aggregation = 0;
      lv_fields = 'MENGE|1;NETPR|1;TO_CALC|1;LWSTE|1;TO_DELV|1;TO_PROV|1;NETWR|1;'.
      go_report->add_aggregation( EXPORTING io_agg = gr_aggs iv_fields = lv_fields ).
      CLEAR lv_fields.
      lv_fields = 'TO_CALC|Por Calcular;TO_DELV|Por Entregar;LWSTE|Por Calcular CLP;to_prov|Valor a Provisionar;'.
      go_report->modify_title( EXPORTING io_column = gr_columns iv_fields = lv_fields ).
      lv_fields = 'NETPR|Valor Neto Pos. Ped.'.
      go_report->modify_title( EXPORTING io_column = gr_columns iv_fields = lv_fields ).

      TRY.
          gr_column ?= gr_columns->get_column( 'BUKRS' ).
          IF gr_column IS BOUND.
            gr_column->set_key( if_salv_c_bool_sap=>true ).
          ENDIF.
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
      ENDTRY.

      TRY.
          gr_column ?= gr_columns->get_column( 'LIFNR' ).
          IF gr_column IS BOUND.
            gr_column->set_key( if_salv_c_bool_sap=>true ).
          ENDIF.
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
      ENDTRY.

      TRY.
          gr_column ?= gr_columns->get_column( 'EBELN' ).
          IF gr_column IS BOUND.
            gr_column->set_key( if_salv_c_bool_sap=>true ).
          ENDIF.
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
      ENDTRY.
    ENDIF.

    IF gr_columns IS BOUND.
      gr_columns->set_key_fixation( if_salv_c_bool_sap=>true ).
    ENDIF.

    IF mr_table IS NOT INITIAL.
      mr_table->display( ).
    ENDIF.

  ENDMETHOD.                    "built_alv

  METHOD get_data.

*    SELECT * FROM ekko INTO TABLE gt_ekko
*      WHERE .

*    IF gt_ekko[] IS NOT INITIAL.
*      SELECT * FROM ekpo INTO TABLE gt_ekpo
*        FOR ALL ENTRIES IN gt_ekko
*          WHERE ebeln = gt_ekko-ebeln.

*      IF gt_ekpo[] IS NOT INITIAL.

*        SELECT b~matnr a~bwkey a~bwmod b~bklas INTO TABLE gt_t001k FROM t001k AS a
*          INNER JOIN mbew AS b ON a~bwkey = b~bwkey
*          FOR ALL ENTRIES IN gt_ekpo
*            WHERE a~bwkey = gt_ekpo-werks
*              AND b~matnr = gt_ekpo-matnr.
*
*        SELECT matnr maktx FROM makt INTO TABLE gt_makt
*          FOR ALL ENTRIES IN gt_ekpo
*            WHERE matnr = gt_ekpo-matnr
*              AND spras = 'S'.
*
*        SELECT werks name1 FROM t001w INTO TABLE gt_t001w
*          FOR ALL ENTRIES IN gt_ekpo
*            WHERE werks = gt_ekpo-werks.

*      ENDIF.


*    ENDIF.

  ENDMETHOD.                    "get_data

  METHOD process_data.

    DATA: ls_detail TYPE ty_detail,
          ls_ekko  LIKE LINE OF gt_ekko,
          ls_ekpo  LIKE LINE OF gt_ekpo.
*          ls_makt  LIKE LINE OF gt_makt,
*          ls_t001w LIKE LINE OF gt_t001w,
*          ls_t001k LIKE LINE OF gt_t001k,
*          ls_t030  LIKE LINE OF gt_t030,
*          ls_oc    LIKE LINE OF gt_oc.

*    LOOP AT gt_ekko INTO ls_ekko.

*      MOVE-CORRESPONDING ls_ekko TO ls_detail.

*      LOOP AT gt_ekpo INTO ls_ekpo
*        WHERE ebeln = ls_ekko-ebeln.

*        MOVE-CORRESPONDING ls_ekpo TO ls_detail.
*
*        IF ls_ekpo-matnr IS INITIAL.
*          ls_detail-maktx = ls_ekpo-txz01.
*        ELSE.
*          READ TABLE gt_makt INTO ls_makt WITH KEY matnr = ls_ekpo-matnr.
*          ls_detail-maktx = ls_makt-maktx.
*        ENDIF.
*
*        READ TABLE gt_t001w INTO ls_t001w WITH KEY werks = ls_ekpo-werks.
*        ls_detail-name1 = ls_t001w-name1.
*
*        READ TABLE gt_t001k INTO ls_t001k WITH KEY matnr = ls_ekpo-matnr
*                                                   bwkey = ls_ekpo-werks.
*        IF sy-subrc EQ 0.
*          READ TABLE gt_t030 INTO ls_t030 WITH KEY bwmod = ls_t001k-bwmod
*                                                   bklas = ls_t001k-bklas.
*          ls_detail-konts = ls_t030-konts.
*        ENDIF.
*
*        APPEND ls_detail TO ev_detail.
*        CLEAR: ls_makt, ls_t001w, ls_t030, ls_t001k.
*      ENDLOOP.
*      ls_oc-ebeln = ls_ekko-ebeln.
*      APPEND ls_oc TO gt_oc.
*    ENDLOOP.
  ENDMETHOD.                    "process_data

ENDCLASS.                    "l
