*&---------------------------------------------------------------------*
*&  Include           ZMMR_PO_RELEASE_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block01 WITH FRAME TITLE text-001.
*SELECTION-SCREEN SKIP.
PARAMETER pa_frgco TYPE t16fv-frgco OBLIGATORY.
SELECT-OPTIONS: " so_frgco FOR t16fv-frgco NO INTERVALS NO-EXTENSION,
                so_frggr FOR t16fv-frggr,
                so_bsart FOR ekko-bsart,
                so_bedat FOR ekko-bedat.
SELECTION-SCREEN END OF BLOCK block01.
