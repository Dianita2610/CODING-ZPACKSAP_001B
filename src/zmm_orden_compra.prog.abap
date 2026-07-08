*&---------------------------------------------------------------------*
*& Report  ZMM_ORDEN_COMPRA
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZMM_ORDEN_COMPRA.

INCLUDE zsmb40fm06top.
*----------------------------------------------------------------------*
* Subroutines for the Print Program
*----------------------------------------------------------------------*
INCLUDE zsmb40fm06pf031.
INCLUDE zsmb40fm06pf04.
INCLUDE zsmb40fm06pf05.


*&---------------------------------------------------------------------*
*&      Form  entry_neu
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ENT_RETCO  text
*      -->ENT_SCREEN text
*----------------------------------------------------------------------*
FORM entry_neu USING ent_retco ent_screen.

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
    PERFORM get_addr_key
    CHANGING ls_addr_key.
  ELSE.
    ls_addr_key = nast-adrnr.
  ENDIF.

* Fill up pricing condition table if calling from ME9F
  IF l_doc-xtkomv IS INITIAL.
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * INTO TABLE l_doc-xtkomv FROM konv
*    WHERE knumv = l_doc-xekko-knumv.
*
* NEW CODE
    SELECT *
 INTO TABLE l_doc-xtkomv FROM konv
    WHERE knumv = l_doc-xekko-knumv ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03
  ENDIF.

*Set the print Parameters
  PERFORM set_print_param USING     ls_addr_key
  CHANGING  ls_control_param
    ls_composer_param
    ls_recipient
    ls_sender
    ent_retco.

*Get the Smart Form name.

  tnapr-sform = 'ZMM_SF_ORDEN_COMPRA'.
  IF NOT tnapr-sform IS INITIAL.
    lf_formname = tnapr-sform.
  ELSE.
    MESSAGE e001(/smb40/ssfcomposer).
  ENDIF.

* Determine smartform function module for invoice
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    formname           = lf_formname
  IMPORTING
    fm_name            = lf_fm_name
  EXCEPTIONS
    no_form            = 1
    no_function_module = 2
    OTHERS             = 3.
  IF sy-subrc <> 0.
*  error handling
    ent_retco = sy-subrc.
    IF sy-subrc = 1.
      MESSAGE e001(/smb40/ssfcomposer).
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e002(/smb40/ssfcomposer).
    ENDIF.
    PERFORM protocol_update_i.
  ENDIF.

  CALL FUNCTION lf_fm_name
  EXPORTING
    archive_index      = toa_dara
    archive_parameters = arc_params
    control_parameters = ls_control_param
    mail_recipient     = ls_recipient
    mail_sender        = ls_sender
    output_options     = ls_composer_param
    zxekko             = l_doc-xekko  " user_settings = ' '
    zxpekko            = l_doc-xpekko
  TABLES
    l_xekpo            = l_doc-xekpo[]
    l_xekpa            = l_doc-xekpa[]
    l_xpekpo           = l_doc-xpekpo[]
    l_xeket            = l_doc-xeket[]
    l_xtkomv           = l_doc-xtkomv[]
    l_xekkn            = l_doc-xekkn[]
    l_xekek            = l_doc-xekek[]
    l_xkomk            = l_xkomk
  EXCEPTIONS
    formatting_error   = 1
    internal_error     = 2
    send_error         = 3
    user_canceled      = 4
    OTHERS             = 5.
  IF sy-subrc <> 0.
    ent_retco = sy-subrc.
    PERFORM protocol_update_i.

* get SmartForm protocoll and store it in the NAST protocoll
    PERFORM add_smfrm_prot.
  ENDIF.
ENDFORM.                    "entry_neu
*----------------------------------------------------------------------*
* Mahnung
*----------------------------------------------------------------------*
FORM entry_mahn USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = '3'.
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
    PERFORM get_addr_key
    CHANGING ls_addr_key.
  ELSE.
    ls_addr_key = nast-adrnr.
  ENDIF.

* Fill up pricing condition table if calling from ME9F
  IF l_doc-xtkomv IS INITIAL.
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * INTO TABLE l_doc-xtkomv FROM konv
*    WHERE knumv = l_doc-xekko-knumv.
*
* NEW CODE
    SELECT *
 INTO TABLE l_doc-xtkomv FROM konv
    WHERE knumv = l_doc-xekko-knumv ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03
  ENDIF.

*Set the print Parameters
  PERFORM set_print_param USING      ls_addr_key
  CHANGING ls_control_param
    ls_composer_param
    ls_recipient
    ls_sender
    ent_retco.

*Get the Smart Form name.
  IF NOT tnapr-sform IS INITIAL.
    lf_formname = tnapr-sform.
  ELSE.
    MESSAGE e001(/smb40/ssfcomposer).
  ENDIF.

* Determine smartform function module for invoice
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    formname           = lf_formname
  IMPORTING
    fm_name            = lf_fm_name
  EXCEPTIONS
    no_form            = 1
    no_function_module = 2
    OTHERS             = 3.
  IF sy-subrc <> 0.
*  error handling
    ent_retco = sy-subrc.
    IF sy-subrc = 1.
      MESSAGE e001(/smb40/ssfcomposer).
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e002(/smb40/ssfcomposer).
    ENDIF.
    PERFORM protocol_update_i.
  ENDIF.

  CALL FUNCTION lf_fm_name
  EXPORTING
    archive_index      = toa_dara
    archive_parameters = arc_params
    control_parameters = ls_control_param
    mail_recipient     = ls_recipient
    mail_sender        = ls_sender
    output_options     = ls_composer_param
    zxekko             = l_doc-xekko  " user_settings = ' '
    zxpekko            = l_doc-xpekko
  TABLES
    l_xekpo            = l_doc-xekpo[]
    l_xekpa            = l_doc-xekpa[]
    l_xpekpo           = l_doc-xpekpo[]
    l_xeket            = l_doc-xeket[]
    l_xtkomv           = l_doc-xtkomv[]
    l_xekkn            = l_doc-xekkn[]
    l_xekek            = l_doc-xekek[]
    l_xkomk            = l_xkomk
  EXCEPTIONS
    formatting_error   = 1
    internal_error     = 2
    send_error         = 3
    user_canceled      = 4
    OTHERS             = 5.
  IF sy-subrc <> 0.
    ent_retco = sy-subrc.
    PERFORM protocol_update_i.
* get SmartForm protocoll and store it in the NAST protocoll
    PERFORM add_smfrm_prot.
  ENDIF.
ENDFORM.                    "entry_mahn

*eject
*----------------------------------------------------------------------*
* Auftragsbestätigungsmahnung
*----------------------------------------------------------------------*
FORM entry_aufb USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = '7'.
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

* Fill up pricing condition table if calling from ME9F
  IF l_doc-xtkomv IS INITIAL.
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * INTO TABLE l_doc-xtkomv FROM konv
*    WHERE knumv = l_doc-xekko-knumv.
*
* NEW CODE
    SELECT *
 INTO TABLE l_doc-xtkomv FROM konv
    WHERE knumv = l_doc-xekko-knumv ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03
  ENDIF.

*Set the print Parameters
  PERFORM set_print_param USING    ls_addr_key
  CHANGING ls_control_param
    ls_composer_param
    ls_recipient
    ls_sender
    ent_retco.

*Get the Smart Form name.
  IF NOT tnapr-sform IS INITIAL.
    lf_formname = tnapr-sform.
  ELSE.
    MESSAGE e001(/smb40/ssfcomposer).
  ENDIF.

* determine smartform function module for invoice
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    formname           = lf_formname
  IMPORTING
    fm_name            = lf_fm_name
  EXCEPTIONS
    no_form            = 1
    no_function_module = 2
    OTHERS             = 3.
  IF sy-subrc <> 0.
*  error handling
    ent_retco = sy-subrc.
    IF sy-subrc = 1.
      MESSAGE e001(/smb40/ssfcomposer).
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e002(/smb40/ssfcomposer).
    ENDIF.
    PERFORM protocol_update_i.
  ENDIF.

  CALL FUNCTION lf_fm_name
  EXPORTING
    archive_index      = toa_dara
    archive_parameters = arc_params
    control_parameters = ls_control_param
    mail_recipient     = ls_recipient
    mail_sender        = ls_sender
    output_options     = ls_composer_param
    zxekko             = l_doc-xekko  " user_settings = ' '
    zxpekko            = l_doc-xpekko
  TABLES
    l_xekpo            = l_doc-xekpo[]
    l_xekpa            = l_doc-xekpa[]
    l_xpekpo           = l_doc-xpekpo[]
    l_xeket            = l_doc-xeket[]
    l_xtkomv           = l_doc-xtkomv[]
    l_xekkn            = l_doc-xekkn[]
    l_xekek            = l_doc-xekek[]
    l_xkomk            = l_xkomk
  EXCEPTIONS
    formatting_error   = 1
    internal_error     = 2
    send_error         = 3
    user_canceled      = 4
    OTHERS             = 5.
  IF sy-subrc <> 0.
    ent_retco = sy-subrc.
    PERFORM protocol_update_i.
* get SmartForm protocoll and store it in the NAST protocoll
    PERFORM add_smfrm_prot.
  ENDIF.
ENDFORM.                    "entry_aufb
*eject
*----------------------------------------------------------------------*
* Lieferabrufdruck für Formular MEDRUCK mit Fortschrittszahlen
*----------------------------------------------------------------------*
FORM entry_lphe USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_xfz,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = '9'.
  l_xfz = 'X'.
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
    PERFORM get_addr_key
    CHANGING ls_addr_key.
  ELSE.
    ls_addr_key = nast-adrnr.
  ENDIF.
  PERFORM set_print_param USING      ls_addr_key
  CHANGING ls_control_param
    ls_composer_param
    ls_recipient
    ls_sender
    ent_retco.

*Get the Smart Form name.
  IF NOT tnapr-sform IS INITIAL.
    lf_formname = tnapr-sform.
  ELSE.
    MESSAGE e001(/smb40/ssfcomposer).
  ENDIF.

* determine smartform function module for invoice
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING  formname           = lf_formname
*                 variant            = ' '
*                 direct_call        = ' '
  IMPORTING  fm_name            = lf_fm_name
  EXCEPTIONS no_form            = 1
    no_function_module = 2
    OTHERS             = 3.
  IF sy-subrc <> 0.
*   error handling
    ent_retco = sy-subrc.
    IF sy-subrc = 1.
      MESSAGE e001(/smb40/ssfcomposer).
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e002(/smb40/ssfcomposer).
    ENDIF.
    PERFORM protocol_update_i.
  ENDIF.

* move the value
  MOVE-CORRESPONDING l_doc-xekko TO l_zekko.
  MOVE-CORRESPONDING l_doc-xpekko TO l_xpekko.
  l_xekpo[] = l_doc-xekpo[].
  l_xekpa[] = l_doc-xekpa[].
  l_xpekpo[] = l_doc-xpekpo[].
  l_xeket[] = l_doc-xeket[].
  l_xtkomv[] = l_doc-xtkomv[].
  l_xekkn[] = l_doc-xekkn[].
  l_xekek[] = l_doc-xekek[].
*l_xaend[]    = l_doc-xaend[].

  CALL FUNCTION lf_fm_name
  EXPORTING
    archive_index              = toa_dara
*   ARCHIVE_INDEX_TAB          =
    archive_parameters         = arc_params
    control_parameters         = ls_control_param
*   MAIL_APPL_OBJ              =
    mail_recipient             = ls_recipient
    mail_sender                = ls_sender
    output_options             = ls_composer_param
    user_settings              = ' '
    zxekko                     = l_zekko
    zxpekko                    = l_xpekko
*   l_xaend                    = l_xaend
*    IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
*   JOB_OUTPUT_INFO            =
*   JOB_OUTPUT_OPTIONS         =
  TABLES
    l_xekpo                    = l_xekpo
    l_xekpa                    = l_xekpa
    l_xpekpo                   = l_xpekpo
    l_xeket                    = l_xeket
    l_xtkomv                   = l_xtkomv
    l_xekkn                    = l_xekkn
    l_xekek                    = l_xekek
    l_xkomk                    = l_xkomk
*    l_xaend                    = l_xaend
* EXCEPTIONS
*   FORMATTING_ERROR           = 1
*   INTERNAL_ERROR             = 2
*   SEND_ERROR                 = 3
*   USER_CANCELED              = 4
*   OTHERS                     = 5
    .
  IF sy-subrc <> 0.
    ent_retco = sy-subrc.
    PERFORM protocol_update_i.
    PERFORM add_smfrm_prot.
  ENDIF.
*{   INSERT         AIDK900012                                        1
* Update print dependent data
* nast-sndex is used as flag for trial printout
  IF nast-kappl EQ 'EL'  AND xscreen IS INITIAL AND
  nast-sndex IS INITIAL AND ent_retco = 0.
*   missing environment for limiting update print dependent data
    IF sy-ucomm NE '9ANZ' AND sy-ucomm NE '9DPR'.
      PERFORM update_release(saplmedruck)
      TABLES l_doc-xekpo l_doc-xekek l_doc-xekeh
      USING l_druvo nast-kschl.
    ENDIF.
  ENDIF.

*}   INSERT
ENDFORM.                    "entry_lphe
*eject
*----------------------------------------------------------------------*
* Lieferabrufdruck für Formular MEDRUCK ohne Fortschrittszahlen
*----------------------------------------------------------------------*
FORM entry_lphe_cd USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = '9'.
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
    PERFORM get_addr_key
    CHANGING ls_addr_key.
  ELSE.
    ls_addr_key = nast-adrnr.
  ENDIF.
  PERFORM set_print_param USING      ls_addr_key
  CHANGING ls_control_param
    ls_composer_param
    ls_recipient
    ls_sender
    ent_retco.

*Get the Smart Form name.
  IF NOT tnapr-sform IS INITIAL.
    lf_formname = tnapr-sform.
  ELSE.
    MESSAGE e001(/smb40/ssfcomposer).
  ENDIF.

* determine smartform function module for invoice
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING  formname           = lf_formname
*                 variant            = ' '
*                 direct_call        = ' '
  IMPORTING  fm_name            = lf_fm_name
  EXCEPTIONS no_form            = 1
    no_function_module = 2
    OTHERS             = 3.
  IF sy-subrc <> 0.
*   error handling
    ent_retco = sy-subrc.
    IF sy-subrc = 1.
      MESSAGE e001(/smb40/ssfcomposer).
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e002(/smb40/ssfcomposer).
    ENDIF.
    PERFORM protocol_update_i.
  ENDIF.

* move the value
  MOVE-CORRESPONDING l_doc-xekko TO l_zekko.
  MOVE-CORRESPONDING l_doc-xpekko TO l_xpekko.
  l_xekpo[] = l_doc-xekpo[].
  l_xekpa[] = l_doc-xekpa[].
  l_xpekpo[] = l_doc-xpekpo[].
  l_xeket[] = l_doc-xeket[].
  l_xtkomv[] = l_doc-xtkomv[].
  l_xekkn[] = l_doc-xekkn[].
  l_xekek[] = l_doc-xekek[].
*  l_xaend[]    = l_doc-xaend[].

  CALL FUNCTION lf_fm_name
  EXPORTING
    archive_index              = toa_dara
*   ARCHIVE_INDEX_TAB          =
    archive_parameters         = arc_params
    control_parameters         = ls_control_param
*   MAIL_APPL_OBJ              =
    mail_recipient             = ls_recipient
    mail_sender                = ls_sender
    output_options             = ls_composer_param
    user_settings              = ' '
    zxekko                     = l_zekko
    zxpekko                    = l_xpekko
*   l_xaend                    = l_xaend
*    IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
*   JOB_OUTPUT_INFO            =
*   JOB_OUTPUT_OPTIONS         =
  TABLES
    l_xekpo                    = l_xekpo
    l_xekpa                    = l_xekpa
    l_xpekpo                   = l_xpekpo
    l_xeket                    = l_xeket
    l_xtkomv                   = l_xtkomv
    l_xekkn                    = l_xekkn
    l_xekek                    = l_xekek
    l_xkomk                    = l_xkomk
*    l_xaend                    = l_xaend
* EXCEPTIONS
*   FORMATTING_ERROR           = 1
*   INTERNAL_ERROR             = 2
*   SEND_ERROR                 = 3
*   USER_CANCELED              = 4
*   OTHERS                     = 5
    .
  IF sy-subrc <> 0.
    ent_retco = sy-subrc.
    PERFORM protocol_update_i.
    PERFORM add_smfrm_prot.
  ENDIF.
*{   INSERT         AIDK900012                                        1
* Update print dependent data
* nast-sndex is used as flag for trial printout
  IF nast-kappl EQ 'EL'  AND xscreen IS INITIAL AND
  nast-sndex IS INITIAL AND ent_retco = 0.
*   missing environment for limiting update print dependent data
    IF sy-ucomm NE '9ANZ' AND sy-ucomm NE '9DPR'.
      PERFORM update_release(saplmedruck)
      TABLES l_doc-xekpo l_doc-xekek l_doc-xekeh
      USING l_druvo nast-kschl.
    ENDIF.
  ENDIF.

*}   INSERT
ENDFORM.                    "entry_lphe_cd
*eject
*----------------------------------------------------------------------*
* Feinabrufdruck für Formular MEDRUCK mit Fortschrittszahlen
*----------------------------------------------------------------------*
FORM entry_lpje USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_xfz,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = 'A'.
  l_xfz = 'X'.
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
    PERFORM get_addr_key
    CHANGING ls_addr_key.
  ELSE.
    ls_addr_key = nast-adrnr.
  ENDIF.
  PERFORM set_print_param USING      ls_addr_key
  CHANGING ls_control_param
    ls_composer_param
    ls_recipient
    ls_sender
    ent_retco.

*Get the Smart Form name.
  IF NOT tnapr-sform IS INITIAL.
    lf_formname = tnapr-sform.
  ELSE.
    MESSAGE e001(/smb40/ssfcomposer).
  ENDIF.

* determine smartform function module for invoice
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING  formname           = lf_formname
*                 variant            = ' '
*                 direct_call        = ' '
  IMPORTING  fm_name            = lf_fm_name
  EXCEPTIONS no_form            = 1
    no_function_module = 2
    OTHERS             = 3.
  IF sy-subrc <> 0.
*   error handling
    ent_retco = sy-subrc.
    IF sy-subrc = 1.
      MESSAGE e001(/smb40/ssfcomposer).
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e002(/smb40/ssfcomposer).
    ENDIF.
    PERFORM protocol_update_i.
  ENDIF.

* move the value
  MOVE-CORRESPONDING l_doc-xekko TO l_zekko.
  MOVE-CORRESPONDING l_doc-xpekko TO l_xpekko.
  l_xekpo[] = l_doc-xekpo[].
  l_xekpa[] = l_doc-xekpa[].
  l_xpekpo[] = l_doc-xpekpo[].
  l_xeket[] = l_doc-xeket[].
  l_xtkomv[] = l_doc-xtkomv[].
  l_xekkn[] = l_doc-xekkn[].
  l_xekek[] = l_doc-xekek[].
*  l_xaend[]    = l_doc-xaend[].

  CALL FUNCTION lf_fm_name
  EXPORTING
    archive_index              = toa_dara
*   ARCHIVE_INDEX_TAB          =
    archive_parameters         = arc_params
    control_parameters         = ls_control_param
*   MAIL_APPL_OBJ              =
    mail_recipient             = ls_recipient
    mail_sender                = ls_sender
    output_options             = ls_composer_param
    user_settings              = ' '
    zxekko                     = l_zekko
    zxpekko                    = l_xpekko
*   l_xaend                    = l_xaend
*    IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
*   JOB_OUTPUT_INFO            =
*   JOB_OUTPUT_OPTIONS         =
  TABLES
    l_xekpo                    = l_xekpo
    l_xekpa                    = l_xekpa
    l_xpekpo                   = l_xpekpo
    l_xeket                    = l_xeket
    l_xtkomv                   = l_xtkomv
    l_xekkn                    = l_xekkn
    l_xekek                    = l_xekek
    l_xkomk                    = l_xkomk
*    l_xaend                    = l_xaend
* EXCEPTIONS
*   FORMATTING_ERROR           = 1
*   INTERNAL_ERROR             = 2
*   SEND_ERROR                 = 3
*   USER_CANCELED              = 4
*   OTHERS                     = 5
    .
  IF sy-subrc <> 0.
    ent_retco = sy-subrc.
    PERFORM protocol_update_i.
    PERFORM add_smfrm_prot.
  ENDIF.
*{   INSERT         AIDK900012                                        1
* Update print dependent data
* nast-sndex is used as flag for trial printout
  IF nast-kappl EQ 'EL'  AND xscreen IS INITIAL AND
  nast-sndex IS INITIAL AND ent_retco = 0.
*   missing environment for limiting update print dependent data
    IF sy-ucomm NE '9ANZ' AND sy-ucomm NE '9DPR'.
      PERFORM update_release(saplmedruck)
      TABLES l_doc-xekpo l_doc-xekek l_doc-xekeh
      USING l_druvo nast-kschl.
    ENDIF.
  ENDIF.
*}   INSERT
ENDFORM.                    "entry_lpje
*eject
*----------------------------------------------------------------------*
* Feinabrufdruck für Formular MEDRUCK ohne Fortschrittszahlen
*----------------------------------------------------------------------*
FORM entry_lpje_cd USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = 'A'.
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
    PERFORM get_addr_key
    CHANGING ls_addr_key.
  ELSE.
    ls_addr_key = nast-adrnr.
  ENDIF.
  PERFORM set_print_param USING      ls_addr_key
  CHANGING ls_control_param
    ls_composer_param
    ls_recipient
    ls_sender
    ent_retco.

*Get the Smart Form name.
  IF NOT tnapr-sform IS INITIAL.
    lf_formname = tnapr-sform.
  ELSE.
    MESSAGE e001(/smb40/ssfcomposer).
  ENDIF.

* Determine smartform function module for invoice
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING  formname           = lf_formname
*                 variant            = ' '
*                 direct_call        = ' '
  IMPORTING  fm_name            = lf_fm_name
  EXCEPTIONS no_form            = 1
    no_function_module = 2
    OTHERS             = 3.
  IF sy-subrc <> 0.
*   error handling
    ent_retco = sy-subrc.
    IF sy-subrc = 1.
      MESSAGE e001(/smb40/ssfcomposer).
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e002(/smb40/ssfcomposer).
    ENDIF.
    PERFORM protocol_update_i.
  ENDIF.

* move the value
  MOVE-CORRESPONDING l_doc-xekko TO l_zekko.
  MOVE-CORRESPONDING l_doc-xpekko TO l_xpekko.
  l_xekpo[] = l_doc-xekpo[].
  l_xekpa[] = l_doc-xekpa[].
  l_xpekpo[] = l_doc-xpekpo[].
  l_xeket[] = l_doc-xeket[].
  l_xtkomv[] = l_doc-xtkomv[].
  l_xekkn[] = l_doc-xekkn[].
  l_xekek[] = l_doc-xekek[].
*  l_xaend[]    = l_doc-xaend[].

  CALL FUNCTION lf_fm_name
  EXPORTING
    archive_index              = toa_dara
*   ARCHIVE_INDEX_TAB          =
    archive_parameters         = arc_params
    control_parameters         = ls_control_param
*   MAIL_APPL_OBJ              =
    mail_recipient             = ls_recipient
    mail_sender                = ls_sender
    output_options             = ls_composer_param
    user_settings              = ' '
    zxekko                     = l_zekko
    zxpekko                    = l_xpekko
*   l_xaend                    = l_xaend
*    IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
*   JOB_OUTPUT_INFO            =
*   JOB_OUTPUT_OPTIONS         =
  TABLES
    l_xekpo                    = l_xekpo
    l_xekpa                    = l_xekpa
    l_xpekpo                   = l_xpekpo
    l_xeket                    = l_xeket
    l_xtkomv                   = l_xtkomv
    l_xekkn                    = l_xekkn
    l_xekek                    = l_xekek
    l_xkomk                    = l_xkomk
*    l_xaend                    = l_xaend
* EXCEPTIONS
*   FORMATTING_ERROR           = 1
*   INTERNAL_ERROR             = 2
*   SEND_ERROR                 = 3
*   USER_CANCELED              = 4
*   OTHERS                     = 5
    .
  IF sy-subrc <> 0.
    ent_retco = sy-subrc.
    PERFORM protocol_update_i.
    PERFORM add_smfrm_prot.
  ENDIF.
*{   INSERT         AIDK900012                                        1
* Update print dependent data
* nast-sndex is used as flag for trial printout
  IF nast-kappl EQ 'EL'  AND xscreen IS INITIAL AND
  nast-sndex IS INITIAL AND ent_retco = 0.
*   missing environment for limiting update print dependent data
    IF sy-ucomm NE '9ANZ' AND sy-ucomm NE '9DPR'.
      PERFORM update_release(saplmedruck)
      TABLES l_doc-xekpo l_doc-xekek l_doc-xekeh
      USING l_druvo nast-kschl.
    ENDIF.
  ENDIF.
*}   INSERT
ENDFORM.                    "entry_lpje_cd
*eject
*----------------------------------------------------------------------*
*   INCLUDE FM06PE02                                                   *
*----------------------------------------------------------------------*
FORM entry_neu_matrix USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  IF nast-aende EQ space.
    l_druvo = '1'.
  ELSE.
    l_druvo = '2'.
  ENDIF.

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
    PERFORM get_addr_key
    CHANGING ls_addr_key.
  ELSE.
    ls_addr_key = nast-adrnr.
  ENDIF.
  PERFORM set_print_param USING      ls_addr_key
  CHANGING ls_control_param
    ls_composer_param
    ls_recipient
    ls_sender
    ent_retco.

*Get the Smart Form name.
  IF NOT tnapr-sform IS INITIAL.
    lf_formname = tnapr-sform.
  ELSE.
    MESSAGE e001(/smb40/ssfcomposer).
  ENDIF.

* Determine smartform function module for invoice
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING  formname           = lf_formname
*                 variant            = ' '
*                 direct_call        = ' '
  IMPORTING  fm_name            = lf_fm_name
  EXCEPTIONS no_form            = 1
    no_function_module = 2
    OTHERS             = 3.
  IF sy-subrc <> 0.
*   error handling
    ent_retco = sy-subrc.
    IF sy-subrc = 1.
      MESSAGE e001(/smb40/ssfcomposer).
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e002(/smb40/ssfcomposer).
    ENDIF.
    PERFORM protocol_update_i.
  ENDIF.

* move the value
  MOVE-CORRESPONDING l_doc-xekko TO l_zekko.
  MOVE-CORRESPONDING l_doc-xpekko TO l_xpekko.
  l_xekpo[] = l_doc-xekpo[].
  l_xekpa[] = l_doc-xekpa[].
  l_xpekpo[] = l_doc-xpekpo[].
  l_xeket[] = l_doc-xeket[].
  l_xtkomv[] = l_doc-xtkomv[].
  l_xekkn[] = l_doc-xekkn[].
  l_xekek[] = l_doc-xekek[].

  CALL FUNCTION lf_fm_name
  EXPORTING
    archive_index      = toa_dara
    archive_parameters = arc_params
    control_parameters = ls_control_param
    mail_recipient     = ls_recipient
    mail_sender        = ls_sender
    output_options     = ls_composer_param
    user_settings      = ' '
    zxekko             = l_zekko
    zxpekko            = l_xpekko
  TABLES
    l_xekpo            = l_xekpo
    l_xekpa            = l_xekpa
    l_xpekpo           = l_xpekpo
    l_xeket            = l_xeket
    l_xtkomv           = l_xtkomv
    l_xekkn            = l_xekkn
    l_xekek            = l_xekek
    l_xkomk            = l_xkomk.

  IF sy-subrc <> 0.
    ent_retco = sy-subrc.
    PERFORM protocol_update_i.
    PERFORM add_smfrm_prot.
  ENDIF.
ENDFORM.                    "entry_neu_matrix
*eject
*----------------------------------------------------------------------*
* Angebotsabsage
*----------------------------------------------------------------------*
FORM entry_absa USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  l_druvo = '4'.
  CLEAR ent_retco.
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
    PERFORM get_addr_key
    CHANGING ls_addr_key.
  ELSE.
    ls_addr_key = nast-adrnr.
  ENDIF.
  PERFORM set_print_param USING      ls_addr_key
  CHANGING ls_control_param
    ls_composer_param
    ls_recipient
    ls_sender
    ent_retco.

*Get the Smart Form name.
  IF NOT tnapr-sform IS INITIAL.
    lf_formname = tnapr-sform.
  ELSE.
    MESSAGE e001(/smb40/ssfcomposer).
  ENDIF.

* Determine smartform function module for invoice
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING  formname           = lf_formname
*                 variant            = ' '
*                 direct_call        = ' '
  IMPORTING  fm_name            = lf_fm_name
  EXCEPTIONS no_form            = 1
    no_function_module = 2
    OTHERS             = 3.
  IF sy-subrc <> 0.
*   error handling
    ent_retco = sy-subrc.
    PERFORM protocol_update_i.
  ENDIF.

* move the value
  MOVE-CORRESPONDING l_doc-xekko TO l_zekko.
  MOVE-CORRESPONDING l_doc-xpekko TO l_xpekko.
  l_xekpo[] = l_doc-xekpo[].
  l_xekpa[] = l_doc-xekpa[].
  l_xpekpo[] = l_doc-xpekpo[].
  l_xeket[] = l_doc-xeket[].
  l_xtkomv[] = l_doc-xtkomv[].
  l_xekkn[] = l_doc-xekkn[].
  l_xekek[] = l_doc-xekek[].
*  l_xaend[]    = l_doc-xaend[].

  CALL FUNCTION lf_fm_name
  EXPORTING
    archive_index      = toa_dara
    archive_parameters = arc_params
    control_parameters = ls_control_param
    mail_recipient     = ls_recipient
    mail_sender        = ls_sender
    output_options     = ls_composer_param
    user_settings      = ' '
    zxekko             = l_zekko
    zxpekko            = l_xpekko
  TABLES
    l_xekpo            = l_xekpo
    l_xekpa            = l_xekpa
    l_xpekpo           = l_xpekpo
    l_xeket            = l_xeket
    l_xtkomv           = l_xtkomv
    l_xekkn            = l_xekkn
    l_xekek            = l_xekek
    l_xkomk            = l_xkomk.
  IF sy-subrc <> 0.
    ent_retco = sy-subrc.
    IF sy-subrc = 1.
      MESSAGE e001(/smb40/ssfcomposer).
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e002(/smb40/ssfcomposer).
    ENDIF.
    PERFORM protocol_update_i.
    PERFORM add_smfrm_prot.
  ENDIF.
ENDFORM.                    "entry_absa
*eject
*----------------------------------------------------------------------*
* Lieferplaneinteilung
*----------------------------------------------------------------------*
FORM entry_lpet USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.
  DATA: l_zekko LIKE ekko,
        l_xpekko LIKE pekko,
        l_xekpo LIKE TABLE OF ekpo,
        l_wa_xekpo LIKE ekpo.

  DATA: l_xekpa LIKE ekpa OCCURS 0,
        l_wa_xekpa LIKE ekpa.
  DATA: l_xpekpo  LIKE pekpo OCCURS 0,
        l_wa_xpekpo LIKE pekpo,
        l_xeket   LIKE TABLE OF eket WITH HEADER LINE,
        l_xekkn  LIKE TABLE OF ekkn WITH HEADER LINE,
        l_xekek  LIKE TABLE OF ekek WITH HEADER LINE,
        l_xekeh   LIKE TABLE OF ekeh WITH HEADER LINE,
        l_xkomk LIKE TABLE OF komk WITH HEADER LINE,
        l_xtkomv  TYPE komv OCCURS 0,
        l_wa_xtkomv TYPE komv.
  DATA: ls_addr_key           LIKE addr_key.
  CLEAR ent_retco.
  IF nast-aende EQ space.
    l_druvo = '5'.
  ELSE.
    l_druvo = '8'.
  ENDIF.

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
    PERFORM get_addr_key
    CHANGING ls_addr_key.
  ELSE.
    ls_addr_key = nast-adrnr.
  ENDIF.
  PERFORM set_print_param USING      ls_addr_key
  CHANGING ls_control_param
    ls_composer_param
    ls_recipient
    ls_sender
    ent_retco.

*Get the Smart Form name.
  IF NOT tnapr-sform IS INITIAL.
    lf_formname = tnapr-sform.
  ELSE.
    MESSAGE e001(/smb40/ssfcomposer).
  ENDIF.

* determine smartform function module for invoice
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING  formname           = lf_formname
*                 variant            = ' '
*                 direct_call        = ' '
  IMPORTING  fm_name            = lf_fm_name
  EXCEPTIONS no_form            = 1
    no_function_module = 2
    OTHERS             = 3.
  IF sy-subrc <> 0.
*   error handling
    ent_retco = sy-subrc.
    IF sy-subrc = 1.
      MESSAGE e001(/smb40/ssfcomposer).
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e002(/smb40/ssfcomposer).
    ENDIF.
    PERFORM protocol_update_i.
  ENDIF.

* move the value
  MOVE-CORRESPONDING l_doc-xekko TO l_zekko.
  MOVE-CORRESPONDING l_doc-xpekko TO l_xpekko.
  l_xekpo[] = l_doc-xekpo[].
  l_xekpa[] = l_doc-xekpa[].
  l_xpekpo[] = l_doc-xpekpo[].
  l_xeket[] = l_doc-xeket[].
  l_xtkomv[] = l_doc-xtkomv[].
  l_xekkn[] = l_doc-xekkn[].
  l_xekek[] = l_doc-xekek[].

  CALL FUNCTION lf_fm_name
  EXPORTING
    archive_index      = toa_dara
    archive_parameters = arc_params
    control_parameters = ls_control_param
    mail_recipient     = ls_recipient
    mail_sender        = ls_sender
    output_options     = ls_composer_param
    user_settings      = ' '
    zxekko             = l_zekko
    zxpekko            = l_xpekko
  TABLES
    l_xekpo            = l_xekpo
    l_xekpa            = l_xekpa
    l_xpekpo           = l_xpekpo
    l_xeket            = l_xeket
    l_xtkomv           = l_xtkomv
    l_xekkn            = l_xekkn
    l_xekek            = l_xekek
    l_xkomk            = l_xkomk
  EXCEPTIONS
    formatting_error   = 1
    internal_error     = 2
    send_error         = 3
    user_canceled      = 4
    OTHERS             = 5.
  IF sy-subrc <> 0.
    ent_retco = sy-subrc.
    PERFORM protocol_update_i.
* get SmartForm protocoll and store it in the NAST protocoll
    PERFORM add_smfrm_prot.
  ENDIF.
ENDFORM.                    "entry_lpet
*eject
*----------------------------------------------------------------------*
* Lieferplaneinteilung
*----------------------------------------------------------------------*
FORM entry_lpfz USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  IF nast-aende EQ space.
    l_druvo = '5'.
  ELSE.
    l_druvo = '8'.
  ENDIF.

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
    PERFORM get_addr_key
    CHANGING ls_addr_key.
  ELSE.
    ls_addr_key = nast-adrnr.
  ENDIF.
  PERFORM set_print_param USING      ls_addr_key
  CHANGING ls_control_param
    ls_composer_param
    ls_recipient
    ls_sender
    ent_retco.

*Get the Smart Form name.
  IF NOT tnapr-sform IS INITIAL.
    lf_formname = tnapr-sform.
  ELSE.
    MESSAGE e001(/smb40/ssfcomposer).
  ENDIF.

* determine smartform function module for invoice
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING  formname           = lf_formname
*                 variant            = ' '
*                 direct_call        = ' '
  IMPORTING  fm_name            = lf_fm_name
  EXCEPTIONS no_form            = 1
    no_function_module = 2
    OTHERS             = 3.
  IF sy-subrc <> 0.
*   error handling
    ent_retco = sy-subrc.
    IF sy-subrc = 1.
      MESSAGE e001(/smb40/ssfcomposer).
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e002(/smb40/ssfcomposer).
    ENDIF.
    PERFORM protocol_update_i.
  ENDIF.

* move the value
  MOVE-CORRESPONDING l_doc-xekko TO l_zekko.
  MOVE-CORRESPONDING l_doc-xpekko TO l_xpekko.
  l_xekpo[] = l_doc-xekpo[].
  l_xekpa[] = l_doc-xekpa[].
  l_xpekpo[] = l_doc-xpekpo[].
  l_xeket[] = l_doc-xeket[].
  l_xtkomv[] = l_doc-xtkomv[].
  l_xekkn[] = l_doc-xekkn[].
  l_xekek[] = l_doc-xekek[].
*  l_xaend[]    = l_doc-xaend[].

  CALL FUNCTION lf_fm_name
  EXPORTING
    archive_index              = toa_dara
*   ARCHIVE_INDEX_TAB          =
    archive_parameters         = arc_params
    control_parameters         = ls_control_param
*   MAIL_APPL_OBJ              =
    mail_recipient             = ls_recipient
    mail_sender                = ls_sender
    output_options             = ls_composer_param
    user_settings              = ' '
    zxekko                     = l_zekko
    zxpekko                    = l_xpekko
*   l_xaend                    = l_xaend
*    IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
*   JOB_OUTPUT_INFO            =
*   JOB_OUTPUT_OPTIONS         =
  TABLES
    l_xekpo                    = l_xekpo
    l_xekpa                    = l_xekpa
    l_xpekpo                   = l_xpekpo
    l_xeket                    = l_xeket
    l_xtkomv                   = l_xtkomv
    l_xekkn                    = l_xekkn
    l_xekek                    = l_xekek
    l_xkomk                    = l_xkomk
*    l_xaend                    = l_xaend
  EXCEPTIONS
    formatting_error           = 1
    internal_error             = 2
    send_error                 = 3
    user_canceled              = 4
    OTHERS                     = 5
    .
  IF sy-subrc <> 0.
    ent_retco = sy-subrc.
    PERFORM protocol_update_i.
* get SmartForm protocoll and store it in the NAST protocoll
    PERFORM add_smfrm_prot.
  ENDIF.

ENDFORM.                    "entry_lpfz
*eject
*----------------------------------------------------------------------*
* Mahnung
*----------------------------------------------------------------------*
FORM entry_lpma USING ent_retco ent_screen.

  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  CLEAR ent_retco.
  l_druvo = '6'.
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
    PERFORM get_addr_key
    CHANGING ls_addr_key.
  ELSE.
    ls_addr_key = nast-adrnr.
  ENDIF.
  PERFORM set_print_param USING      ls_addr_key
  CHANGING ls_control_param
    ls_composer_param
    ls_recipient
    ls_sender
    ent_retco.

*Get the Smart Form name.
  IF NOT tnapr-sform IS INITIAL.
    lf_formname = tnapr-sform.
  ELSE.
    MESSAGE e001(/smb40/ssfcomposer).
  ENDIF.

* Determine smartform function module for invoice
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING  formname           = lf_formname
*                 variant            = ' '
*                 direct_call        = ' '
  IMPORTING  fm_name            = lf_fm_name
  EXCEPTIONS no_form            = 1
    no_function_module = 2
    OTHERS             = 3.
  IF sy-subrc <> 0.
*   error handling
    ent_retco = sy-subrc.
    IF sy-subrc = 1.
      MESSAGE e001(/smb40/ssfcomposer).
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e002(/smb40/ssfcomposer).
    ENDIF.
    PERFORM protocol_update_i.
  ENDIF.

* move the value
  MOVE-CORRESPONDING l_doc-xekko TO l_zekko.
  MOVE-CORRESPONDING l_doc-xpekko TO l_xpekko.
  l_xekpo[] = l_doc-xekpo[].
  l_xekpa[] = l_doc-xekpa[].
  l_xpekpo[] = l_doc-xpekpo[].
  l_xeket[] = l_doc-xeket[].
  l_xtkomv[] = l_doc-xtkomv[].
  l_xekkn[] = l_doc-xekkn[].
  l_xekek[] = l_doc-xekek[].
* l_xaend[]    = l_doc-xaend[].

  CALL FUNCTION lf_fm_name
  EXPORTING
    archive_index              = toa_dara
*   ARCHIVE_INDEX_TAB          =
    archive_parameters         = arc_params
    control_parameters         = ls_control_param
*   MAIL_APPL_OBJ              =
    mail_recipient             = ls_recipient
    mail_sender                = ls_sender
    output_options             = ls_composer_param
    user_settings              = ' '
    zxekko                    = l_zekko
    zxpekko                   = l_xpekko
*   l_xaend                    = l_xaend
*    IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
*   JOB_OUTPUT_INFO            =
*   JOB_OUTPUT_OPTIONS         =
  TABLES
    l_xekpo                    = l_xekpo
    l_xekpa                    = l_xekpa
    l_xpekpo                   = l_xpekpo
    l_xeket                    = l_xeket
    l_xtkomv                   = l_xtkomv
    l_xekkn                    = l_xekkn
    l_xekek                    = l_xekek
    l_xkomk                    = l_xkomk
*    l_xaend                    = l_xaend
* EXCEPTIONS
*   FORMATTING_ERROR           = 1
*   INTERNAL_ERROR             = 2
*   SEND_ERROR                 = 3
*   USER_CANCELED              = 4
*   OTHERS                     = 5
    .
  IF sy-subrc <> 0.
    ent_retco = sy-subrc.
    PERFORM protocol_update_i.
    PERFORM add_smfrm_prot.
  ENDIF.
ENDFORM.                    "entry_lpma

**********************************************************
*form entry_lpf2_new for lpf2
************************************************************

FORM entry_lpf2_new USING ent_retco ent_screen.
  DATA: l_druvo LIKE t166k-druvo,
        l_nast  LIKE nast,
        l_from_memory,
        l_doc   TYPE meein_purchase_doc_print.

  xscreen = ent_screen.
  xlpet  = 'X'.
  IF nast-aende EQ space.
    xdruvo = '5'.
  ELSE.
    xdruvo = '8'.
  ENDIF.
  xfz    = 'X'.
  xoffen = 'X'.
  CLEAR: xlmahn.
*- Anstoß Verarbeitung ------------------------------------------------*
  CLEAR ent_retco.
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
    PERFORM get_addr_key
    CHANGING ls_addr_key.
  ELSE.
    ls_addr_key = nast-adrnr.
  ENDIF.
  PERFORM set_print_param USING      ls_addr_key
  CHANGING ls_control_param
    ls_composer_param
    ls_recipient
    ls_sender
    ent_retco.

*Get the Smart Form name.
  IF NOT tnapr-sform IS INITIAL.
    lf_formname = tnapr-sform.
  ELSE.
    MESSAGE e001(/smb40/ssfcomposer).
  ENDIF.

* determine smartform function module for invoice
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING  formname           = lf_formname
*                 variant            = ' '
*                 direct_call        = ' '
  IMPORTING  fm_name            = lf_fm_name
  EXCEPTIONS no_form            = 1
    no_function_module = 2
    OTHERS             = 3.
  IF sy-subrc <> 0.
*   error handling
    ent_retco = sy-subrc.
    IF sy-subrc = 1.
      MESSAGE e001(/smb40/ssfcomposer).
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e002(/smb40/ssfcomposer).
    ENDIF.
    PERFORM protocol_update_i.
  ENDIF.

* move the value
  MOVE-CORRESPONDING l_doc-xekko TO l_zekko.
  MOVE-CORRESPONDING l_doc-xpekko TO l_xpekko.
  l_xekpo[] = l_doc-xekpo[].
  l_xekpa[] = l_doc-xekpa[].
  l_xpekpo[] = l_doc-xpekpo[].
  l_xeket[] = l_doc-xeket[].
  l_xtkomv[] = l_doc-xtkomv[].
  l_xekkn[] = l_doc-xekkn[].
  l_xekek[] = l_doc-xekek[].
*  l_xaend[]    = l_doc-xaend[].

  CALL FUNCTION lf_fm_name
  EXPORTING
    archive_index              = toa_dara
*   ARCHIVE_INDEX_TAB          =
    archive_parameters         = arc_params
    control_parameters         = ls_control_param
*   MAIL_APPL_OBJ              =
    mail_recipient             = ls_recipient
    mail_sender                = ls_sender
    output_options             = ls_composer_param
    user_settings              = ' '
    zxekko                     = l_zekko
    zxpekko                    = l_xpekko
  TABLES
    l_xekpo                    = l_xekpo
    l_xekpa                    = l_xekpa
    l_xpekpo                   = l_xpekpo
    l_xeket                    = l_xeket
    l_xtkomv                   = l_xtkomv
    l_xekkn                    = l_xekkn
    l_xekek                    = l_xekek
    l_xkomk                    = l_xkomk.
  IF sy-subrc <> 0.
    ent_retco = sy-subrc.
    PERFORM protocol_update_i.
    PERFORM add_smfrm_prot.
  ENDIF.
ENDFORM.                    "entry_lpf2_new
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
    MOVE-CORRESPONDING ls_itcpo TO cs_composer_param.
*    cs_composer_param-tdnoprint = 'X'.                     "Note 591576
    cs_control_param-device      = lf_device.
    cs_control_param-no_dialog   = 'X'.
    cs_control_param-preview     = xscreen.
    cs_control_param-getotf      = ls_itcpo-tdgetotf.
    cs_control_param-langu       = nast-spras.
  ENDIF.
ENDFORM.                    "set_print_paramCOMPRAS.
