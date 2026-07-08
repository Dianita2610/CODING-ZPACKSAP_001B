"Name: \FU:CKMV_AC_DOCUMENT_CREATE\SE:BEGIN\EI
ENHANCEMENT 0 ZMM_EHN_INIT_PROD_UND.
*
IF sy-tcode EQ 'ML81N'.

CONSTANTS: c_dlort(20) TYPE c VALUE '(SAPLMLSR)ESSR-DLORT',
           c_lifnr(20) TYPE c VALUE '(SAPLMLSR)EKKO-LIFNR'.

FIELD-SYMBOLS: <fs_dlort> TYPE any,
               <fs_lifnr> TYPE any,
               <fs_accit> TYPE accit.

  ASSIGN (c_dlort) TO <fs_dlort>.
  ASSIGN (c_lifnr) TO <fs_lifnr>.

  LOOP AT t_accit ASSIGNING <fs_accit>.
  <fs_accit>-zzunid_pro = <fs_dlort>.
  <fs_accit>-zzrut_terc = <fs_lifnr>.
  ENDLOOP.

ELSEIF sy-tcode EQ 'MI07'.

  DATA: rg_bschl TYPE RANGE OF bschl,
        wa_bschl LIKE LINE OF rg_bschl.

  wa_bschl-sign = 'I'.
  wa_bschl-option = 'EQ'.

  wa_bschl-low = '81'.
  APPEND wa_bschl TO rg_bschl.

  wa_bschl-low = '91'.
  APPEND wa_bschl TO rg_bschl.

  LOOP AT t_accit ASSIGNING <fs_accit> WHERE bschl IN rg_bschl.
  <fs_accit>-zzunid_pro = '0000000091'.
  ENDLOOP.

ENDIF.

ENDENHANCEMENT.
