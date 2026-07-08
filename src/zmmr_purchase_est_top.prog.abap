*&---------------------------------------------------------------------*
*&  Include           ZMMR_PURCHASE_EST_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS: slis.

TABLES: zmm_ppto_vta,
        t001w,
        mara,
        lfa1,
        bkpf.

CONSTANTS: gc_ucomm TYPE slis_formname VALUE 'USER_COMMAND',
           gc_x     TYPE c VALUE 'X',
           gc_ktopl TYPE t030-ktopl VALUE 'B100',
           gc_ktosl TYPE t030-ktosl VALUE 'GBB',
           gc_bwmod TYPE t030-bwmod VALUE '0001',
           gc_komok TYPE t030-komok VALUE 'VBR',
           gc_bstyp TYPE ekko-bstyp VALUE 'K',
           gc_zspm  TYPE eban-bsart VALUE 'ZSPM'.

TYPES: BEGIN OF ty_item,
        zorig TYPE char20,
        matnr TYPE matnr,
        maktx TYPE maktx,
        matkl TYPE matkl,
        werks TYPE werks_d,
        konts TYPE saknr,           " Cuenta Gasto
        zcant TYPE zppto13dec2,     " Cantidad
        labst TYPE labst,           " Sum Stock actual
        ebeln TYPE ebeln,           " Contrato Marco
*        ebelp TYPE ebelp,
        netpr TYPE netpr,           " Precio Contrato Marco
        banfn TYPE banfn,
        netwr TYPE bwert,           " Precio ultima compra
        meins TYPE bstme,
        waers TYPE waers,
        lifnr TYPE lifnr,
        name1 TYPE name1_gp,
        stcd1 TYPE stcd1,
        menge TYPE bstmg,           " promedio consumos prod contable 6 meses
        zpexq TYPE bwert,           " P * Q
        zpxqi TYPE bwert,           " P * Q * IVA
       END OF ty_item.

DATA: BEGIN OF gt_makt OCCURS 0,    " Textos breves de material
        matnr TYPE makt-matnr,
        maktx TYPE makt-maktx,
      END OF gt_makt,

      BEGIN OF gt_mara OCCURS 0,
        matnr TYPE mara-matnr,
        matkl TYPE mara-matkl,
      END OF gt_mara,

      BEGIN OF gt_mbew OCCURS 0,
        matnr TYPE mbew-matnr,
        bwkey TYPE mbew-bwkey,
        bwtar TYPE mbew-bwtar,
        bklas TYPE mbew-bklas,
      END OF gt_mbew,

      BEGIN OF gt_mard OCCURS 0,
        matnr TYPE mard-matnr,
        werks TYPE mard-werks,
        lgort TYPE mard-lgort,
        labst TYPE mard-labst,
      END OF gt_mard,

      BEGIN OF gt_ekko OCCURS 0,
        ebeln TYPE ekko-ebeln,
        lifnr TYPE ekko-lifnr,
        waers TYPE ekko-waers,
        kdatb TYPE ekko-kdatb,
        kdate TYPE ekko-kdate,
      END OF gt_ekko,

      BEGIN OF gt_ekpo OCCURS 0,
        ebeln TYPE ekpo-ebeln,
        ebelp TYPE ekpo-ebelp,
        matnr TYPE ekpo-matnr,
        meins TYPE ekpo-meins,
        netpr TYPE ekpo-netpr,
        brtwr TYPE ekpo-brtwr,
        banfn TYPE ekpo-banfn,
        bnfpo TYPE ekpo-bnfpo,
      END OF gt_ekpo,

      BEGIN OF gt_lfa1 OCCURS 0,
        lifnr TYPE lfa1-lifnr,
        name1 TYPE lfa1-name1,
        stcd1 TYPE lfa1-stcd1,
      END OF gt_lfa1,

      BEGIN OF gt_eban OCCURS 0,
        banfn TYPE eban-banfn,
        bnfpo TYPE eban-bnfpo,
        bstyp TYPE eban-bstyp,
        loekz TYPE eban-loekz,
        txz01 TYPE eban-txz01,
        matnr TYPE eban-matnr,
        werks TYPE eban-werks,
        matkl TYPE eban-matkl,
        menge TYPE eban-menge,
        meins TYPE eban-meins,
        preis TYPE eban-preis,
        waers TYPE eban-waers,
        lifnr TYPE eban-lifnr,
        lfdat TYPE eban-lfdat,
      END OF gt_eban,

      BEGIN OF gt_stpo OCCURS 0,
        matnr TYPE mast-matnr,
        werks TYPE mast-werks,
        stlan TYPE mast-stlan,
        stlnr TYPE mast-stlnr,
        stlal TYPE mast-stlal,
        stlkn TYPE stpo-stlkn,
        stpoz TYPE stpo-stpoz,
        idnrk TYPE stpo-idnrk,
        menge TYPE stpo-menge,
      END OF gt_stpo.

DATA: gs_layout TYPE slis_layout_alv,
      gs_variant TYPE disvariant,
      gs_print TYPE slis_print_alv.

DATA: gt_output TYPE TABLE OF zmms_purchase WITH HEADER LINE,
      gt_fieldcat TYPE slis_t_fieldcat_alv,
      gt_events TYPE slis_t_event.

DATA: gt_ppto_vta TYPE STANDARD TABLE OF zmm_ppto_vta,
      gt_mast     TYPE STANDARD TABLE OF mast,
*      gt_stpo     TYPE STANDARD TABLE OF stpo,
      gt_t030     TYPE STANDARD TABLE OF t030,
      gt_ekpo_last LIKE TABLE OF gt_ekpo.

DATA: gs_ppto_vta  LIKE LINE OF gt_ppto_vta,
      gs_ekpo_last LIKE LINE OF gt_ekpo_last,
      gs_stpo      LIKE LINE OF gt_stpo,
      gs_eban      LIKE LINE OF gt_eban,
      gs_mard      LIKE LINE OF gt_mard,
      gs_t030      TYPE t030,
      gs_ekko_last LIKE LINE OF gt_ekko.

DATA: gv_repid TYPE sy-repid.
