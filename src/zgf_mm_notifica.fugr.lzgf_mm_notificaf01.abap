*----------------------------------------------------------------------*
***INCLUDE LZGF_MM_NOTIFICAF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  call_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_otf TABLES tab_komv STRUCTURE komv
              USING p_ekko TYPE ekko
           CHANGING p_return TYPE ssfcrescl
                  .

  DATA: ls_ctrl_param TYPE ssfctrlop,
        ls_output_opt TYPE ssfcompop,
        lv_druvo      TYPE druvo VALUE '1'.

  DATA: ls_ekko  TYPE ekko,
        ls_pekko TYPE pekko.

  DATA: lt_ekpo  TYPE STANDARD TABLE OF ekpo,
        lt_ekpa  TYPE STANDARD TABLE OF ekpa,
        lt_pekpo TYPE STANDARD TABLE OF pekpo,
        lt_eket  TYPE STANDARD TABLE OF eket,
        lt_komv  TYPE STANDARD TABLE OF komv,
        lt_ekkn	 TYPE STANDARD TABLE OF ekkn,
        lt_ekek	 TYPE STANDARD TABLE OF ekek,
        lt_komk	 TYPE STANDARD TABLE OF komk.

  DATA: fname         TYPE tdsfname VALUE 'ZMMSF_OC',
        v_form_name   TYPE rs38l_fnam.

  IF p_ekko-ebeln IS NOT INITIAL.

* Get data to print form

*  SELECT SINGLE * FROM ekko INTO ls_ekko WHERE ebeln = p_ebeln.
    SELECT * FROM ekpo INTO TABLE lt_ekpo WHERE ebeln = p_ekko-ebeln.
*--------------------------------------------------------------------*

    ls_ctrl_param-no_dialog = 'X'.
    ls_ctrl_param-device    = 'PRINTER'.
    ls_output_opt-tddest    = 'LOCL'.
    ls_ctrl_param-getotf    = 'X'.
    ls_ctrl_param-preview   = space.
    ls_output_opt-tdnoprint = 'X'.

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = fname
      IMPORTING
        fm_name            = v_form_name
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.

    CALL FUNCTION v_form_name
      EXPORTING
        control_parameters = ls_ctrl_param
        output_options     = ls_output_opt
        user_settings      = ' '
        is_ekko            = p_ekko
        is_pekko           = ls_pekko
        iv_druvo           = lv_druvo
      IMPORTING
        job_output_info    = p_return
      TABLES
        it_ekpo	           = lt_ekpo
        it_ekpa	           = lt_ekpa
        it_pekpo           = lt_pekpo
        it_eket	           = lt_eket
        it_tkomv           = tab_komv
        it_ekkn	           = lt_ekkn
        it_ekek	           = lt_ekek
        it_komk	           = lt_komk
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    MESSAGE s000(fb) WITH text-t01 DISPLAY LIKE 'W'.
  ENDIF.

ENDFORM.                    " call_form

*&---------------------------------------------------------------------*
*&      Form  get_suppliers_smtp_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PA_LIFNR   text
*      -->PA_ABTNR   text
*----------------------------------------------------------------------*
FORM get_suppliers_smtp_data USING pa_lifnr TYPE lifnr
                                   pa_abtnr TYPE abtnr.

  SELECT a~parnr a~name1 a~prsnr b~smtp_addr INTO TABLE gt_knvk
      FROM knvk AS a INNER JOIN adr6 AS b ON a~prsnr = b~persnumber
    WHERE a~abtnr = pa_abtnr
      AND a~lifnr = pa_lifnr.

ENDFORM.                    "get_suppliers_smtp_data

*&---------------------------------------------------------------------*
*&      Form  get_otf_hes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ESLL     text
*      -->P_EKKO     text
*      -->P_ESSR     text
*      -->P_RETURN   text
*----------------------------------------------------------------------*
FORM get_otf_hes TABLES p_esll STRUCTURE ml_esll
                  USING p_ekko TYPE ekko
                        p_essr TYPE uessr
               CHANGING p_return TYPE ssfcrescl
                  .

  DATA: ls_ctrl_param TYPE ssfctrlop,
        ls_output_opt TYPE ssfcompop,
        lv_druvo      TYPE druvo VALUE '1'.

  DATA: ls_ekko TYPE ekko.

  DATA: fname       TYPE tdsfname VALUE 'ZMMSF_HES',
        v_form_name TYPE rs38l_fnam,
        ls_essr     TYPE essr.

  IF p_essr-lblni IS NOT INITIAL.
    MOVE-CORRESPONDING p_essr TO ls_essr.

    DATA: lt_ekpo	      TYPE STANDARD TABLE	OF ekpo,
          lt_ekpa	      TYPE STANDARD TABLE	OF ekpa,
          lt_pekpo      TYPE STANDARD TABLE OF pekpo,
          lt_eket	      TYPE STANDARD TABLE	OF eket,
          lt_tkomv      TYPE STANDARD TABLE OF komv,
          lt_ekkn	      TYPE STANDARD TABLE	OF ekkn,
          lt_ekek	      TYPE STANDARD TABLE	OF ekek,
          lt_komk	      TYPE STANDARD TABLE	OF komk,
          lt_gliederung	TYPE STANDARD TABLE	OF ml_esll.

* Get data to print form

*   SELECT * FROM ekpo INTO TABLE lt_ekpo WHERE ebeln = p_ekko-ebeln.
*--------------------------------------------------------------------*

    ls_ctrl_param-no_dialog = 'X'.
    ls_ctrl_param-device    = 'PRINTER'.
    ls_output_opt-tddest    = 'LOCL'.
    ls_ctrl_param-getotf    = 'X'.
    ls_ctrl_param-preview   = space.
    ls_output_opt-tdnoprint = 'X'.

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = fname
      IMPORTING
        fm_name            = v_form_name
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.

    CALL FUNCTION v_form_name
      EXPORTING
        control_parameters = ls_ctrl_param
        output_options     = ls_output_opt
        user_settings      = ' '
        is_ekko            = p_ekko
        is_essr            = ls_essr
      IMPORTING
        job_output_info    = p_return
      TABLES
        it_ekpo            = lt_ekpo
        it_ekpa            = lt_ekpa
        it_pekpo           = lt_pekpo
        it_eket            = lt_eket
        it_tkomv           = lt_tkomv
        it_ekkn            = lt_ekkn
        it_ekek            = lt_ekek
        it_komk            = lt_komk
        it_leistung        = p_esll[]
        it_gliederung      = lt_gliederung
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    MESSAGE s000(fb) WITH text-t02 DISPLAY LIKE 'W'.
  ENDIF.

ENDFORM.                    " call_form
