*&---------------------------------------------------------------------*
*&  Include           ZMMRP_PPTO_VTA_E01
*&---------------------------------------------------------------------*

INITIALIZATION.
**comment ini
*  SELECT * FROM mara
*    INTO TABLE gt_mara.
**comment fin
  SELECT * FROM t001w
    INTO TABLE gt_t001w.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_file.

  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
      mask      = '*.xls, *.xlsx'
      static    = 'X'
    CHANGING
      file_name = pa_file.

START-OF-SELECTION.
  PERFORM load_file.
**add comment
  SELECT * FROM zmm_ppto_vta
    INTO TABLE gt_ppto_vta."#EC CI_NOWHERE
**add comment
  LOOP AT gt_ppto INTO gs_ppto.
    gv_pos = sy-tabix.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = gs_ppto-matnr
      IMPORTING
        output = gs_ppto-matnr.

    READ TABLE gt_ppto_vta INTO gs_ppto_vta " TRANSPORTING NO FIELDS
      WITH KEY matnr    = gs_ppto-matnr
               zversion = gs_ppto-versn
               werks    = gs_ppto-werks
               gjahr    = gs_ppto-gjahr.

    gv_pos = gv_pos + 1.
    IF sy-subrc EQ 0.
* / Update record
      MOVE-CORRESPONDING gs_ppto TO gs_ppto_vta.
      gs_ppto_vta-mandt = sy-mandt.
      gs_ppto_vta-zversion = gs_ppto-versn.
      PERFORM valid_data USING gs_ppto_vta gv_pos
              CHANGING gv_check.
      IF gv_check = 0.
        PERFORM update_record USING gs_ppto_vta gv_pos.
      ENDIF.
    ELSE.
* / Insert new record
      MOVE-CORRESPONDING gs_ppto TO gs_ppto_vta.
      gs_ppto_vta-mandt = sy-mandt.
      gs_ppto_vta-zversion = gs_ppto-versn.

      PERFORM valid_data USING gs_ppto_vta gv_pos
              CHANGING gv_check.

        IF gv_check = 0.
          PERFORM insert_record USING gs_ppto_vta gv_pos.
        ENDIF.
    ENDIF.

  ENDLOOP.

END-OF-SELECTION.

  PERFORM show_log.
