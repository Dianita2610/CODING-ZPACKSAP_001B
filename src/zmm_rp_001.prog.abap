*&---------------------------------------------------------------------*
*& Report  ZMM_RP_001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZMM_RP_001.

*----------------------------------------------------------------------
* Declaración de Includes
*----------------------------------------------------------------------
INCLUDE zsmb40fm06top.
INCLUDE zsmb40fm06pf031.
INCLUDE zsmb40fm06pf04.
INCLUDE zsmb40fm06pf05.

*----------------------------------------------------------------------
*    Rutina de Entrada a Orden de Compra
*----------------------------------------------------------------------
FORM entry_neu USING ent_retco ent_screen.

*----------------------------------------------------------------------
* Definición de datos para configuración y emision de Pedido de Compra
*----------------------------------------------------------------------
  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  DATA: ls_print_data_to_read TYPE lbbil_print_data_to_read.
  DATA: ls_bil_invoice TYPE lbbil_invoice.
  DATA: lf_fm_name            TYPE rs38l_fnam.
  DATA: ls_control_param      TYPE ssfctrlop.
  DATA: ls_composer_param     TYPE ssfcompop.
  DATA: ls_recipient          TYPE swotobjid.
  DATA: ls_sender             TYPE swotobjid.
  DATA: lf_formname           TYPE tdsfname.
  DATA: ls_addr_key           LIKE addr_key.

  xscreen = ent_screen.

  CLEAR ent_retco.
  IF nast-aende EQ space.
    l_druvo = '1'.
  ELSE.
    l_druvo = '2'.
  ENDIF.

*--------------------------------------------------------------------
* 1.- Nombre del Formulario (SmartForm from customizing table TNAPR)
*--------------------------------------------------------------------
  IF NOT tnapr-sform IS INITIAL.
    lf_formname = tnapr-sform.
  ELSE.
    MESSAGE e001(/smb40/ssfcomposer).
  ENDIF.

*------------------------------------------------------------------
* 2.- Informacion de Configuracion de Salida ( Parametrización Funcional )
*------------------------------------------------------------------
  CALL FUNCTION 'ME_READ_PO_FOR_PRINTING'
  EXPORTING
    ix_nast        = nast
    ix_screen      = ent_screen
  IMPORTING
    ex_retco       = ent_retco
    ex_nast        = l_nast
    doc            = l_doc
  CHANGING
    cx_druvo       = l_druvo
    cx_from_memory = l_from_memory.

  CHECK ent_retco EQ 0.

  IF nast-adrnr IS INITIAL.
    PERFORM get_addr_key CHANGING ls_addr_key.
  ELSE.
    ls_addr_key = nast-adrnr.
  ENDIF.


  IF l_doc-xtkomv IS INITIAL.
    SELECT * INTO TABLE l_doc-xtkomv FROM konv
    WHERE knumv = l_doc-xekko-knumv.
  ENDIF.

*--------------------------------------------------------------------
* 3.- Configuración del Opcion de Salida del Formulario (Parametrización Funcional)
*--------------------------------------------------------------------
  PERFORM set_print_param USING     ls_addr_key
  CHANGING  ls_control_param
    ls_composer_param
    ls_recipient
    ls_sender
    ent_retco.

*--------------------------------------------------------------------
* 4.- Codigo de Funcion Smartforms donde llama el desarrollo
*--------------------------------------------------------------------
  IF ent_retco EQ 0.
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lf_formname   " Nombre Configuración
    IMPORTING
      fm_name            = lf_fm_name    " Codigo Fisico Smartforms
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
    IF sy-subrc <> 0.
      ent_retco = sy-subrc.
      IF sy-subrc = 1.
        MESSAGE e001(/smb40/ssfcomposer).
      ENDIF.
      IF sy-subrc = 2.
        MESSAGE e002(/smb40/ssfcomposer).
      ENDIF.
      PERFORM protocol_update_i.
    ENDIF.

*----------------------------------------------------------
* Lectura de Texto Largo
*----------------------------------------------------------
    DATA: t_line      LIKE tline OCCURS 0 WITH HEADER LINE.
    DATA: t_esll_1    LIKE esll OCCURS 0 WITH HEADER LINE.
    DATA: t_esll_2    LIKE esll OCCURS 0 WITH HEADER LINE.
    DATA: t_ekpo      LIKE ekpo OCCURS 0 WITH HEADER LINE.
    DATA: wa_ekpo     LIKE ekpo,
          l_frgke     LIKE ekko-frgke,
          l_glosa(25) TYPE C.
    DATA: wa_line     LIKE tline.
    DATA: l_name      LIKE thead-tdname.

    CLEAR   : t_line, l_frgke.
    REFRESH : t_line.

* ini-mod. 20110217. mgr.
    l_frgke = l_doc-xekko-frgke.

    IF l_frgke = 'B' OR
    l_frgke = 'b'.
      l_glosa = 'PENDIENTE DE APROBACIÓN'.
    ENDIF.

* fin-mod. 20110217. mgr.

*---------------------------------------------------------------------
*
*---------------------------------------------------------------------
* READ TABLE l_doc-xekpo index 1.
    CLEAR   : t_ekpo, t_esll_1, t_esll_2.
    REFRESH : t_ekpo, t_esll_1, t_esll_2.

    LOOP AT l_doc-xekpo INTO wa_ekpo.
      MOVE-corresponding wa_ekpo TO t_ekpo.
      APPEND t_ekpo.
    ENDLOOP.

    break fdiaz.
    IF sy-subrc = 0.
      SELECT * INTO TABLE t_esll_1 FROM esll
      FOR ALL entries IN t_ekpo
      WHERE  packno = t_ekpo-packno.

      READ TABLE t_esll_1 INDEX 1.
      IF sy-subrc = 0.
        SELECT * INTO TABLE t_esll_2 FROM esll
        FOR ALL entries IN t_esll_1
        WHERE  packno = t_esll_1-sub_packno.

      ENDIF.
    ENDIF.
*---------------------------------------------------------------------
* 5.- Emision Formulario de Orden de Compra
*---------------------------------------------------------------------
    IF l_glosa EQ space.

      CALL FUNCTION lf_fm_name
      EXPORTING
        archive_index      = toa_dara
        archive_parameters = arc_params
        control_parameters = ls_control_param
        mail_recipient     = ls_recipient
        mail_sender        = ls_sender
        output_options     = ls_composer_param
        zxekko             = l_doc-xekko
        zxpekko            = l_doc-xpekko
        l_glosa            = l_glosa
      TABLES
        l_xekpo            = l_doc-xekpo[]   " Posición del documento de compras
        l_xekpa            = l_doc-xekpa[]   " Funciones de interlocutor en compras
        l_xpekpo           = l_doc-xpekpo[]  " Campo auxiliar para impresión de la posición del doc-compras
        l_xeket            = l_doc-xeket[]   " Repartos del plan de entregas
        l_xtkomv           = l_doc-xtkomv[]  " Determinación precio registro de condición comunicación
        l_xekkn            = l_doc-xekkn[]   " Imputación en el documento de compras
        l_xekek            = l_doc-xekek[]   " Datos cab.órdenes entrega PE
        l_xkomk            = l_xkomk
        t_linex            = t_line          " Condiciones Orden de Compra
        t_esll1            = t_esll_1        "
        t_esll2            = t_esll_2        "
*        t_textos           = t_textos
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
      IF sy-subrc <> 0.
      ENDIF.

    ELSE.
*          message e390 with l_doc-xekko-ebeln.
      MESSAGE 'Imposible imprimir. El documento aún no ha sido liberado' TYPE 'I'.
    ENDIF.

  ENDIF.
ENDFORM.                    "entry_neu
*&---------------------------------------------------------------------*
*&      Form  set_print_param
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_ADDR_KEY  text
*      <--P_LS_CONTROL_PARAM  text
*      <--P_LS_COMPOSER_PARAM  text
*      <--P_LS_RECIPIENT  text
*      <--P_LS_SENDER  text
*      <--P_CF_RETCODE  text
*----------------------------------------------------------------------*
FORM set_print_param USING    is_addr_key LIKE addr_key
CHANGING cs_control_param TYPE ssfctrlop
  cs_composer_param TYPE ssfcompop
  cs_recipient TYPE  swotobjid
  cs_sender TYPE  swotobjid
  cf_retcode TYPE sy-subrc.

  DATA: ls_itcpo     TYPE itcpo.
  DATA: lf_repid     TYPE sy-repid.
  DATA: lf_device    TYPE tddevice.
  DATA: ls_recipient TYPE swotobjid.
  DATA: ls_sender    TYPE swotobjid.

  lf_repid = sy-repid.

  CALL FUNCTION 'WFMC_PREPARE_SMART_FORM'
  EXPORTING
    pi_nast       = nast
    pi_addr_key   = is_addr_key
    pi_repid      = lf_repid
  IMPORTING
    pe_returncode = cf_retcode
    pe_itcpo      = ls_itcpo
    pe_device     = lf_device
    pe_recipient  = cs_recipient
    pe_sender     = cs_sender.

  IF cf_retcode = 0.
    MOVE-corresponding ls_itcpo TO cs_composer_param.
    cs_control_param-device      = lf_device.
    cs_control_param-no_dialog   = 'X'.
    cs_control_param-preview     = xscreen.
    cs_control_param-getotf      = ls_itcpo-tdgetotf.
    cs_control_param-langu       = nast-spras.
  ENDIF.
ENDFORM.                    "set_print_paramCOMPRAS.
