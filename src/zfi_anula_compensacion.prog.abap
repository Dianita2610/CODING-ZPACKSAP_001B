*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&============================================================*
*& Report  ZFI_ANULA_COMPENSACION                             *
*&============================================================*
*& Descripción: Batch input anulación compensación FBRA       *
*&                                                            *
*&                                                            *
*&     Fecha Creacion  = 05.03.2012                           *
*&     Creador         = Julio Sosa                           *
*&     Empresa         = Visionone                            *
*&                                                            *
*&============================================================*
*& Histórico de modificaciones                                *
*&============================================================*
*&                                                            *
*& Autor:                                                     *
*& Fecha:                                                     *
*& Descripción la Modificación:                               *
*&============================================================*

REPORT  ZFI_ANULA_COMPENSACION LINE-SIZE 1023.

INCLUDE BDCRECXY.

PARAMETERS: P_FILE TYPE RLGRAP-FILENAME OBLIGATORY DEFAULT 'C:\'.

DATA: BEGIN OF RECORD OCCURS 0,
        BELNR(10),
        BUKRS(4),
        GJAHR(4),
      END OF RECORD,
      L_MSTRING(480),
      gs_params  LIKE ctu_params,
      gt_messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE,
      GD_FILE    TYPE STRING,
      GT_INTERN  TYPE KCDE_CELLS OCCURS 0 WITH HEADER LINE,
      GD_ERROR,
      GD_FECHA(10),
      GD_BSTAT TYPE BKPF-BSTAT.

TABLES T100.

*** End generated data section ***

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  CALL FUNCTION 'GUI_FILE_LOAD_DIALOG'
    EXPORTING
      WINDOW_TITLE            = 'Seleccionar archivo'
      DEFAULT_EXTENSION       = 'XLS'
      INITIAL_DIRECTORY       = 'C:\'
    IMPORTING
      FULLPATH                = GD_FILE.

  P_FILE = GD_FILE.


START-OF-SELECTION.

  AUTHORITY-CHECK OBJECT 'S_TABU_DIS'
           ID 'DICBERCLS' FIELD 'ZFI1'
           ID 'ACTVT'     FIELD '*'.

  CALL FUNCTION 'KCD_EXCEL_OLE_TO_INT_CONVERT'
    EXPORTING
      filename                      = P_FILE
      i_begin_col                   = 1
      i_begin_row                   = 2
      i_end_col                     = 3
      i_end_row                     = 65535
    tables
      intern                        = GT_INTERN
    EXCEPTIONS
      INCONSISTENT_PARAMETERS       = 1
      UPLOAD_OLE                    = 2
      OTHERS                        = 3.

  IF GT_INTERN[] IS INITIAL OR
     SY-SUBRC <> 0.
    MESSAGE I000(38) WITH 'Error al leer el archivo.'.
    LEAVE PROGRAM.
  ENDIF.

  SORT GT_INTERN BY ROW ASCENDING COL ASCENDING.


  LOOP AT GT_INTERN.
    ON CHANGE OF GT_INTERN-ROW.
      IF GT_INTERN-ROW > 1.
        APPEND RECORD.
        CLEAR RECORD.
      ENDIF.
    ENDON.

    CASE GT_INTERN-COL.
      WHEN 1. RECORD-BELNR = GT_INTERN-VALUE.
      WHEN 2. RECORD-BUKRS = GT_INTERN-VALUE.
      WHEN 3. RECORD-GJAHR = GT_INTERN-VALUE.
    ENDCASE.

    AT LAST.
      APPEND RECORD.
    ENDAT.
  ENDLOOP.


  gs_params-dismode = 'N'.
  gs_params-updmode = 'S'.
  gs_params-defsize = 'X'.

  CONCATENATE SY-DATUM+6(2) SY-DATUM+4(2) SY-DATUM(4)
    INTO GD_FECHA SEPARATED BY '.'.

  LOOP AT RECORD.
    CLEAR: GD_ERROR, GD_BSTAT.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input         = RECORD-BELNR
      IMPORTING
        OUTPUT        = RECORD-BELNR.

    TRANSLATE RECORD-BUKRS TO UPPER CASE.

    perform bdc_dynpro      using 'SAPMF05R' '0100'.
    perform bdc_field       using 'BDC_OKCODE'
                                  '=RAGL'.
    perform bdc_field       using 'RF05R-AUGBL'
                                  RECORD-BELNR.
    perform bdc_field       using 'RF05R-BUKRS'
                                  RECORD-BUKRS.
    perform bdc_field       using 'RF05R-GJAHR'
                                  RECORD-GJAHR.
    CALL TRANSACTION 'FBRA' USING    BDCDATA
                            OPTIONS  FROM Gs_params
                            MESSAGES INTO Gt_messtab.

    READ TABLE GT_MESSTAB WITH KEY MSGTYP = 'E'.
    IF SY-SUBRC = 0.
      WRITE: / 'Documento', SPACE,
                RECORD-BELNR, SPACE,
                RECORD-BUKRS, SPACE,
                RECORD-GJAHR, SPACE,
                'procesado con errores, ver mensajes.'.
      GD_ERROR = 'X'.
    ELSE.
      WRITE: / 'Documento', SPACE,
                RECORD-BELNR, SPACE,
                RECORD-BUKRS, SPACE,
                RECORD-GJAHR, SPACE,
                'procesado correctamente.'.
    ENDIF.

    LOOP AT GT_MESSTAB.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM T100 WHERE SPRSL = GT_MESSTAB-MSGSPRA
*                                AND   ARBGB = GT_MESSTAB-MSGID
*                                AND   MSGNR = GT_MESSTAB-MSGNR.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM T100 WHERE SPRSL = GT_MESSTAB-MSGSPRA
                                AND   ARBGB = GT_MESSTAB-MSGID
                                AND   MSGNR = GT_MESSTAB-MSGNR ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
      IF SY-SUBRC = 0.
        L_MSTRING = T100-TEXT.
        IF L_MSTRING CS '&1'.
          REPLACE '&1' WITH GT_MESSTAB-MSGV1 INTO L_MSTRING.
          REPLACE '&2' WITH GT_MESSTAB-MSGV2 INTO L_MSTRING.
          REPLACE '&3' WITH GT_MESSTAB-MSGV3 INTO L_MSTRING.
          REPLACE '&4' WITH GT_MESSTAB-MSGV4 INTO L_MSTRING.
        ELSE.
          REPLACE '&' WITH GT_MESSTAB-MSGV1 INTO L_MSTRING.
          REPLACE '&' WITH GT_MESSTAB-MSGV2 INTO L_MSTRING.
          REPLACE '&' WITH GT_MESSTAB-MSGV3 INTO L_MSTRING.
          REPLACE '&' WITH GT_MESSTAB-MSGV4 INTO L_MSTRING.
        ENDIF.
        CONDENSE L_MSTRING.
        WRITE: / GT_MESSTAB-MSGTYP, L_MSTRING(250).
      ELSE.
        WRITE: / GT_MESSTAB.
      ENDIF.
    ENDLOOP.

    CLEAR: GT_MESSTAB[], L_MSTRING, BDCDATA, BDCDATA[].

    WAIT UP TO 1 SECONDS.

SELECT SINGLE BSTAT INTO GD_BSTAT
*Begin of change: ReSQ Correction for BYPASS BUFFER 24/12/2019 EY_DES04 ECDK917080 *
*FROM BKPF BYPASSING BUFFER
FROM BKPF
*End of change: ReSQ Correction for BYPASS BUFFER 24/12/2019 EY_DES04 ECDK917080 *
WHERE BUKRS = RECORD-BUKRS AND
BELNR = RECORD-BELNR AND
GJAHR = RECORD-GJAHR.

    IF GD_BSTAT IS INITIAL.
      perform bdc_dynpro      using 'SAPMF05A' '0105'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=BU'.
      perform bdc_field       using 'RF05A-BELNS'
                                    RECORD-BELNR.
      perform bdc_field       using 'BKPF-BUKRS'
                                    RECORD-BUKRS.
      perform bdc_field       using 'RF05A-GJAHS'
                                    RECORD-GJAHR.
      perform bdc_field       using 'UF05A-STGRD'
                                    '01'.
*      perform bdc_field       using 'BSIS-BUDAT'
*                                     GD_FECHA.
      CALL TRANSACTION 'FB08' USING    BDCDATA
                              OPTIONS  FROM Gs_params
                              MESSAGES INTO Gt_messtab.

      LOOP AT GT_MESSTAB.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM T100 WHERE SPRSL = GT_MESSTAB-MSGSPRA
*                                  AND   ARBGB = GT_MESSTAB-MSGID
*                                  AND   MSGNR = GT_MESSTAB-MSGNR.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM T100 WHERE SPRSL = GT_MESSTAB-MSGSPRA
                                  AND   ARBGB = GT_MESSTAB-MSGID
                                  AND   MSGNR = GT_MESSTAB-MSGNR ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
        IF SY-SUBRC = 0.
          L_MSTRING = T100-TEXT.
          IF L_MSTRING CS '&1'.
            REPLACE '&1' WITH GT_MESSTAB-MSGV1 INTO L_MSTRING.
            REPLACE '&2' WITH GT_MESSTAB-MSGV2 INTO L_MSTRING.
            REPLACE '&3' WITH GT_MESSTAB-MSGV3 INTO L_MSTRING.
            REPLACE '&4' WITH GT_MESSTAB-MSGV4 INTO L_MSTRING.
          ELSE.
            REPLACE '&' WITH GT_MESSTAB-MSGV1 INTO L_MSTRING.
            REPLACE '&' WITH GT_MESSTAB-MSGV2 INTO L_MSTRING.
            REPLACE '&' WITH GT_MESSTAB-MSGV3 INTO L_MSTRING.
            REPLACE '&' WITH GT_MESSTAB-MSGV4 INTO L_MSTRING.
          ENDIF.
          CONDENSE L_MSTRING.
          WRITE: / GT_MESSTAB-MSGTYP, L_MSTRING(250).
        ELSE.
          WRITE: / GT_MESSTAB.
        ENDIF.
      ENDLOOP.

      WRITE: /.

      CLEAR: GT_MESSTAB[], L_MSTRING, BDCDATA, BDCDATA[].
    ENDIF.
  ENDLOOP.

*FIN
