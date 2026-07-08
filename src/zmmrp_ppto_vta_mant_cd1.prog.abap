*&---------------------------------------------------------------------*
*&  Include           ZMMRP_PPTO_VTA_MANT_CD1
*&---------------------------------------------------------------------*

  CLASS lcl_event_receiver DEFINITION.
    PUBLIC SECTION.
      METHODS:
      handle_toolbar
          FOR EVENT toolbar OF cl_gui_alv_grid
              IMPORTING e_object e_interactive,

      handle_user_command
          FOR EVENT user_command OF cl_gui_alv_grid
              IMPORTING e_ucomm.
    PRIVATE SECTION.
  ENDCLASS.

  CLASS lcl_maintainer DEFINITION.
    PUBLIC SECTION.
      METHODS: begin.
      METHODS: update.

      METHODS revisa_numero
         IMPORTING
            numero TYPE char20
         EXPORTING
            sino   TYPE char2.


  ENDCLASS.
