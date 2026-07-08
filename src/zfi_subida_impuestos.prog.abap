*&---------------------------------------------------------------------*
*& Report  ZFI_SUBIDA_IMPUESTOS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfi_subida_impuestos.

INCLUDE zfi_subida_impuestos_top.
INCLUDE zfi_subida_impuestos_sel.
INCLUDE zfi_subida_impuestos_rut.

START-OF-SELECTION.
  g_repid = sy-repid.
  PERFORM bajar_archivo.
  IF not ti_entrada[] IS INITIAL.
    PERFORM llenar_tabla.
    IF NOT ti_bset[] IS INITIAL.
      IF p_test IS INITIAL.
        MODIFY bset FROM TABLE ti_bset.
      ENDIF.
      PERFORM mostrar_alv.
    ELSE.
      MESSAGE text-003 TYPE 'I'.
    ENDIF.
  else.
    MESSAGE text-003 TYPE 'I'.
  ENDIF.
