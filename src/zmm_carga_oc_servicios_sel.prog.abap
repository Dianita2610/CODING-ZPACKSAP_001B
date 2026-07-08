*&---------------------------------------------------------------------*
*&  Include           ZMM_CARGA_OC_SERVICIOS_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-t01.
PARAMETERS  p_file  LIKE rlgrap-filename OBLIGATORY.
SELECTION-SCREEN END OF BLOCK blk1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM open_file.
