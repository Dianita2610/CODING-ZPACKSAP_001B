FUNCTION ZFU_MM_SEND_EMAIL_PO.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(I_EKKO) TYPE  EKKO
*"  EXPORTING
*"     REFERENCE(E_SUBRC) TYPE  SYST-SUBRC
*"  TABLES
*"      IT_KOMV STRUCTURE  KOMV
*"  EXCEPTIONS
*"      NO_EXISTE_OC
*"----------------------------------------------------------------------

DATA:   l_txt            TYPE soli,
        l_size           TYPE sood-objlen,
        wa_doc_chng      TYPE sodocchgi1,
        w_smtp_addr      LIKE adr6-smtp_addr,
        w_t000           TYPE t000.

  DATA: ls_return         TYPE ssfcrescl,
        wa_otf            TYPE itcoo,
        lv_binsize        TYPE so_obj_len,
        lv_bin_file       TYPE xstring,
        it_solix_tab      TYPE solix_tab,
        lv_out_length     TYPE i,
        i_lines           LIKE tline OCCURS 0 WITH HEADER LINE,
        wa_buffer         TYPE string.

DATA:   contents_hex     TYPE           solix_tab,
        contents_txt     TYPE           soli_tab,
        i_content        TYPE           soli_tab,                      " Mail content
        ls_soli          TYPE           soli,
        l_send_request   TYPE REF TO    cl_bcs,                        " E-Mail Send Request
        l_document       TYPE REF TO    cl_document_bcs,               " E-Mail Attachment
        l_recipient      TYPE REF TO    if_recipient_bcs,              " Distribution List
        l_sender         TYPE REF TO    if_sender_bcs,                 " Address of Sender
        l_uname          TYPE           salrtdrcpt,                    " Sender Name(SY-UNAME)
        l_bcs_exception  TYPE REF TO    cx_document_bcs,               " BCS Exception
        l_addr_exception TYPE REF TO    cx_address_bcs,                " Address Exception
        l_send_exception TYPE REF TO    cx_send_req_bcs,               " E-Mail sending Exception
        lv_subject    TYPE so_obj_des.

*Class for cobining HMTL & Image
DATA : lo_mime_helper   TYPE REF TO cl_gbt_multirelated_service.

DATA: i_reclist              LIKE somlreci1          OCCURS 0 WITH HEADER LINE.
DATA: wa_ekko like ekko,

*        it_otf              LIKE itcoo OCCURS 0 WITH HEADER LINE,
        it_otf TYPE TSFOTF WITH HEADER LINE,
        ex_retco            LIKE sy-subrc.

  DATA: lt_tvarvc TYPE STANDARD TABLE OF tvarvc,
        ls_tvarvc TYPE tvarvc.

  IF i_ekko-ebeln IS INITIAL.
    RAISE no_existe_oc.
  ENDIF.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE *
*    FROM ekko
*    INTO wa_ekko
*    WHERE ebeln EQ i_ekko-ebeln.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS 
    FROM ekko
    INTO wa_ekko
    WHERE ebeln EQ i_ekko-ebeln ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

  IF sy-subrc NE 0.
    RAISE no_existe_oc.
  ELSE.

  ENDIF.

      PERFORM get_otf TABLES it_komv
                       USING i_ekko
                    CHANGING ls_return.

      CALL FUNCTION 'CONVERT_OTF'
        EXPORTING
          format                = 'PDF'
          max_linewidth         = 132
        IMPORTING
          bin_filesize          = lv_binsize
          bin_file              = lv_bin_file
        TABLES
          otf                   = ls_return-otfdata[]
          lines                 = i_lines
        EXCEPTIONS
          err_max_linewidth     = 1
          err_format            = 2
          err_conv_not_possible = 3
          err_bad_otf           = 4
          OTHERS                = 5.

*  LOOP AT i_lines.
*    TRANSLATE i_lines USING '~'.
*    CONCATENATE wa_buffer i_lines INTO wa_buffer.
*  ENDLOOP.
*
*  TRANSLATE wa_buffer USING '~'.
*
*  DO.
*    i_record = wa_buffer.
*    APPEND i_record.
*    SHIFT wa_buffer LEFT BY 255 PLACES.
*    IF wa_buffer IS INITIAL.
*      EXIT.
*    ENDIF.
*  ENDDO.

*  i_objbin[] = i_record[].

*  SELECT SINGLE *
*    FROM nast
*    WHERE kappl EQ 'EF' AND
*          objky EQ i_ekko-ebeln.
*
*  IF sy-subrc EQ 0.
*    SELECT SINGLE *
*      FROM tnapr
*      WHERE kschl EQ nast-kschl AND
*            nacha EQ nast-nacha.
*
*    IF sy-subrc EQ 0.
*      nast-nacha = '8'.
*      nast-sort1 = 'SWP'.
*
*      PERFORM (tnapr-ronam) IN PROGRAM (tnapr-pgnam) USING ex_retco ' '.
*
*      CALL FUNCTION 'READ_OTF_FROM_MEMORY'
*        EXPORTING
*          memory_key   = nast-objky
*        TABLES
*          otf          = it_otf
*        EXCEPTIONS
*          memory_empty = 1
*          OTHERS       = 2.
*
*      IF sy-subrc NE 0.
*        REFRESH it_otf.
*      ENDIF.
*    ENDIF.
*  ENDIF.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * INTO TABLE lt_tvarvc FROM tvarvc WHERE name EQ gc_copy_mail
*                                              AND low  EQ 'OC'.
*
* NEW CODE
  SELECT *
 INTO TABLE lt_tvarvc FROM tvarvc WHERE name EQ gc_copy_mail
                                              AND low  EQ 'OC' ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03
    IF sy-subrc EQ 0.
      LOOP AT lt_tvarvc INTO ls_tvarvc.
        i_reclist-receiver   = ls_tvarvc-high.
        i_reclist-rec_type   = 'U'.
        i_reclist-express    = 'X'.
        APPEND i_reclist.
      ENDLOOP.
    ENDIF.

**Accessing name and address number of a vendor
*  SELECT SINGLE name1 adrnr FROM lfa1 INTO lv_adrnr WHERE lifnr EQ wa_ekko-lifnr.
**
***Accessing mail id of a vendor
*  SELECT SINGLE smtp_addr FROM adr6 INTO i_reclist-receiver WHERE addrnumber EQ lv_adrnr.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE * FROM t000 CLIENT SPECIFIED INTO w_t000
*  WHERE mandt EQ sy-mandt.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  FROM t000 CLIENT SPECIFIED INTO w_t000
  WHERE mandt EQ sy-mandt ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

    IF w_t000-cccategory NE 'P'.
      CONCATENATE 'TESTING: OC' i_ekko-ebeln 'Liberada' INTO wa_doc_chng-obj_descr SEPARATED BY space.
    ELSE.
    " EXCECUTE CURRENT RUTINE TO GET SUPPLIER MAIL
      PERFORM get_suppliers_smtp_data USING i_ekko-lifnr
                                            'VI01'.
      CONCATENATE 'OC' i_ekko-ebeln 'Liberada' INTO wa_doc_chng-obj_descr SEPARATED BY space.
    ENDIF.

  REFRESH i_content.

  ls_soli = '<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xfa="http://www.xfa.org/schema/xfa-template/2.1/"><head></head>'.
  APPEND ls_soli TO i_content.
  CLEAR ls_soli.
  ls_soli = '<body>'.
  APPEND ls_soli TO i_content.

  IF w_t000-cccategory NE 'P'.
    ls_soli = '<b>CORREO DE PRUEBA, POR FAVOR IGNORAR</b><br><br>'.
    APPEND ls_soli TO i_content.
  ENDIF.

  ls_soli = '<p>Estimado(a),<br>'.
  APPEND ls_soli TO i_content.

  ls_soli = '<br>Junto con saludar, adjunto encontrará orden de compra para VidaIntegra. Dentro de la misma se encuentran todos los datos relacionados al envío<br>'.
  APPEND ls_soli TO i_content.

  ls_soli = '<br>Favor confirmar recepción'.
  APPEND ls_soli TO i_content.

  ls_soli = '<br><br><br>'.
  APPEND ls_soli TO i_content.

  ls_soli = '<br>Atentamente,<br>'.
  APPEND ls_soli TO i_content.


  ls_soli = '<br>Área de Abastecimiento'.
  APPEND ls_soli TO i_content.

  ls_soli = '<br>Pérez Valenzuela 1245, Providencia | Santiago, Chile'.
  APPEND ls_soli TO i_content.

  ls_soli = '<br>+56 2 2410 7400'.
  APPEND ls_soli TO i_content.

  ls_soli = '<br>abastecimiento@vidaintegra.cl</p>'.
  APPEND ls_soli TO i_content.

  CLEAR ls_soli.
  CONCATENATE '</body>' '</html>' INTO ls_soli SEPARATED BY space.
  APPEND ls_soli TO i_content.

*CREATE OBJECT lo_mime_helper.

*  CALL METHOD lo_mime_helper->set_main_html
*    EXPORTING
*      content     = i_content
*      filename    = 'message.htm'      "filename for HMTL form
*      description = 'Orden de Compra'.  "Title

*"Create HTML using BCS class and attach html and image part to it.
*  CONCATENATE 'OC' i_ekko-ebeln 'Liberada' INTO lv_subject SEPARATED BY space.
*
*  l_document = cl_document_bcs=>create_from_multirelated(
*                         i_subject          = lv_subject
*                         i_multirel_service = lo_mime_helper ).

  TRY.
      l_send_request = cl_bcs=>create_persistent( ).

      WRITE i_ekko-ebeln TO l_txt.

*      CONCATENATE 'SP'
*                   w_eban-banfn
*                  'se generó OC'
*                   w_ekko-ebeln
*        INTO wa_doc_chng-obj_descr
*        SEPARATED BY space.

      l_document = cl_document_bcs=>create_document( i_type    = 'HTM'
                                                     i_text    = i_content[]
                                                     i_subject = wa_doc_chng-obj_descr ).

      REFRESH contents_hex.

      CLEAR l_size.

      REFRESH contents_txt.

*      it_otf = ls_return-otfdata[].

      LOOP AT ls_return-otfdata INTO wa_otf. " it_otf.
        l_txt = wa_otf.

        APPEND l_txt TO contents_txt.

        l_size = l_size + strlen( l_txt ).
      ENDLOOP.

      CONCATENATE 'OC'
                  i_ekko-ebeln
        INTO lv_subject
        SEPARATED BY space.

      CALL METHOD l_document->add_attachment
        EXPORTING
          i_attachment_type    = 'OTF'
          i_attachment_size    = l_size
          i_attachment_subject = lv_subject
          i_att_content_text   = contents_txt[].

      CALL METHOD l_send_request->set_document( l_document ).

*      l_uname  = " sy-uname.            " Change here the sender!!!!!!!!!!!!
*      l_sender = cl_sapuser_bcs=>create( l_uname ).

      l_sender = cl_cam_address_bcs=>create_internet_address( 'abastecimiento@vidaintegra.cl' ).

      CALL METHOD l_send_request->set_sender
        EXPORTING
          i_sender = l_sender.

* / set suppliers as recipient

      LOOP AT gt_knvk.
        w_smtp_addr = gt_knvk-smtp_addr.

        l_recipient = cl_cam_address_bcs=>create_internet_address( w_smtp_addr ).

        CALL METHOD l_send_request->add_recipient
          EXPORTING
            i_recipient  = l_recipient
            i_express    = 'X'.
      ENDLOOP.

* / set user list from varset...

      LOOP AT i_reclist.
        w_smtp_addr = i_reclist-receiver.

        l_recipient = cl_cam_address_bcs=>create_internet_address( w_smtp_addr ).

        CALL METHOD l_send_request->add_recipient
          EXPORTING
            i_recipient  = l_recipient
            i_express    = ' '
            i_copy       = 'X'
            i_blind_copy = ' '
            i_no_forward = ' '.
      ENDLOOP.

      l_send_request->set_send_immediately( ' ' ).

      CALL METHOD l_send_request->send( ).

      e_subrc = sy-subrc.

      COMMIT WORK.

    CATCH cx_document_bcs INTO l_bcs_exception.

    CATCH cx_send_req_bcs INTO l_send_exception.

    CATCH cx_address_bcs  INTO l_addr_exception.

    CATCH cx_sy_file_open cx_sy_codepage_converter_init cx_sy_conversion_codepage cx_sy_file_authority cx_sy_pipes_not_supported cx_sy_too_many_files.

  ENDTRY.

ENDFUNCTION.
