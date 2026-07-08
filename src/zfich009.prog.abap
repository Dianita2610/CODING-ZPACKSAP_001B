*&---------------------------------------------------------------------*
*& Report  ZFICH009
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfich009.

INCLUDE zfich009_top.
INCLUDE zfich009_sel.
INCLUDE zfich009_rut.

START-OF-SELECTION.
  g_repid = sy-repid.
  PERFORM bajar_archivo.
  IF NOT ti_entrada[] IS INITIAL.
    PERFORM procesar.
    IF NOT ti_payr[] IS INITIAL.
       PERFORM mostrar_alv.
    ENDIF.
  ELSE.
    MESSAGE text-002 TYPE 'I'.
  ENDIF.
