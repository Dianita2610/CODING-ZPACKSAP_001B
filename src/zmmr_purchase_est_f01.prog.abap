*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZMMR_PURCHASE_EST_F01
*&---------------------------------------------------------------------*

FORM get_data.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM zmm_ppto_vta INTO TABLE gt_ppto_vta
*    WHERE matnr   IN so_matnr
*      AND zversion IN so_versn
*      AND werks   IN so_werks
*      AND gjahr   IN so_gjahr.
*
* NEW CODE
  SELECT *
 FROM zmm_ppto_vta INTO TABLE gt_ppto_vta
    WHERE matnr   IN so_matnr
      AND zversion IN so_versn
      AND werks   IN so_werks
      AND gjahr   IN so_gjahr ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

  IF gt_ppto_vta[] IS NOT INITIAL.
* / Posición de lista de materiales
    SELECT a~matnr a~werks a~stlan a~stlnr a~stlal b~stlkn b~stpoz b~idnrk b~menge INTO TABLE gt_stpo
      FROM mast AS a INNER JOIN stpo AS b
      ON b~stlty = 'M' AND a~stlnr = b~stlnr
      FOR ALL ENTRIES IN gt_ppto_vta
      WHERE matnr = gt_ppto_vta-matnr
        AND werks = gt_ppto_vta-werks.

**    IF gt_stpo[] IS NOT INITIAL.
**
**
**
***      IF gt_mast[] IS NOT INITIAL.
***        SELECT * FROM stpo INTO TABLE gt_stpo
***          FOR ALL ENTRIES IN gt_mast
***            WHERE stlty = 'M'
***              AND stlnr = gt_mast-stlnr.
***      ENDIF.
**
*** / Cantidad
**      SELECT matnr werks lgort labst FROM mard
**        INTO TABLE gt_mard
**          FOR ALL ENTRIES IN gt_stpo
**            WHERE matnr = gt_stpo-idnrk
**              AND werks = gt_stpo-werks.
**    ENDIF.
  ENDIF.

* / Ultima compra

  SELECT SINGLE MAX( ebeln ) lifnr waers kdatb kdate FROM ekko
    INTO gs_ekko_last
    GROUP BY lifnr waers kdatb kdate.

  IF gs_ekko_last IS NOT INITIAL.
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT ebeln ebelp matnr meins netpr brtwr banfn FROM ekpo
*      INTO TABLE gt_ekpo_last
*        WHERE ebeln EQ gs_ekko_last-ebeln.
*
* NEW CODE
    SELECT ebeln ebelp matnr meins netpr brtwr banfn
 FROM ekpo
      INTO TABLE gt_ekpo_last
        WHERE ebeln EQ gs_ekko_last-ebeln ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03
  ENDIF.
*    ORDER BY ebeln bedat DESCENDING
* / Obtener Contratos Marco

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT ebeln lifnr waers kdatb kdate FROM ekko
*    INTO TABLE gt_ekko
*    WHERE bstyp EQ gc_bstyp
*      AND lifnr IN so_lifnr
*      AND kdatb LE sy-datum
*      AND kdate GE sy-datum.
*
* NEW CODE
  SELECT ebeln lifnr waers kdatb kdate
 FROM ekko
    INTO TABLE gt_ekko
    WHERE bstyp EQ gc_bstyp
      AND lifnr IN so_lifnr
      AND kdatb LE sy-datum
      AND kdate GE sy-datum ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

  IF gt_ekko[] IS NOT INITIAL.
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT ebeln ebelp matnr meins netpr brtwr banfn bnfpo FROM ekpo
*      INTO TABLE gt_ekpo
*        FOR ALL ENTRIES IN gt_ekko
*          WHERE ebeln EQ gt_ekko-ebeln
*            AND werks IN so_werks.
*
* NEW CODE
    SELECT ebeln ebelp matnr meins netpr brtwr banfn bnfpo
 FROM ekpo
      INTO TABLE gt_ekpo
        FOR ALL ENTRIES IN gt_ekko
          WHERE ebeln EQ gt_ekko-ebeln
            AND werks IN so_werks ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03
  ENDIF.



ENDFORM.                    "get_data

*&---------------------------------------------------------------------*
*&      Form  get_solped_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_solped_data.

  DATA: lv_lfdat TYPE char08.

  CONCATENATE so_gjahr-low so_monat-low '__' INTO lv_lfdat.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT banfn bnfpo bstyp loekz txz01 matnr werks matkl menge meins preis waers lifnr lfdat FROM eban
*    INTO TABLE gt_eban
*      WHERE bsart EQ   gc_zspm
*        AND matnr IN   so_matnr
*        AND werks IN   so_werks
*        AND lifnr IN   so_lifnr
*        AND lfdat LIKE lv_lfdat.
*
* NEW CODE
  SELECT banfn bnfpo bstyp loekz txz01 matnr werks matkl menge meins preis waers lifnr lfdat
 FROM eban
    INTO TABLE gt_eban
      WHERE bsart EQ   gc_zspm
        AND matnr IN   so_matnr
        AND werks IN   so_werks
        AND lifnr IN   so_lifnr
        AND lfdat LIKE lv_lfdat ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03
ENDFORM.                    "get_solped_data

*&---------------------------------------------------------------------*
*&      Form  process_solped_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM process_solped_data.

  DATA: lv_ctrl  TYPE c,
        lv_brtwr TYPE ekpo-brtwr.

  CLEAR gt_output.

  LOOP AT gt_eban INTO gs_eban.
    gt_output-zorig = 'SOLPED'.
    gt_output-matnr = gs_eban-matnr.
    gt_output-werks = gs_eban-werks.

    READ TABLE gt_makt WITH KEY matnr = gt_output-matnr.
    gt_output-maktx = gt_makt-maktx.

    READ TABLE gt_mara WITH KEY matnr = gt_output-matnr.
    gt_output-matkl = gt_mara-matkl.

    READ TABLE gt_mbew WITH KEY matnr = gt_output-matnr
                                bwkey = gt_output-werks.

    IF sy-subrc EQ 0.
      READ TABLE gt_t030 INTO gs_t030 WITH KEY bklas = gt_mbew-bklas.
      gt_output-konts = gs_t030-konts.
    ENDIF.

    gt_output-zcant = gs_eban-menge.

    LOOP AT gt_mard INTO gs_mard WHERE matnr = gt_output-matnr
                                   AND werks = gt_output-werks.

      gt_output-labst = gt_output-labst + gs_mard-labst.

    ENDLOOP.

    LOOP AT gt_ekpo WHERE matnr = gt_output-matnr.

      READ TABLE gt_ekko WITH KEY ebeln = gt_ekpo-ebeln.

      gt_output-ebeln = gt_ekko-ebeln.
      gt_output-ebelp = gt_ekpo-ebelp.
      gt_output-banfn = gt_ekpo-banfn.
      gt_output-netpr = gt_ekpo-netpr.
      gt_output-meins = gt_ekpo-meins.
      gt_output-waers = gt_ekko-waers.
      gt_output-lifnr = gt_ekko-lifnr.

      READ TABLE gt_lfa1 WITH KEY gt_ekko-lifnr.
      IF sy-subrc EQ 0.
        gt_output-stcd1 = gt_lfa1-stcd1.
        gt_output-name1 = gt_lfa1-name1.
      ENDIF.

      APPEND gt_output.
      CLEAR: gt_ekko, gt_ekpo.
      lv_ctrl = '1'.
      EXIT.
    ENDLOOP.

    IF gt_output-ebeln IS INITIAL.
      CLEAR: lv_brtwr.
      LOOP AT gt_ekpo_last INTO gs_ekpo_last.
        lv_brtwr = lv_brtwr + gs_ekpo_last-brtwr.
      ENDLOOP.
      gt_output-brtwr = lv_brtwr.
      gt_output-meins = gs_ekpo_last-meins.
      gt_output-waers = gs_ekko_last-waers.

    ENDIF.

    IF lv_ctrl IS INITIAL.

      IF gt_output-lifnr IS INITIAL.
        gt_output-lifnr = gs_eban-lifnr.
      ENDIF.

      READ TABLE gt_lfa1 WITH KEY gt_output-lifnr.
      IF sy-subrc EQ 0.
        gt_output-stcd1 = gt_lfa1-stcd1.
        gt_output-name1 = gt_lfa1-name1.
      ENDIF.

      gt_output-banfn = gs_eban-banfn.
      gt_output-bnfpo = gs_eban-bnfpo.
      gt_output-meins = gs_eban-meins.
      gt_output-waers = gs_eban-waers.

      APPEND gt_output.
    ENDIF.
    CLEAR: gt_output, gs_t030, lv_ctrl.
  ENDLOOP.


ENDFORM.                    "process_solped_data

*&---------------------------------------------------------------------*
*&      Form  get_aditional_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_aditional_data.

  DATA: rg_matnr TYPE RANGE OF matnr,
        wa_matnr LIKE LINE OF rg_matnr,
        rg_werks TYPE RANGE OF ewerk,
        wa_werks LIKE LINE OF rg_werks.

  DATA: rg_lifnr TYPE RANGE OF ekko-lifnr,
        wa_lifnr LIKE LINE OF rg_lifnr.


  wa_matnr-sign = 'I'.
  wa_matnr-option = 'EQ'.
  wa_lifnr-sign = 'I'.
  wa_lifnr-option = 'EQ'.

  LOOP AT gt_stpo INTO gs_stpo.
    wa_matnr-low = gs_stpo-idnrk.
    APPEND wa_matnr TO rg_matnr.
    wa_werks-low = gs_stpo-werks.
    APPEND wa_werks TO rg_werks.
  ENDLOOP.

  LOOP AT gt_eban INTO gs_eban.
    wa_matnr-low = gs_eban-matnr.
    APPEND wa_matnr TO rg_matnr.
    wa_werks-low = gs_eban-werks.
    APPEND wa_werks TO rg_werks.
    wa_lifnr-low = gs_eban-lifnr.
    APPEND wa_lifnr TO rg_lifnr.
  ENDLOOP.

  IF rg_matnr[] IS NOT INITIAL.

*Begin of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES04 ECDK917080 *
SORT RG_MATNR BY LOW .
*End of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES04 ECDK917080 *
    DELETE ADJACENT DUPLICATES FROM rg_matnr COMPARING low.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT matnr maktx FROM makt INTO TABLE gt_makt
*      WHERE matnr IN rg_matnr
*        AND spras EQ sy-langu.
*
* NEW CODE
    SELECT matnr maktx
 FROM makt INTO TABLE gt_makt
      WHERE matnr IN rg_matnr
        AND spras EQ sy-langu ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT matnr matkl FROM mara INTO TABLE gt_mara
*      WHERE matnr IN rg_matnr.
*
* NEW CODE
    SELECT matnr matkl
 FROM mara INTO TABLE gt_mara
      WHERE matnr IN rg_matnr ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03
  ENDIF.

  LOOP AT gt_ekko.
    wa_lifnr-low = gt_ekko-lifnr.
    APPEND wa_lifnr TO rg_lifnr.
  ENDLOOP.

*Begin of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES04 ECDK917080 *
SORT RG_LIFNR[] BY LOW .
*End of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES04 ECDK917080 *
  DELETE ADJACENT DUPLICATES FROM rg_lifnr[] COMPARING low.

  IF rg_lifnr[] IS NOT INITIAL.
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT lifnr name1 stcd1 FROM lfa1
*      INTO TABLE gt_lfa1
*        WHERE lifnr IN rg_lifnr.
*
* NEW CODE
    SELECT lifnr name1 stcd1
 FROM lfa1
      INTO TABLE gt_lfa1
        WHERE lifnr IN rg_lifnr ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03
  ENDIF.

* / Valoración de material

*Begin of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES04 ECDK917080 *
SORT RG_WERKS[] BY LOW .
*End of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES04 ECDK917080 *
  DELETE ADJACENT DUPLICATES FROM rg_werks[] COMPARING low.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT matnr bwkey bwtar bklas FROM mbew
*    INTO TABLE gt_mbew
*      WHERE matnr IN rg_matnr
*        AND bwkey IN so_werks.
*
* NEW CODE
  SELECT matnr bwkey bwtar bklas
 FROM mbew
    INTO TABLE gt_mbew
      WHERE matnr IN rg_matnr
        AND bwkey IN so_werks ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

  IF gt_mbew[] IS NOT INITIAL.
* / Cuentas Fijas - Cta. Gasto
SELECT * FROM t030 INTO TABLE gt_t030
FOR ALL ENTRIES IN gt_mbew
WHERE ktopl = gc_ktopl
AND ktosl = gc_ktosl
AND bwmod = gc_bwmod
AND komok = gc_komok
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES04 ECDK917080 *
*AND bklas = gt_mbew-bklas.
AND BKLAS = GT_MBEW-BKLAS ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES04 ECDK917080 *

  ENDIF.

* / Stock actual
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT matnr werks lgort labst FROM mard
*    INTO TABLE gt_mard
*        WHERE matnr IN rg_matnr
*          AND werks IN so_werks.
*
* NEW CODE
  SELECT matnr werks lgort labst
 FROM mard
    INTO TABLE gt_mard
        WHERE matnr IN rg_matnr
          AND werks IN so_werks ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03
ENDFORM.                    "get_aditional_data

*&---------------------------------------------------------------------*
*&      Form  process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM process_bom_data.

  DATA: lv_ctrl  TYPE c,
        lv_brtwr TYPE ekpo-brtwr.

*  LOOP AT gt_ppto_vta INTO gs_ppto_vta.
  LOOP AT gt_stpo INTO gs_stpo.
    gt_output-zorig = 'BOM'.
    gt_output-matnr = gs_stpo-idnrk.
    gt_output-werks = gs_stpo-werks.

    READ TABLE gt_makt WITH KEY matnr = gt_output-matnr.
    gt_output-maktx = gt_makt-maktx.

    READ TABLE gt_mara WITH KEY matnr = gt_output-matnr.
    gt_output-matkl = gt_mara-matkl.

    READ TABLE gt_mbew WITH KEY matnr = gt_output-matnr
                                bwkey = gt_output-werks.

    IF sy-subrc EQ 0.
      READ TABLE gt_t030 INTO gs_t030 WITH KEY bklas = gt_mbew-bklas.
      gt_output-konts = gs_t030-konts.
    ENDIF.

    READ TABLE gt_ppto_vta INTO gs_ppto_vta WITH KEY matnr = gs_stpo-matnr
                                                     werks = gs_stpo-werks.

    PERFORM get_amount USING so_monat-low gs_ppto_vta
                    CHANGING gt_output-zcant.

    gt_output-zcant = gt_output-zcant * gs_stpo-menge.

    LOOP AT gt_mard INTO gs_mard WHERE matnr = gt_output-matnr
                                   AND werks = gt_output-werks.

      gt_output-labst = gt_output-labst + gs_mard-labst.

    ENDLOOP.

    LOOP AT gt_ekpo WHERE matnr = gt_output-matnr.

      READ TABLE gt_ekko WITH KEY ebeln = gt_ekpo-ebeln.

      gt_output-ebeln = gt_ekko-ebeln.
      gt_output-ebelp = gt_ekpo-ebelp.
      gt_output-banfn = gt_ekpo-banfn.
      gt_output-bnfpo = gt_ekpo-bnfpo.
      gt_output-netpr = gt_ekpo-netpr.
      gt_output-meins = gt_ekpo-meins.
      gt_output-waers = gt_ekko-waers.
      gt_output-lifnr = gt_ekko-lifnr.

      READ TABLE gt_lfa1 WITH KEY gt_ekko-lifnr.
      IF sy-subrc EQ 0.
        gt_output-stcd1 = gt_lfa1-stcd1.
        gt_output-name1 = gt_lfa1-name1.
      ENDIF.

      APPEND gt_output.
      CLEAR: gt_ekko, gt_ekpo.
      lv_ctrl = '1'.
      EXIT.
    ENDLOOP.

    IF gt_output-ebeln IS INITIAL.
      CLEAR: lv_brtwr.
      LOOP AT gt_ekpo_last INTO gs_ekpo_last.
        lv_brtwr = lv_brtwr + gs_ekpo_last-brtwr.
      ENDLOOP.
      gt_output-brtwr = lv_brtwr.
      gt_output-meins = gs_ekpo_last-meins.
      gt_output-waers = gs_ekko_last-waers.

    ENDIF.

    IF lv_ctrl IS INITIAL.
      APPEND gt_output.
    ENDIF.

    CLEAR: gs_stpo, gs_ppto_vta, gs_t030, lv_ctrl, gt_output.
  ENDLOOP.
ENDFORM.                    "process_data

*&---------------------------------------------------------------------*
*&      Form  get_amount
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PA_MONAT   text
*      -->PS_BUGET   text
*      -->CH_CANT    text
*----------------------------------------------------------------------*
FORM get_amount USING pa_monat TYPE monat
                      ps_buget TYPE zmm_ppto_vta
             CHANGING ch_cant  TYPE zppto13dec2.

  CASE pa_monat.
    WHEN 01.
      ch_cant = ps_buget-month01.
    WHEN 02.
      ch_cant = ps_buget-month02.
    WHEN 03.
      ch_cant = ps_buget-month03.
    WHEN 04.
      ch_cant = ps_buget-month04.
    WHEN 05.
      ch_cant = ps_buget-month05.
    WHEN 06.
      ch_cant = ps_buget-month06.
    WHEN 07.
      ch_cant = ps_buget-month07.
    WHEN 08.
      ch_cant = ps_buget-month08.
    WHEN 09.
      ch_cant = ps_buget-month09.
    WHEN 10.
      ch_cant = ps_buget-month10.
    WHEN 11.
      ch_cant = ps_buget-month11.
    WHEN 12.
      ch_cant = ps_buget-month12.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    "get_amount

*&---------------------------------------------------------------------*
*&      Form  show_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM show_alv.

  PERFORM set_layout.
  PERFORM fill_catalog.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = gv_repid
      is_layout               = gs_layout
      it_fieldcat             = gt_fieldcat[]
      i_save                  = 'X'
      is_variant              = gs_variant
      it_events               = gt_events
      is_print                = gs_print
      i_callback_user_command = gc_ucomm
    TABLES
      t_outtab                = gt_output[]
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    "show_alv

*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->F_UCOMM    text
*      -->I_SELFIELD text
*----------------------------------------------------------------------*
FORM user_command USING f_ucomm    LIKE sy-ucomm
                        i_selfield TYPE slis_selfield.

  CASE i_selfield-fieldname.
    WHEN 'EBELN'.
*      PERFORM read_oc USING i_selfield.
    WHEN 'BELNR'.
*      PERFORM read_fact USING i_selfield.
    WHEN 'LBLNI'.
*      PERFORM read_hes USING i_selfield.
    WHEN 'BELNRP'.
*      PERFORM read_pago USING i_selfield.
  ENDCASE.

ENDFORM. " USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  set_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_layout.

  gs_layout-zebra        = 'X'.
  gs_layout-detail_popup = 'X'.
  gs_layout-reprep       = 'X'.
  gv_repid               = sy-repid.
  gs_variant-report      = gv_repid.
  gs_print-no_print_listinfos  = 'X'.

ENDFORM.                    "set_layout

*&---------------------------------------------------------------------*
*&      Form  fill_catalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fill_catalog.

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv.

  FIELD-SYMBOLS: <fs_fieldcat> TYPE slis_fieldcat_alv.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = gv_repid
      i_structure_name       = 'ZMMS_PURCHASE'
      i_inclname             = gv_repid
    CHANGING
      ct_fieldcat            = gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT gt_fieldcat ASSIGNING <fs_fieldcat>.
    CASE <fs_fieldcat>-fieldname.
      WHEN 'ZORIG'.
        <fs_fieldcat>-seltext_s    = 'Origen'.
        <fs_fieldcat>-seltext_m    = 'Origen'.
        <fs_fieldcat>-seltext_l    = 'Origen'.
        <fs_fieldcat>-reptext_ddic = 'Origen'.
      WHEN 'MAKTX'.
        <fs_fieldcat>-seltext_s    = 'Nombre Material'.
        <fs_fieldcat>-seltext_m    = 'Nombre Material'.
        <fs_fieldcat>-seltext_l    = 'Nombre Material'.
        <fs_fieldcat>-reptext_ddic = 'Nombre Material'.
      WHEN 'MATKL'.
        <fs_fieldcat>-seltext_s    = 'Grupo Artículo'.
        <fs_fieldcat>-seltext_m    = 'Grupo Artículo'.
        <fs_fieldcat>-seltext_l    = 'Grupo Artículo'.
        <fs_fieldcat>-reptext_ddic = 'Grupo Artículo'.
        <fs_fieldcat>-outputlen    = '12'.
      WHEN 'WERKS'.
        <fs_fieldcat>-outputlen    = '8'.
      WHEN 'KONTS'.
        <fs_fieldcat>-seltext_s    = 'Cta.Gasto'.
        <fs_fieldcat>-seltext_m    = 'Cta.Gasto'.
        <fs_fieldcat>-seltext_l    = 'Cta.Gasto'.
        <fs_fieldcat>-reptext_ddic = 'Cta.Gasto'.
        <fs_fieldcat>-outputlen    = '12'.
      WHEN 'ZCANT'.
        <fs_fieldcat>-seltext_s    = 'Cantidad'.
        <fs_fieldcat>-seltext_m    = 'Cantidad'.
        <fs_fieldcat>-seltext_l    = 'Cantidad'.
        <fs_fieldcat>-reptext_ddic = 'Cantidad'.
        <fs_fieldcat>-outputlen    = '16'.
      WHEN 'LABST'.
        <fs_fieldcat>-seltext_s    = 'Stock Actual'.
        <fs_fieldcat>-seltext_m    = 'Stock Actual'.
        <fs_fieldcat>-seltext_l    = 'Stock Actual'.
        <fs_fieldcat>-reptext_ddic = 'Stock Actual'.
        <fs_fieldcat>-outputlen    = '16'.
        <fs_fieldcat>-decimals_out = '0'.
        <fs_fieldcat>-datatype = 'DEC'.
      WHEN 'EBELN'.
        <fs_fieldcat>-seltext_s    = 'Cnto Marco'.
        <fs_fieldcat>-seltext_m    = 'Cnto Marco'.
        <fs_fieldcat>-seltext_l    = 'Cnto Marco'.
        <fs_fieldcat>-reptext_ddic = 'Cnto Marco'.
      WHEN 'NETPR'.
        <fs_fieldcat>-seltext_s    = 'Precio Cnto Marco'.
        <fs_fieldcat>-seltext_m    = 'Precio Cnto Marco'.
        <fs_fieldcat>-seltext_l    = 'Precio Cnto Marco'.
        <fs_fieldcat>-reptext_ddic = 'Precio Cnto Marco'.
      WHEN 'LIFNR'.
        <fs_fieldcat>-seltext_s    = 'Proveedor'.
        <fs_fieldcat>-seltext_m    = 'Proveedor'.
        <fs_fieldcat>-seltext_l    = 'Proveedor'.
        <fs_fieldcat>-reptext_ddic = 'Proveedor'.
      WHEN 'NAME1'.
        <fs_fieldcat>-seltext_s    = 'Nombre Proveedor'.
        <fs_fieldcat>-seltext_m    = 'Nombre Proveedor'.
        <fs_fieldcat>-seltext_l    = 'Nombre Proveedor'.
        <fs_fieldcat>-reptext_ddic = 'Nombre Proveedor'.
      WHEN 'NETWR'.
        <fs_fieldcat>-seltext_s    = 'Precio.Contrato Marco'.
        <fs_fieldcat>-seltext_m    = 'Precio.Contrato Marco'.
        <fs_fieldcat>-seltext_l    = 'Precio.Contrato Marco'.
        <fs_fieldcat>-reptext_ddic = 'Precio.Contrato Marco'.
      WHEN 'BRTWR'.
        <fs_fieldcat>-seltext_s    = 'Precio ult compra'.
        <fs_fieldcat>-seltext_m    = 'Precio ult compra'.
        <fs_fieldcat>-seltext_l    = 'Precio ult compra'.
        <fs_fieldcat>-reptext_ddic = 'Precio ult compra'.
      WHEN 'MEINS'.
        <fs_fieldcat>-seltext_s    = 'Unidad de Medida'.
        <fs_fieldcat>-seltext_m    = 'Unidad de Medida'.
        <fs_fieldcat>-seltext_l    = 'Unidad de Medida'.
        <fs_fieldcat>-reptext_ddic = 'Unidad de Medida'.
        <fs_fieldcat>-outputlen    = '16'.
      WHEN 'MENGE'.
        <fs_fieldcat>-seltext_s    = 'Stock a comprar'.
        <fs_fieldcat>-seltext_m    = 'Stock a comprar'.
        <fs_fieldcat>-seltext_l    = 'Stock a comprar'.
        <fs_fieldcat>-reptext_ddic = 'Stock a comprar'.
      WHEN 'ZCONS'.
        <fs_fieldcat>-seltext_s    = 'Prom. Consumo Prod. cont. 6 meses'.
        <fs_fieldcat>-seltext_m    = 'Prom. Consumo Prod. cont. 6 meses'.
        <fs_fieldcat>-seltext_l    = 'Prom. Consumo Prod. cont. 6 meses'.
        <fs_fieldcat>-reptext_ddic = 'Prom. Consumo Prod. cont. 6 meses'.
        <fs_fieldcat>-outputlen    = '20'.
      WHEN 'ZPEXQ'.
        <fs_fieldcat>-seltext_s    = 'P * Q'.
        <fs_fieldcat>-seltext_m    = 'P * Q'.
        <fs_fieldcat>-seltext_l    = 'P * Q'.
        <fs_fieldcat>-reptext_ddic = 'P * Q'.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    "fill_catalog
