FUNCTION ZBUSCARUT.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(LAND1) TYPE  LAND1
*"     VALUE(STCD3) TYPE  STCD3
*"     VALUE(GKOAR_I) TYPE  GKOAR
*"     VALUE(BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     VALUE(KUNNR) TYPE  KUNNR
*"     VALUE(NAME1) TYPE  NAME1_GP
*"     VALUE(NAME2) TYPE  NAME2_GP
*"     VALUE(ADRNR) TYPE  ADRNR
*"     VALUE(NAME3) TYPE  NAME3_GP
*"     VALUE(NAME4) TYPE  NAME4_GP
*"     VALUE(LIFNR) TYPE  LIFNR
*"----------------------------------------------------------------------
DATA: LIFNRTMP LIKE LFA1-LIFNR,
      KUNNRTMP LIKE KNA1-KUNNR,
      w_SORTL LIKE LFA1-SORTL.



CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
  EXPORTING
    INPUT         = LIFNR
 IMPORTING
   OUTPUT        = LIFNR
          .

CONDENSE STCD3 NO-GAPS.
w_sortl = stcd3.
REPLACE ALL OCCURRENCES OF '-' IN w_sortl WITH ''.

CASE GKOAR_I.
    WHEN 'K'.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE LIFNR NAME1 NAME2 ADRNR NAME3 NAME4 KUNNR
*      INTO (LIFNRTMP, NAME1, NAME2, ADRNR, NAME3, NAME4, KUNNR)
*    FROM LFA1 CLIENT SPECIFIED
*      WHERE  mandt = sy-mandt
*              and ( sortl = w_sortl or sortl = STCD3 )
*              and STCD1 = STCD3
*              AND LAND1 = LAND1.
*
* NEW CODE
      SELECT LIFNR NAME1 NAME2 ADRNR NAME3 NAME4 KUNNR
      UP TO 1 ROWS 
      INTO (LIFNRTMP, NAME1, NAME2, ADRNR, NAME3, NAME4, KUNNR)
    FROM LFA1 CLIENT SPECIFIED
      WHERE  mandt = sy-mandt
              and ( sortl = w_sortl or sortl = STCD3 )
              and STCD1 = STCD3
              AND LAND1 = LAND1 ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
      IF LIFNRTMP IS INITIAL.
        CLEAR KUNNR.
        CLEAR NAME1.
        CLEAR NAME2.
        CLEAR ADRNR.
        CLEAR NAME3.
        CLEAR NAME4.
        CLEAR LIFNR.
      ELSE.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE LIFNR AKONT LIFNR
*        INTO (LIFNR, NAME3, KUNNR)
*        FROM LFB1 CLIENT SPECIFIED
*        WHERE mandt = sy-mandt
*              and LIFNR EQ LIFNRTMP
*              AND BUKRS EQ BUKRS.
*
* NEW CODE
        SELECT LIFNR AKONT LIFNR
        UP TO 1 ROWS 
        INTO (LIFNR, NAME3, KUNNR)
        FROM LFB1 CLIENT SPECIFIED
        WHERE mandt = sy-mandt
              and LIFNR EQ LIFNRTMP
              AND BUKRS EQ BUKRS ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
        IF LIFNR IS INITIAL.
          CLEAR NAME1.
          CLEAR NAME2.
          CLEAR ADRNR.
          CLEAR NAME3.
          NAME4 = 'N'.
        ELSE.
          NAME4 = 'E'.
        ENDIF.
        KUNNR = LIFNRTMP.
        LIFNR = LIFNRTMP.
      ENDIF.
    WHEN 'D'.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE LIFNR NAME1 NAME2 ADRNR NAME3 NAME4 KUNNR
*      INTO (LIFNR, NAME1, NAME2, ADRNR, NAME3, NAME4, KUNNRTMP)
*    FROM KNA1 CLIENT SPECIFIED
*      WHERE  mandt = sy-mandt
*             and ( sortl = w_sortl or sortl = STCD3 )
*             and STCD1 = STCD3
*             AND LAND1 = LAND1.
*
* NEW CODE
      SELECT LIFNR NAME1 NAME2 ADRNR NAME3 NAME4 KUNNR
      UP TO 1 ROWS 
      INTO (LIFNR, NAME1, NAME2, ADRNR, NAME3, NAME4, KUNNRTMP)
    FROM KNA1 CLIENT SPECIFIED
      WHERE  mandt = sy-mandt
             and ( sortl = w_sortl or sortl = STCD3 )
             and STCD1 = STCD3
             AND LAND1 = LAND1 ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
                IF KUNNRTMP IS INITIAL.
                  CLEAR KUNNR.
                  CLEAR NAME1.
                  CLEAR NAME2.
                  CLEAR ADRNR.
                  CLEAR NAME3.
                  CLEAR NAME4.
                  CLEAR LIFNR.
                ELSE.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*                  SELECT SINGLE KUNNR AKONT KUNNR
*                  INTO (LIFNR, NAME3, KUNNR)
*                  FROM KNB1 CLIENT SPECIFIED
*                  WHERE mandt = sy-mandt
*                        and KUNNR EQ KUNNRTMP
*                        AND BUKRS EQ BUKRS.
*
* NEW CODE
                  SELECT KUNNR AKONT KUNNR
                  UP TO 1 ROWS 
                  INTO (LIFNR, NAME3, KUNNR)
                  FROM KNB1 CLIENT SPECIFIED
                  WHERE mandt = sy-mandt
                        and KUNNR EQ KUNNRTMP
                        AND BUKRS EQ BUKRS ORDER BY PRIMARY KEY.

                  ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
                  IF LIFNR IS INITIAL.
                    CLEAR NAME1.
                    CLEAR NAME2.
                    CLEAR ADRNR.
                    CLEAR NAME3.
                    NAME4 = 'N'.
                  ELSE.
                    NAME4 = 'E'.
                  ENDIF.
                  KUNNR = KUNNRTMP.
                  LIFNR = KUNNRTMP.
               ENDIF.
    WHEN OTHERS.
  ENDCASE.


ENDFUNCTION.
