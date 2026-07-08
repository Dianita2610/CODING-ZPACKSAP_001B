*&---------------------------------------------------------------------*
*& Report  ZMMRP_LISTAMAT
*&
*&---------------------------------------------------------------------*
*& Creado por: SCL Consultores
*& Fecha: 29.08.2017
*& Descripción: Reporte Lista de Materiales
*&---------------------------------------------------------------------*

REPORT  zmmrp_listamat.

TABLES: mbew,
        mara,
        mast,
        stpo.

TABLES: t001.

TYPES: BEGIN OF ty_data,
       matnr   TYPE mara-matnr,
       maktx   TYPE makt-maktx,
       werks   TYPE t001w-werks,
       stlal   TYPE mast-stlal,
       name1   TYPE t001w-name1,
       matnr2  TYPE mara-matnr,
       maktx2  TYPE makt-maktx,
       mtart   TYPE mara-mtart,
       menge   TYPE stpo-menge,
       meins   TYPE stpo-meins,
       lgort   TYPE stpo-lgort,
       costo   TYPE mbew-stprs,
       costo_t TYPE mbew-stprs,
       waers   TYPE t001-waers,
       general TYPE c,
       line_color(4) TYPE c,     "Used to store row color attributes
       END OF ty_data.

DATA: it_data TYPE TABLE OF ty_data.
**********Definiciones ALV
*"General Data
TYPE-POOLS: slis.

*"Callback
DATA:
    gt_events      TYPE slis_t_event,
    gt_sort        TYPE slis_t_sortinfo_alv,
    gt_list_top_of_page TYPE slis_t_listheader,
    g_status_set   TYPE slis_formname VALUE 'PF_STATUS_SET',
    g_user_command TYPE slis_formname VALUE 'USER_COMMAND',
    g_top_of_page  TYPE slis_formname VALUE 'TOP_OF_PAGE',
    g_top_of_list  TYPE slis_formname VALUE 'TOP_OF_LIST',
    g_end_of_list  TYPE slis_formname VALUE 'END_OF_LIST'.
*"Variants
DATA: gs_layout TYPE slis_layout_alv,
      g_exit_caused_by_caller,
      gs_exit_caused_by_user TYPE slis_exit_by_user,
      g_repid LIKE sy-repid.
DATA: gs_variant LIKE disvariant,
      g_save.
DATA: it_fcat      TYPE slis_t_fieldcat_alv.

DATA: lt_t001w TYPE STANDARD TABLE OF t001w,
      ls_t001w LIKE LINE OF lt_t001w.


SELECTION-SCREEN BEGIN OF BLOCK a01 WITH FRAME TITLE text-001.
SELECT-OPTIONS: so_mat FOR mbew-matnr,
                so_wrk FOR mbew-bwkey OBLIGATORY.

SELECTION-SCREEN ULINE.

PARAMETERS: pa_gen RADIOBUTTON GROUP g1,
            pa_det RADIOBUTTON GROUP g1.

SELECTION-SCREEN END OF BLOCK a01.

INITIALIZATION.

START-OF-SELECTION.

  SELECT * INTO TABLE lt_t001w
    FROM t001w WHERE werks IN so_wrk.

  IF sy-subrc = 0.
    LOOP AT lt_t001w INTO ls_t001w.

      AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
        ID 'WERKS' FIELD ls_t001w-werks
        ID 'ACTVT' FIELD '03'.

      IF sy-subrc <> 0.
        MESSAGE e011(z1) WITH 'No tiene autorización para el centro'.
      ENDIF.
    ENDLOOP.
  ENDIF.

  PERFORM fo_get_data.

END-OF-SELECTION.
  PERFORM fo_process_data.

  IF NOT it_data[] IS INITIAL.
    PERFORM fo_alv.
  ELSE.
    MESSAGE 'No se han encontrado datos' TYPE 'S'.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  FO_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fo_get_data.

  DATA: it_mast TYPE TABLE OF mast,
        lv_mast TYPE mast,
        it_stpo TYPE TABLE OF stpo,
        it_stas TYPE TABLE OF stas,
        lv_stpo TYPE stpo,
        lv_stas TYPE stas,
        lv_data LIKE LINE OF it_data.
  DATA: it_data_aux TYPE TABLE OF ty_data,
        lv_data_aux LIKE LINE OF it_data_aux,
        lv_index TYPE sy-tabix.
  DATA: lv_bukrs TYPE t001-bukrs.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_mast
    FROM mast
    WHERE matnr IN so_mat
    AND werks IN so_wrk
*    and STLAN = '7'
    AND andat <= sy-datum.
  IF NOT it_mast[] IS INITIAL.
    SELECT stas~stlnr stas~stlal stas~stlkn
      INTO CORRESPONDING FIELDS OF TABLE it_stas
      FROM stko INNER JOIN stas
      ON  stko~stlnr = stas~stlnr
      AND stko~stlal = stas~stlal
      FOR ALL entries IN it_mast
      WHERE stko~stlnr = it_mast-stlnr
      AND   stko~stlty = 'M'.
  ENDIF.

  LOOP AT it_stas INTO lv_stas.
    SELECT *
      APPENDING CORRESPONDING FIELDS OF TABLE it_stpo
      FROM stpo
      WHERE stlnr = lv_stas-stlnr
      AND   stlkn = lv_stas-stlkn.
  ENDLOOP.

  LOOP AT it_mast INTO lv_mast.
    CLEAR lv_data.
    lv_data-matnr = lv_mast-matnr.
    lv_data-werks = lv_mast-werks.
    lv_data-stlal = lv_mast-stlal.

    SELECT SINGLE mtart INTO lv_data-mtart FROM mara WHERE matnr = lv_mast-matnr.
    SELECT SINGLE bukrs INTO lv_bukrs FROM t001k WHERE bwkey = lv_data-werks.
    SELECT SINGLE * FROM t001 WHERE bukrs = lv_bukrs.
    SELECT SINGLE name1 INTO lv_data-name1 FROM t001w WHERE werks = lv_mast-werks.
    SELECT SINGLE maktx INTO lv_data-maktx FROM makt WHERE spras = sy-langu AND matnr = lv_mast-matnr.
    lv_data-general = 'X'.
    lv_data-waers = t001-waers.
    lv_data-line_color = 'C510'.
    SELECT SINGLE bmeng
    INTO lv_data-menge
    FROM stko WHERE stlnr = lv_mast-stlnr
       AND  stlal = lv_mast-stlal
      AND   stlty = 'M'
      AND   wrkan = lv_mast-werks.

    APPEND lv_data TO it_data.
    LOOP AT it_stas INTO lv_stas WHERE stlnr = lv_mast-stlnr AND stlal = lv_mast-stlal.
      LOOP AT it_stpo INTO lv_stpo WHERE stlnr = lv_stas-stlnr AND stlkn = lv_stas-stlkn.
        lv_data-lgort   = lv_stpo-lgort.
        lv_data-matnr2  = lv_stpo-idnrk.
        lv_data-menge   = lv_stpo-menge.
        lv_data-meins   = lv_stpo-meins.
        SELECT SINGLE maktx INTO lv_data-maktx2 FROM makt WHERE spras = sy-langu AND matnr = lv_stpo-idnrk.
*
        SELECT SINGLE * FROM mbew WHERE matnr = lv_data-matnr2 AND bwkey = lv_data-werks.
        IF sy-subrc = 0.
          IF mbew-vprsv = 'S'. "Precio Fijo (Standard)
            lv_data-costo = lv_stpo-menge * mbew-stprs.
          ELSEIF mbew-vprsv = 'V'. "Precio Variable
            lv_data-costo = lv_stpo-menge * mbew-verpr.
          ENDIF.
        ENDIF.
        lv_data-general = ' '.
        lv_data-line_color = 'C210'.
        APPEND lv_data TO it_data.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

  it_data_aux[] = it_data[].

  LOOP AT it_data INTO lv_data WHERE general = 'X'.
    lv_index = sy-tabix.
    CLEAR lv_data-costo_t.
    LOOP AT it_data_aux INTO lv_data_aux WHERE matnr = lv_data-matnr AND werks = lv_data-werks AND general = ' ' AND stlal = lv_data-stlal.
      lv_data-costo_t = lv_data-costo_t + lv_data_aux-costo.
      lv_data-costo = lv_data-costo_t.
    ENDLOOP.

    MODIFY it_data FROM lv_data INDEX lv_index.
  ENDLOOP.



ENDFORM.                    " FO_GET_DATA
*&---------------------------------------------------------------------*
*&      Form  FO_PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fo_process_data.

  IF pa_gen = 'X'.
    DELETE it_data  WHERE general = ' '.
  ENDIF.

ENDFORM.                    " FO_PROCESS_DATA



*&---------------------------------------------------------------------*
*&  Include           ZMMR_0041_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZMM_REP_GESTION_P_NF01
*&---------------------------------------------------------------------*
FORM fo_alv .

  g_repid = sy-repid.
  PERFORM fo_layout_init USING gs_layout.
  PERFORM fo_eventtab_build USING gt_events[].
  PERFORM fo_set_fcat CHANGING it_fcat.
*  PERFORM fo_sort CHANGING gt_sort.

  gs_variant-report = g_repid.
  g_save           = 'A'.

  PERFORM fo_comment_build USING gt_list_top_of_page[].
*"Display List
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_background_id         = 'ALV_BACKGROUND'
      i_buffer_active         = 'X'
      i_callback_program      = g_repid
      i_callback_user_command = 'USER_COMMAND'
      i_structure_name        = 'IT_DATA'
      is_layout               = gs_layout
      it_fieldcat             = it_fcat
      i_save                  = g_save
      is_variant              = gs_variant
      it_events               = gt_events[]
      it_sort                 = gt_sort[]
    IMPORTING
      e_exit_caused_by_caller = g_exit_caused_by_caller
      es_exit_caused_by_user  = gs_exit_caused_by_user
    TABLES
      t_outtab                = it_data
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc = 0.
    IF g_exit_caused_by_caller = 'X'.
*"  Forced Exit by calling program
*"  .
    ELSE.
*"  User left list via F3, F12 or F15
      IF gs_exit_caused_by_user-back = 'X'.       "F3
*"    .
      ELSE.
        IF gs_exit_caused_by_user-exit = 'X'.     "F15
*"      .
        ELSE.
          IF gs_exit_caused_by_user-cancel = 'X'. "F12
*"        .
          ELSE.
*"        should not occur!
*"        .
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
*"Fatal error callin ALV
* MESSAGE AXXX(XY) WITH ...
  ENDIF.


ENDFORM.                    " FO_ALV

*&---------------------------------------------------------------------*
*&      Form  fo_LAYOUT_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_LAYOUT  text
*----------------------------------------------------------------------*
FORM fo_layout_init USING rs_layout TYPE slis_layout_alv.
*"Build layout for list display
  rs_layout-detail_popup      = 'X'.
  rs_layout-colwidth_optimize = 'X'.
  rs_layout-zebra             = 'X'.
  rs_layout-info_fieldname    = 'LINE_COLOR'.
ENDFORM.                    "fo_LAYOUT_INIT

*&---------------------------------------------------------------------*
*&      Form  fo_EVENTTAB_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EVENTS  text
*----------------------------------------------------------------------*
FORM fo_eventtab_build USING rt_events TYPE slis_t_event.
*"Registration of events to happen during list display
  DATA: ls_event TYPE slis_alv_event.
*
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = rt_events.
  READ TABLE rt_events WITH KEY name = slis_ev_top_of_page
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE g_top_of_page TO ls_event-form.
    APPEND ls_event TO rt_events.
  ENDIF.
ENDFORM.                    "fo_EVENTTAB_BUILD

*&---------------------------------------------------------------------*
*&      Form  fo_COMMENT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LT_TOP_OF_PAGE  text
*----------------------------------------------------------------------*
FORM fo_comment_build USING lt_top_of_page TYPE
                                        slis_t_listheader.
  DATA: ls_line TYPE slis_listheader.
  DATA: lv_name_text TYPE adrp-name_text.
  DATA: lv_date(10) TYPE c.
*
* LIST HEADING LINE: TYPE H
  CLEAR ls_line.
  ls_line-typ  = 'H'.
* LS_LINE-KEY:  NOT USED FOR THIS TYPE
  ls_line-info = 'Lista de materiales'.
  APPEND ls_line TO lt_top_of_page.
* STATUS LINE: TYPE S
  CLEAR ls_line.
  ls_line-typ  = 'S'.
*  key  = text-101.
  SELECT SINGLE name_text
    INTO lv_name_text
    FROM usr21 INNER JOIN adrp
    ON usr21~persnumber = adrp~persnumber
    WHERE usr21~bname = sy-uname.

  CONCATENATE 'Usuario: ' lv_name_text INTO   ls_line-info SEPARATED BY space.

  APPEND ls_line TO lt_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  WRITE sy-datum TO lv_date.
  CONCATENATE 'Fecha de ejecución: ' lv_date INTO ls_line-info SEPARATED BY space.
  APPEND ls_line TO lt_top_of_page.

ENDFORM.                    "fo_COMMENT_BUILD


*&---------------------------------------------------------------------*
*&      Form  fo_set_fcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->CT_FCAT    text
*----------------------------------------------------------------------*
FORM fo_set_fcat CHANGING ct_fcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fcat TYPE slis_fieldcat_alv,
        l_lin   TYPE i.
  CONSTANTS: con_true TYPE char1 VALUE 'X'.

  ADD 1 TO l_lin.
  CLEAR ls_fcat.
  ls_fcat-col_pos   = l_lin.
  ls_fcat-key       = 'X'.
  ls_fcat-fieldname = 'WERKS'.
  ls_fcat-checkbox  = ' '.
  ls_fcat-no_zero   = ' '.
  ls_fcat-seltext_l = 'Centro'.
  ls_fcat-seltext_m = ls_fcat-seltext_l.
  ls_fcat-seltext_s = ls_fcat-seltext_l.
  APPEND ls_fcat TO ct_fcat.

  ADD 1 TO l_lin.
  CLEAR ls_fcat.
  ls_fcat-col_pos   = l_lin.
  ls_fcat-key       = 'X'.
  ls_fcat-fieldname = 'NAME1'.
  ls_fcat-checkbox  = ' '.
  ls_fcat-no_zero   = ' '.
  ls_fcat-seltext_l = 'Nombre'.
  ls_fcat-seltext_m = ls_fcat-seltext_l.
  ls_fcat-seltext_s = ls_fcat-seltext_l.
  APPEND ls_fcat TO ct_fcat.


  ADD 1 TO l_lin.
  CLEAR ls_fcat.
  ls_fcat-col_pos    = l_lin.
  ls_fcat-fieldname  = 'MTART'.
  ls_fcat-key        = ' '.
  ls_fcat-fix_column = ' '.
  ls_fcat-checkbox   = ' '.
  ls_fcat-seltext_l  = 'T.Mat'.
  ls_fcat-seltext_m  = ls_fcat-seltext_l.
  ls_fcat-seltext_s  = ls_fcat-seltext_l.
  APPEND ls_fcat TO ct_fcat.

  ADD 1 TO l_lin.
  CLEAR ls_fcat.
  ls_fcat-col_pos    = l_lin.
  ls_fcat-fieldname  = 'MATNR'.
  ls_fcat-fix_column = ' '.
  ls_fcat-no_zero    = 'X'.
  ls_fcat-seltext_l  = 'Material'.
  ls_fcat-seltext_m  = ls_fcat-seltext_l.
  ls_fcat-seltext_s  = ls_fcat-seltext_l.
  APPEND ls_fcat TO ct_fcat.

  ADD 1 TO l_lin.
  CLEAR ls_fcat.
  ls_fcat-col_pos    = l_lin.
  ls_fcat-fieldname  = 'MAKTX'.
  ls_fcat-fix_column = ' '.
  ls_fcat-checkbox   = ' '.
  ls_fcat-seltext_l  = 'Texto breve de material'.
  ls_fcat-seltext_m  = ls_fcat-seltext_l.
  ls_fcat-seltext_s  = ls_fcat-seltext_l.
  APPEND ls_fcat TO ct_fcat.

*  ADD 1 TO l_lin.
*  CLEAR ls_fcat.
*  ls_fcat-col_pos    = l_lin.
*  ls_fcat-fieldname  = 'LGORT'.
*  ls_fcat-fix_column = ' '.
*  ls_fcat-checkbox   = ' '.
*  ls_fcat-no_zero    = 'X'.
*  ls_fcat-cfieldname = ' '.
*  ls_fcat-seltext_l  = 'Alm.'.
*  ls_fcat-seltext_m  = ls_fcat-seltext_l.
*  ls_fcat-seltext_s  = ls_fcat-seltext_l.
*  APPEND ls_fcat TO ct_fcat.

  IF pa_det = 'X'.

    ADD 1 TO l_lin.
    CLEAR ls_fcat.
    ls_fcat-col_pos    = l_lin.
    ls_fcat-fieldname  = 'MENGE'.
    ls_fcat-fix_column = ' '.
    ls_fcat-checkbox   = ' '.
    ls_fcat-quantity   = 'MEINS'.
    ls_fcat-no_zero    = 'X'.
    ls_fcat-seltext_l  = 'Cantidad Materiales'.
    ls_fcat-seltext_m  = ls_fcat-seltext_l.
    ls_fcat-seltext_s  = ls_fcat-seltext_l.
    APPEND ls_fcat TO ct_fcat.



    ADD 1 TO l_lin.
    CLEAR ls_fcat.
    ls_fcat-col_pos    = l_lin.
    ls_fcat-fieldname  = 'MATNR2'.
    ls_fcat-fix_column = ' '.
    ls_fcat-no_zero    = 'X'.
    ls_fcat-seltext_l  = 'Material Lista'.
    ls_fcat-seltext_m  = ls_fcat-seltext_l.
    ls_fcat-seltext_s  = ls_fcat-seltext_l.
    APPEND ls_fcat TO ct_fcat.

    ADD 1 TO l_lin.
    CLEAR ls_fcat.
    ls_fcat-col_pos    = l_lin.
    ls_fcat-fieldname  = 'MAKTX2'.
    ls_fcat-fix_column = ' '.
    ls_fcat-checkbox   = ' '.
    ls_fcat-seltext_l  = 'Texto breve de material'.
    ls_fcat-seltext_m  = ls_fcat-seltext_l.
    ls_fcat-seltext_s  = ls_fcat-seltext_l.
    APPEND ls_fcat TO ct_fcat.

    ADD 1 TO l_lin.
    CLEAR ls_fcat.
    ls_fcat-col_pos    = l_lin.
    ls_fcat-fieldname  = 'COSTO'.
    ls_fcat-fix_column = ' '.
    ls_fcat-checkbox   = ' '.
    ls_fcat-cfieldname = 'WAERS'.
    ls_fcat-seltext_l  = 'Costo Mat.Det.'.
    ls_fcat-seltext_m  = ls_fcat-seltext_l.
    ls_fcat-seltext_s  = ls_fcat-seltext_l.
    APPEND ls_fcat TO ct_fcat.

  ELSE.

    ADD 1 TO l_lin.
    CLEAR ls_fcat.
    ls_fcat-col_pos    = l_lin.
    ls_fcat-fieldname  = 'COSTO_T'.
    ls_fcat-fix_column = ' '.
    ls_fcat-checkbox   = ' '.
    ls_fcat-cfieldname = 'WAERS'.
    ls_fcat-seltext_l  = 'Costo Mat.Det.'.
    ls_fcat-seltext_m  = ls_fcat-seltext_l.
    ls_fcat-seltext_s  = ls_fcat-seltext_l.
    APPEND ls_fcat TO ct_fcat.

  ENDIF.

ENDFORM.                    "fo_set_fcat

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM top_of_page.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
*      i_logo             = 'Z_CMDLT_LOGO'
      it_list_commentary = gt_list_top_of_page.
ENDFORM.                    "TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  FO_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_SORT  text
*----------------------------------------------------------------------*
FORM fo_sort  CHANGING gt_sort TYPE slis_t_sortinfo_alv.

  DATA: ls_sort LIKE LINE OF gt_sort.

  CLEAR ls_sort.
  ls_sort-fieldname = 'OBJECTID'.
  ls_sort-up = 'X'.
  APPEND ls_sort TO gt_sort.

  CLEAR ls_sort.
  ls_sort-fieldname = 'USERNAME'.
  ls_sort-up = 'X'.
  APPEND ls_sort TO gt_sort.

  CLEAR ls_sort.
  ls_sort-fieldname = 'UDATE'.
  ls_sort-up = 'X'.
  APPEND ls_sort TO gt_sort.

  CLEAR ls_sort.
  ls_sort-fieldname = 'UTIME'.
  ls_sort-up = 'X'.
  APPEND ls_sort TO gt_sort.

  CLEAR ls_sort.
  ls_sort-fieldname = 'TCODE'.
  ls_sort-up = 'X'.
  APPEND ls_sort TO gt_sort.

  CLEAR ls_sort.
  ls_sort-fieldname = 'CHANGENR'.
  ls_sort-up = 'X'.
  APPEND ls_sort TO gt_sort.

  CLEAR ls_sort.
  ls_sort-fieldname = 'FNAME'.
  ls_sort-group = 'X'.
  APPEND ls_sort TO gt_sort.

  CLEAR ls_sort.
  ls_sort-fieldname = 'FTEXT'.
  ls_sort-group = 'X'.
  APPEND ls_sort TO gt_sort.


ENDFORM.                    " FO_SORT

*&---------------------------------------------------------------------*
*&      Form  FO_USER_COMMAND_G
*&---------------------------------------------------------------------*
*       User command del ALV princial
*----------------------------------------------------------------------*
FORM fo_user_command_g  USING r_ucomm      TYPE sy-ucomm
                              ls_selfield  TYPE slis_selfield.

  DATA: lv_data LIKE LINE OF it_data.

  IF r_ucomm = '&IC1'. "Doble Click.
    READ TABLE it_data INTO lv_data INDEX ls_selfield-tabindex.
*    CASE  ls_selfield-fieldname.
*
*
*    ENDCASE.
  ENDIF.

ENDFORM.                    "FO_USER_COMMAND_G
*&---------------------------------------------------------------------*
*&      Form  FO_LISTA_SOLP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fo_lista_solp USING    u_data TYPE ty_data.

  DATA: it_fieldcat TYPE  slis_t_fieldcat_alv,
        lv_fieldcat LIKE LINE OF it_fieldcat.
  DATA: l_lin TYPE i.


  ADD 1 TO l_lin.
  CLEAR lv_fieldcat.
  lv_fieldcat-col_pos   = l_lin.
  lv_fieldcat-fieldname = 'BANFN'.
  lv_fieldcat-checkbox  = ' '.
  lv_fieldcat-datatype  = 'CHAR'.
  lv_fieldcat-outputlen    = 12.
  lv_fieldcat-seltext_l = 'Sol.Ped.'.
  lv_fieldcat-seltext_m = lv_fieldcat-seltext_l.
  lv_fieldcat-seltext_s = lv_fieldcat-seltext_l.
  APPEND lv_fieldcat TO it_fieldcat.

  ADD 1 TO l_lin.
  CLEAR lv_fieldcat.
  lv_fieldcat-col_pos   = l_lin.
  lv_fieldcat-fieldname = 'BNFPO'.
  lv_fieldcat-checkbox  = ' '.
  lv_fieldcat-datatype  = 'NUMC'.
  lv_fieldcat-outputlen    = 7.
  lv_fieldcat-seltext_l = 'Pos.'.
  lv_fieldcat-seltext_m = lv_fieldcat-seltext_l.
  lv_fieldcat-seltext_s = lv_fieldcat-seltext_l.
  APPEND lv_fieldcat TO it_fieldcat.

  ADD 1 TO l_lin.
  CLEAR lv_fieldcat.
  lv_fieldcat-col_pos   = l_lin.
  lv_fieldcat-fieldname = 'MATNR'.
  lv_fieldcat-checkbox  = ' '.
  lv_fieldcat-datatype  = 'CHAR'.
  lv_fieldcat-no_zero   = 'X'.
  lv_fieldcat-outputlen    = 20.
  lv_fieldcat-seltext_l = 'Material'.
  lv_fieldcat-seltext_m = lv_fieldcat-seltext_l.
  lv_fieldcat-seltext_s = lv_fieldcat-seltext_l.
  APPEND lv_fieldcat TO it_fieldcat.

  ADD 1 TO l_lin.
  CLEAR lv_fieldcat.
  lv_fieldcat-col_pos   = l_lin.
  lv_fieldcat-fieldname = 'LFDAT'.
  lv_fieldcat-checkbox  = ' '.
  lv_fieldcat-datatype  = 'DATS'.
  lv_fieldcat-outputlen    = 12.
  lv_fieldcat-seltext_l = 'F.Entrega'.
  lv_fieldcat-seltext_m = lv_fieldcat-seltext_l.
  lv_fieldcat-seltext_s = lv_fieldcat-seltext_l.
  APPEND lv_fieldcat TO it_fieldcat.

  ADD 1 TO l_lin.
  CLEAR lv_fieldcat.
  lv_fieldcat-col_pos   = l_lin.
  lv_fieldcat-fieldname = 'MENGE'.
  lv_fieldcat-checkbox  = ' '.
  lv_fieldcat-datatype  = 'QUAN'.
  lv_fieldcat-outputlen    = 23.
  lv_fieldcat-seltext_l = 'Cantidad'.
  lv_fieldcat-seltext_m = lv_fieldcat-seltext_l.
  lv_fieldcat-seltext_s = lv_fieldcat-seltext_l.
  APPEND lv_fieldcat TO it_fieldcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
     i_callback_program                = sy-repid
     i_callback_user_command           = 'FO_USER_COMMAND_SOLP'
     it_fieldcat                       = it_fieldcat
    TABLES
      t_outtab                          = it_data
   EXCEPTIONS
     program_error                     = 1
     OTHERS                            = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " FO_LISTA_SOLP
*&---------------------------------------------------------------------*
*&      Form  fo_lista_solp_d
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->U_DATA     text
*----------------------------------------------------------------------*
FORM fo_lista_solp_d USING    u_data TYPE ty_data.



  DATA: it_fieldcat TYPE  slis_t_fieldcat_alv,
        lv_fieldcat LIKE LINE OF it_fieldcat.
  DATA: l_lin TYPE i.


  ADD 1 TO l_lin.
  CLEAR lv_fieldcat.
  lv_fieldcat-col_pos   = l_lin.
  lv_fieldcat-fieldname = 'BANFN'.
  lv_fieldcat-checkbox  = ' '.
  lv_fieldcat-datatype  = 'CHAR'.
  lv_fieldcat-outputlen    = 12.
  lv_fieldcat-seltext_l = 'Sol.Ped.'.
  lv_fieldcat-seltext_m = lv_fieldcat-seltext_l.
  lv_fieldcat-seltext_s = lv_fieldcat-seltext_l.
  APPEND lv_fieldcat TO it_fieldcat.

  ADD 1 TO l_lin.
  CLEAR lv_fieldcat.
  lv_fieldcat-col_pos   = l_lin.
  lv_fieldcat-fieldname = 'BNFPO'.
  lv_fieldcat-checkbox  = ' '.
  lv_fieldcat-datatype  = 'NUMC'.
  lv_fieldcat-outputlen    = 7.
  lv_fieldcat-seltext_l = 'Pos.'.
  lv_fieldcat-seltext_m = lv_fieldcat-seltext_l.
  lv_fieldcat-seltext_s = lv_fieldcat-seltext_l.
  APPEND lv_fieldcat TO it_fieldcat.


  ADD 1 TO l_lin.
  CLEAR lv_fieldcat.
  lv_fieldcat-col_pos   = l_lin.
  lv_fieldcat-fieldname = 'MATNR'.
  lv_fieldcat-checkbox  = ' '.
  lv_fieldcat-no_zero   = 'X'.
  lv_fieldcat-datatype  = 'CHAR'.
  lv_fieldcat-outputlen    = 20.
  lv_fieldcat-seltext_l = 'Material'.
  lv_fieldcat-seltext_m = lv_fieldcat-seltext_l.
  lv_fieldcat-seltext_s = lv_fieldcat-seltext_l.
  APPEND lv_fieldcat TO it_fieldcat.

  ADD 1 TO l_lin.
  CLEAR lv_fieldcat.
  lv_fieldcat-col_pos   = l_lin.
  lv_fieldcat-fieldname = 'LFDAT'.
  lv_fieldcat-checkbox  = ' '.
  lv_fieldcat-datatype  = 'DATS'.
  lv_fieldcat-outputlen    = 12.
  lv_fieldcat-seltext_l = 'F.Entrega'.
  lv_fieldcat-seltext_m = lv_fieldcat-seltext_l.
  lv_fieldcat-seltext_s = lv_fieldcat-seltext_l.
  APPEND lv_fieldcat TO it_fieldcat.

  ADD 1 TO l_lin.
  CLEAR lv_fieldcat.
  lv_fieldcat-col_pos   = l_lin.
  lv_fieldcat-fieldname = 'MENGE'.
  lv_fieldcat-checkbox  = ' '.
  lv_fieldcat-datatype  = 'QUAN'.
  lv_fieldcat-outputlen    = 23.
  lv_fieldcat-seltext_l = 'Cantidad'.
  lv_fieldcat-seltext_m = lv_fieldcat-seltext_l.
  lv_fieldcat-seltext_s = lv_fieldcat-seltext_l.
  APPEND lv_fieldcat TO it_fieldcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
     i_callback_program                = sy-repid
     i_callback_user_command           = 'FO_USER_COMMAND_SOLP_D'
     it_fieldcat                       = it_fieldcat
    TABLES
      t_outtab                          = it_data
   EXCEPTIONS
     program_error                     = 1
     OTHERS                            = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " FO_LISTA_SOLP_D

*&---------------------------------------------------------------------*
*&  Form           user_command
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE syst-ucomm
                        rs_selfield TYPE slis_selfield.

*  DATA : wa_alv        LIKE LINE  OF it_data,
*         td            TYPE i.
*
**  REFRESH : tabla_adj.
**  CLEAR   : wa_resultado.
*
*  READ TABLE it_data INDEX rs_selfield-tabindex INTO wa_alv.
*  IF sy-subrc EQ 0.
*    CASE r_ucomm.
*
*      WHEN '&IC1'.
*        IF  rs_selfield-fieldname = 'DOCADJOF'
*        AND rs_selfield-value     = c_green.
*          IF NOT wa_alv-banfn IS INITIAL.
*            LOOP AT sal_sood WHERE docto = wa_alv-banfn
*                             AND   typeid_a = 'BUS2105'.
*              MOVE-CORRESPONDING sal_sood TO tabla_adj.
*              COLLECT tabla_adj.
*            ENDLOOP.
*          ENDIF.
*
*          IF NOT tabla_adj[] IS INITIAL.
*            PERFORM catalogo_adj.
*            PERFORM build_layoutadj.
*            PERFORM display_alv_objdes.
*          ENDIF.
*
*        ELSEIF  rs_selfield-fieldname = 'DOCADJHES'
*        AND     rs_selfield-value     = c_green.
*          IF NOT wa_alv-lblni IS INITIAL.
*            LOOP AT sal_sood WHERE docto = wa_alv-lblni
*                             AND   typeid_a = 'BUS2091'.
*              MOVE-CORRESPONDING sal_sood TO tabla_adj.
*              COLLECT tabla_adj.
*            ENDLOOP.
*          ENDIF.
*
*          IF NOT tabla_adj[] IS INITIAL.
*            PERFORM catalogo_adj.
*            PERFORM build_layoutadj.
*            PERFORM display_alv_objdes.
*          ENDIF.
*
*        ELSEIF rs_selfield-fieldname = 'BANFN'.
*          IF NOT wa_alv-banfn IS INITIAL.
*            SET PARAMETER ID 'BAN' FIELD wa_alv-banfn.
*            CALL  TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.
*          ENDIF.
*
*        ELSEIF rs_selfield-fieldname = 'PETOF'
*        OR     rs_selfield-fieldname = 'ANFNR'.
*          IF NOT wa_alv-anfnr IS INITIAL.
*            SET PARAMETER ID 'ANF' FIELD wa_alv-anfnr.
*            CALL  TRANSACTION 'ME43' AND SKIP FIRST SCREEN.
*          ENDIF.
*        ELSEIF rs_selfield-fieldname = 'PEDID'.
*          IF NOT wa_alv-pedid IS INITIAL.
*            IF wa_alv-pedid+0(2) NE '46'.
*              SET PARAMETER ID 'BES' FIELD wa_alv-pedid.
*              CALL  TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
*            ELSE.
*              SET PARAMETER ID 'VRT' FIELD wa_alv-pedid.
*              CALL  TRANSACTION 'ME33K' AND SKIP FIRST SCREEN.
*            ENDIF.
*          ENDIF.
*        ELSEIF rs_selfield-fieldname = 'LBLNI'.
*          IF wa_alv-lblni IS INITIAL.
*            SET PARAMETER ID 'LBL' FIELD wa_alv-lblni.
*            CALL  TRANSACTION 'ML81N' AND SKIP FIRST SCREEN.
*          ENDIF.
*
*        ELSEIF rs_selfield-fieldname = 'MTO_PEDVIG'.
*          IF NOT wa_alv-mto_pedvig IS INITIAL.
*            SET PARAMETER ID 'LIF' FIELD wa_alv-lifnr.
*            CALL  TRANSACTION 'ME2L' AND SKIP FIRST SCREEN.
*          ENDIF.
*
*        ENDIF.
*
*    ENDCASE.
*  ENDIF.
ENDFORM.     "user_command
