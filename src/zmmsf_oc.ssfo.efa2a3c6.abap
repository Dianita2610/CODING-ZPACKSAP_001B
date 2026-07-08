DATA: lv_adrnr TYPE lfa1-adrnr.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE name1 adrnr stcd1
*  INTO (gv_name1, lv_adrnr, gv_stcd1 )
*  FROM lfa1 WHERE lifnr = is_ekko-lifnr.
*
* NEW CODE
SELECT name1 adrnr stcd1
UP TO 1 ROWS 
  INTO (gv_name1, lv_adrnr, gv_stcd1 )
  FROM lfa1 WHERE lifnr = is_ekko-lifnr ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

  IF lv_adrnr IS NOT INITIAL.
    SELECT SINGLE a~name1 a~street a~city1 a~house_num1
      a~country a~sort1 a~tel_number b~landx
      INTO gs_adrc FROM adrc AS a INNER JOIN t005t AS b
        ON a~country = b~land1 AND b~spras = 'S'
          WHERE a~addrnumber = lv_adrnr.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE smtp_addr INTO gv_mail_addr
*      FROM adr6 WHERE addrnumber = lv_adrnr.
*
* NEW CODE
    SELECT smtp_addr
    UP TO 1 ROWS  INTO gv_mail_addr
      FROM adr6 WHERE addrnumber = lv_adrnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
  ENDIF.
