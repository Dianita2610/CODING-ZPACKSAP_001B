*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
* Nombre Programa : ZFI_CARGA_BAPI_FB01
* Descripción     : Creación de documentos contable a partir de archivo
*---------------------------------------------------------------------*
* Objetivo        :
*---------------------------------------------------------------------*
* Creado por      : VIsionOne.
* Creado en fecha : 19.02.2013
*---------------------------------------------------------------------*
REPORT  zfi_carga_bapi_fb01 LINE-SIZE 250.
* Tablas y estructuras de transferencia para docs. contables.
* -----------------------------------------------------------
TABLES: bgr00,                         " Registro de juego de datos
        bbkpf,                         " Datos de cabecera BTCI
        bbseg, " Datos de segmento de doc. (incl. datos CpD, datos COBL)
        d020s, " Tabla de sistema D020S (sources de dynpro)
        mara.  " Datos generales maestro materiales

* Definición de variables y tablas internas.
* ------------------------------------------
FIELD-SYMBOLS <f>.
DATA:
*FICHERO   LIKE RLGRAP-FILENAME,
      cont(3) TYPE n VALUE 0,
      cierre VALUE 'F'.
DATA: BEGIN OF t_reg_entrada OCCURS 0,
* BKPF
          bukrs   LIKE bbkpf-bukrs,
          belnr1  LIKE bbkpf-belnr,
          blart   LIKE bbkpf-blart,
          waers   LIKE bbkpf-waers,
          kursf   LIKE bbkpf-kursf,
          bldat   LIKE bbkpf-bldat,  "FECHA
          budat   LIKE bbkpf-budat,  "FECHA
          bktxt   LIKE bbkpf-bktxt,
          xblnr   LIKE bbkpf-xblnr,
          xref2_hd LIKE bkpf-xref2_hd,
          newbs   LIKE bbseg-newbs, "Clave Contab
          newko   LIKE bbseg-newko, "hkont,
          wrbtr   LIKE bbseg-wrbtr,  "VALOR
          dmbtr   LIKE bbseg-dmbtr,  "VALOR
          dmbe2   LIKE bbseg-dmbe2,  "Importe moneda Loc 2
          dmbe3   LIKE bbseg-dmbe3,  "Importe moneda Loc 3
          zuonr   LIKE bbseg-zuonr,  "ASIGNACION
          valut   LIKE bbseg-valut,  "FECHA
          sgtxt   LIKE bbseg-sgtxt,  "texto
          kostl   LIKE bbseg-kostl,  "CeCo
          prctr   LIKE bbseg-prctr,  "CeBe
          aufnr   LIKE bbseg-aufnr,  "Num Orden
          projk   LIKE bbseg-projk,  "Proyecto.
          hkont   LIKE bbseg-hkont,  "Cuenta de mayor
          zfbdt   LIKE bbseg-zfbdt,  "Fecha Base
          newum   LIKE bbseg-newum,  "CME
          pprct   LIKE bbseg-pprct,  "CeBE
          mwskz   LIKE bbseg-mwskz,  "Indicador IVA
          gsber   LIKE bbseg-gsber,  "Division
          xref1   LIKE bbseg-xref1,  "Referencia 1
          xref2   LIKE bbseg-xref2,  "Referencia 2
          xref3   LIKE bbseg-xref3,  "Referencia 2
          zterm   LIKE bbseg-zterm,  "Cond.Pago
          zbd1t   LIKE bbseg-zbd1t,  "dias pago
          zlsch   LIKE bbseg-zlsch,   "via de Pago
          segment LIKE bbseg-segment, "Segmento
          lifnr   LIKE bseg-lifnr,    "Cta.Tercero
          hbkid   LIKE bbseg-hbkid,   "Bco.Propio
          hktid   LIKE bbseg-hktid,   "ID cuenta
          augbl   LIKE bseg-augbl,  "documento de compensacion
          zzprestac   LIKE bbseg-zzprestac,
          zzunid_pro  LIKE bbseg-zzunid_pro,
          zzdesc_est  LIKE bbseg-zzdesc_est,
          zzmot_emis  LIKE bbseg-zzmot_emis,
          zzrut_terc  LIKE bseg-zzrut_terc,
          zz_agencia  LIKE bseg-zz_agencia,
          stcd1 TYPE lfa1-stcd1,
          stcd2 TYPE kna1-stcd1,
          kunnr TYPE kna1-kunnr,
          rut_tercero TYPE lfa1-stcd1, "Rut tercero
       END   OF t_reg_entrada.

DATA  cabecera LIKE t_reg_entrada.
DATA  strarq       TYPE string.

DATA: jobcount           LIKE tbtcjob-jobcount,
      jobname(32)        TYPE c,
      l_datum            LIKE sy-datum,
      l_uzeit            LIKE sy-uzeit,
      l_hora_prev        LIKE sy-uzeit,
      strtimmed          LIKE btch0000-char1,
      tit_job(30)        TYPE c.

DATA: wa_header TYPE bapiache09,
      ti_currency TYPE TABLE OF bapiaccr09,
      wa_currency TYPE bapiaccr09,
      ti_accountgl TYPE TABLE OF bapiacgl09,
      wa_accountgl TYPE bapiacgl09,
      ti_payable TYPE TABLE OF bapiacap09,
      wa_payable TYPE bapiacap09,
      ti_deudor TYPE TABLE OF bapiacar09 ,
      wa_deudor TYPE bapiacar09 ,
      ti_extension1 TYPE TABLE OF bapiacextc,
      wa_extension1 TYPE bapiacextc,
      ti_return TYPE TABLE OF bapiret2,
      wa_return TYPE bapiret2.

DATA: objtype TYPE bapiache09-obj_type,
      objkey TYPE bapiache09-obj_key,
      objsys TYPE bapiache09-obj_sys,
      conta TYPE i.

*DATA: ti_log TYPE TABLE OF bdcmsgcoll,
*      wa_log TYPE bdcmsgcoll.

DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
*       messages of call transaction
DATA:   messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
*       error session opened (' ' or 'X')
DATA:   e_group_opened.

DATA: ctumode TYPE c VALUE 'N',
      cupdate TYPE c VALUE 'L'.
TYPES : BEGIN OF t_balmi,
      msgty TYPE balmi-msgty,
      msgid TYPE balmi-msgid,
      msgno TYPE balmi-msgno,
      msgv1 TYPE char100,
      msgv2  TYPE char100,
      msgv3  TYPE char100,
      msgv4  TYPE char100,
      altext TYPE balmi-altext,
      userexitp TYPE balmi-userexitp,
      userexitf TYPE balmi-userexitf,
      detlevel TYPE balmi-detlevel,
      probclass TYPE balmi-probclass,
      alsort TYPE balmi-alsort,
      END OF t_balmi.

DATA:  ti_log        TYPE TABLE OF t_balmi,
       wa_log        TYPE t_balmi.

* Definición de Parámetros.
* -------------------------
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.

PARAMETER: p_local RADIOBUTTON GROUP a1 DEFAULT 'X' USER-COMMAND cmd,
           p_serv RADIOBUTTON GROUP a1.
SELECTION-SCREEN END   OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-001.
PARAMETER:    fichero LIKE rlgrap-filename MODIF ID a1
              DEFAULT 'C:\Asiento_GL.txt',
              servidor  LIKE rlgrap-filename MODIF ID b1
              DEFAULT '/interfaces/paso/asientos' .
SELECTION-SCREEN END   OF BLOCK bl2.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR fichero.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = fichero
      def_path         = 'c:\'
      mask             = ',*.*,*.*.'
      mode             = 'O'
      title            = 'Directorio de Datos'
    IMPORTING
      filename         = fichero
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.


AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 EQ 'A1'.
      IF NOT p_local IS INITIAL.
        screen-active = 1.
      ELSE.
        screen-active = 0.
      ENDIF.
    ELSEIF screen-group1 EQ 'B1'.
      IF NOT p_local IS INITIAL.
        screen-active = 0.
      ELSE.
        screen-active = 1.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

**---------------------------------------------------------------------
**- Inicio Programa Principal -----------------------------------------
**---------------------------------------------------------------------
START-OF-SELECTION.
* -> Tratamiento Archivo de Entrada
  IF NOT p_local IS INITIAL
 AND fichero IS INITIAL.
    MESSAGE s398(00) WITH 'Favor ingresar fichero' DISPLAY LIKE 'E'.
    EXIT.
  ELSEIF NOT p_serv IS INITIAL
   AND servidor IS INITIAL.
    MESSAGE s398(00) WITH 'Favor ingresar fichero' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.


  PERFORM input_local.
  PERFORM armar_datos.
  IF NOT ti_log[] IS INITIAL.
    PERFORM mostrar_log.
  ENDIF.

*** -> Subrutinas (FORM)
***-----------------------------------------------------------------***
***-- Inicio Subrutinas --------------------------------------------***
***-----------------------------------------------------------------***

*---------------------------------------------------------------------*
*       FORM INIT_NODATA                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  TABLA                                                         *
*---------------------------------------------------------------------*
FORM init_nodata USING tabla.
  DATA: c_acumu TYPE i.
  DO.
    ADD 1 TO c_acumu.
    ASSIGN COMPONENT c_acumu OF STRUCTURE tabla TO <f>.
    IF sy-subrc NE 0. EXIT. ENDIF.
    MOVE '/' TO <f>.
  ENDDO.
ENDFORM.                    "INIT_NODATA

*---------------------------------------------------------------------*
*       FORM CHECK_FIELD                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM check_field.
  DATA: c_acumu TYPE i.

  DO.
    ADD 1 TO c_acumu.
    ASSIGN COMPONENT c_acumu OF STRUCTURE t_reg_entrada TO <f>.
    IF sy-subrc NE 0. EXIT. ENDIF.
    IF <f> IS INITIAL.
      MOVE '/' TO <f>.
    ENDIF.
  ENDDO.

* Formatear fechas para batch-input
  CONCATENATE t_reg_entrada-bldat+6(2)                      "Dia
              t_reg_entrada-bldat+4(2)                      "Mes
              t_reg_entrada-bldat(4)   "Año
  INTO t_reg_entrada-bldat.

  CONCATENATE t_reg_entrada-budat+6(2)                      "Dia
              t_reg_entrada-budat+4(2)                      "Mes
              t_reg_entrada-budat(4)   "Año
  INTO t_reg_entrada-budat.

  CONCATENATE t_reg_entrada-zfbdt+6(2)                      "Dia
              t_reg_entrada-zfbdt+4(2)                      "Mes
              t_reg_entrada-zfbdt(4)   "Año
  INTO t_reg_entrada-zfbdt.

  CONCATENATE t_reg_entrada-valut+6(2)                      "Dia
              t_reg_entrada-valut+4(2)                      "Mes
              t_reg_entrada-valut(4)   "Año
  INTO t_reg_entrada-valut.


ENDFORM.                    "CHECK_FIELD
*&---------------------------------------------------------------------*
*&      Form  CABECERA
*&---------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cabecera USING cont.
*  PERFORM init_nodata USING bbkpf.
*  MOVE-CORRESPONDING cabecera TO bbkpf.
*  MOVE: '1'    TO bbkpf-stype,
*        'FB01' TO bbkpf-tcode.
*
*  TRANSFER bbkpf TO pa_file4.
*  cont = 1. cierre = 'F'.
ENDFORM.                               " CABECERA

*&---------------------------------------------------------------------*
*&      Form  POSICION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM posicion.
*  DATA: w_wrbtr LIKE glt0-tslvt."bseg-wrbtr.
*  CLEAR: w_wrbtr.
*
*  PERFORM init_nodata USING bbseg.
*  MOVE: '2'     TO bbseg-stype,
*        'BBSEG' TO bbseg-tbnam.
*
*  MOVE-CORRESPONDING cabecera TO bbseg.
*
*  TRANSFER bbseg TO pa_file4.
ENDFORM.                               " POSICION

*&---------------------------------------------------------------------*
*&      Form  input_local
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM input_local .
  DATA: cadena TYPE string.
  IF NOT p_local IS INITIAL.
    strarq = fichero.

    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename                = strarq
        filetype                = 'ASC'
        has_field_separator     = 'X'
      TABLES
        data_tab                = t_reg_entrada
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        OTHERS                  = 17.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    strarq = servidor.
    DATA: tab TYPE c.
    tab = cl_abap_char_utilities=>horizontal_tab.
    OPEN DATASET strarq FOR INPUT ENCODING DEFAULT IN TEXT MODE.
    IF sy-subrc EQ 0.
      DO.
        READ DATASET strarq INTO cadena.
        IF sy-subrc EQ 0.
          CLEAR t_reg_entrada.
          SPLIT cadena AT tab
                INTO t_reg_entrada-bukrs
                     t_reg_entrada-belnr1
                     t_reg_entrada-blart
                     t_reg_entrada-waers
                     t_reg_entrada-kursf
                     t_reg_entrada-bldat
                     t_reg_entrada-budat
                     t_reg_entrada-bktxt
                     t_reg_entrada-xblnr
                     t_reg_entrada-xref2_hd
                     t_reg_entrada-newbs
                     t_reg_entrada-newko
                     t_reg_entrada-wrbtr
                     t_reg_entrada-dmbtr
                     t_reg_entrada-dmbe2
                     t_reg_entrada-dmbe3
                     t_reg_entrada-zuonr
                     t_reg_entrada-valut
                     t_reg_entrada-sgtxt
                     t_reg_entrada-kostl
                     t_reg_entrada-prctr
                     t_reg_entrada-aufnr
                     t_reg_entrada-projk
                     t_reg_entrada-hkont
                     t_reg_entrada-zfbdt
                     t_reg_entrada-newum
                     t_reg_entrada-pprct
                     t_reg_entrada-mwskz
                     t_reg_entrada-gsber
                     t_reg_entrada-xref1
                     t_reg_entrada-xref2
                     t_reg_entrada-xref3
                     t_reg_entrada-zterm
                     t_reg_entrada-zbd1t
                     t_reg_entrada-zlsch
                     t_reg_entrada-segment
                     t_reg_entrada-lifnr
                     t_reg_entrada-hbkid
                     t_reg_entrada-hktid
                     t_reg_entrada-augbl
                     t_reg_entrada-zzprestac
                     t_reg_entrada-zzunid_pro
                     t_reg_entrada-zzdesc_est
                     t_reg_entrada-zzmot_emis
                     t_reg_entrada-zzrut_terc
                     t_reg_entrada-zz_agencia
                     t_reg_entrada-stcd1
                     t_reg_entrada-stcd2
                     t_reg_entrada-kunnr
                     t_reg_entrada-rut_tercero.
          APPEND t_reg_entrada.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.
    ELSE.
      MESSAGE e398(00) WITH
      'No se encuentra archivo en la ruta indicada'.
    ENDIF.
  ENDIF.
ENDFORM.                    " input_local

*&---------------------------------------------------------------------*
*&      Form  ARMAR_DATOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM armar_datos .
  DATA: indicador TYPE tbsl-shkzg,
        doc_compens TYPE bsad-augbl,
        xref2_hd TYPE bkpf-xref2_hd,
        emision TYPE bseg-zzmot_emis,
        agencia TYPE bseg-zz_agencia,
        rut_terc TYPE bseg-zzrut_terc,
        prestacion TYPE bseg-zzprestac,
        unid_pro TYPE bseg-zzunid_pro,
        desc_est TYPE bseg-zzdesc_est.

  LOOP AT t_reg_entrada.
    MOVE t_reg_entrada TO cabecera.
    AT NEW belnr1.
      CLEAR: wa_header, objtype, objsys, objkey, conta, doc_compens,
             emision, agencia, xref2_hd, rut_terc, unid_pro, desc_est,
             prestacion.
      REFRESH: ti_accountgl, ti_payable, ti_currency, ti_deudor,
               ti_return.
***cabecera de documento por cada nuevo grupo
      wa_header-username    = sy-uname.    "Usuario
      wa_header-bus_act     = 'RFBU'.      "Tipo de operación
      wa_header-header_txt  = cabecera-bktxt."Texto cabecera
      wa_header-comp_code   = cabecera-bukrs. "Sociedad
      wa_header-doc_date    = cabecera-bldat. "Fecha de documento
      wa_header-pstng_date  = cabecera-budat. "Fecha contable
      wa_header-trans_date  = cabecera-budat. "Fecha de conversion
      wa_header-fisc_year   = cabecera-budat(4).  "Ejercicio
      wa_header-fis_period  = cabecera-budat+4(2)."Periodo
      wa_header-doc_type    = cabecera-blart .    "Clase de documento
      wa_header-ref_doc_no  = cabecera-xblnr."Referencia

      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = 50
          text       = 'Procesando datos'.


      CLEAR wa_log.
      wa_log-msgid = '00'.
      wa_log-msgno = 398.
      wa_log-msgty = 'S'.
      CONCATENATE 'Log Documento' cabecera-belnr1 cabecera-bukrs
      cabecera-blart INTO
      wa_log-msgv1  SEPARATED BY space.
      APPEND wa_log TO ti_log.

    ENDAT.

    IF NOT t_reg_entrada-stcd1 IS INITIAL.
      CLEAR t_reg_entrada-lifnr.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE lifnr
*        INTO t_reg_entrada-lifnr
*        FROM lfa1
*        WHERE stcd1 EQ t_reg_entrada-stcd1.
*
* NEW CODE
      SELECT lifnr
      UP TO 1 ROWS 
        INTO t_reg_entrada-lifnr
        FROM lfa1
        WHERE stcd1 EQ t_reg_entrada-stcd1 ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
    ENDIF.

    IF NOT t_reg_entrada-stcd2 IS INITIAL.
      CLEAR t_reg_entrada-kunnr.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE kunnr
*        INTO t_reg_entrada-kunnr
*        FROM kna1
*        WHERE stcd1 EQ t_reg_entrada-stcd2.
*
* NEW CODE
      SELECT kunnr
      UP TO 1 ROWS 
        INTO t_reg_entrada-kunnr
        FROM kna1
        WHERE stcd1 EQ t_reg_entrada-stcd2 ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
    ENDIF.

    IF NOT t_reg_entrada-rut_tercero IS INITIAL.
      CLEAR t_reg_entrada-zzrut_terc.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE lifnr
*        INTO t_reg_entrada-zzrut_terc
*        FROM lfa1
*        WHERE stcd1 EQ t_reg_entrada-rut_tercero.
*
* NEW CODE
      SELECT lifnr
      UP TO 1 ROWS 
        INTO t_reg_entrada-zzrut_terc
        FROM lfa1
        WHERE stcd1 EQ t_reg_entrada-rut_tercero ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
    ENDIF.

    ADD 1 TO conta.
***Cuenta acreedor
    IF NOT t_reg_entrada-lifnr IS INITIAL.
      PERFORM acreedor USING conta.

***Cuenta deudor
    ELSEIF NOT t_reg_entrada-kunnr IS INITIAL.
      PERFORM deudor USING conta.

***Cuenta mayor
    ELSE.
      PERFORM account_gl USING conta.
    ENDIF.

    IF NOT t_reg_entrada-augbl IS INITIAL.
      doc_compens = t_reg_entrada-augbl.
    ENDIF.

    IF NOT t_reg_entrada-xref2_hd IS INITIAL.
      xref2_hd = t_reg_entrada-xref2_hd.
    ENDIF.

    CLEAR indicador.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE shkzg
*      INTO indicador
*      FROM tbsl
*      WHERE bschl EQ t_reg_entrada-newbs.
*
* NEW CODE
    SELECT shkzg
    UP TO 1 ROWS 
      INTO indicador
      FROM tbsl
      WHERE bschl EQ t_reg_entrada-newbs ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

    PERFORM currency USING conta indicador.

    PERFORM extension USING conta t_reg_entrada-newbs
                                  t_reg_entrada-zzprestac
                                  t_reg_entrada-zzunid_pro
                                  t_reg_entrada-zzdesc_est
                                  t_reg_entrada-zzmot_emis
                                  t_reg_entrada-zzrut_terc
                                  t_reg_entrada-zz_agencia.

    AT END OF belnr1.
      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST' "#EC CI_USAGE_OK[2438131]
        EXPORTING
          documentheader    = wa_header
        IMPORTING
          obj_type          = objtype
          obj_key           = objkey
          obj_sys           = objsys
        TABLES
          accountgl         = ti_accountgl
          accountreceivable = ti_deudor
          accountpayable    = ti_payable
          currencyamount    = ti_currency
          extension1        = ti_extension1
          return            = ti_return.
      CLEAR conta.
      conta = STRLEN( objkey ).
      IF conta >= 18.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
        READ TABLE ti_return INTO wa_return WITH KEY id = 'RW'
                                                     number = '605'.
        IF sy-subrc EQ 0.
          CLEAR wa_log.
          wa_log-msgid = wa_return-id.
          wa_log-msgno = wa_return-number.
          wa_log-msgty = wa_return-type.
          wa_log-msgv1 = wa_return-message_v1.
          wa_log-msgv2 = wa_return-message_v2.
          wa_log-msgv3 = wa_return-message_v3.
          wa_log-msgv4 = wa_return-message_v4.
          APPEND wa_log TO ti_log.

          IF NOT doc_compens IS INITIAL.
            PERFORM batch_fb02 USING objkey(10)
                                     objkey+10(4)
                                     objkey+14(4)
                                     doc_compens
                                     xref2_hd.
          ENDIF.
        ENDIF.
      ELSE.
        LOOP AT ti_return INTO wa_return.
          CLEAR wa_log.
          wa_log-msgid = wa_return-id.
          wa_log-msgno = wa_return-number.
          wa_log-msgty = wa_return-type.
          IF wa_log-msgty = 'E'.
            wa_log-msgno = 398.
            wa_log-msgid = '00'.
          ENDIF.

          wa_log-msgv1 = wa_return-message.
          CONCATENATE 'Doc' cabecera-belnr1 '-' wa_log-msgv1
          INTO wa_log-msgv1 SEPARATED BY space.
          APPEND wa_log TO ti_log.
        ENDLOOP.
      ENDIF.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " ARMAR_DATOS
*&---------------------------------------------------------------------*
*&      Form  ACCOUNT_GL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONTA  text
*      -->P_T_REG_ENTRADA  text
*----------------------------------------------------------------------*
FORM account_gl USING p_conta.
  CLEAR wa_accountgl.
  wa_accountgl-itemno_acc  = p_conta. "Posicion
  wa_accountgl-gl_account  = t_reg_entrada-hkont."Cuenta mayor
  wa_accountgl-costcenter  = t_reg_entrada-kostl."centro costo
  wa_accountgl-item_text   = t_reg_entrada-sgtxt."Texto de posicion
  wa_accountgl-doc_type    = t_reg_entrada-blart."Clase de documento
  wa_accountgl-comp_code   = t_reg_entrada-bukrs."Sociedad
  wa_accountgl-fis_period  = t_reg_entrada-budat+4(2)."Periodo
  wa_accountgl-fisc_year   = t_reg_entrada-budat(4).   "Ejercicio
  wa_accountgl-pstng_date  = t_reg_entrada-budat."Fecha contable
  wa_accountgl-value_date  = t_reg_entrada-valut."Fecha valor
  wa_accountgl-alloc_nmbr  = t_reg_entrada-zuonr."Asignación
  wa_accountgl-bus_area    = t_reg_entrada-gsber."División
  wa_accountgl-orderid     = t_reg_entrada-aufnr."Orden
  wa_accountgl-profit_ctr  = t_reg_entrada-prctr."cebe
  wa_accountgl-wbs_element = t_reg_entrada-projk."PEP
  wa_accountgl-segment     = t_reg_entrada-segment."Segmento
  wa_accountgl-tax_code    = t_reg_entrada-mwskz."Indicador IVA
  wa_accountgl-acct_type   = 'S'.                      "Clase de cuenta
  APPEND wa_accountgl TO  ti_accountgl.
ENDFORM.                    " ACCOUNT_GL
*&---------------------------------------------------------------------*
*&      Form  ACREEDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONTA  text
*----------------------------------------------------------------------*
FORM acreedor  USING    p_conta.
  CLEAR wa_payable.
  wa_payable-itemno_acc = p_conta. "Posicion
  wa_payable-vendor_no  = t_reg_entrada-lifnr."Proveedor
  wa_payable-gl_account = t_reg_entrada-hkont."Cuenta mayor
  wa_payable-ref_key_1 = t_reg_entrada-xref1.               "Clave ref1
  wa_payable-ref_key_2 = t_reg_entrada-xref2.               "Clave ref2
  wa_payable-ref_key_3 = t_reg_entrada-xref3.               "Clave ref3
  wa_payable-comp_code = t_reg_entrada-bukrs. "Sociedad
  wa_payable-bus_area  = t_reg_entrada-gsber. "Division
  wa_payable-pmnttrms  = t_reg_entrada-zterm. "Cond. pago
  wa_payable-bline_date = t_reg_entrada-zfbdt."Fecha base
  wa_payable-dsct_days1 = t_reg_entrada-zbd1t.              "Dias  1
  wa_payable-alloc_nmbr = t_reg_entrada-zuonr."Asignacion
  wa_payable-item_text  = t_reg_entrada-sgtxt."Texto posicion
  wa_payable-pymt_meth  = t_reg_entrada-zlsch."Via de pago
  wa_payable-sp_gl_ind  = t_reg_entrada-newum."CME
  wa_payable-bank_id    = t_reg_entrada-hbkid."Clave de banco
  wa_payable-tax_Code   = t_reg_entrada-mwskz.
  wa_payable-housebankacctid = t_reg_entrada-hktid.
  APPEND wa_payable TO ti_payable.
ENDFORM.                    " ACREEDOR
*&---------------------------------------------------------------------*
*&      Form  CURRENCY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONTA  text
*----------------------------------------------------------------------*
FORM currency  USING    p_conta p_shkzg.
  CLEAR wa_currency.
  wa_currency-itemno_acc = p_conta.
  wa_currency-curr_type  = '00'.
  wa_currency-currency   = t_reg_entrada-waers.
  REPLACE ALL OCCURRENCES OF '.' IN t_reg_entrada-wrbtr WITH space.
  wa_currency-amt_doccur = t_reg_entrada-wrbtr.
  IF p_shkzg EQ 'H'.
    wa_currency-amt_doccur = wa_currency-amt_doccur * -1.
  ENDIF.
  APPEND wa_currency TO ti_currency.
ENDFORM.                    " CURRENCY

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  CLEAR bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval.
  APPEND bdcdata.
ENDFORM.                    "BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  BATCH_FB02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OBJKEY(10)  text
*      -->P_OBJKEY+10(4)  text
*      -->P_OBJKEY+14(4)  text
*----------------------------------------------------------------------*
FORM batch_fb02  USING    p_belnr
                          p_bukrs
                          p_gjahr
                          p_augbl
                          p_xref2_hd.


  REFRESH : bdcdata, messtab.
  PERFORM bdc_dynpro      USING 'SAPMF05L' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'RF05L-BELNR'
                                p_belnr.
  PERFORM bdc_field       USING 'RF05L-BUKRS'
                                p_bukrs.
  PERFORM bdc_field       USING 'RF05L-GJAHR'
                                p_gjahr.

  PERFORM bdc_dynpro      USING 'SAPMF05L' '0700'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=VK'.
  PERFORM bdc_dynpro      USING 'SAPMF05L' '1710'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'BKPF-XREF1_HD'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTR'.
  PERFORM bdc_field       USING 'BKPF-XREF1_HD'
                                p_augbl.
  PERFORM bdc_field       USING 'bkpf-xref2_hd'
                                p_xref2_hd.

  PERFORM bdc_dynpro      USING 'SAPMF05L' '0700'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'BKPF-BELNR'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=AE'.

  CALL TRANSACTION 'FB02' USING bdcdata
                 MODE   ctumode
                 UPDATE cupdate
                 MESSAGES INTO messtab.
ENDFORM.                    " BATCH_FB02

*&---------------------------------------------------------------------*
*&      Form  BATCH_FB02_CAMPOSZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OBJKEY(10)  text
*      -->P_OBJKEY+10(4)  text
*      -->P_OBJKEY+14(4)  text
*      -->P_EMISION  text
*      -->P_AGENCIA  text
*----------------------------------------------------------------------*
FORM batch_fb02_camposz  USING    p_belnr
                                  p_bukrs
                                  p_gjahr
                                  p_emision
                                  p_agencia.
  REFRESH : bdcdata, messtab.
  PERFORM bdc_dynpro  USING 'SAPMF05L' '0100'.
  PERFORM bdc_field   USING 'BDC_OKCODE'
                            '/00'.
  PERFORM bdc_field   USING 'RF05L-BELNR'
                            p_belnr.
  PERFORM bdc_field   USING 'RF05L-BUKRS'
                            p_bukrs.
  PERFORM bdc_field   USING 'RF05L-GJAHR'
                            p_gjahr.

  PERFORM bdc_dynpro  USING 'SAPMF05L' '0700'.
  PERFORM bdc_field   USING 'BDC_CURSOR'
                            'RF05L-ANZDT(01)'.
  PERFORM bdc_field   USING 'BDC_OKCODE'
                            '=PK'.

  PERFORM bdc_dynpro  USING 'SAPMF05L'  '0302'.
  PERFORM bdc_field   USING 'BDC_OKCODE'
                            '=ZK'.

  PERFORM bdc_dynpro  USING 'SAPMF05L'  '1302'.
  PERFORM bdc_field   USING 'BDC_OKCODE'  '=ENTR'.
  PERFORM bdc_field   USING 'BSEG-ZZMOT_EMIS'	p_emision.
  PERFORM bdc_field   USING 'BSEG-ZZ_AGENCIA'	p_agencia.

  PERFORM bdc_dynpro  USING 'SAPMF05L'   '0302'.
  PERFORM bdc_field   USING 'BDC_OKCODE' '=AE'.
ENDFORM.                    " BATCH_FB02_CAMPOSZ

*&---------------------------------------------------------------------*
*&      Form  MOSTRAR_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mostrar_log .
  DATA: lf_obj        TYPE balobj_d,
        lf_subobj     TYPE balsubobj,
        ls_header     TYPE balhdri,
        lf_log_handle TYPE balloghndl,
        lf_log_number TYPE balognr,
        lt_lognum     TYPE TABLE OF balnri,
        ls_lognum     TYPE balnri.

  lf_obj     = 'ZFI_LOG'.
  lf_subobj  = 'Z01'.

  ls_header-object     = lf_obj.
  ls_header-subobject  = lf_subobj.
  ls_header-aldate     = sy-datum.
  ls_header-altime     = sy-uzeit.
  ls_header-aluser     = sy-uname.
  ls_header-aldate_del = sy-datum + 1.
*

  CALL FUNCTION 'APPL_LOG_WRITE_HEADER'
    EXPORTING
      header              = ls_header
    IMPORTING
      e_log_handle        = lf_log_handle
    EXCEPTIONS
      object_not_found    = 1
      subobject_not_found = 2
      error               = 3
      OTHERS              = 4.

  IF sy-subrc EQ 0.
    CALL FUNCTION 'BAL_DB_LOGNUMBER_GET'
      EXPORTING
        i_client                 = sy-mandt
        i_log_handle             = lf_log_handle
      IMPORTING
        e_lognumber              = lf_log_number
      EXCEPTIONS
        log_not_found            = 1
        lognumber_already_exists = 2
        numbering_error          = 3
        OTHERS                   = 4.
    IF sy-subrc EQ 0.
      CALL FUNCTION 'APPL_LOG_WRITE_MESSAGES'
        EXPORTING
          object              = lf_obj
          subobject           = lf_subobj
          log_handle          = lf_log_handle
        TABLES
          messages            = ti_log
        EXCEPTIONS
          object_not_found    = 1
          subobject_not_found = 2
          OTHERS              = 3.

      MOVE-CORRESPONDING ls_header TO ls_lognum.
      ls_lognum-lognumber = lf_log_number.
      APPEND ls_lognum TO lt_lognum.

      CALL FUNCTION 'APPL_LOG_WRITE_DB'
        EXPORTING
          object                = lf_obj
          subobject             = lf_subobj
          log_handle            = lf_log_handle
        TABLES
          object_with_lognumber = lt_lognum
        EXCEPTIONS
          object_not_found      = 1
          subobject_not_found   = 2
          internal_error        = 3
          OTHERS                = 4.
      CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'.
    ENDIF.
  ENDIF.
ENDFORM.                    " MOSTRAR_LOG
*&---------------------------------------------------------------------*
*&      Form  EXTENSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONTA  text
*----------------------------------------------------------------------*
FORM extension  USING    p_conta
                         p_bschl
                         p_prestacion
                         p_unid
                         p_desc_est
                         p_emision
                         p_rut
                         p_agencia.

***Se usará la función ZINTERFACE_RWBAPI01
  DATA: posicion TYPE bseg-buzei.
  CLEAR wa_extension1.
  posicion = p_conta.
  wa_extension1-field1 = posicion.
  CONCATENATE wa_extension1-field1
              'BSCHL'
              p_bschl
              INTO wa_extension1-field1.
  APPEND wa_extension1 TO ti_extension1.

  IF NOT p_prestacion IS INITIAL.
    CLEAR wa_extension1.
    posicion = p_conta.
    wa_extension1-field1 = posicion.
    CONCATENATE wa_extension1-field1
                'ZZPRESTAC'
                p_prestacion
                INTO wa_extension1-field1.
    APPEND wa_extension1 TO ti_extension1.
  ENDIF.

  IF NOT p_unid IS  INITIAL.
    CLEAR wa_extension1.
    posicion = p_conta.
    wa_extension1-field1 = posicion.
    CONCATENATE wa_extension1-field1
                'ZZUNID_PRO'
                p_unid
                INTO wa_extension1-field1.
    APPEND wa_extension1 TO ti_extension1.
  ENDIF.

  IF NOT p_desc_est IS INITIAL.
    CLEAR wa_extension1.
    posicion = p_conta.
    wa_extension1-field1 = posicion.
    CONCATENATE wa_extension1-field1
                'ZZDESC_EST'
                p_desc_est
                INTO wa_extension1-field1.
    APPEND wa_extension1 TO ti_extension1.
  ENDIF.

  IF NOT p_emision IS INITIAL.
    CLEAR wa_extension1.
    posicion = p_conta.
    wa_extension1-field1 = posicion.
    CONCATENATE wa_extension1-field1
                'ZZMOT_EMIS'
                p_emision
                INTO wa_extension1-field1.
    APPEND wa_extension1 TO ti_extension1.
  ENDIF.

  IF NOT p_rut IS INITIAL.
    CLEAR wa_extension1.
    posicion = p_conta.
    wa_extension1-field1 = posicion.
    CONCATENATE wa_extension1-field1
                'ZZRUT_TERC'
                p_rut
                INTO wa_extension1-field1.
    APPEND wa_extension1 TO ti_extension1.
  ENDIF.

  IF NOT p_agencia IS INITIAL.
    CLEAR wa_extension1.
    posicion = p_conta.
    wa_extension1-field1 = posicion.
    CONCATENATE wa_extension1-field1
                'ZZ_AGENCIA'
                p_agencia
                INTO wa_extension1-field1.
    APPEND wa_extension1 TO ti_extension1.
  ENDIF.
ENDFORM.                    " EXTENSION
*&---------------------------------------------------------------------*
*&      Form  DEUDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONTA  text
*----------------------------------------------------------------------*
FORM deudor  USING    p_conta.
  CLEAR wa_deudor.
  wa_deudor-itemno_acc = p_conta. "Posicion
  wa_deudor-customer = t_reg_entrada-kunnr.  "Cliente
  wa_deudor-gl_account = t_reg_entrada-hkont."Cuenta mayor
  wa_deudor-ref_key_1 = t_reg_entrada-xref1. "Clave ref1
  wa_deudor-ref_key_2 = t_reg_entrada-xref2. "Clave ref2
  wa_deudor-ref_key_3 = t_reg_entrada-xref3. "Clave ref3
  wa_deudor-comp_code = t_reg_entrada-bukrs. "Sociedad
  wa_deudor-bus_area  = t_reg_entrada-gsber. "Division
  wa_deudor-pmnttrms  = t_reg_entrada-zterm. "Cond. pago
  wa_deudor-bline_date = t_reg_entrada-zfbdt."Fecha base
  wa_deudor-dsct_days1 = t_reg_entrada-zbd1t."Dias  1
  wa_deudor-alloc_nmbr = t_reg_entrada-zuonr."Asignacion
  wa_deudor-item_text  = t_reg_entrada-sgtxt."Texto posicion
  wa_deudor-pymt_meth  = t_reg_entrada-zlsch."Via de pago
  wa_deudor-sp_gl_ind  = t_reg_entrada-newum."CME
  wa_deudor-profit_ctr = t_reg_entrada-prctr."Cebe
  wa_deudor-bank_id         = t_reg_entrada-hbkid.
  wa_deudor-housebankacctid = t_reg_entrada-hktid.
  wa_deudor-tax_Code   = t_reg_entrada-mwskz.
  APPEND wa_deudor TO ti_deudor.
ENDFORM.                    " DEUDOR
