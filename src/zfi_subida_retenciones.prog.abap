*&---------------------------------------------------------------------*
*& Report  ZFI_SUBIDA_RETENCIONES
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfi_subida_retenciones.

INCLUDE zfi_subida_retenciones_top.
INCLUDE zfi_subida_retenciones_sel.
INCLUDE zfi_subida_retenciones_rut.

START-OF-SELECTION.
  g_repid = sy-repid.
  PERFORM bajar_archivo.
  IF NOT ti_entrada[] IS INITIAL.
    PERFORM llenar_tabla.
    IF NOT ti_with_item[] IS INITIAL.
      IF p_test IS INITIAL.
        MODIFY with_item FROM TABLE ti_with_item.
      ENDIF.
      PERFORM mostrar_alv.
    ELSE.
      MESSAGE text-003 TYPE 'I'.
    ENDIF.
  ELSE.
    MESSAGE text-003 TYPE 'I'.
  ENDIF.
