*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <27-12-2019> *
*& Transport Number: < ECDK917018 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZMMR_PO_RELEASE_CI1
*&---------------------------------------------------------------------*
CLASS lcl_event_alv IMPLEMENTATION.

  METHOD user_command.
    PERFORM release_po USING e_salv_function.
  ENDMETHOD.                    "user_command

  METHOD call_transaction.
* / CALL OC
    IF column EQ 'EBELN'.
*      PERFORM check_tcode USING 'ME23N'.
*      IF sy-subrc EQ 0.
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

      CREATE OBJECT go_event.
      gr_events = mr_table->get_event( ).

      SET HANDLER: go_event->user_command FOR gr_events,
                   go_event->call_transaction FOR gr_events.

      gr_functions = mr_table->get_functions( ).
      gr_functions->set_all( abap_true ).
      gr_columns = mr_table->get_columns( ).

* / Set fields as a hospot
      CLEAR lv_fields.
      lv_fields = 'EBELN;'.                                 "#EC NOTEXT
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
          gr_sorts = mr_table->get_sorts( ).
          IF gr_sorts IS BOUND.
            gr_sorts->add_sort( columnname = 'EBELN'
                                sequence   = if_salv_c_sort=>sort_up ).

            gr_sorts->add_sort( columnname = 'EBELP'
                                sequence   = if_salv_c_sort=>sort_up ).

            gr_sorts->add_sort( columnname = 'KONTS'
                                sequence   = if_salv_c_sort=>sort_up
                                subtotal   = if_salv_c_bool_sap=>true ).

          ENDIF.
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
        CATCH cx_salv_existing.                         "#EC NO_HANDLER
        CATCH cx_salv_data_error.                       "#EC NO_HANDLER
      ENDTRY.

      gr_aggs = mr_table->get_aggregations( ).
* / Set aggregations
      CLEAR lv_fields.
* / Total = 1; Minimum = 2; Maximum = 3; Average = 4; No aggregation = 0;
      lv_fields = 'MENGE|1;NETPR|1;NETWR|1;KONTS|4'.
      go_report->add_aggregation( EXPORTING io_agg = gr_aggs iv_fields = lv_fields ).

    ENDIF.

    IF mr_table IS NOT INITIAL.
      mr_table->display( ).
    ENDIF.

  ENDMETHOD.                    "built_alv

  METHOD get_data.
    DATA: lv_frgzu TYPE ekko-frgzu.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t16fv INTO gs_t16fv
*      WHERE frggr IN so_frggr
*        AND frgsx EQ gc_frgsx
*        AND frgco EQ pa_frgco.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t16fv INTO gs_t16fv
      WHERE frggr IN so_frggr
        AND frgsx EQ gc_frgsx
        AND frgco EQ pa_frgco ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

    IF gs_t16fv-frga1 = 'X'.
      lv_frgzu = ''.
    ELSEIF gs_t16fv-frga2 = 'X'.
      lv_frgzu = 'X'.
    ELSEIF gs_t16fv-frga3 = 'X'.
      lv_frgzu = 'XX'.
    ELSEIF gs_t16fv-frga4 = 'X'.
      lv_frgzu = 'XXX'.
    ELSEIF gs_t16fv-frga5 = 'X'.
      lv_frgzu = 'XXXX'.
    ELSEIF gs_t16fv-frga6 = 'X'.
      lv_frgzu = 'XXXXX'.
    ELSEIF gs_t16fv-frga7 = 'X'.
      lv_frgzu = 'XXXXXX'.
    ELSEIF gs_t16fv-frga8 = 'X'.
      lv_frgzu = 'XXXXXXX'.
    ENDIF.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM ekko INTO TABLE gt_ekko
*      WHERE frgsx = gs_t16fv-frgsx
*        AND frgke = '1'
*        AND frgzu = lv_frgzu.
*
* NEW CODE
    SELECT *
 FROM ekko INTO TABLE gt_ekko
      WHERE frgsx = gs_t16fv-frgsx
        AND frgke = '1'
        AND frgzu = lv_frgzu ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

    IF gt_ekko[] IS NOT INITIAL.
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * FROM ekpo INTO TABLE gt_ekpo
*        FOR ALL ENTRIES IN gt_ekko
*          WHERE ebeln = gt_ekko-ebeln.
*
* NEW CODE
      SELECT *
 FROM ekpo INTO TABLE gt_ekpo
        FOR ALL ENTRIES IN gt_ekko
          WHERE ebeln = gt_ekko-ebeln ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

      IF gt_ekpo[] IS NOT INITIAL.

        SELECT b~matnr a~bwkey a~bwmod b~bklas INTO TABLE gt_t001k FROM t001k AS a
          INNER JOIN mbew AS b ON a~bwkey = b~bwkey
          FOR ALL ENTRIES IN gt_ekpo
            WHERE a~bwkey = gt_ekpo-werks
              AND b~matnr = gt_ekpo-matnr.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT matnr maktx FROM makt INTO TABLE gt_makt
*          FOR ALL ENTRIES IN gt_ekpo
*            WHERE matnr = gt_ekpo-matnr
*              AND spras = 'S'.
*
* NEW CODE
        SELECT matnr maktx
 FROM makt INTO TABLE gt_makt
          FOR ALL ENTRIES IN gt_ekpo
            WHERE matnr = gt_ekpo-matnr
              AND spras = 'S' ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT werks name1 FROM t001w INTO TABLE gt_t001w
*          FOR ALL ENTRIES IN gt_ekpo
*            WHERE werks = gt_ekpo-werks.
*
* NEW CODE
        SELECT werks name1
 FROM t001w INTO TABLE gt_t001w
          FOR ALL ENTRIES IN gt_ekpo
            WHERE werks = gt_ekpo-werks ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

      ENDIF.

      SELECT * INTO TABLE gt_t030 FROM t030
        FOR ALL ENTRIES IN gt_t001k
      WHERE ktopl = 'B100'
        AND ktosl = 'GBB'
        AND bwmod = gt_t001k-bwmod
        AND komok = 'VBR'
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK917018*
*        AND bklas = gt_t001k-bklas.
        AND bklas = gt_t001k-bklas ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK917018*
    ENDIF.

  ENDMETHOD.                    "get_data

  METHOD process_data.

    DATA: ls_detail TYPE ty_detail,
          ls_ekko  LIKE LINE OF gt_ekko,
          ls_ekpo  LIKE LINE OF gt_ekpo,
          ls_makt  LIKE LINE OF gt_makt,
          ls_t001w LIKE LINE OF gt_t001w,
          ls_t001k LIKE LINE OF gt_t001k,
          ls_t030  LIKE LINE OF gt_t030,
          ls_oc    LIKE LINE OF gt_oc.

    LOOP AT gt_ekko INTO ls_ekko.
      MOVE-CORRESPONDING ls_ekko TO ls_detail.

      LOOP AT gt_ekpo INTO ls_ekpo
        WHERE ebeln = ls_ekko-ebeln.

        MOVE-CORRESPONDING ls_ekpo TO ls_detail.

        IF ls_ekpo-matnr IS INITIAL.
          ls_detail-maktx = ls_ekpo-txz01.
        ELSE.
          READ TABLE gt_makt INTO ls_makt WITH KEY matnr = ls_ekpo-matnr.
          ls_detail-maktx = ls_makt-maktx.
        ENDIF.

        READ TABLE gt_t001w INTO ls_t001w WITH KEY werks = ls_ekpo-werks.
        ls_detail-name1 = ls_t001w-name1.

        READ TABLE gt_t001k INTO ls_t001k WITH KEY matnr = ls_ekpo-matnr
                                                   bwkey = ls_ekpo-werks.
        IF sy-subrc EQ 0.
          READ TABLE gt_t030 INTO ls_t030 WITH KEY bwmod = ls_t001k-bwmod
                                                   bklas = ls_t001k-bklas.
          ls_detail-konts = ls_t030-konts.
        ENDIF.

        APPEND ls_detail TO ev_detail.
        CLEAR: ls_makt, ls_t001w, ls_t030, ls_t001k.
      ENDLOOP.
      ls_oc-ebeln = ls_ekko-ebeln.
      APPEND ls_oc TO gt_oc.
    ENDLOOP.
  ENDMETHOD.                    "process_data

  METHOD bapi_release.
    DATA: ls_oc LIKE LINE OF gt_oc.

    DATA: lv_commit TYPE bapimmpara-selection.

    LOOP AT gt_oc INTO ls_oc.

    ENDLOOP.

    CALL FUNCTION 'BAPI_PO_RELEASE'
      EXPORTING
        purchaseorder                = ls_oc-ebeln
        po_rel_code                  = pa_frgco
*   USE_EXCEPTIONS               = 'X'
        no_commit                    = lv_commit
* IMPORTING
*   REL_STATUS_NEW               =
*   REL_INDICATOR_NEW            =
*   RET_CODE                     =
     TABLES
       return                       = gt_return
     EXCEPTIONS
       authority_check_fail         = 1
       document_not_found           = 2
       enqueue_fail                 = 3
       prerequisite_fail            = 4
       release_already_posted       = 5
       responsibility_fail          = 6
       OTHERS                       = 7
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDMETHOD.                    "bapi_release

ENDCLASS.                    "lcl_report IMPLEMENTATION
