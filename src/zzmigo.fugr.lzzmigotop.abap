FUNCTION-POOL ZZMIGO.                       "MESSAGE-ID ..
TABLES:mkpf, zunid_prod.

CONSTANTS: c_zzunid_pro(25) TYPE c VALUE '(SAPLKACB)COBL-ZZUNID_PRO'.
FIELD-SYMBOLS: <fs_zzunid_pro> TYPE any.

DATA:  SHIFT TYPE char02
      ,arbpl TYPE arbpl.

DATA: maquina     TYPE C LENGTH 8.
DATA: zzunid_pro  type mseg-zzunid_pro.
DATA: lectura_ant TYPE C LENGTH 8.
DATA: w_line_id   TYPE mb_line_id.
DATA: w_aufnr     TYPE aufnr.

TYPES: BEGIN OF ty_mseg.
  INCLUDE TYPE zzmigo_posicion.
TYPES: END OF ty_mseg.

DATA: gt_mseg TYPE TABLE OF zzmigo_posicion.
DATA: gs_mseg LIKE LINE OF  gt_mseg.

DATA: migo_badi_header TYPE MIGO_BADI_EXAMPL. "E_SCREEN_HEAD.
data: v_action         type GOACTION.
