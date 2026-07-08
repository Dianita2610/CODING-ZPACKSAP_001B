DATA: lv_adrnr TYPE lfa1-adrnr.

SELECT SINGLE name1 adrnr stcd1
  INTO (gv_name1, lv_adrnr, gv_stcd1 )
  FROM lfa1 WHERE lifnr = is_ekko-lifnr.

  IF lv_adrnr IS NOT INITIAL.
    SELECT SINGLE a~name1 a~street a~city1 a~house_num1
      a~country a~sort1 a~tel_number b~landx
      INTO gs_adrc FROM adrc AS a INNER JOIN t005t AS b
        ON a~country = b~land1 AND b~spras = 'S'
          WHERE a~addrnumber = lv_adrnr.

    SELECT SINGLE smtp_addr INTO gv_mail_addr
      FROM adr6 WHERE addrnumber = lv_adrnr.
  ENDIF.
