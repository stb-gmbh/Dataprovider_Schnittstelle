*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_F1004 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  READ_QFIELDS_1004
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_QFIELDS_1004.
  DATA: LINES(2) TYPE N
      , IDX TYPE I
      , WA_S1PG LIKE /SIE/HR_IDP_S1PG
      .
  DATA: BEGIN OF LINE_COUNT OCCURS 0.
  DATA: SATZART LIKE /SIE/HR_IDP_S1PG-RECNA.
  DATA: LINES TYPE I.
  DATA: END OF LINE_COUNT.

  LOOP AT G_IFDATA_TRAN-S1PG INTO WA_S1PG.
    LINE_COUNT-SATZART = WA_S1PG-RECNA.
    LINE_COUNT-LINES = 1.
    COLLECT LINE_COUNT.
  ENDLOOP.

*  idx = 0.
*  loop at line_count.
*    idx = idx + line_count-lines.
*  endloop.
  DESCRIBE TABLE LINE_COUNT LINES IDX.

  IF IDX = 0.
    CONCATENATE 'Keine Satzart def.'     "#EC NOTEXT
                SPACE
                INTO /SIE/HR_IDP_QIFC-TEXT20
    SEPARATED BY SPACE.
  ELSE.
    WRITE IDX TO LINES NO-ZERO LEFT-JUSTIFIED.
    CONCATENATE LINES 'Satzarten'                  "#EC NOTEXT
                INTO /SIE/HR_IDP_QIFC-TEXT20
                SEPARATED BY SPACE.
  ENDIF.
ENDFORM.                    " READ_QFIELDS_1004
