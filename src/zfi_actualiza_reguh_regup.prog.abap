*&---------------------------------------------------------------------*
*& Report  ZFI_ACTUALIZA_REGUH_REGUP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfi_actualiza_reguh_regup.

INCLUDE zfi_actualiza_reguh_regup_top.
INCLUDE zfi_actualiza_reguh_regup_sel.
INCLUDE zfi_actualiza_reguh_regup_rut.

DATA: laufd TYPE reguh-laufd VALUE '20130214',
      laufi TYPE reguh-laufi VALUE 'M2429'.

START-OF-SELECTION.
  g_repid = sy-repid.
  PERFORM cargar_archivo.
  IF NOT p_test IS INITIAL.
    PERFORM mostrar_alv.
  ELSE.
    IF NOT p_reguh IS INITIAL.
      MODIFY reguh FROM TABLE ti_reguh.
    ELSE.
      MODIFY regup FROM TABLE ti_regup.
    ENDIF.
    PERFORM mostrar_alv.
  ENDIF.
