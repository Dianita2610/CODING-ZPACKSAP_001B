*&---------------------------------------------------------------------*
*& Report  ZFI_RUT_TERCEROS
*&
*&---------------------------------------------------------------------*
*& Autor: Julio Sosa
*& Fecha: 05.03.2013
*& Descripción: Batch input a la FB02 para corregir los rut de terceros
*&---------------------------------------------------------------------*

REPORT  zfi_rut_terceros.

INCLUDE zfi_rut_terceros_top.
INCLUDE zfi_rut_terceros_sel.
INCLUDE zfi_rut_terceros_rut.

START-OF-SELECTION.
  g_repid = sy-cprog.
  PERFORM obtener_datos.
  IF NOT ti_salida[] IS INITIAL.
    IF p_test IS INITIAL.
      PERFORM ejecutar.
    ENDIF.
    PERFORM mostrar_alv.
  ELSE.
    MESSAGE text-002 TYPE 'I'.
  ENDIF.
