*&---------------------------------------------------------------------*
*&  Include           ZFIR002_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE text-t01.
PARAMETERS : p_bukrs TYPE bkpf-bukrs DEFAULT 'CL51' OBLIGATORY.
SELECT-OPTIONS : s_kunnr FOR bseg-kunnr, "OBLIGATORY,
                 s_blart FOR bkpf-blart NO-DISPLAY,
                 s_hkont FOR bseg-hkont NO-DISPLAY,
                 s_pago  FOR bkpf-blart NO-DISPLAY,
                 s_cta   FOR bseg-hkont NO-DISPLAY.
SELECTION-SCREEN SKIP.
PARAMETERS: p_a RADIOBUTTON GROUP r1,
            p_y RADIOBUTTON GROUP r1.
SELECTION-SCREEN SKIP.
PARAMETERS : p_pas RADIOBUTTON GROUP b1 DEFAULT 'X' USER-COMMAND cmd,
             p_real RADIOBUTTON GROUP b1.
SELECTION-SCREEN END OF BLOCK a1.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-003.
PARAMETERS : p_budat TYPE bkpf-budat DEFAULT sy-datum MODIF ID a1,
             p_mode  TYPE ctu_mode   DEFAULT 'N' MODIF ID a1,
             p_update TYPE ctu_update DEFAULT 'L' NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 EQ 'A1'.
      IF p_real EQ 'X'.
        screen-active = 1.

      ELSE.
        CLEAR p_real.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
