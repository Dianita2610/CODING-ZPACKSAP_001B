FUNCTION ZZMIGO_CUST_DYNP_VALIDAR.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  EXPORTING
*"     VALUE(ERROR) TYPE  CHAR1
*"----------------------------------------------------------------------
  CLEAR error.

  IF arbpl IS INITIAL.
    error = 'X'.
  ENDIF.

  IF SHIFT IS INITIAL.
    error = 'X'.
  ENDIF.




ENDFUNCTION.
