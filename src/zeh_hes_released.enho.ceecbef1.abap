"Name: \FU:MS_SAVE_SERVICE_ENTRY\SE:END\EI
ENHANCEMENT 0 ZEH_HES_RELEASED.
*
  DATA: lv_subrc      LIKE sy-subrc,
        lt_leistung   TYPE STANDARD TABLE OF ml_esll,
        lv_sub_packno TYPE esll-sub_packno.

  LOOP AT u_essr WHERE kzabn = 'X' AND loekz is initial.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE sub_packno FROM esll INTO lv_sub_packno
*      WHERE packno = u_essr-packno.
*
* NEW CODE
    SELECT sub_packno
    UP TO 1 ROWS  FROM esll INTO lv_sub_packno
      WHERE packno = u_essr-packno ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
        IF sy-subrc EQ 0.
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*          SELECT * FROM ml_esll INTO CORRESPONDING FIELDS OF TABLE lt_leistung
*            WHERE packno = lv_sub_packno.
*
* NEW CODE
          SELECT *
 FROM ml_esll INTO CORRESPONDING FIELDS OF TABLE lt_leistung
            WHERE packno = lv_sub_packno ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03
        ENDIF.

    CALL FUNCTION 'ZFU_MM_SEND_EMAIL_HES'
      EXPORTING
        i_essr              = u_essr
        i_ekko              = xekko
     IMPORTING
       e_subrc              = lv_subrc
       TABLES
       it_esll              = lt_leistung[]
     EXCEPTIONS
       no_existe_hes       = 1
       OTHERS              = 2
              .
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDLOOP.
ENDENHANCEMENT.
