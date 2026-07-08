*&---------------------------------------------------------------------*
*&  Include           ZFIBI_001_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_bukrs FOR bkpf-bukrs OBLIGATORY,
                s_belnr FOR bkpf-belnr,
                s_gjahr FOR bkpf-gjahr OBLIGATORY.
SELECTION-SCREEN END OF BLOCK a1.


SELECTION-SCREEN BEGIN OF BLOCK a2 WITH FRAME TITLE text-002.
PARAMETERS : p_stgrd TYPE bkpf-stgrd OBLIGATORY,
             p_budat TYPE bkpf-budat,
             p_monat TYPE bkpf-monat,
             p_solode AS CHECKBOX DEFAULT ' ',
             p_test   AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK a2.
