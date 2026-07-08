DATA: lv_packno TYPE esll-packno.
CLEAR gt_esll.

SELECT SINGLE sub_packno FROM esll INTO lv_packno
  WHERE packno = gs_ekpo-packno.

  IF sy-subrc = 0.
    SELECT * FROM esll INTO TABLE gt_esll
      WHERE packno = lv_packno.
  ENDIF.





















