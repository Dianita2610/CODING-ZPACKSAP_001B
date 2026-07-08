*data v_direccion type char30.

select single *
  into CORRESPONDING FIELDS OF wa_ekko
  from ekko
  where ebeln eq v_ebeln.

SELECT single *
  into CORRESPONDING FIELDS OF wa_t001
  from T001
  where bukrs eq wa_ekko-bukrs.

SELECT SINGLE *
  INTO CORRESPONDING FIELDS OF wa_t001z
  FROM T001Z
  WHERE bukrs eq wa_ekko-bukrs.

SELECT single *
  into CORRESPONDING FIELDS OF wa_adrc
  FROM adrc
  where ADDRNUMBER eq wa_t001-ADRNR.

CONCATENATE wa_adrc-street wa_ADRC-HOUSE_NUM1 ',' wa_adrc-CITY1 into v_direccion SEPARATED BY space.












