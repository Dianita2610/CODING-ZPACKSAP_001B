*&---------------------------------------------------------------------*
*&  Include           ZXM06TOP
*&---------------------------------------------------------------------*
CONSTANTS: gc_bsart_mail TYPE tvarvc-name VALUE 'ZMM_BSART_MAIL'.

DATA: gt_tvarvc TYPE STANDARD TABLE OF tvarvc,
      gs_tvarvc TYPE tvarvc.

RANGES: rg_bsart_mail FOR ekko-bsart.
