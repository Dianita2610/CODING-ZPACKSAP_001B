*&---------------------------------------------------------------------*
*&  Include           ZFI_RUT_TERCEROS_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK a1 with FRAME TITLE text-001.
  SELECT-OPTIONS: s_bukrs for bkpf-bukrs OBLIGATORY,
                  s_budat for bkpf-budat OBLIGATORY,
                  s_cpudt for bkpf-cpudt ,
                  s_belnr for bkpf-belnr ,
                  s_hkont for bseg-hkont .

  PARAMETERS: p_test as CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK a1.
