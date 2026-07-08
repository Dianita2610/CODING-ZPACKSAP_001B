*&---------------------------------------------------------------------*
*& Report ZMM_CARGA_OC_SERVICIOS
*&---------------------------------------------------------------------*
*& Transacción: ZMM_C_OC_SRV
*& Descripción: Carga masiva de pedidos de servicios a partir de un CSV
*& Fecha : 27.11.2021
*&---------------------------------------------------------------------*
REPORT zmm_carga_oc_servicios.

INCLUDE zmm_carga_oc_servicios_top.
INCLUDE zmm_carga_oc_servicios_sel.
INCLUDE zmm_carga_oc_servicios_f01.

START-OF-SELECTION.
  DATA: lo_report TYPE REF TO lcl_report.
  CREATE OBJECT lo_report.

  lo_report->cargar_archivo( ).
  lo_report->procesar_archivo( ).

end-of-SELECTION.
  lo_report->generate_out( ).
