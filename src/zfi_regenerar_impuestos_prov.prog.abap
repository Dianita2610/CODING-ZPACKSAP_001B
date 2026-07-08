*&---------------------------------------------------------------------*
*& Report  ZFI_REGENERAR_IMPUESTOS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfi_regenerar_impuestos_prov.

INCLUDE zfi_regenerar_prov_top.
INCLUDE zfi_regenerar_prov_sel.
INCLUDE zfi_regenerar_prov_rut.

START-OF-SELECTION.
  g_repid = sy-repid.
  PERFORM bajar_archivo.
  IF NOT ti_entrada[] IS INITIAL.
    PERFORM obtener_datos.
    IF NOT ti_bset IS INITIAL.
      IF p_test IS INITIAL.
        MODIFY bset FROM TABLE ti_bset.
      ENDIF.
      PERFORM mostrar_alv.
    ELSE.
      MESSAGE text-002 TYPE 'I'.
    ENDIF.
  ELSE.
    MESSAGE text-002 TYPE 'I'.
  ENDIF.
