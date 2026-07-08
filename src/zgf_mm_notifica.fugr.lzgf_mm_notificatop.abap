FUNCTION-POOL ZGF_MM_NOTIFICA.              "MESSAGE-ID ..

CONSTANTS: gc_copy_mail TYPE tvarvc-name VALUE 'ZMM_COPY_MAIL'.

TABLES: nast, tnapr.

  DATA: BEGIN OF gt_knvk OCCURS 0,
          parnr     TYPE knvk-parnr,
          name1     TYPE knvk-name1,
          prsnr     TYPE knvk-prsnr,
          smtp_addr TYPE adr6-smtp_addr,
        END OF gt_knvk.
