*&---------------------------------------------------------------------*
*& Report  ZSD_TABLAS_MONITOR_HELP
*&
*&---------------------------------------------------------------------*
*& Programa para recuperar las tablas ZFAC_ANEX y ZCABPEDEXT
*& previamente respaldadas en un archivo txt
*&---------------------------------------------------------------------*

REPORT  zsd_tablas_monitor_help.

TYPES: BEGIN OF t_fac_anex,
  bukrs TYPE  bukrs ,
belnr TYPE  belnr_d ,
gjahr TYPE  gjahr ,
buzei TYPE  buzei ,
zblart  TYPE  blart ,
zbloq_pago  TYPE  zbloq_pago  ,
zcentro TYPE  werks_d ,
zciudad_fact  TYPE  zciudad_fact  ,
zcod_rechazo  TYPE  zcod_rechazo  ,
zcomuna_fact  TYPE  zcomuna_fact  ,
zcopago_plan  TYPE  zcopago_plan  ,
zdcto_conv  TYPE  string , "zdcto_conv  ,
zdcto_esp TYPE  string, "zdcto_esp ,
zdcto_espt  TYPE  string, "zdcto_esp_t ,
zdcto_prom  TYPE  string, "zdcto_prom  ,
zdes_ad TYPE string, " zdes_ad ,
zdir_fact TYPE  zdir_fact ,
zelectronico  TYPE  zelectronico  ,
zfec_cont TYPE  char10 ,
zfec_doc_core TYPE  char10 ,
zgiro_cli_fact  TYPE  zgiro_cli_fact  ,
zind_afecto TYPE  zind_afecto ,
zind_traspaso TYPE  zind_traspaso ,
zing_b_h  TYPE  zing_b_h  ,
zkvgr3  TYPE  kvgr3 ,
zkvgr4  TYPE  kvgr4 ,
zmonto_total  TYPE  string, "dmbtr ,
zmonto_uf TYPE  string, "zmonto_uf ,
znom_cli_fact TYPE  znom_cli_fact ,
znum_doc_core TYPE  znum_doc_core ,
znum_endoso TYPE  znum_endoso ,
znum_mandato  TYPE  znum_mandato  ,
zotro_ing TYPE  string, "zotro_ing ,
zplan TYPE  zplan ,
zprec TYPE  string, "zprec ,
zr_etareo TYPE  zrang_etareo  ,
zrec_ad TYPE  string, "zrec_ad ,
zrut_benef  TYPE  zrut_beneficiario ,
zrut_cli_fact TYPE  zrut_cli_fact ,
zrut_cli_pagador  TYPE  zrut_cli_pagador  ,
zsector TYPE  spart ,
ztip_cambio_ref TYPE  string, "ztip_cambio_ref ,
zurl  TYPE  zurl  ,
zvkorg  TYPE  vkorg ,
zvtweg  TYPE  vtweg ,
zzconve_dpp TYPE  zzconvenio  ,
zzrut_dpp TYPE  stcd1 ,
gjahr_dpp TYPE  gjahr ,
augbl_dpp TYPE  augbl ,
augdt_dpp TYPE  char10 ,
       END OF t_fac_anex.

DATA: ti_fac_anex TYPE TABLE OF t_fac_anex,
      wa_fac_anex TYPE t_fac_anex.


TYPES: BEGIN OF t_cab,
          znum_doc_core TYPE  znum_doc_core ,
zblart  TYPE  zblart  ,
status  TYPE  status_text ,
status_elec TYPE  status_text ,
zelectronico  TYPE  zelectronico  ,
vkorg TYPE  vkorg ,
vtweg TYPE  vtweg ,
spart TYPE  spart ,
vkbur TYPE  vkbur ,
vkgrp TYPE  vkgrp ,
fecdoccore  TYPE  string, "zfec_doc_core ,
fecventes TYPE  string, "fdtag ,
zrut_cli_fact TYPE  zrut_cli_fact ,
znom_cli_fact TYPE  znom_cli_fact ,
zrut_cli_pagador  TYPE  zrut_cli_pagador  ,
zgiro_cli_fact  TYPE  zgiro_cli_fact  ,
zdir_fact TYPE  zdir_fact ,
zcomuna_fact  TYPE  zcomuna_fact  ,
zciudad_fact  TYPE  zciudad_fact  ,
vertn TYPE  znum_contrato ,
zfec_cont TYPE  string, "zfec_contrato ,
zuonr TYPE  dzuonr  ,
zterm TYPE  dzterm  ,
zind_traspaso TYPE  zind_traspaso ,
xref3 TYPE  xref3 ,
hbkid TYPE  hbkid ,
vertt TYPE  rantyp  ,
xref1 TYPE  xref1 ,
waers TYPE  waers ,
zplan TYPE  zplan ,
zlsch TYPE  schzw_bseg  ,
ztip_cambio_ref TYPE  string, "ztip_cambio_ref ,
zcentro TYPE  werks_d ,
znum_mandato  TYPE  znum_mandato  ,
znum_endoso TYPE  znum_endoso ,
zind_afecto TYPE  zind_afecto ,
zkvgr3  TYPE  kvgr3 ,
zkvgr4  TYPE  kvgr4 ,
zcopago_plan  TYPE  zcopago_plan  ,
zmonto_total  TYPE  string, "zmonto_total  ,
zbloq_pago  TYPE  zbloq_pago  ,
pedido  TYPE  vbeln_va  ,
factura TYPE  vbeln_vf  ,
fecfaccon TYPE  string, "zfecfaccon  ,
fec_car TYPE  string, "systdatlo ,
hor_car TYPE  systtimlo ,
error TYPE  selkz ,
error_e TYPE  selkz ,
log_error TYPE  char255 ,
glosa_p1  TYPE  char255 ,
glosa_p2  TYPE  char255 ,
glosa_p3  TYPE  char255 ,
glosa_p4  TYPE  char255 ,
       END OF t_cab.

DATA: ti_cab TYPE TABLE OF t_cab,
      wa_cab TYPE t_cab.


PARAMETERS : p_file TYPE rlgrap-filename OBLIGATORY.
PARAMETERS : r_tabla1 RADIOBUTTON GROUP a1 DEFAULT 'X',
             r_tabla2 RADIOBUTTON GROUP a1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = p_file
      def_path         = 'c:\'
      mask             = ',*.*,*.*.'
      mode             = 'O'
      title            = 'Directorio de Datos'
    IMPORTING
      filename         = p_file
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.


START-OF-SELECTION.

  IF r_tabla1 EQ 'X'.
    PERFORM bajar_archivo_1.
  ELSE.
    PERFORM bajar_archivo_2.
  ENDIF.


*&---------------------------------------------------------------------*
*&      Form  BAJAR_ARCHIVO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bajar_archivo_1.

  DATA: ti_anex TYPE TABLE OF zfac_anex,
        wa_anex TYPE zfac_anex.

  DATA: strarq TYPE string.
  strarq = p_file.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = strarq
      filetype                = 'ASC'
      has_field_separator     = 'X'
    TABLES
      data_tab                = ti_fac_anex
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
  IF sy-subrc EQ 0.


    LOOP AT ti_fac_anex INTO wa_fac_anex.
      IF NOT wa_fac_anex-zfec_cont IS INITIAL.
        PERFORM formato_fecha CHANGING wa_fac_anex-zfec_cont.
      ENDIF.

      IF NOT wa_fac_anex-zfec_doc_core IS INITIAL.
        PERFORM formato_fecha CHANGING wa_fac_anex-zfec_doc_core.
      ENDIF.

      PERFORM conversion CHANGING wa_fac_anex-zdcto_conv .
      PERFORM conversion CHANGING wa_fac_anex-zdcto_esp .
      PERFORM conversion CHANGING wa_fac_anex-zdcto_espt  .
      PERFORM conversion CHANGING wa_fac_anex-zdcto_prom .
      PERFORM conversion CHANGING wa_fac_anex-zdes_ad.
      PERFORM conversion CHANGING wa_fac_anex-zmonto_total.
      PERFORM conversion CHANGING wa_fac_anex-zmonto_uf.
      PERFORM conversion CHANGING wa_fac_anex-zotro_ing.
      PERFORM conversion CHANGING wa_fac_anex-zprec.
      PERFORM conversion CHANGING wa_fac_anex-zrec_ad.
      PERFORM conversion CHANGING wa_fac_anex-ztip_cambio_ref .
      MOVE-CORRESPONDING wa_fac_anex TO wa_anex.
      APPEND wa_anex TO ti_anex.
    ENDLOOP.

    DELETE ti_anex WHERE bukrs IS INITIAL.
    IF NOT ti_anex[] IS INITIAL.
      MODIFY zfac_anex FROM TABLE ti_anex.
      MESSAGE text-001 TYPE 'I'.
    ENDIF.

  ELSE.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                   " BAJAR_ARCHIVO
*&---------------------------------------------------------------------*
*&      Form  CONVERSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_WA_FAC_ANEX_ZDCTO_CONV  text
*----------------------------------------------------------------------*
FORM conversion  CHANGING p_monto.
  REPLACE ALL OCCURRENCES OF '.' IN  p_monto WITH space.
  REPLACE ALL OCCURRENCES OF ',' IN  p_monto WITH '.'.
  CONDENSE p_monto.
ENDFORM.                    " CONVERSION
*&---------------------------------------------------------------------*
*&      Form  BAJAR_ARCHIVO_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bajar_archivo_2 .
  DATA: strarq TYPE string.
  DATA: ti_ped TYPE TABLE OF zcabpedext,
        wa_ped TYPE zcabpedext.
  strarq = p_file.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = strarq
      filetype                = 'ASC'
      has_field_separator     = 'X'
    TABLES
      data_tab                = ti_cab
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
  IF sy-subrc EQ 0.
    LOOP AT ti_cab INTO wa_cab.
      IF NOT wa_cab-fecdoccore IS INITIAL.
        PERFORM formato_fecha CHANGING wa_cab-fecdoccore.
      ENDIF.

      IF NOT wa_cab-fecventes IS INITIAL.
        PERFORM formato_fecha CHANGING wa_cab-fecventes.
      ENDIF.

      IF NOT wa_cab-zfec_cont IS INITIAL.
        PERFORM formato_fecha CHANGING wa_cab-zfec_cont.
      ENDIF.

      IF NOT wa_cab-fecfaccon IS INITIAL.
        PERFORM formato_fecha CHANGING wa_cab-fecfaccon.
      ENDIF.

      IF NOT wa_cab-fec_car IS INITIAL.
        PERFORM formato_fecha CHANGING wa_cab-fec_car.
      ENDIF.

      PERFORM conversion CHANGING wa_cab-ztip_cambio_ref .
      PERFORM conversion CHANGING wa_cab-zmonto_total .

      MOVE-CORRESPONDING wa_cab TO wa_ped.
      APPEND wa_ped TO ti_ped.
    ENDLOOP.

    IF NOT ti_ped[] IS INITIAL.
      MODIFY zcabpedext FROM TABLE ti_ped.
      MESSAGE text-001 TYPE 'I'.
    ENDIF.
  ELSE.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " BAJAR_ARCHIVO_2
*&---------------------------------------------------------------------*
*&      Form  FORMATO_FECHA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_WA_FAC_ANEX_ZFEC_CONT  text
*----------------------------------------------------------------------*
FORM formato_fecha  CHANGING p_fecha.
  DATA: fecha TYPE sy-datum.
  CLEAR fecha.
  REPLACE ALL OCCURRENCES OF '.' IN p_fecha
  WITH space.
  CONDENSE p_fecha.

  CONCATENATE p_fecha+4(4)
              p_fecha+2(2)
              p_fecha(2)
              INTO fecha.

  p_fecha = fecha.
ENDFORM.                    " FORMATO_FECHA
