FUNCTION zzmigo_cust_dynp_get.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_MATNR) TYPE  MATNR
*"     REFERENCE(I_BUKRS) TYPE  BUKRS
*"     REFERENCE(I_LINE_ID) TYPE  MB_LINE_ID
*"  EXPORTING
*"     VALUE(VAR) TYPE  CHAR1
*"  TABLES
*"      ET_MSEG STRUCTURE  ZZMIGO_POSICION
*"----------------------------------------------------------------------

*--------------------------------------------------------------------*
*  se valida el tipo de material.
*--------------------------------------------------------------------*
  DATA : v_mtart TYPE mara-mtart.
  CLEAR: v_mtart, var.

  SELECT SINGLE mtart
    INTO v_mtart
    FROM mara
    WHERE matnr EQ i_matnr.

  IF v_mtart EQ 'ZSSV' OR v_mtart EQ 'ZREA' OR
     v_mtart EQ 'ZPRO' OR v_mtart EQ 'ZAFI'.

    READ TABLE gt_mseg into gs_mseg WITH KEY line_id = i_line_id.
    IF gs_mseg-zzunid_pro IS INITIAL.
 "     message e016(z1) with 'EL CAMPO UNID/PRO' 'NO VALIDO  LINEA' i_line_id.

    ELSE.
      SELECT SINGLE * FROM zunid_prod
                      WHERE bukrs = i_bukrs
                      AND  zzcod_unidad = gs_mseg-zzunid_pro.
      IF sy-subrc = 0.
        var = 'X'.
      ELSE.
      message e016(z1) with 'EL CAMPO UNID/PRO' 'NO EXSITE  LINEA' i_line_id.
      ENDIF.
    ENDIF.
  ENDIF.
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*

  et_mseg[] = gt_mseg[].



ENDFUNCTION.
