*&---------------------------------------------------------------------*
*&  Include           ZXM06U44
*&---------------------------------------------------------------------*
*Data Declaration
DATA : rel_ind LIKE i_ekko-frgke,
       lv_subrc LIKE sy-subrc.

RANGES tcode FOR sy-tcode.
REFRESH tcode.
tcode-option = 'EQ'.
tcode-sign = 'I'.
tcode-low = 'ZMM07'.
APPEND tcode.
tcode-low = 'ME29N'.
APPEND tcode.

rel_ind = i_ekko-frgke.
*Release PO when final authorized person process PO
*IF sy-tcode EQ 'ME29N' AND rel_ind EQ 2.
IF sy-tcode IN tcode AND rel_ind EQ 2.
  CLEAR rg_bsart_mail.
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * INTO TABLE gt_tvarvc FROM tvarvc WHERE name = gc_bsart_mail.
*
* NEW CODE
  SELECT *
 INTO TABLE gt_tvarvc FROM tvarvc WHERE name = gc_bsart_mail ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03
  IF sy-subrc EQ 0.
    LOOP AT gt_tvarvc INTO gs_tvarvc.
      rg_bsart_mail-sign   = 'I'.
      rg_bsart_mail-option = 'EQ'.
      rg_bsart_mail-low = gs_tvarvc-low.
      APPEND rg_bsart_mail.
    ENDLOOP.
  ENDIF.

  IF i_ekko-bsart IN rg_bsart_mail.

    CALL FUNCTION 'ZFU_MM_SEND_EMAIL_PO'
      EXPORTING
        i_ekko       = i_ekko
      IMPORTING
        e_subrc      = lv_subrc
      TABLES
        it_komv      = xkomv
      EXCEPTIONS
        no_existe_oc = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.


**Internal table to get vendor name and address number
*  DATA : BEGIN OF it_vname OCCURS 0,
*         name1 LIKE lfa1-name1,
*         adrnr LIKE lfa1-adrnr,
*         END OF it_vname.
**Internal table to get email_if with address number
*  DATA : BEGIN OF it_vemail OCCURS 0,
*         email LIKE adr6-smtp_addr,
*         END OF it_vemail.
**Emiail subject
*  DATA : psubject(40) TYPE c .
*
**Data declaration for mail FM
*  DATA:   it_packing_list LIKE sopcklsti1 OCCURS 0 WITH HEADER LINE,
*          it_contents LIKE solisti1 OCCURS 0 WITH HEADER LINE,
*          it_receivers LIKE somlreci1 OCCURS 0 WITH HEADER LINE,
*          it_attachment LIKE solisti1 OCCURS 0 WITH HEADER LINE,
*          gd_cnt TYPE i,
*          gd_sent_all(1) TYPE c,
*          gd_doc_data LIKE sodocchgi1,
*          gd_error TYPE sy-subrc.
*
**Internal table for message body
*  DATA:   it_message TYPE STANDARD TABLE OF solisti1 INITIAL SIZE 0
*                  WITH HEADER LINE,
*          it_messagewa LIKE LINE OF it_message        .
*
*  psubject = 'PO Regarding'.
*
**Accessing name and address number of a vendor
**  SELECT SINGLE name1 adrnr FROM lfa1 INTO it_vname WHERE lifnr EQ
**i_ekko-lifnr.
**
***Accessing mail id of a vendor
**  SELECT SINGLE smtp_addr FROM adr6 INTO it_vemail WHERE addrnumber EQ
**it_vname-adrnr.
*
*it_vemail-email = 'scalderon@sclconsultores.com'.
*
** Mail Text
*  CLEAR it_message.
*  REFRESH it_message.
*  CONCATENATE 'Estimado' it_vname-name1 ',' INTO it_messagewa SEPARATED BY
*space.
*  APPEND  it_messagewa TO it_message.
**  APPEND 'Please issue the items for the following PO Number .' TO
**it_message.
*  CLEAR it_messagewa.
*  CONCATENATE 'Orden de Compra liberada: ' i_ekko-ebeln  INTO it_messagewa SEPARATED BY space.
**  APPEND it_messagewa TO it_message.
**  APPEND 'you can view it at www.mindteck/sap/mm/login.' TO it_message.
*  APPEND 'Saludos,' TO it_message.
**  APPEND 'Anand.' TO it_message.
*
** Fill the document data.
*  gd_doc_data-doc_size = 1.
*
** Populate the subject/generic message attributes
*  gd_doc_data-obj_langu = sy-langu.
*  gd_doc_data-obj_name  = 'SAPRPT'.
*  gd_doc_data-obj_descr = psubject.
*  gd_doc_data-sensitivty = 'F'.
*
** Describe the body of the message
*  CLEAR it_packing_list.
*  REFRESH it_packing_list.
*  it_packing_list-transf_bin = space.
*  it_packing_list-head_start = 1.
*  it_packing_list-head_num = 0.
*  it_packing_list-body_start = 1.
*  DESCRIBE TABLE it_message LINES it_packing_list-body_num.
*  it_packing_list-doc_type = 'RAW'.
*  APPEND it_packing_list.
*
** Add the recipients email address
*  CLEAR it_receivers.
*  REFRESH it_receivers.
*  it_receivers-receiver = it_vemail-email.
*  it_receivers-rec_type = 'U'.
*  it_receivers-com_type = 'INT'.
*  it_receivers-notif_del = 'X'.
*  it_receivers-notif_ndel = 'X'.
*  APPEND it_receivers.
*
** Call the FM to post the message to SAPMAIL
*  CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
*    EXPORTING
*      document_data                    = gd_doc_data
*      put_in_outbox                    = 'X'
*      commit_work                      = 'X'
*   IMPORTING
*     sent_to_all                      = gd_sent_all
**   NEW_OBJECT_ID                    =
*    TABLES
*      packing_list                     = it_packing_list
**   OBJECT_HEADER                    =
**   CONTENTS_BIN                     =
*      contents_txt                     = it_message
**   CONTENTS_HEX                     =
**   OBJECT_PARA                      =
**   OBJECT_PARB                      =
*      receivers                        = it_receivers
*   EXCEPTIONS
*     too_many_receivers               = 1
*     document_not_sent                = 2
*     document_type_not_exist          = 3
*     operation_no_authorization       = 4
*     parameter_error                  = 5
*     x_error                          = 6
*     enqueue_error                    = 7
*     OTHERS                           = 8
*            .
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*
** Store function module return code
*  gd_error = sy-subrc.
*
** Get it_receivers return code
*  LOOP AT it_receivers.
*  ENDLOOP.
ENDIF.
