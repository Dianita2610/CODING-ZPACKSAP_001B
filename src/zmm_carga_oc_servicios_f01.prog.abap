
*&---------------------------------------------------------------------*
*&      Form  CARGAR_ARCHIVO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
CLASS lcl_report IMPLEMENTATION.
  METHOD cargar_archivo.

    DATA: lv_filename TYPE string.
    DATA: lt_aux       TYPE truxs_t_text_data.

    lv_filename = p_file.
    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename                = lv_filename
        filetype                = 'DAT'
      CHANGING
        data_tab                = lt_aux
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        not_supported_by_gui    = 17
        error_no_gui            = 18
        OTHERS                  = 19.

    DELETE lt_aux INDEX 1. "Borramos la fila de los titulos cabecera
    CALL FUNCTION 'TEXT_CONVERT_CSV_TO_SAP'
      EXPORTING
        i_field_seperator    = ';'
        i_tab_raw_data       = lt_aux
      TABLES
        i_tab_converted_data = ti_file.

    me->formatear_csv( ).

  ENDMETHOD.
  METHOD formatear_csv .
    DATA: vl_monto TYPE bapicurr-bapicurr.
    LOOP AT ti_file INTO wa_file.
      CLEAR: wa_data, wa_pos, vl_monto.
      MOVE-CORRESPONDING wa_file TO wa_data.
      CLEAR: wa_data-aedat, wa_data-eindt.
      REPLACE ALL OCCURRENCES OF: '.' IN wa_file-aedat WITH space,
                                  '.' IN wa_file-eindt WITH space.

      REPLACE ALL OCCURRENCES OF: '-' IN wa_file-aedat WITH space,
                                  '-' IN wa_file-eindt WITH space.
      CONDENSE: wa_file-aedat, wa_file-eindt.
      CONCATENATE wa_file-aedat+4(4) wa_file-aedat+2(2) wa_file-aedat(2)
      INTO wa_data-aedat.

      CONCATENATE wa_file-eindt+4(4) wa_file-eindt+2(2) wa_file-eindt(2)
      INTO wa_data-eindt.
*      CONCATENATE wa_file-bukrs wa_file-bsart wa_file-lifnr wa_file-aedat
*      INTO wa_data-llave SEPARATED BY '-'.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_file-srvpos
        IMPORTING
          output = wa_data-srvpos.

      REPLACE ALL OCCURRENCES OF '.' IN wa_file-precio WITH ' '.
      CONDENSE wa_file-precio.

      REPLACE ALL OCCURRENCES OF ',' IN wa_file-precio WITH '.'.
      CONDENSE wa_file-precio.

      vl_monto = wa_file-precio.
      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
        EXPORTING
          currency             = wa_file-waers
          amount_external      = vl_monto
          max_number_of_digits = 20
        IMPORTING
          amount_internal      = vl_monto.

      wa_data-brtwr = vl_monto.
      APPEND wa_data TO ti_data.
      MOVE-CORRESPONDING wa_data TO wa_pos.
      APPEND wa_pos TO ti_pos.
    ENDLOOP.
    ti_aux[] = ti_data[].
    DELETE ADJACENT DUPLICATES FROM ti_data COMPARING llave.
    SORT ti_pos BY llave ebelp.
  ENDMETHOD.                  " FORMATEAR_XLS

  METHOD procesar_archivo .
    DATA : wa_cab          TYPE ty_data,
           wa_pos_aux      TYPE ty_pos,
           ls_poheader     TYPE  bapimepoheader,
           ls_poheaderx    TYPE  bapimepoheaderx,
           lt_potextheader TYPE STANDARD TABLE OF bapimepotextheader,
           ls_potextheader TYPE bapimepotextheader,
           lt_poitem       TYPE STANDARD TABLE OF bapimepoitem,
           ls_poitem       TYPE bapimepoitem,
           lt_poitemx      TYPE STANDARD TABLE OF bapimepoitemx,
           ls_poitemx      TYPE bapimepoitemx,
           lt_poschedule   TYPE STANDARD TABLE OF bapimeposchedule,
           ls_poschedule   TYPE bapimeposchedule,
           lt_poschedulex	 TYPE STANDARD TABLE OF bapimeposchedulx,
           ls_poschedulex  TYPE bapimeposchedulx,
           lt_pocond       TYPE STANDARD TABLE OF bapimepocond,
           ls_pocond       TYPE bapimepocond,
           lt_pocondx      TYPE STANDARD TABLE OF bapimepocondx,
           ls_pocondx      TYPE bapimepocondx,
           lt_servicios    TYPE TABLE OF bapiesllc,
           ls_servicios    TYPE bapiesllc,
           lt_posvalues    TYPE STANDARD TABLE OF bapiesklc,
           ls_posvalues    TYPE bapiesklc,
           lt_cuentas      TYPE STANDARD TABLE OF bapimepoaccount, " asignacion de cuentas y ceo a items
           ls_cuentas      TYPE bapimepoaccount,
           lt_cuentasx     TYPE STANDARD TABLE OF bapimepoaccountx,
           ls_cuentasx     TYPE bapimepoaccountx,
           lt_return       TYPE STANDARD TABLE OF bapiret2,
           ls_return       TYPE bapiret2.

    DATA: vl_pckg_no          TYPE packno,
          vl_line_no          TYPE packno,
          vl_ext_line         TYPE packno,
          vl_sub_pckg         TYPE packno,
          vl_leng             TYPE i,
          vl_monto            TYPE bapicurx-bapicurx,
          lv_exppurchaseorder TYPE bapimepoheader-po_number.

    SELECT kschl, krech
      INTO TABLE @DATA(ti_t685)
      FROM t685a
      FOR ALL ENTRIES IN @ti_data
      WHERE kschl = @ti_data-kschl.
    SORT ti_t685 BY kschl.

    SELECT asnum , meins
      INTO TABLE @DATA(ti_serv)
      FROM asmd
      FOR ALL ENTRIES IN @ti_data
      WHERE asnum = @ti_data-srvpos.
    SORT ti_serv BY asnum.

    LOOP AT ti_data INTO wa_data.
      CLEAR : wa_cab,  vl_line_no.
      MOVE-CORRESPONDING wa_data TO wa_cab.
      CLEAR: ls_poheader, ls_poheaderx, ls_potextheader, vl_pckg_no.
      REFRESH: lt_poschedule, lt_poschedulex, lt_pocond, lt_pocondx,
               lt_cuentas, lt_cuentasx, lt_servicios, lt_posvalues,
               lt_poitem, lt_poitemx.

      REFRESH lt_potextheader.
      ls_poheader-comp_code  = wa_cab-bukrs. "Sociedad
      ls_poheader-doc_type   = wa_cab-bsart. "Clase pedido
      ls_poheader-doc_date = wa_cab-aedat. "Fecha documento

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_cab-lifnr
        IMPORTING
          output = ls_poheader-vendor. "Proveedor

      ls_poheader-pmnttrms   = wa_cab-zterm. "Condición pago
      ls_poheader-purch_org  = wa_cab-ekorg. "Org.compra
      ls_poheader-pur_group  = wa_cab-ekgrp. "Grp.compra
      ls_poheader-currency   = wa_cab-waers. "Moneda
      ls_poheader-currency_iso   = wa_cab-waers.

      CLEAR ls_poheaderx.
      ls_poheaderx-comp_code     = c_x.
      ls_poheaderx-doc_type      = c_x.
      ls_poheaderx-doc_date    = c_x.
      ls_poheaderx-vendor        = c_x.
      ls_poheaderx-pmnttrms      = c_x.
      ls_poheaderx-purch_org     = c_x.
      ls_poheaderx-pur_group     = c_x.
      ls_poheaderx-currency      = c_x.
      ls_poheaderx-currency_iso  = c_x.

***Texto cabecera
      CLEAR ls_potextheader.
      ls_potextheader-text_id  = 'F01'.
      ls_potextheader-text_form = '*'.

      vl_leng = strlen( wa_cab-texto ).
      IF vl_leng > 132.
        IF wa_cab-texto+132(1) = space. "Texto cabecera
          ls_potextheader-text_line = wa_cab-texto. "Texto cabecera
          APPEND ls_potextheader TO lt_potextheader.

          CLEAR ls_potextheader-text_form.
          ls_potextheader-text_line = wa_cab-texto+132. "Texto cabecera
          CONDENSE  ls_potextheader-text_line.
          APPEND ls_potextheader TO lt_potextheader.
        ELSE.
          DO.
            vl_leng = 132 - sy-index.
            IF wa_cab-texto+vl_leng(1) = space.
              ls_potextheader-text_line = wa_cab-texto(vl_leng). "Texto cabecera
              APPEND ls_potextheader TO lt_potextheader.

              CLEAR ls_potextheader-text_form.
              ls_potextheader-text_line = wa_cab-texto+vl_leng. "Texto cabecera
              CONDENSE  ls_potextheader-text_line.
              APPEND ls_potextheader TO lt_potextheader.
              EXIT.
            ENDIF.
          ENDDO.
        ENDIF.
      ELSE.
        ls_potextheader-text_line = wa_cab-texto. "Texto cabecera
        APPEND ls_potextheader TO lt_potextheader.
      ENDIF.

      vl_pckg_no = 1.

      LOOP AT ti_pos INTO wa_pos WHERE llave = wa_data-llave.
        MOVE-CORRESPONDING wa_pos TO wa_pos_aux.
        AT NEW ebelp.
          CLEAR : ls_poitem,
                  ls_poitemx,
                  ls_poschedule,
                  ls_poschedulex,
                  ls_servicios,
                  ls_pocond,
                  ls_pocondx,
                  vl_ext_line.

          ls_poitem-po_item      = wa_pos_aux-ebelp. "Posición
          ls_poitem-short_text   = wa_pos_aux-txz01. "Texto breve
          ls_poitem-plant        = wa_pos_aux-werks. "Centro
          ls_poitem-quantity     = wa_pos_aux-menge. "cantidad
          ls_poitem-tax_code     = wa_pos_aux-mwskz. "Ind.IVA
          ls_poitem-item_cat     = wa_pos_aux-pstyp. "Tipo posición
          ls_poitem-po_unit      = c_up. "Unidad medida
          ls_poitem-matl_group   = wa_pos_aux-matkl. "Grp.articulo
          ls_poitem-acctasscat   = wa_pos_aux-knttp. "Tipo imputación
          ls_poitem-preq_name    = wa_pos_aux-afnam. "Solicitante
          ls_poitem-distrib      = '2'. "Distribución porcentual
          ls_poitem-ir_ind       = c_x. "Recepción de factura
          ls_poitem-gr_basediv   = c_x. "Ver.Factura basada en EM
          ls_poitem-pckg_no      = vl_pckg_no. "Paquete padre
          APPEND ls_poitem TO lt_poitem.

          ls_poitemx-po_item     = ls_poitem-po_item.
          ls_poitemx-short_text   = c_x.
          ls_poitemx-plant       = c_x.
          ls_poitemx-quantity    = c_x.
          ls_poitemx-po_unit     = c_x.
          ls_poitemx-tax_code    = c_x.
          ls_poitemx-matl_group   = c_x.
          ls_poitemx-item_cat    = c_x.
          ls_poitemx-acctasscat  = c_x.
          ls_poitemx-preq_name   = c_x.
          ls_poitemx-pckg_no     = c_x.
          ls_poitemx-distrib     = c_x.
          ls_poitemx-ir_ind      = c_x.
          ls_poitemx-gr_basediv  = c_x.
          APPEND ls_poitemx TO lt_poitemx.

          ls_poschedule-po_item        = ls_poitem-po_item.
          ls_poschedule-delivery_date  = wa_pos_aux-eindt. "Fecha entrega
          APPEND ls_poschedule TO lt_poschedule.

          ls_poschedulex-po_item       = ls_poitem-po_item.
          ls_poschedulex-delivery_date = 'X'.
          APPEND ls_poschedulex TO lt_poschedulex.

          CLEAR ls_pocond.
          ls_pocond-itm_number = ls_poitem-po_item.
          ls_pocond-cond_type  = wa_pos_aux-kschl. "ZIVA
          READ TABLE ti_t685 INTO DATA(wa_t685) WITH KEY kschl = wa_pos_aux-kschl
          BINARY SEARCH.
          IF wa_t685-krech = 'A' AND wa_cab-waers = c_clp. "Porcentual.
            ls_pocond-cond_value = wa_pos_aux-kbetr * 1000.
          ELSEIF wa_t685-krech = 'A' AND wa_cab-waers <> c_clp.
            ls_pocond-cond_value = wa_pos_aux-kbetr * 10.
          ELSE.
            ls_pocond-cond_value = wa_pos_aux-kbetr.
          ENDIF.

          ls_pocond-currency   = wa_cab-waers. "Moneda
          ls_pocond-change_id  = 'I'.
          APPEND ls_pocond TO lt_pocond.

          CLEAR ls_pocondx.
          ls_pocondx-itm_number = ls_poitem-po_item.
          ls_pocondx-cond_type = 'X'.
          ls_pocondx-cond_value = 'X'.
          ls_pocondx-currency = 'X'.
          ls_pocondx-change_id = 'X'.
          APPEND ls_pocondx TO lt_pocondx.

*****Servicio
          ls_servicios-pckg_no     = vl_pckg_no.
          ls_servicios-line_no     = vl_pckg_no.
          ls_servicios-outl_ind    = abap_true.
          ADD 1 TO vl_pckg_no.
          ls_servicios-subpckg_no  = vl_pckg_no.
          vl_sub_pckg = ls_servicios-subpckg_no.
          APPEND ls_servicios TO lt_servicios.
        ENDAT.

        vl_line_no              = vl_line_no + 1.
        vl_ext_line             = vl_ext_line + 10.
        ls_servicios-pckg_no    = vl_pckg_no.
        ls_servicios-line_no    = vl_line_no.
        ls_servicios-ext_line   = vl_ext_line.
        ls_servicios-outl_ind   = space.
        ls_servicios-subpckg_no = space.
        ls_servicios-service    = wa_pos_aux-srvpos. "Servicio
        ls_servicios-quantity   = wa_pos_aux-menge_srv. "Cantidad
        READ TABLE ti_serv INTO DATA(wa_serv) WITH KEY asnum = wa_pos_aux-srvpos
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          ls_servicios-base_uom   = wa_serv-meins. "Unidad de medida del servicio
        ENDIF.

        CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERN_9'
          EXPORTING
            currency        = wa_cab-waers
            amount_internal = wa_pos_aux-brtwr
          IMPORTING
            amount_external = vl_monto.

        ls_servicios-gr_price = vl_monto. "Precio bruto

*->Distribucion de inputaciones
        ls_posvalues-pckg_no    = ls_servicios-pckg_no.
        ls_posvalues-line_no    = ls_servicios-line_no.
        ls_posvalues-serial_no  = vl_line_no.
        ls_posvalues-serno_line = '01'.
        ls_posvalues-quantity   = wa_pos_aux-menge_srv.

*-> inputacion de cuentas
        ls_cuentas-po_item      = ls_poitem-po_item. " linea pedido
        ls_cuentas-serial_no    = vl_line_no.
        ls_cuentas-gl_account   = wa_pos_aux-sakto. " cuenta de mayor
        ls_cuentas-costcenter   = wa_pos_aux-kostl.  " centro de costo
        ls_cuentas-net_value    = ls_servicios-gr_price. "Valor neto,
        ls_cuentas-quantity     = wa_pos_aux-menge_srv."Cantidad

        ls_cuentasx-po_item     = ls_poitem-po_item. " linea pedido
        ls_cuentasx-serial_no   = vl_line_no.
        ls_cuentasx-serial_nox  = c_x.
        ls_cuentasx-net_value   = c_x.
        ls_cuentasx-quantity    = c_x.
        ls_cuentasx-gl_account  = c_x. " cuenta de mayor
        ls_cuentasx-costcenter  = c_x.  " centro de costo

        APPEND: ls_servicios TO lt_servicios,
                ls_posvalues TO lt_posvalues,
                ls_cuentas   TO lt_cuentas,
                ls_cuentasx  TO lt_cuentasx.

        AT END OF ebelp.
          vl_pckg_no = vl_pckg_no + 1.
          CLEAR vl_line_no.
        ENDAT.
      ENDLOOP.

      AT END OF llave.
        CALL FUNCTION 'BAPI_PO_CREATE1' "#EC CI_USAGE_OK[2438131]
          EXPORTING
            poheader          = ls_poheader
            poheaderx         = ls_poheaderx
          IMPORTING
            exppurchaseorder  = lv_exppurchaseorder
          TABLES
            return            = lt_return
            poitem            = lt_poitem
            poitemx           = lt_poitemx
            poschedule        = lt_poschedule
            poschedulex       = lt_poschedulex
            poaccount         = lt_cuentas
            poaccountx        = lt_cuentasx
            pocond            = lt_pocond
            pocondx           = lt_pocondx
            poservices        = lt_servicios
            posrvaccessvalues = lt_posvalues
            potextheader      = lt_potextheader.

        IF NOT lv_exppurchaseorder IS INITIAL.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.

          wa_data-ebeln = lv_exppurchaseorder.
          MODIFY ti_data FROM wa_data TRANSPORTING ebeln WHERE llave = wa_data-llave.
        ELSE.
          DELETE lt_return WHERE id = 'BAPI'  AND number = '001'.
          DELETE lt_return WHERE id = 'MEPO'  AND number = '002'.
          SORT lt_return BY id number message_v1 message_v2 message_v3 message_v4.
          DELETE ADJACENT DUPLICATES FROM lt_return
          COMPARING id number message_v1 message_v2 message_v3 message_v4.
          CLEAR wa_data-message.
          LOOP AT lt_return INTO ls_return WHERE type = 'E'.
            IF wa_data-message IS INITIAL.
              wa_data-message = ls_return-message.
            ELSE.
              CONCATENATE wa_data-message ls_return-message
              INTO wa_data-message SEPARATED BY '/'.
            ENDIF.
          ENDLOOP.

          MODIFY ti_data FROM wa_data TRANSPORTING message WHERE llave = wa_data-llave.

        ENDIF.
      ENDAT.
    ENDLOOP.

    LOOP AT ti_aux ASSIGNING FIELD-SYMBOL(<fs>).
      READ TABLE ti_data INTO wa_data WITH KEY llave = <fs>-llave.
*      BINARY SEARCH.
      IF sy-subrc EQ 0.
        <fs>-ebeln = wa_data-ebeln.
        <fs>-message = wa_data-message.
      ENDIF.
    ENDLOOP.

    ti_data[] = ti_aux[].
  ENDMETHOD.

  METHOD generate_out.
    DATA: lx_msg   TYPE REF TO cx_salv_msg.
    IF ti_data[] IS INITIAL.
      MESSAGE i398(00) WITH TEXT-s01 space space space.
      EXIT.
    ELSE.
      TRY.
          cl_salv_table=>factory(
            IMPORTING
              r_salv_table = o_alv_r
            CHANGING
              t_table      = ti_data  ).
        CATCH cx_salv_msg INTO lx_msg.
      ENDTRY.
    ENDIF.

    CALL METHOD set_pf_status
      CHANGING
        co_alv = o_alv_r.

    CALL METHOD me->set_columns
      CHANGING
        co_alv = o_alv_r.

    CALL METHOD set_display_setting
      CHANGING
        co_alv = o_alv_r.

    o_alv_r->display( ).
  ENDMETHOD.                    "GET_dATA

  METHOD on_link_click.
    FIELD-SYMBOLS: <fs_data>          TYPE ty_data.

    READ TABLE ti_data INTO wa_data INDEX row.
    IF column = 'EBELN' AND NOT wa_data-ebeln IS INITIAL.
      SET PARAMETER ID 'BES' FIELD wa_data-ebeln.
      CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
    ENDIF.
    o_alv_r->refresh( ).

  ENDMETHOD.

  METHOD set_pf_status.
*
    DATA: lo_functions TYPE REF TO cl_salv_functions_list.
    DATA: lt_func_list TYPE salv_t_ui_func,
          la_func_list LIKE LINE OF lt_func_list.

    co_alv->set_screen_status(
      pfstatus      =  'ZSTD_ALV'
      report        =  'ZMM_CARGA_OC_SERVICIOS'
      set_functions = co_alv->c_functions_all ).

  ENDMETHOD.                    "set_pf_status

  METHOD set_columns.
    DATA : lo_layout TYPE REF TO cl_salv_layout,
           ls_key    TYPE salv_s_layout_key.
    DATA : lr_columns TYPE REF TO cl_salv_columns_table. "columns instance
    DATA : lr_column TYPE REF TO cl_salv_column_table. "column instance


    DATA:
      lv_text_l TYPE scrtext_l,
      lv_text_m TYPE scrtext_m,
      lv_text_s TYPE scrtext_s.

    lr_columns = co_alv->get_columns( ).
    lr_columns->set_optimize( c_x ).

    lo_layout = co_alv->get_layout( ).
    lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
    ls_key-report = sy-repid.
    lo_layout->set_key( ls_key ).

    TRY.
        lr_column ?= lr_columns->get_column( 'LLAVE' ).
        lr_column->set_visible( space ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        lr_column ?= lr_columns->get_column( 'EBELN' ).
        lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
        lr_column->set_zero( if_salv_c_bool_sap=>false ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        lr_column ?= lr_columns->get_column( 'BRTWR' ).
        lr_column->set_currency_column( 'WAERS' ).
        lr_column->set_zero( if_salv_c_bool_sap=>false ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        lr_column ?= lr_columns->get_column( 'TEXTO' ).
        lr_column->set_long_text( 'Texto cabecera' ).
        lr_column->set_medium_text( 'Texto cabecera' ).
        lr_column->set_short_text( 'Texto cab.' ).
        lr_column->set_zero( if_salv_c_bool_sap=>false ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.
*...Events
    DATA: lo_events     TYPE REF TO cl_salv_events_table.
*   All events
    lo_events = co_alv->get_event( ).

*   Event handler
    SET HANDLER me->on_link_click FOR lo_events.
*    SET HANDLER on_user_command FOR lo_events.
  ENDMETHOD.

  METHOD set_display_setting.
    DATA: lo_display TYPE REF TO cl_salv_display_settings.
    lo_display = co_alv->get_display_settings( ).
    lo_display->set_striped_pattern( c_x ).
    lo_display->set_list_header( sy-title ).
  ENDMETHOD.                    "SET_DISPLAY_SETTING

ENDCLASS.

*&---------------------------------------------------------------------*
*&  Include           ZMM_CARGA_OC_SERVICIOS_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  OPEN_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM open_file .
  DATA: retfiletable TYPE filetable,
        filename     TYPE filetable.
  DATA retrc TYPE sysubrc.
  DATA retuseraction TYPE i.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      multiselection    = abap_false
      file_filter       = '*.csv'
      default_extension = 'csv'
    CHANGING
      file_table        = retfiletable
      rc                = retrc
      user_action       = retuseraction.
  IF sy-subrc EQ 0.
    READ TABLE retfiletable INTO p_file INDEX 1.
  ENDIF.
ENDFORM.
