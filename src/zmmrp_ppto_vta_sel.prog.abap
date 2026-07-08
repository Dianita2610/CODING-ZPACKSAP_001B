*&---------------------------------------------------------------------*
*&  Include           ZMMRP_PPTO_VTA_SEL
*&---------------------------------------------------------------------*


SELECTION-SCREEN BEGIN OF BLOCK bloque1 WITH FRAME TITLE text-001.

  PARAMETERS: pa_werks LIKE t001w-werks     OBLIGATORY,
              pa_file  LIKE rlgrap-filename OBLIGATORY MEMORY ID arc.

SELECTION-SCREEN END OF BLOCK bloque1.
