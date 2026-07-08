*&---------------------------------------------------------------------*
*&  Include           ZFI_CARGA_CHEQUES_TOP
*&---------------------------------------------------------------------*
TYPES: BEGIN OF t_entrada,
          bukrs   TYPE payr-zbukr,
          hbkid   TYPE payr-hbkid,
          hktid   TYPE payr-hktid,
          chect   TYPE payr-chect,
          vblnr   TYPE bkpf-xref1_hd,
          gjahr   TYPE payr-gjahr,
          znme1   type payr-znme1,
       END OF t_entrada.

DATA: ti_entrada TYPE TABLE OF t_entrada,
      wa_entrada TYPE t_entrada.

DATA: bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
*     messages of call transaction
DATA: messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
*       error session opened (' ' or 'X')
DATA: ctumode TYPE c VALUE 'N',
      cupdate TYPE c VALUE 'L'.

TYPES : BEGIN OF t_balmi,
      msgty TYPE balmi-msgty,
      msgid TYPE balmi-msgid,
      msgno TYPE balmi-msgno,
      msgv1 TYPE char100,
      msgv2  TYPE char100,
      msgv3  TYPE char100,
      msgv4  TYPE char100,
      altext TYPE balmi-altext,
      userexitp TYPE balmi-userexitp,
      userexitf TYPE balmi-userexitf,
      detlevel TYPE balmi-detlevel,
      probclass TYPE balmi-probclass,
      alsort TYPE balmi-alsort,
      END OF t_balmi.

DATA:  ti_log        TYPE TABLE OF t_balmi,
       wa_log        TYPE t_balmi.
