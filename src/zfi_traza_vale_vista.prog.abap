*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <27-12-2019> *
*& Transport Number: < ECDK917006 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFI_TRAZA_VALE_VISTA
*&---------------------------------------------------------------------*
*& Report      : ZFI_TRAZA_VALE_VISTA
*& Autor       : Seidor Crystalis Chile - Felipe Garcia T.
*& Funcional   : Oscar Agudelo
*& Fecha       : 04.05.2015
*& Modificación:
*&---------------------------------------------------------------------

REPORT  ZFI_TRAZA_VALE_VISTA.

TABLES: bse_clr, bseg, reguh, payr.

INCLUDE ZFI_TRAZA_VALE_VISTA_TOP.
"---------------------------------------------------------------------------------------------------------------
* SELECT OPTION
"----------------------------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF SCREEN 101 as subscreen.
 SELECTION-SCREEN begin of block uno WITH FRAME title text-001.
   SELECT-OPTIONS: s_bukr1 FOR bse_clr-bukrs  NO INTERVALS NO-EXTENSION. " sociedad
   SELECT-OPTIONS: s_vblnr FOR payr-VBLNR  NO INTERVALS NO-EXTENSION. " Documento ZP
   SELECT-OPTIONS: s_zaldt FOR payr-zaldt  NO INTERVALS NO-EXTENSION.   " Fecha de pago
   SELECT-OPTIONS  s_rzawe FOR payr-rzawe   NO INTERVALS NO-EXTENSION.  " Via de pago
SELECTION-SCREEN END OF BLOCK uno.
selection-screen end of screen 101.

SELECTION-SCREEN BEGIN OF SCREEN 102 as subscreen.
 SELECTION-SCREEN begin of block dos WITH FRAME title text-002.
SELECT-OPTIONS: s_bukrs FOR bseg-bukrs  NO INTERVALS NO-EXTENSION. " sociedad
SELECT-OPTIONS: s_idvv  FOR REGUH-IDENTIF_PAGO  NO INTERVALS NO-EXTENSION.   " ID VV  " N° de comprobante de pago
SELECTION-SCREEN END OF BLOCK dos.
selection-screen end of screen 102.

SELECTION-SCREEN BEGIN OF SCREEN 103 as subscreen.
 SELECTION-SCREEN begin of block tres WITH FRAME title text-003.
   SELECT-OPTIONS: s_bukr3 FOR bse_clr-bukrs  NO INTERVALS NO-EXTENSION. " sociedad
   SELECT-OPTIONS: s_hbkid FOR payr-hbkid  NO INTERVALS NO-EXTENSION. " banco propio
   SELECT-OPTIONS: s_hktid FOR payr-hktid  NO INTERVALS NO-EXTENSION.   " ID BANCO
   SELECT-OPTIONS  s_rzaw3 FOR payr-rzawe   NO INTERVALS NO-EXTENSION.  " Vida de pago
   SELECT-OPTIONS  s_chect FOR payr-chect  NO INTERVALS NO-EXTENSION.  " numero de cheque
SELECTION-SCREEN END OF BLOCK tres.
selection-screen end of screen 103.

selection-screen begin of tabbed block t1 for 60 lines.
selection-screen tab (30) name1 user-command ucomm1 default screen 101.
selection-screen tab (30) name2 user-command ucomm2 default screen 102.
selection-screen tab (30) name3 user-command ucomm3 default screen 103.
selection-screen end of block t1.

AT SELECTION-SCREEN.

 case sy-dynnr.
    when 1000.
      case sy-ucomm.
        when 'UCOMM1'.
          tabname = 101.
        when 'UCOMM2'.
          tabname = 102.
        when 'UCOMM3'.
          tabname = 103.
      endcase.
  endcase.

INITIALIZATION.

name1 = 'CONSULTA POR COMPROBANTE'.
name2 = 'CONSULTA POR VALE VISTA'.
name3 = 'CONSULTA POR CHEQUE'.

START-OF-SELECTION.

      PERFORM busca_historial.  "Aca ordenar primer alv de historial, para que queden ordenados por ordencon de manera decreciente segun ordencon*

 "Luego aca tan solo concatenar el resto de los registros de la busqueda posterior
  IF s_rzawe-low EQ 'C' OR s_rzaw3-low EQ 'C'. " PARA CHEQUE, itera solo en base a segunsa posterior
     PERFORM busca_posterior_chq.
  ELSE.
     PERFORM busca_posterior.
  ENDIF.
 " concatena ultimo registro, en base al ultimo del alv ( ya sea historico o posterior
     PERFORM ultimo_registro.

  IF gt_alv[] IS NOT INITIAL.

  PERFORM univ_datos. " Universo de datos
  PERFORM llena_alv.  " Luego terminar de llenar el ALV
  PERFORM despliega_alv.

  ELSE.
   MESSAGE 'Vale Vista no registrado.' TYPE 'S'.
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  busca_historial
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM busca_historial.
  DATA: lv_contador     TYPE i,
        lv_n  TYPE i,
        lv_sy TYPE i.

  lv_n = 10000.
  lv_contador = 1.

" siempre habra consulta historica
"-----------------------------------------------------------------------------------------------------------
" PRIMERA CONSULTA
"-----------------------------------------------------------------------------------------------------------
 CASE TABNAME.
 WHEN 101.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*   SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_reguh_PRIMERA
*    FROM reguh
*     WHERE ZBUKR EQ  s_bukr1-low
*      AND  VBLNR EQ  s_vblnr-low
*      AND ZALDT  EQ  s_zaldt-low
*      AND RZAWE  EQ  s_rzawe-low.
*
* NEW CODE
   SELECT *
 INTO CORRESPONDING FIELDS OF TABLE gt_reguh_PRIMERA
    FROM reguh
     WHERE ZBUKR EQ  s_bukr1-low
      AND  VBLNR EQ  s_vblnr-low
      AND ZALDT  EQ  s_zaldt-low
      AND RZAWE  EQ  s_rzawe-low ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

 WHEN 102.
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_REGUH_PRIMERA
*    FROM REGUH
*    WHERE ZBUKR        EQ s_bukrs-low
*      AND IDENTIF_PAGO EQ s_idvv-low.
*
* NEW CODE
    SELECT *
 INTO CORRESPONDING FIELDS OF TABLE gt_REGUH_PRIMERA
    FROM REGUH
    WHERE ZBUKR        EQ s_bukrs-low
      AND IDENTIF_PAGO EQ s_idvv-low ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

 WHEN 103.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE ZBUKR VBLNR GJAHR ZALDT INTO CORRESPONDING FIELDS OF gs_payr_ini
*     FROM PAYR
*      WHERE  ZBUKR EQ s_bukr3-low
*        AND HBKID  EQ s_hbkid-low
*        AND HKTID  EQ s_hktid-low
*        AND RZAWE  EQ s_rzaw3-low
*        AND CHECT  EQ s_chect-low.
*
* NEW CODE
    SELECT ZBUKR VBLNR GJAHR ZALDT
    UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF gs_payr_ini
     FROM PAYR
      WHERE  ZBUKR EQ s_bukr3-low
        AND HBKID  EQ s_hbkid-low
        AND HKTID  EQ s_hktid-low
        AND RZAWE  EQ s_rzaw3-low
        AND CHECT  EQ s_chect-low ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_reguh_PRIMERA
*       FROM reguh
*       WHERE ZBUKR EQ  gs_payr_ini-zbukr
*        AND  VBLNR EQ  gs_payr_ini-vblnr
*         AND ZALDT EQ  gs_payr_ini-zaldt
*         AND RZAWE EQ  S_RZAW3-LOW.
*
* NEW CODE
    SELECT *
 INTO CORRESPONDING FIELDS OF TABLE gt_reguh_PRIMERA
       FROM reguh
       WHERE ZBUKR EQ  gs_payr_ini-zbukr
        AND  VBLNR EQ  gs_payr_ini-vblnr
         AND ZALDT EQ  gs_payr_ini-zaldt
         AND RZAWE EQ  S_RZAW3-LOW ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

 ENDCASE.
"-------------------------------------------------------------------------------------------------------------
" FIN PRIMERA CONSULTA
"-------------------------------------------------------------------------------------------------------------
     IF gt_REGUH_PRIMERA IS INITIAL.
       MESSAGE 'Vale Vista no registrado.' TYPE 'S'.
       EXIT.
     ENDIF.

     READ TABLE gt_reguh_primera INTO gs_reguh INDEX 1.
 " Se identifica Consulta Historica   VBLNR  ZALDT ( BASE )
  DO lv_n TIMES. " itera las lv_n veces, hasta que no existan mas consultas exitosas y realiza un EXIT. del DO TIMES.
    " PRIMERA HISTORICA
    IF lv_contador EQ 1.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT bukrs_clr belnr_clr gjahr_clr bukrs belnr gjahr buzei agzei shkzg dmbtr waers INTO CORRESPONDING FIELDS OF TABLE gt_hist
*      FROM bse_clr
*     WHERE bukrs_clr EQ gs_reguh-zbukr
*      AND belnr_clr  EQ gs_reguh-vblnr
*      AND gjahr_clr  EQ gs_reguh-zaldt+0(4).
*
* NEW CODE
      SELECT bukrs_clr belnr_clr gjahr_clr bukrs belnr gjahr buzei agzei shkzg dmbtr waers
 INTO CORRESPONDING FIELDS OF TABLE gt_hist
      FROM bse_clr
     WHERE bukrs_clr EQ gs_reguh-zbukr
      AND belnr_clr  EQ gs_reguh-vblnr
      AND gjahr_clr  EQ gs_reguh-zaldt+0(4) ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

    ELSE. " SEGUNDA HISTORICA ( ..N HISTORICA )

    IF gt_REGUH[] IS NOT INITIAL. " para nueva consulta historica base
      READ TABLE gt_reguh INTO gs_Reguh INDEX 1.
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT bukrs_clr belnr_clr gjahr_clr bukrs belnr gjahr buzei agzei shkzg dmbtr waers INTO CORRESPONDING FIELDS OF TABLE gt_hist
*       FROM bse_clr
*       WHERE bukrs_clr EQ gs_reguh-zbukr
*         AND belnr_clr EQ gs_reguh-vblnr
*         AND gjahr_clr EQ gs_reguh-zaldt+0(4).
*
* NEW CODE
      SELECT bukrs_clr belnr_clr gjahr_clr bukrs belnr gjahr buzei agzei shkzg dmbtr waers
 INTO CORRESPONDING FIELDS OF TABLE gt_hist
       FROM bse_clr
       WHERE bukrs_clr EQ gs_reguh-zbukr
         AND belnr_clr EQ gs_reguh-vblnr
         AND gjahr_clr EQ gs_reguh-zaldt+0(4) ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

**ins ini
       SORT gt_hist BY bukrs_clr belnr_clr gjahr_clr.
*ins fin
         lv_sy = sy-subrc.
         CLEAR: gt_reguh. " se limpia la tabla aca, ya que en caso de que encuentre datos ya tendre directamente las parejas en la gt_hist
     ELSE.

      " se creo una tabla gt_hist2 ya que si la consulta no contiene datos me borraria la tabla gt_hist, y la necesito
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT bukrs_clr belnr_clr gjahr_clr bukrs belnr gjahr buzei agzei shkzg dmbtr waers INTO CORRESPONDING FIELDS OF TABLE gt_hist2
*        FROM bse_clr FOR ALL ENTRIES IN gt_hist
*         WHERE bukrs_clr   EQ gt_hist-bukrs
*           AND belnr_clr  EQ gt_hist-belnr
*           AND gjahr_clr  EQ gt_hist-gjahr.
*
* NEW CODE
      SELECT bukrs_clr belnr_clr gjahr_clr bukrs belnr gjahr buzei agzei shkzg dmbtr waers
 INTO CORRESPONDING FIELDS OF TABLE gt_hist2
        FROM bse_clr FOR ALL ENTRIES IN gt_hist
         WHERE bukrs_clr   EQ gt_hist-bukrs
           AND belnr_clr  EQ gt_hist-belnr
           AND gjahr_clr  EQ gt_hist-gjahr ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03
**ins ini
       SORT gt_hist2 BY bukrs_clr belnr_clr gjahr_clr.
*ins fin
        lv_sy = sy-subrc.
         " Si es positiva ya tendre el siguiente  historico ( parejas)
            IF lv_sy  EQ 0.
                 gt_hist = gt_hist2[].
             ELSE. "  Si no, deberian estar en la reguh las parejas, borro el belnr para que despues en el LOOP DE LA LINEA 382 en  IF gs_hist-belnr IS INITIAL." SI NO TIENE PAREJA SE ENCUENTRA EN LA REGUH. lo busque ahi
                 DATA: INDEX TYPE I.
                 INDEX = 1.
                 LOOP AT gt_hist INTO gs_hist. "325********
                 gs_hist-bukrs_clr =  gs_hist-bukrs.
                 gs_hist-belnr_clr =  gs_hist-belnr.
                 gs_hist-gjahr_Clr =  gs_hist-gjahr.
                 gs_hist-agzei     =  gs_hist-buzei.
                 gs_hist-bukrs     = SPACE.
                 gs_hist-belnr     = SPACE.
                 gs_hist-gjahr     = SPACE.
*                 gs_hist-buzei     = SPACE.

                  MODIFY gt_hist FROM gs_hist INDEX INDEX.
                   INDEX = INDEX + 1.
                 ENDLOOP." FIN "325********
            ENDIF.

        IF lv_sy NE 0. " si no hay datos se consulta la bseg para completar pareja de documentos
            SELECT BUKRS BELNR GJAHR BUZEI AUGDT AUGCP AUGBL WRBTR LIFNR XREF2 INTO CORRESPONDING FIELDS OF TABLE gt_bseg
             FROM BSEG FOR ALL ENTRIES IN gt_hist
                WHERE  BUKRS EQ gt_hist-bukrs_Clr "s_bukrs-low
                AND BELNR EQ  gt_hist-belnr_clr "   Nº documento " TOMANDO EL CUENTA LINEA 325*****.
                AND GJAHR EQ  gt_hist-gjahr_clr  " Ejercicio    " TOMANDO EL CUENTA LINEA 325 *****.
                AND BUZEI EQ  gt_hist-buzei    "                   "
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK917006*
*                AND XREF2 NE  SPACE.
                AND XREF2 NE  SPACE ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK917006*

          IF sy-subrc NE 0.
            EXIT. " TERMINA PROCESO
          ELSE.
            CLEAR: gt_reguh.
              " Despues se consulta la REGUH
*             READ TABLE gt_bseg INTO gs_bseg INDEX 1.
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*              SELECT *
*              INTO CORRESPONDING FIELDS OF TABLE gt_REGUH
*              FROM REGUH FOR ALL ENTRIES IN GT_BSEG
*              WHERE ZBUKR     EQ  gt_bseg-bukrs
*                AND LIFNR     EQ gs_reguh-LIFNR
*                AND VBLNR     EQ gt_bseg-XREF2.
*
* NEW CODE
              SELECT *

              INTO CORRESPONDING FIELDS OF TABLE gt_REGUH
              FROM REGUH FOR ALL ENTRIES IN GT_BSEG
              WHERE ZBUKR     EQ  gt_bseg-bukrs
                AND LIFNR     EQ gs_reguh-LIFNR
                AND VBLNR     EQ gt_bseg-XREF2 ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03
*                AND ZALDT     EQ gt_bseg-AUGDT. " CAMBIO 07.05.2015
*                AND GJAHR_DEV EQ gt_bseg-GJAHR. " COMENTADO

              IF gt_reguh IS INITIAL.
               EXIT.
              ELSE.
               " SE COMPLETA PAREJA
             ENDIF.

          ENDIF.
        ENDIF. " FIN se consulta la bseg para completar pareja de documentos

    ENDIF.

    ENDIF. " FIN CONTADOR 1

    DATA: lv_belnr_notzero TYPE reguh-belnr_Dev. "bse_clr-belnr_clr.

    IF gt_hist[] IS NOT INITIAL.
      LOOP AT gt_hist INTO gs_hist.
        gs_hist-ordencon = lv_contador.

        IF gs_hist-belnr IS INITIAL." SI NO TIENE PAREJA SE ENCUENTRA EN LA REGUH.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT' "En algunos casos la variable venia con 10 caracteres y no lo encontraba en la siguiente consulta
        EXPORTING
          input         = gs_hist-BELNR_CLR
        IMPORTING
          OUTPUT        = lv_belnr_notzero.

        READ TABLE gt_REGUH INTO gs_reguh WITH KEY ZBUKR      = gs_hist-BUKRS_CLR
                                                   BELNR_DEV  = lv_belnr_notzero "gs_hist-BELNR_CLR
                                                   GJAHR_DEV  = gs_hist-GJAHR_CLR.
        gs_hist-BUKRS =  gs_reguh-zbukr.
        gs_hist-BELNR =  gs_reguh-VBLNR.
        gs_hist-GJAHR =  gs_reguh-zaldt+0(4).
        gs_hist-BUZEI =  SPACE.

        ENDIF.

        MODIFY gt_hist FROM gs_hist TRANSPORTING ordencon BUKRS BELNR GJAHR  WHERE bukrs_clr EQ gs_hist-bukrs_clr
                                                           AND belnr_clr  EQ gs_hist-belnr_clr
                                                           AND gjahr_clr  EQ gs_hist-gjahr_clr
                                                           AND bukrs      EQ gs_hist-bukrs
                                                           AND belnr      EQ gs_hist-belnr
                                                           AND gjahr      EQ gs_hist-gjahr.

        MOVE-CORRESPONDING gs_hist TO gs_alv.
        gs_alv-traza = 'VVISTA'.
        gs_alv-TYPE  =  'H'. " HISTORICO
        APPEND gs_alv TO gt_alv.

      ENDLOOP.
      lv_contador =  lv_contador + 1.

      ELSEIF lv_sy NE 0.
      EXIT.
    ENDIF.

  ENDDO. " FIN ITERACIONES

  SORT gt_alv BY ordencon DESCENDING.

ENDFORM.                    "seleccion_datos
**&---------------------------------------------------------------------*
**&      Form  busca_posterior
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
FORM busca_posterior.
  DATA: lv_contador_p TYPE i,
        lv_n   TYPE i,
        lv_sy  TYPE i,
        LINES  TYPE i,
        lv_reguh_Cont TYPE i,
        flag_reguh(1),
        lv_num_pivote TYPE i.
  lv_n = 10000.
  lv_contador_p = 1.

  gs_Alv-type = 'P'.
"------------------------------------------------------------------------------------------------------------------
" PRINCIPIO ITERACION ( DO TIMES )
"------------------------------------------------------------------------------------------------------------------
 DO lv_n TIMES. " itera las lv_n veces, hasta que no existan mas consultas exitosas y realiza un EXIT. del DO TIMES
"----------------------------------------------------------------------------------------------------------
" ARMA DOCUMENTO PIVOTE
"-----------------------------------------------------------------------------------------------------------
  IF lv_contador_p EQ 1.

 CASE TABNAME.
  WHEN 101.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_reguh
*   FROM reguh
*   WHERE ZBUKR EQ  s_bukr1-low
*    AND  VBLNR EQ  s_vblnr-low
*    AND ZALDT  EQ  s_zaldt-low
*    AND RZAWE  EQ  s_rzawe-low.
*
* NEW CODE
  SELECT *
 INTO CORRESPONDING FIELDS OF TABLE gt_reguh
   FROM reguh
   WHERE ZBUKR EQ  s_bukr1-low
    AND  VBLNR EQ  s_vblnr-low
    AND ZALDT  EQ  s_zaldt-low
    AND RZAWE  EQ  s_rzawe-low ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03


  WHEN 102.
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_REGUH
*    FROM REGUH
*    WHERE ZBUKR        EQ s_bukrs-low
*      AND IDENTIF_PAGO EQ s_idvv-low.
*
* NEW CODE
    SELECT *
 INTO CORRESPONDING FIELDS OF TABLE gt_REGUH
    FROM REGUH
    WHERE ZBUKR        EQ s_bukrs-low
      AND IDENTIF_PAGO EQ s_idvv-low ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

 ENDCASE.

      IF gt_REGUH IS INITIAL.
       MESSAGE 'Vale Vista no registrado.' TYPE 'S'.
       EXIT.
      ENDIF.
      " PRIMERA CONSULTA
"-----------------------------------------------------------------------------------------------------------

*       DESCRIBE TABLE gt_reguh lINES LINES. " ITERA EN BASE LA REGUH
    ELSE.
        " RECORDAR ITERAR EN BASE A CUANDO CONTADOR_P ES MAYOR QUE UNO,
        " EN ESE CASO YA TENDRE UN BLOQUE DE DOCUMENTOS Y PODRE ITERAR EN BASE A ELLOS
       DESCRIBE TABLE gt_alv lINES LINES.
       READ TABLE gt_alv INTO gs_alv INDEX LINES. " orden con de ultimo grupo de documentos agregado
       lv_num_pivote = gs_alv-ordencon.

        CLEAR: gt_alv_aux.
        LOOP AT gt_alv INTO gs_alv WHERE ordencon EQ lv_num_pivote
                                      AND belnr_CLR NE SPACE
                                      AND flag_fin  NE 'X'
                                      AND TYPE EQ 'P'.
          APPEND gs_Alv to gt_Alv_aux.
        ENDLOOP.

        IF gt_Alv_aux IS INITIAL.
           EXIT. " FIN
        ENDIF.

    ENDIF.
"----------------------------------------------------------------------------------------------------------------
" INICIO ITERACIONES POR REGISTRO REGUH (o por gt_Alv_aux, despues de la primera iteracion)
"----------------------------------------------------------------------------------------------------------------
   lv_reguh_Cont = 1.

"----------------------------------------
 " PARA CUANDO CONTADOR = 1.
"----------------------------------------
  IF gt_reguh[] IS NOT INITIAL.  " PARA PRIMERA PESTAÑA EN CASO DE VIA DE PAGO CHEQUE, este bloque no aplica
    READ TABLE gt_reguh INTO gs_reguh INDEX lv_reguh_Cont.
    gv_lifnr = gs_reguh-lifnr.
*    ENDIF.
   IF gs_reguh-FECHA_PAGO IS INITIAL. " Si este campo esta lleno no habra consulta posterior, pero si este campo es vacio se debera consultar si esta lleno el campo REGUH-BELNR_DEV
      IF gs_REGUH-BELNR_DEV  IS NOT INITIAL. "
   " TIRAR LA LOGICA ACA
        PERFORM LOGICA USING gs_Reguh
                             gs_Alv
                             lv_contador_p.

    "-------------------------------------------------------------------------------------------------------------
*          lv_flag = 'X'. " tiene posterior
         ELSE. " Si esta vacio

        ENDIF.

      ELSE.
         EXIT.   " No hay consulta posterior
   ENDIF.

    ELSE.
      CLEAR: gs_reguh.
   ENDIF.

"---------------------------------------------------
" PARA CONTADOR > 1..n
"---------------------------------------------------
 " DESPUES DE HABER ITERADO EN BASE A LA REGUH INICIAL
    IF gt_alv_aux[] IS NOT INITIAL. " ENTRA ALTIRO ACA PARA EL CASO DE CHEQUE
*       READ TABLE gt_alv_Aux INTO gs_alv INDEX lv_reguh_Cont.
        PERFORM LOGICA USING gs_Reguh
                             gs_alv
                             lv_contador_p.

    ENDIF.

  ENDDO.
"------------------------------------------------------------------------------------------------------------------
" FIN ITERACION ( DO TIMES )
"------------------------------------------------------------------------------------------------------------------

ENDFORM.                    "seleccion posteriores


**&      Form  busca_posterior_chq
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
FORM busca_posterior_chq.
  DATA: lv_contador_p TYPE i,
        lv_n   TYPE i,
        lv_sy  TYPE i,
        LINES  TYPE i,
        lv_reguh_Cont TYPE i,
        flag_reguh(1),
        lv_num_pivote TYPE i.
  lv_n = 10000.
  lv_contador_p = 1.

  gs_Alv-type = 'P'.
"------------------------------------------------------------------------------------------------------------------
" PRINCIPIO ITERACION ( DO TIMES )
"------------------------------------------------------------------------------------------------------------------
 DO lv_n TIMES. " itera las lv_n veces, hasta que no existan mas consultas exitosas y realiza un EXIT. del DO TIMES
"----------------------------------------------------------------------------------------------------------
" ARMA DOCUMENTO PIVOTE
"-----------------------------------------------------------------------------------------------------------
  IF lv_contador_p EQ 1.

   CASE tabname.

    WHEN 101 OR 102.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*     SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_reguh
*      FROM reguh
*     WHERE ZBUKR EQ  s_bukr1-low
*      AND  VBLNR EQ  s_vblnr-low
*      AND  ZALDT EQ  s_zaldt-low
*      AND  RZAWE EQ  s_rzawe-low.
*
* NEW CODE
     SELECT *
 INTO CORRESPONDING FIELDS OF TABLE gt_reguh
      FROM reguh
     WHERE ZBUKR EQ  s_bukr1-low
      AND  VBLNR EQ  s_vblnr-low
      AND  ZALDT EQ  s_zaldt-low
      AND  RZAWE EQ  s_rzawe-low ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

    WHEN 103.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_reguh
*       FROM reguh
*       WHERE ZBUKR EQ  gs_payr_ini-zbukr  " viene de consulta historica
*        AND  VBLNR EQ  gs_payr_ini-vblnr
*        AND  ZALDT EQ  gs_payr_ini-zaldt
*        AND  RZAWE EQ  S_RZAW3-LOW.
*
* NEW CODE
      SELECT *
 INTO CORRESPONDING FIELDS OF TABLE gt_reguh
       FROM reguh
       WHERE ZBUKR EQ  gs_payr_ini-zbukr  " viene de consulta historica
        AND  VBLNR EQ  gs_payr_ini-vblnr
        AND  ZALDT EQ  gs_payr_ini-zaldt
        AND  RZAWE EQ  S_RZAW3-LOW ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

  ENDCASE.

      IF gt_REGUH IS INITIAL.
       MESSAGE 'Vale Vista no registrado.' TYPE 'S'.
       EXIT.
*       ELSE.
*         lv_flag = 'X'.
      ENDIF.
      " PRIMERA CONSULTA
"-----------------------------------------------------------------------------------------------------------
*       DESCRIBE TABLE gt_reguh lINES LINES. " ITERA EN BASE LA REGUH
    ELSE.
        " RECORDAR ITERAR EN BASE A CUANDO CONTADOR_P ES MAYOR QUE UNO,
        " EN ESE CASO YA TENDRE UN BLOQUE DE DOCUMENTOS Y PODRE ITERAR EN BASE A ELLOS
       DESCRIBE TABLE gt_alv lINES LINES.
       READ TABLE gt_alv INTO gs_alv INDEX LINES. " orden con de ultimo grupo de documentos agregado
       lv_num_pivote = gs_alv-ordencon.

        CLEAR: gt_alv_aux.
        LOOP AT gt_alv INTO gs_alv WHERE ordencon EQ lv_num_pivote
                                      AND belnr_CLR NE SPACE
                                      AND flag_fin  NE 'X'
                                      AND TYPE EQ 'P'.
          APPEND gs_Alv to gt_Alv_aux.
        ENDLOOP.

        IF gt_Alv_aux IS INITIAL.
           EXIT. " FIN
        ENDIF.

    ENDIF.
"----------------------------------------------------------------------------------------------------------------
" INICIO ITERACIONES POR REGISTRO REGUH (o por gt_Alv_aux, despues de la primera iteracion)
"----------------------------------------------------------------------------------------------------------------
   lv_reguh_Cont = 1.

        IF lv_Contador_p EQ 1.
          READ TABLE gt_reguh INTO gs_reguh INDEX lv_reguh_Cont.
        ENDIF.
           READ TABLE gt_alv_Aux INTO gs_alv INDEX lv_reguh_Cont.
        PERFORM LOGICA_CHQ USING gs_Reguh
                             gs_alv
                             lv_contador_p.

  ENDDO.
"------------------------------------------------------------------------------------------------------------------
" FIN ITERACION ( DO TIMES )
"------------------------------------------------------------------------------------------------------------------

ENDFORM.                    "seleccion posteriores chq

FORM ultimo_registro.
   DATA: lv_lineas TYPE i.

   IF  lv_flag IS INITIAL AND gt_REGUH_PRIMERA IS NOT INITIAL. " SI NO TIENE POSTERIOR; EL ULTIMO REGISTRO SERA EN BASE AL HISTORICO

  " PARA EL ULTIMO REGISTRO ( en base a historial)
    DESCRIBE TABLE gt_Alv LINES lv_lineas.
    READ TABLE gt_Alv INTO gs_Alv INDEX lv_lineas.
*    gs_alv-orden    = 0.
    gs_alv-ordencon = gs_alv-ordencon + 1.
    gs_alv-BUKRS_CLR    = gs_alv-bukrs_clr.
    gs_alv-BELNR_CLR    = gs_alv-belnr_clr.
    gs_alv-GJAHR_CLR    = gs_alv-gjahr_clr.
    gs_alv-BUKRS        = gs_alv-bukrs_clr.
    gs_alv-BELNR        = gs_alv-belnr_clr.
    gs_alv-GJAHR        = gs_alv-GJAHR_CLR.
    gs_alv-BUZEI        = gs_alv-AGZEI.
    gs_alv-SHKZG        = gs_alv-SHKZG.
    gs_alv-DMBTR        = gs_alv-DMBTR.

    APPEND gs_alv TO gt_alv.
   ENDIF.

*     READ TABLE gt_Alv INTO gs_Alv WITH KEY TYPE = 'P'.
*
*     IF sy-subrc NE 0. " si no existen registros posteriores, y la _gs_reguh es inicial,
*                       " esto indica que existiria al menos un registro posterior ( sin pareja)
*
*    IF  lv_flag IS NOT INITIAL AND gt_REGUH IS NOT INITIAL. " SI NO TIENE POSTERIOR; EL ULTIMO REGISTRO SERA EN BASE AL HISTORICO
*
*
*    " PARA EL ULTIMO REGISTRO ( en base a posterior)
*     DESCRIBE TABLE gt_Alv LINES lv_lineas.
*     READ TABLE gt_Alv INTO gs_Alv INDEX lv_lineas.
*     READ TABLE gt_reguh INTO gs_reguh INDEX 1.
*          gs_Alv-ordencon   =  gs_alv-ordencon + 1.
*          gs_alv-BUKRS_CLR     = ''.
*          gs_alv-BELNR_CLR     = ''.
*          gs_alv-GJAHR_CLR     = ''.
*          gs_alv-AGZEI     = SPACE.
*          gs_alv-BUKRS     = gs_reguh-ZBUKR.
*          gs_alv-BELNR     = gs_reguh-BELNR_DEV.
*          gs_alv-GJAHR     = gs_reguh-GJAHR_DEV.
*          gs_alv-BUZEI     = gs_bsak-BUZEI.
*          gs_alv-SHKZG     = gs_bsak-SHKZG.
*          gs_alv-DMBTR     = gs_bsak-WRBTR.
*          gs_alv-flag_fin  = 'X'.
*          gs_alv-traza = 'VVISTA'.
*          APPEND gs_alv TO gt_alv.
*           CLEAR: gs_alv-flag_fin.
*
*    APPEND gs_alv TO gt_alv.
*    ENDIF.
*   ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  univ_datos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM univ_datos.
  "------------------------------------------------------------------------------------
  " GT_BKPF
  "------------------------------------------------------------------------------------
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT bukrs belnr gjahr bvorg INTO CORRESPONDING FIELDS OF TABLE gt_bkpf
*    FROM bkpf FOR ALL ENTRIES IN gt_alv
*    WHERE bukrs   EQ gt_alv-bukrs
*      AND belnr   EQ gt_alv-belnr
*      AND gjahr   EQ gt_alv-gjahr.
*
* NEW CODE
  SELECT bukrs belnr gjahr bvorg
 INTO CORRESPONDING FIELDS OF TABLE gt_bkpf
    FROM bkpf FOR ALL ENTRIES IN gt_alv
    WHERE bukrs   EQ gt_alv-bukrs
      AND belnr   EQ gt_alv-belnr
      AND gjahr   EQ gt_alv-gjahr ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

  SORT gt_bkpf BY bukrs belnr gjahr.
  "------------------------------------------------------------------------------------
  " GT_BSEG
  "------------------------------------------------------------------------------------
  SELECT bukrs belnr gjahr buzei zuonr hkont lifnr xref1 xref2 xref2 xref3 zzmot_emis INTO CORRESPONDING FIELDS OF TABLE gt_bseg
    FROM bseg FOR ALL ENTRIES IN gt_alv
    WHERE bukrs   EQ gt_alv-bukrs
      AND belnr   EQ gt_alv-belnr
      AND gjahr   EQ gt_alv-gjahr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK917006*
*      AND buzei   EQ gt_alv-buzei.
      AND buzei   EQ gt_alv-buzei ORDER BY PRIMARY KEY .
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK917006*
  SORT gt_bseg BY bukrs belnr gjahr buzei.

  "------------------------------------------------------------------------------------
  " GT_BSAS
  "------------------------------------------------------------------------------------
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT bukrs belnr gjahr buzei augdt augbl budat bldat xblnr blart sgtxt INTO CORRESPONDING FIELDS OF TABLE gt_bsas
*   FROM bsas FOR ALL ENTRIES IN gt_alv
*   WHERE bukrs  EQ gt_alv-bukrs
*     AND belnr  EQ gt_alv-belnr
*     AND gjahr  EQ gt_alv-gjahr
*     AND buzei  EQ gt_alv-buzei.
*
* NEW CODE
  SELECT bukrs belnr gjahr buzei augdt augbl budat bldat xblnr blart sgtxt
 INTO CORRESPONDING FIELDS OF TABLE gt_bsas
   FROM bsas FOR ALL ENTRIES IN gt_alv
   WHERE bukrs  EQ gt_alv-bukrs
     AND belnr  EQ gt_alv-belnr
     AND gjahr  EQ gt_alv-gjahr
     AND buzei  EQ gt_alv-buzei ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

  SORT gt_bsas BY bukrs belnr gjahr buzei.
ENDFORM.                    "univ_datos
*&---------------------------------------------------------------------*
*&      Form  llena_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM llena_alv.
  DATA: lv_contador_alv TYPE i,
        lv_pivote       TYPE i,
        gs_alv_next     TYPE ty_alv,
        lv_index        TYPE i.
  DATA: lv_plan_cta TYPE t001-ktopl.

  lv_contador_alv = 1.

  LOOP AT gt_alv INTO gs_alv.
    "------------------------------------------------------------------------------------
    " PARA ASIGNAR NUMERO AL ORDEN DEL HISTORIAL Y POSTERIORES ( CRECIENTE RESPECTIVAMENTE)
    "------------------------------------------------------------------------------------
    lv_pivote = gs_alv-ordencon.
    lv_index  = sy-tabix + 1.

    READ TABLE gt_alv INTO gs_alv_next INDEX lv_index.

    IF lv_pivote EQ gs_alv_next-ordencon.
      gs_alv-orden = lv_contador_alv.
    ELSE.
      gs_alv-orden = lv_contador_alv.
      lv_contador_alv = lv_contador_alv + 1.
    ENDIF.

    IF gs_alv-shkzg EQ 'H'.
      gs_alv-dmbtr = gs_alv-dmbtr * -1.
    ENDIF.

    "---------------------------------------------------------------------------------------
    " AGREGAR BUZEI AL DOCUMENTO BELNR GJHAR  EN CASO DE QUE NO LO TENGA, AGREGADO 14.05.2015
    "---------------------------------------------------------------------------------------
     IF gs_alv-buzei IS INITIAL. " busco el documento en los belnr_Clr de mi tabla gt_Alv
       READ TABLE gt_Alv INTO gs_Alv_aux2 WITH KEY BELNR_CLR = gs_alv-belnr
                                                   GJAHR_CLR = gs_Alv-gjahr.
        gs_Alv-buzei = gs_Alv_aux2-agzei.
     ENDIF.
    "------------------------------------------------------------------------------------
    " BKPF
    "------------------------------------------------------------------------------------

    CLEAR: gs_bkpf.
    READ TABLE gt_bkpf INTO gs_bkpf WITH KEY bukrs = gs_alv-bukrs
                                             belnr = gs_alv-belnr
                                             gjahr = gs_alv-gjahr BINARY SEARCH.

    gs_alv-bvorg = gs_bkpf-bvorg.
    "------------------------------------------------------------------------------------
    " BSEG
    "------------------------------------------------------------------------------------
    CLEAR: gs_bseg.
    READ TABLE gt_bseg INTO gs_bseg WITH KEY bukrs = gs_alv-bukrs
                                             belnr = gs_alv-belnr
                                             gjahr = gs_alv-gjahr
                                             buzei = gs_alv-buzei BINARY SEARCH.

    IF sy-subrc NE 0.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE bukrs belnr gjahr buzei zuonr hkont lifnr xref1 xref2 xref2 xref3 zzmot_emis INTO CORRESPONDING FIELDS OF gs_bseg
*    FROM bseg
*    WHERE bukrs   EQ gs_alv-bukrs
*      AND belnr   EQ gs_alv-belnr
*      AND gjahr   EQ gs_alv-gjahr
*      AND buzei   EQ gs_alv-buzei.
*
* NEW CODE
    SELECT bukrs belnr gjahr buzei zuonr hkont lifnr xref1 xref2 xref2 xref3 zzmot_emis
    UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF gs_bseg
    FROM bseg
    WHERE bukrs   EQ gs_alv-bukrs
      AND belnr   EQ gs_alv-belnr
      AND gjahr   EQ gs_alv-gjahr
      AND buzei   EQ gs_alv-buzei ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

    ENDIF.

      MOVE-CORRESPONDING gs_bseg TO gs_alv.
    "------------------------------------------------------------------------------------
    " BSAS
    "------------------------------------------------------------------------------------
    CLEAR: gs_bsas.
    READ TABLE gt_bsas INTO gs_bsas WITH KEY bukrs = gs_alv-bukrs
                                             belnr = gs_alv-belnr
                                             gjahr = gs_alv-gjahr
                                             buzei = gs_alv-buzei BINARY SEARCH.
    IF sy-subrc NE 0.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE bukrs belnr gjahr buzei augdt augbl budat bldat xblnr blart sgtxt INTO  gs_bsas
*    FROM bsis
*    WHERE bukrs  EQ gs_alv-bukrs
*      AND belnr  EQ gs_alv-belnr
*      AND gjahr  EQ gs_alv-gjahr
*      AND buzei  EQ gs_alv-buzei.
*
* NEW CODE
    SELECT bukrs belnr gjahr buzei augdt augbl budat bldat xblnr blart sgtxt
    UP TO 1 ROWS  INTO  gs_bsas
    FROM bsis
    WHERE bukrs  EQ gs_alv-bukrs
      AND belnr  EQ gs_alv-belnr
      AND gjahr  EQ gs_alv-gjahr
      AND buzei  EQ gs_alv-buzei ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

     ENDIF.

*   MOVE-CORRESPONDING gs_bsas TO gs_alv.
    gs_alv-AUGDT = gs_bsas-augdt.
    gs_alv-BUDAT = gs_bsas-budat.
    gs_alv-BLDAT = gs_bsas-bldat.
    gs_alv-XBLNR = gs_bsas-xblnr.
    gs_alv-BLART = gs_bsas-blart.
    gs_alv-SGTXT = gs_bsas-sgtxt.

    "---------------------------------------------------------------------------------------
    " SKAT
    "---------------------------------------------------------------------------------------
                                                            " T001
    CLEAR: lv_plan_cta.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE ktopl INTO lv_plan_cta
*      FROM t001
*      WHERE bukrs EQ gs_alv-bukrs.
*
* NEW CODE
    SELECT ktopl
    UP TO 1 ROWS  INTO lv_plan_cta
      FROM t001
      WHERE bukrs EQ gs_alv-bukrs ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

    CLEAR: gs_alv-txt50.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE txt50  INTO gs_alv-txt50
*     FROM skat
*     WHERE spras EQ sy-langu
*       AND ktopl EQ lv_plan_cta
*       AND saknr EQ gs_alv-hkont.
*
* NEW CODE
    SELECT txt50
    UP TO 1 ROWS   INTO gs_alv-txt50
     FROM skat
     WHERE spras EQ sy-langu
       AND ktopl EQ lv_plan_cta
       AND saknr EQ gs_alv-hkont ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

    "---------------------------------------------------------------------------------------
                                                            " T003
    "---------------------------------------------------------------------------------------
    CLEAR: gs_alv-ltext.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE ltext INTO gs_alv-ltext
*    FROM t003t
*     WHERE spras EQ sy-langu
*       AND blart EQ gs_alv-blart.
*
* NEW CODE
    SELECT ltext
    UP TO 1 ROWS  INTO gs_alv-ltext
    FROM t003t
     WHERE spras EQ sy-langu
       AND blart EQ gs_alv-blart ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

    "------------------------------------------------------------------------------------
    " PAYR
    "------------------------------------------------------------------------------------
    CLEAR: gs_payr.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE hbkid hktid rzawe chect laufd laufi zaldt  xbanc bancd xbukr voidr
*           voidd voidu INTO CORRESPONDING FIELDS OF gs_payr
*     FROM payr
*      WHERE zbukr EQ gs_alv-bukrs
*        AND vblnr EQ gs_alv-belnr
*        AND gjahr EQ gs_Alv-gjahr.
*
* NEW CODE
    SELECT hbkid hktid rzawe chect laufd laufi zaldt  xbanc bancd xbukr voidr
           voidd voidu
    UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF gs_payr
     FROM payr
      WHERE zbukr EQ gs_alv-bukrs
        AND vblnr EQ gs_alv-belnr
        AND gjahr EQ gs_Alv-gjahr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
*        AND zaldt EQ gs_alv-augdt
*        AND lifnr EQ gs_alv-lifnr.

    MOVE-CORRESPONDING gs_payr TO gs_alv.

     gs_Alv-chectno = gs_Alv-chect.
    " CUANDO EL CAMPO NUM:CHECQUE ES VACIO SE BUSCA ID-VALEVISTA
    IF gs_Alv-chect IS INITIAL.
    PERFORM llena_reguh_vvista USING gs_alv.
    ENDIF.

    " AGREGA A REGISTRO ALV
    MODIFY gt_alv FROM gs_alv TRANSPORTING ORDEN
                                           BUZEI
                                           DMBTR
                                           BVORG " BKPF
                                     ZUONR HKONT LIFNR XREF1 XREF2 XREF2 XREF3 ZZMOT_EMIS " BSEG
                                     AUGDT BUDAT BLDAT XBLNR BLART SGTXT " BSAS
                                     TXT50 LTEXT " t001 "SKAT
                                     HBKID HKTID RZAWE CHECT LAUFD LAUFI ZALDT  XBANC BANCD XBUKR VOIDR VOIDD VOIDU " PAYR
                                     chectno vvistid VV_FechaEnvio VV_Usuario VV_IndPago VV_FechaPago VV_IndDev  VV_FechaDev VV_IndRech
                                     VV_FechaRech  VV_BelnrDev VV_AnioDev VV_IndCust VV_FechaCust VV_MotRech VV_IndEnt
                                     VV_FchEntreg  VV_IndREsct VV_FchREsct    " REGUH VVISTA
                                                 WHERE bukrs_clr EQ gs_alv-bukrs_clr
                                                  AND belnr_clr  EQ gs_alv-belnr_clr
                                                  AND gjahr_clr  EQ gs_alv-gjahr_clr
                                                  AND bukrs      EQ gs_alv-bukrs
                                                  AND belnr      EQ gs_alv-belnr
                                                  AND gjahr      EQ gs_alv-gjahr.
  ENDLOOP.

ENDFORM.                    "llena_alv

FORM llena_1eraposterior USING gt_bsak LIKE gt_bsak
                               gs_reguh LIKE gs_reguh
                               lv_contador_p TYPE i.
    "-----------------------------------------------------------------------------------------------------------------
    IF gt_bsak[] IS NOT INITIAL. " si es exitoso, lleno parejas
     LOOP AT gt_bsak INTO gs_bsak.
          gs_bsak-ordencon = lv_contador_p.

           READ TABLE gt_Alv INTO gs_Alv WITH KEY belnr_clr = gs_bsak-augbl.

           IF sy-subrc NE 0. " si no existe ya agregado, lo agrega,

           MODIFY gt_bsak FROM gs_bsak TRANSPORTING ordencon WHERE AUGDT EQ gs_bsak-augdt
                                                           AND AUGBL  EQ gs_bsak-augbl
                                                           AND BUZEI  EQ gs_bsak-buzei
                                                           AND SHKZG  EQ gs_bsak-shkzg
                                                           AND WRBTR  EQ gs_bsak-wrbtr.


          gs_Alv-ordencon = lv_contador_p.
          gs_alv-BUKRS_CLR = gs_reguh-ZBUKR.  " completo parejas de reguh
          gs_alv-BELNR_CLR = gs_bsak-AUGBL.
          gs_alv-GJAHR_CLR = gs_bsak-AUGDT.
*        	gs_alv-AGZEI     =
          gs_alv-BUKRS     = gs_reguh-ZBUKR.
          gs_alv-BELNR     = gs_reguh-BELNR_DEV.
          gs_alv-GJAHR     = gs_reguh-GJAHR_DEV.
          gs_alv-BUZEI     = gs_bsak-BUZEI.
          gs_alv-SHKZG     = gs_bsak-SHKZG.
          gs_alv-DMBTR     = gs_bsak-WRBTR.
          gs_alv-traza     = 'VVISTA'.
          gs_Alv-type      = 'P'.

         APPEND gs_alv TO gt_alv.
         ENDIF.
      ENDLOOP.
      lv_flag = 'X'. " tiene posterior
      ENDIF.
      CLEAR:GT_REGUH.", GS_REGUH.

ENDFORM.

FORM llena_2daposterior USING gt_bkpf LIKE gt_bkpf
                              gt_bse_clr LIKE gt_bse_clr
                               lv_contador_p TYPE i.

     IF gt_bkpf[] IS NOT INITIAL.
**      LOOP AT gt_bkpf INTO gs_bkpf.
       lv_contador_p = lv_contador_p.
       LOOP AT gt_bse_clr INTO gs_bse_clr.
         gs_bse_Clr-ordencon = lv_contador_p .

         READ TABLE gt_Alv INTO gs_Alv WITH KEY belnr_clr = gs_bse_clr-belnr_clr.

         IF sy-subrc NE 0. " si no existe ya agregado, lo agrega,
          MOVE-CORRESPONDING gs_bse_Clr TO  gs_Alv.
          gs_Alv-type      = 'P'.
          gs_alv-traza = 'VVISTA'.

         APPEND gs_alv TO gt_alv.
         ELSE.

         ENDIF.
       ENDLOOP.

       CLEAR: gt_bse_clr, GT_BSAK.

     ENDIF.

ENDFORM.

FORM itera_reguh USING gt_reguh LIKE gt_reguh
                       gt_bsak_reguh LIKE gt_bsak
                       lv_contador_p TYPE i.

  DATA: lv_contador_ultimo.

  lv_contador_ultimo = lv_contador_p + 1.
  LOOP AT gt_reguh INTO gs_Reguh.

       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT' "En algunos casos la variable venia con 9 caracteres y no lo encontraba en la siguiente consulta
       EXPORTING
          input         = gs_reguh-BELNR_DEV
        IMPORTING
         OUTPUT        = gs_reguh-BELNR_DEV.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*   SELECT BUKRS AUGDT  AUGBL BUZEI SHKZG WRBTR  LIFNR BELNR BUDAT INTO CORRESPONDING FIELDS OF TABLE gt_bsak_reguh
*       FROM bsak
*       WHERE bukrs EQ gs_reguh-zbukr
*        AND LIFNR  EQ gs_reguh-LIFNR
*        AND GJAHR	 EQ gs_reguh-GJAHR_DEV
*        AND BELNR	 EQ gs_reguh-BELNR_DEV.
*
* NEW CODE
   SELECT BUKRS AUGDT  AUGBL BUZEI SHKZG WRBTR  LIFNR BELNR BUDAT
 INTO CORRESPONDING FIELDS OF TABLE gt_bsak_reguh
       FROM bsak
       WHERE bukrs EQ gs_reguh-zbukr
        AND LIFNR  EQ gs_reguh-LIFNR
        AND GJAHR	 EQ gs_reguh-GJAHR_DEV
        AND BELNR	 EQ gs_reguh-BELNR_DEV ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

       IF sy-subrc EQ 0.

          PERFORM llena_1eraposterior USING gt_bsak_reguh
                                            gs_reguh
                                            lv_contador_p.
        ELSE. " si no eta en la bsak lo agrego solo al final

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*           SELECT SINGLE BUZEI SHKZG WRBTR INTO CORRESPONDING FIELDS OF  gs_bsik
*           FROM bsik
*           WHERE bukrs EQ gs_reguh-zbukr
*            AND LIFNR  EQ gs_reguh-LIFNR
*            AND GJAHR  EQ gs_reguh-GJAHR_DEV
*            AND BELNR	 EQ gs_reguh-BELNR_DEV
*            AND XREF2	 EQ gs_reguh-vblnr.
*
* NEW CODE
           SELECT BUZEI SHKZG WRBTR
           UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF  gs_bsik
           FROM bsik
           WHERE bukrs EQ gs_reguh-zbukr
            AND LIFNR  EQ gs_reguh-LIFNR
            AND GJAHR  EQ gs_reguh-GJAHR_DEV
            AND BELNR	 EQ gs_reguh-BELNR_DEV
            AND XREF2	 EQ gs_reguh-vblnr ORDER BY PRIMARY KEY.

           ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

          gs_Alv-ordencon   = lv_contador_p .
          gs_alv-BUKRS_CLR     = ''.
          gs_alv-BELNR_CLR     = ''.
          gs_alv-GJAHR_CLR     = ''.
          gs_alv-AGZEI     = SPACE.
          gs_alv-BUKRS     = gs_reguh-ZBUKR.
          gs_alv-BELNR     = gs_reguh-BELNR_DEV.
          gs_alv-GJAHR     = gs_reguh-GJAHR_DEV.
          gs_alv-BUZEI     = gs_bsik-BUZEI.
          gs_alv-SHKZG     = gs_bsik-SHKZG.
          gs_alv-DMBTR     = gs_bsik-WRBTR.
          gs_alv-flag_fin  = 'X'.
          gs_alv-traza = 'VVISTA'.
          APPEND gs_alv TO gt_alv.
           CLEAR: gs_alv-flag_fin.
       ENDIF.
   ENDLOOP.

     CLEAR: gt_Reguh.


ENDFORM.

FORM LOGICA USING gs_Reguh LIKe gs_reguh
                  gs_alv   LIKE gs_alv
                  lv_contador_p TYPE i.

 "-----------------------------------------------------------------------------------------------------------------
 " PRIMERA POSTERIOR ' ( INICIAL)
 "-----------------------------------------------------------------------------------------------------------------
      If gs_reguh IS NOT INITIAL.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT' "En algunos casos la variable venia con 9 caracteres y no lo encontraba en la siguiente consulta
       EXPORTING
          input         = gs_reguh-BELNR_DEV
        IMPORTING
         OUTPUT        = gs_reguh-BELNR_DEV.

* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT BUKRS AUGDT  AUGBL BUZEI SHKZG WRBTR  LIFNR BELNR BUDAT INTO CORRESPONDING FIELDS OF TABLE gt_bsak
*       FROM bsak
*       WHERE bukrs EQ gs_reguh-zbukr
*        AND LIFNR  EQ gs_reguh-LIFNR
*        AND GJAHR	 EQ gs_reguh-GJAHR_DEV
*        AND BELNR	 EQ gs_reguh-BELNR_DEV.
*
* NEW CODE
      SELECT BUKRS AUGDT  AUGBL BUZEI SHKZG WRBTR  LIFNR BELNR BUDAT
 INTO CORRESPONDING FIELDS OF TABLE gt_bsak
       FROM bsak
       WHERE bukrs EQ gs_reguh-zbukr
        AND LIFNR  EQ gs_reguh-LIFNR
        AND GJAHR	 EQ gs_reguh-GJAHR_DEV
        AND BELNR	 EQ gs_reguh-BELNR_DEV ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

          IF sy-subrc EQ 0.

          PERFORM llena_1eraposterior USING gt_bsak
                                            gs_reguh
                                            lv_contador_p.

          ELSEIF lv_contador_p EQ 1 AND sy-subrc NE 0.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*           SELECT SINGLE BUZEI SHKZG WRBTR INTO CORRESPONDING FIELDS OF  gs_bsik
*           FROM bsik
*           WHERE bukrs EQ gs_reguh-zbukr
*            AND LIFNR  EQ gs_reguh-LIFNR
*            AND GJAHR  EQ gs_reguh-GJAHR_DEV
*            AND BELNR	 EQ gs_reguh-BELNR_DEV
*            AND XREF2	 EQ gs_reguh-vblnr.
*
* NEW CODE
           SELECT BUZEI SHKZG WRBTR
           UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF  gs_bsik
           FROM bsik
           WHERE bukrs EQ gs_reguh-zbukr
            AND LIFNR  EQ gs_reguh-LIFNR
            AND GJAHR  EQ gs_reguh-GJAHR_DEV
            AND BELNR	 EQ gs_reguh-BELNR_DEV
            AND XREF2	 EQ gs_reguh-vblnr ORDER BY PRIMARY KEY.

           ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

          gs_Alv-ordencon   =  lv_contador_p.
          gs_alv-BUKRS_CLR     = ''.
          gs_alv-BELNR_CLR     = ''.
          gs_alv-GJAHR_CLR     = ''.
          gs_alv-AGZEI     = SPACE.
          gs_alv-BUKRS     = gs_reguh-ZBUKR.
          gs_alv-BELNR     = gs_reguh-BELNR_DEV.
          gs_alv-GJAHR     = gs_reguh-GJAHR_DEV.
          gs_alv-BUZEI     = gs_bsik-BUZEI.
          gs_alv-SHKZG     = gs_bsik-SHKZG.
          gs_alv-DMBTR     = gs_bsik-WRBTR.
          gs_alv-flag_fin  = 'X'.
          gs_alv-traza = 'VVISTA'.
          APPEND gs_alv TO gt_alv.
          CLEAR: gs_alv-flag_fin.

          lv_flag = 'X'.  " indica que tiene posterior.
          lv_contador_p = lv_contador_p + 1.
          EXIT.

       ENDIF.
       ENDIF.
"-------------------------------------------------------------------------------------------------------------
" SEGUNDA POSTERIOR
"--------------------------------------------------------------------------------------------------------------
*        IF sy-subrc EQ 0.
        IF gt_bsak IS NOT INITIAL.
          lv_contador_p = lv_contador_p + 1.
*          LOOP AT gt_bsak INTO gs_bsak.
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*            SELECT  BUKRS BELNR GJAHR BLART BUDAT INTO CORRESPONDING FIELDS OF TABLE  gt_bkpf
*            FROM bkpf  FOR ALL ENTRIES IN gt_bsak
*             WHERE BUKRS  EQ gt_bsak-BUKRS
*               AND BELNR  EQ gt_bsak-AUGBL
*               AND GJAHR  EQ gt_bsak-AUGDT+0(4).
*
* NEW CODE
            SELECT BUKRS BELNR GJAHR BLART BUDAT
 INTO CORRESPONDING FIELDS OF TABLE  gt_bkpf
            FROM bkpf  FOR ALL ENTRIES IN gt_bsak
             WHERE BUKRS  EQ gt_bsak-BUKRS
               AND BELNR  EQ gt_bsak-AUGBL
               AND GJAHR  EQ gt_bsak-AUGDT+0(4) ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

              CLEAR: gt_reguh.
            LOOP AT gt_bkpf INTO gs_bkpf.
*            como el resultado es ZP se hace consulta  a la REGUH
             IF  gs_bkpf-BLART EQ 'ZP'.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE * INTO CORRESPONDING FIELDS OF gs_reguh2
*              FROM reguh
*              WHERE ZBUKR EQ gs_bkpf-BUKRS
*                AND LIFNR EQ gs_reguh-LIFNR
*                AND  VBLNR EQ gs_bkpf-BELNR
*                AND ZALDT EQ gs_bkpf-BUDAT
*                AND  BELNR_DEV NE SPACE.
*
* NEW CODE
              SELECT *
              UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF gs_reguh2
              FROM reguh
              WHERE ZBUKR EQ gs_bkpf-BUKRS
                AND LIFNR EQ gs_reguh-LIFNR
                AND  VBLNR EQ gs_bkpf-BELNR
                AND ZALDT EQ gs_bkpf-BUDAT
                AND  BELNR_DEV NE SPACE ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

               IF sy-subrc EQ 0.
               APPEND gs_reguh2 TO gt_reguh. "con la gt_reguh se vuelve a iterar desde la primera posterior ''

                ELSE.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*               SELECT SINGLE BUKRS_CLR BELNR_CLR GJAHR_CLR AGZEI BUKRS BELNR GJAHR BUZEI SHKZG DMBTR INTO CORRESPONDING FIELDS OF gs_bse_clr
*                 FROM bse_clr
*               WHERE BUKRS EQ  gs_bkpf-BUKRS
*                 AND BELNR EQ gs_bkpf-belnr
*                 AND GJAHR EQ gs_bkpf-GJAHR.
*
* NEW CODE
               SELECT BUKRS_CLR BELNR_CLR GJAHR_CLR AGZEI BUKRS BELNR GJAHR BUZEI SHKZG DMBTR
               UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF gs_bse_clr
                 FROM bse_clr
               WHERE BUKRS EQ  gs_bkpf-BUKRS
                 AND BELNR EQ gs_bkpf-belnr
                 AND GJAHR EQ gs_bkpf-GJAHR ORDER BY PRIMARY KEY.

               ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

                 IF sy-subrc EQ 0.

                 APPEND gs_bse_clr TO gt_bse_clr.
                 ELSE.


                       lv_contador_p_fin = lv_contador_p + 1.
                       gs_Alv-ordencon    = lv_contador_p. "_fin.
                       gs_alv-BUKRS     = gs_bkpf-BUKRS.
                       gs_alv-BELNR     = gs_bkpf-BELNR.
                       gs_alv-GJAHR     = gs_bkpf-GJAHR.
*                       gs_alv-BUZEI     = gs_bsak-BUZEI.
*                       gs_alv-SHKZG     = gs_bsak-SHKZG.
*                       gs_alv-DMBTR     = gs_bsak-WRBTR.
                        gs_alv-flag_fin  = 'X'.
                        gs_Alv-type      = 'P'.
                       APPEND gs_alv TO gt_alv.
                       CLEAR: gs_Alv-flag_fin.

                       DELETE GT_BKPF WHERE BUKRS  = gs_bkpf-BUKRS
                                         AND BELNR  = gs_bkpf-BELNR
                                         AND  GJAHR  = gs_bkpf-GJAHR.

                 ENDIF.
               ENDIF.

             ELSE. " Si no, se consulta la bse_Clr
                 " SI NO ES ZP (BSC_CLR)
               "---------------------------------------------------------------------------------------
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*               SELECT SINGLE BUKRS_CLR BELNR_CLR GJAHR_CLR AGZEI BUKRS BELNR GJAHR BUZEI SHKZG DMBTR INTO CORRESPONDING FIELDS OF gs_bse_clr
*                 FROM bse_clr
*               WHERE BUKRS EQ  gs_bkpf-BUKRS
*                 AND BELNR EQ gs_bkpf-belnr
*                 AND GJAHR EQ gs_bkpf-GJAHR.
*
* NEW CODE
               SELECT BUKRS_CLR BELNR_CLR GJAHR_CLR AGZEI BUKRS BELNR GJAHR BUZEI SHKZG DMBTR
               UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF gs_bse_clr
                 FROM bse_clr
               WHERE BUKRS EQ  gs_bkpf-BUKRS
                 AND BELNR EQ gs_bkpf-belnr
                 AND GJAHR EQ gs_bkpf-GJAHR ORDER BY PRIMARY KEY.

               ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

            IF sy-subrc EQ 0.

                APPEND gs_bse_clr TO gt_bse_clr.
             ELSE.
"-----------------------------------------------------------------------------------------------------------
              " AGREGADO DESPUES DE PRIMERA PASADA A PRD
 "------------------------------------------------------------------------------------------------------------
               " AGREGA PAREJA SOLA
                    lv_contador_p_fin = lv_contador_p + 1.
                    gs_Alv-ordencon    = lv_contador_p. "_fin.
                    gs_alv-BUKRS     = gs_bkpf-BUKRS.
                    gs_alv-BELNR     = gs_bkpf-BELNR.
                    gs_alv-GJAHR     = gs_bkpf-GJAHR.
*                       gs_alv-BUZEI     = gs_bsak-BUZEI.
*                       gs_alv-SHKZG     = gs_bsak-SHKZG.
*                       gs_alv-DMBTR     = gs_bsak-WRBTR.
                        gs_alv-flag_fin  = 'X'.
                        gs_Alv-type      = 'P'.
                       APPEND gs_alv TO gt_alv.
                       CLEAR: gs_Alv-flag_fin.

                       DELETE GT_BKPF WHERE BUKRS  = gs_bkpf-BUKRS
                                         AND BELNR  = gs_bkpf-BELNR
                                         AND  GJAHR  = gs_bkpf-GJAHR.


            ENDIF.
             ENDIF.
             ENDLOOP. "

                IF gt_reguh IS NOT INITIAL.
                  PERFORM itera_reguh USING gt_reguh
                                            gt_bsak
                                            lv_contador_p.
                 ENDIF.

                 PERFORM llena_2daposterior USING gt_bkpf
                                gt_bse_clr
                                lv_contador_p.


             lv_flag = 'X'.
*              EXIT.
           ELSEIF sy-subrc NE 0 AND lv_flag NE 'X' .
             lv_contador_p = lv_contador_p + 1.
             EXIT. " TERMINA
        ENDIF.

  "_----------------------------------------------------------------------------------------------------------
  "SEGUNDA POSTERIOR DESPUES DE PRIMERA ITERACION (CONTADOR > 1 )
  "------------------------------------------------------------------------------------------------------------

        IF gt_alv_aux IS NOT INITIAL.
          lv_contador_p = lv_contador_p + 1.
           CLEAR: gt_reguh.
           LOOP AT gt_Alv_Aux INTO gs_Alv_aux.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE BUKRS BELNR GJAHR BLART BUDAT INTO CORRESPONDING FIELDS OF  gs_bkpf
*            FROM bkpf "FOR ALL ENTRIES IN gt_alv_aux
*             WHERE BUKRS  EQ gs_alv_Aux-bukrs_clr
*               AND BELNR  EQ gs_Alv_aux-BELNR_CLR
*               AND GJAHR  EQ gs_alv_aux-GJAHR_CLR.
*
* NEW CODE
            SELECT BUKRS BELNR GJAHR BLART BUDAT
            UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF  gs_bkpf
            FROM bkpf "FOR ALL ENTRIES IN gt_alv_aux
             WHERE BUKRS  EQ gs_alv_Aux-bukrs_clr
               AND BELNR  EQ gs_Alv_aux-BELNR_CLR
               AND GJAHR  EQ gs_alv_aux-GJAHR_CLR ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

*             CLEAR: gt_reguh.
*              LOOP AT gt_bkpf INTO gs_bkpf.
*            como el resultado es ZP se hace consulta  a la REGUH
             IF  gs_bkpf-BLART EQ 'ZP'.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE * INTO CORRESPONDING FIELDS OF gs_reguh2
*              FROM reguh
*              WHERE ZBUKR  EQ gs_bkpf-BUKRS
*                AND LIFNR  EQ gv_lifnr"gs_reguh-LIFNR
*                AND  VBLNR EQ gs_bkpf-BELNR
*                AND ZALDT  EQ gs_bkpf-BUDAT
*                AND  BELNR_DEV NE SPACE.
*
* NEW CODE
              SELECT *
              UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF gs_reguh2
              FROM reguh
              WHERE ZBUKR  EQ gs_bkpf-BUKRS
                AND LIFNR  EQ gv_lifnr"gs_reguh-LIFNR
                AND  VBLNR EQ gs_bkpf-BELNR
                AND ZALDT  EQ gs_bkpf-BUDAT
                AND  BELNR_DEV NE SPACE ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

              IF sy-subrc EQ 0.
               APPEND gs_reguh2 TO gt_reguh. "con la gt_reguh se vuelve a iterar desde la primera posterior ''

                ELSE.

* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*               SELECT SINGLE BUKRS_CLR BELNR_CLR GJAHR_CLR AGZEI BUKRS BELNR GJAHR BUZEI SHKZG DMBTR INTO CORRESPONDING FIELDS OF gs_bse_clr
*                 FROM bse_clr
*               WHERE BUKRS EQ  gs_bkpf-BUKRS
*                 AND BELNR EQ gs_bkpf-belnr
*                 AND GJAHR EQ gs_bkpf-GJAHR.
*
* NEW CODE
               SELECT BUKRS_CLR BELNR_CLR GJAHR_CLR AGZEI BUKRS BELNR GJAHR BUZEI SHKZG DMBTR
               UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF gs_bse_clr
                 FROM bse_clr
               WHERE BUKRS EQ  gs_bkpf-BUKRS
                 AND BELNR EQ gs_bkpf-belnr
                 AND GJAHR EQ gs_bkpf-GJAHR ORDER BY PRIMARY KEY.

               ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

                 IF sy-subrc EQ 0.

                APPEND gs_bse_clr TO gt_bse_clr.
                 ELSE.

                       lv_contador_p_fin = lv_contador_p + 1.
                       gs_Alv-ordencon    = lv_contador_p."_fin.
                       gs_alv-BUKRS_CLR     = gs_bkpf-BUKRS.
                       gs_alv-BELNR_CLR     = gs_bkpf-BELNR.
                       gs_alv-GJAHR_CLR    = gs_bkpf-GJAHR.
                       gs_alv-BUKRS     = gs_bkpf-BUKRS.
                       gs_alv-BELNR     = gs_bkpf-BELNR.
                       gs_alv-GJAHR     = gs_bkpf-GJAHR.
                       gs_alv-BUZEI     = gs_alv_Aux-AGZEI.
                       gs_alv-SHKZG     = gs_alv_aux-SHKZG.
                       gs_alv-DMBTR     = gs_alv_aux-DMBTR.
                        gs_alv-flag_fin  = 'X'.
                        gs_Alv-type      = 'P'.
                       APPEND gs_alv TO gt_alv.
                       CLEAR: gs_Alv-flag_fin.

                       DELETE GT_BKPF WHERE BUKRS  = gs_bkpf-BUKRS
                                         AND BELNR  = gs_bkpf-BELNR
                                         AND  GJAHR  = gs_bkpf-GJAHR.
                  ENDIF.
               ENDIF.
             ELSE. " Si no, se consulta la bse_Clr
               " SI NO ES ZP (BSC_CLR)
               "---------------------------------------------------------------------------------------
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*               SELECT SINGLE BUKRS_CLR BELNR_CLR GJAHR_CLR AGZEI BUKRS BELNR GJAHR BUZEI SHKZG DMBTR INTO CORRESPONDING FIELDS OF gs_bse_clr
*                 FROM bse_clr
*               WHERE BUKRS EQ  gs_bkpf-BUKRS
*                 AND BELNR EQ gs_bkpf-belnr
*                 AND GJAHR EQ gs_bkpf-GJAHR.
*
* NEW CODE
               SELECT BUKRS_CLR BELNR_CLR GJAHR_CLR AGZEI BUKRS BELNR GJAHR BUZEI SHKZG DMBTR
               UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF gs_bse_clr
                 FROM bse_clr
               WHERE BUKRS EQ  gs_bkpf-BUKRS
                 AND BELNR EQ gs_bkpf-belnr
                 AND GJAHR EQ gs_bkpf-GJAHR ORDER BY PRIMARY KEY.

               ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

                 IF sy-subrc EQ 0.

                    APPEND gs_bse_clr TO gt_bse_clr.
                 ELSE.

                       lv_contador_p_fin = lv_contador_p + 1.
                       gs_Alv-ordencon    = lv_contador_p."_fin.
                       gs_alv-BUKRS_CLR     = gs_bkpf-BUKRS.
                       gs_alv-BELNR_CLR     = gs_bkpf-BELNR.
                       gs_alv-GJAHR_CLR    = gs_bkpf-GJAHR.
                       gs_alv-BUKRS     = gs_bkpf-BUKRS.
                       gs_alv-BELNR     = gs_bkpf-BELNR.
                       gs_alv-GJAHR     = gs_bkpf-GJAHR.
                       gs_alv-BUZEI     = gs_alv_Aux-AGZEI.
                       gs_alv-SHKZG     = gs_alv_aux-SHKZG.
                       gs_alv-DMBTR     = gs_alv_aux-DMBTR.
                        gs_alv-flag_fin  = 'X'.
                        gs_Alv-type      = 'P'.
                       APPEND gs_alv TO gt_alv.
                       CLEAR: gs_Alv-flag_fin.

                       DELETE GT_BKPF WHERE BUKRS  = gs_bkpf-BUKRS
                                         AND BELNR  = gs_bkpf-BELNR
                                         AND  GJAHR  = gs_bkpf-GJAHR.
                  ENDIF.
             ENDIF.
             ENDLOOP. "

                IF gt_reguh IS NOT INITIAL.
                  PERFORM itera_reguh USING gt_reguh
                                            gt_bsak
                                            lv_contador_p.
                 ENDIF.

                 PERFORM llena_2daposterior USING gt_bkpf
                                gt_bse_clr
                                lv_contador_p.


             lv_flag = 'X'.
*              EXIT.
           ELSEIF sy-subrc NE 0 AND lv_flag NE 'X' .
             EXIT. " TERMINA
        ENDIF.

ENDFORM.


FORM LOGICA_CHQ USING gs_Reguh LIKe gs_reguh
                  gs_alv   LIKE gs_alv
                  lv_contador_p TYPE i.
"-----------------------------------------------------------------------------------------------------------------
"-------------------------------------------------------------------------------------------------------------
" SEGUNDA POSTERIOR
"--------------------------------------------------------------------------------------------------------------
*        IF sy-subrc EQ 0.
        IF gs_reguh IS NOT INITIAL.
           lv_contador_p = lv_contador_p + 1.
*          LOOP AT gt_bsak INTO gs_bsak.
* BEGIN. 08-07-2026 - ATC - ATC-03
* OLD CODE
*            SELECT  BUKRS BELNR GJAHR BLART BUDAT INTO CORRESPONDING FIELDS OF TABLE  gt_bkpf
*            FROM bkpf  " FOR ALL ENTRIES IN gt_bsak
*             WHERE BUKRS  EQ gs_reguh-zbukr
*               AND BELNR  EQ gs_reguh-vblnr
*               AND GJAHR  EQ gs_reguh-zaldt+0(4).
*
* NEW CODE
            SELECT BUKRS BELNR GJAHR BLART BUDAT
 INTO CORRESPONDING FIELDS OF TABLE  gt_bkpf
            FROM bkpf  " FOR ALL ENTRIES IN gt_bsak
             WHERE BUKRS  EQ gs_reguh-zbukr
               AND BELNR  EQ gs_reguh-vblnr
               AND GJAHR  EQ gs_reguh-zaldt+0(4) ORDER BY PRIMARY KEY.

* END. 08-07-2026 - ATC - ATC-03

              CLEAR: gt_reguh.
            LOOP AT gt_bkpf INTO gs_bkpf.
*            como el resultado es ZP se hace consulta  a la REGUH
             IF  gs_bkpf-BLART EQ 'ZP'.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE * INTO CORRESPONDING FIELDS OF gs_reguh2
*              FROM reguh
*              WHERE ZBUKR EQ gs_bkpf-BUKRS
*                AND LIFNR EQ gs_reguh-LIFNR
*                AND  VBLNR EQ gs_bkpf-BELNR
*                AND ZALDT EQ gs_bkpf-BUDAT
*                AND  BELNR_DEV NE SPACE.
*
* NEW CODE
              SELECT *
              UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF gs_reguh2
              FROM reguh
              WHERE ZBUKR EQ gs_bkpf-BUKRS
                AND LIFNR EQ gs_reguh-LIFNR
                AND  VBLNR EQ gs_bkpf-BELNR
                AND ZALDT EQ gs_bkpf-BUDAT
                AND  BELNR_DEV NE SPACE ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

               IF sy-subrc EQ 0.
               APPEND gs_reguh2 TO gt_reguh. "con la gt_reguh se vuelve a iterar desde la primera posterior ''

                ELSE.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*               SELECT SINGLE BUKRS_CLR BELNR_CLR GJAHR_CLR AGZEI BUKRS BELNR GJAHR BUZEI SHKZG DMBTR INTO CORRESPONDING FIELDS OF gs_bse_clr
*                 FROM bse_clr
*               WHERE BUKRS EQ  gs_bkpf-BUKRS
*                 AND BELNR EQ gs_bkpf-belnr
*                 AND GJAHR EQ gs_bkpf-GJAHR.
*
* NEW CODE
               SELECT BUKRS_CLR BELNR_CLR GJAHR_CLR AGZEI BUKRS BELNR GJAHR BUZEI SHKZG DMBTR
               UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF gs_bse_clr
                 FROM bse_clr
               WHERE BUKRS EQ  gs_bkpf-BUKRS
                 AND BELNR EQ gs_bkpf-belnr
                 AND GJAHR EQ gs_bkpf-GJAHR ORDER BY PRIMARY KEY.

               ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

                 IF sy-subrc EQ 0.

                 APPEND gs_bse_clr TO gt_bse_clr.
                 ELSE.

                       lv_contador_p_fin = lv_contador_p + 1.
                       gs_Alv-ordencon    = lv_contador_p. "_fin.
                       gs_alv-BUKRS     = gs_bkpf-BUKRS.
                       gs_alv-BELNR     = gs_bkpf-BELNR.
                       gs_alv-GJAHR     = gs_bkpf-GJAHR.
*                       gs_alv-BUZEI     = gs_bsak-BUZEI.
*                       gs_alv-SHKZG     = gs_bsak-SHKZG.
*                       gs_alv-DMBTR     = gs_bsak-WRBTR.
                        gs_alv-flag_fin  = 'X'.
                        gs_Alv-type      = 'P'.
                       APPEND gs_alv TO gt_alv.
                       CLEAR: gs_Alv-flag_fin.

                       DELETE GT_BKPF WHERE BUKRS  = gs_bkpf-BUKRS
                                         AND BELNR  = gs_bkpf-BELNR
                                         AND  GJAHR  = gs_bkpf-GJAHR.

                 ENDIF.
               ENDIF.

             ELSE. " Si no, se consulta la bse_Clr
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*               SELECT SINGLE BUKRS_CLR BELNR_CLR GJAHR_CLR AGZEI BUKRS BELNR GJAHR BUZEI SHKZG DMBTR INTO CORRESPONDING FIELDS OF gs_bse_clr
*                 FROM bse_clr
*               WHERE BUKRS EQ  gs_bkpf-BUKRS
*                 AND BELNR EQ gs_bkpf-belnr
*                 AND GJAHR EQ gs_bkpf-GJAHR.
*
* NEW CODE
               SELECT BUKRS_CLR BELNR_CLR GJAHR_CLR AGZEI BUKRS BELNR GJAHR BUZEI SHKZG DMBTR
               UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF gs_bse_clr
                 FROM bse_clr
               WHERE BUKRS EQ  gs_bkpf-BUKRS
                 AND BELNR EQ gs_bkpf-belnr
                 AND GJAHR EQ gs_bkpf-GJAHR ORDER BY PRIMARY KEY.

               ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

                 IF sy-subrc EQ 0.

                 APPEND gs_bse_clr TO gt_bse_clr.
                 ELSE.

                       lv_contador_p_fin = lv_contador_p + 1.
                       gs_Alv-ordencon    = lv_contador_p. "_fin.
                       gs_alv-BUKRS     = gs_bkpf-BUKRS.
                       gs_alv-BELNR     = gs_bkpf-BELNR.
                       gs_alv-GJAHR     = gs_bkpf-GJAHR.
*                       gs_alv-BUZEI     = gs_bsak-BUZEI.
*                       gs_alv-SHKZG     = gs_bsak-SHKZG.
*                       gs_alv-DMBTR     = gs_bsak-WRBTR.
                        gs_alv-flag_fin  = 'X'.
                        gs_Alv-type      = 'P'.
                       APPEND gs_alv TO gt_alv.
                       CLEAR: gs_Alv-flag_fin.

                       DELETE GT_BKPF WHERE BUKRS  = gs_bkpf-BUKRS
                                         AND BELNR  = gs_bkpf-BELNR
                                         AND  GJAHR  = gs_bkpf-GJAHR.

                 ENDIF.
             ENDIF.
             ENDLOOP. "

                IF gt_reguh IS NOT INITIAL.
                  PERFORM itera_reguh USING gt_reguh
                                            gt_bsak
                                            lv_contador_p.
                 ENDIF.

                 PERFORM llena_2daposterior USING gt_bkpf
                                gt_bse_clr
                                lv_contador_p.


             lv_flag = 'X'.
*              EXIT.
           ELSEIF sy-subrc NE 0 AND lv_flag NE 'X' .
             lv_contador_p = lv_contador_p + 1.
             EXIT. " TERMINA
        ENDIF.

        CLEAR: gs_reguh.
  "SEGUNDA POSTERIOR DESPUES DE PRIMERA ITERACION (CONTADOR > 1 )

        IF gt_alv_aux IS NOT INITIAL.
          lv_contador_p = lv_contador_p + 1.
           CLEAR: gt_reguh.
           LOOP AT gt_Alv_Aux INTO gs_Alv_aux.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE BUKRS BELNR GJAHR BLART BUDAT INTO CORRESPONDING FIELDS OF  gs_bkpf
*            FROM bkpf "FOR ALL ENTRIES IN gt_alv_aux
*             WHERE BUKRS  EQ gs_alv_Aux-bukrs_clr
*               AND BELNR  EQ gs_Alv_aux-BELNR_CLR
*               AND GJAHR  EQ gs_alv_aux-GJAHR_CLR.
*
* NEW CODE
            SELECT BUKRS BELNR GJAHR BLART BUDAT
            UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF  gs_bkpf
            FROM bkpf "FOR ALL ENTRIES IN gt_alv_aux
             WHERE BUKRS  EQ gs_alv_Aux-bukrs_clr
               AND BELNR  EQ gs_Alv_aux-BELNR_CLR
               AND GJAHR  EQ gs_alv_aux-GJAHR_CLR ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

*             CLEAR: gt_reguh.
*              LOOP AT gt_bkpf INTO gs_bkpf.
*            como el resultado es ZP se hace consulta  a la REGUH
             IF  gs_bkpf-BLART EQ 'ZP'.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE * INTO CORRESPONDING FIELDS OF gs_reguh2
*              FROM reguh
*              WHERE ZBUKR  EQ gs_bkpf-BUKRS
*                AND LIFNR  EQ gv_lifnr"gs_reguh-LIFNR
*                AND  VBLNR EQ gs_bkpf-BELNR
*                AND ZALDT  EQ gs_bkpf-BUDAT
*                AND  BELNR_DEV NE SPACE.
*
* NEW CODE
              SELECT *
              UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF gs_reguh2
              FROM reguh
              WHERE ZBUKR  EQ gs_bkpf-BUKRS
                AND LIFNR  EQ gv_lifnr"gs_reguh-LIFNR
                AND  VBLNR EQ gs_bkpf-BELNR
                AND ZALDT  EQ gs_bkpf-BUDAT
                AND  BELNR_DEV NE SPACE ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

              IF sy-subrc EQ 0.
               APPEND gs_reguh2 TO gt_reguh. "con la gt_reguh se vuelve a iterar desde la primera posterior ''

                ELSE.
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*               SELECT SINGLE BUKRS_CLR BELNR_CLR GJAHR_CLR AGZEI BUKRS BELNR GJAHR BUZEI SHKZG DMBTR INTO CORRESPONDING FIELDS OF gs_bse_clr
*                 FROM bse_clr
*               WHERE BUKRS EQ  gs_bkpf-BUKRS
*                 AND BELNR EQ gs_bkpf-belnr
*                 AND GJAHR EQ gs_bkpf-GJAHR.
*
* NEW CODE
               SELECT BUKRS_CLR BELNR_CLR GJAHR_CLR AGZEI BUKRS BELNR GJAHR BUZEI SHKZG DMBTR
               UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF gs_bse_clr
                 FROM bse_clr
               WHERE BUKRS EQ  gs_bkpf-BUKRS
                 AND BELNR EQ gs_bkpf-belnr
                 AND GJAHR EQ gs_bkpf-GJAHR ORDER BY PRIMARY KEY.

               ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

                 IF sy-subrc EQ 0.

                APPEND gs_bse_clr TO gt_bse_clr.
                 ELSE.

                       lv_contador_p_fin = lv_contador_p + 1.
                       gs_Alv-ordencon    = lv_contador_p."_fin.
                       gs_alv-BUKRS_CLR     = gs_bkpf-BUKRS.
                       gs_alv-BELNR_CLR     = gs_bkpf-BELNR.
                       gs_alv-GJAHR_CLR    = gs_bkpf-GJAHR.
                       gs_alv-BUKRS     = gs_bkpf-BUKRS.
                       gs_alv-BELNR     = gs_bkpf-BELNR.
                       gs_alv-GJAHR     = gs_bkpf-GJAHR.
                       gs_alv-BUZEI     = gs_alv_Aux-AGZEI.
                       gs_alv-SHKZG     = gs_alv_aux-SHKZG.
                       gs_alv-DMBTR     = gs_alv_aux-DMBTR.
                        gs_alv-flag_fin  = 'X'.
                        gs_Alv-type      = 'P'.
                       APPEND gs_alv TO gt_alv.
                       CLEAR: gs_Alv-flag_fin.

                       DELETE GT_BKPF WHERE BUKRS  = gs_bkpf-BUKRS
                                         AND BELNR  = gs_bkpf-BELNR
                                         AND  GJAHR  = gs_bkpf-GJAHR.
                  ENDIF.
               ENDIF.
             ELSE. " Si no, se consulta la bse_Clr
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
*               SELECT SINGLE BUKRS_CLR BELNR_CLR GJAHR_CLR AGZEI BUKRS BELNR GJAHR BUZEI SHKZG DMBTR INTO CORRESPONDING FIELDS OF gs_bse_clr
*                 FROM bse_clr
*               WHERE BUKRS EQ  gs_bkpf-BUKRS
*                 AND BELNR EQ gs_bkpf-belnr
*                 AND GJAHR EQ gs_bkpf-GJAHR.
*
* NEW CODE
               SELECT BUKRS_CLR BELNR_CLR GJAHR_CLR AGZEI BUKRS BELNR GJAHR BUZEI SHKZG DMBTR
               UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF gs_bse_clr
                 FROM bse_clr
               WHERE BUKRS EQ  gs_bkpf-BUKRS
                 AND BELNR EQ gs_bkpf-belnr
                 AND GJAHR EQ gs_bkpf-GJAHR ORDER BY PRIMARY KEY.

               ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01

                IF sy-subrc EQ 0.

                APPEND gs_bse_clr TO gt_bse_clr.
                 ELSE.

                       lv_contador_p_fin = lv_contador_p + 1.
                       gs_Alv-ordencon    = lv_contador_p."_fin.
                       gs_alv-BUKRS_CLR     = gs_bkpf-BUKRS.
                       gs_alv-BELNR_CLR     = gs_bkpf-BELNR.
                       gs_alv-GJAHR_CLR    = gs_bkpf-GJAHR.
                       gs_alv-BUKRS     = gs_bkpf-BUKRS.
                       gs_alv-BELNR     = gs_bkpf-BELNR.
                       gs_alv-GJAHR     = gs_bkpf-GJAHR.
                       gs_alv-BUZEI     = gs_alv_Aux-AGZEI.
                       gs_alv-SHKZG     = gs_alv_aux-SHKZG.
                       gs_alv-DMBTR     = gs_alv_aux-DMBTR.
                        gs_alv-flag_fin  = 'X'.
                        gs_Alv-type      = 'P'.
                       APPEND gs_alv TO gt_alv.
                       CLEAR: gs_Alv-flag_fin.

                       DELETE GT_BKPF WHERE BUKRS  = gs_bkpf-BUKRS
                                         AND BELNR  = gs_bkpf-BELNR
                                         AND  GJAHR  = gs_bkpf-GJAHR.
                  ENDIF.
             ENDIF.
             ENDLOOP. "

                IF gt_reguh IS NOT INITIAL.
                  PERFORM itera_reguh USING gt_reguh
                                            gt_bsak
                                            lv_contador_p.
                 ENDIF.

                 PERFORM llena_2daposterior USING gt_bkpf
                                gt_bse_clr
                                lv_contador_p.


             lv_flag = 'X'.
*              EXIT.
           ELSEIF sy-subrc NE 0 AND lv_flag NE 'X' .
             EXIT. " TERMINA
        ENDIF.

ENDFORM.


FORM llena_reguh_vvista USING gs_alv TYPE ty_Alv.

  " ARMA RANGO
  clear wa_zaldt.
  CONCATENATE  gs_Alv-gjahr_clr+0(4) '01' '01' INTO wa_zaldt-low.
  CONCATENATE  gs_Alv-gjahr_clr+0(4) '12' '31' INTO wa_zaldt-high.
  wa_zaldt-sign   = 'I'."wa_seatleaf-valsign.
  wa_zaldt-option = 'BT'.
  append wa_zaldt to r_zaldt.

* reguh-HBKID reguh-HKTID reguh-RZAWE   reguh-LAUFD reguh-LAUFI Reguh-ZALDT

  IF gs_Alv-lifnr IS INITIAL.
    READ TABLE gt_Alv INTO gs_Alv_aux2 WITH KEY BELNR_CLR = gs_alv-belnr
                                                GJAHR_CLR = gs_Alv-gjahr
                                                AGZEI     = gs_alv-buzei.
     gs_Alv-lifnr = gs_alv_aux2-lifnr.
  ENDIF.

CLEAR: gs_reguh_vv.
  "Consulta REGUH con los datos del ALV:
* BEGIN. 08-07-2026 - ATC - ATC-01
* OLD CODE
* SELECT SINGLE IDENTIF_PAGO HBKID HKTID RZAWE LAUFD LAUFI ZALDT FECHA_ENVIO USUARIO_ENVIO IND_PAGO
*        FECHA_PAGO IND_DEVUELTO FECHA_DEVUELTO IND_RECHAZO FECHA_RECHAZO BELNR_DEV
*        GJAHR_DEV IND_CUSTODIA FECHA_CUSTODIA MOTIVO_RECHAZO IND_ENTREGADO
*       FECHA_ENTREGADO IND_RESCATADO FECHA_RESCATADO INTO gs_reguh_vv
* FROM REGUH
*  WHERE ZBUKR EQ gs_alv-bukrs_Clr
*     AND LIFNR EQ gs_Alv-lifnr
*     AND VBLNR EQ gs_Alv-belnr_clr
*     AND ( ZALDT GE wa_zaldt-low AND ZALDT LE wa_zaldt-high ).
*
* NEW CODE
 SELECT IDENTIF_PAGO HBKID HKTID RZAWE LAUFD LAUFI ZALDT FECHA_ENVIO USUARIO_ENVIO IND_PAGO
        FECHA_PAGO IND_DEVUELTO FECHA_DEVUELTO IND_RECHAZO FECHA_RECHAZO BELNR_DEV
        GJAHR_DEV IND_CUSTODIA FECHA_CUSTODIA MOTIVO_RECHAZO IND_ENTREGADO
       FECHA_ENTREGADO IND_RESCATADO FECHA_RESCATADO
 UP TO 1 ROWS  INTO gs_reguh_vv
 FROM REGUH
  WHERE ZBUKR EQ gs_alv-bukrs_Clr
     AND LIFNR EQ gs_Alv-lifnr
     AND VBLNR EQ gs_Alv-belnr_clr
     AND ( ZALDT GE wa_zaldt-low AND ZALDT LE wa_zaldt-high ) ORDER BY PRIMARY KEY.

 ENDSELECT.
* END. 08-07-2026 - ATC - ATC-01
*     AND ZALDT EQ r_zaldt.

   gs_Alv-vvistid        = gs_reguh_vv-VV_ValeVista.
   gs_alv-hbkid          = gs_reguh_vv-VV_BANCO.
   gs_alv-hktid          = gs_reguh_vv-VV_IDCTA.
   gs_Alv-rzawe          = gs_reguh_vv-vv_VIAPAGO.     "via_pago
   gs_alv-laufd          = gs_reguh_vv-vv_pagofecha. " ppago_fch
   gs_Alv-laufi          = gs_Reguh_vv-vv_pagoID.       " ppago_id
   gs_Alv-zaldt          = gs_reguh_vv-VV_PPago_Fhp. "      , "ppago_fhp
   gs_alv-VV_FechaEnvio  = gs_reguh_vv-VV_FechaEnvio.
   gs_alv-VV_Usuario     = gs_reguh_vv-VV_Usuario.
   gs_alv-VV_IndPago     = gs_reguh_vv-VV_IndPago.
   gs_alv-VV_FechaPago   = gs_reguh_vv-VV_FechaPago.
   gs_alv-VV_IndDev      = gs_reguh_vv-VV_IndDev.
   gs_alv-VV_FechaDev    = gs_reguh_vv-VV_FechaDev.
   gs_alv-VV_IndRech     = gs_reguh_vv-VV_IndRech.
   gs_alv-VV_FechaRech   = gs_reguh_vv-VV_FechaRech.
   gs_alv-VV_BelnrDev    = gs_reguh_vv-VV_BelnrDev.
   gs_alv-VV_AnioDev     = gs_reguh_vv-VV_AnioDev.
   gs_alv-VV_IndCust     = gs_reguh_vv-VV_IndCust.
   gs_alv-VV_FechaCust   = gs_reguh_vv-VV_FechaCust.
   gs_alv-VV_MotRech     = gs_reguh_vv-VV_MotRech.
   gs_alv-VV_IndEnt      =  gs_reguh_vv-VV_IndEnt.
   gs_alv-VV_FchEntreg   = gs_reguh_vv-VV_FchEntreg.
   gs_alv-VV_IndREsct    = gs_reguh_vv-VV_IndREsct.
   gs_alv-VV_FchREsct    = gs_reguh_vv-VV_FchREsct.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  frm_pf_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM frm_pf_status USING rt_extab TYPE slis_t_extab.
*  First i copy PF-STATUS SAPLKKBL STANDARD_FULLSCREEN
  SET PF-STATUS 'ZSTANDARD' .
ENDFORM.                    "FRM_PF_STATUS.
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       User_command del alv principal
*----------------------------------------------------------------------*
FORM user_command_1 USING r_ucomm LIKE sy-ucomm
      rs_selfield TYPE slis_selfield.
  "marca el checkbox si fue seleccionado
  IF ref_grid IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ref_grid.
  ENDIF.

  IF NOT ref_grid IS INITIAL.
    CALL METHOD ref_grid->check_changed_data.
  ENDIF.

  CASE r_ucomm.

  ENDCASE.
ENDFORM.                    "USER_COMMAND

**&---------------------------------------------------------------------*
**&      Form  DESPLIEGA_ALV
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
FORM despliega_alv.

  ASSIGN gt_alv[] TO <tabla>[].

  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = gr_table
        CHANGING  t_table      = <tabla>[] ).
    CATCH cx_salv_msg.                                  "#EC NO_HANDLER
  ENDTRY.
*  "copiar status gui de function group SALV_METADATA_STATUS
*  "and copy the gui status SALV_TABLE_STANDARD into the program.
**  "se80 -> grupo de funciones -> status gui ->boton derecho copiar

  gr_table->set_screen_status(
    pfstatus      = 'ZSTANDARD'
    report        = sy-repid
    set_functions = gr_table->c_functions_all ).

**... optimize the column widths
  TRY.
      lr_columns = gr_table->get_columns( ).
      lr_columns->set_optimize( 'X' ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  gr_events = gr_table->get_event( ).

*  * Set up selections.
  gr_selections = gr_table->get_selections( ).
  "none(0) Single(1) multiple (2) cell selection(3) row_column(4)
  gr_selections->set_selection_mode( 4 ).

* Habilita las funciones del alv
  gr_functions = gr_table->get_functions( ).
  gr_functions->set_all( abap_true ).

**      &ALL
*      TRY.
*        CALL METHOD gr_functions->set_function
*          EXPORTING
*            name    = '&ALL'
*            boolean = space.
*        CATCH cx_salv_not_found .
*        CATCH cx_salv_wrong_call .
*      ENDTRY.
*
*      DATA: l_icon TYPE string.
*      DATA: l_text TYPE string.
*
**      l_icon = icon_select_all.

*      TRY.
*          l_text = 'select_all'.
*          gr_functions->add_function(
*            name     = 'SET_ROWS'
*            icon     = l_icon
**          text     = l_text
*            tooltip  = l_text
*            position = if_salv_c_function_position=>right_of_salv_functions ).
*        CATCH cx_salv_wrong_call cx_salv_existing.
*      ENDTRY.

  gr_display = gr_table->get_display_settings( ).
  gr_display->set_striped_pattern( cl_salv_display_settings=>true ).
  gr_display->set_list_header( 'Traza de Pagos' ).

  TRY.

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'ORDEN' )."
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'OrdenALV' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'ORDENCON' )."
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( '#CON' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BUKRS_CLR' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Sociedad' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BELNR_CLR' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'N°Doc.Comp.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'GJAHR_CLR' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Año Comp.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'AGZEI' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Pos. Comp.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BUKRS' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Soc. Ini.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BELNR' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Doc. Ini.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'GJAHR' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Fecha Ini.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BUZEI' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Pos. Ini' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'SHKZG' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'S/H' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'DMBTR' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Importe' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BVORG' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'ID. Multisociedad' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'ZUONR' ).
        gr_column->set_long_text( ' ' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Asignacion' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'HKONT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Cuenta' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'LIFNR' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Acreedor' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'XREF1' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'ClaveRef-1' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'XREF2' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'ClaveRef-2' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'XREF3' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'ClaveRef-3' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'ZZMOT_EMIS' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Mot. Emision' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'AUGDT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Fecha Comp.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BUDAT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Fecha Cont.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BLDAT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Fecha Docm.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'XBLNR' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Referencia' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BLART' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Clase Doc.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'LTEXT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Nombre Doc.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'LTEXT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Nombre Cta.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'SGTXT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Texto Posicion' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'HBKID' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Banco' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'HKTID' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'ID Cta.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'RZAWE' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Via Pago' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'CHECT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'No. Cheque' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'LAUFD' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'PPago Fch' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'LAUFI' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'PPago ID' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'ZALDT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'PPago Fhp' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'XBANC' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Chq. Cob.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'BANCD' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Fch. Cobro' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'XBUKR' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Chq. Multisoc.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VOIDR' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Anula Chq.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VOIDD' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Anula fch. Chq.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VOIDU' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Anula Chq. Usu.' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'TYPE' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Modo' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

         gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'TRAZA' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'Traza' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres


        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VVISTID' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'ID-ValeVista' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'CHECTNO' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'No.Cheque' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_FECHAENVIO' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-FechaEnvio' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_USUARIO' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-Usuario' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

         gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_INDPAGO' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-IndPago' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_FECHAPAGO' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-FechaPago' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_INDDEV' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-IndDev' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_FECHADEV' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-FechaDev' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_INDRECH' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-IndRech' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_FECHARECH' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-FechaRech' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

         gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_BELNRDEV' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-BelnrDev' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_ANIODEV' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-AnioDev' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_INDCUST' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-IndCust' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_FECHACUST' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-FechaCust' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_MOTRECH' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-MotRech' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_INDENT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-INDENT' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

         gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_FCHENTREG' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-FCHENTREG' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_INDRESCT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-IndREsct' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'VV_FCHRESCT' ).
        gr_column->set_long_text( '' )." Máximo 40 caracteres
        gr_column->set_medium_text( 'VV-FchREsct' ). "Máx 20 caractere
        gr_column->set_short_text( ' ' ). "Máx 10 caracteres

    CATCH cx_salv_not_found
    .
  ENDTRY.

"--------------------------------------------------------------------------------------------------------------
* OCULTA COLUMNAS
"--------------------------------------------------------------------------------------------------------------
  TRY.
            gr_column ?= gr_columns->get_column( 'FLAG_FIN'  ).
            gr_column->set_visible( abap_false ).
            gr_column ?= gr_columns->get_column( 'WAERS'  ).
            gr_column->set_visible( abap_false ).


        catch cx_salv_not_found .
 ENDTRY.

"-----------------------------------------------------------------------------------------------------------------
" FORMATEA A CLP
"------------------------------------------------------------------------------------------------------------------
  TRY.
        gr_columns = gr_table->get_columns( ).
        gr_column ?= gr_columns->get_column( 'DMBTR' ).       gr_column->set_currency_column( 'WAERS' ).

    CATCH cx_salv_not_found.
  ENDTRY."SET_moneda
"-------------------------------------------------------------------------------------------------------------
" PINTA COLUMNAS
"-------------------------------------------------------------------------------------------------------------
  gr_column ?= gr_columns->get_column( 'BUKRS' ).
  color-col = '7'.color-int = '0'.color-inv = '0'.
  gr_column->set_color( color ).

  gr_column ?= gr_columns->get_column( 'BELNR' ).
  color-col = '7'.color-int = '0'.color-inv = '0'.
  gr_column->set_color( color ).

  gr_column ?= gr_columns->get_column( 'GJAHR' ).
  color-col = '7'.color-int = '0'.color-inv = '0'.
  gr_column->set_color( color ).

  gr_column ?= gr_columns->get_column( 'BUZEI' ).
  color-col = '7'.color-int = '0'.color-inv = '0'.
  gr_column->set_color( color ).
*  try.
*  gr_sorts = gr_table->get_sorts( ).
*  gr_sorts->add_sort( columnname = 'CITYTO' subtotal = abap_true ).
*  gr_agg = gr_table->get_aggregations( ).
*
*  gr_agg->add_aggregation( 'DISTANCE' ).
*  catch cx_salv_not_found cx_salv_existing cx_salv_data_error.
*  endtry.

*  gr_filter = gr_table->get_filters( ).
*  gr_filter->add_filter( columnname = 'CARRID' low = 'LH' ).
**
"-----------------------------------------------------------------------------------------------------------------
" CUENTA FILAS
"-----------------------------------------------------------------------------------------------------------------
  DATA: nfilas(10) TYPE c.
  DATA: nfilas1 TYPE i.
  DESCRIBE TABLE gt_alv LINES  nfilas1.
  MOVE nfilas1 TO nfilas.
  DATA: vl_texto(25) TYPE c.
  CONCATENATE 'Número de filas' nfilas INTO vl_texto SEPARATED BY space.
  MESSAGE vl_texto TYPE 'S'.
  gr_layout = gr_table->get_layout( ).
  key-report = sy-repid.
  gr_layout->set_key( key ).

  gr_layout->set_save_restriction( cl_salv_layout=>restrict_none ).
"-----------------------------------------------------------------------------------------------------------------
" DESPLIEGA ALV
"-----------------------------------------------------------------------------------------------------------------
  gr_table->display( ).
*  ELSE.
*    gr_table->refresh( ).
* ENDIF.

ENDFORM.                    "DESPLIEGA_ALV
