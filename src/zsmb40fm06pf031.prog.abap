*&---------------------------------------------------------------------*
*&  Include           ZSMB40FM06PF031
*&---------------------------------------------------------------------*
FORM get_plant_address USING    p_werks LIKE t001w-werks
CHANGING p_adrnr
  p_sadr  LIKE sadr.
* parameter P_ADRNR without type since there are several address
* fields with different domains

  DATA: l_ekko LIKE ekko,
        l_address LIKE addr1_val.

  CHECK NOT p_werks IS INITIAL.
  l_ekko-reswk = p_werks.
  l_ekko-bsakz = 'T'.
  CALL FUNCTION 'MM_ADDRESS_GET'
  EXPORTING
    i_ekko    = l_ekko
  IMPORTING
    e_address = l_address
    e_sadr    = p_sadr.
  p_adrnr = l_address-addrnumber.

ENDFORM.                    " GET_PLANT_ADDRESS
