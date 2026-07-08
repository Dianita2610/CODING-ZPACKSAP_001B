*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION z_pagos_01.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(P_BUKRS) TYPE  BUKRS
*"     VALUE(P_STCD1) TYPE  STCD1
*"  EXPORTING
*"     VALUE(MENSAJE) TYPE  CHAR20
*"  TABLES
*"      TI_SALIDA STRUCTURE  ZPAGOSPROVEEDOR
*"----------------------------------------------------------------------
*& La logica de este programa es identica a la del programa ZFI_PAGO_SIN_COBRO
*& por lo tanto si se modifica este programa, tambien se debe modificar ZFI_PAGO_SIN_COBRO.
* TABLES: bsid, kna1, zmot_emis, bseg.
*"----------------------------------------------------------------------------------------
  TYPES: BEGIN OF ty_salida,
    bukrs           LIKE bsik-bukrs,        "sociedad
    stcd1           LIKE kna1-stcd1,        "rut
    hkont           LIKE bsik-hkont,        "cuenta
    belnr           LIKE bsik-belnr,        "documento
    budat           LIKE bsik-budat,        "fecha doc
    xblnr           LIKE bsid-xblnr,        "doc pago
    blart           LIKE bsik-blart,        "clase doc
    lifnr           LIKE lfa1-lifnr,        "id_maestro
    wrbtr           LIKE bsid-wrbtr,        "importe
    waers           LIKE bsid-waers,
    zfbdt           LIKE bsik-zfbdt,        "fecha pago comprometida
    augdt           LIKE bsak-augdt,
    augbl           LIKE bsak-augbl,
    blart1          LIKE bsik-blart,        "clase doc
    identif_pago    LIKE reguh-identif_pago,
    zzmot_emis      LIKE bsik-zzmot_emis,   "motivo giro
    hbkid           LIKE bseg-hbkid,
    zlsch           LIKE bseg-zlsch,
    buzei           LIKE bsik-buzei,              "agregado 15.12.2014
    zuonr           LIKE bsik-zuonr,        "asignacion
    zlspr           LIKE bseg-zlspr,
    cambio_estado   LIKE zfitr020_t03-cambio_estado, "tipo doc
    documento_dev   LIKE reguh-belnr_dev,
    anno_dev        LIKE reguh-gjahr_dev,
    fecha_dev       LIKE reguh-fecha_devuelto,
  END OF ty_salida.


  DATA: ti_lfa1             TYPE TABLE OF lfa1,
        wa_lfa1             TYPE lfa1,
        ti_zmot_emis        TYPE TABLE OF zmot_emis,
        wa_zmot_emis        TYPE zmot_emis,
        ti_bsik             TYPE TABLE OF bsik,
        ti_bsak             TYPE TABLE OF bsak,
        ti_bkpf             TYPE TABLE OF bkpf,
        ti_payr             TYPE TABLE OF payr,
        ti_salida1          TYPE TABLE OF ty_salida,
        ti_salida_bsak      TYPE TABLE OF ty_salida,
        wa_bsik             TYPE bsik,
        wa_bsak             TYPE ty_salida,
        wa_bkpf             TYPE bkpf,
        wa_payr             TYPE payr,
        wa_reguh            TYPE reguh,
        wa_salida1          TYPE ty_salida,
        wa_salida           TYPE zpagosproveedor,
        wa_salida_bsak      TYPE ty_salida,
        v_valor             TYPE zfitr020_t04-valor,
        v_fecha             TYPE sy-datum,
        v_fecha1            TYPE sy-datum,
        vano(4)             TYPE n,
        vmes(2)             TYPE n,
        vdia(2)             TYPE n,
        v_char_monto        TYPE c LENGTH 13.

  RANGES:  r_hkont           FOR bsik-hkont .
  DATA:    wa_hkont          LIKE LINE OF r_hkont .
  RANGES:  r_emision         FOR zmot_emis-zzmot_emis .
  DATA:    wa_emision        LIKE LINE OF r_emision .
  RANGES:  r_blart           FOR bsad-blart .
  DATA:    wa_blart          LIKE LINE OF r_blart .

*--------------------------------------------------------------------*
* Armar rangos
*--------------------------------------------------------------------*

  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE ti_zmot_emis
  FROM zmot_emis
  WHERE report = 'X'
    AND bukrs  = p_bukrs.

  LOOP AT ti_zmot_emis INTO wa_zmot_emis.

    CLEAR wa_hkont.
    wa_hkont-low    = wa_zmot_emis-cta_cadf.
    wa_hkont-sign   = 'I'."wa_seatleaf-valsign.
    wa_hkont-option = 'EQ'.
    APPEND wa_hkont TO r_hkont.

    CLEAR wa_hkont.
    wa_hkont-low    = wa_zmot_emis-cta_cade.
    wa_hkont-sign   = 'I'."wa_seatleaf-valsign.
    wa_hkont-option = 'EQ'.
    APPEND wa_hkont TO r_hkont.

    CLEAR wa_hkont.
    wa_hkont-low    = wa_zmot_emis-cta_pres_h.
    wa_hkont-sign   = 'I'."wa_seatleaf-valsign.
    wa_hkont-option = 'EQ'.
    APPEND wa_hkont TO r_hkont.

    CLEAR wa_hkont.
    wa_hkont-low    = wa_zmot_emis-cta_cadvv .
    wa_hkont-sign   = 'I'."wa_seatleaf-valsign.
    wa_hkont-option = 'EQ'.
    APPEND wa_hkont TO r_hkont.

    CLEAR wa_emision.
    wa_emision-low    = wa_zmot_emis-zzmot_emis.
    wa_emision-sign   = 'I'."wa_seatleaf-valsign.
    wa_emision-option = 'EQ'.
    APPEND wa_emision TO r_emision.

  ENDLOOP.

  CLEAR wa_blart.
  wa_blart-low    = 'ZP'.
  wa_blart-sign   = 'I'."wa_seatleaf-valsign.
  wa_blart-option = 'EQ'.
  APPEND wa_blart TO r_blart.
  CLEAR wa_blart.

  wa_blart-low    = 'ZA'.
  wa_blart-sign   = 'I'."wa_seatleaf-valsign.
  wa_blart-option = 'EQ'.
  APPEND wa_blart TO r_blart.

*--------------------------------------------------------------------*
  v_fecha = sy-datum .

  vano   = sy-datum(4).
  vmes   = sy-datum+4(2) - 1.
  vdia   = sy-datum+6(2).
  IF vmes = 0.
    vmes = 12.
    vano   = vano - 2.
  ELSE.
    vano   = vano - 1.
  ENDIF.
  CONCATENATE vano vmes vdia INTO v_fecha1.


  SELECT cta_cadf cta_cade cta_pres_h
  INTO CORRESPONDING FIELDS OF TABLE ti_zmot_emis
  FROM zmot_emis
  WHERE report = 'X'.

*-----------------------------------------------------------------------------------
* Selecciona partidas desde BSIK, para:
*                               Cuentas cargadas en tabla R_KONT
*                               Motivos cargados en tabla R_EMISION
*                               Fecha menor o igual a la del sistema
*     Carga en tabla ti_salida1
*------------------------------------------------------------------------------------
  SELECT lf~stcd1
  lf~lifnr
  bs~bukrs
  bs~hkont
  bs~belnr
  bs~budat
  bs~blart
  bs~xblnr
  bs~wrbtr
  bs~waers
  bs~zfbdt
  bs~augdt
  bs~augbl
  bs~hbkid
  bs~zlsch
  bs~zlspr
  bs~buzei                                    "agregado 15.12.2014
  bs~zuonr                                    "agregado 27.12.2016
*         zf~cambio_estado
  bs~zzmot_emis
  INTO CORRESPONDING FIELDS OF TABLE ti_salida1
  FROM bsik AS bs INNER JOIN lfa1 AS lf
  ON bs~lifnr = lf~lifnr
  WHERE bs~bukrs  = p_bukrs
  AND   bs~budat <= v_fecha
  AND   bs~budat >= v_fecha1
  AND   bs~hkont IN r_hkont
  AND   bs~zzmot_emis IN r_emision
  AND   lf~stcd1 = p_stcd1.

*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES01 ECDK917080 *
SORT TI_SALIDA1 .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES01 ECDK917080 *
  LOOP AT ti_salida1 INTO wa_salida1 .

    IF wa_salida1-xblnr = '0'.                  "agregado 26.12.2016
      wa_salida1-xblnr = wa_salida1-zuonr.
      MODIFY ti_salida1 FROM wa_salida1 INDEX sy-tabix..
    ENDIF.

    SELECT SINGLE *
    FROM zmot_emis
    WHERE cta_cadf = wa_salida1-hkont.

    IF sy-subrc EQ 0.
      SELECT SINGLE glosa
      INTO wa_salida1-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_CADF'.
*ReSQ: No Need Of Change Internal Table TI_SALIDA1 Already Sorted
      MODIFY ti_salida1 FROM wa_salida1 INDEX sy-tabix.
    ENDIF.

    SELECT SINGLE *
    FROM zmot_emis
    WHERE cta_cade = wa_salida1-hkont.

    IF sy-subrc EQ 0.
      SELECT SINGLE glosa
      INTO wa_salida1-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_CADE'.
*ReSQ: No Need Of Change Internal Table TI_SALIDA1 Already Sorted
      MODIFY ti_salida1 FROM wa_salida1 INDEX sy-tabix.
    ENDIF.

    SELECT SINGLE *
    FROM zmot_emis
    WHERE cta_pres_h = wa_salida1-hkont.

    IF sy-subrc EQ 0.
      SELECT SINGLE glosa
      INTO wa_salida1-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_PRES_H'.
*ReSQ: No Need Of Change Internal Table TI_SALIDA1 Already Sorted
      MODIFY ti_salida1 FROM wa_salida1 INDEX sy-tabix.
    ENDIF.

    SELECT SINGLE *
    FROM zmot_emis
    WHERE cta_cadvv = wa_salida1-hkont.

    IF sy-subrc EQ 0.
      SELECT SINGLE glosa
      INTO wa_salida1-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_CADVV'.
*ReSQ: No Need Of Change Internal Table TI_SALIDA1 Already Sorted
      MODIFY ti_salida1 FROM wa_salida1 INDEX sy-tabix.
    ENDIF.

  ENDLOOP.
*-----------------------------------------------------------------------------------
* Selecciona partidas desde BSAK, para tipos de documentos cargados en tabla r_blart
*     Con valores ZP y ZA
*     Carga en tabla ti_salida_bsak
*------------------------------------------------------------------------------------
  SELECT lfa~stcd1
  lfa~lifnr
  bsa~bukrs
  bsa~hkont
  bsa~belnr
  bsa~budat
  bsa~blart
  bsa~xblnr
  bsa~wrbtr
  bsa~waers
  bsa~zfbdt
  bsa~augdt
  bsa~augbl
  bsa~hbkid
  bsa~zlsch
  bsa~zlspr
  bsa~buzei
  bsa~zuonr                                    "agregado 27.12.2016
*         zf~cambio_estado
  bsa~zzmot_emis

  INTO CORRESPONDING FIELDS OF TABLE ti_salida_bsak
  FROM bsak AS bsa INNER JOIN lfa1 AS lfa
  ON bsa~lifnr = lfa~lifnr
  WHERE bsa~bukrs = p_bukrs
  AND bsa~budat <= v_fecha
  AND bsa~budat >= v_fecha1
  AND bsa~blart IN r_blart
  AND lfa~stcd1 = p_stcd1.


*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES01 ECDK917080 *
SORT TI_SALIDA_BSAK .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES01 ECDK917080 *
  LOOP AT ti_salida_bsak INTO wa_bsak .

    SELECT  *
    INTO CORRESPONDING FIELDS OF TABLE ti_bkpf
    FROM bkpf
    WHERE bukrs = p_bukrs
    AND belnr = wa_bsak-belnr
    AND gjahr = wa_bsak-budat(4)
    AND stblg = space.

    IF sy-subrc EQ 0.

      SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF wa_payr
      FROM payr
      WHERE vblnr = wa_bsak-belnr
      AND gjahr = wa_bsak-budat(4).
*      AND voidr = space.

      IF sy-subrc EQ 0.
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
        SELECT SINGLE *
          FROM bseg
          WHERE belnr EQ wa_bsak-belnr
          AND bukrs EQ wa_bsak-bukrs
          AND gjahr EQ wa_bsak-budat(4)
          AND hkont EQ wa_payr-ubhkt.


        IF sy-subrc EQ 0.

          IF wa_bsak-xblnr = '0'.
            wa_bsak-xblnr = wa_bsak-zuonr.
            MODIFY ti_salida_bsak FROM wa_bsak INDEX sy-tabix.
          ENDIF.


          SELECT SINGLE glosa
          INTO wa_salida_bsak-cambio_estado
          FROM zfitr020_t06
          WHERE campo = 'PAYR'.
          IF sy-subrc EQ 0.
            wa_salida_bsak-identif_pago = wa_payr-chect.
          ELSE.
            CLEAR wa_salida_bsak-identif_pago.
          ENDIF.
          IF wa_payr-voidr <> space.
            wa_salida_bsak-cambio_estado = 'PAGO ANULADO'.
          ENDIF.

        ENDIF.
      ELSE.                                                 "-----|ini agregado 07.11.2014

        SELECT SINGLE *
        INTO CORRESPONDING FIELDS OF wa_reguh
        FROM reguh
        WHERE zbukr = wa_bsak-bukrs
        AND lifnr = wa_bsak-lifnr
        AND vblnr = wa_bsak-belnr
        AND zaldt = wa_bsak-budat
        AND identif_pago NE space
        AND ind_pago     = space
        AND belnr_dev    = space.

        IF sy-subrc EQ 0.

          SELECT SINGLE glosa
          INTO wa_salida_bsak-cambio_estado
          FROM zfitr020_t06
          WHERE campo = 'REGUH'.

          IF sy-subrc EQ 0.
            wa_salida_bsak-identif_pago    = wa_reguh-identif_pago.
            wa_salida_bsak-documento_dev   = wa_reguh-belnr_dev.
            wa_salida_bsak-anno_dev        = wa_reguh-gjahr_dev.
            wa_salida_bsak-fecha_dev       = wa_reguh-fecha_devuelto.
          ELSE.
            CLEAR  wa_salida_bsak-identif_pago.
            CLEAR wa_salida_bsak-documento_dev.
            CLEAR wa_reguh-belnr_dev.
            CLEAR wa_salida_bsak-anno_dev.
            CLEAR wa_salida_bsak-fecha_dev.
          ENDIF.
        ENDIF.
      ENDIF.


      SELECT
           belnr
           budat
           xblnr
           blart
           lifnr
           wrbtr
           waers
           zfbdt
           augbl
           augdt
           zlsch
           zzmot_emis
           hbkid
           buzei
           zuonr
         FROM bsak
      INTO CORRESPONDING FIELDS OF wa_salida_bsak
        WHERE bukrs = wa_bsak-bukrs
         AND augdt = wa_bsak-augdt
         AND augbl = wa_bsak-augbl
         AND belnr NE wa_bsak-belnr.

        wa_salida_bsak-bukrs   = wa_bsak-bukrs.
        wa_salida_bsak-stcd1   = wa_bsak-stcd1.
        wa_salida_bsak-hkont   = wa_bsak-hkont.
        wa_salida_bsak-blart1  = wa_bsak-blart.

          IF wa_salida_bsak-xblnr = '0'.
            wa_salida_bsak-xblnr = wa_salida_bsak-zuonr.
          ENDIF.

        APPEND wa_salida_bsak TO ti_salida1.
      ENDSELECT.
    ENDIF.
  ENDLOOP.


  IF ti_salida1 IS NOT INITIAL.

    LOOP AT ti_salida1 INTO wa_salida1.

      wa_salida-stcd1         = wa_salida1-stcd1.
      wa_salida-bukrs         = wa_salida1-bukrs.
      wa_salida-lifnr         = wa_salida1-lifnr.
      wa_salida-hkont         = wa_salida1-hkont.
      wa_salida-belnr         = wa_salida1-belnr.
      wa_salida-budat         = wa_salida1-budat.
      wa_salida-blart         = wa_salida1-blart.
      wa_salida-xblnr         = wa_salida1-xblnr.
      WRITE wa_salida1-wrbtr TO v_char_monto CURRENCY 'CLP'.  "Agregado 17.02.2015
      CONDENSE v_char_monto NO-GAPS.
      wa_salida-wrbtr         = v_char_monto.
      wa_salida-waers         = wa_salida1-waers.
      wa_salida-zfbdt         = wa_salida1-zfbdt.
      wa_salida-augdt         = wa_salida1-augdt.
      wa_salida-augbl         = wa_salida1-augbl.
      wa_salida-blart1        = wa_salida1-blart1.
      wa_salida-identif_pago  = wa_salida1-identif_pago.
      wa_salida-zzmot_emis    = wa_salida1-zzmot_emis.
      wa_salida-hbkid          = wa_salida1-hbkid.
      wa_salida-zlsch          = wa_salida1-zlsch.
      wa_salida-buzei          = wa_salida1-buzei.                  "agregado 15.12.2014
      wa_salida-zlspr          = wa_salida1-zlspr.
      wa_salida-cambio_estado  = wa_salida1-cambio_estado.
      wa_salida-documento_dev  = wa_salida1-documento_dev.
      wa_salida-anno_dev       = wa_salida1-anno_dev.
      wa_salida-fecha_dev      = wa_salida1-fecha_dev.
      APPEND wa_salida TO ti_salida.
    ENDLOOP.
  ELSE.
    mensaje = 'RUT NO TIENE DEUDA' .
  ENDIF.
*--------------------------------------------------------------------*

ENDFUNCTION.
