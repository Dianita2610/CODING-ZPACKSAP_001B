*&---------------------------------------------------------------------*
*& Report  ZFI_CARGA_CHEQUES
*&
*&---------------------------------------------------------------------*
*& Autor: Julio Sosa
*& Fecha : 19.02.2013
*& Empresa : Visionone
*& Descripcion: Batch input a la fch5 a partir de un archivo txt
*&---------------------------------------------------------------------*

REPORT  zfi_carga_cheques.

INCLUDE zfi_carga_cheques_top.
INCLUDE zfi_carga_cheques_sel.
INCLUDE zfi_carga_cheques_rut.

START-OF-SELECTION.
* -> Tratamiento Archivo de Entrada
  IF NOT p_local IS INITIAL
 AND p_file IS INITIAL.
    MESSAGE s398(00) WITH 'Favor ingresar fichero' DISPLAY LIKE 'E'.
    EXIT.
  ELSEIF NOT p_serv IS INITIAL
   AND servidor IS INITIAL.
    MESSAGE s398(00) WITH 'Favor ingresar fichero' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  PERFORM input_local.
  IF NOT ti_entrada[] IS INITIAL.
    PERFORM procesar_datos.
    IF NOT ti_log[] IS INITIAL.
      PERFORM mostrar_log.
    ELSE.
      MESSAGE i398(00) WITH text-002.
    ENDIF.
  ELSE.
    MESSAGE i398(00) WITH text-002.
  ENDIF.
