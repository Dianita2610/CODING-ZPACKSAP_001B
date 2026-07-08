*&---------------------------------------------------------------------*
*& Report  ZFI_ACTUALIZA_REGUH
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfi_actualiza_reguh.

INCLUDE zfi_actualiza_reguh_top.
INCLUDE zfi_actualiza_reguh_sel.
INCLUDE zfi_actualiza_reguh_rut.

START-OF-SELECTION.
  g_repid = sy-repid.
  PERFORM bajar_archivo.
  IF NOT ti_salida[] IS INITIAL.
    PERFORM buscar_datos.
    IF NOT ti_reguh[] IS INITIAL.
      IF p_test IS INITIAL.
        MODIFY reguh FROM TABLE ti_reguh.
      ENDIF.
      PERFORM mostrar_alv.
    ELSE.
      MESSAGE text-003 TYPE 'I'.
    ENDIF.
  ELSE.
    MESSAGE text-003 TYPE 'I'.
  ENDIF.
