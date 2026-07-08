*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION z_pagos.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(P_BUKRS) TYPE  BUKRS
*"     VALUE(P_STCD1) TYPE  STCD1
*"  EXPORTING
*"     VALUE(MENSAJE) TYPE  CHAR20
*"  TABLES
*"      TI_SALIDA STRUCTURE  ZPAGOSINCOBRO
*"----------------------------------------------------------------------
*& La logica de este programa es identica a la del programa ZFI_PAGO_SIN_COBRO
*& por lo tanto si se modifica este programa, tambien se debe modificar ZFI_PAGO_SIN_COBRO.
  TABLES: bsid, kna1, zmot_emis, bseg.

  TYPES: BEGIN OF ty_salida,
    stcd1           LIKE kna1-stcd1,        "rut
*  ktokd   LIKE kna1-ktokd,
    lifnr           LIKE lfa1-lifnr,        "id_maestro
    bukrs           LIKE bsik-bukrs,        "sociedad
    hkont           LIKE bsik-hkont,        "cuenta
*  kunnr   LIKE bsid-kunnr,
    belnr           LIKE bsik-belnr,        "documento
    budat           LIKE bsik-budat,        "fecha doc
    blart           LIKE bsik-blart,        "clase doc
    xblnr           LIKE bsid-xblnr,        "doc pago
    wrbtr           LIKE bsid-wrbtr,        "importe
    waers           LIKE bsid-waers,
    cambio_estado   LIKE zfitr020_t03-cambio_estado, "tipo doc
    zzmot_emis      LIKE bsik-zzmot_emis,   "motivo giro
    augdt           LIKE bsak-augdt,
    augbl           LIKE bsak-augbl,
    buzei           LIKE bsik-buzei,              "agregado 15.12.2014
    hbkid           LIKE bsak-hbkid,
    zlsch           LIKE bsak-zlsch,
    zlspr           LIKE bsak-zlspr,
    ZFBDT           LIKE bsak-ZFBDT,
    zuonr           like bsik-zuonr,        "asignación  2016-12-30
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
        wa_bsak             TYPE bsak,
        wa_bkpf             TYPE bkpf,
        wa_payr             TYPE payr,
        wa_reguh            TYPE reguh,
        wa_salida1          TYPE ty_salida,
        wa_salida           TYPE zpagosincobro,
        wa_salida_bsak      TYPE ty_salida,
        v_valor             TYPE zfitr020_t04-valor,
        v_fecha             TYPE sy-datum,
        v_char_monto        TYPE c LENGTH 13.

  RANGES: r_hkont           FOR bsik-hkont .
  DATA:   wa_hkont          LIKE LINE OF r_hkont .
  RANGES: r_emision         FOR zmot_emis-zzmot_emis .
  DATA:   wa_emision        LIKE LINE OF r_emision .
  RANGES: r_blart           FOR bsad-blart .
  DATA:  wa_blart           LIKE LINE OF r_blart .

*--------------------------------------------------------------------*
*armar rangos
*--------------------------------------------------------------------*

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *
*  INTO CORRESPONDING FIELDS OF TABLE ti_zmot_emis
*  FROM zmot_emis
*  WHERE report = 'X'
*    AND bukrs  = p_bukrs.
*
* NEW CODE
  SELECT *

  INTO CORRESPONDING FIELDS OF TABLE ti_zmot_emis
  FROM zmot_emis
  WHERE report = 'X'
    AND bukrs  = p_bukrs ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

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
*--------------------------------------------------------------------*
*selecciona datos
* Obtengo dias
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE valor
*  INTO v_valor
*  FROM zfitr020_t04
*  WHERE nombre EQ 'ZFITR040_DIAS'.
*
* NEW CODE
  SELECT valor
  UP TO 1 ROWS 
  INTO v_valor
  FROM zfitr020_t04
  WHERE nombre EQ 'ZFITR040_DIAS' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

  v_fecha = sy-datum - v_valor.


* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT cta_cadf cta_cade cta_pres_h
*  INTO CORRESPONDING FIELDS OF TABLE ti_zmot_emis
*  FROM zmot_emis
*  WHERE report = 'X'.
*
* NEW CODE
  SELECT cta_cadf cta_cade cta_pres_h

  INTO CORRESPONDING FIELDS OF TABLE ti_zmot_emis
  FROM zmot_emis
  WHERE report = 'X' ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03


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
  bs~buzei                                    "agregado 15.12.2014
  bs~hbkid
  bs~zlsch
  bs~zlspr
  bs~zuonr                                    "agregado 30.12.2016
*         zf~cambio_estado
  bs~zzmot_emis
  bs~ZFBDT
  INTO CORRESPONDING FIELDS OF TABLE ti_salida1
  FROM bsik AS bs INNER JOIN lfa1 AS lf
  ON bs~lifnr = lf~lifnr
*    INNER JOIN zfitr020_t03 AS zf
*    ON zf~clase_doc = bs~blart
  WHERE bs~bukrs = p_bukrs
  AND bs~budat < v_fecha
  AND bs~hkont IN r_hkont
  AND bs~zzmot_emis IN r_emision
  AND lf~stcd1 = p_stcd1
  AND ( bs~zlspr = '' OR bs~zlspr ='W' ).

*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES01 ECDK917080 *
SORT TI_SALIDA1 .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES01 ECDK917080 *
  LOOP AT ti_salida1 INTO wa_salida1 .

    if wa_salida1-xblnr = '0'.                  "agregado 30.12.2016
      wa_salida1-xblnr = wa_salida1-zuonr.
      modify ti_salida1 from wa_salida1 index sy-tabix..
    endif.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*    FROM zmot_emis
*    WHERE cta_cadf = wa_salida1-hkont.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
    FROM zmot_emis
    WHERE cta_cadf = wa_salida1-hkont ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

    IF sy-subrc EQ 0.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE glosa
*      INTO wa_salida1-cambio_estado
*      FROM zfitr020_t06
*      WHERE campo = 'CTA_CADF'.
*
* NEW CODE
      SELECT glosa
      UP TO 1 ROWS 
      INTO wa_salida1-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_CADF' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
*ReSQ: No Need Of Change Internal Table TI_SALIDA1 Already Sorted
      MODIFY ti_salida1 FROM wa_salida1 INDEX sy-tabix.
    ENDIF.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*    FROM zmot_emis
*    WHERE cta_cade = wa_salida1-hkont.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
    FROM zmot_emis
    WHERE cta_cade = wa_salida1-hkont ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

    IF sy-subrc EQ 0.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE glosa
*      INTO wa_salida1-cambio_estado
*      FROM zfitr020_t06
*      WHERE campo = 'CTA_CADE'.
*
* NEW CODE
      SELECT glosa
      UP TO 1 ROWS 
      INTO wa_salida1-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_CADE' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
*ReSQ: No Need Of Change Internal Table TI_SALIDA1 Already Sorted
      MODIFY ti_salida1 FROM wa_salida1 INDEX sy-tabix.
    ENDIF.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*    FROM zmot_emis
*    WHERE cta_pres_h = wa_salida1-hkont.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
    FROM zmot_emis
    WHERE cta_pres_h = wa_salida1-hkont ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

    IF sy-subrc EQ 0.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE glosa
*      INTO wa_salida1-cambio_estado
*      FROM zfitr020_t06
*      WHERE campo = 'CTA_PRES_H'.
*
* NEW CODE
      SELECT glosa
      UP TO 1 ROWS 
      INTO wa_salida1-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_PRES_H' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
*ReSQ: No Need Of Change Internal Table TI_SALIDA1 Already Sorted
      MODIFY ti_salida1 FROM wa_salida1 INDEX sy-tabix.
    ENDIF.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*    FROM zmot_emis
*    WHERE cta_cadvv = wa_salida1-hkont.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
    FROM zmot_emis
    WHERE cta_cadvv = wa_salida1-hkont ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

    IF sy-subrc EQ 0.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE glosa
*      INTO wa_salida1-cambio_estado
*      FROM zfitr020_t06
*      WHERE campo = 'CTA_CADVV'.
*
* NEW CODE
      SELECT glosa
      UP TO 1 ROWS 
      INTO wa_salida1-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_CADVV' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
*ReSQ: No Need Of Change Internal Table TI_SALIDA1 Already Sorted
      MODIFY ti_salida1 FROM wa_salida1 INDEX sy-tabix.
    ENDIF.

    IF wa_salida1-zlspr ='W'.
      wa_salida1-cambio_estado = 'En trámite - ya solicitado a pago'.
*ReSQ: No Need Of Change Internal Table TI_SALIDA1 Already Sorted
      MODIFY ti_salida1 FROM wa_salida1 INDEX sy-tabix.
    ENDIF.


  ENDLOOP.


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
*         zf~cambio_estado
  bsa~zzmot_emis
  bsa~augdt
  bsa~augbl
  bsa~buzei
  bsa~hbkid
  bsa~zlsch
  bsa~zlspr
  bsa~ZFBDT
  bsa~zuonr                                    "agregado 30.12.2016
  INTO CORRESPONDING FIELDS OF TABLE ti_salida_bsak
  FROM bsak AS bsa INNER JOIN lfa1 AS lfa
  ON bsa~lifnr = lfa~lifnr
*      INNER JOIN zfitr020_t03 AS zf
*      ON zf~clase_doc = bsa~blart
  WHERE bsa~bukrs = p_bukrs
  AND bsa~budat < v_fecha
  AND bsa~blart IN r_blart
*      AND bsa~hkont IN r_hkont
*      AND bsa~zzmot_emis IN r_emision
  AND lfa~stcd1 = p_stcd1.

*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES01 ECDK917080 *
SORT TI_SALIDA_BSAK .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES01 ECDK917080 *
  LOOP AT ti_salida_bsak INTO wa_salida_bsak .

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*    INTO CORRESPONDING FIELDS OF wa_bsak
*    FROM bsak
*    WHERE bukrs = wa_salida_bsak-bukrs
*    AND lifnr = wa_salida_bsak-lifnr
*    AND augdt = wa_salida_bsak-augdt
*    AND augbl = wa_salida_bsak-augbl
*    AND belnr NE wa_salida_bsak-belnr
*    AND zzmot_emis IN r_emision.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
    INTO CORRESPONDING FIELDS OF wa_bsak
    FROM bsak
    WHERE bukrs = wa_salida_bsak-bukrs
    AND lifnr = wa_salida_bsak-lifnr
    AND augdt = wa_salida_bsak-augdt
    AND augbl = wa_salida_bsak-augbl
    AND belnr NE wa_salida_bsak-belnr
    AND zzmot_emis IN r_emision ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

    IF sy-subrc EQ 0.

      wa_salida_bsak-zzmot_emis = wa_bsak-zzmot_emis.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE ti_bkpf
*      FROM bkpf
*      WHERE bukrs = p_bukrs
*      AND belnr = wa_salida_bsak-belnr
*      AND gjahr = wa_salida_bsak-budat(4)
*      AND stblg = space.
*
* NEW CODE
      SELECT *

      INTO CORRESPONDING FIELDS OF TABLE ti_bkpf
      FROM bkpf
      WHERE bukrs = p_bukrs
      AND belnr = wa_salida_bsak-belnr
      AND gjahr = wa_salida_bsak-budat(4)
      AND stblg = space ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

      IF sy-subrc EQ 0.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE *
*        INTO CORRESPONDING FIELDS OF wa_payr
*        FROM payr
*        WHERE vblnr = wa_salida_bsak-belnr
*        AND gjahr = wa_salida_bsak-budat(4)
*        AND xbanc = space
*        AND voidr = space.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS 
        INTO CORRESPONDING FIELDS OF wa_payr
        FROM payr
        WHERE vblnr = wa_salida_bsak-belnr
        AND gjahr = wa_salida_bsak-budat(4)
        AND xbanc = space
        AND voidr = space ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

        IF sy-subrc EQ 0.
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE *
*            FROM bseg
*            WHERE belnr EQ wa_salida_bsak-belnr
*            AND bukrs EQ wa_salida_bsak-bukrs
*            AND gjahr EQ wa_salida_bsak-budat(4)
*            AND hkont EQ wa_payr-ubhkt
*            AND augbl EQ ''.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS 
            FROM bseg
            WHERE belnr EQ wa_salida_bsak-belnr
            AND bukrs EQ wa_salida_bsak-bukrs
            AND gjahr EQ wa_salida_bsak-budat(4)
            AND hkont EQ wa_payr-ubhkt
            AND augbl EQ '' ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

          IF sy-subrc EQ 0.

          if wa_salida_bsak-xblnr = '0'.
            wa_salida_bsak-xblnr = wa_salida_bsak-zuonr.
            modify ti_salida_bsak from wa_salida_bsak index sy-tabix.
          endif.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE glosa
*          INTO wa_salida_bsak-cambio_estado
*          FROM zfitr020_t06
*          WHERE campo = 'PAYR'.
*
* NEW CODE
          SELECT glosa
          UP TO 1 ROWS 
          INTO wa_salida_bsak-cambio_estado
          FROM zfitr020_t06
          WHERE campo = 'PAYR' ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
          wa_salida_bsak-xblnr = wa_payr-chect.
          APPEND wa_salida_bsak TO ti_salida1.
          ENDIF.
        ELSE.                                                 "-----|ini agregado 07.11.2014

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE *
*          INTO CORRESPONDING FIELDS OF wa_reguh
*          FROM reguh
*          WHERE zbukr = wa_salida_bsak-bukrs
*          AND lifnr = wa_salida_bsak-lifnr
*          AND vblnr = wa_salida_bsak-belnr
*          AND zaldt = wa_salida_bsak-budat
*          AND identif_pago NE space
*          AND ind_pago     = space
*          AND belnr_dev    = space.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS 
          INTO CORRESPONDING FIELDS OF wa_reguh
          FROM reguh
          WHERE zbukr = wa_salida_bsak-bukrs
          AND lifnr = wa_salida_bsak-lifnr
          AND vblnr = wa_salida_bsak-belnr
          AND zaldt = wa_salida_bsak-budat
          AND identif_pago NE space
          AND ind_pago     = space
          AND belnr_dev    = space ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
*            AND ind_custodia = space.

          IF sy-subrc EQ 0.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE glosa
*            INTO wa_salida_bsak-cambio_estado
*            FROM zfitr020_t06
*            WHERE campo = 'REGUH'.
*
* NEW CODE
            SELECT glosa
            UP TO 1 ROWS 
            INTO wa_salida_bsak-cambio_estado
            FROM zfitr020_t06
            WHERE campo = 'REGUH' ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
            wa_salida_bsak-xblnr = wa_reguh-identif_pago.
            APPEND wa_salida_bsak TO ti_salida1.
          ENDIF.
        ENDIF.
      ENDIF.
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
      WRITE wa_salida1-wrbtr TO wa_salida-wrbtr CURRENCY 'CLP'.  "Agregado 17.02.2015
      CONDENSE wa_salida-wrbtr NO-GAPS.
*     wa_salida-wrbtr         = wa_salida1-wrbtr.
      wa_salida-cambio_estado = wa_salida1-cambio_estado.
      wa_salida-zzmot_emis    = wa_salida1-zzmot_emis.
      wa_salida-buzei         = wa_salida1-buzei.            "agregado 15.12.2014
      wa_salida-hbkid         = wa_salida1-hbkid.
      wa_salida-zlsch         = wa_salida1-zlsch.
      wa_salida-zlspr         = wa_salida1-zlspr.
      wa_salida-fecha_pag     = wa_salida1-ZFBDT .
      APPEND wa_salida TO ti_salida.
    ENDLOOP.
  ELSE.
    mensaje = 'RUT NO TIENE DEUDA' .
  ENDIF.


*--------------------------------------------------------------------*
*--------------------------------------------------------------------*



ENDFUNCTION.
