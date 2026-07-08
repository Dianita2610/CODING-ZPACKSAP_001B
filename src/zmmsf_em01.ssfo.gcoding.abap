*****************************************************
PERFORM     GET_PRINT_LANGUAGE
USING     CONTROL_PARAMETERS
CHANGING  GV_LANGUAGE.
*****************************************************

*Landesabhängige Aufbereitung von Datum und Betrag
*in Tab. t005x steht Aufbereitung
*bei Materialbelegen Land aus Werk ziehen
SET COUNTRY IS_T001W-land1.

*if is_nast-spras     = 'E'.
*  SET COUNTRY 'US'.
*elseif is_nast-spras = 'D'.
*  set country 'DE'.
*endif.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT * FROM mseg INTO TABLE gt_mseg
*  WHERE mblnr = is_mkpf-mblnr
*    AND mjahr = is_mkpf-mjahr.
*
* NEW CODE
SELECT *
 FROM mseg INTO TABLE gt_mseg
  WHERE mblnr = is_mkpf-mblnr
    AND mjahr = is_mkpf-mjahr ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

*dynamic logo

 IF IS_T001W-WERKS = 'CMD1'.
    GV_LOGO_OTROS_CEN = 'MED_NEW'.
 elseif IS_T001W-WERKS = 'SCA1'.
    GV_LOGO_OTROS_CEN = 'MED_NEW'.
 elseif IS_T001W-WERKS = 'ECO1'.
    GV_LOGO_OTROS_CEN = 'MED_NEW'.
 elseif IS_T001W-WERKS = 'ECO1'.
    GV_LOGO_OTROS_CEN = 'MED_NEW'.
 elseif IS_T001W-WERKS = 'CMQ1'.
    GV_LOGO_OTROS_CEN = 'MED_NEW'.
 elseif IS_T001W-WERKS = 'CMDQ'.
    GV_LOGO_OTROS_CEN = 'MED_NEW'.
 elseif IS_T001W-WERKS = 'CMDV'.
    GV_LOGO_OTROS_CEN = 'MED_NEW'.
 elseif IS_T001W-WERKS = 'VMED'.
    GV_LOGO_OTROS_CEN = 'MED_NEW'.
 elseif IS_T001W-WERKS = 'DIA1'.
    GV_LOGO_OTROS_CEN = 'MED_NEW'.
 elseif IS_T001W-WERKS = 'LQUI'.
    GV_LOGO_OTROS_CEN = 'MED_NEW'.
 elseif IS_T001W-WERKS = 'LLIM'.
    GV_LOGO_OTROS_CEN = 'MED_NEW'.
 elseif IS_T001W-WERKS = 'SQUI'.
    GV_LOGO_OTROS_CEN = 'MED_NEW'.
 else.
    GV_LOGO_OTROS_CEN = 'Z_LOGOVI'.

 endif.












 		
