*&---------------------------------------------------------------------*
*& Report  ZFI_COMPENSACIONES
*&
*&---------------------------------------------------------------------*
*& Descripción: Realizar compensaciones a traves de la F-53 a partir
*& de los datos de la reguh y regup cuyos documentos de pago no se
*& generaron por un error en la BSEG (ACTUALIZACION INTERRUMPIDA.)
*&---------------------------------------------------------------------*

REPORT  zfi_compensaciones.

INCLUDE zfi_compensaciones_top.
INCLUDE zfi_compensaciones_sel.
INCLUDE zfi_compensaciones_rut.

START-OF-SELECTION.
  g_repid = sy-cprog.
  PERFORM obtener_datos.
  IF NOT ti_reguh[] IS INITIAL.
    IF NOT p_test IS INITIAL.
      PERFORM mostrar_alv.
    ELSE.
      PERFORM ejecutar_batch.
      IF NOT ti_log[] IS INITIAL.
        PERFORM mostrar_log.
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE 'No se encontraron datos para procesar' TYPE 'I'.
  ENDIF.
