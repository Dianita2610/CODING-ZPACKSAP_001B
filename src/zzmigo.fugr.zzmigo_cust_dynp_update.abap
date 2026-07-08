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
    SELECT SINGLE * FROM mseg
      WHERE mblnr EQ i_mblnr.
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
        SELECT SINGLE bukrs gjahr lifnr  INTO (v_bukrs, v_gjahr, v_lifnr)
        FROM mseg
        WHERE mblnr      EQ i_mblnr
        AND line_id      EQ wa_mseg-line_id.

        CONCATENATE i_mblnr i_gjahr INTO v_awkey.
*buscamos el belnr en la bkpf
        SELECT SINGLE belnr
          INTO v_belnr
          FROM bkpf
          WHERE awtyp EQ 'MKPF'
            AND awkey EQ v_awkey
            AND awsys EQ ''.
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
