CLEAR GV_MAKTX.
SELECT SINGLE MAKTX FROM MAKT INTO GV_MAKTX
  WHERE MATNR = GS_MSEG-MATNR
    AND SPRAS = 'S'.

*SELECT SINGLE zzdescr FROM zunid_prod INTO gv_hd_und_desc
*  WHERE bukrs = is_mseg-bukrs
*    AND zzcod_unidad = is_mseg-zzunid_pro.

  SELECT SINGLE BDTER BDMNG MEINS FROM RESB
    INTO (GV_HD_BDTER, GV_BDMNG, GV_MEINS)
      WHERE RSNUM = GS_MSEG-RSNUM
        AND RSPOS = GS_MSEG-RSPOS
        AND RSART = GS_MSEG-RSART.




















