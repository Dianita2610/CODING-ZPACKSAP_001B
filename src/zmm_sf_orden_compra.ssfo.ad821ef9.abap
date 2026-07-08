*data v_direccion type char30.


* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE *
*  into CORRESPONDING FIELDS OF wa_ekpo
*  from ekpo
*  where ebeln eq v_ebeln.
*
* NEW CODE
SELECT *
UP TO 1 ROWS 
  into CORRESPONDING FIELDS OF wa_ekpo
  from ekpo
  where ebeln eq v_ebeln ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE *
*INTO CORRESPONDING FIELDS OF wa_ekko
*FROM ekko
*WHERE ebeln EQ v_ebeln.
*
* NEW CODE
SELECT *
UP TO 1 ROWS 
INTO CORRESPONDING FIELDS OF wa_ekko
FROM ekko
WHERE ebeln EQ v_ebeln ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01


* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT single *
*  into CORRESPONDING FIELDS OF wa_adrc
*  from adrc
*  where ADDRNUMBER eq wa_ekpo-adrnr.
*
* NEW CODE
SELECT *
UP TO 1 ROWS 
  into CORRESPONDING FIELDS OF wa_adrc
  from adrc
  where ADDRNUMBER eq wa_ekpo-adrnr ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

CONCATENATE wa_adrc-street wa_ADRC-HOUSE_NUM1 ',' wa_adrc-CITY2 into v_direccion SEPARATED BY space.
*break crystalis_ab.

data v_name type THEAD-TDNAME.
v_name = v_ebeln.

call FUNCTION 'READ_TEXT'
EXPORTING
  ID          = 'F01'
  LANGUAGE    = sy-langu
  NAME        = v_name
  OBJECT      = 'EKKO'
TABLES
  LINES       = v_text.

data: ti_cdhdr TYPE TABLE OF CDHDR.
clear ti_cdhdr[].

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT *
*  into CORRESPONDING FIELDS OF table ti_cdhdr
*  from CDHDR
*  where OBJECTID eq v_ebeln
**    and TCODE    eq 'ME29N'
*    and TCODE    in ('ME29N', 'ME28')
*  .
*
* NEW CODE
SELECT *

  into CORRESPONDING FIELDS OF table ti_cdhdr
  from CDHDR
  where OBJECTID eq v_ebeln
*    and TCODE    eq 'ME29N'
    and TCODE    in ('ME29N', 'ME28')
   ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03
sort ti_cdhdr by udate DESCENDING utime DESCENDING.

READ TABLE ti_cdhdr into wa_cdhdr INDEX 1.

READ TABLE v_text into wa_text index 1.



