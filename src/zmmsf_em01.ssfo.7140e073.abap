* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE zzdescr FROM zunid_prod INTO gv_hd_und_desc
*  WHERE bukrs = is_mseg-bukrs
*    AND zzcod_unidad = is_mseg-zzunid_pro.
*
* NEW CODE
SELECT zzdescr
UP TO 1 ROWS  FROM zunid_prod INTO gv_hd_und_desc
  WHERE bukrs = is_mseg-bukrs
    AND zzcod_unidad = is_mseg-zzunid_pro ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

*  SELECT SINGLE BDTER BDMNG MEINS FROM RESB
*    INTO (GV_HD_BDTER, GV_BDMNG, GV_MEINS)
*      WHERE RSNUM = IS_MSEG-RSNUM
*        AND RSPOS = IS_MSEG-RSPOS
*        AND RSART = IS_MSEG-RSART.




















