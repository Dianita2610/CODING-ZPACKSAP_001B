*&---------------------------------------------------------------------*
*& Report  Z_DEPRECIACION_PRE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  z_depreciacion_pre.

TABLES: anlc.
**mod ini
*DATA: BEGIN OF xanlc OCCURS 0.
*        INCLUDE STRUCTURE anlc.
*DATA: END OF xanlc.
DATA: xanlc TYPE STANDARD TABLE OF anlc WITH HEADER LINE.
**mod fin
DATA: ld_current_fyr LIKE anlc-gjahr.
DATA: hlp_knafa LIKE anlc-knafa.
DATA: hlp_ksafa LIKE anlc-ksafa.
DATA: hlp_kaafa LIKE anlc-kaafa.

START-OF-SELECTION.
** Generate selectionscreen with question to
* ask if this is a test or reality
  SELECTION-SCREEN BEGIN OF BLOCK test
                   WITH FRAME TITLE scrtit.
  PARAMETERS: pa_bukrs LIKE anlc-bukrs.
  SELECTION-SCREEN COMMENT /1(60) scrcomm1.

  PARAMETERS: pa_abjhr LIKE anlc-gjahr.
  SELECTION-SCREEN COMMENT /1(60) scrcomm2.

  PARAMETERS: pa_afabe LIKE anlc-afabe.
  SELECTION-SCREEN COMMENT /1(60) scrcomm3.

  PARAMETERS pa_test AS CHECKBOX DEFAULT 'X'.
  SELECTION-SCREEN COMMENT /1(60) scrcomm5.
  SELECTION-SCREEN END OF BLOCK test.

*IF pa_test IS INITIAL.                                        "> 697094
*  PERFORM open_schedman.                                      "> 697094
*ENDIF.                                                        "> 697094

INITIALIZATION.

  MOVE 'Repair assets with wrong planned depr. in closed fiscal year'
        TO scrtit.
  MOVE 'Company Code!' TO scrcomm1.
  MOVE 'Last closed fiscal year to repair!' TO scrcomm2.
  MOVE 'Depreciation area containing wrong planned depreciation!'
    TO scrcomm3.
  MOVE 'If test is checked database won''t be altered'
    TO scrcomm5.

END-OF-SELECTION.


* Select all entries in table ANLC for the selection options, where the
*   planned and the posted depreciation differs.
**mod ini
****  EXEC SQL  PERFORMING XANLC_APPEND.
****    SELECT * FROM ANLC INTO :XANLC
****       WHERE MANDT = :SY-MANDT
****         AND BUKRS = :PA_BUKRS
****         AND GJAHR = :PA_ABJHR
****         AND AFABE = :PA_AFABE
****         AND ( NAFAP <> NAFAG
****          OR   SAFAP <> SAFAG
****          OR   AAFAP <> AAFAG  )
****  ENDEXEC.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT *
*  FROM anlc
*  INTO TABLE xanlc
*  WHERE bukrs = pa_bukrs
*    AND gjahr = pa_abjhr
*    AND afabe = pa_afabe.
*
* NEW CODE
SELECT *

  FROM anlc
  INTO TABLE xanlc
  WHERE bukrs = pa_bukrs
    AND gjahr = pa_abjhr
    AND afabe = pa_afabe ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03
**mod fin
LOOP AT xanlc.
  IF xanlc-nafap = xanlc-nafag AND
     xanlc-safap = xanlc-safag AND
     xanlc-aafap = xanlc-aafag.
    DELETE xanlc.
  ENDIF.
ENDLOOP.
  WRITE:/ 'Assetno.  '(001), 'Subno'(002),
          '    Ord.Dep. planed'(003), 'Ord.Dep. posted'(004),
          '    Spec.Dep planed'(005), 'Spec.Dep posted'(006),
          '    Unpl.Dep planed'(007), 'Unpl.Dep posted'(008).
  ULINE.
* Current fiscal year is the last fiscal year + 1.
  ld_current_fyr = pa_abjhr + 1.
  LOOP AT xanlc.
    WRITE:/ xanlc-anln1, xanlc-anln2, xanlc-nafap, xanlc-nafag,
                                      xanlc-safap, xanlc-safag,
                                      xanlc-aafap, xanlc-aafag.
*   Update database if checkbox "Test" is not checked.
    IF pa_test IS INITIAL.
*     Set the planned to the posted values:
      UPDATE anlc
        SET  nafap = xanlc-nafag
             safap = xanlc-safag
             aafap = xanlc-aafag
       WHERE bukrs = xanlc-bukrs
         AND anln1 = xanlc-anln1
         AND anln2 = xanlc-anln2
         AND gjahr = xanlc-gjahr
         AND afabe = xanlc-afabe.

*     Correct the cumulative depreciation of the current fiscal year
      hlp_knafa = xanlc-nafap - xanlc-nafag.
      hlp_ksafa = xanlc-safap - xanlc-safag.
      hlp_kaafa = xanlc-aafap - xanlc-aafag.
**mod ini
****      EXEC SQL.
****        UPDATE ANLC
****          SET  KNAFA = KNAFA - :HLP_KNAFA ,
****               KSAFA = KSAFA - :HLP_KSAFA ,
****               KAAFA = KAAFA - :HLP_KAAFA
****         WHERE MANDT = :XANLC-MANDT
****           AND BUKRS = :XANLC-BUKRS
****           AND ANLN1 = :XANLC-ANLN1
****           AND ANLN2 = :XANLC-ANLN2
****           AND GJAHR = :ld_current_fyr
****           AND AFABE = :XANLC-AFABE
****      ENDEXEC.
     UPDATE anlc
     SET knafa = knafa - @hlp_knafa,
           ksafa = ksafa - @hlp_ksafa,
           kaafa = kaafa - @hlp_kaafa
     WHERE bukrs = @xanlc-bukrs
       AND anln1 = @xanlc-anln1
       AND anln2 = @xanlc-anln2
       AND gjahr = @ld_current_fyr
       AND afabe = @xanlc-afabe.
**mod fin
      COMMIT WORK.
    ENDIF. "pa_test IS INITIAL
  ENDLOOP.

*PERFORM close_schedman USING ' '.                    "> 697094 / 871778
*INCLUDE RACORR_SCHEDMAN.                                      "> 697094
**comment ini
**FORM xanlc_append.
** APPEND xanlc.
**ENDFORM.                    "xanlc_append
**comment fin
