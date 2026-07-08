FUNCTION ZMIGO_BADI_EXAMPLE_PUT_DATA.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(IS_MIGO_BADI_SCREEN_FIELDS) TYPE
*"        MIGO_BADI_EXAMPLE_SCREEN_FIELD
*"----------------------------------------------------------------------


MOVE-CORRESPONDING is_migo_badi_screen_fields TO migo_badi_header.


ENDFUNCTION.
