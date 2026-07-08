"Name: \FU:MB_CREATE_MATERIAL_DOCUMENT\SE:END\EI
ENHANCEMENT 0 ZMM_EHN_INIT_PROD_UND_MSEG.
*
IF sy-tcode EQ 'ML81N'.

CONSTANTS: c_dlort(20) TYPE c VALUE '(SAPLMLSR)ESSR-DLORT',
           c_lifnr(20) TYPE c VALUE '(SAPLMLSR)EKKO-LIFNR'.

FIELD-SYMBOLS: <fs_dlort> TYPE any,
               <fs_lifnr> TYPE any,
               <fs_xmseg> LIKE xmseg.

  ASSIGN (c_dlort) TO <fs_dlort>.
  ASSIGN (c_lifnr) TO <fs_lifnr>.

  LOOP AT xmseg ASSIGNING <fs_xmseg>.
  <fs_xmseg>-zzunid_pro = <fs_dlort>.
  <fs_xmseg>-zzrut_terc = <fs_lifnr>.
  ENDLOOP.

ENDIF.
ENDENHANCEMENT.
