DATA: lv_packno TYPE esll-packno.
CLEAR gt_esll.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE sub_packno FROM esll INTO lv_packno
*WHERE packno = gs_ekpo-packno.
*
* NEW CODE
SELECT sub_packno
UP TO 1 ROWS  FROM esll INTO lv_packno
WHERE packno = gs_ekpo-packno ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

IF sy-subrc = 0.
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT * FROM esll INTO TABLE gt_esll
*WHERE packno = lv_packno.
*
* NEW CODE
SELECT *
 FROM esll INTO TABLE gt_esll
WHERE packno = lv_packno ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03
ENDIF.





















