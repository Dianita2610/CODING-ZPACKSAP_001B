class ZCL_IM__SCREEN_EXIT_MIGO definition
  public
  final
  create public .

*"* public components of class ZCL_IM__SCREEN_EXIT_MIGO
*"* do not include other source files here!!!
public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_MB_MIGO_BADI .
protected section.
*"* protected components of class ZCL_IM__SCREEN_EXIT_MIGO
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM__SCREEN_EXIT_MIGO
*"* do not include other source files here!!!

  data GT_EXTDATA type TY_T_EXTDATA .
  constants GF_CLASS_ID type MIGO_CLASS_ID value 'MIGO_BADI_IMPLEMENTATION1'. "#EC NOTEXT
  data G_NO_INPUT type XFELD .
  data GS_EXDATA_HEADER type MIGO_BADI_EXAMPLE_SCREEN_HEAD .
  data G_CANCEL type XFELD .
  data G_LINE_ID type GOITEM-GLOBAL_COUNTER .
ENDCLASS.



CLASS ZCL_IM__SCREEN_EXIT_MIGO IMPLEMENTATION.


method IF_EX_MB_MIGO_BADI~CHECK_HEADER.
endmethod.


method IF_EX_MB_MIGO_BADI~CHECK_ITEM.
endmethod.


method IF_EX_MB_MIGO_BADI~HOLD_DATA_DELETE.
* Delete entry from database table
  DELETE FROM migo_badi_hold WHERE guid = i_guid.
endmethod.


method IF_EX_MB_MIGO_BADI~HOLD_DATA_LOAD.
  DATA: ls_migo_badi_hold TYPE migo_badi_hold.
* Select hold data from database
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM migo_badi_hold INTO ls_migo_badi_hold
*  WHERE guid = i_guid.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM migo_badi_hold INTO ls_migo_badi_hold
  WHERE guid = i_guid ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
* Get internal structure gs_exdata_header from data buffer
  IMPORT gs_exdata_header TO gs_exdata_header FROM DATA BUFFER
        ls_migo_badi_hold-hold_string_head.
* Get internal table gt_extdata from data buffer
  IMPORT gt_extdata TO gt_extdata FROM DATA BUFFER
        ls_migo_badi_hold-hold_string.
endmethod.


method IF_EX_MB_MIGO_BADI~HOLD_DATA_SAVE.

  DATA: ls_migo_badi_hold TYPE migo_badi_hold.

* Store data cluster (detail data) to data buffer
  EXPORT gt_extdata FROM gt_extdata TO DATA BUFFER
        ls_migo_badi_hold-hold_string.
* Store data cluster (header data) to data buffer
  EXPORT gs_exdata_header FROM gs_exdata_header TO DATA BUFFER
        ls_migo_badi_hold-hold_string_head.
  ls_migo_badi_hold-guid = i_guid.
* Database update:
  INSERT INTO migo_badi_hold VALUES ls_migo_badi_hold.
  IF sy-subrc <> 0.
    MESSAGE a398(00) WITH 'Error update MIGO_BADI_HOLD'(005).
  ENDIF.
endmethod.


method IF_EX_MB_MIGO_BADI~INIT.

   APPEND gf_class_id TO ct_init.
endmethod.


method IF_EX_MB_MIGO_BADI~LINE_DELETE.
endmethod.


METHOD if_ex_mb_migo_badi~line_modify.

  DATA:zzunid_pro TYPE goitem-zzunid_pro.

  DATA: l_erfmg TYPE erfmg.

  CALL FUNCTION 'ZZMIGO_CUST_DYNP_DETAIL'
  EXPORTING
    i_line_id = i_line_id.
*    i_aufnr     = cs_goitem-pps_aufnr
*  IMPORTING
*    zunid_pro   = zzunid_pro.
*  IF zzunid_pro NE space.
*    cs_goitem-zzunid_pro = zzunid_pro.
*  ENDIF.
**
***--------------------------------------------------------------------*
**  DATA: ls_extdata_old      TYPE migo_badi_example_screen_field,
**        ls_extdata_new      TYPE migo_badi_example_screen_field,
**        ls_migo_badi_exampl TYPE migo_badi_exampl,
**        l_subrc             TYPE sy-subrc.
**
*** Get external data from internal table:
**  READ TABLE gt_extdata INTO ls_extdata_old
**  WITH TABLE KEY line_id = i_line_id.
**  l_subrc = sy-subrc.
**
*** Update data in internal table:
**  IF l_subrc <> 0.
***   Line is new: If GOITEM has a reference to a material document,
***                the already existing external data can be read.
**    IF NOT cs_goitem-mblnr IS INITIAL AND NOT cs_goitem-mjahr IS INITIAL
**    AND NOT cs_goitem-zeile IS INITIAL.
**      SELECT SINGLE * FROM migo_badi_exampl INTO ls_migo_badi_exampl
**      WHERE mblnr = cs_goitem-mblnr
**      AND mjahr = cs_goitem-mjahr
**      AND zeile = cs_goitem-zeile.
**      IF sy-subrc = 0.
**        MOVE-CORRESPONDING ls_migo_badi_exampl TO ls_extdata_new.
**      ENDIF.
**    ENDIF.
**    ls_extdata_new-sgtxt  = cs_goitem-sgtxt.
**    ls_extdata_new-line_id = i_line_id.
**    INSERT ls_extdata_new INTO TABLE gt_extdata.
**  ELSE.
***   Line exists: Get external data entered on BAdI-subscreeen, but only
***                if line_modify was called for the item displayed in the
***                'detail tabstrip'.
**    CHECK g_line_id = i_line_id.
**
**    CALL FUNCTION 'MIGO_BADI_EXAMPLE_GET_DATA'
**    IMPORTING
**      es_migo_badi_screen_fields = ls_extdata_new.
**    ls_extdata_new-line_id = i_line_id.
**    IF ls_extdata_new-sgtxt <> ls_extdata_old-sgtxt.
***     Field was changed on external screen
**      cs_goitem-sgtxt = ls_extdata_new-sgtxt.
**    ELSE.
***     Take data from GOITEM
**      ls_extdata_new-sgtxt = cs_goitem-sgtxt.
**    ENDIF.
**    MODIFY TABLE gt_extdata FROM ls_extdata_new.
**  ENDIF.
**



ENDMETHOD.


  method IF_EX_MB_MIGO_BADI~MAA_LINE_ID_ADJUST.
  endmethod.


method IF_EX_MB_MIGO_BADI~MODE_SET.
* ACTION and REFDOC will discribe the mode of transaction MIGO.
* ----------------------------------------------------------------------
* i_action:
* A01 = Goods receipt
* A02 = Return delivery
* A03 = Cancellation
* A04 = Display
* A05 = Release GR bl.st.
* A06 = Subsequent deliv.
* A07 = Goods issue
*
* i_refdoc:
* R01 = Purchase order
* R02 = Material document
* R03 = Delivery note
* R04 = Inbound delivery
* R05 = Outbound delivery
* R06 = Transport
* R07 = Transport ID code
* R08 = Order
* R09 = Reservation
* R10 = Other GR
*-----------------------------------------------------------------------

* In case of 'DISPLAY' the global field G_NO_INPUT will be set to 'X'.
* The result is that a different external subscreen will be choosen in
* method PBO_DETAIL.
  IF i_action = 'A04' OR i_action = 'A03'.
    g_no_input = 'X'.
  ENDIF.
* In case of 'CANCEL' the global field G_CANCEL will be set to 'X'.
* The result is that in method POST_DOCUMENT a different handling is
* used
  IF i_action = 'A03'.
    g_cancel = 'X'.
  ENDIF.

  CALL FUNCTION 'ZZMIGO_OBTENER_MODO'
  EXPORTING
    i_action = i_action.

endmethod.


method IF_EX_MB_MIGO_BADI~PAI_DETAIL.
  IF i_line_id IS NOT INITIAL.
    e_force_change = 'X'.
  ENDIF.
*-----------------------------------------------------------------------
* Changing parameter E_FORCE_CHANGE can be set to 'X'. In this case
* method LINE_MODIFY is called.
* ATTENTION:
* DO NOT SET parameter E_FORCE_CHANGE = ' '. In this case you might
* overwrite parameter E_FORCE_CHANGE of another BAdI implementation.
*-----------------------------------------------------------------------
  DATA: ls_extdata_new TYPE migo_badi_example_screen_field,
        ls_extdata_old TYPE migo_badi_example_screen_field.

* Only if a line exists
  CHECK i_line_id <> 0.
* Get data from external screen
  CALL FUNCTION 'MIGO_BADI_EXAMPLE_GET_DATA'
  IMPORTING
    es_migo_badi_screen_fields = ls_extdata_new.
* Compare new data with old data
  READ TABLE gt_extdata INTO ls_extdata_old
  WITH TABLE KEY line_id = i_line_id.
  ls_extdata_new-line_id = i_line_id.
  IF ls_extdata_old <> ls_extdata_new.
*   If there were any changes, it's obligatory to force MIGO to trigger
*   method LINE_MODIFY.
    e_force_change = 'X'.
  ENDIF.

endmethod.


method IF_EX_MB_MIGO_BADI~PAI_HEADER.
endmethod.


method IF_EX_MB_MIGO_BADI~PBO_DETAIL.
 DATA: ls_extdata TYPE migo_badi_example_screen_field.

 data: ls_goitem  TYPE goitem,
       v_campo    TYPE string.
    FIELD-SYMBOLS <fs> TYPE goitem.

  "Verificamos que sea la badi que estamos implementando
  CHECK i_class_id = gf_class_id.

  "Cargamos los datos de la dynpro
  e_cprog   = 'SAPLZZMIGO'.
  e_dynnr   = '0004'.                     "External fields: Input
  e_heading = 'UNID/PRO'(004).

" Pasamos la posición a la tabla interna
  CALL FUNCTION 'ZZMIGO_CUST_DYNP_DETAIL'
  EXPORTING
    i_line_id = i_line_id.

* Set G_LINE_ID (= line_id of item displayed on detail-tabstrip)
  g_line_id = i_line_id.
** Read data
*  READ TABLE gt_extdata INTO ls_extdata
*  WITH TABLE KEY line_id = i_line_id.

  v_campo = '(SAPLMIGO)GOITEM'.

  ASSIGN (v_campo) TO <fs>.
  ls_goitem = <fs>.

  MOVE-CORRESPONDING ls_goitem TO ls_extdata.
  ls_extdata-line_id = i_line_id.

* Export data to function group (for display on subscreen)
  CALL FUNCTION 'ZMIGO_BADI_EXAMPLE_PUT_DATA'
  EXPORTING
    is_migo_badi_screen_fields = ls_extdata.



endmethod.


method IF_EX_MB_MIGO_BADI~PBO_HEADER.
endmethod.


METHOD if_ex_mb_migo_badi~post_document.
  DATA: et_mseg TYPE TABLE OF zzmigo_posicion.
  DATA: es_mseg LIKE LINE OF et_mseg.

*  break crystalis_ab.

  "Rescatamos la tabla interna
  CALL FUNCTION 'ZZMIGO_CUST_DYNP_GET'
    TABLES
      et_mseg = et_mseg.

  "Le pasamos la tabla interna rescatada a la función update
  "para ejecutarla de fondo
  CALL FUNCTION 'ZZMIGO_CUST_DYNP_UPDATE' IN BACKGROUND TASK
    EXPORTING
      i_mblnr = is_mkpf-mblnr
    TABLES
      et_mseg = et_mseg.


ENDMETHOD.


  method IF_EX_MB_MIGO_BADI~PROPOSE_SERIALNUMBERS.
  endmethod.


method IF_EX_MB_MIGO_BADI~PUBLISH_MATERIAL_ITEM.
endmethod.


method IF_EX_MB_MIGO_BADI~RESET.
endmethod.


method IF_EX_MB_MIGO_BADI~STATUS_AND_HEADER.
* In case of 'Display Material document' select external header data
  IF NOT g_no_input IS INITIAL.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM migo_badi_examp2 INTO gs_exdata_header
*  WHERE mblnr = is_gohead-mblnr
*  AND   mjahr = is_gohead-mjahr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM migo_badi_examp2 INTO gs_exdata_header
  WHERE mblnr = is_gohead-mblnr
  AND   mjahr = is_gohead-mjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
  ENDIF.
endmethod.
ENDCLASS.
