*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_SE54F02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_LANGTEXT_FROM_DB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_LANGTEXT_FROM_DB.
*  SELECT * FROM /sie/hr_idp_f1lt INTO TABLE ltxtab
*           WHERE spras = sy-langu.
*wird jetzt von der Update-Schnittstelle Just-in-time gelesen

ENDFORM.                    " GET_LANGTEXT_FROM_DB
*&---------------------------------------------------------------------*
*&      Form  SAVE_LANGTEXT_TO_DB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_LANGTEXT_TO_DB.
  DATA: DELTA LIKE /SIE/HR_IDP_F1LT OCCURS 0 WITH HEADER LINE.
  DATA: BEGIN OF WA_TOTAL.
          INCLUDE STRUCTURE /SIE/HR_IDP_VF1T.
          INCLUDE STRUCTURE VIMTBFLAGS.
  DATA: END OF WA_TOTAL.

  LOOP AT LTXTAB WHERE ACTION = 'D'.
    MOVE-CORRESPONDING LTXTAB TO DELTA.
    APPEND DELTA.
  ENDLOOP.
  DELETE /SIE/HR_IDP_F1LT FROM TABLE DELTA.
  CLEAR DELTA. REFRESH DELTA.
  LOOP AT LTXTAB WHERE ACTION = 'C'.
    MOVE-CORRESPONDING LTXTAB TO DELTA.
    APPEND DELTA.
  ENDLOOP.
  MODIFY /SIE/HR_IDP_F1LT FROM TABLE DELTA.
  CLEAR DELTA. REFRESH DELTA.
  LOOP AT LTXTAB WHERE ACTION = 'N'.
    MOVE-CORRESPONDING LTXTAB TO DELTA.
    APPEND DELTA.
  ENDLOOP.
  INSERT /SIE/HR_IDP_F1LT FROM TABLE DELTA.
  CLEAR LTXTAB.
  REFRESH LTXTAB.

*delete
  LOOP AT TOTAL INTO WA_TOTAL..
    CASE WA_TOTAL-VIM_ACTION.
      WHEN 'D'.
        DELETE FROM /SIE/HR_IDP_F1LT
               WHERE FELDNAME = WA_TOTAL-FELDNAME.
    ENDCASE.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  TR_HEAD_ENTRY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TR_HEAD_ENTRY.
* Kopfeintrag in der Korrektur erzeugen
  VIM_CORR_OBJTAB = E071.
  VIM_CORR_OBJTAB-PGMID = 'R3TR'.
  VIM_CORR_OBJTAB-OBJECT = 'TABU'.
  VIM_CORR_OBJTAB-OBJ_NAME = '/SIE/HR_IDP_F1LT'.
  VIM_CORR_OBJTAB-OBJFUNC = 'K'.
  APPEND VIM_CORR_OBJTAB.
ENDFORM.                    " TR_HEAD_ENTRY
*&---------------------------------------------------------------------*
*&      Form  TR_TAB_KEYS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TR_TAB_KEYS.
  DATA: RC LIKE SY-SUBRC.
  DATA: BEGIN OF WA_TOTAL.
          INCLUDE STRUCTURE /SIE/HR_IDP_VF1T.
          INCLUDE STRUCTURE VIMTBFLAGS.
  DATA: END OF WA_TOTAL.

  CORR_KEYTAB = E071K.
  CORR_KEYTAB-TRKORR = E071K-TRKORR.
  CORR_KEYTAB-PGMID = 'R3TR'.
  CORR_KEYTAB-OBJECT = 'TABU'.
  CORR_KEYTAB-OBJNAME = '/SIE/HR_IDP_F1LT'.
  CORR_KEYTAB-MASTERTYPE = 'TABU'.
  CORR_KEYTAB-MASTERNAME = '/SIE/HR_IDP_F1LT'.
  CASE FUNCTION.
    WHEN 'TRIN'.
      WA_TOTAL = TOTAL.
      CORR_ACTION = HINZUFUEGEN.
      CORR_KEYTAB-TABKEY+0(3) = SY-MANDT.
      CORR_KEYTAB-TABKEY+3(1) = SY-LANGU.
      CORR_KEYTAB-TABKEY+4(20) = WA_TOTAL-FELDNAME.
      CORR_KEYTAB-TABKEY+24(4) = '*   '.
      PERFORM UPDATE_CORR_KEYTAB USING CORR_ACTION RC.
    WHEN 'TREX'.
      WA_TOTAL = TOTAL.
      CORR_ACTION = GELOESCHT.
      CORR_KEYTAB-TABKEY+0(3) = SY-MANDT.
      CORR_KEYTAB-TABKEY+3(1) = SY-LANGU.
      CORR_KEYTAB-TABKEY+4(20) = WA_TOTAL-FELDNAME.
      CORR_KEYTAB-TABKEY+24(4) = '*   '.
      PERFORM UPDATE_CORR_KEYTAB USING CORR_ACTION RC.
    WHEN OTHERS.
      WA_TOTAL = TOTAL.
      IF WA_TOTAL-VIM_ACTION = 'D'.
        CORR_ACTION = GELOESCHT.
      ELSE.: "IF wa_total-vim_action = 'D'.
        CORR_ACTION = HINZUFUEGEN.
      ENDIF.
      CORR_KEYTAB-TABKEY+0(3) = SY-MANDT.
      CORR_KEYTAB-TABKEY+3(1) = SY-LANGU.
      CORR_KEYTAB-TABKEY+4(20) = WA_TOTAL-FELDNAME.
      CORR_KEYTAB-TABKEY+24(4) = '*   '.
      PERFORM UPDATE_CORR_KEYTAB USING CORR_ACTION RC.


*      LOOP AT LTXTAB WHERE ACTION = 'D'.
*        CORR_ACTION = GELOESCHT.
*        CORR_KEYTAB-TABKEY+0(3) = SY-MANDT.
*        CORR_KEYTAB-TABKEY+3(1) = LTXTAB-SPRAS.
*        CORR_KEYTAB-TABKEY+4(20) = LTXTAB-FELDNAME.
*        CORR_KEYTAB-TABKEY+24(4) = LTXTAB-SEQNR.
*        PERFORM UPDATE_CORR_KEYTAB USING CORR_ACTION RC.
*      ENDLOOP.
*      LOOP AT LTXTAB WHERE ACTION = 'N' OR ACTION = 'C'.
*        CORR_ACTION = HINZUFUEGEN.
*        CORR_KEYTAB-TABKEY+0(3) = SY-MANDT.
*        CORR_KEYTAB-TABKEY+3(1) = LTXTAB-SPRAS.
*        CORR_KEYTAB-TABKEY+4(20) = LTXTAB-FELDNAME.
*        CORR_KEYTAB-TABKEY+24(4) = LTXTAB-SEQNR.
*        PERFORM UPDATE_CORR_KEYTAB USING CORR_ACTION RC.
*      ENDLOOP.
*
*      LOOP AT TOTAL INTO WA_TOTAL.
*        IF <ACTION> = 'D'.
*          CORR_ACTION = GELOESCHT.
*          CORR_KEYTAB-TABKEY+0(3) = WA_TOTAL+0(3).
*          CORR_KEYTAB-TABKEY+3(1) = SY-LANGU.
*          CORR_KEYTAB-TABKEY+4(20) = WA_TOTAL+3(20).
*          CORR_KEYTAB-TABKEY+24(4) = '*   '.
*          PERFORM UPDATE_CORR_KEYTAB USING CORR_ACTION RC.
*        ENDIF.
*      ENDLOOP.
  ENDCASE.


ENDFORM.                    " TR_TAB_KEYS

*&---------------------------------------------------------------------*
*&      Form  TR_TAB_KEYS_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TR_TAB_KEYS_2.
*  DATA: RC LIKE SY-SUBRC.
*  DATA: BEGIN OF WA_EXTRACT.
*          INCLUDE STRUCTURE /SIE/HR_IDP_VF1T.
*          INCLUDE STRUCTURE VIMTBFLAGS.
*  DATA: END OF WA_EXTRACT.
*  DATA: BEGIN OF WA_TOTAL.
*          INCLUDE STRUCTURE /SIE/HR_IDP_VF1T.
*          INCLUDE STRUCTURE VIMTBFLAGS.
*  DATA: END OF WA_TOTAL.
*
*
*  CORR_KEYTAB = E071K.
*  CORR_KEYTAB-TRKORR = E071K-TRKORR.
*  CORR_KEYTAB-PGMID = 'R3TR'.
*  CORR_KEYTAB-OBJECT = 'TABU'.
*  CORR_KEYTAB-OBJNAME = '/SIE/HR_IDP_F1LT'.
*  CORR_KEYTAB-MASTERTYPE = 'TABU'.
*  CORR_KEYTAB-MASTERNAME = '/SIE/HR_IDP_F1LT'.
*
*
*  CASE FUNCTION.
*    WHEN 'TRIN'.
*
*      LOOP AT EXTRACT INTO WA_EXTRACT.
*        IF WA_EXTRACT-VIM_ACTION = 'T'.
*          CORR_ACTION = HINZUFUEGEN.
*          CORR_KEYTAB-TABKEY+0(3) = SY-MANDT.
*          CORR_KEYTAB-TABKEY+3(1) = SY-LANGU.
*          CORR_KEYTAB-TABKEY+4(20) = WA_EXTRACT-FELDNAME.
*          CORR_KEYTAB-TABKEY+24(4) = '*   '.
*          PERFORM UPDATE_CORR_KEYTAB USING CORR_ACTION RC.
*        ENDIF.
*      ENDLOOP.
*    WHEN 'TREX'.
*      LOOP AT EXTRACT INTO WA_EXTRACT.
*        IF WA_EXTRACT-VIM_ACTION = 'T'.
*          CORR_ACTION = GELOESCHT.
*          CORR_KEYTAB-TABKEY+0(3) = SY-MANDT.
*          CORR_KEYTAB-TABKEY+3(1) = SY-LANGU.
*          CORR_KEYTAB-TABKEY+4(20) = WA_EXTRACT-FELDNAME.
*          CORR_KEYTAB-TABKEY+24(4) = '*   '.
*          PERFORM UPDATE_CORR_KEYTAB USING CORR_ACTION RC.
*        ENDIF.
*      ENDLOOP.
*  ENDCASE.
ENDFORM.                    " TR_TAB_KEYS_2
