*&---------------------------------------------------------------------*
*&  Include           ZFI_SUBIDA_RETENCIONES_SEL
*&---------------------------------------------------------------------*
* Definición de Parámetros.
* -------------------------
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.

PARAMETER: p_local RADIOBUTTON GROUP a1 DEFAULT 'X' USER-COMMAND cmd,
           p_serv RADIOBUTTON GROUP a1.
SELECTION-SCREEN END   OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE text-001.
SELECT-OPTIONS : s_bukrs for bkpf-bukrs,
                 s_belnr for bkpf-belnr,
                 s_gjahr for bkpf-gjahr.
SELECTION-SCREEN END   OF BLOCK bl3.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
PARAMETER:    fichero LIKE rlgrap-filename MODIF ID a1
              DEFAULT 'C:\Asiento_GL.txt',
              servidor  LIKE rlgrap-filename MODIF ID b1
              DEFAULT '/interfaces/paso/asientos' ,
              p_test as checkbox.

SELECTION-SCREEN END   OF BLOCK bl2.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR fichero.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = fichero
      def_path         = 'c:\'
      mask             = ',*.*,*.*.'
      mode             = 'O'
      title            = 'Directorio de Datos'
    IMPORTING
      filename         = fichero
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.


AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 EQ 'A1'.
      IF NOT p_local IS INITIAL.
        screen-active = 1.
      ELSE.
        screen-active = 0.
      ENDIF.
    ELSEIF screen-group1 EQ 'B1'.
      IF NOT p_local IS INITIAL.
        screen-active = 0.
      ELSE.
        screen-active = 1.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
