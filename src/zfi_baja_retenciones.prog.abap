*&---------------------------------------------------------------------*
*& Report  ZFI_BAJA_RETENCIONES
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfi_baja_retenciones.

INCLUDE zfi_baja_retenciones_top.

SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_bukrs FOR bkpf-bukrs OBLIGATORY,
                s_belnr FOR bkpf-belnr,
                s_gjahr FOR bkpf-gjahr,
                s_budat FOR bkpf-budat,
                s_blart FOR bkpf-blart.

PARAMETER: fichero TYPE string OBLIGATORY.
SELECTION-SCREEN END OF BLOCK a1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR fichero.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = fichero
      def_path         = 'c:\'
      mask             = ',*.*,*.*.'
      mode             = 'S'
      title            = 'Directorio de Datos'
    IMPORTING
      filename         = fichero
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.
if sy-subrc eq 0.
  if not fichero cs '.txt'.
     concatenate fichero '.txt' into fichero.
  endif.
endif.

INCLUDE zfi_baja_retenciones_rut.

START-OF-SELECTION.
  g_repid = sy-repid.
  PERFORM obtener_datos.
  IF ti_salida[] IS INITIAL.
    MESSAGE text-002 TYPE 'I'.
  ELSE.
    PERFORM mostrar_alv.
  ENDIF.
