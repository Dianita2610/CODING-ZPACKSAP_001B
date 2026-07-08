*Test system fields
TYPES: BEGIN OF sysinfo,
system       TYPE	cccategory,
fonam	       TYPE	na_fname,
sform	       TYPE	na_fname,
pgnam	       TYPE	na_pgnam,
param     TYPE  char1,
END OF sysinfo.

TYPES: BEGIN OF ty_mseg,
  mblnr TYPE mseg-mblnr,
  mjahr TYPE mseg-mjahr,
  zeile TYPE mseg-zeile,
  matnr TYPE mseg-matnr,
  meins TYPE mseg-meins,
END OF ty_mseg.























