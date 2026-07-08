*&---------------------------------------------------------------------*
*& Report  ZFI_PAGO_SIN_COBRO
*&
*&---------------------------------------------------------------------*
*&
*& La logica de este programa es identica a la de el modulo de  funcion
*& Z_PAGOS por lo tanto si se modifica este programa, tambien se debe
*& modificar Z_PAGOS.
*&---------------------------------------------------------------------*

REPORT  zfi_pago_sin_cobro.

TABLES: bsid, kna1, zmot_emis, bseg, lfa1.

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
  buzei           LIKE bsik-buzei,
END OF ty_salida.

DATA: ti_lfa1             TYPE TABLE OF lfa1,
      wa_lfa1             TYPE lfa1,
      ti_zmot_emis        TYPE TABLE OF zmot_emis,
      wa_zmot_emis        TYPE zmot_emis,
      ti_bsik             TYPE TABLE OF bsik,
      ti_bsak             TYPE TABLE OF bsak,
      ti_bkpf             TYPE TABLE OF bkpf,
      ti_payr             TYPE TABLE OF payr,
      ti_salida           TYPE TABLE OF ty_salida,
      ti_salida_bsak      TYPE TABLE OF ty_salida,
      wa_bsik             TYPE bsik,
      wa_bsak             TYPE bsak,
      wa_bkpf             TYPE bkpf,
      wa_payr             TYPE payr,
      wa_reguh            TYPE reguh,                               "agregado 07.11.2014
      wa_salida           TYPE ty_salida,
      wa_salida_bsak      TYPE ty_salida,
      v_valor             TYPE zfitr020_t04-valor,
      v_fecha             TYPE sy-datum.

RANGES: r_hkont           FOR bsik-hkont .
DATA:   wa_hkont          LIKE LINE OF r_hkont .
RANGES: r_emision         FOR zmot_emis-zzmot_emis .
DATA:   wa_emision        LIKE LINE OF r_emision .
RANGES: r_blart           FOR bsad-blart .
DATA:  wa_blart           LIKE LINE OF r_blart .

DATA: gr_table      TYPE REF TO cl_salv_table.
DATA: gr_events     TYPE REF TO cl_salv_events_table.
DATA: gr_functions  TYPE REF TO cl_salv_functions.
DATA: gr_selections TYPE REF TO cl_salv_selections.
DATA: gr_display    TYPE REF TO cl_salv_display_settings.
DATA: gr_columns    TYPE REF TO cl_salv_columns_table.
DATA: gr_column     TYPE REF TO cl_salv_column_table.
DATA: gr_sorts      TYPE REF TO cl_salv_sorts.
DATA: gr_agg        TYPE REF TO cl_salv_aggregations.
DATA: gr_filter     TYPE REF TO cl_salv_filters.
DATA: gr_layout     TYPE REF TO cl_salv_layout.

DATA: color TYPE lvc_s_colo.
DATA: key   TYPE salv_s_layout_key.

DATA: lr_column  TYPE REF TO cl_salv_column_table,
      lr_columns TYPE REF TO cl_salv_columns.
FIELD-SYMBOLS <tabla> TYPE ANY TABLE.


*----------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
    on_user_command FOR EVENT added_function OF cl_salv_events
    IMPORTING e_salv_function.
    METHODS:
    on_double_click FOR EVENT double_click OF cl_salv_events_table
    IMPORTING row column.

ENDCLASS.     "lcl_handle_events DEFINITION
DATA: event_handler TYPE REF TO lcl_handle_events.
*----------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_user_command.
    DATA: lr_selections TYPE REF TO cl_salv_selections.
    DATA: lt_rows TYPE salv_t_row.
    DATA: ls_rows TYPE i.
    DATA: message TYPE string.

    CASE e_salv_function.

      WHEN 'MYFUNCTION'.
*        lr_selections = gr_table->get_selections( ).
*        lt_rows = lr_selections->get_selected_rows( ).
*        READ TABLE lt_rows INTO ls_rows INDEX 1.
*        READ TABLE ti_salida INTO wa_salida INDEX ls_rows.
**        CONCATENATE xspfli-carrid xspfli-connid
**           xspfli-cityfrom xspfli-cityto
**             INTO message SEPARATED BY space.
*
*        MESSAGE i001(00) WITH 'You pushed the button!' message.

    ENDCASE.
  ENDMETHOD. "on_user_command endclass.
  METHOD on_double_click.
    DATA: message TYPE string.
    DATA: row_c(4) TYPE c.
    DATA: column_c(4) TYPE c.

    READ TABLE ti_salida INTO wa_salida INDEX row.
    IF column = 'BELNR'. " CLIENTE es el nombre en la tabla interna de la columna del avl mostrado
      SET PARAMETER ID 'BLN' FIELD wa_salida-belnr.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
    ENDIF.

  ENDMETHOD.                    "on_double_click

ENDCLASS.                    "lcl_handle_events IMPLEMENTATION

SELECTION-SCREEN BEGIN OF BLOCK uno WITH FRAME TITLE text-001.
PARAMETERS:         p_bukrs   LIKE  bsid-bukrs.
SELECT-OPTIONS:     p_stcd1   FOR  kna1-stcd1 NO INTERVALS MODIF ID A.
SELECT-OPTIONS:     p_lifnr   FOR  lfa1-lifnr NO INTERVALS MODIF ID B.
SELECTION-SCREEN END OF BLOCK uno.

*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
PARAMETERS: p_A RADIOBUTTON GROUP rad1 USER-COMMAND ACT DEFAULT 'X',
p_B RADIOBUTTON GROUP rad1.

AT SELECTION-SCREEN OUTPUT.
LOOP AT SCREEN.
  IF p_A = 'X'.
    IF SCREEN-group1 = 'B'.
      SCREEN-active = 0.
    ENDIF.
ELSEIF p_B = 'X'.
    IF SCREEN-group1 = 'A'.
      SCREEN-active = 0.
    ENDIF.
  ENDIF.

  MODIFY SCREEN.
ENDLOOP.
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*

INITIALIZATION.

  PERFORM armar_rangos.

START-OF-SELECTION.

  PERFORM buscar_datos.
  PERFORM despliega_alv.
*&---------------------------------------------------------------------*
*&      Form  BUSCAR_DATOS
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM buscar_datos .

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
*  WHERE REPORT = 'X'.
*
* NEW CODE
  SELECT cta_cadf cta_cade cta_pres_h

  INTO CORRESPONDING FIELDS OF TABLE ti_zmot_emis
  FROM zmot_emis
  WHERE REPORT = 'X' ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03


  if p_A eq 'X'.

*obtengo acreedor
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT lifnr
*  INTO CORRESPONDING FIELDS OF TABLE ti_lfa1
*  FROM lfa1
*  WHERE stcd1 IN p_stcd1.
*
* NEW CODE
  SELECT lifnr

  INTO CORRESPONDING FIELDS OF TABLE ti_lfa1
  FROM lfa1
  WHERE stcd1 IN p_stcd1 ORDER BY PRIMARY KEY.

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
  bs~buzei
*         zf~cambio_estado
  bs~zzmot_emis
  INTO CORRESPONDING FIELDS OF TABLE ti_salida
  FROM bsik AS bs INNER JOIN lfa1 AS lf
  ON bs~lifnr = lf~lifnr
*    INNER JOIN zfitr020_t03 AS zf
*    ON zf~clase_doc = bs~blart
  WHERE bs~bukrs = p_bukrs
  AND bs~budat < v_fecha
  AND bs~hkont IN r_hkont
  AND bs~zzmot_emis IN r_emision
  AND lf~stcd1 IN p_stcd1.

  endif.
  IF p_B eq 'X'.

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
    bs~buzei
*         zf~cambio_estado
    bs~zzmot_emis
    INTO CORRESPONDING FIELDS OF TABLE ti_salida
    FROM bsik AS bs INNER JOIN lfa1 AS lf
    ON bs~lifnr = lf~lifnr
    WHERE bs~bukrs = p_bukrs
    AND bs~lifnr IN p_lifnr
    AND bs~budat < v_fecha
    AND bs~hkont IN r_hkont
    AND bs~zzmot_emis IN r_emision.

  ENDIF.

  LOOP AT ti_salida INTO wa_salida .

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*    FROM zmot_emis
*    WHERE cta_cadf = wa_salida-hkont.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
    FROM zmot_emis
    WHERE cta_cadf = wa_salida-hkont ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

    IF sy-subrc EQ 0.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE glosa
*      INTO wa_salida-cambio_estado
*      FROM zfitr020_t06
*      WHERE campo = 'CTA_CADF'.
*
* NEW CODE
      SELECT glosa
      UP TO 1 ROWS 
      INTO wa_salida-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_CADF' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
      MODIFY ti_salida FROM wa_salida INDEX sy-tabix.
    ENDIF.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*    FROM zmot_emis
*    WHERE cta_cade = wa_salida-hkont.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
    FROM zmot_emis
    WHERE cta_cade = wa_salida-hkont ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

    IF sy-subrc EQ 0.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE glosa
*      INTO wa_salida-cambio_estado
*      FROM zfitr020_t06
*      WHERE campo = 'CTA_CADE'.
*
* NEW CODE
      SELECT glosa
      UP TO 1 ROWS 
      INTO wa_salida-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_CADE' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
      MODIFY ti_salida FROM wa_salida INDEX sy-tabix.
    ENDIF.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*    FROM zmot_emis
*    WHERE cta_pres_h = wa_salida-hkont.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
    FROM zmot_emis
    WHERE cta_pres_h = wa_salida-hkont ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

    IF sy-subrc EQ 0.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE glosa
*      INTO wa_salida-cambio_estado
*      FROM zfitr020_t06
*      WHERE campo = 'CTA_PRES_H'.
*
* NEW CODE
      SELECT glosa
      UP TO 1 ROWS 
      INTO wa_salida-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_PRES_H' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
      MODIFY ti_salida FROM wa_salida INDEX sy-tabix.
    ENDIF.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*    FROM zmot_emis
*    WHERE cta_cadvv = wa_salida-hkont.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
    FROM zmot_emis
    WHERE cta_cadvv = wa_salida-hkont ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

    IF sy-subrc EQ 0.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE glosa
*      INTO wa_salida-cambio_estado
*      FROM zfitr020_t06
*      WHERE campo = 'CTA_CADVV'.
*
* NEW CODE
      SELECT glosa
      UP TO 1 ROWS 
      INTO wa_salida-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_CADVV' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
      MODIFY ti_salida FROM wa_salida INDEX sy-tabix.
    ENDIF.

  ENDLOOP.

if p_A eq 'X'.
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
  AND lfa~stcd1 IN p_stcd1.
endif.
if p_B eq 'X'.

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
    INTO CORRESPONDING FIELDS OF TABLE ti_salida_bsak
    FROM bsak AS bsa INNER JOIN lfa1 AS lfa
    ON bsa~lifnr = lfa~lifnr
    WHERE bsa~bukrs = p_bukrs
    AND bsa~lifnr IN p_lifnr
    AND bsa~budat < v_fecha
    AND bsa~blart IN r_blart.

ENDIF.

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

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE *
*          FROM bseg
*          WHERE belnr EQ wa_salida_bsak-belnr
*          AND bukrs EQ wa_salida_bsak-bukrs
*          AND gjahr EQ wa_salida_bsak-budat(4)
*          AND hkont EQ wa_payr-ubhkt
*          AND augbl EQ ''.
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


* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE glosa
*            INTO wa_salida_bsak-cambio_estado
*            FROM zfitr020_t06
*            WHERE campo = 'PAYR'.                               
*
* NEW CODE
            SELECT glosa
            UP TO 1 ROWS 
            INTO wa_salida_bsak-cambio_estado
            FROM zfitr020_t06
            WHERE campo = 'PAYR' ORDER BY PRIMARY KEY.                               

            ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01"modificado 07.11.2014

            wa_salida_bsak-xblnr = wa_payr-chect.

            APPEND wa_salida_bsak TO ti_salida.
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
            APPEND wa_salida_bsak TO ti_salida.
          ENDIF.                                             "-----|fin agregado 07.11.2014

        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF ti_salida IS INITIAL.
    MESSAGE : 'RUT NO TIENE DEUDA' TYPE 'I'.
*leave SCREEN.
  ENDIF.

ENDFORM.                    " BUSCAR_DATOS
*&---------------------------------------------------------------------*
*&      Form  ARMAR_RANGOS
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM armar_rangos .

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *
*  INTO CORRESPONDING FIELDS OF TABLE ti_zmot_emis
*  FROM zmot_emis
*  WHERE report = 'X'.
*
* NEW CODE
  SELECT *

  INTO CORRESPONDING FIELDS OF TABLE ti_zmot_emis
  FROM zmot_emis
  WHERE report = 'X' ORDER BY PRIMARY KEY.

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

ENDFORM.                    " ARMAR_RANGOS
*&---------------------------------------------------------------------*
*&      Form  DESPLIEGA_ALV
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM despliega_alv .

  "no necesita structura de datos si se asigna el field symbol
  ASSIGN ti_salida[] TO <tabla>[].
  TRY.
      cl_salv_table=>factory(
      IMPORTING r_salv_table = gr_table
      CHANGING  t_table      = <tabla>[] ).
    CATCH cx_salv_msg.                                  "#EC NO_HANDLER
  ENDTRY.

*  "copiar status gui de function group SALV_METADATA_STATUS
*  "and copy the gui status SALV_TABLE_STANDARD into the program.
*  "se80 -> grupo de funciones -> status gui ->boton derecho copiar
*  gr_table->set_screen_status(
*    pfstatus      = 'SALV_TABLE_STANDARD'
*    report        = sy-repid
*    set_functions = gr_table->c_functions_all ).

**... optimize the column widths
  TRY.
      lr_columns = gr_table->get_columns( ).
      lr_columns->set_optimize( 'X' ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.


  gr_events = gr_table->get_event( ).

  CREATE OBJECT event_handler.
  SET HANDLER event_handler->on_user_command FOR gr_events.
  SET HANDLER event_handler->on_double_click FOR gr_events.
*  set HANDLER event_handler->MOSTRARDATOS.

*  * Set up selections.
  gr_selections = gr_table->get_selections( ).
  "none(0) Single(1) multiple (2) cell selection(3) row_column(4)
  gr_selections->set_selection_mode( 2 ).

* Habilita las funciones del alv
  gr_functions = gr_table->get_functions( ).
  gr_functions->set_all( abap_true ).

  TRY.
      gr_columns = gr_table->get_columns( ).
      gr_column ?= gr_columns->get_column( 'WRBTR' ).       gr_column->set_currency_column( 'WAERS' ).
    CATCH cx_salv_not_found.
  ENDTRY.

  gr_display = gr_table->get_display_settings( ).
  gr_display->set_striped_pattern( cl_salv_display_settings=>true ).
  gr_display->set_list_header( 'PAGOS PENDIENTES DE COBRO' ).

*  gr_table->set_screen_status( pfstatus = 'SALV_TABLE_STANDARD2'        "Agregado 09.10.2014
*  REPORT = sy-repid                                                     "agregado
*  set_functions = gr_table->c_functions_all ).                          "agregado

  DATA: nfilas(5) TYPE c.
  DATA: nfilas1 TYPE i.
  DESCRIBE TABLE ti_salida LINES  nfilas1.
  MOVE nfilas1 TO nfilas.
  DATA: vl_texto(25) TYPE c.
  CONCATENATE 'Número de filas' nfilas INTO vl_texto SEPARATED BY space.
  MESSAGE vl_texto TYPE 'S'.



*  TRY.
*    gr_columns = gr_table->get_columns( ).
*    gr_column ?= gr_columns->get_column( 'STCD1' ). gr_column->set_long_text( '' ). gr_column->set_medium_text( 'Rut' ). gr_column->set_short_text( '' ).
*    gr_column ?= gr_columns->get_column( 'KTOKD' ). gr_column->set_long_text( '' ). gr_column->set_medium_text( 'Tipo Rut' ). gr_column->set_short_text( '' ).
*    gr_column ?= gr_columns->get_column( 'BUKRS' ). gr_column->set_long_text( '' ). gr_column->set_medium_text( 'Sociedad' ). gr_column->set_short_text( '' ).
*    gr_column ?= gr_columns->get_column( 'HKONT' ). gr_column->set_long_text( '' ). gr_column->set_medium_text( 'Cta Sap' ). gr_column->set_short_text( '' ).
*    gr_column ?= gr_columns->get_column( 'KUNNR' ). gr_column->set_long_text( '' ). gr_column->set_medium_text( 'ID Maestro' ). gr_column->set_short_text( '' ).
*    gr_column ?= gr_columns->get_column( 'BELNR' ). gr_column->set_long_text( '' ). gr_column->set_medium_text( 'Doc Sap' ). gr_column->set_short_text( '' ).
*    gr_column ?= gr_columns->get_column( 'BUDAT' ). gr_column->set_long_text( '' ). gr_column->set_medium_text( 'Fch Doc' ). gr_column->set_short_text( '' ).
*    gr_column ?= gr_columns->get_column( 'BLART' ). gr_column->set_long_text( '' ). gr_column->set_medium_text( 'Clase Doc' ). gr_column->set_short_text( '' ).
*    gr_column ?= gr_columns->get_column( 'XBLNR' ). gr_column->set_long_text( '' ). gr_column->set_medium_text( 'Doc Pago' ). gr_column->set_short_text( '' ).
*    gr_column ?= gr_columns->get_column( 'WRBTR' ). gr_column->set_long_text( '' ). gr_column->set_medium_text( 'Importe' ). gr_column->set_short_text( '' ).
*    gr_column ?= gr_columns->get_column( 'WAERS' ). gr_column->set_long_text( '' ). gr_column->set_medium_text( 'Moneda' ). gr_column->set_short_text( '' ).
*    gr_column ?= gr_columns->get_column( 'ESTADO' ). gr_column->set_long_text( '' ). gr_column->set_medium_text( 'Tipo DocEst' ). gr_column->set_short_text( '' ).
*    gr_column ?= gr_columns->get_column( 'PROCESO' ). gr_column->set_long_text( '' ). gr_column->set_medium_text( 'Motivo Giro' ). gr_column->set_short_text( '' ).
*  CATCH cx_salv_not_found.
*  ENDTRY."SET_COLOR

*  "si se  requiere cambiar los textos de alguna columna.
  TRY.
      gr_columns = gr_table->get_columns( ).
      gr_column ?= gr_columns->get_column( 'XBLNR' ).
      gr_column->set_long_text( 'Documento Pago' ).
      gr_column->set_medium_text( 'Documento Pago' ).
      gr_column->set_short_text( 'Doc Pago' ).
    CATCH cx_salv_not_found.
  ENDTRY.
  TRY.
      gr_columns = gr_table->get_columns( ).
      gr_column ?= gr_columns->get_column( 'CAMBIO_ESTADO' ).
      gr_column->set_long_text( 'Estado' ).
      gr_column->set_medium_text( 'Estado' ).
      gr_column->set_short_text( 'Estado' ).
    CATCH cx_salv_not_found.
  ENDTRY.

**  oculta columnas
  TRY.
      lr_column ?= lr_columns->get_column( 'WAERS' ).
      lr_column->set_technical( abap_true ). " <<-- si es TECHNICAL NO se puede ver de ninguna forma

      lr_column ?= lr_columns->get_column( 'DFAELL' ).
      lr_column->set_visible( abap_false ). "<<-- si es VISIBLE FALSE se puede mostrar usando el boton de editar layout

    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column ?= lr_columns->get_column( 'AUGDT' ).
      lr_column->set_technical( abap_true ). " <<-- si es TECHNICAL NO se puede ver de ninguna forma

      lr_column ?= lr_columns->get_column( 'DFAELL' ).
      lr_column->set_visible( abap_false ). "<<-- si es VISIBLE FALSE se puede mostrar usando el boton de editar layout

    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.
  TRY.
      lr_column ?= lr_columns->get_column( 'AUGBL' ).
      lr_column->set_technical( abap_true ). " <<-- si es TECHNICAL NO se puede ver de ninguna forma

      lr_column ?= lr_columns->get_column( 'DFAELL' ).
      lr_column->set_visible( abap_false ). "<<-- si es VISIBLE FALSE se puede mostrar usando el boton de editar layout

    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.
*  TRY.
*      gr_column ?= gr_columns->get_column( 'WAERS' ).
*      gr_column->set_visible(abap_false).
*    CATCH cx_salv_not_found .
*  ENDTRY.
*
*  "pinta la columna
*  gr_column ?= gr_columns->get_column( 'CITYFROM' ).
*  color-col = '6'.
*  color-int = '1'.
*  color-inv = '0'.
*  gr_column->set_color( color ).
*  try.
*  gr_sorts = gr_table->get_sorts( ).
*  gr_sorts->add_sort( columnname = 'CITYTO' subtotal = abap_true ).
*  gr_agg = gr_table->get_aggregations( ).
*
*  gr_agg->add_aggregation( 'DISTANCE' ).
*  catch cx_salv_not_found cx_salv_existing cx_salv_data_error.
*  endtry.

*  gr_filter = gr_table->get_filters( ).
*  gr_filter->add_filter( columnname = 'CARRID' low = 'LH' ).
*
*  gr_layout = gr_table->get_layout( ).
*  key-report = sy-repid.
*  gr_layout->set_key( key ).
*
*  gr_layout->set_save_restriction( cl_salv_layout=>restrict_none ).
  "despliega el alv



  gr_table->display( ).

ENDFORM.                    " DESPLIEGA_ALV
