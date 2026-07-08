FORM zconvert_amount_to_print
CHANGING p_betrg
  l_betan.

  DATA: l_betrg(17) TYPE C.
  WRITE p_betrg TO l_betrg CURRENCY 'CLP'.
  MOVE l_betrg TO l_betan.

ENDFORM.






















