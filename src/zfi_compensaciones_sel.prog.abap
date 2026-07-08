*&---------------------------------------------------------------------*
*&  Include           ZFI_COMPENSACIONES_SEL.
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_laufd FOR reguh-laufd,
                s_laufi FOR reguh-laufi,
                s_bukrs FOR bkpf-bukrs,
                s_zaldt FOR reguh-zaldt.

PARAMETERS: p_mode TYPE ctu_mode   DEFAULT 'E',
            p_test AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK a1.
