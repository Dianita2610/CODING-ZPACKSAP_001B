*data v_direccion type char30.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*select single *
*  into CORRESPONDING FIELDS OF wa_ekko
*  from ekko
*  where ebeln eq v_ebeln.
*
* NEW CODE
SELECT *
UP TO 1 ROWS 
  into CORRESPONDING FIELDS OF wa_ekko
  from ekko
  where ebeln eq v_ebeln ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT single *
*  into CORRESPONDING FIELDS OF wa_t001
*  from T001
*  where bukrs eq wa_ekko-bukrs.
*
* NEW CODE
SELECT *
UP TO 1 ROWS 
  into CORRESPONDING FIELDS OF wa_t001
  from T001
  where bukrs eq wa_ekko-bukrs ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE *
*  INTO CORRESPONDING FIELDS OF wa_t001z
*  FROM T001Z
*  WHERE bukrs eq wa_ekko-bukrs.
*
* NEW CODE
SELECT *
UP TO 1 ROWS 
  INTO CORRESPONDING FIELDS OF wa_t001z
  FROM T001Z
  WHERE bukrs eq wa_ekko-bukrs ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT single *
*  into CORRESPONDING FIELDS OF wa_adrc
*  FROM adrc
*  where ADDRNUMBER eq wa_t001-ADRNR.
*
* NEW CODE
SELECT *
UP TO 1 ROWS 
  into CORRESPONDING FIELDS OF wa_adrc
  FROM adrc
  where ADDRNUMBER eq wa_t001-ADRNR ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

CONCATENATE wa_adrc-street wa_ADRC-HOUSE_NUM1 ',' wa_adrc-CITY1 into v_direccion SEPARATED BY space.












