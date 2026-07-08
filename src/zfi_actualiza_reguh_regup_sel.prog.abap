*&---------------------------------------------------------------------*
*&  Include           ZFI_ACTUALIZA_REGUH_REGUP_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
PARAMETER: p_reguh RADIOBUTTON GROUP a1 DEFAULT 'X',
           p_regup RADIOBUTTON GROUP a1.
SELECTION-SCREEN END   OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE text-003.
PARAMETER:    fichero LIKE rlgrap-filename MODIF ID a1
              DEFAULT 'C:\',
              p_test as checkbox default 'X'.

SELECTION-SCREEN END   OF BLOCK bl3.

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
