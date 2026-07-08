
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE text1 FROM t052u INTO gv_tzterm
*  WHERE spras = 'S'
*    AND zterm = is_ekko-zterm.
*
* NEW CODE
SELECT text1
UP TO 1 ROWS  FROM t052u INTO gv_tzterm
  WHERE spras = 'S'
    AND zterm = is_ekko-zterm ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01























