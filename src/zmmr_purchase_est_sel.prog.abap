*&---------------------------------------------------------------------*
*&  Include           ZMMR_PURCHASE_EST_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block01 WITH FRAME TITLE text-001.
SELECT-OPTIONS: so_werks FOR t001w-werks,
                so_matnr FOR mara-matnr,
                so_lifnr FOR lfa1-lifnr ,
                so_gjahr FOR zmm_ppto_vta-gjahr NO INTERVALS NO-EXTENSION,
                so_monat FOR bkpf-monat NO INTERVALS NO-EXTENSION,
                so_versn FOR zmm_ppto_vta-zversion NO INTERVALS NO-EXTENSION.
SELECTION-SCREEN END OF BLOCK block01.
