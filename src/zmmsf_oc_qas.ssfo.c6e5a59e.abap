CLEAR gv_netpr.

IF is_ekko-waers = 'CLP'.
gv_netpr = gs_esll-brtwr * 100.
ELSE.
gv_netpr = gs_esll-brtwr.
ENDIF.




















