*&---------------------------------------------------------------------*
*&  Include           ZMMRP_PPTO_VTA_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS: truxs,
            slis,
            icon.

TABLES: zmm_ppto_vta,
        mara,
        t001w.

CONSTANTS: gc_begin_row TYPE i VALUE 1,
           gc_end_row TYPE i VALUE 9999.

TYPES: BEGIN OF ty_ppto,
      matnr   TYPE matnr,
      versn   TYPE char02,
      werks   TYPE werks_d,
      gjahr   TYPE gjahr,
      month01 TYPE zppto13dec2,
      month02 TYPE zppto13dec2,
      month03 TYPE zppto13dec2,
      month04 TYPE zppto13dec2,
      month05 TYPE zppto13dec2,
      month06 TYPE zppto13dec2,
      month07 TYPE zppto13dec2,
      month08 TYPE zppto13dec2,
      month09 TYPE zppto13dec2,
      month10 TYPE zppto13dec2,
      month11 TYPE zppto13dec2,
      month12 TYPE zppto13dec2,
      END OF ty_ppto.

DATA: BEGIN OF gt_msg OCCURS 1,
       msgtyp        TYPE bdcmsgcoll-msgtyp,
       icon(4)       TYPE c,
       mstring(480)  TYPE c,
       row(2)        TYPE c,
      END OF gt_msg,

      gs_msg LIKE LINE OF gt_msg.

DATA: gt_ppto TYPE STANDARD TABLE OF ty_ppto,
      gs_ppto LIKE LINE OF gt_ppto.

DATA: gt_ppto_vta TYPE STANDARD TABLE OF zmm_ppto_vta,
      gs_ppto_vta TYPE zmm_ppto_vta.

DATA: gv_filename TYPE rlgrap-filename.

DATA: gt_mara  TYPE STANDARD TABLE OF mara,
      gt_t001w TYPE STANDARD TABLE OF t001w.

DATA: gv_pos   TYPE sy-tabix,
      gv_check TYPE sy-subrc.
