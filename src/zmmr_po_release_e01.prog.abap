*&---------------------------------------------------------------------*
*&  Include           ZMMR_PO_RELEASE_E01
*&---------------------------------------------------------------------*

START-OF-SELECTION.

  CREATE OBJECT go_report
    EXPORTING
      iv_tabnam = 'GT_RESULT[]'.

  go_report->get_data( ).
  go_report->process_data( IMPORTING ev_detail = gt_result ).

  IF gt_result[] IS NOT INITIAL.
    go_report->built_alv( ).
  ELSE.
    MESSAGE text-002 TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
