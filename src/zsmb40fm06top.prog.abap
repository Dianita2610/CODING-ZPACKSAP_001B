*&---------------------------------------------------------------------*
*&  Include           ZSMB40FM06TOP
*&---------------------------------------------------------------------*
TYPE-POOLS:   addi, meein,
mmpur.
TABLES: nast,                          "Messages
  *nast,                         "Messages
  tnapr,                         "Programs & Forms
  itcpo,                         "Communicationarea for Spool
  arc_params,                    "Archive parameters
  toa_dara,                      "Archive parameters
  addr_key.                      "Adressnumber for ADDRESS

TYPE-POOLS szadr.
TABLES : varposr,
  rwerter,
  mtxh.

DATA  umbruch TYPE I VALUE 4.
DATA  headerflag.
DATA  BEGIN OF vartab OCCURS 15.
  INCLUDE STRUCTURE varposr.
DATA  END   OF vartab.
DATA  tabn TYPE I.
DATA  taba TYPE I.
DATA  ebelph LIKE ekpo-ebelp.
DATA  bis TYPE I.
DATA  xmax TYPE I.
DATA  tab LIKE varposr-yzeile.
DATA  diff TYPE I.
DATA  ldat_sam LIKE eket-eindt.

DATA: s, v TYPE I.
DATA: sampr LIKE pekpov-netpr, varpr LIKE pekpov-netpr.

* Struktur zur Variantenbildung

DATA: BEGIN OF wertetab OCCURS 30.
  INCLUDE STRUCTURE rwerter.
  DATA: atzhl LIKE econf_out-atzhl,
END OF wertetab.

* Interne Tabelle fuer Konditionen
DATA: BEGIN OF kond OCCURS 30.
  INCLUDE STRUCTURE komvd.
DATA: END OF kond.
* Hilfsfelder
DATA:
      merknamex(15) TYPE C,            "Merkmalname x-Achse
      merknamey(15) TYPE C,            "Merkmalname y-Achse
      merknrx LIKE rwerter-nr,         "Int. Merkmal x-Achse
      merknry LIKE rwerter-nr,         "Int. Merkmal y-Achse
      I TYPE I VALUE 1,
      nr LIKE cawn-atinn.
DATA: inserterror(1),SUM TYPE I,menge TYPE I,gsumh TYPE I, xmaxh TYPE I.
DATA: gsumv TYPE I.
* Matrixflag
DATA: m_flag VALUE 'x'.

*- Tabellen -----------------------------------------------------------*
TABLES: cpkme,
  ekvkp,
  ekko,
  pekko,
  rm06p,
  ekpo,
  pekpo,
  pekpov,
  pekpos,
  eket,
  ekek,
  ekes,
  ekeh,
  ekkn,
  ekpa,
  ekbe,
  eine, *eine,
  lfa1,
  likp,
  *lfa1,
  kna1,
  komk,
  komp,
  komvd,
  ekomd,
  econf_out,
  thead, *thead,
  sadr,
  mdpa,
  mdpm,
  mkpf,
  tinct,
  ttxit,
  tmsi2,
  tq05,
  tq05t,
  t001,
  t001w,
  t006, *t006,
  t006a, *t006a,
  t024,
  t024e,
  t027a,
  t027b,
  t052,
  t161n,
  t163d,
  t166a,
  t165p,
  t166c,
  t166k,
  t166p,
  t166t,
  t166u,
  t165m,
  t165a,
  tmamt,
  *mara,                                               "HTN 4.0C
  mara,
  marc,
  mt06e,
  makt,
  vbak,
  vbkd,
  *vbkd,
  vbap.
TABLES: drad,
  drat.
TABLES: addr1_sel,
  addr1_val.
TABLES: v_htnm, rampl,tmppf.           "HTN-Abwicklung

TABLES: stxh.              "schnellerer Zugriff auf Texte Dienstleistung

TABLES: t161.              "Abgebotskennzeichen für Dienstleistung

*- INTERNE TABELLEN ---------------------------------------------------*
*- Tabelle der Positionen ---------------------------------------------*
DATA: BEGIN OF xekpo OCCURS 10.
  INCLUDE STRUCTURE ekpo.
  DATA:     bsmng LIKE ekes-menge,
END OF xekpo.

*- Key für xekpo ------------------------------------------------------*
DATA: BEGIN OF xekpokey,
  mandt LIKE ekpo-mandt,
  ebeln LIKE ekpo-ebeln,
  ebelp LIKE ekpo-ebelp,
END OF xekpokey.

*- Tabelle der Einteilungen -------------------------------------------*
DATA: BEGIN OF xeket OCCURS 10.
  INCLUDE STRUCTURE eket.
  DATA:     fzete LIKE pekpo-wemng,
END OF xeket.

*- Tabelle der Einteilungen temporär ----------------------------------*
DATA: BEGIN OF teket OCCURS 10.
  INCLUDE STRUCTURE beket.
DATA: END OF teket.

DATA: BEGIN OF zeket.
  INCLUDE STRUCTURE eket.
DATA:  END OF zeket.

*- Tabelle der Positionszusatzdaten -----------------------------------*
DATA: BEGIN OF xpekpo OCCURS 10.
  INCLUDE STRUCTURE pekpo.
DATA: END OF xpekpo.

*- Tabelle der Positionszusatzdaten -----------------------------------*
DATA: BEGIN OF xpekpov OCCURS 10.
  INCLUDE STRUCTURE pekpov.
DATA: END OF xpekpov.

*- Tabelle der Zahlungbedingungen--------------------------------------*
DATA: BEGIN OF zbtxt OCCURS 5,
  LINE(50),
END OF zbtxt.

*- Tabelle der Merkmalsausprägungen -----------------------------------*
DATA: BEGIN OF tconf_out OCCURS 50.
  INCLUDE STRUCTURE econf_out.
DATA: END OF tconf_out.

*- Tabelle der Konditionen --------------------------------------------*
DATA: BEGIN OF tkomv OCCURS 50.
  INCLUDE STRUCTURE komv.
DATA: END OF tkomv.

DATA: BEGIN OF tkomk OCCURS 1.
  INCLUDE STRUCTURE komk.
DATA: END OF tkomk.

DATA: BEGIN OF tkomvd OCCURS 50.       "Belegkonditionen
  INCLUDE STRUCTURE komvd.
DATA: END OF tkomvd.

DATA: BEGIN OF tekomd OCCURS 50.       "Stammkonditionen
  INCLUDE STRUCTURE ekomd.
DATA: END OF tekomd.

*- Tabelle der Bestellentwicklung -------------------------------------*
DATA: BEGIN OF xekbe OCCURS 10.
  INCLUDE STRUCTURE ekbe.
DATA: END OF xekbe.

*- Tabelle der Bezugsnebenkosten --------------------------------------*
DATA: BEGIN OF xekbz OCCURS 10.
  INCLUDE STRUCTURE ekbz.
DATA: END OF xekbz.

*- Tabelle der WE/RE-Zuordnung ----------------------------------------*
DATA: BEGIN OF xekbez OCCURS 10.
  INCLUDE STRUCTURE ekbez.
DATA: END OF xekbez.

*- Tabelle der Positionssummen der Bestellentwicklung -----------------*
DATA: BEGIN OF tekbes OCCURS 10.
  INCLUDE STRUCTURE ekbes.
DATA: END OF tekbes.

*- Tabelle der Bezugsnebenkosten der Bestandsführung ------------------*
DATA: BEGIN OF xekbnk OCCURS 10.
  INCLUDE STRUCTURE ekbnk.
DATA: END OF xekbnk.

*- Tabelle für Kopieren Positionstexte (hier wegen Infobestelltext) ---*
DATA: BEGIN OF xt165p OCCURS 10.
  INCLUDE STRUCTURE t165p.
DATA: END OF xt165p.

*- Tabelle der Kopftexte ----------------------------------------------*
DATA: BEGIN OF xt166k OCCURS 10.
  INCLUDE STRUCTURE t166k.
DATA: END OF xt166k.

*- Tabelle der Positionstexte -----------------------------------------*
DATA: BEGIN OF xt166p OCCURS 10.
  INCLUDE STRUCTURE t166p.
DATA: END OF xt166p.

*- Tabelle der Anahngstexte -------------------------------------------*
DATA: BEGIN OF xt166a OCCURS 10.
  INCLUDE STRUCTURE t166a.
DATA: END OF xt166a.

*- Tabelle der Textheader ---------------------------------------------*
DATA: BEGIN OF xthead OCCURS 10.
  INCLUDE STRUCTURE thead.
DATA: END OF xthead.

DATA: BEGIN OF xtheadkey,
  tdobject LIKE thead-tdobject,
  tdname LIKE thead-tdname,
  tdid LIKE thead-tdid,
END OF xtheadkey.

DATA: BEGIN OF qm_text_key OCCURS 5,
  tdobject LIKE thead-tdobject,
  tdname LIKE thead-tdname,
  tdid LIKE thead-tdid,
  tdtext LIKE ttxit-tdtext,
END OF qm_text_key.

*- Tabelle der Nachrichten alt/neu ------------------------------------*
DATA: BEGIN OF xnast OCCURS 10.
  INCLUDE STRUCTURE nast.
DATA: END OF xnast.

DATA: BEGIN OF ynast OCCURS 10.
  INCLUDE STRUCTURE nast.
DATA: END OF ynast.

*------ Struktur zur Übergabe der Adressdaten --------------------------
DATA:    BEGIN OF addr_fields.
  INCLUDE STRUCTURE sadrfields.
DATA:    END OF addr_fields.

*------ Struktur zur Übergabe der Adressreferenz -----------------------
DATA:    BEGIN OF addr_reference.
  INCLUDE STRUCTURE addr_ref.
DATA:    END OF addr_reference.

*------ Tabelle zur Übergabe der Fehler -------------------------------
DATA:    BEGIN OF error_table OCCURS 10.
  INCLUDE STRUCTURE addr_error.
DATA:    END OF error_table.

*------ Tabelle zur Übergabe der Adressgruppen ------------------------
DATA:    BEGIN OF addr_groups OCCURS 3.
  INCLUDE STRUCTURE adagroups.
DATA:    END OF addr_groups.

*- Tabelle der Aenderungsbescheibungen --------------------------------*
DATA: BEGIN OF xaend OCCURS 10,
  ebelp LIKE ekpo-ebelp,
  zekkn LIKE ekkn-zekkn,
  etenr LIKE eket-etenr,
  ctxnr LIKE t166c-ctxnr,
  rounr LIKE t166c-rounr,
  INSERT,
  flag_adrnr,
END OF xaend.

DATA: BEGIN OF xaendkey,
  ebelp LIKE ekpo-ebelp,
  zekkn LIKE ekkn-zekkn,
  etenr LIKE eket-etenr,
  ctxnr LIKE t166c-ctxnr,
  rounr LIKE t166c-rounr,
  INSERT,
  flag_adrnr,
END OF xaendkey.

*- Tabelle der Textänderungen -----------------------------------------*
DATA: BEGIN OF xaetx OCCURS 10,
  ebelp LIKE ekpo-ebelp,
  textart LIKE cdshw-textart,
  chngind LIKE cdshw-chngind,
END OF xaetx.

*- Tabelle der geänderten Adressen ------------------------------------*
DATA: BEGIN OF xadrnr OCCURS 5,
  adrnr LIKE sadr-adrnr,
  tname LIKE cdshw-tabname,
  fname LIKE cdshw-fname,
END OF xadrnr.

*- Tabelle der gerade bearbeiteten aktive Komponenten -----------------*
DATA BEGIN OF mdpmx OCCURS 10.
  INCLUDE STRUCTURE mdpm.
DATA END OF mdpmx.

*- Tabelle der gerade bearbeiteten Sekundärbedarfe --------------------*
DATA BEGIN OF mdsbx OCCURS 10.
  INCLUDE STRUCTURE mdsb.
DATA END OF mdsbx.

*- Struktur des Archivobjekts -----------------------------------------*
DATA: BEGIN OF xobjid,
  objky  LIKE nast-objky,
  arcnr  LIKE nast-optarcnr,
END OF xobjid.

* Struktur für zugehörigen Sammelartikel
DATA: BEGIN OF sekpo.
  INCLUDE STRUCTURE ekpo.
  DATA:   first_varpos,
END OF sekpo.

*- Struktur für Ausgabeergebnis zB Spoolauftragsnummer ----------------*
DATA: BEGIN OF result.
  INCLUDE STRUCTURE itcpp.
DATA: END OF result.

*- Struktur für Internet NAST -----------------------------------------*
DATA: BEGIN OF intnast.
  INCLUDE STRUCTURE snast.
DATA: END OF intnast.

*- HTN-Abwicklung
DATA: BEGIN OF htnmat OCCURS 0.
  INCLUDE STRUCTURE v_htnm.
  DATA:  revlv LIKE rampl-revlv,
END OF htnmat.

DATA  htnamp LIKE rampl  OCCURS 0 WITH HEADER LINE.

*- Hilfsfelder --------------------------------------------------------*
DATA: hadrnr(8),                       "Key TSADR
      elementn(30),                    "Name des Elements
      save_el(30),                     "Rettfeld für Element
      retco LIKE sy-subrc,             "Returncode Druck
      INSERT,                          "Kz. neue Position
      h-ind LIKE sy-tabix,             "Hilfsfeld Index
      h-ind1 LIKE sy-tabix,            "Hilfsfeld Index
      f1 TYPE f,                       "Rechenfeld
      h-menge LIKE ekpo-menge,         "Hilfsfeld Mengenumrechnung
      h-meng1 LIKE ekpo-menge,         "Hilfsfeld Mengenumrechnung
      h-meng2 LIKE ekpo-menge,         "Hilfsfeld Mengenumrechnung
      ab-menge LIKE ekes-menge,        "Hilfsfeld bestätigte Menge
      kzbzg LIKE konp-kzbzg,           "Staffeln vorhanden?
      hdatum LIKE eket-eindt,          "Hilfsfeld Datum
      hmahnz LIKE ekpo-mahnz,          "Hilfsfeld Mahnung
      addressnum LIKE ekpo-adrn2,      "Hilfsfeld Adressnummer
      tablines LIKE sy-tabix,          "Zähler Tabelleneinträge
      entries  LIKE sy-tfill,          "Zähler Tabelleneinträge
      hstap,                           "statistische Position
      hsamm,                           "Positionen mit Sammelartikel
      hloep,                           "Gelöschte Positionen im Spiel
      hkpos,                           "Kondition zu löschen
      kopfkond,                        "Kopfkonditionen vorhanden
      no_zero_line,                    "keine Nullzeilen
      xdrflg LIKE t166p-drflg,         "Hilfsfeld Textdruck
      xprotect,                        "Kz. protect erfolgt
      archiv_object LIKE toa_dara-ar_object, "für opt. Archivierung
      textflag,                        "Kz. druckrel. Positionstexte
      flag,                            "allgemeines Kennzeichen
      spoolid(10),                     "Spoolidnummer
      xprogram LIKE sy-repid,          "Programm
      lvs_recipient LIKE swotobjid,    "Internet
      lvs_sender LIKE swotobjid,       "Internet
      timeflag,                        "Kz. Uhrzeit bei mind. 1 Eint.
      h_vbeln LIKE vbak-vbeln,
      h_vbelp LIKE vbap-posnr.

*- Drucksteuerung -----------------------------------------------------*
DATA: aendernsrv.
DATA: xdruvo.                          "Druckvorgang
DATA: neu  VALUE '1',                  "Neudruck
      aend VALUE '2',                  "Änderungsdruck
      mahn VALUE '3',                  "Mahnung
      absa VALUE '4',                  "Absage
      lpet VALUE '5',                  "Lieferplaneinteilung
      lpma VALUE '6',                  "Mahnung Lieferplaneinteilung
      aufb VALUE '7',                  "Auftragsbestätigung
      lpae VALUE '8',                  "Änderung Lieferplaneinteilung
      lphe VALUE '9',                  "Historisierte Einteilungen
      preisdruck,                      "Kz. Gesamtpreis drucken
      kontrakt_preis,                  "Kz. Kontraktpreise drucken
      we   VALUE 'E'.                  "Wareneingangswert

*- Hilfsfelder Lieferplaneinteilung -----------------------------------*
DATA:
      xlpet,                           "Lieferplaneinteilung
      xfz,                             "Fortschrittszahlendarstellung
      xoffen,                          "offene WE-Menge
      xlmahn,                          "Lieferplaneinteilungsmahnung
      fzflag,                          "KZ. Abstimmdatum erreicht
      xnoaend,                         "keine Änderungsbelege da  LPET
      xetdrk,                        "Druckrelevante Positionen da LPET
      xetefz LIKE eket-menge,          "Einteilungsfortschrittszahl
      xwemfz LIKE eket-menge,          "Lieferfortschrittszahl
      xabruf LIKE ekek-abruf,          "Alter Abruf
      p_abart LIKE ekek-abart.         "Abrufart

*data: sum-euro-price like komk-fkwrt.                       "302203
DATA: SUM-euro-price LIKE komk-fkwrt_euro.                  "302203
DATA: euro-price LIKE ekpo-effwr.

*- Hilfsfelder für Ausgabemedium --------------------------------------*
DATA: xdialog,                         "Kz. POP-UP
      xscreen,                         "Kz. Probeausgabe
      xformular LIKE tnapr-fonam,      "Formular
      xdevice(10).                     "Ausgabemedium

*- Hilfsfelder für QM -------------------------------------------------*
DATA: qv_text_i LIKE tq09t-kurztext,   "Bezeichnung Qualitätsvereinb.
      tl_text_i LIKE tq09t-kurztext,   "Bezeichnung Technische Lieferb.
      zg_kz.                           "Zeugnis erforderlich

*- Hilfsfelder für Änderungsbeleg -------------------------------------*
DATA: objectid              LIKE cdhdr-objectid,
      tcode                 LIKE cdhdr-tcode,
      planned_change_number LIKE cdhdr-planchngnr,
      utime                 LIKE cdhdr-utime,
      udate                 LIKE cdhdr-udate,
      username              LIKE cdhdr-username,
      cdoc_planned_or_real  LIKE cdhdr-change_ind,
      cdoc_upd_object       LIKE cdhdr-change_ind VALUE 'U',
      cdoc_no_change_pointers LIKE cdhdr-change_ind.


*- Common-Part für Änderungsbeleg -------------------------------------*
*include zzfm06lccd.
DATA:    BEGIN OF COMMON PART fm06lccd.

*------- Tabelle der Änderunsbelegzeilen (temporär) -------------------*
  DATA: BEGIN OF EDIT OCCURS 50.             "Änderungsbelegzeilen temp.
    INCLUDE STRUCTURE cdshw.
  DATA: END OF EDIT.

  DATA: BEGIN OF editd OCCURS 50.             "Änderungsbelegzeilen temp.
    INCLUDE STRUCTURE cdshw.            "für Dienstleistungen
  DATA: END OF editd.


*------- Tabelle der Änderunsbelegzeilen (Ausgabeform) ----------------*
  DATA: BEGIN OF ausg OCCURS 50.             "Änderungsbelegzeilen
    INCLUDE STRUCTURE cdshw.
    DATA:   changenr LIKE cdhdr-changenr,
          udate    LIKE cdhdr-udate,
          utime    LIKE cdhdr-utime,
  END OF ausg.

*------- Tabelle der Änderunsbelegköpfe -------------------------------*
  DATA: BEGIN OF icdhdr OCCURS 50.           "Änderungbelegköpfe
    INCLUDE STRUCTURE cdhdr.
  DATA: END OF icdhdr.

*------- Key Tabelle der Änderunsbelegköpfe --------------------------*
  DATA: BEGIN OF hkey,                       "Key für ICDHDR
    mandt LIKE cdhdr-mandant,
    objcl LIKE cdhdr-objectclas,
    objid LIKE cdhdr-objectid,
    chang LIKE cdhdr-changenr,
  END OF hkey.

*------- Key der geänderten Tabelle für Ausgabe ----------------------*
  DATA: BEGIN OF ekkey,                    "Tabellenkeyausgabe
    ebeln LIKE ekko-ebeln,
    ebelp LIKE ekpo-ebelp,
    zekkn LIKE ekkn-zekkn,
    etenr LIKE eket-etenr,
    abruf LIKE ekek-abruf,
    ekorg LIKE ekpa-ekorg,           "Änderungsbelege Partner
    ltsnr LIKE ekpa-ltsnr,           "Änderungsbelege Partner
    werks LIKE ekpa-werks,           "Änderungsbelege Partner
    parvw LIKE ekpa-parvw,           "Änderungsbelege Partner
    parza LIKE ekpa-parza,           "Änderungsbelege Partner
    consnumber LIKE adr2-consnumber, "Änderungsbelege Adressen
    comm_type  LIKE adrt-comm_type,  "Änderungsbelege Adressen
  END OF ekkey.

DATA:    END OF COMMON PART.
*- Direktwerte --------------------------------------------------------*
************************************************************************
*          Direktwerte                                                 *
************************************************************************
*------- Werte zu Trtyp und Aktyp:
CONSTANTS:  hin VALUE 'H',             "Hinzufuegen
ver VALUE 'V',             "Veraendern
anz VALUE 'A',             "Anzeigen
erw VALUE 'E'.             "Bestellerweiterung

CONSTANTS:
* BSTYP
bstyp-info VALUE 'I',
bstyp-ordr VALUE 'W',
bstyp-banf VALUE 'B',
bstyp-best VALUE 'F',
bstyp-anfr VALUE 'A',
bstyp-kont VALUE 'K',
bstyp-lfpl VALUE 'L',
bstyp-lerf VALUE 'Q',

* BSAKZ
bsakz-norm VALUE ' ',
bsakz-tran VALUE 'T',
bsakz-rahm VALUE 'R',
* BSAKZ-BEIS VALUE 'B',  "not used
* BSAKZ-KONS VALUE 'K',  "not used
* BSAKZ-LOHN VALUE 'L', "not used
* BSAKZ-STRE VALUE 'S', "not used
* BSAKZ-MENG VALUE 'M', "not used
* BSAKZ-WERT VALUE 'W', "not used
* PSTYP
pstyp-lagm VALUE '0',
pstyp-blnk VALUE '1',
pstyp-kons VALUE '2',
pstyp-lohn VALUE '3',
pstyp-munb VALUE '4',
pstyp-stre VALUE '5',
pstyp-TEXT VALUE '6',
pstyp-umlg VALUE '7',
pstyp-wagr VALUE '8',
pstyp-dien VALUE '9',

* Kzvbr
kzvbr-anla VALUE 'A',
kzvbr-unbe VALUE 'U',
kzvbr-verb VALUE 'V',
kzvbr-einz VALUE 'E',
kzvbr-proj VALUE 'P',

* ESOKZ
esokz-pipe VALUE 'P',
esokz-lohn VALUE '3',
esokz-konsi VALUE '2',               "konsi
esokz-charg VALUE '1',               "sc-jp
esokz-norm VALUE '0'.

CONSTANTS:
* Handling von Unterpositionsdaten
sihan-nix  VALUE ' ',           "keine eigenen Daten
sihan-anz  VALUE '1', "Daten aus Hauptposition kopiert, nicht änd
sihan-kop  VALUE '2', "Daten aus Hauptposition kopiert, aber ände
sihan-eig  VALUE '3'. "eigene Daten (nicht aus Hauptposition kopi

* Unterpositionstypen
CONSTANTS:
uptyp-hpo VALUE ' ',                 "Hauptposition
uptyp-var VALUE '1',                 "Variante
uptyp-nri VALUE '2',           "Naturalrabatt Inklusive (=Dreingabe)
uptyp-ler VALUE '3',                 "Leergut
uptyp-nre VALUE '4',           "Naturalrabatt Exklusive (=Draufgabe)
uptyp-lot VALUE '5',                 "Lot Position
uptyp-dis VALUE '6',                 "Display Position
uptyp-vks VALUE '7',                 "VK-Set Position
uptyp-mpn VALUE '8',                 "Austauschposition (A&D)
uptyp-sls VALUE '9',           "Vorkommisionierungsposition (retail)
uptyp-DIV VALUE 'X'.           "HP hat UP's mit verschiedenen Typen

* Artikeltypen
CONSTANTS:
attyp-sam(2) VALUE '01',             "Sammelartikel
attyp-var(2) VALUE '02',             "Variante
attyp-we1(2) VALUE '20',             "Wertartikel
attyp-we2(2) VALUE '21',             "Wertartikel
attyp-we3(2) VALUE '22',             "Wertartikel
attyp-vks(2) VALUE '10',             "VK-Set
attyp-lot(2) VALUE '11',             "Lot-Artikel
attyp-dis(2) VALUE '12'.             "Display

* Konfigurationsherkunft
CONSTANTS:
kzkfg-fre VALUE ' ',                 "Konfiguration sonst woher
kzkfg-kan VALUE '1',                 "noch nicht konfiguriert
kzkfg-eig VALUE '2'.                 "Eigene Konfiguration

CONSTANTS:
c_ja   TYPE C VALUE 'X',
c_nein TYPE C VALUE ' '.

* Vorgangsart, welche Anwendung den Fkt-Baustein aufruft
CONSTANTS:
cva_ab(1) VALUE 'B',     "Automatische bestellung (aus banfen)
cva_we(1) VALUE 'C',                 "Wareneingang
cva_bu(1) VALUE 'D',     "Übernahme bestellungen aus fremdsystem
cva_au(1) VALUE 'E',                 "Aufteiler
cva_kb(1) VALUE 'F',                 "Kanban
cva_fa(1) VALUE 'G',                 "Filialauftrag
cva_dr(1) VALUE 'H',                                      "DRP
cva_en(1) VALUE '9',                 "Enjoy
cva_ap(1) VALUE '1',                                      "APO
cva_ed(1) VALUE 'T'.     "EDI-Eingang Auftragsbestätigung Update Preis

* Status des Einkaufsbeleges (EKKO-STATU)
CONSTANTS:
cks_ag(1) VALUE 'A',                 "Angebot vorhanden für Anfrage
cks_ab(1) VALUE 'B',     "Automatische Bestellung (aus Banfen) ME59
cks_we(1) VALUE 'C',                 "Bestellung aus Wareneingang
cks_bu(1) VALUE 'D',                 "Bestellung aus Datenübernahme
cks_au(1) VALUE 'E',     "Bestellung aus Aufteiler (IS-Retail)
cks_kb(1) VALUE 'F',                 "Bestellung aus Kanban
cks_fa(1) VALUE 'G',     "Bestellung aus Filialauftrag (IS-Retail)
cks_dr(1) VALUE 'H',                 "Bestellung aus DRP
cks_ba(1) VALUE 'I',                 "Bestellung aus BAPI
cks_al(1) VALUE 'J',                 "Bestellung aus ALE-Szenario
cks_sb(1) VALUE 'S',                 "Sammelbestellung (IS-Retail)
cks_ap(1) VALUE '1',                                      "APO
cks_en(1) VALUE '9',                 "Enjoy Bestellung
cks_fb(1) VALUE 'X'.                 "Bestellung aus Funktionsbaustein

* Vorgang aus T160
CONSTANTS:
vorga-angb(2) VALUE 'AG',   "Angebot zur Anfrage    ME47, ME48
vorga-lpet(2) VALUE 'LE',   "Lieferplaneinteilung   ME38, ME39
vorga-frge(2) VALUE 'EF',   "Einkaufsbelegfreigabe  ME28, ME35, ME45
vorga-frgb(2) VALUE 'BF',   "Banffreigabe           ME54, ME55
vorga-bgen(2) VALUE 'BB',            "Best. Lief.unbekannt   ME25
vorga-anha(2) VALUE 'FT',   "Textanhang             ME24, ME26,...
vorga-banf(2) VALUE 'B ',   "Banf                   ME51, ME52, ME53
vorga-anfr(2) VALUE 'A ',   "Anfrage                ME41, ME42, ME43
vorga-best(2) VALUE 'F ',   "Bestellung             ME21, ME22, ME23
vorga-kont(2) VALUE 'K ',   "Kontrakt               ME31, ME32, ME33
vorga-lfpl(2) VALUE 'L ',   "Lieferplan             ME31, ME32, ME33
vorga-mahn(2) VALUE 'MA',            "Liefermahnung          ME91
vorga-aufb(2) VALUE 'AB'.            "Bestätigungsmahnung    ME92

* Felder für Feldauswahl (früher FMMEXCOM)
DATA:       endmaske(210) TYPE C,
      kmaske(140) TYPE C,
      auswahl0 TYPE brefn,
      auswahl1 TYPE brefn,
      auswahl2 TYPE brefn,
      auswahl3 TYPE brefn,
      auswahl4 TYPE brefn,
      auswahl5 TYPE brefn,
      auswahl6 TYPE brefn.

* Sonderbestandskennzeichen
CONSTANTS:
sobkz-kdein VALUE 'E',               "Kundeneinzel
sobkz-prein VALUE 'Q',               "Projekteinzel
sobkz-lohnb VALUE 'O'.               "Lohnbearbeiterbeistell

* Min-/Maxwerte für Datenelemente
CONSTANTS:
* offener Rechnungseingangswert / Feldlänge: 13 / Dezimalstellen: 2
c_max_orewr       LIKE rm06a-orewr   VALUE '99999999999.99',
c_max_orewr_f     TYPE f             VALUE '99999999999.99',
c_max_orewr_x(15) TYPE C             VALUE '**************',

c_max_proz_p(3)   TYPE p DECIMALS 2  VALUE '999.99',      "@80545
c_max_proz_x(6)   TYPE C             VALUE '******',      "@80545

c_max_menge       LIKE ekpo-menge  VALUE '9999999999.999', "@83886
c_max_menge_f     TYPE f           VALUE '9999999999.999', "@83886

c_max_netwr       LIKE ekpo-netwr  VALUE '99999999999.99', "@83886
c_max_netwr_f     TYPE f           VALUE '99999999999.99'. "@83886


* Distribution Indicator Account assignment
CONSTANTS:
c_dist_ind-SINGLE   VALUE ' ',       "no multiple = single
c_dist_ind-quantity VALUE '1',       "quantity distribution
c_dist_ind-percent  VALUE '2'.       "percentag

* Datendefinitionen für Dienstleistungen
TABLES: eslh,
  esll,
  ml_esll,
  rm11p.

DATA  BEGIN OF gliederung OCCURS 50.
  INCLUDE STRUCTURE ml_esll.
DATA  END   OF gliederung.

DATA  BEGIN OF leistung OCCURS 50.
  INCLUDE STRUCTURE ml_esll.
DATA  END   OF leistung.

DATA  RETURN.

*- interne Tabelle für Abrufköpfe -------------------------------------*
DATA: BEGIN OF xekek          OCCURS 20.
  INCLUDE STRUCTURE iekek.
DATA: END OF xekek.

*- interne Tabelle für Abrufköpfe alt----------------------------------*
DATA: BEGIN OF pekek          OCCURS 20.
  INCLUDE STRUCTURE iekek.
DATA: END OF pekek.

*- interne Tabelle für Abrufeinteilungen ------------------------------*
DATA: BEGIN OF xekeh          OCCURS 20.
  INCLUDE STRUCTURE iekeh.
DATA: END OF xekeh.

*- interne Tabelle für Abrufeinteilungen ------------------------------*
DATA: BEGIN OF tekeh          OCCURS 20.
  INCLUDE STRUCTURE iekeh.
DATA: END OF tekeh.

*- Zusatztabelle Abruf nicht vorhanden XEKPO---------------------------*
DATA: BEGIN OF xekpoabr OCCURS 20,
  mandt LIKE ekpo-mandt,
  ebeln LIKE ekpo-ebeln,
  ebelp LIKE ekpo-ebelp,
END OF xekpoabr.

*-- Daten Hinweis 39234 -----------------------------------------------*
*- Hilfstabelle Einteilungen ------------------------------------------*
DATA: BEGIN OF heket OCCURS 10.
  INCLUDE STRUCTURE eket.
  DATA:       tflag LIKE sy-calld,
END OF heket.

*- Key für HEKET ------------------------------------------------------*
DATA: BEGIN OF heketkey,
  mandt LIKE eket-mandt,
  ebeln LIKE eket-ebeln,
  ebelp LIKE eket-ebelp,
  etenr LIKE eket-etenr,
END OF heketkey.

DATA: h_subrc LIKE sy-subrc,
      h_tabix LIKE sy-tabix,
      h_field LIKE cdshw-f_old,
      h_eindt LIKE rvdat-extdatum.
DATA  Z TYPE I.

* Defintionen für Formeln

TYPE-POOLS msfo.

DATA: variablen TYPE msfo_tab_variablen WITH HEADER LINE.

DATA: formel TYPE msfo_formel.

* Definition für Rechnungsplan

DATA: tfpltdr LIKE fpltdr OCCURS 0 WITH HEADER LINE.

DATA: fpltdr LIKE fpltdr.

* Definiton Defaultschema für Dienstleistung

CONSTANTS: default_kalsm LIKE t683-kalsm VALUE 'MS0000',
default_kalsm_stamm LIKE t683-kalsm VALUE 'MS0001'.

DATA: bstyp LIKE ekko-bstyp,
      bsart LIKE ekko-bsart.


DATA dkomk LIKE komk.

* Defintion für Wartungsplan
TABLES: rmipm.

DATA: mpos_tab LIKE mpos OCCURS 0 WITH HEADER LINE,
      zykl_tab LIKE mmpt OCCURS 0 WITH HEADER LINE.

DATA: print_schedule.

DATA: BEGIN OF d_tkomvd OCCURS 50.
  INCLUDE STRUCTURE komvd.
DATA: END OF d_tkomvd.
DATA: BEGIN OF d_tkomv OCCURS 50.
  INCLUDE STRUCTURE komv.
DATA: END OF d_tkomv.


* Definition Drucktabellen blockweises Lesen

DATA: leistung_thead LIKE stxh OCCURS 1 WITH HEADER LINE.
DATA: gliederung_thead LIKE stxh OCCURS 1 WITH HEADER LINE. "HS

DATA: BEGIN OF thead_key,
  mandt    LIKE sy-mandt,
  tdobject LIKE stxh-tdobject,
  tdname   LIKE stxh-tdname,
  tdid     LIKE stxh-tdid,
  tdspras  LIKE stxh-tdspras.
DATA: END OF thead_key.

RANGES: r1_tdname FOR stxh-tdname,
r2_tdname FOR stxh-tdname.

DATA: BEGIN OF doktab OCCURS 0.
  INCLUDE STRUCTURE drad.
  DATA  dktxt LIKE drat-dktxt.
DATA: END OF doktab.

*  Additionals Tabelle (CvB/4.0c)
DATA: l_addis_in_orders TYPE LINE OF addi_buying_print_itab
      OCCURS 0 WITH HEADER LINE.
*  Die Additionals-Strukturen müssen bekannt sein
TABLES: wtad_buying_print_addi, wtad_buying_print_extra_text.

DATA: ls_print_data_to_read TYPE lbbil_print_data_to_read.
DATA: ls_bil_invoice TYPE lbbil_invoice.
DATA: lf_fm_name            TYPE rs38l_fnam.
DATA: ls_control_param      TYPE ssfctrlop.
DATA: ls_composer_param     TYPE ssfcompop.
DATA: ls_recipient          TYPE swotobjid.
DATA: ls_sender             TYPE swotobjid.
DATA: lf_formname           TYPE tdsfname.
DATA: ls_addr_key           LIKE addr_key,
      dunwitheket           TYPE xfeld.

DATA: l_zekko                  LIKE ekko,
      l_xpekko                 LIKE pekko,
      l_xekpo                LIKE TABLE OF ekpo,
      l_wa_xekpo             LIKE ekpo.

DATA: l_xekpa LIKE ekpa OCCURS 0,
      l_wa_xekpa LIKE ekpa.
DATA: l_xpekpo  LIKE pekpo OCCURS 0,
      l_wa_xpekpo LIKE pekpo,
      l_xeket   LIKE TABLE OF eket WITH HEADER LINE,
      l_xekkn  LIKE TABLE OF ekkn WITH HEADER LINE,
      l_xekek  LIKE TABLE OF ekek WITH HEADER LINE,
      l_xekeh   LIKE TABLE OF ekeh WITH HEADER LINE,
      l_xkomk LIKE TABLE OF komk WITH HEADER LINE,
      l_xtkomv  TYPE komv OCCURS 0,
      l_wa_xtkomv TYPE komv.

DATA   ls_ssfcompop  TYPE     ssfcompop.
