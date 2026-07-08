FUNCTION zzmigo_cust_dynp_update.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_MBLNR) TYPE  MBLNR
*"     VALUE(I_GJAHR) TYPE  GJAHR
*"  TABLES
*"      ET_MSEG STRUCTURE  ZZMIGO_POSICION
*"----------------------------------------------------------------------
  "Función que actualiza la tabla MSEG en modo de fondo
  DATA: v_ebeln TYPE mseg-ebeln,
        v_ebelp TYPE mseg-ebelp,
        v_bukrs TYPE mseg-bukrs,
        v_awkey TYPE char20,
        v_belnr TYPE bseg-belnr,
        v_gjahr TYPE mseg-gjahr,
        v_lifnr TYPE mseg-lifnr.

  TABLES: mseg.
  DATA: wa_mseg TYPE zzmigo_posicion.
  DATA: num TYPE i.
  CHECK i_mblnr IS NOT INITIAL.

  DO.
    ADD 1 TO num.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM mseg
*      WHERE mblnr EQ i_mblnr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM mseg
      WHERE mblnr EQ i_mblnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
    IF sy-subrc EQ 0.
      EXIT.
    ENDIF.
    IF num EQ 100000.
      EXIT.
    ENDIF.
  ENDDO.

  LOOP AT et_mseg INTO wa_mseg.
    IF NOT wa_mseg-zzunid_pro IS INITIAL.



*--------------------------------------------------------------------*
*  se agrega el dato en la bseg
*--------------------------------------------------------------------*
      IF sy-subrc EQ 0.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE bukrs gjahr lifnr  INTO (v_bukrs, v_gjahr, v_lifnr)
*        FROM mseg
*        WHERE mblnr      EQ i_mblnr
*        AND line_id      EQ wa_mseg-line_id.
*
* NEW CODE
        SELECT bukrs gjahr lifnr
        UP TO 1 ROWS   INTO (v_bukrs, v_gjahr, v_lifnr)
        FROM mseg
        WHERE mblnr      EQ i_mblnr
        AND line_id      EQ wa_mseg-line_id ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

        CONCATENATE i_mblnr i_gjahr INTO v_awkey.
*buscamos el belnr en la bkpf
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE belnr
*          INTO v_belnr
*          FROM bkpf
*          WHERE awtyp EQ 'MKPF'
*            AND awkey EQ v_awkey
*            AND awsys EQ ''.
*
* NEW CODE
        SELECT belnr
        UP TO 1 ROWS 
          INTO v_belnr
          FROM bkpf
          WHERE awtyp EQ 'MKPF'
            AND awkey EQ v_awkey
            AND awsys EQ '' ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
        IF sy-subrc EQ 0.
          UPDATE mseg SET zzunid_pro = wa_mseg-zzunid_pro
                               zzrut_terc = v_lifnr
                           WHERE mblnr EQ i_mblnr
                             AND line_id EQ wa_mseg-line_id.

          UPDATE bseg SET zzunid_pro = wa_mseg-zzunid_pro
                          zzrut_terc = v_lifnr
          WHERE belnr EQ v_belnr
          AND   bukrs EQ v_bukrs
          AND   gjahr EQ v_gjahr
*        and   ebeln EQ v_ebeln
*        AND   ebelp EQ v_ebelp
          AND   bschl EQ '81'.


        ENDIF.
        CLEAR : v_ebeln, v_ebelp, v_belnr, v_awkey.
      ENDIF.

    ENDIF.
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*

  ENDLOOP.

  COMMIT WORK.


ENDFUNCTION.
