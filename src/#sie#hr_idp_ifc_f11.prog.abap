*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_F11                                        *
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  WRITE_MATRIX_1001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM WRITE_MATRIX_1001.

  DATA: WA_MATRIX TYPE /SIE/HR_IDP_S1R.

  DATA: L_WORK_S1R TYPE /SIE/HR_IDP_S1R.

  LOOP AT G_IFDATA_TRAN-S1R INTO L_WORK_S1R WHERE TROLE <= 7.
    DELETE TABLE G_IFDATA_TRAN-S1R FROM L_WORK_S1R.
  ENDLOOP.

  LOOP AT G_MATRIX INTO WA_MATRIX.
    MOVE-CORRESPONDING WA_MATRIX TO L_WORK_S1R.
    APPEND L_WORK_S1R TO G_IFDATA_TRAN-S1R.
  ENDLOOP.

ENDFORM.                    " WRITE_MATRIX_1001

*&---------------------------------------------------------------------*
*&      Form  FIND_LAST_CHANGE_1001
*&---------------------------------------------------------------------*
*       Diese Routine findet den letzten änderer von allen
*       Teilobjekten auf dem 1001 Dynpro.
*----------------------------------------------------------------------*
*      <--P_ADMIN  Letzter änderer
*----------------------------------------------------------------------*
FORM FIND_LAST_CHANGE_1001 CHANGING P_ADMIN TYPE /SIE/HR_IDP_ADM.

  DATA: L_ITAB_ADM TYPE STANDARD TABLE OF /SIE/HR_IDP_ADM INITIAL SIZE 0
      , L_WA_ADM TYPE /SIE/HR_IDP_ADM
      , L_WA_S1R TYPE /SIE/HR_IDP_S1R
      .

  CLEAR L_ITAB_ADM.

* S1
  MOVE-CORRESPONDING G_IFDATA_TRAN-S1 TO L_WA_ADM.
  APPEND L_WA_ADM TO L_ITAB_ADM.

* S1T
  MOVE-CORRESPONDING G_IFDATA_TRAN-S1T TO L_WA_ADM.
  APPEND L_WA_ADM TO L_ITAB_ADM.

* S1VN
  MOVE-CORRESPONDING G_IFDATA_TRAN-S1VN TO L_WA_ADM.
  APPEND L_WA_ADM TO L_ITAB_ADM.

* S1R
  LOOP AT G_IFDATA_TRAN-S1R INTO L_WA_S1R.
    MOVE-CORRESPONDING L_WA_S1R TO L_WA_ADM.
    APPEND L_WA_ADM TO L_ITAB_ADM.
  ENDLOOP.

  SORT L_ITAB_ADM DESCENDING BY DATUM UZEIT.
  READ TABLE L_ITAB_ADM INDEX 1 INTO L_WA_ADM.
  IF SY-SUBRC = 0.
    MOVE-CORRESPONDING L_WA_ADM TO P_ADMIN.
  ELSE.
    CLEAR P_ADMIN.
  ENDIF.

ENDFORM.                    " FIND_LAST_CHANGE_1001

FORM FIND_LAST_CHANGE_1004 CHANGING P_ADMIN TYPE /SIE/HR_IDP_ADM.

  DATA: L_ITAB_ADM TYPE STANDARD TABLE OF /SIE/HR_IDP_ADM INITIAL SIZE 0
      , L_WA_ADM TYPE /SIE/HR_IDP_ADM
      , L_WA_S1PG TYPE /SIE/HR_IDP_S1PG
      .

  CLEAR L_ITAB_ADM.
*break mch0664.
* S1PG
  LOOP AT G_IFDATA_TRAN-S1PG INTO L_WA_S1PG.
    MOVE-CORRESPONDING L_WA_S1PG TO L_WA_ADM.
    APPEND L_WA_ADM TO L_ITAB_ADM.
  ENDLOOP.

  SORT L_ITAB_ADM DESCENDING BY DATUM UZEIT.
  READ TABLE L_ITAB_ADM INDEX 1 INTO L_WA_ADM.
  IF SY-SUBRC = 0.
    MOVE-CORRESPONDING L_WA_ADM TO P_ADMIN.
  ELSE.
    CLEAR P_ADMIN.
  ENDIF.

ENDFORM.

FORM FIND_LAST_CHANGE_1006 CHANGING P_ADMIN TYPE /SIE/HR_IDP_ADM.

  DATA: L_ITAB_ADM TYPE STANDARD TABLE OF /SIE/HR_IDP_ADM INITIAL SIZE 0
      , L_WA_ADM TYPE /SIE/HR_IDP_ADM
      , L_WA_S1SA TYPE /SIE/HR_IDP_S1SA
      , L_WA_S1PG TYPE /SIE/HR_IDP_S1PG
      .

  CLEAR L_ITAB_ADM.

* S1sa
  LOOP AT G_IFDATA_TRAN-S1SA INTO L_WA_S1SA.
    MOVE-CORRESPONDING L_WA_S1SA TO L_WA_ADM.
    APPEND L_WA_ADM TO L_ITAB_ADM.
  ENDLOOP.

* S1pg
  LOOP AT G_IFDATA_TRAN-S1PG INTO L_WA_S1PG.
    MOVE-CORRESPONDING L_WA_S1PG TO L_WA_ADM.
    APPEND L_WA_ADM TO L_ITAB_ADM.
  ENDLOOP.

  MOVE-CORRESPONDING /SIE/HR_IDP_S1DL TO L_WA_ADM.
  APPEND L_WA_ADM TO L_ITAB_ADM.

  SORT L_ITAB_ADM DESCENDING BY DATUM UZEIT.

  READ TABLE L_ITAB_ADM INDEX 1 INTO L_WA_ADM.
  IF SY-SUBRC = 0.
    MOVE-CORRESPONDING L_WA_ADM TO P_ADMIN.
  ELSE.
    CLEAR P_ADMIN.
  ENDIF.

ENDFORM.
