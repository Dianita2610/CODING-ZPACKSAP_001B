*&---------------------------------------------------------------------*
*& Report  zfibi_001
*&
*&---------------------------------------------------------------------*
*& Autor: Julio Sosa
*& Empresa : Visionone
*& Fecha : 07.12.2013
*& Descompensación masiva desde la FBRA mediante batch input.
*&---------------------------------------------------------------------*
*& Autor: Julio Sosa
*& Empresa : Visionone
*& Fecha : 14.01.2014
*& Ahora por parametro se puede Descompensar o Descompensar y anular.
*&---------------------------------------------------------------------*

REPORT  zfibi_001.

INCLUDE zfibi_001_top.
INCLUDE zfibi_001_sel.
INCLUDE zfibi_001_rut.

START-OF-SELECTION.
  g_repid = sy-repid.
  PERFORM obtener_datos.
  IF NOT p_test IS INITIAL.
    PERFORM mostrar_alv.
  ELSE.
    IF NOT t_log[] IS INITIAL.
      PERFORM display_log.
    ENDIF.
  ENDIF.
