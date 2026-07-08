*&---------------------------------------------------------------------*
*&  Include           ZMMR_PURCHASE_EST_E01
*&---------------------------------------------------------------------*

START-OF-SELECTION.

PERFORM get_data.
PERFORM get_solped_data.
PERFORM get_aditional_data.
PERFORM process_bom_data.
PERFORM process_solped_data.

IF gt_output[] IS NOT INITIAL.
  PERFORM show_alv.
ELSE.
  MESSAGE e011(z1) WITH text-010.
ENDIF.
