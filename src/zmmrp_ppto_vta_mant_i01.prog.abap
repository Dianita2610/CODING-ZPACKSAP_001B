*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZMMRP_PPTO_VTA_MANT_I01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'CANC' OR 'ENDE' OR 'BACK'.
      LEAVE PROGRAM.
    WHEN 'SAVE'.
      MOVE '0' TO sw.
      PERFORM check_input.

      IF sw = '1'.
        PERFORM show_messages.
        RETURN.
*      ENDIF.
      ELSE.                                                 " sw = 0
** graba en tabla
        CLEAR wa_zmm_ppto_vta.
        MOVE sy-mandt TO zmm_ppto_vta-mandt.
        MODIFY zmm_ppto_vta. "from w_ZCLRET006.
        IF sw = 0.
          PERFORM agrega_mensaje USING 'Registro Grabado' 'I'.
        ENDIF.
        COMMIT WORK.
        MOVE:
        zmm_ppto_vta-mandt   TO wa_zmm_ppto_vta-mandt,
        zmm_ppto_vta-matnr   TO wa_zmm_ppto_vta-matnr,
        zmm_ppto_vta-zversion TO wa_zmm_ppto_vta-zversion,
        zmm_ppto_vta-werks   TO wa_zmm_ppto_vta-werks,
        zmm_ppto_vta-gjahr   TO wa_zmm_ppto_vta-gjahr,
        zmm_ppto_vta-month01 TO wa_zmm_ppto_vta-month01,
        zmm_ppto_vta-month02 TO wa_zmm_ppto_vta-month02,
        zmm_ppto_vta-month03 TO wa_zmm_ppto_vta-month03,
        zmm_ppto_vta-month04 TO wa_zmm_ppto_vta-month04,
        zmm_ppto_vta-month05 TO wa_zmm_ppto_vta-month05,
        zmm_ppto_vta-month06 TO wa_zmm_ppto_vta-month06,
        zmm_ppto_vta-month07 TO wa_zmm_ppto_vta-month07,
        zmm_ppto_vta-month08 TO wa_zmm_ppto_vta-month08,
        zmm_ppto_vta-month09 TO wa_zmm_ppto_vta-month09,
        zmm_ppto_vta-month10 TO wa_zmm_ppto_vta-month10,
        zmm_ppto_vta-month11 TO wa_zmm_ppto_vta-month11,
        zmm_ppto_vta-month12 TO wa_zmm_ppto_vta-month12.

        READ TABLE gt_zmm_ppto_vta INTO gs_zmm_ppto_vta
             WITH KEY matnr  = wa_zmm_ppto_vta-matnr
                    zversion  = wa_zmm_ppto_vta-zversion
                      werks  = wa_zmm_ppto_vta-werks
                      gjahr  = wa_zmm_ppto_vta-gjahr.

        IF sy-subrc = 0.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES04 ECDK917080 *
SORT GT_ZMM_PPTO_VTA .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES04 ECDK917080 *
          MODIFY gt_zmm_ppto_vta FROM wa_zmm_ppto_vta INDEX sy-tabix.
        ELSE.
          APPEND  wa_zmm_ppto_vta TO gt_zmm_ppto_vta.
        ENDIF.
        IF sw = 0.
          PERFORM agrega_mensaje USING 'Tabla Visualización Modificada' 'I'.
        ENDIF.

        CALL METHOD go_grid->refresh_table_display.

        PERFORM show_messages.
        CLEAR wa_zmm_ppto_vta.

        view = 'NO'. " es nuevo.
      ENDIF.                                                "sw = 0

    WHEN 'CLEAR'.

      CLEAR: zmm_ppto_vta.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
