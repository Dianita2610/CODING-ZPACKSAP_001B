*&---------------------------------------------------------------------*
*&  Include           LZZMIGOI01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0900  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0900 INPUT.
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = zzunid_pro
*    IMPORTING
*      output = zzunid_pro.

  "Guardamos el valor de la Unidada en la tabla interna


  READ TABLE gt_mseg INTO gs_mseg WITH KEY line_id = w_line_id.
  IF sy-subrc EQ 0.
    gs_mseg-zzunid_pro = zzunid_pro.
    MODIFY gt_mseg FROM gs_mseg INDEX sy-tabix.
  ENDIF.

ENDMODULE.                 " USER_COMMAND_0900  INPUT
*&---------------------------------------------------------------------*
*&      Module  FORMAT_LECTURA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE format_zzunid_pro INPUT.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = zzunid_pro
    IMPORTING
      output = zzunid_pro.

ENDMODULE.                 " FORMAT_LECTURA  INPUT
*&---------------------------------------------------------------------*
*&      Module  CARGAR_PUESTO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE cargar_zzunid_pro OUTPUT.

  IF v_action = 'A04'.
    SELECT SINGLE zzunid_pro INTO (zzunid_pro)
        FROM mseg
        WHERE mblnr EQ migo_badi_header-mblnr
        AND mjahr EQ migo_badi_header-mjahr
        AND zeile EQ migo_badi_header-zeile.

    IF sy-subrc NE 0.
      CLEAR zzunid_pro.
    ENDIF.

    LOOP AT SCREEN.
      IF screen-name = 'ZZUNID_PRO'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF zzunid_pro IS INITIAL.
      ASSIGN (c_zzunid_pro) TO <fs_zzunid_pro>.
        IF sy-subrc EQ 0.
          zzunid_pro = <fs_zzunid_pro>.
        ENDIF.

  ENDIF.

  IF v_action = 'A01'.

"if zzunid_pro cs '0000'.
"      clear zzunid_pro.
"ENDIF.

  ENDIF.
ENDMODULE.                 " CARGAR_PUESTO  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0003  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0003 INPUT.
*  CLEAR:  ARBPL
*       .

ENDMODULE.                 " USER_COMMAND_0003  INPUT
