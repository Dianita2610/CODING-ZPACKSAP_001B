*&---------------------------------------------------------------------*
*&  Include           ZSMB40FM06PF04
*&---------------------------------------------------------------------*
FORM get_customer_address USING    p_kunnr LIKE ekpo-kunnr
CHANGING p_adrnr.
* parameter P_ADRNR without type since there are several address
* fields with different domains

  DATA: l_adrnr LIKE kna1-adrnr.

  CHECK NOT p_kunnr IS INITIAL.
  SELECT SINGLE adrnr FROM  kna1 INTO (l_adrnr)
  WHERE  kunnr  = p_kunnr.
  IF sy-subrc EQ 0.
    p_adrnr = l_adrnr.
  ELSE.
    CLEAR p_adrnr.
  ENDIF.

ENDFORM.                    " GET_CUSTOMER_ADDRESS
