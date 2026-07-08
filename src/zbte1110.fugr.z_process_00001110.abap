FUNCTION Z_PROCESS_00001110.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_BUKRS) LIKE  BKPF-BUKRS
*"     VALUE(I_LIFNR) LIKE  BSEG-LIFNR
*"     VALUE(I_WAERS) LIKE  BKPF-WAERS
*"     VALUE(I_BLDAT) LIKE  BKPF-BLDAT
*"     VALUE(I_XBLNR) LIKE  BKPF-XBLNR
*"     VALUE(I_WRBTR) LIKE  BSEG-WRBTR OPTIONAL
*"     VALUE(I_BELNR) LIKE  BSEG-BELNR OPTIONAL
*"     VALUE(I_GJAHR) LIKE  BSEG-GJAHR OPTIONAL
*"     VALUE(I_BUZEI) LIKE  BSEG-BUZEI OPTIONAL
*"     VALUE(I_SHKZG) LIKE  BSEG-SHKZG
*"     VALUE(I_BLART) TYPE  BLART OPTIONAL
*"  EXPORTING
*"     VALUE(E_NOSTD) LIKE  BOOLE-BOOLE
*"----------------------------------------------------------------------
**"----------------------------------------------------------------------
  data ti_bsip type TABLE OF bsip.
  data wa_bsip type bsip.
  data v_blart type blart.
  data:  not_shkzg like bseg-shkzg.

  not_shkzg = i_shkzg.
  translate not_shkzg using 'SHHS'.
  "Variables para perform

 DATA: loc_stblg    LIKE bkpf-stblg,
       loc_stblg_mm LIKE bkpf-stblg,
       loc_subrc    LIKE sy-subrc,
       dop_rc       TYPE sysubrc,
       wa_bkpf      TYPE bkpf.

"AGREGADO 16.02.2015
"-----------------------------------------------------------------------------------------------
*------- Index für doppelte Rechnungen lesen ---------------------------
*        Rechnungen können in BSIP mit SHKZG 'H' und SPACE stehen,
*        da SHKZG neu in BSIP zu 4.0A
 if i_xblnr = space.

      SELECT * into wa_bsip
             from bsip
             where bukrs = i_bukrs
             and   lifnr = i_lifnr
             and   waers = i_waers
             and   xblnr = i_xblnr
             and   wrbtr = i_wrbtr
             and   bldat = i_bldat
             and   shkzg ne not_shkzg.

**     credit memos & invoice < 4.0
      check not ( i_shkzg = 'S' and wa_bsip-shkzg = space ).
*
* check if bsip refers to same document
      check not ( i_belnr = wa_bsip-belnr and
                  i_bukrs = wa_bsip-bukrs and
                  i_gjahr = wa_bsip-gjahr ) .

*  PERFORM
"---------------------------------------------------------------------------------------------------------
   CLEAR: loc_stblg, loc_stblg_mm , loc_subrc, dop_rc, wa_bkpf.

   SELECT SINGLE * INTO wa_bkpf
      FROM bkpf
      WHERE belnr = wa_bsip-belnr
      AND   bukrs = wa_bsip-bukrs
      AND   gjahr = wa_bsip-gjahr
      AND   blart = I_BLART.   " AGRGADO FGT

   loc_subrc = sy-subrc.

   IF wa_bkpf-awtyp = 'RMRP'.
* Check, if original MM document was reversed
    SELECT SINGLE stblg INTO loc_stblg_mm FROM rbkp
         WHERE belnr = wa_bkpf-awkey(10)
           AND gjahr = wa_bkpf-awkey+10.
   ELSE.
    loc_stblg = wa_bkpf-stblg.
   ENDIF.

  IF loc_subrc NE 0 OR loc_stblg NE space.
    dop_rc = 4.
  ELSEIF loc_stblg_mm NE space.
    CLEAR: sy-msgid, sy-msgty, sy-msgno.                    "Note781858
    CALL FUNCTION 'CUSTOMIZED_MESSAGE'
      EXPORTING
        i_arbgb = 'F5A'
        i_dtype = 'W'
        i_msgnr = '291'
        i_var01 = wa_bsip-belnr
        i_var02 = wa_bsip-gjahr.
    IF sy-msgid IS INITIAL.                                 "Note781858
      dop_rc = 4.                                           "Note781858
    ELSE.                                                   "Note781858
      dop_rc = 0.                                           "Note781858
    ENDIF.                                                  "Note781858
  ELSE.
    EXPORT wa_bsip-bukrs wa_bsip-belnr wa_bsip-gjahr TO MEMORY ID 'BSIP_DOC'.
    CALL FUNCTION 'CUSTOMIZED_MESSAGE'
      EXPORTING
        i_arbgb = 'F5'
        i_dtype = 'W'
        i_msgnr = '117'
        i_var01 = wa_bsip-bukrs                          "Note885212
        i_var02 = wa_bsip-belnr                          "Note885212
        i_var03 = wa_bsip-gjahr.                         "Note885212
*del    i_var01 = bsip-belnr                          "Note885212
*del    i_var02 = bsip-gjahr.              "Note604428 Note885212
        dop_rc = 0.
    FREE MEMORY ID 'BSIP_DOC'.                              "Note 546071
   ENDIF.

"----------------------------------------------------------------------------------------------
""ENDFORM.
      check dop_rc = 0.
      exit.
      ENDSELECT.

 ELSE.

     SELECT * into wa_bsip
             from bsip
             where bukrs = i_bukrs
             and   lifnr = i_lifnr
             and   waers = i_waers
             and   xblnr = i_xblnr
             and   bldat = i_bldat
             and   shkzg ne not_shkzg.

*     credit memos & invoice < 4.0
      check not ( i_shkzg = 'S' and wa_bsip-shkzg = space ).


* check if bsip refers to same document
      check not ( i_belnr = wa_bsip-belnr and
                  i_bukrs = wa_bsip-bukrs and
                  i_gjahr = wa_bsip-gjahr ) .

" perform doppelte_belege_pruefen_s using rc.
*  PERFORM
"---------------------------------------------------------------------------------------------------------
   CLEAR: loc_stblg, loc_stblg_mm , loc_subrc, dop_rc, wa_bkpf.

     SELECT SINGLE * INTO wa_bkpf
      FROM bkpf
      WHERE belnr = wa_bsip-belnr
      AND   bukrs = wa_bsip-bukrs
      AND   gjahr = wa_bsip-gjahr
      AND   blart = I_BLART.   " AGRGADO FGT

     loc_subrc = sy-subrc.

   IF wa_bkpf-awtyp = 'RMRP'.
* Check, if original MM document was reversed
    SELECT SINGLE stblg INTO loc_stblg_mm FROM rbkp
         WHERE belnr = wa_bkpf-awkey(10)
           AND gjahr = wa_bkpf-awkey+10.
   ELSE.
    loc_stblg = wa_bkpf-stblg.
   ENDIF.

  IF loc_subrc NE 0 OR loc_stblg NE space.
    dop_rc = 4.
  ELSEIF loc_stblg_mm NE space.
    CLEAR: sy-msgid, sy-msgty, sy-msgno.                    "Note781858
    CALL FUNCTION 'CUSTOMIZED_MESSAGE'
      EXPORTING
        i_arbgb = 'F5A'
        i_dtype = 'W'
        i_msgnr = '291'
        i_var01 = wa_bsip-belnr
        i_var02 = wa_bsip-gjahr.
    IF sy-msgid IS INITIAL.                                 "Note781858
      dop_rc = 4.                                           "Note781858
    ELSE.                                                   "Note781858
      dop_rc = 0.                                           "Note781858
    ENDIF.                                                  "Note781858
  ELSE.
    EXPORT wa_bsip-bukrs wa_bsip-belnr wa_bsip-gjahr TO MEMORY ID 'BSIP_DOC'.
    CALL FUNCTION 'CUSTOMIZED_MESSAGE'
      EXPORTING
        i_arbgb = 'F5'
        i_dtype = 'W'
        i_msgnr = '117'
        i_var01 = wa_bsip-bukrs                          "Note885212
        i_var02 = wa_bsip-belnr                          "Note885212
        i_var03 = wa_bsip-gjahr.                         "Note885212
*del    i_var01 = bsip-belnr                          "Note885212
*del    i_var02 = bsip-gjahr.              "Note604428 Note885212
        dop_rc = 0.
    FREE MEMORY ID 'BSIP_DOC'.               "Note 546071
   ENDIF.

""----------------------------------------------------------------------------------------------
""ENDFORM.
      check dop_rc = 0.
      exit.
     ENDSELECT.

ENDIF.

 E_NOSTD = 'X'.


" COMENTADO 16.02.2015
*  CLEAR: ti_bsip.
*  SELECT *
*  INTO CORRESPONDING FIELDS OF TABLE ti_bsip
*  FROM bsip
*  WHERE bukrs = i_bukrs
*  AND   lifnr = i_lifnr
*  AND   waers = i_waers
*  AND   xblnr = i_xblnr
*  AND   bldat = i_bldat
*  AND   shkzg NE not_shkzg.
*
*  LOOP AT ti_bsip into wa_bsip.
*
**    check not ( i_shkzg = 'S' and wa_bsip-shkzg = space ).  " agregado 16.02.2015
*    SELECT SINGLE blart
*    INTO v_blart
*    FROM  bkpf
*    WHERE belnr = wa_bsip-belnr
*    AND   bukrs = wa_bsip-bukrs
*    AND   gjahr = wa_bsip-gjahr
*    And   STBLG = ''.  " Agregado 16.02.2015
*
*    IF i_blart EQ v_blart.
*
*      EXPORT wa_bsip-bukrs wa_bsip-belnr wa_bsip-gjahr TO MEMORY ID 'BSIP_DOC'.
*      CALL FUNCTION 'CUSTOMIZED_MESSAGE'
*      EXPORTING
*        i_arbgb = 'F5'
*        i_dtype = 'W'
*        i_msgnr = '117'
*        i_var01 = wa_bsip-bukrs                          "Note885212
*        i_var02 = wa_bsip-belnr                          "Note885212
*        i_var03 = wa_bsip-gjahr.                         "Note885212
*
*      FREE MEMORY ID 'BSIP_DOC'.
*    ENDIF.
*    clear v_blart.
*  ENDLOOP.
*
*E_NOSTD = 'X'.


ENDFUNCTION.
