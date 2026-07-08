*&---------------------------------------------------------------------*
*&  Include           ZSMB40FM06PF04
*&---------------------------------------------------------------------*
FORM get_customer_address USING    p_kunnr LIKE ekpo-kunnr
CHANGING p_adrnr.
* parameter P_ADRNR without type since there are several address
* fields with different domains

  DATA: l_adrnr LIKE kna1-adrnr.

  CHECK NOT p_kunnr IS INITIAL.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE adrnr FROM  kna1 INTO (l_adrnr)
*  WHERE  kunnr  = p_kunnr.
*
* NEW CODE
  SELECT adrnr
  UP TO 1 ROWS  FROM  kna1 INTO (l_adrnr)
  WHERE  kunnr  = p_kunnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
  IF sy-subrc EQ 0.
    p_adrnr = l_adrnr.
  ELSE.
    CLEAR p_adrnr.
  ENDIF.

ENDFORM.                    " GET_CUSTOMER_ADDRESS
