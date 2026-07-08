*&---------------------------------------------------------------------*
*&  Include           ZMMRP_PPTO_VTA_MANT_E01
*&---------------------------------------------------------------------*

START-OF-SELECTION.
  CREATE OBJECT go_maintainer.
  CALL FUNCTION 'MESSAGES_INITIALIZE'.
  CALL METHOD go_maintainer->begin.
  CALL METHOD go_maintainer->update.

END-OF-SELECTION.
