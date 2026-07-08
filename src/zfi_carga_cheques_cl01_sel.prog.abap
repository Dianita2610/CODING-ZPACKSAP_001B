*&---------------------------------------------------------------------*
*&  Include           ZFI_CARGA_CHEQUES_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.

PARAMETER: p_local RADIOBUTTON GROUP a1 DEFAULT 'X' USER-COMMAND cmd,
           p_serv RADIOBUTTON GROUP a1.
SELECTION-SCREEN END   OF BLOCK bl1.

sELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-003.
PARAMETER: p_file LIKE rlgrap-filename modif id a1,
*           p_gjahr type bkpf-gjahr DEFAULT 2013 OBLIGATORY modif id a1,
           servidor  LIKE rlgrap-filename MODIF ID b1
           DEFAULT '/interfaces/paso/asientos' .
SELECTION-SCREEN end of BLOCK bl2.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = p_file
      def_path         = 'c:\'
      mask             = ',*.*,*.*.'
      mode             = 'O'
      title            = 'Directorio de Datos'
    IMPORTING
      filename         = p_file
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
