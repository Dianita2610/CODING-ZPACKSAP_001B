*&---------------------------------------------------------------------*
*& Report  ZFIR002
*&---------------------------------------------------------------------*
*& Autor : Julio Sosa
*& Empresa : Visionone
*& Transacción : ZFIR002
*& Fecha : 10.09.2012
*& Descripcion: Compensación automatica masiva de deudores por la F-32
*& Se dejará corriendo un job en forma diaria para ello.
*&---------------------------------------------------------------------*
*& Historial de Modificaciones :
*&
*& Autor :      Julio Sosa
*& Empresa :    VisionOne.
*& Fecha :      01.08.2014
*& Descripcion: Corrige algoritmo de compensación
*&---------------------------------------------------------------------*
REPORT  zfir002.

INCLUDE zfir002_top.
INCLUDE zfir002_sel.
INCLUDE zfir002_rut.

*--------------------------------------------------------------------*
*                   START-OF-SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.

  IF p_budat IS INITIAL.
    p_budat = sy-datum. "Fecha contable = Fecha del día
  ENDIF.

  g_repid = sy-repid.
  PERFORM obtener_datos.

  IF NOT ti_salida[] IS INITIAL.
    IF p_pas IS NOT INITIAL.
      PERFORM mostrar_alv.
    ELSE.
*     Compensamos
      PERFORM compensar.
      IF NOT t_log[] IS INITIAL.
        PERFORM display_log .
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE text-001 TYPE 'I'.
  ENDIF.
