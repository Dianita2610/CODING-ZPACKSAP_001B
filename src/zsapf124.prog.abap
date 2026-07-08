*-----------------------------------------------------------------------
*      FI - Maschinelles Ausgleichen
*-----------------------------------------------------------------------
*
REPORT zsapf124 LINE-SIZE 132 NO STANDARD PAGE HEADING MESSAGE-ID fg.

INCLUDE f124top.
INCLUDE inclf124.           "general constants
INCLUDE f124_auslaufende_waehrung_mf01.
INCLUDE f124_check_payment_methodf01.
INCLUDE f124_set_global_flagsf01.
INCLUDE f124_detail_list.   "Data and form routines for the detail list
INCLUDE f124_short_list.    "Data and form routines for the short list
INCLUDE f124_logs.          "Data and form routines for the logs
INCLUDE zf124_merge.         "Main subroutines
*------------------------------------------Initilization----------------
INITIALIZATION.
*  gd_repid = sy-repid.
  bhdgd-inifl = '0'.
  bhdgd-lines = sy-linsz.              " Zeilenbreite aus Report
  bhdgd-uname = sy-uname.              " Benutzername
  bhdgd-repid = sy-repid.              " Name des ABAP-Programmes
  bhdgd-line1 = sy-title.              " Titel des ABAP-Programmes
  bhdgd-separ = space.                 " Keine Listseparation
  PERFORM set_info_icon.               " Info Icon will be set.
  PERFORM fill_xf123_if123.

*------------------------------------------At selection-screen output-------------
AT SELECTION-SCREEN OUTPUT.
  bsis-waers = zwaers.

*----------------- Load screen depending on the selected clearing method-----------------------
*-----------------Not Parked in Enhancementpackage --------------------------------------------
*-----------------Cause: MODIF ID works not correctly with Enhancement ------------------------
  PERFORM modif_screen_cl.


AT SELECTION-SCREEN.

* Checks only when not multiple selection choosen
  CHECK NOT ( sy-ucomm CP '%0++' ).
  PERFORM call_f1_help.
  CHECK NOT ( sy-ucomm EQ 'FC01').
* Check parameters
  PERFORM check_xfield.
  PERFORM check_bukrs.
  PERFORM gjvtab_init.
  PERFORM check_authority.
  PERFORM check_augdt.

  IF NOT augdt IS INITIAL.
    PERFORM gjvtab_check.
    monat = bmonat.
    LOOP AT i001.
      CHECK i001-bukrs IN bukrx.
      CLEAR gejahr.
*     Ignore company codes without fiscal year variant
      CHECK i001-periv NE space.
*     Ignore company codes without variant for posting periods
      CHECK i001-opvar NE space.
*     Determine posting period
      PERFORM periode_ermitteln USING i001-bukrs
                                      augdt
                                      gejahr
                                      monat.                    "1121415
      IF NOT bmonat IS INITIAL                                  "1121415
      AND    monat NE bmonat.
        MESSAGE w000 WITH i001-bukrs bmonat augdt monat.        "1121415
      ENDIF.
*     check posting period
      PERFORM periode_pruefen USING i001-bukrs
                                    augdt
                                    gejahr
                                    monat                       "1121415
                                    'X'.                        "1112148
      IF zwaers NE space.
        CALL FUNCTION 'CURRENCY_EXPIRATION_CHECK'
          EXPORTING
            currency         = zwaers
            date             = augdt
            object           = 'BKPF'
            bukrs            = i001-bukrs
          EXCEPTIONS
            warning_occurred = 1
            error_occurred   = 2.
        IF sy-subrc = 1.
          MESSAGE w895(fg) WITH zwaers i001-bukrs.
        ELSEIF sy-subrc = 2.
          MESSAGE e895(fg) WITH zwaers i001-bukrs.
        ENDIF.
      ENDIF.
    ENDLOOP.
                                                                "1121415
  ENDIF.
  IF xauslw = 'X'.
    CALL FUNCTION 'CURRENCY_CHECK_FOR_PROCESS'
      EXPORTING
        process                = 'SAPF124E'
      EXCEPTIONS
        process_not_maintained = 1.
    IF sy-subrc <> 0.
      MESSAGE i896(fg).
    ENDIF.
  ENDIF.
* determine GR/IR and cash discount clearing accounts
  IF x_saknr = 'X'.
    PERFORM select_t030.
  ENDIF.
* customizing in TF123 maintained?
  PERFORM check_rules.
* Warning at update run
  PERFORM check_echtl.
* Determine list format
  PERFORM init_list.
*------------------------------------------At selection-screen on Zwaers
AT SELECTION-SCREEN ON zwaers.
  PERFORM check_waehrung.
*------------------------------------------Start-of-selection-----------
START-OF-SELECTION.
  CLEAR bsis-waers.
* Check for enqueues in REGUS                                    "681786
  PERFORM regus_pruefen.                                    "681786
* keep start time
  PERFORM acc_init_log.
  Perform Start_schedman.                                       "1081370
  Commit work.                                                  "1081370
  PERFORM set_global_flags.
  IF xauslw = 'X'.
*   principal check for expiring currencies
    PERFORM currency_check_for_process.
  ENDIF.
* Fill TDEBI, TKREDI, TSAKO
  PERFORM kontotabellen_fuellen.
* process customer accounts
  PERFORM debi_verarbeiten.
* process vendor accounts
  PERFORM kredi_verarbeiten.
* process GL accounts
  PERFORM sako_verarbeiten.
  Perform End_schedman.                                         "1081370
  Commit work.                                                  "1081370
  IF flg_liste = '2'.
*   write total
    PERFORM ausgabe_gesamtsumme.
  ENDIF.
*------------------------------------------End-of-selection-------------
END-OF-SELECTION.
  IF flg_liste = char_2.
**comment
*   short list
**    PERFORM acc_ausgabe_statistik.
  ELSE.
*   detailed list
**comment
**    PERFORM acc_ausgabe_detailliste.
  ENDIF.

  INCLUDE f124_modif_screen_clf01.

*INCLUDE F124_F01.

  INCLUDE f124_set_info_iconf01.
