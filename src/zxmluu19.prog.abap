*&---------------------------------------------------------------------*
*&  Include           ZXMLUU19
*&---------------------------------------------------------------------*

DATA: lv_ebelp TYPE ekpo-ebelp.

CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
  EXPORTING
    input  = i_ekpo-ebelp
  IMPORTING
    output = lv_ebelp.

CONCATENATE i_ekpo-ebeln lv_ebelp INTO c_essr-xblnr.
