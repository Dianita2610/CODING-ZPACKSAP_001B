*&---------------------------------------------------------------------*
*&  Include           SAPF124_MERGE
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
*---------- Füllen der internen Tabelle IF123 --------------------------
*---------- mit den Werten der Regeltabelle TF123 ----------------------
*---------- und den Tabellennamen, die zu den Regeln gehören -----------
*-----------------------------------------------------------------------
FORM fill_xf123_if123.
  SELECT * FROM tf123 INTO TABLE xf123.                 "#EC CI_NOWHERE
  PERFORM fill_if123.
  PERFORM itext_ergaenzen.
  SORT itext BY kritx.
ENDFORM.                    "fill_xf123_if123
*-----------------------------------------------------------------------
FORM fill_if123.
  LOOP AT xf123.
    MOVE-CORRESPONDING xf123 TO if123.
    IF if123-kont2 EQ space.
      if123-kont2 = if123-kont1.
    ENDIF.
    PERFORM fill_tablx
            USING xf123-koart.
*----- Währungsfelder aus TF123 merken ---------------------------------
    PERFORM fill_dfiestab.
    APPEND if123.
  ENDLOOP.
ENDFORM.                                                    "FILL_IF123
*-----------------------------------------------------------------------
*           FORM FILL_TABLX
*-----------------------------------------------------------------------
*---------- Füllen der Felder IF123-TABLx (x=1-4); ---------------------
*---------- falls Konto in Index-Tabelle und Felder aus Index-Tabelle --
*---------- werden die Felder mit TABELLE gefüllt, ---------------------
*---------- sonst werden die entsprechenden Tabellen -------------------
*---------- (BKPF, BSEG ...) gesucht. ----------------------------------
*-----------------------------------------------------------------------
FORM fill_tablx
     USING koart LIKE bseg-koart.
  DATA: bedng LIKE tf123-bedg1,
        table LIKE if123-tabl1.
  DO 5 TIMES VARYING bedng FROM xf123-bedg1 NEXT xf123-bedg2
             VARYING table FROM if123-tabl1 NEXT if123-tabl2.
    table = space.
    CHECK NOT bedng IS INITIAL.
    PERFORM find_tabl
            USING    koart bedng
            CHANGING table.
  ENDDO.
ENDFORM.                               "FILL_TABLX
*---------------------------------------------------------------------*
*       FORM FIND_TABL                                                *
*---------------------------------------------------------------------*
*       Die Bedinung BEDGX wird in den Tabellen der Feldleiste        *
*       TABL (BKPF, BSEG ...) gesucht und der Tabellenname nach TABLX *
*       geschrieben. Wird keine Tabelle gefunden ist TABLX initial    *
*---------------------------------------------------------------------*
*  -->  KOART         Kontoart                                        *
*  -->  BEDGX         Bedingung    x (x=1-4)                          *
*  -->  TABLX         Tabellenname x (x=1-4)                          *
*  -->  INDEX         Nummer der Bedingung                            *
*---------------------------------------------------------------------*
FORM find_tabl USING    i_koart LIKE bseg-koart
                        i_bedgx LIKE if123-bedg1
               CHANGING e_tablx LIKE if123-tabl1.
  DATA: text(15) TYPE c,
        table    LIKE if123-tabl1,
        rc       LIKE sy-subrc.
*
  CASE i_koart.
    WHEN char_d.
      tabl-tab1 = 'BSID'.
    WHEN char_k.
      tabl-tab1 = 'BSIK'.
    WHEN char_s.
      tabl-tab1 = 'BSIS'.
  ENDCASE.
*
  DO tabl-ntabl TIMES VARYING table FROM tabl-tab1 NEXT tabl-tab2.
    SELECT * FROM dd03l
             WHERE tabname   = table
             AND   fieldname = i_bedgx
             AND   as4local  = char_a.
      EXIT.
    ENDSELECT.
    IF sy-subrc EQ 0.
      e_tablx = table.
      EXIT.
    ENDIF.
  ENDDO.
*
*----- Texte für Überschriften sammeln ---------------------------------
*
  PERFORM schluesselwort_lesen2(sapfs003)
          USING e_tablx i_bedgx text rc.
  CHECK rc IS INITIAL.
  itext-kritx+00(10) = e_tablx.
  itext-kritx+10(01) = '-'.
  itext-kritx+11(09) = i_bedgx.
  CONDENSE itext-kritx NO-GAPS.
  itext-textx        = text.
  COLLECT itext.
ENDFORM.                               "FIND_TABL
*&---------------------------------------------------------------------*
*&      Form  FILL_DFIESTAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_dfiestab.
  IF if123-tabl1 = 'BSID'
  OR if123-tabl1 = 'BSIK'
  OR if123-tabl1 = 'BSIS'.
    PERFORM ddif_fieldinfo_get USING if123-tabl1 if123-bedg1.
  ENDIF.

  IF if123-tabl2 = 'BSID'
  OR if123-tabl2 = 'BSIK'
  OR if123-tabl2 = 'BSIS'.
    PERFORM ddif_fieldinfo_get USING if123-tabl2 if123-bedg2.
  ENDIF.

  IF if123-tabl3 = 'BSID'
  OR if123-tabl3 = 'BSIK'
  OR if123-tabl3 = 'BSIS'.
    PERFORM ddif_fieldinfo_get USING if123-tabl3 if123-bedg3.
  ENDIF.

  IF if123-tabl4 = 'BSID'
  OR if123-tabl4 = 'BSIK'
  OR if123-tabl4 = 'BSIS'.
    PERFORM ddif_fieldinfo_get USING if123-tabl4 if123-bedg4.
  ENDIF.

  IF if123-tabl5 = 'BSID'
  OR if123-tabl5 = 'BSIK'
  OR if123-tabl5 = 'BSIS'.
    PERFORM ddif_fieldinfo_get USING if123-tabl5 if123-bedg5.
  ENDIF.

ENDFORM.                               " FILL_DFIESTAB
*&---------------------------------------------------------------------*
*&      Form  DDIF_FIELDINFO_GET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ddif_fieldinfo_get USING p_tabname p_fieldname.
  DATA: tabname  LIKE dfiestab-tabname,
        fieldname LIKE dfiestab-fieldname.

  CLEAR dfiestab.
  REFRESH dfiestab.
  tabname = p_tabname.
  fieldname = p_fieldname.
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = tabname
      fieldname      = fieldname
      langu          = sy-langu                             "878408
    TABLES
      dfies_tab      = dfiestab
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc = 0.
    IF dfiestab-datatype = 'DATS'.                          "418389
      READ TABLE dfiestab INDEX 1 INTO tdfies.              "878408
      APPEND tdfies.                                        "418389
    ELSEIF dfiestab-datatype = 'CURR'                       "418389
    AND ( dfiestab-reftable = 'BSIS' OR dfiestab-reftable = 'BSIK'
    OR    dfiestab-reftable = 'BSID' OR dfiestab-reftable = 'T001' ).
      READ TABLE dfiestab INDEX 1 INTO tdfies.              "878408
      APPEND tdfies.
      CASE xf123-koart.
        WHEN 'D'.
          betraeged = 'X'.
        WHEN 'K'.
          betraegek = 'X'.
        WHEN 'S'.
          betraeges = 'X'.
      ENDCASE.
    ENDIF.
  ENDIF.
ENDFORM.                               " DDIF_FIELDINFO_GET
*&---------------------------------------------------------------------*
*&      Form  ITEXT_ERGAENZEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM itext_ergaenzen.
  DATA: text(15) TYPE c,
        table    LIKE if123-tabl1,
        rc       LIKE sy-subrc,
        bedng LIKE tf123-bedg1.
  PERFORM itexterg_fuellen.
  LOOP AT itexterg.
    READ TABLE itext WITH KEY kritx = itexterg-kritx.
    IF sy-subrc NE 0.
      PERFORM schluesselwort_lesen2(sapfs003)
              USING itexterg-table itexterg-bedng text rc.
      CHECK rc IS INITIAL.
      PERFORM itext_fuellen USING itexterg-table itexterg-bedng text.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " ITEXT_ERGAENZEN
*&---------------------------------------------------------------------*
*&      Form  ITEXTERG_FUELLEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM itexterg_fuellen.
  itexterg-table = 'BSID'.
  itexterg-bedng = 'XREF3'.
  itexterg-kritx = 'BSID-XREF3'.
  APPEND itexterg.
  itexterg-table = 'BSIS'.
  itexterg-bedng = 'XREF3'.
  itexterg-kritx = 'BSIS-XREF3'.
  APPEND itexterg.
  itexterg-table = 'BSEG'.
  itexterg-bedng = 'EBELN'.
  itexterg-kritx = 'BSEG-EBELN'.
  APPEND itexterg.
  itexterg-table = 'BSEG'.
  itexterg-bedng = 'EBELP'.
  itexterg-kritx = 'BSEG-EBELP'.
  APPEND itexterg.
  itexterg-table = 'BSIS'.
  itexterg-bedng = 'GSBER'.
  itexterg-kritx = 'BSIS-GSBER'.
  APPEND itexterg.
*  ITEXTERG-TABLE = 'BKPF'.
*  ITEXTERG-BEDNG = 'XBLNR'.
*  ITEXTERG-KRITX = 'BKPF-XBLNR'.
*  APPEND ITEXTERG.
ENDFORM.                               " ITEXTERG_FUELLEN
*&---------------------------------------------------------------------*
*&      Form  ITEXT_FUELLEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TABLE  text                                                *
*      -->P_BEDNG  text                                                *
*      -->P_TEXT  text                                                 *
*----------------------------------------------------------------------*
FORM itext_fuellen USING    p_table
                            p_bedng
                            p_text.
  itext-kritx+00(10) = p_table.
  itext-kritx+10(01) = '-'.
  itext-kritx+11(09) = p_bedng.
  CONDENSE itext-kritx NO-GAPS.
  itext-textx        = p_text.
  COLLECT itext.

ENDFORM.                               " ITEXT_FUELLEN


*---------------------------------------------------------------------*
*       FORM CHECK_XFIELD                                             *
*---------------------------------------------------------------------*
*       Mindestens ein Konto muß selektiert sein                      *
*---------------------------------------------------------------------*
FORM check_xfield.
* If ledger group specific clearing, x_saknr is set automatically.
  IF x_lg = 2.
    IF x_saknr EQ space.
      x_saknr = 'X'.
    ENDIF.
  ENDIF.

  IF  x_kunnr EQ space
  AND x_shbkn EQ space
  AND x_lifnr EQ space
  AND x_shblf EQ space
  AND x_saknr EQ space.
* Sie haben keine Konten selektiert
    MESSAGE e111.
  ENDIF.
  IF x_saknr = space AND xsobwere = 'X'.
    MESSAGE e118.
  ENDIF.
  IF xtol = 'X' AND min_bel NE 0.
    MESSAGE e099.
  ENDIF.
  IF xsobebvk = 'X'.
    IF x_saknr = space.
      MESSAGE e892.
    ELSEIF x_kunnr = 'X'
    OR     x_shbkn = 'X'
    OR     x_lifnr = 'X'
    OR     x_shblf = 'X'.
      MESSAGE w892.
    ENDIF.
  ENDIF.
  IF xsobebvk = 'X' AND zwaers NE space.
    MESSAGE e890(fg).
  ENDIF.
  IF xauslw = 'X' AND zwaers NE space.
    MESSAGE e894(fg).
  ENDIF.
  IF xauslw = 'X'
  OR xsobebvk = 'X'
  OR zwaers <> space.
    xf124e = 'X'.
  ELSE.
    xf124e = space.
  ENDIF.
  IF  xaugdt = 'X'
  AND xf124e = 'X'.
    MESSAGE e022.
  ENDIF.
ENDFORM.                               "CHECK_XFIELD.
*&---------------------------------------------------------------------*
*&      Form  GJVTAB_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM gjvtab_init.
  CLEAR gjvtab.
  REFRESH gjvtab.
ENDFORM.                               " GJVTAB_INIT
*---------------------------------------------------------------------*
*       FORM CHECK_AUTHORITY                                          *
*---------------------------------------------------------------------*
*       Berechtigungsprüfungen für SAPF124                            *
*---------------------------------------------------------------------*
FORM check_authority.
  CHECK sy-ucomm NE 'SPOS'.                                 "616384
  CHECK sy-ucomm NE 'SAVE'.                                 "725776
  PERFORM check_authority_bukrs.
  PERFORM check_authority_koart.
  CALL FUNCTION 'FI_ADD_AUTHORITY_CHECK'                    "516329
  IMPORTING e_xblar = gb_xaubl                              "516329
            e_xgsbe = gb_xaugs.                             "516329
  IF gb_xaubl NE space.                                     "516329
    PERFORM record_fill USING 'AUBLA' space space space space "516329
    space space 'I'.                                        "516329
  ENDIF.                                                    "516329
  IF gb_xaugs NE space.                                     "516329
    PERFORM record_fill USING 'AUGSB' space space space space "516329
    space space 'I'.                                        "516329
  ENDIF.                                                    "516329
ENDFORM.                    "CHECK_AUTHORITY
*---------------------------------------------------------------------*
*       FORM CHECK_AUTHORITY_BUKRS                                    *
*---------------------------------------------------------------------*
*       Prüfung der Buchungskreisberechtigung                         *
*---------------------------------------------------------------------*
FORM check_authority_bukrs.
  DATA: text(20)     TYPE c.
  DATA: BEGIN OF itab OCCURS 3,
          bukrs LIKE t001-bukrs,
        END OF itab.
  CLEAR i001.
  REFRESH i001.
*----- Kein Check beim Anlegen von Wertemengen -------------------------
  CHECK sy-ucomm NE 'FSET'.
  IF x_testl EQ space.
    actvt = '02'.                      " Anzeigeberechtigung
  ELSE.
    actvt = '03'.                      " Änderungsberechtigung
  ENDIF.
*
  authorit = '00'.
  SELECT * FROM t001
           WHERE bukrs IN bukrx.
    i001 = t001.
    APPEND i001.
    gjvtab-periv = t001-periv.
    COLLECT gjvtab.
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
      ID 'BUKRS' FIELD t001-bukrs
      ID 'ACTVT' FIELD actvt.
    IF sy-subrc NE 0.
      authorit = actvt.
      itab-bukrs = t001-bukrs.
      APPEND itab.
    ENDIF.
  ENDSELECT.

*----- Text für Fehlermeldung aufbauen ---------------------------------
  LOOP AT itab.
    CASE sy-tabix.
      WHEN 1.
        text+00 = itab-bukrs.
      WHEN 2.
        text+04 = ','.
        text+06 = itab-bukrs.
      WHEN 3.
        text+10 = ','.
        text+12 = itab-bukrs.
      WHEN 4.
        text+17 = '...'.
    ENDCASE.
  ENDLOOP.
*
  CASE authorit.
    WHEN '02'.
      SET CURSOR FIELD 'BUKRX'.
*----- Keine Berechtigung zum Ändern von Buchungskreis $ ---------------
      MESSAGE e112 WITH text.
    WHEN '03'.
      SET CURSOR FIELD 'BUKRX'.
*----- Keine Berechtigung zum Anzeigen von Buchungskreis $ -------------
      MESSAGE e113 WITH text.
  ENDCASE.
ENDFORM.                               "CHECK_AUTHORITY_BUKRS.
*---------------------------------------------------------------------*
*       FORM CHECK_AUTHORITY_KOART                                    *
*---------------------------------------------------------------------*
*       Prüfung der Kontoartenberechtigung                            *
*       Der Anwender muß die Berechtigung zum Anzeigen und Ändern     *
*       einer Kontoart (D,K,S) haben, um den Ausgleich druchzuführen. *
* Bei SAPF123W wird wg. Defaults f. Parameter nur f. Sako geprueft
*---------------------------------------------------------------------*
FORM check_authority_koart.
  DATA: text(21)      TYPE c,
        text0(200)    TYPE c,
        text1(80)     TYPE c,
        text2(20)     TYPE c.
  DATA: BEGIN OF itab OCCURS 3,
          text(20) TYPE c,
        END OF itab.
*
* Initialisieren der Berechtigung (00 heißt berechtigt zum Ausgleich)
*
  authorit = '00'.
  IF x_testl EQ space.
    actvt = '02'.                      "Änderungsberechtigung
    text1 = text-004.                  "Keine Änderungsberechtigung für
  ELSE.
    actvt = '03'.                      "Anzeigeberechtigung
    text1 = text-005.                  "Keine Anzeigeberechtigung für
  ENDIF.
*
  DO 3 TIMES.
    CASE sy-index.
      WHEN 1.
        CHECK NOT x_kunnr IS INITIAL   "G.V.24.04.96
           OR NOT x_shbkn IS INITIAL.
        koart = char_d.
        text2 = 'Debitoren'(001).
      WHEN 2.
        CHECK NOT x_lifnr IS INITIAL   "G.V.24.04.96
           OR NOT x_shblf IS INITIAL.
        koart = char_k.
        text2 = 'Kreditoren'(002).
      WHEN 3.
        CHECK NOT x_saknr IS INITIAL.  "G.V.24.04.96
        koart = char_s.
        text2 = 'Sachkonten'(003).
    ENDCASE.
*   Check nur falls Kontoart bei Aufruf selektiert wurde
    AUTHORITY-CHECK OBJECT 'F_BKPF_KOA'
      ID 'KOART' FIELD koart
      ID 'ACTVT' FIELD actvt.
    IF sy-subrc NE 0.
      authorit = actvt.                "Merken, dass Auth. fehlt
      itab-text = text2.
      APPEND itab.
    ENDIF.
  ENDDO.
*
  IF  authorit NE '00'.
*
* Text für Fehlermeldung aufbauen
*
    LOOP AT itab.
      CASE sy-tabix.
        WHEN 1.
          text+00(20) = itab-text.
          text0+00    = text.
        WHEN 2.
          text+20(1)  = ','.
          CONDENSE text NO-GAPS.
          text0+00    = text.
          text+00(20) = itab-text.
          text0+20    = text.
        WHEN 3.
          text+20(1)  = ','.
          CONDENSE text NO-GAPS.
          text0+20  = text.
          text0+40  = itab-text.
      ENDCASE.
    ENDLOOP.
    CONDENSE text0.
*
    MESSAGE e114 WITH text1 text0.
  ENDIF.
ENDFORM.                               "CHECK_AUTHORITY_KOART.
*&---------------------------------------------------------------------*
*&      Form  CHECK_AUGDT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_augdt.
  IF ( NOT augdt IS INITIAL AND xaugdt = 'X' )
  OR ( augdt IS INITIAL AND xaugdt IS INITIAL ).
    MESSAGE e018.
  ENDIF.
  IF augdt IS INITIAL AND NOT bmonat IS INITIAL.
    MESSAGE e021.
  ENDIF.
  save_augdt = augdt.                                       "985181
ENDFORM.                               " CHECK_AUGDT
*&---------------------------------------------------------------------*
*&      Form  GJVTAB_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM gjvtab_check.
*----- Periodenangabe nur erlaubt, wenn nicht mehrere GJ-Varianten -----
*----- im Spiel sind ---------------------------------------------------
  IF NOT bmonat IS INITIAL.
    DESCRIBE TABLE gjvtab LINES sy-tfill.
    IF sy-tfill > 1.
      MESSAGE e020.
    ENDIF.
  ENDIF.
ENDFORM.                               " GJVTAB_CHECK
*&---------------------------------------------------------------------*
*&      Form  PERIODE_ERMITTELN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_AUGDAT  text                                               *
*----------------------------------------------------------------------*
FORM periode_ermitteln USING i_bukrs LIKE t001-bukrs
                             i_augdt LIKE bkpf-budat
                             e_gjahr LIKE bseg-gjahr
                             e_monat.
  DATA: rcperiod LIKE sy-subrc.

  CHECK augdttab-xnok IS INITIAL.

  CALL FUNCTION 'FI_PERIOD_DETERMINE'
    EXPORTING
      i_bukrs        = i_bukrs
      i_budat        = i_augdt
      i_monat        = e_monat
      i_gjahr        = e_gjahr
    IMPORTING
      e_gjahr        = e_gjahr
      e_monat        = e_monat
    EXCEPTIONS
      fiscal_year    = 1
      period         = 2
      period_version = 3
      posting_period = 4
      special_period = 5
      version        = 6
      posting_date   = 7
      OTHERS         = 8.
  rcperiod = sy-subrc.
  IF rcperiod NE 0.                                         "985181
    IF augdt NE save_augdt.                                 "985181
      IF flg_liste = char_3.
*----- Ausgabe: Kein Ausgleich -----------------------------------------
        PERFORM record_clearing_info USING 'NOCLEAR' ' ' 'X' koart.
      ENDIF.
*----- Fehlerprotokoll füllen ------------------------------------------
      PERFORM fehler_merken.
      PERFORM augdttab_fuellen USING i_bukrs i_augdt 'X'.
    ELSE.                                                   "985181
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.                                                     "985181
    PERFORM augdttab_fuellen USING i_bukrs i_augdt ' '.
  ENDIF.
ENDFORM.                               " PERIODE_ERMITTELN
*&---------------------------------------------------------------------*
*&      Form  AUGDTTAB_FUELLEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM augdttab_fuellen USING p_bukrs LIKE t001-bukrs
                            p_augdt LIKE bseg-augdt
                            p_xnok  LIKE augdttab-xnok.
  augdttab-bukrs = p_bukrs.
  augdttab-augdt = p_augdt.
  augdttab-xnok =  p_xnok.
ENDFORM.                               " AUGDTTAB_FUELLEN
*&---------------------------------------------------------------------*
*&      Form  PERIODE_PRUEFEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM periode_pruefen USING i_bukrs LIKE t001-bukrs
                           i_augdt LIKE bkpf-budat
                           i_gjahr LIKE bseg-gjahr
                           i_monat
                           i_mess.                          "1112148
  PERFORM periode_ermitteln USING i_bukrs i_augdt i_gjahr i_monat.
  PERFORM period_check
  USING i_bukrs '+' '+' i_gjahr i_monat i_mess.             "1112148
ENDFORM.                               " PERIODE_PRUEFEN
*&---------------------------------------------------------------------*
*&      Form  PERIOD_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM period_check USING i_bukrs LIKE t001-bukrs
                        i_koart LIKE bseg-koart
                        i_konto
                        i_gjahr LIKE bseg-gjahr
                        i_monat
                        i_mess.                             "1112148
  DATA: konto    LIKE t001b-vkont,
        monat    LIKE t001b-frpe1,
        rccheck LIKE sy-subrc.

  CHECK augdttab-xnok IS INITIAL.
*Typenkonflikte vermeiden

  konto = i_konto.
  monat = i_monat.

  CALL FUNCTION 'FI_PERIOD_CHECK'
    EXPORTING
      i_bukrs          = i_bukrs
      i_gjahr          = i_gjahr
      i_koart          = i_koart
      i_konto          = konto
      i_monat          = monat
    EXCEPTIONS
      error_period     = 1
      error_period_acc = 2
      OTHERS           = 3.
  rccheck = sy-subrc.
  IF rccheck NE 0.
    IF x_testl ='X'.
      IF i_mess = space.                                    "1112148
        IF flg_liste = char_3.
*----- Ausgabe: Kein Ausgleich -----------------------------------------
          PERFORM record_clearing_info USING 'NOCLEAR' ' ' 'X' i_koart.
        ENDIF.
*----- Fehlerprotokoll füllen ------------------------------------------
        PERFORM fehler_merken.
        PERFORM augdttab_fuellen USING i_bukrs augdt 'X'.
      ELSE.
        MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ELSE.
      IF i_mess = space.                                    "1112148
        IF flg_liste = char_3.
*----- Ausgabe: Kein Ausgleich -----------------------------------------
          PERFORM record_clearing_info USING 'NOCLEAR' ' ' 'X' i_koart.
        ENDIF.
*----- Fehlerprotokoll füllen ------------------------------------------
        PERFORM fehler_merken.
        PERFORM augdttab_fuellen USING i_bukrs augdt 'X'.
      ELSE.
        MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ELSE.
    PERFORM augdttab_fuellen USING i_bukrs augdt ' '.       "985181
  ENDIF.


ENDFORM.                               " PERIOD_CHECK
*---------------------------------------------------------------------*
*       FORM SELECT_T030                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM select_t030.

* SKV-Konten in allen BUKen aufsammeln, f. Check in read_bsis
  REFRESH i030_skv.
  CLEAR i030_skv.
  LOOP AT i001.
    SELECT * FROM  t030
             WHERE ktopl =  i001-ktopl
               AND ktosl =  'SKV'.     " Skontoverrechnung
      i030_skv-bukrs = i001-bukrs.
      i030_skv-konts = t030-konts.
      COLLECT i030_skv.
    ENDSELECT.
* WE/RE-Konten bestimmen, falls bessere Zuordnung erforderlich, z.B. bei
* Lieferplänen
    IF i001-ktopl NE i030_were-ktopl.
      CLEAR i030_were.
      SELECT * FROM  t030 INTO TABLE i030_were
               WHERE ktopl =  i001-ktopl
                 AND ktosl =  'WRX'.   " WE/RE-Konto
    ENDIF.
    LOOP AT i030_were.
*       LOOP AT I001 WHERE KTOPL EQ I030_WERE-KTOPL.
*         MOVE-CORRESPONDING I001 TO IWERE.
*         EXIT.
*       ENDLOOP.
*       CHECK SY-SUBRC IS INITIAL.
      iwere-bukrs = i001-bukrs.
      iwere-hkont = i030_were-konts.
      IF NOT iwere-hkont IS INITIAL.
        COLLECT iwere.
      ENDIF.
      iwere-hkont = i030_were-konth.
      IF NOT iwere-hkont IS INITIAL.
        COLLECT iwere.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    "SELECT_T030
*-----------------------------------------------------------------------
*       FORM CHECK_RULES                                               *
*-----------------------------------------------------------------------
*       Sind Anwenderkriterien in der Tabelle TF123 gepflegt           *
*-----------------------------------------------------------------------
FORM check_rules.
  DESCRIBE TABLE xf123 LINES sy-tfill. "Gefuellt in INITILIZATION
  IF sy-tfill = 0.
* Anwenderkriterien für maschinelles Ausgleichen sind nicht gepflegt
    MESSAGE w100.
  ENDIF.
ENDFORM.                               "CHECK_RULES.
*---------------------------------------------------------------------*
*       FORM CHECK_ECHTL                                              *
*---------------------------------------------------------------------*
FORM check_echtl.
  IF x_testl = space.
    x_echtl = char_x.
*   Dieser Programmlauf ist ein Echtlauf!
    MESSAGE w013.
  ELSE.
    x_echtl = space.
  ENDIF.
ENDFORM.                    "CHECK_ECHTL
*---------------------------------------------------------------------*
*       FORM INIT_LIST                                                *
*---------------------------------------------------------------------*
*       Initialisieren der Ausgabeliste abhängig von der Eingabe      *
*---------------------------------------------------------------------*
FORM init_list.
  IF xausbel = 'X'
  OR xnausbel = 'X'.
    flg_liste = char_3.
  ELSE.
    flg_liste = char_2.
  ENDIF.
ENDFORM.                               "INIT_LIST


*&---------------------------------------------------------------------*
*&      Form  CHECK_WAEHRUNG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_waehrung.
  IF NOT zwaers IS INITIAL.
    SELECT SINGLE * FROM tcurc WHERE waers = zwaers.
    IF sy-subrc = 0.
      bsis-waers = zwaers.
    ELSE.
      MESSAGE e107(sg) WITH zwaers.
    ENDIF.
  ENDIF.

ENDFORM.                               " CHECK_WAEHRUNG
*&---------------------------------------------------------------------*
*-----------------------------------------Form Regus_pruefen-----"681786
FORM regus_pruefen.                                         "681786
  DATA: BEGIN OF xregus OCCURS 51,                          "681786
           koart LIKE regus-koart,                          "681786
           bukrs LIKE regus-bukrs,                          "681786
           konko LIKE regus-konko,                          "681786
           laufd LIKE regus-laufd,                          "681786
           laufi LIKE regus-laufi,                          "681786
        END OF xregus.                                      "681786
  DATA: rc LIKE sy-subrc.                                   "681786
                                                            "681786
  IF x_echtl ='X'                                           "681786
  AND ( x_kunnr = 'X' OR x_lifnr = 'X' ).                   "681786
    LOOP AT i001.                                           "681786
      SELECT * FROM regus                                   "681786
      WHERE bukrs = i001-bukrs                              "681786
      AND   koart = 'D'                                     "681786
      AND   laufi <> '$F124$'.                              "965141
        xregus-laufd = regus-laufd.                         "681786
        xregus-laufi = regus-laufi.                         "681786
        COLLECT xregus.                                     "681786
      ENDSELECT.                                            "681786
      SELECT * FROM regus                                   "681786
      WHERE bukrs = i001-bukrs                              "681786
      AND   koart = 'K'                                     "681786
      AND   laufi <> '$F124$'.                              "965141
        xregus-laufd = regus-laufd.                         "681786
        xregus-laufi = regus-laufi.                         "681786
        COLLECT xregus.                                     "681786
      ENDSELECT.                                            "681786
    ENDLOOP.                                                "681786
    LOOP AT xregus.                                         "681786
      regus-laufd = xregus-laufd.                           "681786
      regus-laufi = xregus-laufi.                           "681786
      PERFORM regus_pruefen_fehler(sapf110e) USING rc.      "681786
    ENDLOOP.                                                "681786
    CLEAR regus.                                            "681786
  ENDIF.                                                    "681786
ENDFORM.                                                    "681786
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  KONTOTABELLEN_FUELLEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM kontotabellen_fuellen.
  PERFORM tdebi_fuellen.
  PERFORM tkredi_fuellen.
  PERFORM tsako_fuellen.
*----- Nur Konten mit Soll u. Habenbuchungen (bei Debi/Kredi) ----------
  IF x_saknr = space.
    PERFORM record_fill
           USING 'SOHA ' space space space space space space char_i.
  ENDIF.
ENDFORM.                               " KONTOTABELLEN_FUELLEN
*&---------------------------------------------------------------------*
*&      Form  TDEBI_FUELLEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM tdebi_fuellen.
  DATA: BEGIN OF lt_knbw OCCURS 1.                          "500429
          INCLUDE STRUCTURE knbw.                           "500429
  DATA: END OF lt_knbw.                                     "500429

  IF x_lg = 1
  AND x_kunnr EQ space
  AND x_shbkn EQ space.
*----- Keine Debitorenbelege selektiert --------------------------------
    PERFORM record_fill
            USING 'BSID ' space space space space space space char_s.
    EXIT.
  ENDIF.
*----- Normale OP's ----------------------------------------------------
  IF x_shbkn EQ space AND x_kunnr NE space.
    SELECT DISTINCT bukrs kunnr shkzg FROM bsid INTO tdebi
                            WHERE bukrs IN bukrx
                              AND kunnr IN kontd
                              AND umsks EQ space
                              AND gjahr IN gjahx.
      CALL FUNCTION 'FI_WT_READ_KNBW'                       "500429
      EXPORTING i_kunnr = tdebi-kunnr                       "500429
                i_bukrs = tdebi-bukrs                       "500429
      TABLES t_knbw     = lt_knbw                           "500429
      EXCEPTIONS not_found = 1.                             "500429
      IF sy-subrc = 0.                                      "500429
        tdebi-wt_newwt = 'X'.                               "500429
      ELSE.                                                 "538265
        CLEAR tdebi-wt_newwt.                               "538265
      ENDIF.                                                "500429
      APPEND tdebi.
    ENDSELECT.
    IF sy-subrc NE 0.
*----- Keine Debitorenbelege selektiert --------------------------------
      PERFORM record_fill
              USING 'BSID ' space space space space space space char_s.
    ENDIF.
  ENDIF.
*----- Sonderhauptbuchvorgänge (außer 'A' und 'W') ---------------------
  IF x_shbkn NE space AND x_kunnr EQ space.
    SELECT DISTINCT bukrs kunnr shkzg FROM bsid INTO tdebi
                            WHERE bukrs IN bukrx
                              AND kunnr IN kontd
                              AND umsks NE char_w           "401470
                              AND umskz NE space
                              AND gjahr IN gjahx.
      CALL FUNCTION 'FI_WT_READ_KNBW'                       "500429
      EXPORTING i_kunnr = tdebi-kunnr                       "500429
                i_bukrs = tdebi-bukrs                       "500429
      TABLES t_knbw     = lt_knbw                           "500429
      EXCEPTIONS not_found = 1.                             "500429
      IF sy-subrc = 0.                                      "500429
        tdebi-wt_newwt = 'X'.                               "500429
      ELSE.                                                 "538265
        CLEAR tdebi-wt_newwt.                               "538265
      ENDIF.                                                "500429
      APPEND tdebi.
    ENDSELECT.
    IF sy-subrc NE 0.
*----- Keine SHB-Vorgänge der Klasse 'A' und 'W' -----------------------
      PERFORM record_fill
              USING '    ' space space space space space space char_i.
*----- Keine Debitorenbelege selektiert --------------------------------
      PERFORM record_fill
              USING 'BSID ' space space space space space space char_s.
    ELSE.
*----- Keine SHB-Vorgänge der Klasse 'A' und 'W' -----------------------
      PERFORM record_fill
              USING '    ' space space space space space space char_i.
    ENDIF.
  ENDIF.
*----- Normale OP's und Sonderhauptbuchvorgänge (außer 'A' und 'W')-----
  IF x_shbkn NE space AND x_kunnr NE space.
    SELECT DISTINCT bukrs kunnr shkzg FROM bsid INTO tdebi
                            WHERE bukrs IN bukrx
                              AND kunnr IN kontd
                              AND umsks NE char_w           "401470
                              AND gjahr IN gjahx.
      CALL FUNCTION 'FI_WT_READ_KNBW'                       "500429
      EXPORTING i_kunnr = tdebi-kunnr                       "500429
                i_bukrs = tdebi-bukrs                       "500429
      TABLES t_knbw     = lt_knbw                           "500429
      EXCEPTIONS not_found = 1.                             "500429
      IF sy-subrc = 0.                                      "500429
        tdebi-wt_newwt = 'X'.                               "500429
      ELSE.                                                 "538265
        CLEAR tdebi-wt_newwt.                               "538265
      ENDIF.                                                "500429
      APPEND tdebi.
    ENDSELECT.
    IF sy-subrc NE 0.
*----- Keine SHB-Vorgänge der Klasse 'A' und 'W' -----------------------
      PERFORM record_fill
              USING '    ' space space space space space space char_i.
*----- Keine Debitorenbelege selektiert --------------------------------
      PERFORM record_fill
          USING 'BSID ' space space space space space space char_s.
    ELSE.
*----- Keine SHB-Vorgänge der Klasse 'A' und 'W' -----------------------
      PERFORM record_fill
              USING '    ' space space space space space space char_i.
    ENDIF.
  ENDIF.
  SORT tdebi BY bukrs kunnr.
ENDFORM.                               " TDEBI_FUELLEN

*&---------------------------------------------------------------------*
*&      Form  TKREDI_FUELLEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM tkredi_fuellen.

  IF x_lg = 1
  AND x_lifnr EQ space
  AND x_shblf EQ space.
*----- Keine Kreditorenbelege selektiert -------------------------------
    PERFORM record_fill
            USING 'BSIK ' space space space space space space char_s.
    EXIT.
  ENDIF.
*----- Normale OP's ----------------------------------------------------
  IF x_shblf EQ space AND x_lifnr NE space.
    SELECT DISTINCT bukrs lifnr shkzg FROM bsik INTO tkredi
                            WHERE bukrs IN bukrx
                              AND lifnr IN kontk
                              AND umsks EQ space
                              AND gjahr IN gjahx.
      APPEND tkredi.
    ENDSELECT.
    IF sy-subrc NE 0.
*----- Keine Kreditorenbelege selektiert -------------------------------
      PERFORM record_fill
              USING 'BSIK ' space space space space space space char_s.
    ENDIF.
  ENDIF.
*----- Sonderhauptbuchvorgänge (außer 'A' und 'W') ---------------------
  IF x_shblf NE space AND x_lifnr EQ space.
    SELECT DISTINCT bukrs lifnr shkzg FROM bsik INTO tkredi
                            WHERE bukrs IN bukrx
                              AND lifnr IN kontk
                              AND umsks NE char_w           "401470
                              AND umskz NE space
                              AND gjahr IN gjahx.
      APPEND tkredi.
    ENDSELECT.
    IF sy-subrc NE 0.
*----- Keine SHB-Vorgänge der Klasse 'A' und 'W' -----------------------
      PERFORM record_fill
              USING '    ' space space space space space space char_i.
*----- Keine Kreditorenbelege selektiert -------------------------------
      PERFORM record_fill
            USING 'BSIK ' space space space space space space char_s.
    ELSE.
*----- Keine SHB-Vorgänge der Klasse 'A' und 'W' -----------------------
      PERFORM record_fill
              USING '    ' space space space space space space char_i.
    ENDIF.
  ENDIF.
*----- Normale OP's und Sonderhauptbuchvorgänge (außer 'A' und 'W')-----
  IF x_shblf NE space AND x_lifnr NE space.
    SELECT DISTINCT bukrs lifnr shkzg FROM bsik INTO tkredi
                            WHERE bukrs IN bukrx
                              AND lifnr IN kontk
                              AND umsks NE char_w           "401470
                              AND gjahr IN gjahx.
      APPEND tkredi.
    ENDSELECT.
    IF sy-subrc NE 0.
*----- Keine SHB-Vorgänge der Klasse 'A' und 'W' -----------------------
      PERFORM record_fill
              USING '    ' space space space space space space char_i.
*----- Keine Kreditorenbelege selektiert -------------------------------
      PERFORM record_fill
          USING 'BSIK ' space space space space space space char_s.
    ELSE.
*----- Keine SHB-Vorgänge der Klasse 'A' und 'W' -----------------------
      PERFORM record_fill
              USING '    ' space space space space space space char_i.
    ENDIF.
  ENDIF.
  SORT tkredi BY bukrs lifnr.
ENDFORM.                               " TKREDI_FUELLEN

*&---------------------------------------------------------------------*
*&      Form  TSAKO_FUELLEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM tsako_fuellen.

  DATA: BEGIN OF skb1tab,
          bukrs LIKE skb1-bukrs,
          saknr LIKE skb1-saknr,
          xlgclr LIKE skb1-xlgclr, " Ledger group specific clearing
        END OF skb1tab.

  IF x_saknr EQ space.
*----- Keine Sachkontenbelege selktiert --------------------------------
    PERFORM record_fill
            USING 'BSIS ' space space space space space space char_s.
    EXIT.
  ENDIF.
  LOOP AT i001.
    SELECT  bukrs saknr xlgclr FROM skb1 INTO skb1tab
                               WHERE bukrs = i001-bukrs
                               AND   saknr IN konts
                               AND   ( xopvw = 'X'    "#EC CI_SGLSELECT
                               OR      xlgclr = 'X' ). "#EC CI_SGLSELECT
      tsako-bukrs = skb1tab-bukrs.
      tsako-hkont = skb1tab-saknr.
      tsako-shkzg = 'H'.
      tsako-xlgclr = skb1tab-xlgclr.
      APPEND tsako.
      tsako-bukrs = skb1tab-bukrs.
      tsako-hkont = skb1tab-saknr.
      tsako-shkzg = 'S'.
      tsako-xlgclr = skb1tab-xlgclr.
      APPEND tsako.
    ENDSELECT.
  ENDLOOP.

  SORT tsako BY bukrs hkont.
  DESCRIBE TABLE tsako LINES sy-tfill.
  IF sy-tfill EQ 0.
*----- Keine Sachkontenbelege selektiert -------------------------------
    PERFORM record_fill
            USING 'BSIS ' space space space space space space char_s.
  ENDIF.
ENDFORM.                               " TSAKO_FUELLEN
*&---------------------------------------------------------------------*
*&      Form  DEBI_VERARBEITEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM debi_verarbeiten.
  last_kunnr = space.
  last_bukrs = space.
  last_tabix = 0.                 " verwendet in form regeln_vorbereiten
  LOOP AT tdebi.
    AT NEW bukrs.
      new_bukr = 'X'.
      suinf = space.
    ENDAT.
    IF tdebi-kunnr = last_kunnr AND tdebi-bukrs = last_bukrs.
      REFRESH xbsid.
      REFRESH xbsidgr.
      koart = char_d.
*----- Sind für das Konto Regeln in TF123 hinterlegt? ------------------
      PERFORM check_table_if123
                           USING koart tdebi-bukrs tdebi-kunnr
                           CHANGING flag_if123.
      IF flag_if123 EQ char_x.
        IF x_echtl = 'X' OR xtol = 'X' .
          PERFORM echtlauf USING koart.
        ELSE.
          PERFORM testlauf USING koart.
        ENDIF.
      ENDIF.
    ELSE.
      last_kunnr = tdebi-kunnr.
      last_bukrs = tdebi-bukrs.
    ENDIF.
    AT END OF bukrs.
      IF flg_liste = '2' AND suinf = 'X'.
*----- Ausgabe der Summenzeile bei Statistik pro BUkrs -----------------
        bukreis = tdebi-bukrs.
        PERFORM sum_info USING bukreis '1' sum1_op sum1_ap sum1_eap.
      ENDIF.
    ENDAT.
  ENDLOOP.

ENDFORM.                               " DEBI_VERARBEITEN
*
*&---------------------------------------------------------------------*
*&      Form  KREDI_VERARBEITEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM kredi_verarbeiten.
  last_lifnr = space.
  last_bukrs = space.
  last_tabix = 0.
  LOOP AT tkredi.
    AT NEW bukrs.
      new_bukr = 'X'.
      suinf = space.
    ENDAT.
    IF tkredi-lifnr = last_lifnr AND tkredi-bukrs = last_bukrs.
      REFRESH xbsik.
      REFRESH xbsikgr.
      koart = char_k.
*----- Sind für das Konto Regeln in TF123 hinterlegt? ------------------
      PERFORM check_table_if123
                           USING koart tkredi-bukrs tkredi-lifnr
                           CHANGING flag_if123.
      IF flag_if123 EQ char_x.
        IF x_echtl = 'X' OR xtol = 'X' .
          PERFORM echtlauf USING koart.
        ELSE.
          PERFORM testlauf USING koart.
        ENDIF.
      ENDIF.
    ELSE.
      last_lifnr = tkredi-lifnr.
      last_bukrs = tkredi-bukrs.
    ENDIF.
    AT END OF bukrs.
      IF flg_liste = '2' AND suinf = 'X'.
*----- Ausgabe der Summenzeile bei Statistik pro Bukrs -----------------
        bukreis = tkredi-bukrs.
        PERFORM sum_info USING bukreis '1' sum1_op sum1_ap sum1_eap.
      ENDIF.
    ENDAT.
  ENDLOOP.

ENDFORM.                               " KREDI_VERARBEITEN
*&---------------------------------------------------------------------*
*&      Form  SAKO_VERARBEITEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sako_verarbeiten.
  DATA: lv_continue TYPE xfeld VALUE 'X'.
  DATA: msg_switch  TYPE xfeld VALUE 'X'.
  last_hkont = space.
  last_bukrs = space.
  last_tabix = 0.
  LOOP AT tsako.
    lv_continue = 'X'.
* F.13 and f13E not allowed for account with ledger group specific clearing
    IF tsako-xlgclr = space AND x_lg = 2.
*ENHANCEMENT-POINT ehp603_f124_merge_1 SPOTS es_sapf124.
      IF msg_switch = 'X'.
        PERFORM record_fill
                USING 'BSIS' tsako-bukrs space space tsako-hkont space space char_i.
      ENDIF.
      DELETE tsako.
      lv_continue = space.
    ENDIF.
    IF tsako-xlgclr = 'X' AND x_lg = 1.
      PERFORM record_fill
              USING 'NOLG' tsako-bukrs space space tsako-hkont space space char_i.
      DELETE tsako.
      lv_continue = space.
    ENDIF.
    CHECK lv_continue = 'X'.
    AT NEW bukrs.
      new_bukr = 'X'.
      suinf = space.
    ENDAT.
    IF tsako-hkont = last_hkont AND tsako-bukrs = last_bukrs.
      IF xsobwere = 'X'.
        REFRESH iekbe.
        REFRESH ixaccdn.
        ctixaccdn = 0.
      ENDIF.
      REFRESH xbsis.
      REFRESH xbsisgr.
      CLEAR zaehler_xbsisgr.                                "427471
      CLEAR x_exit.                                         "427471
      koart = char_s.
*----- Sind für das Konto Regeln in TF123 hinterlegt? ------------------
      PERFORM check_table_if123
                           USING koart tsako-bukrs tsako-hkont
                           CHANGING flag_if123.
      IF flag_if123 EQ char_x.
        IF x_echtl = 'X' OR xtol = 'X' .
          PERFORM echtlauf USING koart.
        ELSE.
          PERFORM testlauf USING koart.
        ENDIF.
      ENDIF.
    ELSE.
      last_hkont = tsako-hkont.
      last_bukrs = tsako-bukrs.
    ENDIF.
    AT END OF bukrs.
      IF flg_liste = '2' AND suinf = 'X'.
*----- Ausgabe der Summenzeile bei Statistik pro Bukrs -----------------
        bukreis = tsako-bukrs.
        PERFORM sum_info USING bukreis '1' sum1_op sum1_ap sum1_eap.
      ENDIF.
    ENDAT.
  ENDLOOP.
ENDFORM.                               " SAKO_VERARBEITEN
*&---------------------------------------------------------------------*
*&      Form  CHECK_TABLE_IF123
*&---------------------------------------------------------------------*
*       Sind für ein KOnto Regeln in TF123 hinterlegt?
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_table_if123 USING
                            i_koart    LIKE bseg-koart
                            i_bukrs    LIKE t001-bukrs
                            i_konto
                   CHANGING flag_if123 TYPE c.

* CHECK SAVE2_KONTO NE I_KONTO.
* SAVE2_KONTO = I_KONTO.
  flag_if123 = space.
  SET EXTENDED CHECK OFF.
*----- Zuerst mit Kontenplan lesen und dann eventuell ohne -------------
  READ TABLE i001 WITH KEY bukrs = i_bukrs.
  IF sy-subrc = 0.
    LOOP AT if123 WHERE ktopl EQ i001-ktopl
                    AND koart EQ i_koart
                    AND kont1 LE i_konto
                    AND kont2 GE i_konto.
      flag_if123 = char_x.
      EXIT.
    ENDLOOP.
  ENDIF.
  IF sy-subrc NE 0.
    LOOP AT if123
         WHERE ktopl EQ space
         AND   koart EQ i_koart
         AND   kont1 LE i_konto
         AND   kont2 GE i_konto.
      flag_if123 = char_x.
      EXIT.
    ENDLOOP.
  ENDIF.
  SET EXTENDED CHECK ON.
  CHECK flag_if123 EQ space.
*----- Konto hat keine Regeln in TF123 ---------------------------------
*----- Eintrag ins Zusatzprotokoll, falls angekreuzt -------------------
  PERFORM record_fill
         USING 'RULES' i_bukrs i_koart i_konto space space space char_l.
ENDFORM.                               " CHECK_TABLE_IF123
*&---------------------------------------------------------------------*
*&      Form  ECHTLAUF
*&---------------------------------------------------------------------*
*       Speeren des KOntos im Echtlauf oder bei Benutzung von
*       Toleranzen wegen der Simulation, d.h. im Testlauf mit Tole-
*       ranzen wird die Transaktion aufgerufen und dann simuliert,
*       aber nicht gebucht
*----------------------------------------------------------------------*
*      -->P_KOART  text                                                *
*----------------------------------------------------------------------*
FORM echtlauf USING koart LIKE bseg-koart.
  CASE koart.
    WHEN 'D'.
      enqsubrc = '9'.
*----- Sperren des Kontos im Echtlauf oder bei Toleranzen --------------
      PERFORM sperren_konto USING koart tdebi-bukrs tdebi-kunnr
                      CHANGING enqsubrc.
      CASE enqsubrc.
        WHEN '2'.                      " Systemfehler beim Sperren
*----- Alle Sperren d. Transaktion freigeben, refresh iregus -----------
          PERFORM dequeue_all USING  koart.
          EXIT.
        WHEN OTHERS.                   " 0, 1, 3, 6
*----- 0 = Sperren OK , 1 = Konto gesperrt -----------------------------
*----- 3 = Sperreintrag in REGUS ---------------------------------------
*----- 6 = Sperreintrag in T042X ---------------------------------------

*----- Posten lesen, gruppieren, ausgeben u. ausziffern ----------------
          PERFORM indextabellen_fuellen USING koart.
*----- Entsperren des Kontos im Echtlauf -------------------------------
          IF enqsubrc = 0.
            PERFORM dequeue_all USING  koart.
          ENDIF.
      ENDCASE.
    WHEN 'K'.
      enqsubrc = '9'.
*----- Sperren des Kontos im Echtlauf oder bei Toleranzen --------------
      PERFORM sperren_konto USING koart tkredi-bukrs tkredi-lifnr
                      CHANGING enqsubrc.
      CASE enqsubrc.
        WHEN '2'.                      " Systemfehler
*----- Alle Sperren d. Transaktion freigeben, refresh iregus -----------
          PERFORM dequeue_all USING  koart.
          EXIT.
        WHEN OTHERS.                   " 0, 1, 3, 6
*0 sperren ok, 1 foreign lock, 3 regus Eintrag vorh., t042x Eintrag vorh
*----- Posten lesen, gruppieren, ausgeben u. ausziffern ----------------
          PERFORM indextabellen_fuellen USING koart.
*----- Entsperren des Kontos Echtlauf ----------------------------------
          IF enqsubrc = 0.
            PERFORM dequeue_all USING  koart.
          ENDIF.
      ENDCASE.
    WHEN 'S'.
      enqsubrc = '9'.
*----- Sperren des Kontos im Echtlauf oder bei Toleranzen --------------
      PERFORM sperren_konto USING koart tsako-bukrs tsako-hkont
                      CHANGING enqsubrc.
      CASE enqsubrc.
        WHEN '2'.                      " Systemfehler
*----- Alle Sperren d. Transaktion freigeben, refresh iregus -----------
          PERFORM dequeue_all USING  koart.
          EXIT.
        WHEN OTHERS.                   " 0, 1, 3, 6
*0 sperren ok, 1 foreign lock, 3 regus Eintrag vorh., t042x Eintrag vorh
*----- Posten lesen, gruppieren, ausgeben u. ausziffern ----------------
          PERFORM indextabellen_fuellen USING koart.
*----- Entsperren des Kontos im Echtlauf -------------------------------
          IF enqsubrc = 0.
            PERFORM dequeue_all USING  koart.
          ENDIF.
      ENDCASE.

  ENDCASE.
ENDFORM.                               " ECHTLAUF
*&---------------------------------------------------------------------*
*&      Form  TESTLAUF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_KOART  text                                                *
*----------------------------------------------------------------------*
FORM testlauf USING koart LIKE bseg-koart.
*----- Posten lesen, gruppieren, ausgeben ------------------------------
  PERFORM indextabellen_fuellen USING koart.
ENDFORM.                               " TESTLAUF
*&---------------------------------------------------------------------*
*&      Form  SPERREN_KONTO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sperren_konto USING i_koart LIKE bseg-koart
                         i_bukrs LIKE bseg-bukrs
                         i_konto
                CHANGING rc_enq  LIKE sy-subrc.
  DATA: kunnr LIKE knc1-kunnr,
        lifnr LIKE lfc1-lifnr,
        hkont LIKE bsis-hkont.

  CASE i_koart.
    WHEN char_d.
      kunnr = i_konto.
      CALL FUNCTION 'ENQUEUE_EFKNB1A'
           EXPORTING
                kunnr          = kunnr
                bukrs          = i_bukrs
                _scope         = '1'
*----- _scope = 1 = Sperre bleibt bei der Transaktion,------------------
*----- die sie angefordert hat -----------------------------------------
           EXCEPTIONS
                foreign_lock   = 1
                system_failure = 2.
      rc_enq = sy-subrc.
    WHEN char_k.
      lifnr = i_konto.
      CALL FUNCTION 'ENQUEUE_EFLFB1A'
        EXPORTING
          lifnr          = lifnr
          bukrs          = i_bukrs
          _scope         = '1'
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2.
      rc_enq = sy-subrc.
    WHEN char_s.
      hkont = i_konto.
      CALL FUNCTION 'ENQUEUE_EFSKB1A'
        EXPORTING
          saknr          = hkont
          bukrs          = i_bukrs
          _scope         = '1'
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2.
      rc_enq = sy-subrc.
  ENDCASE.
*
  IF koart EQ char_d
  OR koart EQ char_k.
    IF rc_enq EQ 0.
*     BUKRS/KOART darf in T042X nicht f.Zahlungsvorschlag gesperrt sein.
*     SAPF124 darf beim Ausgleichen nicht mit Zahlpgm konkurrieren.
*     Einträge in T042X von SAPF100 (F100XX) spielen keine Rolle.
      SELECT * FROM t042x WHERE koart EQ i_koart
                           AND  bukrs EQ i_bukrs
                           AND  laufi NE 'F100XX'.
        EXIT.
      ENDSELECT.
      IF sy-subrc IS INITIAL.
        rc_enq = 6.
      ELSE.
        regus-koart = i_koart.
        regus-bukrs = i_bukrs.
        regus-konko = i_konto.
        regus-laufd = sy-datum.
        regus-laufi = '$F124$'.
        INSERT regus.
        IF sy-subrc = 0.
          SELECT * FROM regus
                 WHERE koart EQ i_koart
                 AND   bukrs EQ i_bukrs
                 AND   konko EQ i_konto
                 AND   laufi NE '$F124$'.
            EXIT.
          ENDSELECT.
          IF sy-subrc NE 0.
            APPEND regus TO iregus.    "Sperren merken f. DEQUEUE_ALL
          ELSE.
            DELETE FROM regus WHERE koart = i_koart
                                AND bukrs = i_bukrs
                                AND konko = i_konto
                                AND laufd = sy-datum
                                AND laufi = '$F124$'.
            rc_enq = 3.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
*
  CHECK rc_enq NE 0.
*
* Die verschiedenen Sperrfälle und -fehler werden protokolliert
*
  CASE rc_enq.
    WHEN 1.
      PERFORM record_fill
              USING 'LOCK1' i_bukrs i_koart i_konto space space space
                            char_l.
    WHEN 2.
      PERFORM record_fill
              USING 'LOCK2' i_bukrs i_koart i_konto space space space
                            char_l.
    WHEN 3.
      PERFORM record_fill
              USING 'LOCK3' i_bukrs i_koart i_konto space space space
                            char_l.
    WHEN 6.
      PERFORM record_fill
              USING 'LOCK6' i_bukrs i_koart space space space space
                            char_l.
  ENDCASE.
ENDFORM.                               " SPERREN_KONTO
*---------------------------------------------------------------------*
*       FORM DEQUEUE_ALL                                              *
*---------------------------------------------------------------------*
*       Alle Sperren aufheben                                         *
*---------------------------------------------------------------------*
*
FORM dequeue_all USING i_koart LIKE bseg-koart.
* Alle Sperren zu einer Transaktion freigeben
  CALL FUNCTION 'DEQUEUE_ALL'.
*
  CHECK i_koart EQ char_d
  OR    i_koart EQ char_k.
*
* Einträge dieses SAPF124 löschen, sonst Deadlock bei parallelem Auszif.
  DELETE regus FROM TABLE iregus.
  REFRESH iregus.
ENDFORM.                               "DEQUEUE_ALL
*&---------------------------------------------------------------------*
*&      Form  INDEXTABELLEN_FUELLEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM indextabellen_fuellen USING i_koart LIKE bseg-koart.
  DATA:
    ls_xbsidgr LIKE LINE OF xbsidgr,
    ls_xbsikgr LIKE LINE OF xbsikgr,
    ls_xbsisgr LIKE LINE OF xbsisgr.

*DATA: OLD_HKONT LIKE BSEG-HKONT. "für Test
  CASE i_koart.
    WHEN 'D'.
*----- Wiederholten Aufruf bei gleichem Konto vermeiden ----------------
      IF save_kunnr NE tdebi-kunnr.
        save_kunnr = tdebi-kunnr.
        PERFORM regeln_vorbereiten USING koart tdebi-kunnr tdebi-bukrs.
      ENDIF.
*----- Lesen der BSID, Füllen der XBSID, XBSIDGR -----------------------
      bsid_subrc = 9.
      PERFORM read_bsid CHANGING bsid_subrc.
      CHECK bsid_subrc = 0.
*----- Überschrift Statistik, Zähler initialisieren --------------------
      IF flg_liste = '2' AND new_bukr = 'X'.
        PERFORM init_header_stat.
      ENDIF.
      IF flg_liste = '2'.
        suinf = 'X'.   " Flag für Summeninfo, at end of bukrs
      ENDIF.
*----- Sortieren XBSID, XBSIDGR ----------------------------------------
      PERFORM sortieren USING i_koart.
*----- Verarbeiten XBSIDGR ---------------------------------------------
      LOOP AT xbsidgr.
        ls_xbsidgr = xbsidgr.

        IF min_bel = 0.                                     "985181
          augdt = save_augdt.                               "985181
        ENDIF.
        AT NEW hkont.
          IF flg_liste = '3'.
            NEW-PAGE.
          ENDIF.
        ENDAT.
        PERFORM ausgleich USING koart xbsidgr-bet_bw.
        AT END OF xcurr.
          IF min_bel NE 0.
            PERFORM restbelege_buchen USING koart.
          ENDIF.
        ENDAT.
        AT END OF hkont.
**comment
**          PERFORM acc_end_of_account USING
**                                       'D'
**                                       ls_xbsidgr
**                                       ls_xbsikgr
**                                       ls_xbsisgr.

          IF flg_liste = '2'.
*         PERFORM STATISTIK USING KOART CNT_AP CNT_OP CNT_EAP ENQSUBRC.
            PERFORM statistik USING koart cnt_ap cnt_op cnt_eap enqsubrc
                                   tdebi-bukrs tdebi-kunnr xbsidgr-hkont.
            cnt_ap = 0.
            cnt_op = 0.
            cnt_eap = 0.
          ENDIF.
        ENDAT.
      ENDLOOP.
    WHEN 'K'.
*----- Wiederholten Aufruf bei gleichem Konto vermeiden ----------------
      IF save_lifnr NE tkredi-lifnr.
        save_lifnr = tkredi-lifnr.
        PERFORM regeln_vorbereiten USING koart tkredi-lifnr tkredi-bukrs.
      ENDIF.
*----- Lesen der BSIK, Füllen der XBSIK, XBSIKGR -----------------------
      bsik_subrc = 9.
      PERFORM read_bsik CHANGING bsik_subrc.
      CHECK bsik_subrc = 0.
*----- Überschrift Statistik, Zähler initialisieren --------------------
      IF flg_liste = '2' AND new_bukr = 'X'.
        PERFORM init_header_stat.
      ENDIF.
      IF flg_liste = '2'.
        suinf = 'X'.   " Flag für Summeninfo, at end of bukrs
      ENDIF.
*----- Sortieren XBSIK, XBSIKGR ----------------------------------------
      PERFORM sortieren USING i_koart.
*----- Verarbeiten XBSIDGR ---------------------------------------------
      LOOP AT xbsikgr.
        ls_xbsikgr = xbsikgr.

        IF min_bel = 0.                                     "985181
          augdt = save_augdt.                               "985181
        ENDIF.

        AT NEW hkont.
          IF flg_liste = '3'.
            NEW-PAGE.
          ENDIF.
        ENDAT.
        PERFORM ausgleich USING koart xbsikgr-bet_bw.
        AT END OF xcurr.
          IF min_bel NE 0.
            PERFORM restbelege_buchen USING koart.
          ENDIF.
        ENDAT.
        AT END OF hkont.
**cmment
**          PERFORM acc_end_of_account USING
**                                       'K'
**                                       ls_xbsidgr
**                                       ls_xbsikgr
**                                       ls_xbsisgr.
          IF flg_liste = '2'.
            PERFORM statistik USING koart cnt_ap cnt_op cnt_eap enqsubrc
                                 tkredi-bukrs tkredi-lifnr xbsikgr-hkont.
            cnt_ap  = 0.
            cnt_op  = 0.
            cnt_eap = 0.
          ENDIF.
        ENDAT.
      ENDLOOP.
    WHEN 'S'.
*----- Wiederholten Aufruf bei gleichem Konto vermeiden ----------------
      IF save_hkont NE tsako-hkont.
        save_hkont = tsako-hkont.
        PERFORM regeln_vorbereiten USING koart tsako-hkont tsako-bukrs.
      ENDIF.
*----- Lesen der BSIS, Füllen der XBSIS, XBSISGR -----------------------
*----- Sonderbearbeitung für WE/RE-Konten ------------------------------
      bsis_subrc = 9.
      PERFORM read_bsis CHANGING bsis_subrc.
      CHECK bsis_subrc = 0.
*----- Überschrift Statistik, Zähler initialisieren --------------------
      IF flg_liste = '2' AND new_bukr = 'X'.
        PERFORM init_header_stat.
      ENDIF.
      IF flg_liste = '2'.
        suinf = 'X'.   " Flag für Summeninfo, at end of bukrs
      ENDIF.
*----- Sortieren XBSIS, XBSISGR ----------------------------------------
      PERFORM sortieren USING i_koart.
*----- Verarbeiten XBSISGR ---------------------------------------------
      LOOP AT xbsisgr.
        ls_xbsisgr = xbsisgr.

        IF min_bel = 0.                                     "985181
          augdt = save_augdt.                               "985181
        ENDIF.

        AT NEW hkont.
          IF flg_liste = '3'.
            NEW-PAGE.
          ENDIF.
        ENDAT.
        IF xbsisgr-bet_tw = 0.
          PERFORM ausgleich USING koart xbsisgr-bet_tw.
        ELSE.
          READ TABLE iwere WITH KEY bukrs = bsis-bukrs
                                    hkont = bsis-hkont.
          IF sy-subrc = 0.
*----- Sonderbearbeitung WE/RE-Konten ----------------------------------
            PERFORM sonderverarbeitung_were.
          ELSE.
            PERFORM ausgleich USING koart xbsisgr-bet_tw.
          ENDIF.
        ENDIF.
        AT END OF xcurr.
          IF min_bel NE 0.
            PERFORM restbelege_buchen USING koart.
          ENDIF.
        ENDAT.
        AT END OF hkont.
**comment
**          PERFORM acc_end_of_account USING
**                                       'S'
**                                       ls_xbsidgr
**                                       ls_xbsikgr
**                                       ls_xbsisgr.
          IF flg_liste = '2'.
            PERFORM statistik USING koart cnt_ap cnt_op cnt_eap enqsubrc
                                   tsako-bukrs tsako-hkont xbsisgr-hkont.
            cnt_ap  = 0.
            cnt_op  = 0.
            cnt_eap = 0.
          ENDIF.
        ENDAT.
*    OLD_HKONT = XBSISGR-HKONT. "test
*    DELETE XBSISGR.
      ENDLOOP.                         "xbsisgr
  ENDCASE.
ENDFORM.                               " INDEXTABELLEN_FUELLEN
*&---------------------------------------------------------------------*
*&      Form  REGELN_VORBEREITEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM regeln_vorbereiten USING koart   LIKE bseg-koart
                              konto   LIKE if123-kont1
                              i_bukrs LIKE t001-bukrs.
  DATA: konto_vorh(1) TYPE c.
  CLEAR if123.
  SET EXTENDED CHECK OFF.
*----- Relevanter Bereich in Kopfzeile stellen -------------------------
  CLEAR konto_vorh.
  READ TABLE i001 WITH KEY bukrs = i_bukrs.
  IF sy-subrc = 0.
    LOOP AT if123
               WHERE ktopl EQ i001-ktopl
               AND   koart EQ koart.
      IF konto GE if123-kont1 AND
         konto LE if123-kont2.
        tabix = sy-tabix.
        konto_vorh = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF sy-subrc NE 0 OR konto_vorh = ' '.
    LOOP AT if123
               WHERE ktopl EQ space
               AND   koart EQ koart.
      IF konto GE if123-kont1 AND
         konto LE if123-kont2.
        tabix = sy-tabix.
        konto_vorh = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
  SET EXTENDED CHECK ON.
*----- Zeile merken, um unnötiges assign zu vermeiden ------------------
  IF last_tabix NE tabix OR xsobwere = 'X'.
    last_tabix = tabix.
    flg_bkpf = ' '.
    flg_bseg = ' '.
*----- Müssen später BKPF bzw. BSEG gelesen werden? --------------------
    PERFORM check_table USING 'BKPF' CHANGING flg_bkpf.
    PERFORM check_table USING 'BSEG' CHANGING flg_bseg.

    DO 5 TIMES VARYING bedgx FROM if123-bedg1 NEXT if123-bedg2
               VARYING tablx FROM if123-tabl1 NEXT if123-tabl2.
      IF bedgx NE space.
*----- Bedingungen werden den Feldsymbolen zugewiesen ------------------
        PERFORM feldsymbole USING bedgx tablx.
      ELSE.
*----- Initialisieren der Kriterien, weil sonst ------------------------
*----- die Indextabellen falsch gefüllt werden -------------------------
*----- z.B. wenn für ein Konto in Tabelle Tf123 ------------------------
*----- mehr oder weniger Bedingungen vereinbart ------------------------
*----- wurden als für ein anderes Konto --------------------------------
        CASE sy-index.
          WHEN '1'.
            krit1 = space.
          WHEN '2'.
            krit2 = space.
          WHEN '3'.
            krit3 = space.
          WHEN '4'.
            krit4 = space.
          WHEN '5'.
            krit5 = space.
        ENDCASE.
      ENDIF.
    ENDDO.
  ENDIF.
ENDFORM.                               " REGELN_VORBEREITEN
*---------------------------------------------------------------------*
*       FORM CHECK_TABLE                                              *
*---------------------------------------------------------------------*
*       Ist Tabelle TABLE in der internen Tabelle IF123 für das       *
*       aktuelle Kontonummerintervall enthalten, muß die Tabelle      *
*       nachgelesen werden - in diesem Fall wird FLG_TABLE gesetzt.   *
*       Beachte, daß die interne Tabelle IF123 bereits in             *
*       der Unterroutine CHECK_IF123 auf das aktuelle Kontonummer-    *
*       intervall eingestellt wurde.                                  *
*---------------------------------------------------------------------*
*  -->  TABLE       Tabelle ('BKPF', 'BSEG' ...)                      *
*  -->  FLG_TABLE   Flag                                              *
*---------------------------------------------------------------------*
FORM check_table
     USING    table LIKE if123-tabl1
     CHANGING flg_table TYPE c.
  DATA: tabl LIKE if123-tabl1.
*
  flg_table = char_0.
  DO 5 TIMES VARYING tabl FROM if123-tabl1 NEXT if123-tabl2.
    IF tabl EQ  table.
      flg_table = char_x.
      EXIT.
    ENDIF.
  ENDDO.
ENDFORM.                               "CHECK_TABLE
*---------------------------------------------------------------------*
*       FORM FELDSYMBOLE                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  BEDGX                                                         *
*  -->  TABLX                                                         *
*---------------------------------------------------------------------*
FORM feldsymbole USING    bedgx  LIKE if123-bedg1
                          tablx  LIKE if123-tabl1.

  DATA: bedingung(35) TYPE c.

  bedingung(4)   = tablx.
  bedingung+4(1) = '-'.
  bedingung+5(30) = bedgx.
  CASE sy-index.
    WHEN '1'.
      krit1 = bedingung.
      ASSIGN TABLE FIELD (bedingung) TO <f1>.
    WHEN '2'.
      krit2 = bedingung.
      ASSIGN TABLE FIELD (bedingung) TO <f2>.
    WHEN '3'.
      krit3 = bedingung.
      ASSIGN TABLE FIELD (bedingung) TO <f3>.
    WHEN '4'.
      krit4 = bedingung.
      ASSIGN TABLE FIELD (bedingung) TO <f4>.
    WHEN '5'.
      krit5 = bedingung.
      ASSIGN TABLE FIELD (bedingung) TO <f5>.
  ENDCASE.

ENDFORM.                    "FELDSYMBOLE
*&---------------------------------------------------------------------*
*&      Form  READ_BSID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_bsid CHANGING e_subrc LIKE sy-subrc.
  DATA: yt_avis09 TYPE  farmatch_payment_advices_list.
  DATA: yt_avis09_zeile TYPE farmatch_payment_advices.
  DATA: lt_bsidkey TYPE farmatch_items_table.
  DATA: ls_bsidkey TYPE farmatch_items.
  DATA: ld_ignore_doc(1) TYPE c.
  IF x_avisd = space.
*----- Normale OP's ----------------------------------------------------
    IF x_shbkn EQ space AND x_kunnr NE space.
      SELECT * FROM bsid
                          WHERE bukrs = tdebi-bukrs
                            AND kunnr = tdebi-kunnr
                            AND umsks EQ space
                            AND zuonr IN so_zuonr
                            AND gjahr IN gjahx
                            AND belnr IN docnr
                            AND budat IN postdate.
        CHECK bsid-xpypr = space.
*----- Zur Stornierung vorgemerkte Posten ausschließen, ----------------
*----- z.B. Abgrenzungsposten ------------------------------------------
        CHECK bsid-xstov = space.
        CLEAR: xbsid, xbsidgr.
        PERFORM check_authority_add                         "516329
        USING bsid-blart bsid-gsber                         "516329
        CHANGING rtc.                                       "516329
        CHECK rtc IS INITIAL.                               "516329
                                                            "516329
        IF tdebi-wt_newwt IS INITIAL                        "500429
        OR bsid-qsskz IS INITIAL.                           "500429
*----- Ist Belegbuchung zum Ausgleichsdatum erlaubt? -------------------
*----- Wird Ausgleichsdatum aus jüngstem Beleg bestimmt, werden Belege
*----- zunächst selektiert; die Prüfung kann dann erst im sapmf05a
*----- erfolgen, weil Ausgleichsdatum erst kurz vor call transaction
*----- bestimmt werden kann
          IF xf124e = space AND xaugdt = space.
            PERFORM currency_expiration_check USING    bsid-waers augdt
                                                       bsid-bukrs
                                              CHANGING ld_ignore_doc.
            CHECK ld_ignore_doc = space.
          ENDIF.
          IF gd_ebpp_active = 'X' AND bsid-zlsch NE space.
            PERFORM check_payment_method USING bsid-zlsch bsid-bukrs
                                         CHANGING ld_ignore_doc.
            CHECK ld_ignore_doc = space.
          ENDIF.
*----- Füllen der Gruppierungstabelle xbsidgr --------------------------
*----- und der Tabelle xbsid -------------------------------------------
          IF  bsid-rebzt IS INITIAL
          AND bsid-rebzg IS INITIAL.
            bsid-rebzg = bsid-belnr.
          ENDIF.
          PERFORM xbsid_xbsidgr_fuellen.
        ELSE.                                               "500429
          PERFORM record_fill                               "500429
          USING 'QSSKZ' bsid-bukrs koart bsid-kunnr bsid-hkont "500429
                bsid-belnr bsid-buzei char_x.               "500429
        ENDIF.                                              "500429
      ENDSELECT.
      e_subrc = sy-subrc.
      IF e_subrc NE 0.
*----- Keine Debitorenbelege selektiert --------------------------------
        PERFORM record_fill
            USING 'BSID ' space space space space space space char_s.
      ENDIF.
    ENDIF.
*----- Normale OP's und SHB-Vorgänge (außer 'A' und 'W') ---------------
    IF x_shbkn NE space AND x_kunnr NE space.
      ktopl = space.
      SELECT * FROM bsid
                          WHERE bukrs = tdebi-bukrs
                            AND kunnr = tdebi-kunnr
                            AND umsks NE char_w             "401470
                            AND zuonr IN so_zuonr
                            AND gjahr IN gjahx
                            AND belnr IN docnr
                            AND budat IN postdate
                            AND ( umskz IN shbkd OR umskz = space ).
                                                            "355602
        CHECK bsid-xpypr = space.
*----- Zur Stornierung vorgemerkte Posten ausschließen, ----------------
*----- z.B. Abgrenzungsposten ------------------------------------------
        CHECK bsid-xstov = space.
        CHECK bsid-bstat NE 'S'.                            "353740
        CLEAR: xbsid, xbsidgr.
        rtc = 0.
*----- Stat. SHB-Vorgänge ausschließen ---------------------------------
        IF bsid-umskz NE space.
          IF ktopl = space.
            READ TABLE i001 WITH KEY bukrs = tdebi-bukrs.
            ktopl = i001-ktopl.
          ENDIF.
          SELECT * FROM t030 WHERE ktopl = ktopl
                               AND ktosl = 'SGA'.
            CHECK t030-komok(1) = 'D'.
            IF t030-komok+1(1) = bsid-umskz.
              rtc = 4.
              EXIT.
            ENDIF.
          ENDSELECT.
        ENDIF.
        CHECK rtc = 0.
        PERFORM check_authority_add                         "516329
        USING bsid-blart bsid-gsber                         "516329
        CHANGING rtc.                                       "516329
        CHECK rtc IS INITIAL.                               "516329
                                                            "516329
        IF tdebi-wt_newwt IS INITIAL                        "500429
        OR bsid-qsskz IS INITIAL.                           "500429
*----- Ist Belegbuchung zum Ausgleichsdatum erlaubt? -------------------
*----- Wird Ausgleichsdatum aus jüngstem Beleg bestimmt, werden Belege
*----- zunächst selektiert; die Prüfung kann dann erst im sapmf05a *
*----- erfolgen, weil Ausgleichsdatum erst kurz vor call transaction
*----- bestimmt werden kann
          IF xf124e = space AND xaugdt = space.
            PERFORM currency_expiration_check USING    bsid-waers augdt
                                                       bsid-bukrs
                                              CHANGING ld_ignore_doc.
            CHECK ld_ignore_doc = space.
          ENDIF.

          IF gd_ebpp_active = 'X' AND bsid-zlsch NE space.
            PERFORM check_payment_method USING bsid-zlsch bsid-bukrs
                                         CHANGING ld_ignore_doc.
            CHECK ld_ignore_doc = space.
          ENDIF.

*----- Füllen der Gruppierungstabelle xbsidgr --------------------------
*----- und der Tabelle xbsid -------------------------------------------
          IF  bsid-rebzt IS INITIAL                         "496007
          AND bsid-rebzg IS INITIAL.
            bsid-rebzg = bsid-belnr.
          ENDIF.                                            "496007

          PERFORM xbsid_xbsidgr_fuellen.
        ELSE.                                               "500429
          PERFORM record_fill                               "500429
          USING 'QSSKZ' bsid-bukrs koart bsid-kunnr bsid-hkont "500429
                bsid-belnr bsid-buzei char_x.               "500429
        ENDIF.                                              "500429
      ENDSELECT.
      e_subrc = sy-subrc.
      IF e_subrc NE 0.
*----- Keine Debitorenbelege selektiert --------------------------------
        PERFORM record_fill
            USING 'BSID ' space space space space space space char_s.
      ENDIF.
    ENDIF.
*----- Nur Sonderhauptbuchvorgänge (außer 'A' und 'W') -----------------
    IF x_shbkn NE space AND x_kunnr EQ space.
      ktopl = space.
      SELECT * FROM bsid
                          WHERE bukrs = tdebi-bukrs
                            AND kunnr = tdebi-kunnr
                            AND umsks NE char_w             "401470
                            AND umskz NE space
                            AND zuonr IN so_zuonr
                            AND umskz IN shbkd              "355602
                            AND gjahr IN gjahx
                            AND belnr IN docnr
                            AND budat IN postdate.
        CHECK bsid-xpypr = space.
*----- Zur Stornierung vorgemerkte Posten ausschließen, ----------------
*----- z.B. Abgrenzungsposten ------------------------------------------
        CHECK bsid-xstov = space.
        CHECK bsid-bstat NE 'S'.                            "353740
        CLEAR: xbsid, xbsidgr.
        rtc = 0.
*----- Stat. SHB-Vorgänge ausschließen ---------------------------------
        IF bsid-umskz NE space.
          IF ktopl = space.
            READ TABLE i001 WITH KEY bukrs = tdebi-bukrs.
            ktopl = i001-ktopl.
          ENDIF.
          SELECT * FROM t030 WHERE ktopl = ktopl
                               AND ktosl = 'SGA'.
            CHECK t030-komok(1) = 'D'.
            IF t030-komok+1(1) = bsid-umskz.
              rtc = 4.
              EXIT.
            ENDIF.
          ENDSELECT.
        ENDIF.
        CHECK rtc = 0.
        PERFORM check_authority_add                         "516329
        USING bsid-blart bsid-gsber                         "516329
        CHANGING rtc.                                       "516329
        CHECK rtc IS INITIAL.                               "516329
                                                            "516329
        IF tdebi-wt_newwt IS INITIAL                        "500429
        OR bsid-qsskz IS INITIAL.                           "500429
*----- Ist Belegbuchung zum Ausgleichsdatum erlaubt? -------------------
*----- Wird Ausgleichsdatum aus jüngstem Beleg bestimmt, werden Belege
*----- zunächst selektiert; die Prüfung kann dann erst im sapmf05a *
*----- erfolgen, weil Ausgleichsdatum erst kurz vor call transaction
*----- bestimmt werden kann
          IF xf124e = space AND xaugdt = space.
            PERFORM currency_expiration_check USING   bsid-waers augdt
                                                      bsid-bukrs
                                             CHANGING ld_ignore_doc.
            CHECK ld_ignore_doc = space.
          ENDIF.

          IF gd_ebpp_active = 'X' AND bsid-zlsch NE space.
            PERFORM check_payment_method USING bsid-zlsch bsid-bukrs
                                         CHANGING ld_ignore_doc.
            CHECK ld_ignore_doc = space.
          ENDIF.

*----- Füllen der Gruppierungstabelle xbsidgr --------------------------
*----- und der Tabelle xbsid -------------------------------------------
          IF  bsid-rebzt IS INITIAL                         "496007
          AND bsid-rebzg IS INITIAL.
            bsid-rebzg = bsid-belnr.
          ENDIF.                                            "496007
          PERFORM xbsid_xbsidgr_fuellen.
        ELSE.                                               "500429
          PERFORM record_fill                               "500429
          USING 'QSSKZ' bsid-bukrs koart bsid-kunnr bsid-hkont "500429
                bsid-belnr bsid-buzei char_x.               "500429
        ENDIF.                                              "500429
      ENDSELECT.
      e_subrc = sy-subrc.
      IF e_subrc NE 0.
*----- Keine Debitorenbelege selektiert --------------------------------
        PERFORM record_fill
            USING 'BSID ' space space space space space space char_s.
      ENDIF.
    ENDIF.
  ELSE.
    PERFORM fill_gt_selavis.
    CALL FUNCTION 'FARMATCH_GET_PAYMENT_ADVICES'
      TABLES
        it_select     = gt_selavis
        et_pa_list    = yt_avis09
      EXCEPTIONS
        nothing_found = 1
        system_error  = 2
        OTHERS        = 3.
    e_subrc = sy-subrc.
    IF sy-subrc <> 0.
*----- Keine Debitorenbelege selektiert --------------------------------
      PERFORM record_fill
          USING 'BSID ' space space space space space space char_s.
    ENDIF.
    LOOP AT yt_avis09 INTO yt_avis09_zeile.
      lt_bsidkey = yt_avis09_zeile-items.
      LOOP AT lt_bsidkey INTO ls_bsidkey.
        SELECT SINGLE * FROM  bsid
               WHERE  bukrs  = ls_bsidkey-bukrs
               AND    kunnr  = ls_bsidkey-kunnr
               AND    umsks  = ls_bsidkey-umsks
               AND    umskz  = ls_bsidkey-umskz
               AND    augdt  = ls_bsidkey-augdt
               AND    augbl  = ls_bsidkey-augbl
               AND    zuonr  = ls_bsidkey-zuonr
               AND    gjahr  = ls_bsidkey-gjahr
               AND    belnr  = ls_bsidkey-belnr
               AND    buzei  = ls_bsidkey-buzei.
        IF sy-subrc = 0.
          bsid-xref3 = yt_avis09_zeile-avsid.
          CHECK bsid-gjahr IN gjahx.
          CHECK bsid-belnr IN docnr.
          CHECK bsid-zuonr IN so_zuonr.
          CHECK bsid-budat IN postdate.
          CHECK bsid-xpypr = space.
*----- Zur Stornierung vorgemerkte Posten ausschließen, ----------------
*----- z.B. Abgrenzungsposten ------------------------------------------
          CHECK bsid-xstov = space.
          CHECK bsid-bstat NE 'S'.
          CLEAR: xbsid, xbsidgr.
          rtc = 0.
*----- Stat. SHB-Vorgänge ausschließen ---------------------------------
          IF bsid-umskz NE space.
            IF ktopl = space.
              READ TABLE i001 WITH KEY bukrs = tdebi-bukrs.
              ktopl = i001-ktopl.
            ENDIF.
            SELECT * FROM t030 WHERE ktopl = ktopl
                                 AND ktosl = 'SGA'.
              CHECK t030-komok(1) = 'D'.
              IF t030-komok+1(1) = bsid-umskz.
                rtc = 4.
                EXIT.
              ENDIF.
            ENDSELECT.
          ENDIF.
          CHECK rtc = 0.
          PERFORM check_authority_add                       "516329
          USING bsid-blart bsid-gsber                       "516329
          CHANGING rtc.                                     "516329
          CHECK rtc IS INITIAL.                             "516329
                                                            "516329
          IF tdebi-wt_newwt IS INITIAL                      "500429
          OR bsid-qsskz IS INITIAL.                         "500429
*----- IST BELEGBUCHUNG ZUM AUSGLEICHSDATUM ERLAUBT? -------------------
*----- Wird Ausgleichsdatum aus jüngstem Beleg bestimmt, werden Belege
*----- zunächst selektiert; die Prüfung kann dann erst im sapmf05a *
*----- erfolgen, weil Ausgleichsdatum erst kurz vor call transaction
*----- bestimmt werden kann
            IF xf124e = space AND xaugdt = space.
              PERFORM currency_expiration_check USING    bsid-waers augdt
                                                         bsid-bukrs
                                                CHANGING ld_ignore_doc.
              CHECK ld_ignore_doc = space.
            ENDIF.

            IF gd_ebpp_active = 'X' AND bsid-zlsch NE space.
              PERFORM check_payment_method USING bsid-zlsch bsid-bukrs
                                           CHANGING ld_ignore_doc.
              CHECK ld_ignore_doc = space.
            ENDIF.

*----- Füllen der Gruppierungstabelle xbsidgr --------------------------
*----- und der Tabelle xbsid -------------------------------------------
            IF  bsid-rebzt IS INITIAL                       "496007
            AND bsid-rebzg IS INITIAL.
              bsid-rebzg = bsid-belnr.
            ENDIF.                                          "496007

            PERFORM xbsid_xbsidgr_fuellen.
          ELSE.                                             "500429
            PERFORM record_fill                             "500429
            USING 'QSSKZ' bsid-bukrs koart bsid-kunnr bsid-hkont "500429
                  bsid-belnr bsid-buzei char_x.             "500429
          ENDIF.                                            "500429
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDFORM.                               " READ_BSID
*&---------------------------------------------------------------------*
*&      Form  FILL_IT_SELAVIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_gt_selavis.
  REFRESH gt_selavis.
  CLEAR   gt_selavis.
  gt_selavis-sign   = 'I'.
  gt_selavis-option = 'EQ'.

  gt_selavis-field = 'BUKRS'.
  gt_selavis-low   = tdebi-bukrs.
  CLEAR gt_selavis-high.
  APPEND gt_selavis.

  gt_selavis-field = 'KONTO'.
  gt_selavis-low   = tdebi-kunnr.
  CLEAR gt_selavis-high.
  APPEND gt_selavis.
*----- Only consider advices which are confirmed -----------------------
  gt_selavis-field = 'ASTAT'.
  gt_selavis-low   = 'C'..
  CLEAR gt_selavis-high.
  APPEND gt_selavis.
ENDFORM.                               " FILL_GT_SELAVIS
*&---------------------------------------------------------------------*
*&      Form  READ_BSIK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_BSIK_SUBRC  text                                           *
*----------------------------------------------------------------------*
FORM read_bsik CHANGING e_subrc LIKE sy-subrc.
  DATA: ld_ignore_doc(1) TYPE c.
  CONSTANTS: ldc_paym_directive LIKE bsik-xref3 VALUE 'FMPO'. "861169

*----- Normale OP's ----------------------------------------------------
  IF x_shblf EQ space AND x_lifnr NE space.
    SELECT * FROM bsik
                        WHERE bukrs = tkredi-bukrs
                          AND lifnr = tkredi-lifnr
                          AND umsks EQ space
                          AND zuonr IN so_zuonr
                          AND gjahr IN gjahx
                          AND belnr IN docnr
                          AND budat IN postdate.
      CHECK bsik-xpypr = space.
*----- Zur Stornierung vorgemerkte Posten ausschließen, ----------------
*----- z.B. Abgrenzungsposten ------------------------------------------
      CHECK bsik-xstov = space.
      CLEAR: xbsik, xbsikgr.
      PERFORM check_authority_add                           "516329
      USING bsik-blart bsik-gsber                           "516329
      CHANGING rtc.                                         "516329
      CHECK rtc IS INITIAL.                                 "516329
                                                            "516329
*----- Füllen der Gruppierungstabelle xbsikgr --------------------------
*----- und der Tabelle xbsik -------------------------------------------
      IF bsik-qsshb NE 0.
        bsik-qsshb = 0.
      ENDIF.

      IF bsik-qsshb = 0
      OR ( bsik-xref3 = ldc_paym_directive                  "861169
       AND gb_eaps_active <> space                          "861169
       AND bsik-zlspr <> space ).                           "861169
*----- IST BELEGBUCHUNG ZUM AUSGLEICHSDATUM ERLAUBT? -------------------
*----- Wird Ausgleichsdatum aus jüngstem Beleg bestimmt, werden Belege
*----- zunächst selektiert; die Prüfung kann dann erst im sapmf05a *
*----- erfolgen, weil Ausgleichsdatum erst kurz vor call transaction
*----- bestimmt werden kann
        IF xf124e = space AND xaugdt = space.
          PERFORM currency_expiration_check USING    bsik-waers augdt
                                                     bsik-bukrs
                                              CHANGING ld_ignore_doc.
          CHECK ld_ignore_doc = space.
        ENDIF.
        IF  bsik-rebzt IS INITIAL                           "496007
        AND bsik-rebzg IS INITIAL.
          bsik-rebzg = bsik-belnr.
        ENDIF.                                              "496007

        PERFORM xbsik_xbsikgr_fuellen.
      ELSE.
        PERFORM record_fill
             USING 'QSSHB' bsik-bukrs koart bsik-lifnr bsik-hkont
                   bsik-belnr bsik-buzei char_x.
      ENDIF.
    ENDSELECT.
    e_subrc = sy-subrc.
    IF e_subrc NE 0.
*----- Keine Kreditorenbelege selektiert -------------------------------
      PERFORM record_fill
           USING 'BSIK ' space space space space space space char_s.
    ENDIF.
  ENDIF.
*----- Normale OP's und Sonderhauptbuchvorgänge (außer 'A' und 'W')-----
  IF x_shblf NE space AND x_lifnr NE space.
    ktopl = space.
    SELECT * FROM bsik
                        WHERE bukrs = tkredi-bukrs
                          AND lifnr = tkredi-lifnr
                          AND umsks NE char_w               "401470
                          AND zuonr IN so_zuonr
                          AND gjahr IN gjahx
                          AND belnr IN docnr
                          AND budat IN postdate
                          AND ( umskz IN shbkk OR umskz = space ).
                                                            "355602
      CHECK bsik-xpypr = space.
*----- Zur Stornierung vorgemerkte Posten ausschließen, ----------------
*----- z.B. Abgrenzungsposten ------------------------------------------
      CHECK bsik-xstov = space.
      CHECK bsik-bstat NE 'S'.                              "353740
      CLEAR: xbsik, xbsikgr.
      rtc = 0.
*----- Stat. SHB-Vorgänge ausschließen ---------------------------------
      IF bsik-umskz NE space.
        IF ktopl = space.
          READ TABLE i001 WITH KEY bukrs = tkredi-bukrs.
          ktopl = i001-ktopl.
        ENDIF.
        SELECT * FROM t030 WHERE ktopl = ktopl
                             AND ktosl = 'SGA'.
          CHECK t030-komok(1) = 'K'.
          IF t030-komok+1(1) = bsik-umskz.
            rtc = 4.
            EXIT.
          ENDIF.
        ENDSELECT.
      ENDIF.
      CHECK rtc = 0.
      PERFORM check_authority_add                           "516329
      USING bsik-blart bsik-gsber                           "516329
      CHANGING rtc.                                         "516329
      CHECK rtc IS INITIAL.                                 "516329
                                                            "516329
*----- Füllen der Gruppierungstabelle xbsikgr --------------------------
*----- und der Tabelle xbsik -------------------------------------------
      IF bsik-qsshb NE 0.
        bsik-qsshb = 0.
      ENDIF.
      IF bsik-qsshb = 0
      OR ( bsik-xref3 = ldc_paym_directive                  "861169
       AND gb_eaps_active <> space                          "861169
       AND bsik-zlspr <> space ).                           "861169
*----- IST BELEGBUCHUNG ZUM AUSGLEICHSDATUM ERLAUBT? -------------------
*----- Wird Ausgleichsdatum aus jüngstem Beleg bestimmt, werden Belege
*----- zunächst selektiert; die Prüfung kann dann erst im sapmf05a *
*----- erfolgen, weil Ausgleichsdatum erst kurz vor call transaction
*----- bestimmt werden kann
        IF xf124e = space AND xaugdt = space.
          PERFORM currency_expiration_check USING    bsik-waers augdt
                                                     bsik-bukrs
                                              CHANGING ld_ignore_doc.
          CHECK ld_ignore_doc = space.
        ENDIF.
        IF  bsik-rebzt IS INITIAL                           "496007
        AND bsik-rebzg IS INITIAL.
          bsik-rebzg = bsik-belnr.
        ENDIF.                                              "496007

        PERFORM xbsik_xbsikgr_fuellen.
      ELSE.
        PERFORM record_fill
             USING 'QSSHB' bsik-bukrs koart bsik-lifnr bsik-hkont
                   bsik-belnr bsik-buzei char_x.
      ENDIF.
    ENDSELECT.
    e_subrc = sy-subrc.
    IF e_subrc NE 0.
*----- Keine Kreditorenbelege selektiert -------------------------------
      PERFORM record_fill
          USING 'BSIK ' space space space space space space char_s.
    ENDIF.
  ENDIF.
*----- Nur Sonderhauptbuchvorgänge (außer 'A' und 'W') -----------------
  IF x_shblf NE space AND x_lifnr EQ space.
    ktopl = space.
    SELECT * FROM bsik
                        WHERE bukrs = tkredi-bukrs
                          AND lifnr = tkredi-lifnr
                          AND umsks NE char_w               "401470
                          AND umskz NE space
                          AND zuonr IN so_zuonr
                          AND umskz IN shbkk                "355602
                          AND gjahr IN gjahx
                          AND belnr IN docnr
                          AND budat IN postdate.
      CHECK bsik-xpypr = space.
*----- Zur Stornierung vorgemerkte Posten ausschließen, ----------------
*----- z.B. Abgrenzungsposten ------------------------------------------
      CHECK bsik-xstov = space.
      CHECK bsik-bstat NE 'S'.                              "353740
      CLEAR: xbsik, xbsikgr.
      rtc = 0.
*----- Stat. SHB-Vorgänge ausschließen ---------------------------------
      IF bsik-umskz NE space.
        IF ktopl = space.
          READ TABLE i001 WITH KEY bukrs = tkredi-bukrs.
          ktopl = i001-ktopl.
        ENDIF.
        SELECT * FROM t030 WHERE ktopl = ktopl
                             AND ktosl = 'SGA'.
          CHECK t030-komok(1) = 'K'.
          IF t030-komok+1(1) = bsik-umskz.
            rtc = 4.
            EXIT.
          ENDIF.
        ENDSELECT.
      ENDIF.
      CHECK rtc = 0.
      PERFORM check_authority_add                           "516329
      USING bsik-blart bsik-gsber                           "516329
      CHANGING rtc.                                         "516329
      CHECK rtc IS INITIAL.                                 "516329
                                                            "516329
*----- Füllen der Gruppierungstabelle xbsikgr --------------------------
*----- und der Tabelle xbsik -------------------------------------------
      IF bsik-qsshb NE 0.
        bsik-qsshb = 0.
      ENDIF.
      IF bsik-qsshb = 0
      OR ( bsik-xref3 = ldc_paym_directive                  "861169
       AND gb_eaps_active <> space                          "861169
       AND bsik-zlspr <> space ).                           "861169
*----- IST BELEGBUCHUNG ZUM AUSGLEICHSDATUM ERLAUBT? -------------------
*----- Wird Ausgleichsdatum aus jüngstem Beleg bestimmt, werden Belege
*----- zunächst selektiert; die Prüfung kann dann erst im sapmf05a *
*----- erfolgen, weil Ausgleichsdatum erst kurz vor call transaction
*----- bestimmt werden kann
        IF xf124e = space AND xaugdt = space.
          PERFORM currency_expiration_check USING     bsik-waers augdt
                                                      bsik-bukrs
                                             CHANGING ld_ignore_doc.
          CHECK ld_ignore_doc = space.
        ENDIF.
        IF  bsik-rebzt IS INITIAL                           "496007
        AND bsik-rebzg IS INITIAL.
          bsik-rebzg = bsik-belnr.
        ENDIF.                                              "496007

        PERFORM xbsik_xbsikgr_fuellen.
      ELSE.
        PERFORM record_fill
             USING 'QSSHB' bsik-bukrs koart bsik-lifnr bsik-hkont
                   bsik-belnr bsik-buzei char_x.
      ENDIF.
    ENDSELECT.
    e_subrc = sy-subrc.
    e_subrc = sy-subrc.
    IF e_subrc NE 0.
*----- Keine Kreditorenbelege selektiert -------------------------------
      PERFORM record_fill
          USING 'BSIK ' space space space space space space char_s.
    ENDIF.
  ENDIF.

ENDFORM.                               " READ_BSIK
*&---------------------------------------------------------------------*
*&      Form  READ_BSIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_BSIS_SUBRC  text                                           *
*----------------------------------------------------------------------*
FORM read_bsis CHANGING e_subrc LIKE sy-subrc.
  DATA: subrcbseg LIKE sy-subrc.
  DATA: ld_ignore_doc(1) TYPE c.

  IF x_saknr NE space.
    READ TABLE i030_skv WITH KEY bukrs = tsako-bukrs
                                 konts = tsako-hkont.
    IF sy-subrc <> 0.                  "SY-SUBRC=0 -> SKV-Konto
      REFRESH ibsis.                                        "454904
* ---If account is not ledger group specific clearable
      IF tsako-xlgclr IS INITIAL.
        SELECT * FROM bsis
                         WHERE bukrs = tsako-bukrs
                           AND hkont = tsako-hkont
                           AND zuonr IN so_zuonr
                           AND gjahr IN gjahx
                           AND belnr IN docnr
                           AND budat IN postdate
                           AND xopvw EQ char_x.
          CLEAR ibsis-ldgrp.
          PERFORM check_authority_add                       "516329
          USING bsis-blart bsis-gsber                       "516329
          CHANGING rtc.                                     "516329
          CHECK rtc IS INITIAL.                             "516329
                                                            "516329
*----- IST BELEGBUCHUNG ZUM AUSGLEICHSDATUM ERLAUBT? -------------------
*----- Wird Ausgleichsdatum aus jüngstem Beleg bestimmt, werden Belege
*----- zunächst selektiert; die Prüfung kann dann erst im sapmf05a *
*----- erfolgen, weil Ausgleichsdatum erst kurz vor call transaction
*----- bestimmt werden kann
          IF xf124e = space AND xaugdt = space.
            PERFORM currency_expiration_check USING     bsis-pswsl augdt
                                                        bsis-bukrs
                                               CHANGING ld_ignore_doc.
            CHECK ld_ignore_doc = space.
          ENDIF.

          MOVE bsis TO ibsis-bsis.
          APPEND ibsis.
        ENDSELECT.
* ---If account is ledger group specific clearable
      ELSE.
        SELECT * FROM faglbsis
                     WHERE bukrs = tsako-bukrs
                       AND hkont = tsako-hkont
                       AND zuonr IN so_zuonr
                       AND gjahr IN gjahx
                       AND belnr IN docnr
                       AND budat IN postdate
                       AND ldgrp IN p_lg.
          MOVE-CORRESPONDING faglbsis TO bsis.
          ibsis-ldgrp = faglbsis-ldgrp.
          PERFORM check_authority_add                       "516329
                  USING bsis-blart bsis-gsber               "516329
                  CHANGING rtc.                             "516329
          CHECK rtc IS INITIAL.                             "516329
                                                            "516329
*----- IST BELEGBUCHUNG ZUM AUSGLEICHSDATUM ERLAUBT? -------------------
*----- Wird Ausgleichsdatum aus jüngstem Beleg bestimmt, werden Belege
*----- zunächst selektiert; die Prüfung kann dann erst im sapmf05a *
*----- erfolgen, weil Ausgleichsdatum erst kurz vor call transaction
*----- bestimmt werden kann
          IF xf124e = space AND xaugdt = space.
            PERFORM currency_expiration_check USING     bsis-pswsl augdt
                                                        bsis-bukrs
                                               CHANGING ld_ignore_doc.
            CHECK ld_ignore_doc = space.
          ENDIF.

          MOVE bsis TO ibsis-bsis.
          APPEND ibsis.
        ENDSELECT.
      ENDIF.
*----- WE/RE-Konto? ----------------------------------------------------
      IF xsobwere = 'X'.
        READ TABLE iwere WITH KEY
                               bukrs = tsako-bukrs hkont = tsako-hkont.
        IF sy-subrc = 0.
          LOOP AT ibsis.
            bsis = ibsis-bsis.
            PERFORM read_bseg_neu USING bsis-bukrs bsis-belnr
                                        bsis-gjahr bsis-buzei
                                  CHANGING subrcbseg.
            IF subrcbseg = 0.
              ibsis-ebeln = bseg-ebeln.
              ibsis-ebelp = bseg-ebelp.
              MODIFY ibsis.
            ENDIF.
          ENDLOOP.
          SORT ibsis BY ebeln ebelp bsis-gjahr bsis-belnr bsis-buzei.
        ENDIF.
      ENDIF.

      LOOP AT ibsis.
        AT NEW ebelp.                                       "454904
          REFRESH iekbe.                                    "454904
          rcekbe = 4.                                       "454904
          rciekbe = 4.                                      "454904
        ENDAT.                                              "454904
        bsis = ibsis-bsis.
        bseg-ebeln = ibsis-ebeln.                           "454904
        bseg-ebelp = ibsis-ebelp.                           "454904
*----- Zur Stornierung vorgemerkte Posten ausschließen, ----------------
*----- z.B. Abgrenzungsposten ------------------------------------------
        CHECK bsis-xstov = space.
        CLEAR: xbsis, xbsisgr.
*----- Fuellen der Gruppierungstabelle xbsisgr -------------------------
*----- und der Tabelle xbsis -------------------------------------------
*----- Sonderbearbeitung für WE/RE-Konten ------------------------------
        PERFORM xbsis_xbsisgr_fuellen.
        IF x_exit = 'X'.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF x_exit = 'X'.
        REFRESH ibsis.
      ENDIF.
      e_subrc = sy-subrc.
    ELSE.
      e_subrc = 7.
    ENDIF.
    IF e_subrc NE 0 AND e_subrc NE 7.
*----- Keine Sachkontenbelege selektiert -------------------------------
      PERFORM record_fill
          USING 'BSIS ' tsako-bukrs space space tsako-hkont space space char_s.
    ENDIF.
  ENDIF.
ENDFORM.                               " READ_BSIS
*&---------------------------------------------------------------------*
*----------------------------------------------------------------"516329
FORM check_authority_add USING id_blart LIKE bkpf-blart     "516329
                               id_gsber LIKE bseg-gsber     "516329
                         CHANGING cd_subrc LIKE sy-subrc.   "516329
  DATA: ld_aktvt LIKE tact-actvt VALUE '03',                "516329
        ld_rtcode TYPE n.                                   "516329
                                                            "516329
  CLEAR: cd_subrc, ld_rtcode.                               "516329
  IF NOT gb_xaubl IS INITIAL.                               "516329
    CALL FUNCTION 'FI_BLART_AUTH_CHECK'                     "516329
    EXPORTING i_blart = id_blart                            "516329
              i_aktvt = ld_aktvt                            "516329
    IMPORTING e_rtcode = ld_rtcode.                         "516329
  ENDIF.                                                    "516329
  IF NOT gb_xaugs IS INITIAL                                "516329
  AND ld_rtcode IS INITIAL                                  "516329
  AND NOT id_gsber IS INITIAL.                              "516329
    CALL FUNCTION 'FI_GSBER_AUTH_CHECK'                     "516329
    EXPORTING i_gsber = id_gsber                            "516329
              i_aktvt = ld_aktvt                            "516329
    IMPORTING e_rtcode = ld_rtcode.                         "516329
  ENDIF.                                                    "516329
  IF NOT ld_rtcode IS INITIAL.                              "516329
    cd_subrc = '4'.                                         "516329
  ENDIF.                                                    "516329
ENDFORM.                                                    "516329
*&---------------------------------------------------------------------*
*&      Form  XBSID_XBSIDGR_FUELLEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM xbsid_xbsidgr_fuellen.
  DATA: subrcbkpf LIKE sy-subrc.
  DATA: subrcbseg LIKE sy-subrc.
  DATA: ld_ignore_doc(1) TYPE c.

  CLEAR xwrbtr.
  IF bsid-pswbt = 0.
    PERFORM fill_pswbt USING    bsid-bukrs bsid-waers bsid-dmbtr
                                bsid-wrbtr ' '
                       CHANGING bsid-pswbt.
  ENDIF.

  MOVE-CORRESPONDING bsid TO xbsid.
  IF xf124e = 'X'.
    PERFORM  wrbtr_umrechnen USING koart
                             CHANGING ld_ignore_doc.
    CHECK ld_ignore_doc = space.
  ENDIF.
  IF xwrbtr = 'X'.
    xbsid-xcurr = awaers.
  ELSE.
    xbsid-xamnt = xbsid-wrbtr.
    xbsid-xcurr = xbsid-waers.
  ENDIF.

  MOVE-CORRESPONDING xbsid TO xbsidgr.
  IF bsid-shkzg = 'H'.
    xbsidgr-bet_bw = - xbsid-xamnt.
  ELSE.
    xbsidgr-bet_bw =  xbsid-xamnt.
  ENDIF.

  IF x_avisd = 'X'.
    PERFORM feldsymbole_veraendern_avis.
  ENDIF.
  IF flg_bkpf = 'X'.
    PERFORM read_bkpf_neu
    USING bsid-bukrs bsid-belnr bsid-gjahr 'X'              "455320
    CHANGING subrcbkpf.
    CHECK subrcbkpf = 0.
  ENDIF.
  IF flg_bseg = 'X'.
    PERFORM read_bseg_neu USING bsid-bukrs bsid-belnr bsid-gjahr
                                bsid-buzei
                          CHANGING subrcbseg.
    CHECK subrcbseg = 0.
  ENDIF.

  IF NOT krit1 IS INITIAL.
    xbsidgr-krit1 = krit1.
    xbsid-krit1 = krit1.
    PERFORM check_betragsfelder USING krit1.                "365889
    IF NOT x_betrag IS INITIAL.                             "418389
      MOVE <f1> TO xbsid-bedg1.                             "365889
      MOVE <f1> TO xbsidgr-bedg1.                           "365889
    ELSE.                                                   "365889
      WRITE <f1> TO xbsid-bedg1.                            "333215
      WRITE <f1> TO xbsidgr-bedg1.                          "333215
    ENDIF.                                                  "365889
*----- Fuehrende Leerzeichen entfernen, f. Betraege notwendig ----------
    IF NOT xbsid-bedg1 IS INITIAL.
      WHILE xbsid-bedg1(01) IS INITIAL.
        SHIFT xbsid-bedg1.
        SHIFT xbsidgr-bedg1.
      ENDWHILE.
    ENDIF.
  ENDIF.

  IF NOT krit2 IS INITIAL.
    xbsidgr-krit2 = krit2.
    xbsid-krit2 = krit2.
    PERFORM check_betragsfelder USING krit2.                "365889
    IF NOT x_betrag IS INITIAL.                             "418389
      MOVE <f2> TO xbsid-bedg2.                             "365889
      MOVE <f2> TO xbsidgr-bedg2.                           "365889
    ELSE.                                                   "365889
      WRITE <f2> TO xbsid-bedg2.                            "333215
      WRITE <f2> TO xbsidgr-bedg2.                          "333215
    ENDIF.                                                  "365889
*----- Fuehrende Leerzeichen entfernen, f. Betraege notwendig ----------
    IF NOT xbsid-bedg2 IS INITIAL.
      WHILE xbsid-bedg2(01) IS INITIAL.
        SHIFT xbsid-bedg2.
        SHIFT xbsidgr-bedg2.
      ENDWHILE.
    ENDIF.
  ENDIF.

  IF NOT krit3 IS INITIAL.
    xbsidgr-krit3 = krit3.
    xbsid-krit3 = krit3.
    PERFORM check_betragsfelder USING krit3.                "365889
    IF NOT x_betrag IS INITIAL.                             "418389
      MOVE <f3> TO xbsid-bedg3.                             "365889
      MOVE <f3> TO xbsidgr-bedg3.                           "365889
    ELSE.                                                   "365889
      WRITE <f3> TO xbsid-bedg3.                            "333215
      WRITE <f3> TO xbsidgr-bedg3.                          "333215
    ENDIF.                                                  "365889
*----- Fuehrende Leerzeichen entfernen, f. Betraege notwendig ----------
    IF NOT xbsid-bedg3 IS INITIAL.
      WHILE xbsid-bedg3(01) IS INITIAL.
        SHIFT xbsid-bedg3.
        SHIFT xbsidgr-bedg3.
      ENDWHILE.
    ENDIF.
  ENDIF.

  IF NOT krit4 IS INITIAL.
    xbsidgr-krit4 = krit4.
    xbsid-krit4 = krit4.
    PERFORM check_betragsfelder USING krit4.                "365889
    IF NOT x_betrag IS INITIAL.                             "418389
      MOVE <f4> TO xbsid-bedg4.                             "365889
      MOVE <f4> TO xbsidgr-bedg4.                           "365889
    ELSE.                                                   "365889
      WRITE <f4> TO xbsid-bedg4.                            "333215
      WRITE <f4> TO xbsidgr-bedg4.                          "333215
    ENDIF.                                                  "365889
*----- Fuehrende Leerzeichen entfernen, f. Betraege notwendig ----------
    IF NOT xbsid-bedg4 IS INITIAL.
      WHILE xbsid-bedg4(01) IS INITIAL.
        SHIFT xbsid-bedg4.
        SHIFT xbsidgr-bedg4.
      ENDWHILE.
    ENDIF.
  ENDIF.

  IF NOT krit5 IS INITIAL.
    xbsidgr-krit5 = krit5.
    xbsid-krit5 = krit5.
    PERFORM check_betragsfelder USING krit5.                "365889
    IF NOT x_betrag IS INITIAL.                             "418389
      MOVE <f5> TO xbsid-bedg5.                             "365889
      MOVE <f5> TO xbsidgr-bedg5.                           "365889
    ELSE.                                                   "365889
      WRITE <f5> TO xbsid-bedg5.                            "333215
      WRITE <f5> TO xbsidgr-bedg5.                          "333215
    ENDIF.                                                  "365889
*----- Fuehrende Leerzeichen entfernen, f. Betraege notwendig ----------
    IF NOT xbsid-bedg5 IS INITIAL.
      WHILE xbsid-bedg5(01) IS INITIAL.
        SHIFT xbsid-bedg5.
        SHIFT xbsidgr-bedg5.
      ENDWHILE.
    ENDIF.
  ENDIF.
  APPEND xbsid.
  COLLECT xbsidgr.

ENDFORM.                               " XBSID_XBSIDGR_FUELLEN
*&---------------------------------------------------------------------*
*&      Form  XBSIK_XBSIKGR_FUELLEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM xbsik_xbsikgr_fuellen.
  DATA: subrcbkpf LIKE sy-subrc.
  DATA: subrcbseg LIKE sy-subrc.
  DATA: ld_ignore_doc(1) TYPE c.

  CLEAR xwrbtr.
  IF bsik-pswbt = 0.
    PERFORM fill_pswbt USING bsik-bukrs bsik-waers bsik-dmbtr
                             bsik-wrbtr ' '
                    CHANGING bsik-pswbt.
  ENDIF.

  MOVE-CORRESPONDING bsik TO xbsik.
  IF xf124e = 'X'.
    PERFORM  wrbtr_umrechnen USING koart
                          CHANGING ld_ignore_doc.
    CHECK ld_ignore_doc = space.
  ENDIF.
  IF xwrbtr = 'X'.
    xbsik-xcurr = awaers.
  ELSE.
    xbsik-xamnt = xbsik-wrbtr.
    xbsik-xcurr = xbsik-waers.
  ENDIF.

  MOVE-CORRESPONDING xbsik TO xbsikgr.
  IF bsik-shkzg = 'H'.
    xbsikgr-bet_bw = - xbsik-xamnt.
  ELSE.
    xbsikgr-bet_bw =  xbsik-xamnt.
  ENDIF.

  IF flg_bkpf = 'X'.
    PERFORM read_bkpf_neu
    USING bsik-bukrs bsik-belnr bsik-gjahr 'X'              "455320
    CHANGING subrcbkpf.
    CHECK subrcbkpf = 0.
  ENDIF.
  IF flg_bseg = 'X'.
    PERFORM read_bseg_neu USING bsik-bukrs bsik-belnr bsik-gjahr
                                bsik-buzei
                          CHANGING subrcbseg.
    CHECK subrcbseg = 0.
  ENDIF.

  IF NOT krit1 IS INITIAL.
    xbsikgr-krit1 = krit1.
    xbsik-krit1 = krit1.
    PERFORM check_betragsfelder USING krit1.                "365889
    IF NOT x_betrag IS INITIAL.                             "418389
      MOVE <f1> TO xbsik-bedg1.                             "365889
      MOVE <f1> TO xbsikgr-bedg1.                           "365889
    ELSE.                                                   "365889
      WRITE <f1> TO xbsik-bedg1.                            "333215
      WRITE <f1> TO xbsikgr-bedg1.                          "333215
    ENDIF.                                                  "365889
*----- Fuehrende Leerzeichen entfernen, f. Betraege notwendig ----------
    IF NOT xbsik-bedg1 IS INITIAL.
      WHILE xbsik-bedg1(01) IS INITIAL.
        SHIFT xbsik-bedg1.
        SHIFT xbsikgr-bedg1.
      ENDWHILE.
    ENDIF.
  ENDIF.

  IF NOT krit2 IS INITIAL.
    xbsikgr-krit2 = krit2.
    xbsik-krit2 = krit2.
    PERFORM check_betragsfelder USING krit2.                "365889
    IF NOT x_betrag IS INITIAL.                             "418389
      MOVE <f2> TO xbsik-bedg2.                             "365889
      MOVE <f2> TO xbsikgr-bedg2.                           "365889
    ELSE.                                                   "365889
      WRITE <f2> TO xbsik-bedg2.                            "333215
      WRITE <f2> TO xbsikgr-bedg2.                          "333215
    ENDIF.                                                  "365889
*----- Fuehrende Leerzeichen entfernen, f. Betraege notwendig ----------
    IF NOT xbsik-bedg2 IS INITIAL.
      WHILE xbsik-bedg2(01) IS INITIAL.
        SHIFT xbsik-bedg2.
        SHIFT xbsikgr-bedg2.
      ENDWHILE.
    ENDIF.
  ENDIF.

  IF NOT krit3 IS INITIAL.
    xbsikgr-krit3 = krit3.
    xbsik-krit3 = krit3.
    PERFORM check_betragsfelder USING krit3.                "365889
    IF NOT x_betrag IS INITIAL.                             "418389
      MOVE <f3> TO xbsik-bedg3.                             "365889
      MOVE <f3> TO xbsikgr-bedg3.                           "365889
    ELSE.                                                   "365889
      WRITE <f3> TO xbsik-bedg3.                            "333215
      WRITE <f3> TO xbsikgr-bedg3.                          "333215
    ENDIF.                                                  "365889
*----- Fuehrende Leerzeichen entfernen, f. Betraege notwendig ----------
    IF NOT xbsik-bedg3 IS INITIAL.
      WHILE xbsik-bedg3(01) IS INITIAL.
        SHIFT xbsik-bedg3.
        SHIFT xbsikgr-bedg3.
      ENDWHILE.
    ENDIF.
  ENDIF.

  IF NOT krit4 IS INITIAL.
    xbsikgr-krit4 = krit4.
    xbsik-krit4 = krit4.
    PERFORM check_betragsfelder USING krit4.                "365889
    IF NOT x_betrag IS INITIAL.                             "418389
      MOVE <f4> TO xbsik-bedg4.                             "365889
      MOVE <f4> TO xbsikgr-bedg4.                           "365889
    ELSE.                                                   "365889
      WRITE <f4> TO xbsik-bedg4.                            "333215
      WRITE <f4> TO xbsikgr-bedg4.                          "333215
    ENDIF.                                                  "365889
*----- Fuehrende Leerzeichen entfernen, f. Betraege notwendig ----------
    IF NOT xbsik-bedg4 IS INITIAL.
      WHILE xbsik-bedg4(01) IS INITIAL.
        SHIFT xbsik-bedg4.
        SHIFT xbsikgr-bedg4.
      ENDWHILE.
    ENDIF.
  ENDIF.

  IF NOT krit5 IS INITIAL.
    xbsikgr-krit5 = krit5.
    xbsik-krit5 = krit5.
    PERFORM check_betragsfelder USING krit5.                "365889
    IF NOT x_betrag IS INITIAL.                             "418389
      MOVE <f5> TO xbsik-bedg5.                             "365889
      MOVE <f5> TO xbsikgr-bedg5.                           "365889
    ELSE.                                                   "365889
      WRITE <f5> TO xbsik-bedg5.                            "333215
      WRITE <f5> TO xbsikgr-bedg5.                          "333215
    ENDIF.                                                  "365889
*----- Fuehrende Leerzeichen entfernen, f. Betraege notwendig ----------
    IF NOT xbsik-bedg5 IS INITIAL.
      WHILE xbsik-bedg5(01) IS INITIAL.
        SHIFT xbsik-bedg5.
        SHIFT xbsikgr-bedg5.
      ENDWHILE.
    ENDIF.
  ENDIF.

  APPEND xbsik.
  COLLECT xbsikgr.

ENDFORM.                               " XBSIK_XBSIKGR_FUELLEN
*&---------------------------------------------------------------------*
*&      Form  XBSIS_XBSISGR_FUELLEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM xbsis_xbsisgr_fuellen.
  DATA: subrcbkpf LIKE sy-subrc.
  DATA: subrcbseg LIKE sy-subrc.
  DATA: ld_ignore_doc(1) TYPE c.

  CLEAR xwrbtr.
  IF bsis-pswbt = 0.
    PERFORM fill_pswbt USING    bsis-bukrs bsis-waers bsis-dmbtr
                                bsis-wrbtr 'X'
                       CHANGING bsis-pswbt.
  ENDIF.

  MOVE-CORRESPONDING bsis TO xbsis.
  xbsis-ldgrp = ibsis-ldgrp.
  IF xf124e = 'X'.
    PERFORM  wrbtr_umrechnen USING koart
                          CHANGING ld_ignore_doc.
    CHECK ld_ignore_doc = space.
  ENDIF.
  IF xwrbtr = 'X'.
    xbsis-xcurr = awaers.
  ELSE.
    xbsis-xamnt = xbsis-pswbt.
    xbsis-xcurr = xbsis-pswsl.
  ENDIF.

  MOVE-CORRESPONDING xbsis TO xbsisgr.
  IF bsis-shkzg = 'H'.
    xbsisgr-bet_tw = - xbsis-xamnt.
  ELSE.
    xbsisgr-bet_tw =  xbsis-xamnt.
  ENDIF.

  IF xsobebvk = 'X'.
    PERFORM feldsymbole_veraendern_bvk USING bsis-bukrs bsis-hkont.
  ENDIF.
  xsobeerf = 'X'.
*----- Sonderbearbeitung für WE/RE-Konten ------------------------------
  IF xsobwere = 'X'.
    PERFORM sonderbearbeitung_were CHANGING subrcbkpf subrcbseg.
    CHECK subrcbkpf = 0 AND subrcbseg = 0.
  ENDIF.

  IF flg_bkpf = 'X'.
    PERFORM read_bkpf_neu
    USING bsis-bukrs bsis-belnr bsis-gjahr 'X'              "455320
    CHANGING subrcbkpf.
    CHECK subrcbkpf = 0.
  ENDIF.
  IF flg_bseg = 'X'.                                        "454904
    PERFORM read_bseg_neu USING bsis-bukrs bsis-belnr bsis-gjahr
                                bsis-buzei
                          CHANGING subrcbseg.
    CHECK subrcbseg = 0.
  ENDIF.

  IF NOT krit1 IS INITIAL.
    xbsisgr-krit1 = krit1.
    xbsis-krit1 = krit1.
    IF xsobeerf = 'X'.
      PERFORM check_betragsfelder USING krit1.              "365889
      IF NOT x_betrag IS INITIAL.                           "418389
        MOVE <f1> TO xbsis-bedg1.                           "365889
        MOVE <f1> TO xbsisgr-bedg1.                         "365889
      ELSE.                                                 "365889
        WRITE <f1> TO xbsis-bedg1.                          "333215
        WRITE <f1> TO xbsisgr-bedg1.                        "333215
      ENDIF.                                                "365889
*----- Fuehrende Leerzeichen entfernen, f. Betraege notwendig ----------
      IF NOT xbsis-bedg1 IS INITIAL.
        WHILE xbsis-bedg1(01) IS INITIAL.
          SHIFT xbsis-bedg1.
          SHIFT xbsisgr-bedg1.
        ENDWHILE.
      ENDIF.
    ENDIF.
  ENDIF.

  IF NOT krit2 IS INITIAL.
    xbsisgr-krit2 = krit2.
    xbsis-krit2 = krit2.
    PERFORM check_betragsfelder USING krit2.                "365889
    IF NOT x_betrag IS INITIAL.                             "418389
      MOVE <f2> TO xbsis-bedg2.                             "365889
      MOVE <f2> TO xbsisgr-bedg2.                           "365889
    ELSE.                                                   "365889
      WRITE <f2> TO xbsis-bedg2.                            "333215
      WRITE <f2> TO xbsisgr-bedg2.                          "333215
    ENDIF.                                                  "365889
*----- Fuehrende Leerzeichen entfernen, f. Betraege notwendig ----------
    IF NOT xbsis-bedg2 IS INITIAL.
      WHILE xbsis-bedg2(01) IS INITIAL.
        SHIFT xbsis-bedg2.
        SHIFT xbsisgr-bedg2.
      ENDWHILE.
    ENDIF.
  ENDIF.

  IF NOT krit3 IS INITIAL.
    xbsisgr-krit3 = krit3.
    xbsis-krit3 = krit3.
    PERFORM check_betragsfelder USING krit3.                "365889
    IF NOT x_betrag IS INITIAL.                             "418389
      MOVE <f3> TO xbsis-bedg3.                             "365889
      MOVE <f3> TO xbsisgr-bedg3.                           "365889
    ELSE.                                                   "365889
      WRITE <f3> TO xbsis-bedg3.                            "333215
      WRITE <f3> TO xbsisgr-bedg3.                          "333215
    ENDIF.                                                  "365889
*----- Fuehrende Leerzeichen entfernen, f. Betraege notwendig ----------
    IF NOT xbsis-bedg3 IS INITIAL.
      WHILE xbsis-bedg3(01) IS INITIAL.
        SHIFT xbsis-bedg3.
        SHIFT xbsisgr-bedg3.
      ENDWHILE.
    ENDIF.
  ENDIF.

  IF NOT krit4 IS INITIAL.
    xbsisgr-krit4 = krit4.
    xbsis-krit4 = krit4.
    PERFORM check_betragsfelder USING krit4.                "365889
    IF NOT x_betrag IS INITIAL.                             "418389
      MOVE <f4> TO xbsis-bedg4.                             "365889
      MOVE <f4> TO xbsisgr-bedg4.                           "365889
    ELSE.                                                   "365889
      WRITE <f4> TO xbsis-bedg4.                            "333215
      WRITE <f4> TO xbsisgr-bedg4.                          "333215
    ENDIF.                                                  "365889
*----- Fuehrende Leerzeichen entfernen, f. Betraege notwendig ----------
    IF NOT xbsis-bedg4 IS INITIAL.
      WHILE xbsis-bedg4(01) IS INITIAL.
        SHIFT xbsis-bedg4.
        SHIFT xbsisgr-bedg4.
      ENDWHILE.
    ENDIF.
  ENDIF.

  IF NOT krit5 IS INITIAL.
    xbsisgr-krit5 = krit5.
    xbsis-krit5 = krit5.
    PERFORM check_betragsfelder USING krit5.                "365889
    IF NOT x_betrag IS INITIAL.                             "418389
      MOVE <f5> TO xbsis-bedg5.                             "365889
      MOVE <f5> TO xbsisgr-bedg5.                           "365889
    ELSE.                                                   "365889
      WRITE <f5> TO xbsis-bedg5.                            "333215
      WRITE <f5> TO xbsisgr-bedg5.                          "333215
    ENDIF.                                                  "365889
*----- Fuehrende Leerzeichen entfernen, f. Betraege notwendig ----------
    IF NOT xbsis-bedg5 IS INITIAL.
      WHILE xbsis-bedg5(01) IS INITIAL.
        SHIFT xbsis-bedg5.
        SHIFT xbsisgr-bedg5.
      ENDWHILE.
    ENDIF.
  ENDIF.

  APPEND xbsis.
  xbsisgr-ldgrp = xbsis-ldgrp.
  COLLECT xbsisgr.
  CHECK NOT pzbsisgr IS INITIAL.
  zaehler_xbsisgr = zaehler_xbsisgr + 1.
  IF zaehler_xbsisgr > pzbsisgr.
    DESCRIBE TABLE xbsisgr LINES sy-tfill.
    IF sy-tfill >= pzbsisgr.
      x_exit = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                               " XBSIS_XBSISGR_FUELLEN
*&---------------------------------------------------------------------*
*&      Form  FILL_PSWBT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BSIS_BUKRS  text
*      -->P_BSIS_WAERS  text
*      -->P_BSIS_DMBTR  text
*      -->P_BSIS_WRBTR  text
*      <--P_BSIS_PSWBT  text
*----------------------------------------------------------------------*
FORM fill_pswbt USING    i_bukrs i_waers i_dmbtr i_wrbtr i_flag
                CHANGING e_pswbt.
  IF i_bukrs NE t001-bukrs.
    SELECT SINGLE * FROM t001
           WHERE bukrs EQ i_bukrs.
  ENDIF.
*
  IF i_flag IS INITIAL.
    IF t001-waers EQ i_waers.
      e_pswbt = i_dmbtr.
    ELSE.
      e_pswbt = i_wrbtr.
    ENDIF.
  ELSE.
    IF bsis-pswsl EQ t001-waers.
      e_pswbt = i_dmbtr.
    ELSE.
      e_pswbt = i_wrbtr.
    ENDIF.
  ENDIF.
ENDFORM.                               " FILL_PSWBT
*&---------------------------------------------------------------------*
*&      Form  WRBTR_UMRECHNEN
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM wrbtr_umrechnen USING koart
                     CHANGING p_ignore_doc.
  DATA: BEGIN OF const_zuonr,
          kukey LIKE febep-kukey,
          esnum LIKE febep-esnum,
          kwaer LIKE febep-kwaer,
       END OF const_zuonr.
  DATA: refe16 TYPE wrbtr_x8.                               "972624
  DATA: wsubrc LIKE sy-subrc.
  DATA: ld_fixed_rate LIKE tcurr-ukurs.                     "439312
  DATA: ld_new_waers LIKE bkpf-waers.
  DATA: ld_save_subrc LIKE sy-subrc.

  CASE koart.
    WHEN 'D'.
*-----------------------------------------------------------------------
*       Ausgleich in Drittwährung
*
*       POSTAB-PSWSL =/= POSTAB-WAERS ist nur bei Sachkonten möglich,
*       die ihre Salden in Hauswährung haben, für alle anderen Konten
*       sind die beiden Abfragen bedeutungsgleich. Für die Sachkonten
*       mit Salden in Hauswährung gilt:
*
*       Ausgleich in Hauswährung:  POSTAB-PSWSL = BKPF-WAERS, also
*                                  keinerlei Umrechnungen
*       Ausgleich in Belegwährung: POSTAB-WAERS = BKPF-WAERS, also
*                                  keinerlei Umrechnungen
*       Ausgleich in Drittwährung: POSTAB-WAERS =/= BKPF-WAERS und
*                                  POSTAB-PSWSL =/= BKPF-WAERS
*-----------------------------------------------------------------------
      IF zwaers IS INITIAL.
        awaers = xbsid-waers.
      ELSE.
        awaers = zwaers.
      ENDIF.
      IF xauslw = 'X' AND gd_no_get_subsequent = space.
        CLEAR ld_save_subrc.
        IF gd_read_tcur_bukrs = 'X'.
          IF gt_tcur_bukrs-bukrs NE xbsid-bukrs.
            READ TABLE gt_tcur_bukrs WITH KEY xbsid-bukrs.
            ld_save_subrc = sy-subrc.
          ENDIF.
        ENDIF.
        IF ld_save_subrc = 0.
          PERFORM currency_get_subsequent USING awaers
                                                augdt
                                                xbsid-bukrs
                                          CHANGING ld_new_waers.
          IF awaers NE ld_new_waers.
            awaers = ld_new_waers.
          ENDIF.
        ENDIF.
      ENDIF.
*------- Prüfe, ob ein Ausgleich in dieser Währung erlaubt ist ---------
*------- Es könnte auch eine auslaufende Währung vorgegeben worden sein
      PERFORM currency_expiration_check USING awaers augdt xbsid-bukrs
                                        CHANGING p_ignore_doc.
      CHECK p_ignore_doc = space.

      IF xbsid-pycur EQ awaers                              "878401
      AND xbsid-pyamt NE 0.                                 "878401
        xbsid-xamnt = xbsid-pyamt.                          "878401
        xwrbtr = 'X'.                                       "878401
      ELSEIF xbsid-waers NE awaers                          "878401
      AND xbsid-pswsl NE awaers.
*------- Ursprungsbetrag retten ----------------------------------------
        old_wrbtr = xbsid-wrbtr.


        SELECT SINGLE * FROM  bkpf
               WHERE  bukrs       = xbsid-bukrs
               AND    belnr       = xbsid-belnr
               AND    gjahr       = xbsid-gjahr.
        CHECK sy-subrc = 0.
        IF xbsid-bukrs NE t001-bukrs.
          SELECT SINGLE * FROM t001 WHERE bukrs = xbsid-bukrs.
          CHECK sy-subrc = 0.
        ENDIF.
*------- Ausgleich in Hauswährung ohne erneute Kursumrechnung ? --------
        IF  t001-waers EQ awaers
        AND t001-xslta NE space.
          xbsid-xamnt = xbsid-dmbtr.

*------- Umrechnen Belegwährung in Hauswährung der Position ------------
        ELSE.
          CALL FUNCTION 'READ_EXCHANGE_RATE'                "439312
          EXPORTING date = augdt                            "439312
                    foreign_currency = awaers               "439312
                    local_currency   = xbsid-waers          "439312
          IMPORTING fixed_rate = ld_fixed_rate              "439312
          EXCEPTIONS OTHERS = 7.                            "455974
          IF sy-subrc = 0                                   "455974
          AND NOT ld_fixed_rate IS INITIAL.                 "455974
            CALL FUNCTION 'CONVERT_FOREIGN_TO_FOREIGN_CUR'  "439312
            EXPORTING date = augdt                          "439312
                      from_amount = xbsid-wrbtr             "439312
                      from_currency = xbsid-waers           "439312
                      to_currency   = awaers                "439312
                      local_currency = bkpf-hwaer           "439312
            IMPORTING to_amount = xbsid-xamnt.
          ELSE.                                             "439312
            IF xbsid-waers NE bkpf-hwaer.
              CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
                EXPORTING
                  date             = augdt
                  foreign_amount   = xbsid-wrbtr
                  foreign_currency = xbsid-waers
                  local_currency   = bkpf-hwaer
                IMPORTING
                  local_amount     = refe16.
            ELSE.
              refe16 = xbsid-wrbtr.
            ENDIF.

*------- Umrechnen Hauswährung der Position in Zahlungswährung ---------
            IF bkpf-hwaer NE awaers.
              CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
                   EXPORTING  date             = augdt
                              local_amount     = refe16
                              foreign_currency = awaers
                              local_currency   = bkpf-hwaer
*                        rate             = bkpf-kursf
                   IMPORTING  foreign_amount   = xbsid-xamnt.
            ELSE.
              xbsid-xamnt = refe16.
            ENDIF.
          ENDIF.                                            "439312
        ENDIF.
        xwrbtr = 'X'.
      ENDIF.
    WHEN 'K'.
      IF zwaers IS INITIAL.
        awaers = xbsik-waers.
      ELSE.
        awaers = zwaers.
      ENDIF.
      IF xauslw = 'X' AND gd_no_get_subsequent = space.
        CLEAR ld_save_subrc.
        IF gd_read_tcur_bukrs = 'X'.
          IF gt_tcur_bukrs-bukrs NE xbsik-bukrs.
            READ TABLE gt_tcur_bukrs WITH KEY xbsik-bukrs.
            ld_save_subrc = sy-subrc.
          ENDIF.
        ENDIF.
        IF ld_save_subrc = 0.
          PERFORM currency_get_subsequent USING awaers
                                                augdt
                                                xbsik-bukrs
                                          CHANGING ld_new_waers.
          IF awaers NE ld_new_waers.
            awaers = ld_new_waers.
          ENDIF.
        ENDIF.
      ENDIF.
*------- Prüfe, ob ein Ausgleich in dieser Währung erlaubt ist ---------
*------- Es könnte auch eine auslaufende Währung vorgegeben worden sein
      PERFORM currency_expiration_check USING awaers augdt xbsik-bukrs
                                        CHANGING p_ignore_doc.
      CHECK p_ignore_doc = space.

      IF xbsik-pycur EQ awaers                              "878401
      AND xbsik-pyamt NE 0.                                 "878401
        xbsik-xamnt = xbsik-pyamt.                          "878401
        xwrbtr = 'X'.                                       "878401
      ELSEIF xbsik-waers NE awaers                          "878401
      AND xbsik-pswsl NE awaers.
*------- Ursprungsbetrag retten ----------------------------------------
        old_wrbtr = xbsik-wrbtr.


        SELECT SINGLE * FROM  bkpf
               WHERE  bukrs       = xbsik-bukrs
               AND    belnr       = xbsik-belnr
               AND    gjahr       = xbsik-gjahr.
        CHECK sy-subrc = 0.
        IF xbsik-bukrs NE t001-bukrs.
          SELECT SINGLE * FROM t001 WHERE bukrs = xbsik-bukrs.
          CHECK sy-subrc = 0.
        ENDIF.
*------- Ausgleich in Hauswährung ohne erneute Kursumrechnung ? --------
        IF  t001-waers EQ awaers
        AND t001-xslta NE space.
          xbsik-xamnt = xbsik-dmbtr.

*------- Umrechnen Belegwährung in Hauswährung der Position ------------
        ELSE.
          CALL FUNCTION 'READ_EXCHANGE_RATE'                "439312
          EXPORTING date = augdt                            "439312
                    foreign_currency = awaers               "439312
                    local_currency   = xbsik-waers          "439312
          IMPORTING fixed_rate = ld_fixed_rate              "439312
          EXCEPTIONS OTHERS = 7.                            "455974
          IF sy-subrc = 0                                   "455974
          AND NOT ld_fixed_rate IS INITIAL.                 "455974
            CALL FUNCTION 'CONVERT_FOREIGN_TO_FOREIGN_CUR'  "439312
            EXPORTING date = augdt                          "439312
                      from_amount = xbsik-wrbtr             "439312
                      from_currency = xbsik-waers           "439312
                      to_currency   = awaers                "439312
                      local_currency = bkpf-hwaer           "439312
            IMPORTING to_amount = xbsik-xamnt.
          ELSE.                                             "439312
            IF xbsik-waers NE bkpf-hwaer.
              CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
                EXPORTING
                  date             = augdt
                  foreign_amount   = xbsik-wrbtr
                  foreign_currency = xbsik-waers
                  local_currency   = bkpf-hwaer
                IMPORTING
                  local_amount     = refe16.
            ELSE.
              refe16 = xbsik-wrbtr.
            ENDIF.

*------- Umrechnen Hauswährung der Position in Zahlungswährung ---------
            IF bkpf-hwaer NE awaers.
              CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
                   EXPORTING  date             = augdt
                              local_amount     = refe16
                              foreign_currency = awaers
                              local_currency   = bkpf-hwaer
*                        rate             = bkpf-kursf
                   IMPORTING  foreign_amount   = xbsik-xamnt.
            ELSE.
              xbsik-xamnt = refe16.
            ENDIF.
          ENDIF.                                            "439132
        ENDIF.
        xwrbtr = 'X'.
      ENDIF.
    WHEN 'S'.
*------- Ausgleichswährung awaers festlegen ----------------------------
* 1.Bei Währung aus Zuordnung ist awaers entweder Zuordnungswährung
*   oder Belegwährung (falls Zuzordnungswährung nicht existiert):
*   Die Ausgleichswährung kann man in diesem Fall nicht vorgeben, d.h.
*   zwaers = space.
*   Sollen auslaufende Währungen berücksichtigt werden, wird awaers
*   ebentuell durch die Nachfolgewährung ersetzt
* 2.Bei Währung nicht aus Zuordnung ist awaers entweder
*   die vorgegebene Ausgleichswährung (falls auslaufende Währung
*   nicht berücksichtigt werden sollen), die Belegwährung (falls
*   auslaufende Währungen berücksichtigt werden sollen) oder die
*   Zuordnungswährung (falls doch etwas in der Zuordnung stand)
*   Sollen auslaufende Währungen berücksichtigt werden, wird awaers
*   ebentuell durch die Nachfolgewährung ersetzt

*------- Währung aus Zuordnung? ----------------------------------------
      IF xsobebvk = 'X'.
*------- ... ja --------------------------------------------------------
        const_zuonr = xbsis-zuonr.
*------- Ist es auch wirklich eine Währung? ----------------------------
        IF const_zuonr-kukey CO '0123456789'                "357657
        AND const_zuonr-esnum CO '0123456789'.              "357657
          awaers = const_zuonr-kwaer.
          PERFORM waehrung_pruefen USING awaers.
          IF awaers = space.
*------- Währung aus Zuordnung war ungültig, setze Belegwährung
            awaers = xbsis-waers.
          ENDIF.
        ELSE.
*------- ... nein, setze Belegwährung
          awaers = xbsis-waers.
        ENDIF.                                              "357657
      ELSE.
        IF zwaers IS INITIAL.
          awaers = xbsis-waers.
        ELSE.
          awaers = zwaers.
        ENDIF.
      ENDIF.
      CHECK awaers NE space.
      IF xauslw = 'X' AND gd_no_get_subsequent = space.
        CLEAR ld_save_subrc.
        IF gd_read_tcur_bukrs = 'X'.
          IF gt_tcur_bukrs-bukrs NE xbsis-bukrs.
            READ TABLE gt_tcur_bukrs WITH KEY xbsis-bukrs.
            ld_save_subrc = sy-subrc.
          ENDIF.
        ENDIF.
        IF ld_save_subrc = 0.
          PERFORM currency_get_subsequent USING awaers
                                                augdt
                                                xbsis-bukrs
                                          CHANGING ld_new_waers.
          IF awaers NE ld_new_waers.
            awaers = ld_new_waers.
          ENDIF.
        ENDIF.
      ENDIF.
*------- Prüfe, ob ein Ausgleich in dieser Währung erlaubt ist ---------
*------- Es könnte auch eine auslaufende Währung vorgegeben worden sein
      PERFORM currency_expiration_check USING awaers augdt xbsis-bukrs
                                        CHANGING p_ignore_doc.
      CHECK p_ignore_doc = space.

      IF xbsis-waers = awaers.
        xbsis-xamnt = xbsis-wrbtr.
        xwrbtr = 'X'.
      ELSEIF xbsis-pswsl NE awaers.
*------- Ursprungsbetrag retten ----------------------------------------
        old_wrbtr = xbsis-wrbtr.


        SELECT SINGLE * FROM  bkpf
               WHERE  bukrs       = xbsis-bukrs
               AND    belnr       = xbsis-belnr
               AND    gjahr       = xbsis-gjahr.
        CHECK sy-subrc = 0.
        IF xbsis-bukrs NE t001-bukrs.
          SELECT SINGLE * FROM t001 WHERE bukrs = xbsis-bukrs.
          CHECK sy-subrc = 0.
        ENDIF.
*------- Ausgleich in Hauswährung ohne erneute Kursumrechnung ? --------
        IF  t001-waers EQ awaers
        AND t001-xslta NE space.
          xbsis-xamnt = xbsis-dmbtr.

*------- Umrechnen Belegwährung in Hauswährung der Position ------------
        ELSE.
          CALL FUNCTION 'READ_EXCHANGE_RATE'                "439312
          EXPORTING date = augdt                            "439312
                    foreign_currency = awaers               "439312
                    local_currency   = xbsis-waers          "439312
          IMPORTING fixed_rate = ld_fixed_rate              "439312
          EXCEPTIONS OTHERS = 7.                            "455974
          IF sy-subrc = 0                                   "455974
          AND NOT ld_fixed_rate IS INITIAL.                 "455974
            CALL FUNCTION 'CONVERT_FOREIGN_TO_FOREIGN_CUR'  "439312
            EXPORTING date = augdt                          "439312
                      from_amount = xbsis-wrbtr             "439312
                      from_currency = xbsis-waers           "439312
                      to_currency   = awaers                "439312
                      local_currency = bkpf-hwaer           "439312
            IMPORTING to_amount = xbsis-xamnt.
          ELSE.                                             "439312
            IF xbsis-waers NE bkpf-hwaer.
              CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
                EXPORTING
                  date             = augdt
                  foreign_amount   = xbsis-wrbtr
                  foreign_currency = xbsis-waers
                  local_currency   = bkpf-hwaer
                IMPORTING
                  local_amount     = refe16.
            ELSE.
              refe16 = xbsis-wrbtr.
            ENDIF.

*------- Umrechnen Hauswährung der Position in Zahlungswährung ---------
            IF bkpf-hwaer NE awaers.
              CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
                   EXPORTING  date             = augdt
                              local_amount     = refe16
                              foreign_currency = awaers
                              local_currency   = bkpf-hwaer
*                        rate             = bkpf-kursf
                   IMPORTING  foreign_amount   = xbsis-xamnt.
            ELSE.
              xbsis-xamnt = refe16.
            ENDIF.
          ENDIF.                                            "439312
        ENDIF.
        xwrbtr = 'X'.
      ENDIF.
  ENDCASE.
ENDFORM.                               " WRBTR_UMRECHNEN
*&---------------------------------------------------------------------*
*&      Form  WAEHRUNG_PRUEFEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_AWAERS  text
*----------------------------------------------------------------------*
FORM waehrung_pruefen USING    p_awaers.
  CHECK p_awaers NE space.
  SELECT SINGLE * FROM tcurc WHERE waers = p_awaers.
  IF sy-subrc NE 0.
    CLEAR p_awaers.
  ENDIF.
ENDFORM.                               " WAEHRUNG_PRUEFEN
*&---------------------------------------------------------------------*
*&      Form  FELDSYMBOLE_VERAENDERN_AVIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BSID_BUKRS  text
*      -->P_BSID_KUNNR  text
*----------------------------------------------------------------------*
FORM feldsymbole_veraendern_avis.
  DATA: bedingung(35) TYPE c.

  krit1 = 'BSID-XREF3'.
  bedingung = 'BSID-XREF3'.
  ASSIGN TABLE FIELD (bedingung) TO <f1>.
  CLEAR: krit2, krit3, krit4, krit5.
ENDFORM.                               " FELDSYMBOLE_VERAENDERN_AVIS
*&---------------------------------------------------------------------*
*&      Form  FELDSYMBOLE_VERÄNDERN_BVK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM feldsymbole_veraendern_bvk USING pbukrs LIKE bsis-bukrs
                                      phkont LIKE bsis-hkont.
  DATA: bedingung(35) TYPE c.

  IF ( last_pbukrs NE pbukrs OR last_phkont NE phkont )
  AND xsobebvk = 'X'.
* Note 310882

    krit1 = 'BSIS-ZUONR'.
    bedingung = 'BSIS-ZUONR'.
    ASSIGN TABLE FIELD (bedingung) TO <f1>.
    CLEAR: krit2, krit3, krit4, krit5.
    last_pbukrs = pbukrs.
    last_phkont = phkont.
  ELSE.
    EXIT.
  ENDIF.
ENDFORM.                               " FELDSYMBOLE_VERAENDERN_BVK
*&---------------------------------------------------------------------*
*&      Form  FELDSYMBOLE_VERÄNDERN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM feldsymbole_veraendern USING pbukrs LIKE bsis-bukrs
                                  phkont LIKE bsis-hkont.
  DATA: bedingung(35) TYPE c.

  IF last_pbukrs NE pbukrs OR last_phkont NE phkont.       "Note 310882
    krit1 = 'BSIS-XREF3'.
    bedingung = 'BSIS-XREF3'.
    ASSIGN TABLE FIELD (bedingung) TO <f1>.
    krit2 = 'BSEG-EBELN'.
    bedingung = 'BSEG-EBELN'.
    ASSIGN TABLE FIELD (bedingung) TO <f2>.
    krit3 = 'BSEG-EBELP'.
    bedingung = 'BSEG-EBELP'.
    ASSIGN TABLE FIELD (bedingung) TO <f3>.
    krit4 = 'BSIS-GSBER'.
    bedingung = 'BSIS-GSBER'.
    ASSIGN TABLE FIELD (bedingung) TO <f4>.
    CLEAR krit5.
    last_pbukrs = pbukrs.
    last_phkont = phkont.
  ELSE.
    EXIT.
  ENDIF.
ENDFORM.                               " FELDSYMBOLE_VERAENDERN
*&---------------------------------------------------------------------*
*&      Form  SONDERBERARBEITUNG_WERE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sonderbearbeitung_were CHANGING e_subrcbkpf
                                     e_subrcbseg.

  READ TABLE iwere WITH KEY bukrs = bsis-bukrs hkont = bsis-hkont.
  IF sy-subrc = 0.
    CLEAR xsobeerf.
    PERFORM refresh_were_tables.
*----- Kriterien aus TF123 verändern -----------------------------------
    PERFORM feldsymbole_veraendern USING bsis-bukrs bsis-hkont.
*----- Wird geprüft, ob das Feld XREF gefüllt ist oder nicht     "377410
*----- Wenn ja, wird das Unterprogramm abgebrochen               "377410
    IF NOT ( bsis-xref3 IS INITIAL OR bsis-xref3+4(1) = '*' ). "377410
      xsobeerf = 'X'.                                       "377410
      EXIT.                                                 "377410
    ENDIF.                                                  "377410
    IF rcekbe NE 0.                                         "454904
*----- Kennzeichen WE-Bezogene Rechnung gesetzt? -----------------------
      PERFORM ekpo_lesen.
    ENDIF.                                                  "454904
    IF rcekpo = 0.
*----- Bestellentwicklung ermitteln ------------------------------------
      PERFORM bestellentwicklung_ermitteln.
      IF rciekbe = 0.                                       "454904
        CLEAR docok.
        LOOP AT iekbe.                                      "454904
*Vorsicht: eine Sollbuchung auf dem WE/RE-Konto im FI entspricht nicht
*unbedingt einem RE im MM.
*----- AWREF und AWORG ermitteln ---------------------------------------
          rcappend = 4.
          rcmkpf = 4.
          rcrbkp = 4.
          rcbkpf = 4.
          IF iekbe-vgabe = '1'.
            PERFORM mkpf_lesen.
          ENDIF.
          IF iekbe-vgabe = '2' OR iekbe-vgabe = '3'.
            PERFORM rbkp_lesen.
          ENDIF.
          IF rcmkpf = 0 OR rcrbkp = 0 OR rcbkpf = 0.
*----- Mit AWREF und AWORG zughörigen RW-Beleg ermitteln ---------------
            PERFORM rw_beleg_bestimmen.
*----- Richtiger Beleg gefunden ? --------------------------------------
            IF docok = 'X'.
              IF ekpo-pstyp = '9'.                          "432613
                CONCATENATE iekbe-lfgja iekbe-lfbnr         "432613
                INTO bsis-xref3.                            "432613
              ELSE.                                         "432613
                CONCATENATE iekbe-lfgja iekbe-lfbnr iekbe-lfpos
                INTO bsis-xref3.
              ENDIF.                                        "432613
              xsobeerf = 'X'.
              EXIT.                                         "454904
            ENDIF.
          ENDIF.
        ENDLOOP.                                            "454904
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                               " Sonderbearbeitung_WERE
*&---------------------------------------------------------------------*
*&      Form  REFRESH_WERE_TABLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM refresh_were_tables.
  DATA: linmax LIKE sy-tfill VALUE '300'.
  CHECK ctixaccdn GT linmax.
  CLEAR: ixaccdn.
  REFRESH:  ixaccdn.
  ctixaccdn = 0.
ENDFORM.                               " REFRESH_WERE_TABLES
*&---------------------------------------------------------------------*
*&      Form  EKPO_LESEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ekpo_lesen.
  rcekpo = 4.
*----- gepuffertes Lesen der EKPO --------------------------------------
  CALL FUNCTION 'ME_EKPO_SINGLE_READ'
    EXPORTING
      pi_ebeln            = ibsis-ebeln                     "454904
      pi_ebelp            = ibsis-ebelp                     "454904
      pi_bypassing_buffer = ' '
      pi_refresh_buffer   = ' '
    IMPORTING
      po_ekpo             = ekpo
    EXCEPTIONS
      no_records_found    = 1
      OTHERS              = 2.
  IF sy-subrc = 0.
    IF ekpo-webre = 'X'.
      rcekpo = 0.
    ENDIF.
  ENDIF.
ENDFORM.                               " EKPO_LESEN
*&---------------------------------------------------------------------*
*&      Form  BESTELLENTWICKLUNG_ERMITTELN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bestellentwicklung_ermitteln.

  IF rcekbe NE 0.
    CLEAR: ekbetab,
           iekbes,
           iekbez,
           iekbnk,
           iekbz.
    REFRESH: ekbetab,
             iekbes,
             iekbez,
             iekbnk,
             iekbz.
*   CALL FUNCTION 'ME_READ_HISTORY'
*        EXPORTING
*             EBELN   = EKPO-EBELN
*             EBELP   = EKPO-EBELP
*             WEBRE   = EKPO-WEBRE
*        TABLES
*             XEKBE   = EKBETAB
*             XEKBES  = IEKBES
*             XEKBEZ  = IEKBEZ
*             XEKBNK  = IEKBNK
*             XEKBZ   = IEKBZ
*        EXCEPTIONS
*             OTHERS  = 1.
    CALL FUNCTION 'ME_READ_HISTORY_HEADER'
      EXPORTING
        i_ebeln   = ibsis-ebeln                             "454904
        i_ebelp   = ibsis-ebelp                             "454904
      TABLES
        t_ekbe    = ekbetab
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    IF sy-subrc = 0.
      rcekbe = 0.
*------- Nur WE und RE berücksichtigen ---------------------------------
      PERFORM ekbetab_reduzieren.
      PERFORM iekbe_fuellen.
      PERFORM iekbe_sortieren.
    ENDIF.
  ENDIF.
ENDFORM.                               " BESTELLENTWICKLUNG_ERMITTELN
*&---------------------------------------------------------------------*
*&      Form  EKBETAB_REDUZIEREN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ekbetab_reduzieren.
  DELETE ekbetab WHERE vgabe NE '1'                         " 1 = WE
                   AND vgabe NE '2'                         " 2 = RE
                   AND vgabe NE '3'.   " 3 = Nachbelastung
ENDFORM.                               " EKBETAB_REDUZIEREN
*&---------------------------------------------------------------------*
*&      Form  IEKBE_FUELLEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM iekbe_fuellen.
  LOOP AT ekbetab.
    iekbe = ekbetab.
    APPEND iekbe.
    rciekbe = 0.                                            "454904
  ENDLOOP.
ENDFORM.                               " IEKBE_FUELLEN
*&---------------------------------------------------------------------*
*&      Form  IEKBE_SORTIEREN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM iekbe_sortieren.
  SORT iekbe BY ebeln ebelp bewtp
                      gjahr belnr buzei.
ENDFORM.                               " IEKBE_SORTIEREN
*&---------------------------------------------------------------------*
*&      Form  MKPF_LESEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mkpf_lesen.
  READ TABLE ixaccdn WITH KEY awtyp = 'MKPF'
                              awref = iekbe-belnr
                              aworg = iekbe-gjahr.
  IF sy-subrc = 0.
    rcmkpf = 0.
  ELSE.
    SELECT SINGLE * FROM mkpf WHERE mblnr = iekbe-belnr
                                AND mjahr = iekbe-gjahr.
    IF sy-subrc = 0.
      rcmkpf = 0.
      rcappend = 0.
    ENDIF.
  ENDIF.
ENDFORM.                               " MKPF_LESEN
*&---------------------------------------------------------------------*
*&      Form  RBKP_LESEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM rbkp_lesen.
  DATA: subrcbkpf LIKE sy-subrc.
  DATA: aworgbkpf LIKE acchd-aworg.
*----- document of MR11? Can't decide whether old or new document"363689
  IF ( iekbe-vgabe = '2' AND iekbe-bewtp = 'K' ).           "363689
    READ TABLE ixaccdn WITH KEY awtyp = 'RMRP'              "363689
                                awref = iekbe-belnr         "363689
                                aworg = iekbe-gjahr.        "363689
    IF sy-subrc = 0.                                        "363689
      rcrbkp = 0.                                           "363689
    ELSE.                                                   "363689
      CALL FUNCTION 'MRM_RBKP_SINGLE_READ'                  "363689
      EXPORTING i_belnr     = iekbe-belnr                   "363689
                i_gjahr     = iekbe-gjahr                   "363689
                i_buffer_on = 'X'                           "363689
      IMPORTING e_rbkp      = rbkptab                       "363689
      EXCEPTIONS entry_not_found = 1                        "363689
                 OTHERS          = 2.                       "363689
      IF sy-subrc = 0.                                      "363689
        rcrbkp = 0.                                         "363689
        rcappend = 0.                                       "363689
      ENDIF.                                                "363689
    ENDIF.                                                  "363689
    IF sy-subrc NE 0.                                       "363689
      CONCATENATE bsis-bukrs iekbe-gjahr INTO aworgbkpf.    "454904
      READ TABLE ixaccdn WITH KEY awtyp = 'BKPF'            "363689
                                  awref = iekbe-belnr       "363689
                                  aworg = aworgbkpf.        "363689
      IF sy-subrc = 0.                                      "363689
        rcrbkp = 0.                                         "363689
      ELSE.                                                 "363689
        PERFORM read_bkpf_neu                               "363689
        USING bsis-bukrs iekbe-belnr iekbe-gjahr space      "455320
        CHANGING subrcbkpf.                                 "454904
        IF subrcbkpf = 0.                                   "363689
          rcbkpf = 0.                                       "363689
          rcappend = 0.                                     "363689
        ELSE.                                               "363689
          rcbkpf = 9.                                       "363689
        ENDIF.                                              "363689
      ENDIF.                                                "363689
    ENDIF.                                                  "363689
  ELSE.                                                     "363689
*----- Rechnungen/Nachbelastungen aus der log. RP oder alte Rechnungen?
*----- bei Nachbelast. vgabe = '3', vgl. Fugr MRMP form EKBE_aufbauen
    IF ( iekbe-vgabe = '2' AND
       ( iekbe-bewtp = 'Q' OR iekbe-bewtp = 'N' ) )
    OR ( iekbe-vgabe = '3' AND
       ( iekbe-bewtp = 'N' OR iekbe-bewtp = 'W' ) ).
*----- neu... (aus log. RP, neu ab 3.0) --------------------------------
      READ TABLE ixaccdn WITH KEY awtyp = 'RMRP'
                                  awref = iekbe-belnr
                                  aworg = iekbe-gjahr.
    ELSE.
*----- alt... ----------------------------------------------------------
      CONCATENATE bsis-bukrs iekbe-gjahr INTO aworgbkpf.    "454904
      READ TABLE ixaccdn WITH KEY awtyp = 'BKPF'
                                  awref = iekbe-belnr
                                  aworg = aworgbkpf.
    ENDIF.
    IF sy-subrc = 0.
      rcrbkp = 0.
    ELSE.
      IF ( iekbe-vgabe = '2' AND
         ( iekbe-bewtp = 'Q' OR iekbe-bewtp = 'N' ) )
      OR ( iekbe-vgabe = '3' AND
         ( iekbe-bewtp = 'N' OR iekbe-bewtp = 'W' ) ).
*----- Neue oder alte Rechnungsprüfung ? -------------------------------
*----- ... neue --------------------------------------------------------

        CALL FUNCTION 'MRM_RBKP_SINGLE_READ'
          EXPORTING
            i_belnr         = iekbe-belnr
            i_gjahr         = iekbe-gjahr
            i_buffer_on     = 'X'  "wegen Refresh im FUBA doch gut
          IMPORTING
            e_rbkp          = rbkptab
          EXCEPTIONS
            entry_not_found = 1
            OTHERS          = 2.
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
        IF sy-subrc = 0.
          rcrbkp = 0.
          rcappend = 0.
        ENDIF.
      ENDIF.
*----- ... alte --------------------------------------------------------
      IF ( iekbe-vgabe = '2' AND
         ( iekbe-bewtp = 'R' OR iekbe-bewtp = 'K' ) )
      OR ( iekbe-vgabe = '3' AND
         ( iekbe-bewtp NE 'N' AND iekbe-bewtp NE 'W' ) ).
        PERFORM read_bkpf_neu
        USING bsis-bukrs iekbe-belnr iekbe-gjahr space      "455320
        CHANGING subrcbkpf.                                 "454904
        IF subrcbkpf = 0.
          rcbkpf = 0.
          rcappend = 0.
        ELSE.
          rcbkpf = 9.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.                                                    "363689
ENDFORM.                               " RBKP_LESEN
*&---------------------------------------------------------------------*
*&      Form  RW_BELEG_BESTIMMEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM rw_beleg_bestimmen.
  DATA: aworgbkpf LIKE acchd-aworg.
  CLEAR: xaccdn.
  REFRESH: xaccdn.
  IF rcappend = 0.
    IF iekbe-vgabe = '1'.
      awref    = mkpf-mblnr.
      aworg    = mkpf-mjahr.
      awtyp    = 'MKPF'.
      awsys    = mkpf-awsys.
    ELSE.
      IF rcrbkp = 0.
        awref    = rbkptab-belnr.
        aworg    = rbkptab-gjahr.
        awtyp    = 'RMRP'.
        awsys    = rbkptab-logsys.
      ENDIF.
      IF rcbkpf = 0.
        awref    = bkpf-awkey+00(10).
        aworg    = bkpf-awkey+10(10).
        awtyp    = bkpf-awtyp.
        awsys    = bkpf-awsys.
      ENDIF.
    ENDIF.
    IF rcbkpf = 0.
*----- AC_Document_record nicht notwendig, da Beleg bereits FI-Beleg ist
      CLEAR: xaccdn, ixaccdn.                               "420677
      ixaccdn-belnr = iekbe-belnr.
      ixaccdn-awref = awref.
      ixaccdn-aworg = aworg.
      ixaccdn-awsys = awsys.
      ixaccdn-awtyp = awtyp.
      ixaccdn-gjahr = bkpf-gjahr.                           "420677
      ixaccdn-bukrs = bkpf-bukrs.                           "420677
      ctixaccdn = ctixaccdn + 1.
      APPEND ixaccdn.

      IF  ixaccdn-belnr = bsis-belnr
      AND ixaccdn-aworg+4(4) = bsis-gjahr
      AND bsis-buzei = iekbe-buzei.
        docok = 'X'.
      ENDIF.
    ELSE.
      PERFORM ac_document_record.
      IF sy-subrc = 0.
        LOOP AT xaccdn.
          ixaccdn = xaccdn.
          ctixaccdn = ctixaccdn + 1.
          APPEND ixaccdn.
*----- Stimmt RW-Beleg mit aktuellem BSIS-Belegnr. überein -------------
          IF xaccdn-belnr = bsis-belnr
          AND xaccdn-gjahr = bsis-gjahr.                    "309434
            docok = 'X'.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ELSE.
    READ TABLE ixaccdn WITH KEY  belnr = bsis-belnr
                                 gjahr = bsis-gjahr.        "309434
    IF sy-subrc = 0.
      IF iekbe-vgabe = '1'.
        IF  ixaccdn-awref = iekbe-belnr
        AND ixaccdn-aworg = iekbe-gjahr.
          docok = 'X'.
        ENDIF.
      ELSE.
        IF ( iekbe-vgabe = '2' AND
           ( iekbe-bewtp = 'Q' OR iekbe-bewtp = 'N' ) )
        OR ( iekbe-vgabe = '3' AND
           ( iekbe-bewtp = 'N' OR iekbe-bewtp = 'W' ) ).
          IF  ixaccdn-awref = iekbe-belnr
          AND ixaccdn-aworg = iekbe-gjahr.
            docok = 'X'.
          ENDIF.
        ELSE.
          CONCATENATE bsis-bukrs iekbe-gjahr INTO aworgbkpf. "454904
          IF  ixaccdn-awref = iekbe-belnr
          AND ixaccdn-aworg = aworgbkpf
          AND bsis-buzei    = iekbe-buzei.
            docok = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                               " RW_BELEG_BESTIMMEN
*&---------------------------------------------------------------------*
*&      Form  AC_DOCUMENT_RECORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ac_document_record.
  xaccdn-awtyp = awtyp.
  xaccdn-awref = awref.
  xaccdn-aworg = aworg.
  xaccdn-awsys = awsys.
  APPEND xaccdn.
  CALL FUNCTION 'FI_DOCUMENT_NUMBER_GET'
    TABLES
      t_accdn = xaccdn.
ENDFORM.                               " AC_DOCUMENT_RECORD
*&---------------------------------------------------------------------*
*&      Form  READ_BKPF_NEU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BSID-BUKRS  text                                           *
*      -->P_BSID-BELNR  text                                           *
*      -->P_BSID-GJAHR  text                                           *
*----------------------------------------------------------------------*
FORM read_bkpf_neu USING    bukrs LIKE bseg-bukrs
                            belnr LIKE bseg-belnr
                            gjahr LIKE bseg-gjahr
                            xmesg TYPE c                    "455320
                   CHANGING e_subrc.
  CHECK NOT ( bkpf-bukrs = bukrs                            "407054
          AND bkpf-belnr = belnr                            "407054
          AND bkpf-gjahr = gjahr ).                         "407054
  CALL FUNCTION 'READ_DOCUMENT_HEADER'
    EXPORTING
      belnr          = belnr
      bukrs          = bukrs
      gjahr          = gjahr
      xarch          = ' '
    IMPORTING
      e_bkpf         = bkpf
    EXCEPTIONS
      exit           = 1
      not_found      = 2
      archive_cancel = 3
      OTHERS         = 4.
  IF sy-subrc NE 0.
    e_subrc = sy-subrc.
    IF xmesg = 'X'.                                         "455320
      PERFORM record_fill
           USING 'BKPF ' bukrs space space space belnr space char_s.
    ENDIF.                                                  "455320
  ENDIF.
ENDFORM.                               " READ_BKPF_NEU

*&---------------------------------------------------------------------*
*&      Form  READ_BSEG_NEU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BSID-BUKRS  text                                           *
*      -->P_BSID-BELNR  text                                           *
*      -->P_BSID-GJAHR  text                                           *
*      -->P_BSID_BUZEI  text                                           *
*----------------------------------------------------------------------*
FORM read_bseg_neu USING    bukrs LIKE bseg-bukrs
                            belnr LIKE bseg-belnr
                            gjahr LIKE bseg-gjahr
                            buzei LIKE bseg-buzei
                   CHANGING e_subrc.
  SELECT SINGLE * FROM bseg
         WHERE bukrs = bukrs
         AND   belnr = belnr
         AND   gjahr = gjahr
         AND   buzei = buzei.
  IF sy-subrc NE 0.
    e_subrc = sy-subrc.
    PERFORM record_fill
            USING 'BSEG ' bukrs space space space belnr buzei char_s.
  ENDIF.
ENDFORM.                               " READ_BSEG_NEU
*&---------------------------------------------------------------------*
*&      Form  CHECK_BETRAGSFELDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_betragsfelder USING p_krit.

  DATA: tabl       LIKE dfies-tabname,
        tabl1      LIKE dfies-tabname,
        fnam       LIKE dfies-fieldname,
        waehrfeld  LIKE dfiestab-reffield.

  tabl  = p_krit(04).
  fnam  = p_krit+5(30).
  READ TABLE tdfies WITH KEY tabname   = tabl
                             fieldname = fnam.
  IF sy-subrc = 0.
    IF tdfies-datatype = 'DATS'.                            "418389
      x_betrag = 'Y'.                                       "418389
    ELSE.                                                   "418389
      x_betrag = 'X'.
      IF tdfies-reftable NE 'T001'.
        waehrfeld  = tdfies-reffield.
*        IF gb_xcopy IS INITIAL.                             "443350
*          CONCATENATE 'X' tabl INTO tabl1.
        CONCATENATE 'GS_' tabl INTO tabl1.
*        ELSE.                                               "443350
*          CONCATENATE 'X' tabl 'COPY' INTO tabl1.           "443350
*        ENDIF.                                              "443350
        CONCATENATE tabl1 '-' waehrfeld INTO curr.
      ELSE.
        READ TABLE i001 WITH KEY bukrs = xbsid-bukrs.
        waehrfeld  = 'WAERS'.
        CONCATENATE 'I001' '-' waehrfeld INTO curr.
      ENDIF.
    ENDIF.                                                  "418389
  ELSE.
    CLEAR x_betrag.
  ENDIF.
ENDFORM.                               " CHECK_BETRAGSFELDER
*&---------------------------------------------------------------------*
*&      Form  INIT_header_stat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_header_stat.
  cnt_ap = 0.
  cnt_op = 0.
  cnt_eap = 0.
  sum1_op = 0.
  sum1_ap = 0.
  sum1_eap = 0.
  new_bukr = space.
ENDFORM.                               " INIT_SHORT_LIST
*&---------------------------------------------------------------------*
*&      Form  SORTIEREN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KOART  text
*----------------------------------------------------------------------*
FORM sortieren USING    p_koart LIKE bseg-koart.
  CASE p_koart.
    WHEN 'D'.
      SORT xbsid BY hkont xcurr umskz bedg1 bedg2 bedg3 bedg4 bedg5
                    wrbtr budat DESCENDING.                 "792290
      SORT xbsidgr BY hkont bedg1 bedg2 bedg3 bedg4 bedg5 xcurr.
    WHEN 'K'.
      SORT xbsik BY hkont xcurr umskz bedg1 bedg2 bedg3 bedg4 bedg5
                    wrbtr budat DESCENDING.                 "792290
      SORT xbsikgr BY hkont bedg1 bedg2 bedg3 bedg4 bedg5 xcurr.
    WHEN 'S'.
*----- Bei WE/RE-Konten Sortierung nach Bestellnumer/Bestellposition ---
      IF xsobwere = 'X'.
        READ TABLE iwere WITH KEY bukrs = bsis-bukrs hkont = bsis-hkont.
        IF sy-subrc = 0.
          SORT xbsis BY hkont xcurr bedg2 bedg3 bedg1 bedg4 bedg5
*                        xamnt budat DESCENDING.                 "792290
                     xamnt budat DESCENDING belnr DESCENDING. "1127849
          SORT xbsisgr BY hkont bedg2 bedg3 bedg1 bedg4 bedg5 xcurr.
        ELSE.
          SORT xbsis BY hkont xcurr bedg1 bedg2 bedg3 bedg4 bedg5
*                        xamnt budat DESCENDING.                 "792290
                     xamnt budat DESCENDING belnr DESCENDING. "1127849
          SORT xbsisgr BY hkont bedg1 bedg2 bedg3 bedg4 bedg5 xcurr.
        ENDIF.
      ELSE.
        SORT xbsis BY hkont xcurr ldgrp bedg1 bedg2 bedg3 bedg4 bedg5
*                        xamnt budat DESCENDING.                 "792290
                   xamnt budat DESCENDING belnr DESCENDING. "1127849

        SORT xbsisgr BY hkont xcurr ldgrp bedg1 bedg2 bedg3 bedg4 bedg5.
      ENDIF.
  ENDCASE.
ENDFORM.                               " SORTIEREN
*&---------------------------------------------------------------------*
*&      Form  AUSGLEICH
*&---------------------------------------------------------------------*
FORM ausgleich USING i_koart LIKE bseg-koart
                     i_sum LIKE xbsisgr-bet_tw.
  DATA: rcgrup LIKE sy-subrc.
**commet
*        ld_data TYPE gtyp_data.

  counter = 0.
  CASE i_koart.
    WHEN 'D'.
      REFRESH ybsid.
      PERFORM read_xbsid.
    WHEN 'K'.
      REFRESH ybsik.
      PERFORM read_xbsik.
    WHEN 'S'.
      REFRESH ybsis.
      PERFORM read_xbsis.
  ENDCASE.
*  Ausgabe ausgl. Belege, Statistikzähler, ybsik füllen
  PERFORM belege_ausgeben USING i_koart.
  IF x_echtl = space.
*     test run
    IF i_sum = 0.
*        group balances to 0
      IF flg_liste = char_3.
        PERFORM acc_append_data USING i_koart
                                      augdt
                                      space
                                      'AUGDT'.
      ENDIF.
    ELSE.
*        group does not balance to 0
      IF xtol = 'X'.
*           with tolerances
        rcgrup = 0.
        IF xtoleb = space.
          PERFORM check_gruppe CHANGING rcgrup.
        ENDIF.
        IF rcgrup <> 0.
*              single line not permitted
          IF flg_liste = char_3.
            PERFORM acc_append_data USING i_koart
                                          augdt
                                          space
                                          'NOCLEAR'.
          ENDIF.
        ELSE.
          IF enqsubrc = 0.
            CLEAR gejahr.                                   "1121415
            monat = bmonat.                                 "1121415
            PERFORM augdt_pruefen USING i_koart.            "985181
            PERFORM call_transaction USING i_koart.
          ELSE.
*                 enqueue failed
            IF flg_liste = char_3.
              PERFORM acc_append_data USING i_koart
                                            augdt
                                            space
                                            'ENQ'.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
*           no tolerances
        IF flg_liste = char_3.
          PERFORM acc_append_data USING i_koart
                                        augdt
                                        space
                                        'NOTZERO'.
        ENDIF.
      ENDIF.
    ENDIF.
    PERFORM clear_augdt_testl USING i_koart.
  ELSE.
*     productive run
    IF i_sum = 0.
*        group balances to 0
      IF enqsubrc = 0.
*           enqeueue successfull
        CLEAR gejahr.                                       "1121415
        monat = bmonat.                                     "1121415
        PERFORM augdt_pruefen USING i_koart.
        PERFORM call_transaction USING i_koart.
      ELSE.
*           enqueue failed
        IF flg_liste = char_3.
          PERFORM acc_append_data USING i_koart
                                        augdt
                                        space
                                        'ENQ'.
        ENDIF.
      ENDIF.
    ELSE.
*        group does not balance to 0.
      IF xtol = 'X'.
*           with tolerances
        rcgrup = 0.
        IF xtoleb = space.
          PERFORM check_gruppe CHANGING rcgrup.
        ENDIF.
        IF rcgrup <> 0.
*              single line not permitted
          IF flg_liste = char_3.
            PERFORM acc_append_data USING i_koart
                                          augdt
                                          space
                                          'NOCLEAR'.
          ENDIF.
        ELSE.
          IF enqsubrc = 0.
*                 enqueue successfull
            CLEAR gejahr.                                   "1121415
            monat = bmonat.                                 "1121415
            PERFORM augdt_pruefen USING i_koart.            "985181
            PERFORM call_transaction USING i_koart.
          ELSE.
*                 enqueue failed
            IF flg_liste = char_3.
              PERFORM acc_append_data USING i_koart
                                            augdt
                                            space
                                            'ENQ'.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
*           zero tolerance
        IF flg_liste = char_3.
          PERFORM acc_append_data USING i_koart
                                        augdt
                                        space
                                        'NOTZERO'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                               " AUSGLEICH
*&---------------------------------------------------------------------*
*&      Form  READ_XBSID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_xbsid.

  READ TABLE xbsid WITH KEY
                           hkont = xbsidgr-hkont
                           xcurr = xbsidgr-xcurr
                           umskz = xbsidgr-umskz
                           bedg1 = xbsidgr-bedg1
                           bedg2 = xbsidgr-bedg2
                           bedg3 = xbsidgr-bedg3
                           bedg4 = xbsidgr-bedg4
                           bedg5 = xbsidgr-bedg5
         BINARY SEARCH.
ENDFORM.                               " READ_XBSID
*&---------------------------------------------------------------------*
*&      Form  READ_XBSIK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_xbsik.
  READ TABLE xbsik WITH KEY
                           hkont = xbsikgr-hkont
                           xcurr = xbsikgr-xcurr
                           umskz = xbsikgr-umskz
                           bedg1 = xbsikgr-bedg1
                           bedg2 = xbsikgr-bedg2
                           bedg3 = xbsikgr-bedg3
                           bedg4 = xbsikgr-bedg4
                           bedg5 = xbsikgr-bedg5
         BINARY SEARCH.

ENDFORM.                               " READ_XBSIK
*&---------------------------------------------------------------------*
*&      Form  READ_XBSIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_xbsis.
  IF xsobwere = space.
    READ TABLE xbsis WITH KEY
                             hkont = xbsisgr-hkont
                             xcurr = xbsisgr-xcurr
                             ldgrp = xbsisgr-ldgrp
                             bedg1 = xbsisgr-bedg1
                             bedg2 = xbsisgr-bedg2
                             bedg3 = xbsisgr-bedg3
                             bedg4 = xbsisgr-bedg4
                             bedg5 = xbsisgr-bedg5
           BINARY SEARCH.
  ELSE.
    READ TABLE iwere WITH KEY bukrs = bsis-bukrs hkont = bsis-hkont.
    IF sy-subrc = 0.
      READ TABLE xbsis WITH KEY
                               hkont = xbsisgr-hkont
                               xcurr = xbsisgr-xcurr
                               bedg2 = xbsisgr-bedg2
                               bedg3 = xbsisgr-bedg3
                               bedg1 = xbsisgr-bedg1
                               bedg4 = xbsisgr-bedg4
                               bedg5 = xbsisgr-bedg5
            BINARY SEARCH.
    ELSE.
      READ TABLE xbsis WITH KEY
                               hkont = xbsisgr-hkont
                               xcurr = xbsisgr-xcurr
                               bedg1 = xbsisgr-bedg1
                               bedg2 = xbsisgr-bedg2
                               bedg3 = xbsisgr-bedg3
                               bedg4 = xbsisgr-bedg4
                               bedg5 = xbsisgr-bedg5
             BINARY SEARCH.
    ENDIF.
  ENDIF.
ENDFORM.                               " READ_XBSIS
*&---------------------------------------------------------------------*
*&      Form  BELEGE_AUSGEBEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_KOART  text                                                *
*----------------------------------------------------------------------*
FORM belege_ausgeben USING    i_koart LIKE bseg-koart.
  CASE i_koart.
    WHEN 'D'.
      icount = sy-tabix.
      WHILE icount NE 0.
        READ TABLE xbsid INDEX icount.
        IF sy-subrc = 0.
*----- YBSID fuellen, AUGDT bestimmen ----------------------------------
*----- Statistikzähler, Ausgabe ausgleichbarer Belege ------------------
          PERFORM verarbeiten USING koart xbsidgr-bet_bw.
        ELSE.                          " sy-subrc nach read table ne 0
          icount = 0.
        ENDIF.
      ENDWHILE.
    WHEN 'K'.
      icount = sy-tabix.
      WHILE icount NE 0.
        READ TABLE xbsik INDEX icount.
        IF sy-subrc = 0.
*----- ybsik fuellen, AUGDT bestimmen ----------------------------------
*----- Statistikzähler, Ausgabe ausgleichbarer Belege ------------------
          PERFORM verarbeiten USING koart xbsikgr-bet_bw.
        ELSE.                          " sy-subrc nach read table ne 0
          icount = 0.
        ENDIF.
      ENDWHILE.
    WHEN 'S'.
      icount = sy-tabix.
      WHILE icount NE 0.
        READ TABLE xbsis INDEX icount.
        IF sy-subrc = 0.
*----- ybsis fuellen, AUGDT bestimmen ----------------------------------
*----- Statistikzähler, Ausgabe ausgleichbarer Belege ------------------
          PERFORM verarbeiten USING koart xbsisgr-bet_tw.
        ELSE.                          " sy-subrc nach read table ne 0
          icount = 0.
        ENDIF.
      ENDWHILE.
  ENDCASE.
ENDFORM.                               " BELEGE_AUSGEBEN
*&---------------------------------------------------------------------*
*&      Form  Verarbeiten
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM verarbeiten USING i_koart LIKE bseg-koart
                       i_betrag LIKE xbsidgr-bet_bw.
  CASE i_koart.
    WHEN 'D'.
      IF i_betrag = 0  OR xtol = 'X'.
        IF  ( xbsid-hkont EQ xbsidgr-hkont )
        AND ( xbsid-xcurr EQ xbsidgr-xcurr )
        AND ( xbsid-umskz EQ xbsidgr-umskz )
        AND ( xbsid-bedg1 EQ xbsidgr-bedg1 )
        AND ( xbsid-bedg2 EQ xbsidgr-bedg2 )
        AND ( xbsid-bedg3 EQ xbsidgr-bedg3 )
        AND ( xbsid-bedg4 EQ xbsidgr-bedg4 )
        AND ( xbsid-bedg5 EQ xbsidgr-bedg5 ).
          icount = icount + 1.
          MOVE-CORRESPONDING xbsid TO ybsid.
*----- Ausgleichsdatum aus jüngstem Beleg? -----------------------------
          PERFORM augdt_bestimmen USING i_koart.            "985181
          APPEND ybsid.
*----- Zähler für Statistik --------------------------------------------
          IF flg_liste = char_2.
            cnt_ap = cnt_ap + 1.
            cnt_op = cnt_op + 1.
            sum1_ap = sum1_ap + 1.
            sum1_op = sum1_op + 1.
          ENDIF.
*----- Ausgabe der ausgleichbaren Belege -------------------------------
          IF flg_liste = char_3.
            PERFORM record_document USING 'XBSID'.
          ENDIF.
          IF i_betrag NE 0.
            counter = counter + 1.
          ENDIF.
        ELSE.                          " keyfelder nicht gleich
          icount = 0.
        ENDIF.
      ELSE.
        IF  ( xbsid-hkont EQ xbsidgr-hkont )
        AND ( xbsid-xcurr EQ xbsidgr-xcurr )
        AND ( xbsid-umskz EQ xbsidgr-umskz )
        AND ( xbsid-bedg1 EQ xbsidgr-bedg1 )
        AND ( xbsid-bedg2 EQ xbsidgr-bedg2 )
        AND ( xbsid-bedg3 EQ xbsidgr-bedg3 )
        AND ( xbsid-bedg4 EQ xbsidgr-bedg4 )
        AND ( xbsid-bedg5 EQ xbsidgr-bedg5 ).
          icount = icount + 1.
*----- Zähler für Statistik --------------------------------------------
          IF flg_liste = char_2.
            cnt_op = cnt_op + 1.
            sum1_op = sum1_op + 1.
          ENDIF.
*----- Ausgabe der nicht ausgleichbaren Belege -------------------------
          IF flg_liste = char_3.
            PERFORM record_document USING 'XBSID'.
          ENDIF.
          counter = counter + 1.
        ELSE.                          " key-felder nicht gleich
          icount = 0.
        ENDIF.
      ENDIF.
    WHEN 'K'.
      IF i_betrag = 0 OR xtol = 'X'.
        IF  ( xbsik-hkont EQ xbsikgr-hkont )
        AND ( xbsik-xcurr EQ xbsikgr-xcurr )
        AND ( xbsik-umskz EQ xbsikgr-umskz )
        AND ( xbsik-bedg1 EQ xbsikgr-bedg1 )
        AND ( xbsik-bedg2 EQ xbsikgr-bedg2 )
        AND ( xbsik-bedg3 EQ xbsikgr-bedg3 )
        AND ( xbsik-bedg4 EQ xbsikgr-bedg4 )
        AND ( xbsik-bedg5 EQ xbsikgr-bedg5 ).
          icount = icount + 1.
          MOVE-CORRESPONDING xbsik TO ybsik.
*----- Ausgleichsdatum aus jüngstem Beleg? -----------------------------
          PERFORM augdt_bestimmen USING i_koart.            "985181
          APPEND ybsik.
*----- Zähler für Statistik --------------------------------------------
          IF flg_liste = char_2.
            cnt_ap = cnt_ap + 1.
            cnt_op = cnt_op + 1.
            sum1_ap = sum1_ap + 1.
            sum1_op = sum1_op + 1.
          ENDIF.
*----- Ausgabe der ausgleichbaren Belege -------------------------------
          IF flg_liste = char_3.
            PERFORM record_document USING 'XBSIK'.
          ENDIF.
          IF i_betrag NE 0.
            counter = counter + 1.
          ENDIF.
        ELSE.                          " keyfelder nicht gleich
          icount = 0.
        ENDIF.
      ELSE.
        IF  ( xbsik-hkont EQ xbsikgr-hkont )
        AND ( xbsik-xcurr EQ xbsikgr-xcurr )
        AND ( xbsik-umskz EQ xbsikgr-umskz )
        AND ( xbsik-bedg1 EQ xbsikgr-bedg1 )
        AND ( xbsik-bedg2 EQ xbsikgr-bedg2 )
        AND ( xbsik-bedg3 EQ xbsikgr-bedg3 )
        AND ( xbsik-bedg4 EQ xbsikgr-bedg4 )
        AND ( xbsik-bedg5 EQ xbsikgr-bedg5 ).
          icount = icount + 1.
*----- Zähler für Statistik --------------------------------------------
          IF flg_liste = char_2.
            cnt_op = cnt_op + 1.
            sum1_op = sum1_op + 1.
          ENDIF.
*----- Ausgabe der nicht ausgleichbaren Belege -------------------------
          IF flg_liste = char_3.
            PERFORM record_document USING 'XBSIK'.
          ENDIF.
          counter = counter + 1.
        ELSE.                          " key-felder nicht gleich
          icount = 0.
        ENDIF.
      ENDIF.
    WHEN 'S'.
      IF i_betrag = 0 OR xtol = 'X'.
        IF  ( xbsis-hkont EQ xbsisgr-hkont )
        AND ( xbsis-xcurr EQ xbsisgr-xcurr )
        AND ( xbsis-bedg1 EQ xbsisgr-bedg1 )
        AND ( xbsis-bedg2 EQ xbsisgr-bedg2 )
        AND ( xbsis-bedg3 EQ xbsisgr-bedg3 )
        AND ( xbsis-bedg4 EQ xbsisgr-bedg4 )
        AND ( xbsis-bedg5 EQ xbsisgr-bedg5 )
        AND ( xbsis-ldgrp EQ xbsisgr-ldgrp ).
          icount = icount + 1.
          MOVE-CORRESPONDING xbsis TO ybsis.
*----- Ausgleichsdatum aus jüngstem Beleg? -----------------------------
          PERFORM augdt_bestimmen USING i_koart.            "985181
          APPEND ybsis.
*----- Zähler für Statistik --------------------------------------------
          IF flg_liste = char_2.
            cnt_ap = cnt_ap + 1.
            cnt_op = cnt_op + 1.
            sum1_ap = sum1_ap + 1.
            sum1_op = sum1_op + 1.
          ENDIF.
*----- Ausgabe der ausgleichbaren Belege -------------------------------
          IF flg_liste = char_3.
            PERFORM record_document USING 'XBSIS'.
          ENDIF.
          IF i_betrag NE 0.
            counter = counter + 1.
          ENDIF.
        ELSE.                          " keyfelder nicht gleich
          icount = 0.
        ENDIF.
      ELSE.
        IF  ( xbsis-hkont EQ xbsisgr-hkont )
        AND ( xbsis-xcurr EQ xbsisgr-xcurr )
        AND ( xbsis-bedg1 EQ xbsisgr-bedg1 )
        AND ( xbsis-bedg2 EQ xbsisgr-bedg2 )
        AND ( xbsis-bedg3 EQ xbsisgr-bedg3 )
        AND ( xbsis-bedg4 EQ xbsisgr-bedg4 )
        AND ( xbsis-bedg5 EQ xbsisgr-bedg5 )
        AND ( xbsis-ldgrp EQ xbsisgr-ldgrp ).
          icount = icount + 1.
*----- Zähler für Statistik --------------------------------------------
          IF flg_liste = char_2.
            cnt_op = cnt_op + 1.
            sum1_op = sum1_op + 1.
          ENDIF.
*----- Ausgabe der nicht ausgleichbaren Belege -------------------------
          IF flg_liste = char_3.
            PERFORM record_document USING 'XBSIS'.
          ENDIF.
          counter = counter + 1.
        ELSE.                          " key-felder nicht gleich
          icount = 0.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    "VERARBEITEN
*&---------------------------------------------------------------------*
*&      Form  AUGDT_BESTIMMEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KOART  text
*----------------------------------------------------------------------*
FORM augdt_bestimmen USING    p_koart LIKE bseg-koart.
  CASE p_koart.
    WHEN 'D'.
      IF ybsid-budat > augdt.
        augdt = ybsid-budat.
      ENDIF.
    WHEN 'K'.
      IF ybsik-budat > augdt.
        augdt = ybsik-budat.
      ENDIF.
    WHEN 'S'.
      IF ybsis-budat > augdt.
        augdt = ybsis-budat.
      ENDIF.
  ENDCASE.
ENDFORM.                               " AUGDT_BESTIMMEN
*---------------------------------------------------------------------*
*       FORM RECORD_DOCUMENT                                          *
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*  -->  ITAB                                                          *
*---------------------------------------------------------------------*
FORM record_document USING itab.
**comment
*  CASE itab.
*    WHEN 'XBSID'.
*      MOVE-CORRESPONDING xbsid TO gs_bsid.
*      gs_bsid-waers = xbsid-xcurr.
*      gs_bsid-wrbtr = xbsid-xamnt.
*      APPEND gs_bsid to XBSID.
*    WHEN 'XBSIK'.
*      MOVE-CORRESPONDING xbsik TO gs_bsik.
*      gs_bsik-waers = xbsik-xcurr.
*      gs_bsik-wrbtr = xbsik-xamnt.
*      APPEND gs_bsik to xbsik.
*    WHEN 'XBSIS'.
*      MOVE-CORRESPONDING xbsis TO gs_bsis.
*      gs_bsis-waers = xbsis-xcurr.
*      gs_bsis-wrbtr = xbsis-xamnt.
*      APPEND gs_bsis to xbsis.
*    WHEN 'XBSISCOPY'.
*      gb_xcopy = 'X'.                                       "443350
*      MOVE-CORRESPONDING xbsiscopy TO gs_bsis.
*      gs_bsis-waers = xbsiscopy-xcurr.
*      gs_bsis-wrbtr = xbsiscopy-xamnt.
*      APPEND gs_bsis to .
*      CLEAR gb_xcopy.                                       "443350
*  ENDCASE.
ENDFORM.                    "RECORD_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  RECORD_CLEARING_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM record_clearing_info USING i_char i_uline1 i_uline2 koart.
  DATA:
    ld_footer   TYPE slis_listheader.

  CASE i_char.
    WHEN 'AUGDT'.
      PERFORM acc_append_data USING koart augdt ' ' 'AUGDT'.
    WHEN 'AUGBL'.
      PERFORM acc_append_data USING koart augdt augblnr 'AUGBL'.
    WHEN 'NOCLEAR'.
      PERFORM acc_append_data USING koart augdt ' ' 'NOCLEAR'.
    WHEN 'NOCLEARTOL'.
      PERFORM acc_append_data USING koart augdt ' ' 'NOCLEARTOL'.
    WHEN 'ENQ'.
      PERFORM acc_append_data USING koart augdt ' ' 'ENQ'.
  ENDCASE.
ENDFORM.                               " RECORD_CLEARING_INFO
*&---------------------------------------------------------------------*
*&      Form  AUGDT_PRUEFEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM augdt_pruefen USING p_koart LIKE bseg-koart.
  CASE p_koart.
    WHEN 'D'.
      CLEAR augdttab.
      READ TABLE augdttab WITH KEY bukrs = ybsid-bukrs
                                   augdt = augdt.
      IF sy-subrc NE 0.
        PERFORM periode_ermitteln                           "1121415
        USING ybsid-bukrs augdt gejahr monat.               "1121415
*----- Buchungsperiode prüfen ------------------------------------------
        PERFORM periode_pruefen
        USING ybsid-bukrs augdt gejahr monat space.         "1121415
        COLLECT augdttab.
      ELSE.
        IF augdttab-xnok = 'X'.
*----- Ausgabe: Kein Ausgleich -----------------------------------------
          PERFORM record_clearing_info USING 'NOCLEAR' ' ' 'X' p_koart.
        ENDIF.
      ENDIF.
    WHEN 'K'.
      CLEAR augdttab.
      READ TABLE augdttab WITH KEY bukrs = ybsik-bukrs
                                   augdt = augdt.
      IF sy-subrc NE 0.
        PERFORM periode_ermitteln                           "1121415
        USING ybsik-bukrs augdt gejahr monat.               "1121415
*----- Buchungsperiode prüfen ------------------------------------------
        PERFORM periode_pruefen
        USING ybsik-bukrs augdt gejahr monat space.         "1121415
        COLLECT augdttab.
      ELSE.
        IF augdttab-xnok = 'X'.
*----- Ausgabe: Kein Ausgleich -----------------------------------------
          PERFORM record_clearing_info USING 'NOCLEAR' ' ' 'X' p_koart.
        ENDIF.
      ENDIF.
    WHEN 'S'.
      CLEAR augdttab.
      READ TABLE augdttab WITH KEY bukrs = ybsis-bukrs
                                   augdt = augdt.
      IF sy-subrc NE 0.
        PERFORM periode_ermitteln                           "1121415
        USING ybsis-bukrs augdt gejahr monat.               "1121415
*----- Buchungsperiode prüfen ------------------------------------------
        PERFORM periode_pruefen
        USING ybsis-bukrs augdt gejahr monat space.         "1121415
        COLLECT augdttab.
      ELSE.
        IF augdttab-xnok = 'X'.
*----- Ausgabe: Kein Ausgleich -----------------------------------------
          PERFORM record_clearing_info USING 'NOCLEAR' ' ' 'X' p_koart.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                               " AUGDT_PRUEFEN
*&---------------------------------------------------------------------*
*&      Form  check_gruppe
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RCGRUP  text
*----------------------------------------------------------------------*
FORM check_gruppe CHANGING p_rcgrup.
  CASE koart.
    WHEN 'D'.
      DESCRIBE TABLE ybsid LINES sy-tfill.
    WHEN 'K'.
      DESCRIBE TABLE ybsik LINES sy-tfill.
    WHEN 'S'.
      DESCRIBE TABLE ybsis LINES sy-tfill.
  ENDCASE.
  IF sy-tfill LE 1.
    IF sy-tfill = 1.
      CASE koart.
        WHEN 'D'.
          READ TABLE ybsid INDEX 1.
          IF ybsid-wrbtr NE 0.
            p_rcgrup = 4.
          ENDIF.
        WHEN 'K'.
          READ TABLE ybsik INDEX 1.
          IF ybsik-wrbtr NE 0.
            p_rcgrup = 4.
          ENDIF.
        WHEN 'S'.
          READ TABLE ybsis INDEX 1.
          IF ybsis-pswbt NE 0.
            p_rcgrup = 4.
          ENDIF.
      ENDCASE.
    ELSE.
      p_rcgrup = 4.
    ENDIF.
  ENDIF.
ENDFORM.                               " check_gruppe
*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_transaction USING i_koart LIKE bseg-koart.
*------ Temporäres Speichern der auszugleichenden Belege aus YBSIS -----
  DATA  BEGIN OF tbsis OCCURS 1.
          INCLUDE STRUCTURE bsis.
  DATA  END OF tbsis.
*------ Temporäres Speichern der auszugleichenden Belege aus YBSID -----
  DATA  BEGIN OF tbsid OCCURS 1.
          INCLUDE STRUCTURE bsid.
  DATA  END OF tbsid.
*------ Temporäres Speichern der auszugleichenden Belege aus YBSIK -----
  DATA  BEGIN OF tbsik OCCURS 1.
          INCLUDE STRUCTURE bsik.
  DATA  END OF tbsik.
  DATA: xcalltr(1) TYPE c.

  CHECK augdttab-xnok = ' '.

  x_ausglv = 'X'. " Ausgl.vorgang wurde versucht, nur für Ausgabezwecke
  mod = 'N'.
  upd = 'S'.
*----- FB1* soll nicht mehr sperren ------------------------------------
*  export xf124e to memory id '%F124E%'.
*----- Export to memory und call transaction ---------------------------
  CASE i_koart.
    WHEN 'D'.
      REFRESH messtab.
      CLEAR messtab.
      IF min_bel = 0.
        PERFORM bdcdtab_fuellen USING i_koart.
        EXPORT ybsid TO MEMORY ID '%F124%'.
        CALL TRANSACTION 'FB1D' USING bdcdtab
                                 MODE mod
                                 UPDATE upd
                                 MESSAGES INTO messtab.
        xcalltr = 'X'.
      ELSE.
*----- Belege für späteren Ausgleich in PBSID sammeln ------------------
        PERFORM belege_sammeln USING i_koart.
*----- Ausgleich der Belege jetzt durchführen? -------------------------
        IF ct_pbsid GE min_bel.
          CLEAR ct_pbsid.
          tbsid[] = ybsid[].
          ybsid[] = pbsid[].
          PERFORM bdcdtab_fuellen USING i_koart.
          EXPORT ybsid TO MEMORY ID '%F124%'.
          CALL TRANSACTION 'FB1D' USING bdcdtab
                                   MODE mod
                                   UPDATE upd
                                   MESSAGES INTO messtab.
          ybsid[] = tbsid[].
          xcalltr = 'X'.
        ENDIF.
      ENDIF.
    WHEN 'K'.
      REFRESH messtab.
      CLEAR messtab.
      IF min_bel = 0.
        PERFORM bdcdtab_fuellen USING i_koart.
        EXPORT ybsik TO MEMORY ID '%F124%'.
        CALL TRANSACTION 'FB1K' USING bdcdtab
                                 MODE mod
                                 UPDATE upd
                                 MESSAGES INTO messtab.
        xcalltr = 'X'.
      ELSE.
*----- Belege für späteren Ausgleich in PBSID sammeln ------------------
        PERFORM belege_sammeln USING i_koart.
*----- Ausgleich der Belege jetzt durchführen? -------------------------
        IF ct_pbsik GE min_bel.
          CLEAR ct_pbsik.
          tbsik[] = ybsik[].
          ybsik[] = pbsik[].
          PERFORM bdcdtab_fuellen USING i_koart.
          EXPORT ybsik TO MEMORY ID '%F124%'.
          CALL TRANSACTION 'FB1K' USING bdcdtab
                                   MODE mod
                                   UPDATE upd
                                   MESSAGES INTO messtab.
          ybsik[] = tbsik[].
          xcalltr = 'X'.
        ENDIF.
      ENDIF.
    WHEN 'S'.
      REFRESH messtab.
      CLEAR messtab.
      IF min_bel = 0.
        PERFORM bdcdtab_fuellen USING i_koart.
        EXPORT ybsis TO MEMORY ID '%F124%'.
        IF tsako-xlgclr IS INITIAL.
          CALL TRANSACTION 'FB1S' USING bdcdtab
                                 MODE mod
                                 UPDATE upd
                                 MESSAGES INTO messtab.
          xcalltr = 'X'.
        ELSE.
          CALL TRANSACTION 'FB1SL' USING bdcdtab
                       MODE mod
                       UPDATE upd
                       MESSAGES INTO messtab.
          xcalltr = 'X'.
        ENDIF.
      ELSE.
*----- Belege für späteren Ausgleich in PBSIS sammeln ------------------
        PERFORM belege_sammeln USING i_koart.
*----- Ausgleich der Belege jetzt durchführen? -------------------------
        IF ct_pbsis GE min_bel.
          CLEAR ct_pbsis.
          tbsis[] = ybsis[].
          ybsis[] = pbsis[].
          PERFORM bdcdtab_fuellen USING i_koart.
          EXPORT ybsis TO MEMORY ID '%F124%'.
          IF tsako-xlgclr IS INITIAL.
            CALL TRANSACTION 'FB1S' USING bdcdtab
                                     MODE mod
                                     UPDATE upd
                                     MESSAGES INTO messtab.
            ybsis[] = tbsis[].
            xcalltr = 'X'.
          ELSE.
            CALL TRANSACTION 'FB1SL' USING bdcdtab
                                     MODE mod
                                     UPDATE upd
                                     MESSAGES INTO messtab.
            ybsis[] = tbsis[].
            xcalltr = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.
  IF xcalltr = 'X'.
    IF x_echtl = space.
*----- Meldung Batch-Input Daten auf Dynpro ... im Testlauf ignorieren -
      READ TABLE messtab WITH KEY msgid = '00' msgnr = '344'.
      IF sy-subrc = 0.
        DELETE messtab INDEX sy-tabix.
      ENDIF.
    ENDIF.
    PERFORM messtab_auswerten USING koart.
  ENDIF.
ENDFORM.                               " CALL_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  BDCDTAB_FUELLEN
*&---------------------------------------------------------------------*
*  Füllen der bdcdtab zur Übergabe für call transaction
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bdcdtab_fuellen USING i_koart LIKE bseg-koart.
  FIELD-SYMBOLS: <xbsis> TYPE ys_xbsis.
  CLEAR bdcdtab.
  CASE i_koart.
    WHEN 'D'.
      REFRESH bdcdtab.
      READ TABLE ybsid INDEX 1.
*--- Felder des Startdynpros der Ausgleichstransaktion füllen-----------
      bdcdtab-program = 'SAPMF05A'.
      bdcdtab-dynpro = '0131'.
      bdcdtab-dynbegin = 'X'.
      bdcdtab-fnam = ' '.
      bdcdtab-fval = ' '.
      APPEND bdcdtab.

      bdcdtab-dynpro = '0000'.
      bdcdtab-dynbegin = ' '.
      bdcdtab-fnam = 'RF05A-AGKON'.
      bdcdtab-fval = ybsid-kunnr.
      APPEND bdcdtab.

      bdcdtab-dynpro = '0000'.
      bdcdtab-dynbegin = ' '.
      bdcdtab-fnam = 'BKPF-BUKRS'.
      bdcdtab-fval = ybsid-bukrs.
      APPEND bdcdtab.

      bdcdtab-dynpro = '0000'.
      bdcdtab-dynbegin = ' '.
      bdcdtab-fnam = 'BKPF-WAERS'.
      bdcdtab-fval = xbsidgr-xcurr.                         "1033780
      APPEND bdcdtab.

      bdcdtab-dynpro = '0000'.
      bdcdtab-dynbegin = ' '.
      bdcdtab-fnam = 'BKPF-BUDAT'.
      WRITE augdt TO bdcdtab-fval DD/MM/YYYY.
      APPEND bdcdtab.

      bdcdtab-dynpro = '0000'.
      bdcdtab-dynbegin = ' '.
      bdcdtab-fnam = 'BKPF-MONAT'.
      bdcdtab-fval = monat.                                 "1121415
      APPEND bdcdtab.

      bdcdtab-dynpro = '0000'.
      bdcdtab-dynbegin = ' '.
      bdcdtab-fnam = 'RF05A-XNOPS'.
      bdcdtab-fval = 'X'.
      APPEND bdcdtab.

      IF x_avisd = 'X'.
        bdcdtab-dynpro = '0000'.
        bdcdtab-dynbegin = ' '.
        bdcdtab-fnam = 'RF05A-AVSID'.
        bdcdtab-fval = ybsid-xref3.
        APPEND bdcdtab.
      ENDIF.


*----- Toleranzen im Testlauf simulieren oder Buchen? ------------------
      IF xtol = 'X' AND x_echtl = space.
*---------- OP-Bearbeitung ---------------------------------------------
        bdcdtab-dynpro = '0000'.
        bdcdtab-dynbegin = ' '.
        bdcdtab-fnam = 'BDC_OKCODE'.
        bdcdtab-fval = 'PA'.
        APPEND bdcdtab.

*---------- Simulieren -------------------------------------------------
        bdcdtab-program = 'SAPDF05X'.
*       BDCDTAB-DYNPRO = '1102'.
        bdcdtab-dynpro = '3100'.
        bdcdtab-dynbegin = 'X'.
        bdcdtab-fnam = 'BDC_OKCODE'.
        bdcdtab-fval = 'BS'.
        APPEND bdcdtab.
*--------- Auf Dynpro 700 gibt es kein Simulieren! ---------------------
      ELSE.
*---------- Buchen -----------------------------------------------------
        bdcdtab-dynpro = '0000'.
        bdcdtab-dynbegin = ' '.
        bdcdtab-fnam = 'BDC_OKCODE'.
        bdcdtab-fval = '/11'.
        APPEND bdcdtab.
*---------- ENTER aud Dynpro 700 wegen automatischen Zeilen (313) ------
        IF xnkon = space.
          bdcdtab-program = 'SAPMF05A'.
          bdcdtab-dynpro = '0700'.
          bdcdtab-dynbegin = 'X'.
          bdcdtab-fnam = 'BDC_OKCODE'.
          bdcdtab-fval = '/ '.
          APPEND bdcdtab.
*---------- Buchen -----------------------------------------------------
          bdcdtab-dynpro = '0000'.
          bdcdtab-dynbegin = ' '.
          bdcdtab-fnam = 'BDC_OKCODE'.
          bdcdtab-fval = '/11'.
          APPEND bdcdtab.
        ENDIF.
      ENDIF.
    WHEN 'K'.
      REFRESH bdcdtab.
      READ TABLE ybsik INDEX 1.
*--- Felder des Startdynpros der Ausgleichstransaktion füllen-----------
      bdcdtab-program = 'SAPMF05A'.
      bdcdtab-dynpro = '0131'.
      bdcdtab-dynbegin = 'X'.
      bdcdtab-fnam = ' '.
      bdcdtab-fval = ' '.
      APPEND bdcdtab.

      bdcdtab-dynpro = '0000'.
      bdcdtab-dynbegin = ' '.
      bdcdtab-fnam = 'RF05A-AGKON'.
      bdcdtab-fval = ybsik-lifnr.
      APPEND bdcdtab.

      bdcdtab-dynpro = '0000'.
      bdcdtab-dynbegin = ' '.
      bdcdtab-fnam = 'BKPF-BUKRS'.
      bdcdtab-fval = ybsik-bukrs.
      APPEND bdcdtab.

      bdcdtab-dynpro = '0000'.
      bdcdtab-dynbegin = ' '.
      bdcdtab-fnam = 'BKPF-WAERS'.
      bdcdtab-fval = xbsikgr-xcurr.                         "1033780
      APPEND bdcdtab.

      bdcdtab-dynpro = '0000'.
      bdcdtab-dynbegin = ' '.
      bdcdtab-fnam = 'BKPF-BUDAT'.
      WRITE augdt TO bdcdtab-fval DD/MM/YYYY.
      APPEND bdcdtab.

      bdcdtab-dynpro = '0000'.
      bdcdtab-dynbegin = ' '.
      bdcdtab-fnam = 'BKPF-MONAT'.
      bdcdtab-fval = monat.                                 "1121415
      APPEND bdcdtab.

      bdcdtab-dynpro = '0000'.
      bdcdtab-dynbegin = ' '.
      bdcdtab-fnam = 'RF05A-XNOPS'.
      bdcdtab-fval = 'X'.
      APPEND bdcdtab.
*----- Toleranzen im Testlauf simulieren oder Buchen? ------------------
      IF xtol = 'X' AND x_echtl = space.
*---------- OP-Bearbeitung ---------------------------------------------
        bdcdtab-dynpro = '0000'.
        bdcdtab-dynbegin = ' '.
        bdcdtab-fnam = 'BDC_OKCODE'.
        bdcdtab-fval = 'PA'.
        APPEND bdcdtab.

*---------- Simulieren -------------------------------------------------
        bdcdtab-program = 'SAPDF05X'.
*        BDCDTAB-DYNPRO = '1102'.
        bdcdtab-dynpro = '3100'.
        bdcdtab-dynbegin = 'X'.
        bdcdtab-fnam = 'BDC_OKCODE'.
        bdcdtab-fval = 'BS'.
        APPEND bdcdtab.
*--------- Auf Dynpro 700 gibt es kein Simulieren! ---------------------
      ELSE.
*---------- Buchen -----------------------------------------------------
        bdcdtab-dynpro = '0000'.
        bdcdtab-dynbegin = ' '.
        bdcdtab-fnam = 'BDC_OKCODE'.
        bdcdtab-fval = '/11'.
        APPEND bdcdtab.
        IF xnkon = space.
*---------- ENTER auf Dynpro 700 wegen automatischen Zeilen (313) ------
          bdcdtab-program = 'SAPMF05A'.
          bdcdtab-dynpro = '0700'.
          bdcdtab-dynbegin = 'X'.
          bdcdtab-fnam = 'BDC_OKCODE'.
          bdcdtab-fval = '/ '.
          APPEND bdcdtab.
*---------- Buchen -----------------------------------------------------
          bdcdtab-dynpro = '0000'.
          bdcdtab-dynbegin = ' '.
          bdcdtab-fnam = 'BDC_OKCODE'.
          bdcdtab-fval = '/11'.
          APPEND bdcdtab.
        ENDIF.
      ENDIF.
    WHEN 'S'.
      REFRESH bdcdtab.
      READ TABLE ybsis INDEX 1.
*--- Felder des Startdynpros der Ausgleichstransaktion füllen-----------
      bdcdtab-program = 'SAPMF05A'.
      bdcdtab-dynpro = '0131'.
      bdcdtab-dynbegin = 'X'.
      bdcdtab-fnam = ' '.
      bdcdtab-fval = ' '.
      APPEND bdcdtab.

      bdcdtab-dynpro = '0000'.
      bdcdtab-dynbegin = ' '.
      bdcdtab-fnam = 'RF05A-AGKON'.
      bdcdtab-fval = ybsis-hkont.
      APPEND bdcdtab.

      bdcdtab-dynpro = '0000'.
      bdcdtab-dynbegin = ' '.
      bdcdtab-fnam = 'BKPF-BUKRS'.
      bdcdtab-fval = ybsis-bukrs.
      APPEND bdcdtab.

      IF tsako-xlgclr = 'X'.
        READ TABLE xbsis WITH KEY bukrs = ybsis-bukrs
                                  hkont = ybsis-hkont
                                  gjahr = ybsis-gjahr
                                  belnr = ybsis-belnr
                                  buzei = ybsis-buzei
                         ASSIGNING <xbsis>.
        bdcdtab-dynpro = '0000'.
        bdcdtab-dynbegin = ' '.
        bdcdtab-fnam = 'BKPF-LDGRP'.
        bdcdtab-fval = <xbsis>-ldgrp.
        APPEND bdcdtab.
      ENDIF.

      IF gv_tcode <> 'F13L'.
        bdcdtab-dynpro = '0000'.
        bdcdtab-dynbegin = ' '.
        bdcdtab-fnam = 'BKPF-WAERS'.
        bdcdtab-fval = xbsisgr-xcurr.                       "1033780
        APPEND bdcdtab.
      ENDIF.

      bdcdtab-dynpro = '0000'.
      bdcdtab-dynbegin = ' '.
      bdcdtab-fnam = 'BKPF-BUDAT'.
      WRITE augdt TO bdcdtab-fval DD/MM/YYYY.
      APPEND bdcdtab.

      bdcdtab-dynpro = '0000'.
      bdcdtab-dynbegin = ' '.
      bdcdtab-fnam = 'BKPF-MONAT'.
      bdcdtab-fval = monat.                                 "1121415
      APPEND bdcdtab.

*----- Toleranzen im Testlauf simulieren oder Buchen? ------------------
      IF xtol = 'X' AND x_echtl = space.
*---------- OP-Bearbeitung ---------------------------------------------
        bdcdtab-dynpro = '0000'.
        bdcdtab-dynbegin = ' '.
        bdcdtab-fnam = 'BDC_OKCODE'.
        bdcdtab-fval = 'PA'.
        APPEND bdcdtab.

*---------- Simulieren -------------------------------------------------
        bdcdtab-program = 'SAPDF05X'.
*        BDCDTAB-DYNPRO = '1103'.
        bdcdtab-dynpro = '3100'.
        bdcdtab-dynbegin = 'X'.
        bdcdtab-fnam = 'BDC_OKCODE'.
        bdcdtab-fval = 'BS'.
        APPEND bdcdtab.
*--------- Auf Dynpro 700 gibt es kein Simulieren! ---------------------
      ELSE.
*---------- Buchen -----------------------------------------------------
        bdcdtab-dynpro = '0000'.
        bdcdtab-dynbegin = ' '.
        bdcdtab-fnam = 'BDC_OKCODE'.
        bdcdtab-fval = '/11'.
        APPEND bdcdtab.
*---------- ENTER auf Dynpro 700 wegen automatischen Zeilen (313) ------
        IF xnkon = space.
          bdcdtab-program = 'SAPMF05A'.
          bdcdtab-dynpro = '0700'.
          bdcdtab-dynbegin = 'X'.
          bdcdtab-fnam = 'BDC_OKCODE'.
          bdcdtab-fval = '/ '.
          APPEND bdcdtab.
*---------- Buchen -----------------------------------------------------
          bdcdtab-dynpro = '0000'.
          bdcdtab-dynbegin = ' '.
          bdcdtab-fnam = 'BDC_OKCODE'.
          bdcdtab-fval = '/11'.
          APPEND bdcdtab.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                               " BDCDTAB_FUELLEN

*&---------------------------------------------------------------------*
*&      Form  belege_sammeln
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KOART  text
*----------------------------------------------------------------------*
FORM belege_sammeln USING    p_koart.
  CASE p_koart.
    WHEN 'D'.
      LOOP AT ybsid.
        pbsid = ybsid.
        APPEND pbsid.
        ct_pbsid = ct_pbsid + 1.
      ENDLOOP.
    WHEN 'K'.
      LOOP AT ybsik.
        pbsik = ybsik.
        APPEND pbsik.
        ct_pbsik = ct_pbsik + 1.
      ENDLOOP.
    WHEN 'S'.
      LOOP AT ybsis.
        pbsis = ybsis.
        APPEND pbsis.
        ct_pbsis = ct_pbsis + 1.
      ENDLOOP.
  ENDCASE.
ENDFORM.                               " belege_sammeln

*&---------------------------------------------------------------------*
*&      Form  messtab_auswerten
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_KOART  text
*----------------------------------------------------------------------*
FORM messtab_auswerten USING koart.
  DATA: ld_errtol(1) TYPE c.

*----- Verarbeitung der messtab ----------------------------------------
  IF x_echtl = 'X'.
*----- Beleg gebucht? --------------------------------------------------
    READ TABLE messtab WITH KEY msgid = 'F5' msgnr = '312'.
*   "Beleg & wurde im Buchungskreis & gebucht"
    IF sy-subrc EQ 0.
*----- ... ja! ---------------------------------------------------------
*----- Ausgleichsbelegnr u. Ausgleichsdatum ausgeben -------------------
      IF flg_liste = char_3.
        augblnr = messtab-msgv1.
        PERFORM record_clearing_info USING 'AUGBL' ' ' 'X' koart.
      ENDIF.
      IF flg_liste = char_2.
        PERFORM statistik_fortschreiben USING koart.
      ENDIF.
    ELSE.
*----- ... nein! -------------------------------------------------------
      IF xtol = space.
        IF flg_liste = char_3.
*----- Ausgabe: Kein Ausgleich -----------------------------------------
          PERFORM record_clearing_info USING 'NOCLEAR' ' ' 'X' koart.
        ENDIF.
*----- Fehlerprotokoll füllen ------------------------------------------
        IF x_fehler = 'X'.
          x_fehl_sub = 'X'.
          PERFORM messtab_lesen USING koart.
        ENDIF.
      ELSE.
*----- Bei Toleranzen: Differenz zu groß? ------------------------------
        READ TABLE messtab WITH KEY msgid = 'F5' msgnr = '263'.
*       "Die Differenz ist für einen Ausgleich zu groß"
        IF sy-subrc = 0.
*----- ... ja! ---------------------------------------------------------
          IF flg_liste = char_3.
*----- Ausgabe: Kein Ausgleich (Differenz zu groß, kein Fehlerprot. ----
            PERFORM record_clearing_info USING 'NOCLEARTOL' ' ' 'X' koart.
          ENDIF.
        ELSE.
*----- ... nein! -------------------------------------------------------
          IF flg_liste = char_3.
*----- Ausgabe: Kein Ausgleich -----------------------------------------
            PERFORM record_clearing_info USING 'NOCLEAR' ' ' 'X' koart.
          ENDIF.
*----- Fehlerprotokoll füllen ------------------------------------------
          IF x_fehler = 'X'.
            x_fehl_sub = 'X'.
            PERFORM messtab_lesen USING koart.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSEIF ( x_echtl = space AND xtol = 'X' ).
*----- Differenz zu groß? ----------------------------------------------
    READ TABLE messtab WITH KEY msgid = 'F5' msgnr = '263'.
    IF sy-subrc NE 0.
*----- nein --> Ausgleichsdatum ausgeben, falls kein anderer Fehler ----
      LOOP AT messtab WHERE msgtyp = 'E'.
        ld_errtol = 'X'.
        EXIT.
      ENDLOOP.
      IF flg_liste = char_3.
        IF enqsubrc = 0.
          IF ld_errtol = 'X'.
            PERFORM record_clearing_info USING 'NOCLEAR' ' ' 'X' koart.
          ELSE.
            PERFORM record_clearing_info USING 'AUGDT' ' ' 'X' koart.
          ENDIF.
        ENDIF.
      ENDIF.
*----- Fehlerprotokoll füllen ------------------------------------------
      IF x_fehler = 'X'.
        x_fehl_sub = 'X'.
        PERFORM messtab_lesen USING koart.
      ENDIF.
      IF flg_liste = char_2 AND ld_errtol = space.
        PERFORM statistik_fortschreiben USING koart.
      ENDIF.
    ELSE.
*----- ... ja ----------------------------------------------------------
      IF flg_liste = char_3.
*----- Ausgabe: Kein Ausgleich (Differenz zu groß) ---------------------
        PERFORM record_clearing_info USING 'NOCLEARTOL' ' ' 'X' koart.
      ENDIF.
    ENDIF.
  ENDIF.
  IF min_bel NE 0.
    REFRESH: pbsid, pbsik, pbsis.
    augdt = save_augdt.                                     "985181
  ENDIF.
*----- immer Meldung bei ausl. Währung ------------------------- "985181
  READ TABLE messtab WITH KEY msgid = 'E!' msgnr = '101'.
  IF sy-subrc = 0.
    PERFORM auslaufende_waehrung_merken USING messtab-msgid
                                              messtab-msgtyp
                                              messtab-msgnr
                                              messtab-msgv1.
  ENDIF.                                                    "985181
ENDFORM.                               " messtab_auswerten

*&---------------------------------------------------------------------*
*&      Form  statistik_fortschreiben
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_KOART  text
*----------------------------------------------------------------------*
FORM statistik_fortschreiben USING    p_koart.
  CASE p_koart.
    WHEN 'D'.
      IF min_bel = 0.
        DESCRIBE TABLE ybsid LINES sy-tfill.
      ELSE.
        DESCRIBE TABLE pbsid LINES sy-tfill.
      ENDIF.
      cnt_eap = cnt_eap + sy-tfill.
      sum1_eap = sum1_eap + sy-tfill.
    WHEN 'K'.
      IF min_bel = 0.
        DESCRIBE TABLE ybsik LINES sy-tfill.
      ELSE.
        DESCRIBE TABLE pbsik LINES sy-tfill.
      ENDIF.
      cnt_eap = cnt_eap + sy-tfill.
      sum1_eap = sum1_eap + sy-tfill.
    WHEN 'S'.
      IF min_bel = 0.
        DESCRIBE TABLE ybsis LINES sy-tfill.
      ELSE.
        DESCRIBE TABLE pbsis LINES sy-tfill.
      ENDIF.
      cnt_eap = cnt_eap + sy-tfill.
      sum1_eap = sum1_eap + sy-tfill.
  ENDCASE.

ENDFORM.                               " statistik_fortschreiben

*&---------------------------------------------------------------------*
*&      Form  MESSTAB_LESEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM messtab_lesen USING i_koart LIKE bseg-koart.
  CLEAR cha500.
  CLEAR t100.
  LOOP AT messtab.
    PERFORM nachricht_merken USING messtab-msgspra messtab-msgid
                                   messtab-msgnr messtab-msgv1
                                   messtab-msgv2 messtab-msgv3
                                   messtab-msgv4
                                   i_koart
                                   messtab-dyname messtab-dynumb
                                   messtab-msgtyp.
  ENDLOOP.
ENDFORM.                               " MESSTAB_LESEN

*&---------------------------------------------------------------------*
*&      Form  clear_augdt_testl
*&---------------------------------------------------------------------*
*       Ausgleichsdatum aus jüngstem Beleg im Testlauf clearen
*----------------------------------------------------------------------*
*      -->P_KOART  text
*----------------------------------------------------------------------*
FORM clear_augdt_testl USING p_koart.
  CHECK x_echtl = space.                                    "985181
  PERFORM belege_sammeln USING p_koart.
  CASE p_koart.
    WHEN 'D'.
      IF ct_pbsid GE min_bel.
        CLEAR ct_pbsid.                                     "985181
        augdt = save_augdt.                                 "985181
        REFRESH pbsid.
      ENDIF.
    WHEN 'K'.
      IF ct_pbsik GE min_bel.
        CLEAR ct_pbsik.                                     "985181
        augdt = save_augdt.                                 "985181
        REFRESH pbsik.
      ENDIF.
    WHEN 'S'.
      IF ct_pbsis GE min_bel.
        CLEAR ct_pbsis.                                     "985181
        augdt = save_augdt.                                 "985181
        REFRESH pbsis.
      ENDIF.
  ENDCASE.
ENDFORM.                               " clear_augdt_testl

*&---------------------------------------------------------------------*
*&      Form  SONDERVERARBEITUNG_WERE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sonderverarbeitung_were.
* redesigned by note 574482
  DATA: ld_grpsh LIKE bseg-shkzg,
        ld_scount LIKE sy-tabix,
        ld_hcount LIKE sy-tabix.
  DATA: xbsiscopys2 TYPE yt_xbsis WITH HEADER LINE,         "1026807
        xbsiscopyh2 TYPE yt_xbsis WITH HEADER LINE.         "1026807

  counter = 0.

*--search for the one document which is too much---------------------
  IF xbsisgr-bet_tw > 0.
    ld_grpsh = 'S'.
    savebetrag_tw = xbsisgr-bet_tw.
  ELSE.
    ld_grpsh = 'H'.
    savebetrag_tw = xbsisgr-bet_tw * -1.
  ENDIF.
  IF savebetrag_tw LE 9999999999999.
    IF xsobwere = space.
*        how is XBSIS sorted?
      READ TABLE xbsis
      WITH KEY hkont = xbsisgr-hkont
               xcurr = xbsisgr-xcurr
               bedg1 = xbsisgr-bedg1
               bedg2 = xbsisgr-bedg2
               bedg3 = xbsisgr-bedg3
               bedg4 = xbsisgr-bedg4
               bedg5 = xbsisgr-bedg5
               xamnt = savebetrag_tw
      BINARY SEARCH.
    ELSE.
      READ TABLE iwere
      WITH KEY bukrs = bsis-bukrs
               hkont = bsis-hkont.
      IF sy-subrc = 0.
        READ TABLE xbsis
        WITH KEY hkont = xbsisgr-hkont
                 xcurr = xbsisgr-xcurr
                 bedg2 = xbsisgr-bedg2
                 bedg3 = xbsisgr-bedg3
                 bedg1 = xbsisgr-bedg1
                 bedg4 = xbsisgr-bedg4
                 bedg5 = xbsisgr-bedg5
                 xamnt = savebetrag_tw
        BINARY SEARCH.
      ELSE.
        READ TABLE xbsis
        WITH KEY hkont = xbsisgr-hkont
                 xcurr = xbsisgr-xcurr
                 bedg1 = xbsisgr-bedg1
                 bedg2 = xbsisgr-bedg2
                 bedg3 = xbsisgr-bedg3
                 bedg4 = xbsisgr-bedg4
                 bedg5 = xbsisgr-bedg5
                 xamnt = savebetrag_tw
        BINARY SEARCH.
      ENDIF.
    ENDIF.
    IF sy-subrc = 0.
*        We've found one document with the amount of the whole group!
*        Now check the sign!....
      savetabix = sy-tabix.
      WHILE savetabix NE 0.
        IF sy-subrc = 0.
          IF  ( xbsis-hkont = xbsisgr-hkont )
          AND ( xbsis-xcurr = xbsisgr-xcurr )
          AND ( xbsis-bedg1 = xbsisgr-bedg1 )
          AND ( xbsis-bedg2 = xbsisgr-bedg2 )
          AND ( xbsis-bedg3 = xbsisgr-bedg3 )
          AND ( xbsis-bedg4 = xbsisgr-bedg4 )
          AND ( xbsis-bedg5 = xbsisgr-bedg5 )
          AND ( xbsis-xamnt = savebetrag_tw ).
            IF xbsis-shkzg = ld_grpsh.
*                    found one document with correct sign!
*                    write the document which can't be cleared
              counter = counter + 1.
              IF flg_liste = char_2.
                cnt_op = cnt_op + 1.
                sum1_op = sum1_op + 1.
              ENDIF.
              IF  flg_liste = char_3.
                PERFORM record_document USING 'XBSIS'.
              ENDIF.
              IF xtol = 'X' AND xtoleb = 'X'.
                APPEND xbsis TO xbsiscopytol.
                PERFORM nachtraeglicher_ausgleich USING koart
                                                        'WITH_TOL'.
                REFRESH xbsiscopytol.
              ELSE.
                PERFORM acc_append_data USING koart augdt ' ' 'NOTZERO'.
              ENDIF.
              DELETE xbsis INDEX savetabix.
*                    stop reading and keep SAVETABIX
              EXIT.
            ELSE.
*                    Read next document
              savetabix = savetabix + 1.
              READ TABLE xbsis INDEX savetabix.
            ENDIF.
          ELSE.
*                 found no document with the correct sign
            savetabix = 0.
          ENDIF.
        ELSE.
          savetabix = 0.
        ENDIF.
      ENDWHILE.
    ELSE.
*        found no document with the correct amount
      savetabix = 0.
    ENDIF.
  ELSE.
    savetabix = 0.
  ENDIF.
  PERFORM read_xbsis.
  CHECK sy-subrc = 0.
  icount = sy-tabix.
*  now fill XBSISCOPY for further processing
  WHILE icount NE 0.
    IF sy-subrc = 0.
      IF  ( xbsis-hkont = xbsisgr-hkont )
      AND ( xbsis-xcurr = xbsisgr-xcurr )
      AND ( xbsis-bedg1 = xbsisgr-bedg1 )
      AND ( xbsis-bedg2 = xbsisgr-bedg2 )
      AND ( xbsis-bedg3 = xbsisgr-bedg3 )
      AND ( xbsis-bedg4 = xbsisgr-bedg4 )
      AND ( xbsis-bedg5 = xbsisgr-bedg5 ).
        counter = counter + 1.
*----- Zähler für Statistik --------------------------------------------
        IF flg_liste = char_2.
          cnt_op = cnt_op + 1.
          sum1_op = sum1_op + 1.
        ENDIF.
        IF savetabix = 0.
*              Above, we have not found one document with the missing
*              amount and the correct sign
*              => build XBSISCOPYS and -H for next strategy
          IF xbsis-shkzg = 'S'.
            APPEND xbsis TO xbsiscopys.
          ELSE.
            APPEND xbsis TO xbsiscopyh.
          ENDIF.
        ELSE.
*              build XBSISCOPY for clearing
          APPEND xbsis TO xbsiscopy.
        ENDIF.
        icount = icount + 1.
        READ TABLE xbsis INDEX icount.
      ELSE.
        icount = 0.
      ENDIF.
    ELSE.
      icount = 0.
    ENDIF.
  ENDWHILE.
  IF savetabix NE 0.
*     XBSISCOPY is filled and ready for clearing
    PERFORM nachtraeglicher_ausgleich USING koart
                                            space.
    REFRESH xbsiscopy.
    EXIT.
  ENDIF.

  CASE counter.
    WHEN 0.
*     no documents?
      EXIT.
    WHEN 1.
*     already done above
      EXIT.
    WHEN 2.
*     If these two matched, they would already be cleared.
    WHEN 3.
*     if there were two matching, there would be one with amount of the
*     group
    WHEN OTHERS.
*     try to biuld new groups of items balancing to 0
      SORT xbsiscopyh BY xamnt ASCENDING budat ASCENDING    "955803
                         belnr ASCENDING buzei ASCENDING.   "1026807
      SORT xbsiscopys BY xamnt ASCENDING budat ASCENDING    "955803
                         belnr ASCENDING buzei ASCENDING.   "1026807
      xbsiscopys2[] = xbsiscopys[].                         "1026807
      xbsiscopyh2[] = xbsiscopyh[].                         "1026807
      SORT xbsiscopyh2 BY xamnt ASCENDING budat DESCENDING  "1026807
                         belnr DESCENDING buzei DESCENDING. "1026807
      SORT xbsiscopys2 BY xamnt ASCENDING budat DESCENDING  "1026807
                         belnr DESCENDING buzei DESCENDING. "1026807
      DESCRIBE TABLE xbsiscopys LINES ld_scount.
      DESCRIBE TABLE xbsiscopyh LINES ld_hcount.
      IF ld_scount > ld_hcount.
        PERFORM extra_logic TABLES xbsiscopys
                                   xbsiscopys2              "1026807
                                   xbsiscopyh
                                   xbsiscopyh2              "1026807
                                   xbsiscopyeq
                            USING 'X'.
*        now other turn round
        PERFORM extra_logic TABLES xbsiscopyh
                                   xbsiscopyh2              "1026807
                                   xbsiscopys
                                   xbsiscopys2              "1026807
                                   xbsiscopyeq
                            USING 'X'.
*        searching once more, less fast
        PERFORM extra_logic TABLES xbsiscopys
                                   xbsiscopys2              "1026807
                                   xbsiscopyh
                                   xbsiscopyh2              "1026807
                                   xbsiscopyeq
                            USING ' '.
        PERFORM extra_logic TABLES xbsiscopyh
                                   xbsiscopyh2              "1026807
                                   xbsiscopys
                                   xbsiscopys2              "1026807
                                   xbsiscopyeq
                            USING ' '.
      ELSE.
        PERFORM extra_logic TABLES xbsiscopyh
                                   xbsiscopyh2              "1026807
                                   xbsiscopys
                                   xbsiscopys2              "1026807
                                   xbsiscopyeq
                            USING 'X'.
        PERFORM extra_logic TABLES xbsiscopys
                                   xbsiscopys2              "1026807
                                   xbsiscopyh
                                   xbsiscopyh2              "1026807
                                   xbsiscopyeq
                            USING 'X'.
        PERFORM extra_logic TABLES xbsiscopyh
                                   xbsiscopyh2              "1026807
                                   xbsiscopys
                                   xbsiscopys2              "1026807
                                   xbsiscopyeq
                            USING ' '.
        PERFORM extra_logic TABLES xbsiscopys
                                   xbsiscopys2              "1026807
                                   xbsiscopyh
                                   xbsiscopyh2              "1026807
                                   xbsiscopyeq
                            USING ' '.
      ENDIF.
  ENDCASE.

*--try to biuld XBSISCOPY so that it balances to 0-------------------
  SORT xbsiscopyh BY xamnt DESCENDING budat DESCENDING      "792290
                     belnr DESCENDING.                      "1026807
  SORT xbsiscopys BY xamnt DESCENDING budat DESCENDING      "792290
                     belnr DESCENDING.                      "1026807
  IF ld_grpsh = 'S'.
    PERFORM xbsiscopy_fuellen TABLES xbsiscopys.
    savebetrag_tw = savebetrag_tw * -1.
    PERFORM xbsiscopy_fuellen TABLES xbsiscopyh.
  ELSE.
    PERFORM xbsiscopy_fuellen TABLES xbsiscopyh.
    savebetrag_tw = savebetrag_tw * -1.
    PERFORM xbsiscopy_fuellen TABLES xbsiscopys.
  ENDIF.
  IF savebetrag_tw = 0.
*     XBSISCOPY balances to 0, XBSISCOPYTOL contains the rest
    IF xtol = 'X'.
      DESCRIBE TABLE xbsiscopytol LINES sy-tfill.
      IF sy-tfill > 0.
        PERFORM nachtraeglicher_ausgleich USING koart
                                                'WITH_TOL'.
      ENDIF.
    ELSE.
      PERFORM acc_append_data USING koart augdt ' ' 'NOTZERO'.
    ENDIF.

    LOOP AT xbsiscopyeq INTO xbsiscopy.
*        put those found by SPECIAL_LOGIC into XBSISCOPY
      APPEND xbsiscopy.
    ENDLOOP.
    DESCRIBE TABLE xbsiscopy LINES sy-tfill.
    IF sy-tfill > 0.
      PERFORM nachtraeglicher_ausgleich USING koart
                                              space.
    ENDIF.
  ELSE.
    LOOP AT xbsiscopy.
      APPEND xbsiscopy TO xbsiscopytol.
      IF flg_liste = char_3.
        PERFORM record_document USING 'XBSISCOPY'.
      ENDIF.
    ENDLOOP.

    IF xtol = 'X'. " consider tolerances
* Here you try to clear the records that have been just written
      PERFORM nachtraeglicher_ausgleich USING koart 'WITH_TOL'.
    ELSE.
      PERFORM acc_append_data USING koart augdt ' ' 'NOTZERO'.
    ENDIF.

*     there may be some found by SPECIAL_LOGIC that can be cleared
    xbsiscopy[] = xbsiscopyeq[].
    DESCRIBE TABLE xbsiscopy LINES sy-tfill.
    IF sy-tfill > 0.
      PERFORM nachtraeglicher_ausgleich USING koart space.
    ENDIF.
  ENDIF.
  REFRESH: xbsiscopy, xbsiscopytol, xbsiscopys, xbsiscopyh,
           xbsiscopyeq, xbsiscopys2, xbsiscopyh2.           "1026807
* redesigned by note 574482
ENDFORM.                               " SONDERVERARBEITUNG_WERE
*&---------------------------------------------------------------------*
*&      Form  Extra_logic
*&
*&      new with note 574482
*&---------------------------------------------------------------------*
FORM extra_logic TABLES ct_items1 STRUCTURE xbsiscopy
                        ct_items1d STRUCTURE xbsiscopy      "1026807
                        ct_items2 STRUCTURE xbsiscopy
                        ct_items2d STRUCTURE xbsiscopy      "1026807
                        ct_equals STRUCTURE xbsiscopy
                 USING cb_fast TYPE c.
*  Logic: Fetch one document, then look for those with the other sign,
*  trying to build a group balancing to 0.
  FIELD-SYMBOLS: <l_item1> LIKE xbsiscopy,
                 <l_item2_low> LIKE xbsiscopy,
                 <l_item2_high> LIKE xbsiscopy.
  DATA: ld_sum TYPE pswbt,
        ld_diff TYPE pswbt,
        ld_low TYPE sytabix,
        ld_high TYPE sytabix,
        ld_high_keep TYPE sytabix,
        ld_mini TYPE pswbt,
        ld_maxi TYPE pswbt,
        ld_residual TYPE pswbt,
        ld_half TYPE pswbt,
        lb_toolittle TYPE c.
  DATA: lt_tmp TYPE yt_xbsis WITH HEADER LINE.

  DESCRIBE TABLE ct_items2 LINES sy-tfill.
  CHECK sy-tfill > 1.
  CLEAR ld_sum.
  LOOP AT ct_items1 ASSIGNING <l_item1>.
    CHECK <l_item1>-xamnt <> ld_sum.
*     if there was no success, we need not repeat the whole procedure
*     for the same amount
    ld_sum = <l_item1>-xamnt.
    READ TABLE ct_items2 WITH KEY xamnt = ld_sum BINARY SEARCH.
    CASE sy-subrc.
      WHEN 0.
*        found a pair of matching items
        APPEND ct_items2 TO ct_equals.
        DELETE TABLE ct_items2d FROM ct_items2.             "1026807
        DELETE TABLE ct_items2.
        APPEND <l_item1> TO ct_equals.
        DELETE TABLE ct_items1d FROM <l_item1>.             "1026807
        DELETE ct_items1.
        CLEAR ld_sum.
        CONTINUE.
      WHEN 4.
        IF sy-tabix < 3.
          CONTINUE.
        ENDIF.
      WHEN 8.
        IF sy-tabix < 3.
          EXIT.
        ENDIF.
    ENDCASE.
*     no such entry, but we need the index.
    ld_high_keep = sy-tabix - 1.
*     start searching with this. It has the highest amount possible
    CLEAR ld_mini.
    ld_half = ld_sum / 2.
    LOOP AT ct_items2 ASSIGNING <l_item2_low>.
*        get the smallest item in table 2
      CHECK <l_item2_low>-xamnt <> ld_mini.                 "1026807
*        same amount as last turn, skip it!                     "1026807
      ld_low = sy-tabix.
      IF NOT ld_low < ld_high_keep.
        EXIT.
      ENDIF.
      ld_mini = <l_item2_low>-xamnt.                        "1026807
      IF ld_mini > ld_half.
        EXIT.
      ENDIF.
      IF cb_fast = 'X'.
        ld_residual = ld_sum MOD ld_mini.
        CHECK ld_residual = 0.
      ENDIF.
      REFRESH lt_tmp.
      ld_high = ld_high_keep.
      lb_toolittle = 'X'.
      WHILE ld_low =< ld_high.                              "1026807
*           Read table 2 starting with the highest amount possible
*           and oldest date.                                    "1026807
        READ TABLE ct_items2d INDEX ld_high                 "1026807
        ASSIGNING <l_item2_high>.
        ld_maxi = <l_item2_high>-xamnt.
        IF ld_maxi = ld_mini.                               "1026807
          IF <l_item2_high> = <l_item2_low>.                "1026807
            IF ld_low = ld_high.                            "1026807
              EXIT.                                         "1026807
            ENDIF.                                          "1026807
*                 Special treatment necessary: Due to the       "1026807
*                 different sorting of CT_ITEMS2 and CT_ITEMSD, "1026807
*                 a crossover now occurs: The first high items  "1026807
*                 is the low one, hence skip it!                "1026807
            ld_diff = ld_maxi * ( ld_high - ld_low + 1 ).   "1026807
            IF ld_diff < ld_sum.                            "1026807
              EXIT.                                         "1026807
            ENDIF.                                          "1026807
            IF cb_fast = space.                             "1026807
              ld_residual = ld_sum MOD ld_maxi.             "1026807
              IF ld_residual <> 0.                          "1026807
                CLEAR lb_toolittle.                         "1026807
                EXIT.                                       "1026807
              ENDIF.                                        "1026807
            ENDIF.                                          "1026807
            ld_high = ld_high - 1.                          "1026807
            CONTINUE.                                       "1026807
          ENDIF.                                            "1026807
        ELSE.                                               "1026807
          IF cb_fast = 'X'.
            ld_residual = ld_maxi MOD ld_mini.
            IF ld_residual <> 0.
              ld_high = ld_high - 1.
              CLEAR lb_toolittle.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDIF.                                              "1026807
        ld_diff = ld_sum - ld_maxi.
        IF ld_diff > ld_mini.
*              take and keep it in LT_TMP
          APPEND <l_item2_high> TO lt_tmp.
          ld_high = ld_high - 1.
          ld_sum = ld_sum - ld_maxi.
        ELSEIF ld_diff = ld_mini.
*              together with the smallest, these items match!
          APPEND <l_item2_high> TO lt_tmp.
          APPEND <l_item2_low> TO lt_tmp.
          ld_sum = 0.
          EXIT.
        ELSEIF ld_diff = 0.
*              bingo!
          APPEND <l_item2_high> TO lt_tmp.
          ld_sum = 0.
          EXIT.
        ELSE.
*              If we took this, even the smallest item would be to big
          ld_high = ld_high - 1.
          CLEAR lb_toolittle.
        ENDIF.
      ENDWHILE.
      IF ld_sum = 0.
        CLEAR lb_toolittle.
        EXIT.
      ELSE.
        ld_sum = <l_item1>-xamnt.
      ENDIF.
      IF lb_toolittle = 'X'.
        IF ld_low = 1.
          DESCRIBE TABLE ct_items2 LINES sy-tfill.
          IF ld_high_keep < sy-tfill.
            CLEAR lb_toolittle.
          ENDIF.
        ELSE.
          CLEAR lb_toolittle.
        ENDIF.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF ld_sum = 0.
      LOOP AT lt_tmp ASSIGNING <l_item2_high>.
        APPEND <l_item2_high> TO ct_equals.
        DELETE TABLE ct_items2 FROM <l_item2_high>.
        DELETE TABLE ct_items2d FROM <l_item2_high>.        "1026807
      ENDLOOP.
      APPEND <l_item1> TO ct_equals.
      DELETE TABLE ct_items1d FROM <l_item1>.               "1026807
      DELETE ct_items1.
    ELSEIF lb_toolittle = 'X'.
      EXIT.
    ELSE.
      ld_sum = <l_item1>-xamnt.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "Extra_logic

*&---------------------------------------------------------------------*
*&      Form  xbsiscopy_FUELLEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM xbsiscopy_fuellen TABLES it_items STRUCTURE xbsiscopyh.
*  redesigned with note 574482
  LOOP AT it_items.
    MOVE it_items TO xbsiscopy.
    AT LAST.
      IF xbsiscopy-xamnt > savebetrag_tw
      AND NOT savebetrag_tw = 0.
        APPEND xbsiscopy TO xbsiscopytol.
        IF flg_liste = char_3.
          PERFORM record_document USING 'XBSISCOPY'.
        ENDIF.
        savebetrag_tw = savebetrag_tw - xbsiscopy-xamnt.
        EXIT.
      ENDIF.
    ENDAT.
    IF xbsiscopy-xamnt = 0
    OR xbsiscopy-xamnt > savebetrag_tw.
      APPEND xbsiscopy.
    ELSE.
      APPEND xbsiscopy TO xbsiscopytol.
      IF flg_liste = char_3.
        PERFORM record_document USING 'XBSISCOPY'.
      ENDIF.
      savebetrag_tw = savebetrag_tw - xbsiscopy-xamnt.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " xbsiscopy_FUELLEN

*&---------------------------------------------------------------------*
*&      Form  NACHTRAEGLICHER_AUSGLEICH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM nachtraeglicher_ausgleich USING i_koart LIKE bseg-koart
                                     p_with_tol.
  CASE i_koart.
    WHEN 'S'.
      IF p_with_tol = space.
        REFRESH ybsis.
        LOOP AT xbsiscopy.
          ybsis = xbsiscopy.
          PERFORM augdt_bestimmen USING i_koart.            "985181
          APPEND ybsis.
*----- Zähler für Statistik --------------------------------------------
          IF flg_liste = char_2.
            cnt_ap = cnt_ap + 1.
            sum1_ap = sum1_ap + 1.
          ENDIF.
*----- Ausgabe der ausgleichbaren Belege -------------------------------
          IF flg_liste = char_3.
            PERFORM record_document USING 'XBSISCOPY'.
          ENDIF.
          DELETE xbsiscopy.
        ENDLOOP.
      ELSE.
        REFRESH ybsis.
        LOOP AT xbsiscopytol.
          ybsis = xbsiscopytol.
          PERFORM augdt_bestimmen USING i_koart.            "985181
          APPEND ybsis.
*----- Zähler für Statistik --------------------------------------------
          IF flg_liste = char_2.
            cnt_ap = cnt_ap + 1.
            sum1_ap = sum1_ap + 1.
          ENDIF.
*----- Ausgabe der ausgleichbaren Belege -------------------------------
*          IF FLG_LISTE = CHAR_3.
*            PERFORM RECORD_DOCUMENT USING 'XBSISCOPYTOL'.
*          ENDIF.
          DELETE xbsiscopytol.
        ENDLOOP.
      ENDIF.
  ENDCASE.
*----- Ausgabe des Ausgleichsdatums -----------------------------------
  IF flg_liste = char_3 AND x_testl = 'X' AND xtol = space.
    PERFORM record_clearing_info USING 'AUGDT' 'X' 'X' i_koart.
  ENDIF.
*----- Ausgabe des Ausgleichsdatums im Echtlauf, -----------------------
*----- falls Kontosperre nicht erfolgreich -----------------------------
  IF x_echtl = 'X' AND enqsubrc NE 0 AND flg_liste = char_3.
    PERFORM record_clearing_info USING 'NOCLEAR' ' ' 'X' i_koart.
  ENDIF.
*----- Buchungsperiode offen? ------------------------------------------
  CLEAR gejahr.                                             "985181
  monat = bmonat.                                           "1121415
  PERFORM augdt_pruefen USING i_koart.                      "985181

  IF ( x_echtl NE space AND enqsubrc = 0 )
  OR ( x_echtl EQ space AND xtol = 'X' ).
*----- Ausgleichstransaktion aufrufen ----------------------------------
    PERFORM call_transaction USING koart.
  ENDIF.
  PERFORM clear_augdt_testl USING koart.
ENDFORM.                               " NACHTRAEGLICHER_AUSGLEICH

*&---------------------------------------------------------------------*
*&      Form  restbelege_buchen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_KOART  text
*----------------------------------------------------------------------*
FORM restbelege_buchen USING koart.
  CASE koart.
    WHEN 'D'.
      CLEAR ct_pbsid.
      DESCRIBE TABLE pbsid LINES sy-tfill.
      IF sy-tfill > 0.
        ybsid[] = pbsid[].
        IF ( x_echtl NE space AND enqsubrc = 0 )
        OR ( x_echtl EQ space AND xtol = 'X' ).
*----- Ausgleichstransaktion aufrufen ----------------------------------
          PERFORM  bdcdtab_fuellen USING koart.
          mod = 'N'.
          upd = 'S'.
          REFRESH messtab.
          CLEAR messtab.
          EXPORT ybsid TO MEMORY ID '%F124%'.
          CALL TRANSACTION 'FB1D' USING bdcdtab
                                        MODE mod
                                        UPDATE upd
                                        MESSAGES INTO messtab.
          PERFORM messtab_auswerten USING koart.
        ENDIF.
      ENDIF.
    WHEN 'K'.
      CLEAR ct_pbsik.
      DESCRIBE TABLE pbsik LINES sy-tfill.
      IF sy-tfill > 0.
        ybsik[] = pbsik[].
        IF ( x_echtl NE space AND enqsubrc = 0 )
        OR ( x_echtl EQ space AND xtol = 'X' ).
*----- Ausgleichstransaktion aufrufen ----------------------------------
          PERFORM  bdcdtab_fuellen USING koart.
          mod = 'N'.
          upd = 'S'.
          REFRESH messtab.
          CLEAR messtab.
          EXPORT ybsik TO MEMORY ID '%F124%'.
          CALL TRANSACTION 'FB1K' USING bdcdtab
                                        MODE mod
                                        UPDATE upd
                                        MESSAGES INTO messtab.
          PERFORM messtab_auswerten USING koart.
        ENDIF.
      ENDIF.
    WHEN 'S'.
      CLEAR ct_pbsis.
      DESCRIBE TABLE pbsis LINES sy-tfill.
      IF sy-tfill > 0.
        ybsis[] = pbsis[].
        IF ( x_echtl NE space AND enqsubrc = 0 )
        OR ( x_echtl EQ space AND xtol = 'X' ).
*----- Ausgleichstransaktion aufrufen ----------------------------------
          PERFORM  bdcdtab_fuellen USING koart.
          mod = 'N'.
          upd = 'S'.
          REFRESH messtab.
          CLEAR messtab.
          EXPORT ybsis TO MEMORY ID '%F124%'.
          IF tsako-xlgclr IS INITIAL.
            CALL TRANSACTION 'FB1S' USING bdcdtab
                                          MODE mod
                                          UPDATE upd
                                          MESSAGES INTO messtab.
          ELSE.
            CALL TRANSACTION 'FB1SL' USING bdcdtab
                                 MODE mod
                                 UPDATE upd
                                 MESSAGES INTO messtab.
          ENDIF.
          PERFORM messtab_auswerten USING koart.
        ENDIF.
      ENDIF.
  ENDCASE.
  IF min_bel NE 0.
    REFRESH: pbsid, pbsik, pbsis.
    augdt = save_augdt.                                     "985181
  ENDIF.
ENDFORM.                               " restbelege_buchen

*&---------------------------------------------------------------------*
*&      Form  STATISTIK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
**comment
**FORM statistik USING i_koart LIKE bseg-koart
**                     cnt_ap  TYPE i
**                     cnt_op  TYPE i
**                     cnt_eap  TYPE i
**                     enqsubrc LIKE sy-subrc
**                     i_bukrs LIKE tdebi-bukrs
**                     i_konto
**                     i_hkont LIKE xbsidgr-hkont.
**
**  DATA:
**    ls_statistik TYPE gst_statistik.
**
**  IF flg_liste EQ char_3.              "lange Ausgabeliste
**  ELSE.                                "kurze Ausgabeliste
**    IF xtol = 'X'.                                          "364207
**      cnt_ap = cnt_eap.                                     "364207
**      IF x_echtl NE 'X'.                                    "364207
**        CLEAR cnt_eap.                                      "364207
**      ENDIF.                                                "364207
**    ENDIF.                                                  "364207
**    percent = ( 1000 * cnt_ap ) / cnt_op.
**    IF x_echtl = 'X' AND enqsubrc = 0.
**      spercent = ( 1000 * cnt_eap ) / cnt_op.
**    ENDIF.
**
**    CLEAR ls_statistik.
**    IF x_echtl = 'X' AND cnt_ap NE cnt_eap.
**      ls_statistik-info = 'C71'.
**      IF cnt_eap NE 0.
**        ls_statistik-message = text-231. " Nicht alle APs ausgegl.
**      ELSE.
**        ls_statistik-message = text-043. " Kein Ausgleich
**      ENDIF.
**    ENDIF.
**
**    ls_statistik-bukrs = i_bukrs.
**    ls_statistik-koart = i_koart.
**    ls_statistik-konto = i_konto.
**    ls_statistik-hkont = i_hkont.
**    ls_statistik-cnt_op = cnt_op.
**    ls_statistik-cnt_ap = cnt_ap.
**    ls_statistik-percent = percent.
**    ls_statistik-cnt_eap = cnt_eap.
**    ls_statistik-spercent = spercent.
**    APPEND ls_statistik TO gt_statistik.
**
**  ENDIF.
**ENDFORM.                               " STATISTIK

*&---------------------------------------------------------------------*
*&      Form  AUSGABE_GESAMTSUMME
*&---------------------------------------------------------------------*
*  Statistik (Kurzliste): Ausgabe der Summenzeile über alle Bukrse
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
**comment
**FORM ausgabe_gesamtsumme.
**  bukreis = '0001'.                    "Dummy
**  sumg_op = sumd_op + sumk_op + sums_op.
**  sumg_ap = sumd_ap + sumk_ap + sums_ap.
**  sumg_eap = sumd_eap + sumk_eap + sums_eap.
**  IF sumg_op > 0.
**    PERFORM sum_info USING bukreis '0' sumg_op sumg_ap sumg_eap.
**  ENDIF.
**ENDFORM.                               " AUSGABE_GESAMTSUMME

*---------------------------------------------------------------------*
*       FORM SUM_INFO                                                 *
*---------------------------------------------------------------------*
*       Summeninformation                                             *
*---------------------------------------------------------------------*
**comment
**FORM sum_info USING  i_bukrs LIKE t001-bukrs
**                     i_level TYPE c
**                     e_sum_op TYPE i
**                     e_sum_ap TYPE i
**                     e_sum_eap TYPE i.
**
**  DATA:
**    ls_statistik TYPE gst_statistik.
**
**  IF flg_liste EQ char_3.              "lange Ausgabeliste
**  ELSE.                                "kurze Ausgabeliste
**    IF xtol = 'X' AND i_level = '1'.                        "364207
**      e_sum_ap = e_sum_eap.                                 "364207
**      IF x_echtl NE 'X'.                                    "364207
**        CLEAR e_sum_eap.                                    "364207
**      ENDIF.                                                "364207
**    ENDIF.                                                  "364207
**    percent = ( 1000 * e_sum_ap ) / e_sum_op.
**    IF x_echtl = 'X' AND enqsubrc = 0.
**      spercent = ( 1000 * e_sum_eap ) / e_sum_op.
**    ENDIF.
**
**    CLEAR ls_statistik.
**    CASE i_level.
**      WHEN char_0.
**        ls_statistik-bukrs = char_*.
**        ls_statistik-info = 'C31'.
**      WHEN char_1.
**        ls_statistik-bukrs = i_bukrs.
**        ls_statistik-info = 'C30'.
**    ENDCASE.
**
**    ls_statistik-koart = char_*.
**    ls_statistik-konto = char_*.
**    ls_statistik-hkont = char_*.
**    ls_statistik-cnt_op = e_sum_op.
**    ls_statistik-cnt_ap = e_sum_ap.
**    ls_statistik-percent = percent.
**    ls_statistik-cnt_eap = e_sum_eap.
**    ls_statistik-spercent = spercent.
**    APPEND ls_statistik TO gt_statistik.
**  ENDIF.
**  CASE koart.
**    WHEN 'D'.
**      sumd_op = sumd_op + e_sum_op.
**      sumd_ap = sumd_ap + e_sum_ap.
**      sumd_eap = sumd_eap + e_sum_eap.
**    WHEN 'K'.
**      sumk_op = sumk_op + e_sum_op.
**      sumk_ap = sumk_ap + e_sum_ap.
**      sumk_eap = sumk_eap + e_sum_eap.
**    WHEN 'S'.
**      sums_op = sums_op + e_sum_op.
**      sums_ap = sums_ap + e_sum_ap.
**      sums_eap = sums_eap + e_sum_eap.
**  ENDCASE.
**  CLEAR e_sum_op.
**  CLEAR e_sum_ap.
**  CLEAR e_sum_eap.
**ENDFORM.                               "SUM_INFO

*---------------------------------------------------------------------*
*       FORM RECORD_FILL                                              *
*---------------------------------------------------------------------*
*       Zusatzprotokoll fuellen                                       *
*       Systemmeldungen werden immer gefüllt und ausgegeben           *
*---------------------------------------------------------------------*
*  -->  PROTOKOLL   Kennzeichnung des Protokollsatzes                 *
*  -->  KOART       Kontoart                                          *
*  -->  KONTO       Kontonummer: Debitor, Kreditor, Sachkonto         *
*  -->  HKONT       Kontonummer: Abstimmkonto                         *
*  -->  MSGID       Message ID 'S' (System), 'B' (Belege)             *
*---------------------------------------------------------------------*
**Comment
**FORM record_fill
**    USING i_txt i_bukrs i_koart i_konto i_hkont i_belnr i_buzei i_msgid.
**  CLEAR iprot.
**  iprot-bukrs = i_bukrs.
**  iprot-koart = i_koart.
**  iprot-konto = i_konto.
**  iprot-hkont = i_hkont.
**  iprot-belnr = i_belnr.
**  iprot-buzei = i_buzei.
**  iprot-msgid = i_msgid.
**
**  CASE i_txt.
**    WHEN '     '.
**      iprot-text0 = text-101.
**    WHEN 'QSSHB'.
**      x_zprt_sub = 'X'.
**      iprot-text0 = text-104.
**    WHEN 'AUGSB'.                                           "516329
**      iprot-text0 = text-133.                               "516329
**    WHEN 'AUBLA'.                                           "516329
**      iprot-text0 = text-134.                               "516329
**    WHEN 'QSSKZ'.                                           "500429
**      x_zprt_sub = 'X'.                                     "500429
**      iprot-text0 = text-105.                               "500429
**    WHEN 'BSID '.
**      iprot-text0 = text-110.
**    WHEN 'BSIK '.
**      iprot-text0 = text-111.
**    WHEN 'BSIS '.
**      iprot-text0 = text-112.
**    WHEN 'BKPF '.
**      iprot-text0 = text-113.
**      REPLACE '&1' WITH i_bukrs INTO iprot-text0.
**      REPLACE '&2' WITH i_belnr INTO iprot-text0.
**    WHEN 'BSEG '.
**      iprot-text0 = text-114.
**      REPLACE '&1' WITH i_bukrs INTO iprot-text0.
**      REPLACE '&2' WITH i_belnr INTO iprot-text0.
**      REPLACE '&3' WITH i_buzei INTO iprot-text0.
**    WHEN 'LOCK1'.
**      x_zprt_sub = 'X'.
**      iprot-text0 = text-120.          "Konto ist gesperrt
**    WHEN 'LOCK2'.
**      x_zprt_sub = 'X'.
**      iprot-text0 = text-121.          "Systemfehler beim Sperren - Prog
**    WHEN 'LOCK3'.
**      x_zprt_sub = 'X'.
**      iprot-text0 = text-122.          " Sperreintrag in Tabelle REGUS
**    WHEN 'LOCK6'.
**      x_zprt_sub = 'X'.
**      iprot-text0 = text-126.          " Sperreintrag in Tabelle T042X
**    WHEN 'RULES'.
**      x_zprt_sub = 'X'.
**      iprot-text0 = text-125.          "Keine Regeln in Tabelle TF123
**    WHEN 'SOHA '.
**      iprot-text0 = text-127.
**    WHEN 'ZUONR'.                                           "451047
**      iprot-text0 = text-132.                               "451047
**    WHEN 'NOCLEAR'.
**      iprot-text0 = text-043.
**    WHEN 'NOCLEARTOL'.
**      iprot-text0 = text-046.
**    WHEN 'ENQ'.
**      iprot-text0 = text-051.
**    WHEN 'LG'.
**      iprot-text0 = text-t03.
**    WHEN 'NOLG'.
**      iprot-text0 = text-t04.
**    WHEN OTHERS.
**      EXIT.
**  ENDCASE.
**
**  COLLECT iprot.
**
**ENDFORM.                               "RECORD_FILL
*&---------------------------------------------------------------------*
*&      Form  FEHLER_MERKEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fehler_merken.
  DATA ls_msg LIKE bdcmsgcoll.
  IF x_fehler = 'X'.
    ls_msg-msgspra = sy-langu.
    ls_msg-msgid   = sy-msgid.
    ls_msg-msgnr   = sy-msgno.
    ls_msg-msgv1   = sy-msgv1.
    ls_msg-msgv2   = sy-msgv2.
    ls_msg-msgv3   = sy-msgv3.
    ls_msg-msgv4   = sy-msgv4.
    ls_msg-msgtyp  = sy-msgty.
    x_fehl_sub = 'X'.
    PERFORM nachricht_merken USING ls_msg-msgspra ls_msg-msgid
                                   ls_msg-msgnr   ls_msg-msgv1
                                   ls_msg-msgv2   ls_msg-msgv2
                                   ls_msg-msgv4 koart ' ' ' '
                                   ls_msg-msgtyp.
  ENDIF.

ENDFORM.                               " FEHLER_MERKEN
*&---------------------------------------------------------------------*
*&      Form  NACHRICHT_MERKEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM nachricht_merken USING i_msgspra LIKE bdcmsgcoll-msgspra
                            i_msgid   LIKE bdcmsgcoll-msgid
                            i_msgnr   LIKE bdcmsgcoll-msgnr
                            i_msgv1   LIKE bdcmsgcoll-msgv1
                            i_msgv2   LIKE bdcmsgcoll-msgv2
                            i_msgv3   LIKE bdcmsgcoll-msgv3
                            i_msgv4   LIKE bdcmsgcoll-msgv4
                            i_koart   LIKE bseg-koart
                            i_dynam   LIKE bdcmsgcoll-dyname
                            i_dynum   LIKE bdcmsgcoll-dynumb
                            i_msgtp   LIKE bdcmsgcoll-msgtyp.
  SELECT SINGLE * FROM t100
         WHERE sprsl = i_msgspra
           AND arbgb = i_msgid
           AND msgnr = i_msgnr.
  IF sy-subrc NE 0.
    cha500 = text-312.
    REPLACE '&' WITH i_msgid INTO cha500.
    REPLACE '&' WITH i_msgnr INTO cha500.
    CONDENSE cha500.
    PERFORM fehlprot_fuellen USING i_koart i_dynam i_dynum i_msgtp
                                   i_msgid i_msgnr cha500.
  ENDIF.
  CLEAR cha500.
  cha500+30 = t100-text.
  REPLACE '&1'   WITH '&'   INTO cha500.
  REPLACE '&2'   WITH '&'   INTO cha500.
  REPLACE '&3'   WITH '&'   INTO cha500.
  REPLACE '&4'   WITH '&'   INTO cha500.
  REPLACE '&V1&' WITH '&'   INTO cha500.
  REPLACE '&V2&' WITH '&'   INTO cha500.
  REPLACE '&V3&' WITH '&'   INTO cha500.
  REPLACE '&V4&' WITH '&'   INTO cha500.
  REPLACE '&v1&' WITH '&'   INTO cha500.
  REPLACE '&v2&' WITH '&'   INTO cha500.
  REPLACE '&v3&' WITH '&'   INTO cha500.
  REPLACE '&v4&' WITH '&'   INTO cha500.
  REPLACE '&' WITH i_msgv1 INTO cha500.
  REPLACE '&' WITH i_msgv2 INTO cha500.
  REPLACE '&' WITH i_msgv3 INTO cha500.
  REPLACE '&' WITH i_msgv4 INTO cha500.
  CONDENSE cha500.
  PERFORM fehlprot_fuellen USING i_koart i_dynam i_dynum i_msgtp
                                 i_msgid i_msgnr cha500.

ENDFORM.                               " NACHRICHT_MERKEN
*&---------------------------------------------------------------------*
*&      Form  FEHLPROT_FUELLEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fehlprot_fuellen USING i_koart LIKE bseg-koart                 "4.7
                            i_dynam LIKE bdcmsgcoll-dyname          "4.7
                            i_dynum LIKE bdcmsgcoll-dynumb          "4.7
                            i_msgty LIKE bdcmsgcoll-msgtyp          "4.7
                            i_msgid LIKE bdcmsgcoll-msgid           "4.7
                            i_msgnr LIKE bdcmsgcoll-msgnr           "4.7
                            i_ch500.

  CLEAR fehlprot.
  CASE i_koart.
    WHEN 'D'.
      fehlprot-bukrs = ybsid-bukrs.
      fehlprot-koart = koart.
      fehlprot-hkont = ybsid-hkont.
      fehlprot-konto = ybsid-kunnr.
      fehlprot-waers = ybsid-waers.
    WHEN 'K'.
      fehlprot-bukrs = ybsik-bukrs.
      fehlprot-koart = koart.
      fehlprot-hkont = ybsik-hkont.
      fehlprot-konto = ybsik-lifnr.
      fehlprot-waers = ybsik-waers.
    WHEN 'S'.
      fehlprot-bukrs = ybsis-bukrs.
      fehlprot-koart = koart.
      fehlprot-hkont = ybsis-hkont.
      fehlprot-konto = ybsis-hkont.
      fehlprot-waers = ybsis-pswsl.
  ENDCASE.
  fehlprot-dyname = i_dynam.
  fehlprot-dynumb = i_dynum.
  fehlprot-msgtyp = i_msgty.
  fehlprot-msgid  = i_msgid.
  fehlprot-msgnr  = i_msgnr.
  fehlprot-text   = i_ch500.

  APPEND fehlprot.
ENDFORM.                               " FEHLPROT_FUELLEN
*&---------------------------------------------------------------------*
*&      Form  CHECK_BUKRS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_bukrs .

* internal fields
  DATA: bukrs LIKE bkpf-bukrs.
  DATA: index         TYPE p.

  RANGES: bukreis FOR bukrs.

  REFRESH bukreis.
  IF NOT bukrx IS INITIAL.
    LOOP AT bukrx.
      bukreis = bukrx.
      APPEND bukreis.
    ENDLOOP.
  ENDIF.

  DESCRIBE TABLE bukreis LINES index.

  IF index = 1 AND
     bukreis-sign = 'I' AND
     bukreis-option = 'EQ'.
    MOVE bukreis-low TO t001-bukrs.
    READ TABLE t001.
    IF sy-subrc NE 0.
      MESSAGE e023(fg) WITH bukreis-low.
    ELSE.
      IF bukreis-low = space.
        REFRESH bukreis.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_BUKRS
