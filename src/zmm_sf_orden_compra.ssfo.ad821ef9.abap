*data v_direccion type char30.


SELECT SINGLE *
  into CORRESPONDING FIELDS OF wa_ekpo
  from ekpo
  where ebeln eq v_ebeln.

SELECT SINGLE *
INTO CORRESPONDING FIELDS OF wa_ekko
FROM ekko
WHERE ebeln EQ v_ebeln.


SELECT single *
  into CORRESPONDING FIELDS OF wa_adrc
  from adrc
  where ADDRNUMBER eq wa_ekpo-adrnr.

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

SELECT *
  into CORRESPONDING FIELDS OF table ti_cdhdr
  from CDHDR
  where OBJECTID eq v_ebeln
*    and TCODE    eq 'ME29N'
    and TCODE    in ('ME29N', 'ME28')
  .
sort ti_cdhdr by udate DESCENDING utime DESCENDING.

READ TABLE ti_cdhdr into wa_cdhdr INDEX 1.

READ TABLE v_text into wa_text index 1.



