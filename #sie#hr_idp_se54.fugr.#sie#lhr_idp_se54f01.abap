*----------------------------------------------------------------------*
*   INCLUDE /SIE/LHR_IDP_SE54F01                                       *
*----------------------------------------------------------------------*
*  M. Przygocki 20230208 ATC findings C2C correction

*---------------------------------------------------------------------*
*       FORM INSERT_ADM_INFO                                          *
*---------------------------------------------------------------------*
*       Form insert_adm_info fügt die User Namen und andere           *
*       Administrationsinformationen in die Views ein. Es wird durch  *
*       die Ereignis-Exits der Viewpflege aufgerufen.                 *
*---------------------------------------------------------------------*
FORM INSERT_ADM_INFO.

  DATA: H_MARK(1) TYPE C
      ,  H_ACTION(1) TYPE C
      .

  DEFINE MOVE_ADMIN_DATA.
    MOVE: TOTAL TO &1
        , <ACTION> TO H_ACTION
        , <MARK> TO H_MARK
        .
* Update Felder
    MOVE SY-UNAME TO &1-UNAME.
    MOVE SY-UZEIT TO &1-UZEIT.
    MOVE SY-REPID TO &1-REPID.
    MOVE SY-DATUM TO &1-DATUM.

* Bei Neuen Einträgen in der Tabelle wird auch der Ersteller vermerkt
    IF H_ACTION = 'N'.                                      "#EC NOTEXT
      MOVE SY-UNAME TO &1-CR_UNAME.
      MOVE SY-UZEIT TO &1-CR_UZEIT.
      MOVE SY-REPID TO &1-CR_REPID.
      MOVE SY-DATUM TO &1-CR_DATUM.
    ENDIF.
    TOTAL = &1.
    <ACTION> = H_ACTION.
    <MARK> = H_MARK.
    MODIFY TOTAL.
  END-OF-DEFINITION.

  LOOP AT TOTAL.
    CASE <ACTION>.
      WHEN 'N' OR 'U'.                                      "#EC NOTEXT
        CASE X_HEADER-MAINTVIEW.
          WHEN '/SIE/HR_IDP_VC1T'.                          "#EC NOTEXT
            MOVE_ADMIN_DATA /SIE/HR_IDP_VC1T.
          WHEN '/SIE/HR_IDP_VF0T'.                          "#EC NOTEXT
            MOVE_ADMIN_DATA /SIE/HR_IDP_VF0T.
          WHEN '/SIE/HR_IDP_VF1T'.                          "#EC NOTEXT
            MOVE_ADMIN_DATA /SIE/HR_IDP_VF1T.
          WHEN '/SIE/HR_IDP_VF1S'.                          "#EC NOTEXT
            MOVE_ADMIN_DATA /SIE/HR_IDP_VF1S.
          WHEN '/SIE/HR_IDP_VS0T'.                          "#EC NOTEXT
            MOVE_ADMIN_DATA /SIE/HR_IDP_VS0T.
          WHEN OTHERS.
        ENDCASE.
      WHEN OTHERS.
*       Do nothing.
    ENDCASE.
  ENDLOOP.
  PERFORM SAVE_LANGTEXT_TO_DB.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  EXIT_CODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_CODE_ADM INPUT.

  IF FUNCTION = 'YADM'.
    FUNCTION = SPACE.
    PERFORM EXIT_CODE_ADM.
  ENDIF.

ENDMODULE.                 " EXIT_CODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_CODE_LTXT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_CODE_LTXT INPUT.
  DATA: BEGIN OF TOTS.
          INCLUDE STRUCTURE /SIE/HR_IDP_VF1T.
          INCLUDE STRUCTURE VIMTBFLAGS..
  DATA: END OF TOTS.
  DATA: H_TOTAL LIKE TOTS OCCURS 0 WITH HEADER LINE.
  DATA: DIRTY TYPE XFELD.
* check ok_code = 'LTXT'.
  CHECK FUNCTION = 'LTXT'.
  FUNCTION = SPACE.

  IF STATUS-ACTION EQ ANZEIGEN.
    CALL FUNCTION '/SIE/HR_IDP_F1LT_SHOW'
         EXPORTING
              FELDNAME = /SIE/HR_IDP_VF1T-FELDNAME.
  ELSE.
    READ TABLE LTXTAB WITH KEY SPRAS = SY-LANGU
                               FELDNAME = /SIE/HR_IDP_VF1T-FELDNAME.
    IF SY-SUBRC = 4.
      SELECT * FROM /SIE/HR_IDP_F1LT
               APPENDING CORRESPONDING FIELDS OF TABLE LTXTAB
               WHERE SPRAS = SY-LANGU
               AND FELDNAME = /SIE/HR_IDP_VF1T-FELDNAME.
    ENDIF.
    CALL FUNCTION '/SIE/HR_IDP_F1LT_EDIT'
         EXPORTING
              FIELDNAME = /SIE/HR_IDP_VF1T-FELDNAME
              SPRAS     = SY-LANGU
         IMPORTING
              DIRTY     = DIRTY
         TABLES
              TXTABLE   = LTXTAB.
    CHECK NOT DIRTY IS INITIAL.
*   Set update flag
    <STATUS>-UPD_FLAG = 'X'.
*   <action> = 'U'.
*    H_TOTAL[] = EXTRACT[].
*    LOOP AT H_TOTAL.
*      IF H_TOTAL = TOTAL.
*        H_TOTAL-VIM_ACTION = 'U'.
*        MODIFY H_TOTAL.
*        EXTRACT[] = H_TOTAL[].
*        EXIT.
*      ENDIF.
*    ENDLOOP.
*    H_TOTAL[] = TOTAL[].
*    LOOP AT H_TOTAL.
*      IF H_TOTAL = EXTRACT.
*        H_TOTAL-VIM_ACTION = 'U'.
*        MODIFY H_TOTAL.
*        TOTAL[] = H_TOTAL[].
*        EXIT.
*      ENDIF.
*    ENDLOOP.
  ENDIF.
ENDMODULE.                 " EXIT_CODE_LTXT  INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT_CODE_F4  INPUT
*&---------------------------------------------------------------------*
*       Feldsuchhilfe ausführen
*----------------------------------------------------------------------*
MODULE EXIT_CODE_F4 INPUT.

  CHECK FUNCTION = 'YSER'.
  FUNCTION = SPACE.
  CALL FUNCTION '/SIE/HR_IDP_F4'
            .

ENDMODULE.                 " EXIT_CODE_F4  INPUT

*&---------------------------------------------------------------------*
*&      Form  READ_QFIELDS
*&---------------------------------------------------------------------*
*       Füllt die Textfelder des Dynpros
*----------------------------------------------------------------------*
FORM READ_QFIELDS.

  CLEAR /SIE/HR_IDP_QVF1T.

  IF NOT ( /SIE/HR_IDP_VF1T-GRKEY IS INITIAL ).
"BEG of conversion
*    SELECT SINGLE * FROM  /SIE/HR_IDP_F0T
*           WHERE  SPRAS  = SY-LANGU
*           AND    GRKEY  = /SIE/HR_IDP_VF1T-GRKEY.
    SELECT * FROM  /SIE/HR_IDP_F0T UP TO 1 ROWS
         WHERE  SPRAS  = SY-LANGU
           AND  GRKEY  = /SIE/HR_IDP_VF1T-GRKEY
         ORDER BY PRIMARY KEY.
    ENDSELECT.
"END of conversion "M. Przygocki 20230208 ATC findings C2C correction
    /SIE/HR_IDP_QVF1T-GRKEY_TEXT = /SIE/HR_IDP_F0T-IDENT.
  ENDIF.

  IF NOT ( /SIE/HR_IDP_VF1T-INFTY IS INITIAL ).
    SELECT SINGLE * FROM  T582S
           WHERE  SPRSL  = SY-LANGU
           AND    INFTY  = /SIE/HR_IDP_VF1T-INFTY
           AND    ITBLD  = SPACE.
    /SIE/HR_IDP_QVF1T-INFTY_TEXT = T582S-ITEXT.
  ENDIF.

  IF NOT ( /SIE/HR_IDP_VF1T-SUBTY IS INITIAL ).
    SELECT SINGLE * FROM T591S
      WHERE SPRSL = SY-LANGU
      AND   INFTY  = /SIE/HR_IDP_VF1T-INFTY
      AND   SUBTY = /SIE/HR_IDP_VF1T-SUBTY.
    /SIE/HR_IDP_QVF1T-SUBTY_TEXT = T591S-STEXT.
  ENDIF.

* if not ( /sie/hr_idp_vf1t-dpftype is initial ).
*   perform read_doma_value using '/SIE/HR_IDP_FTYPE'
*                                 /sie/hr_idp_vf1t-dpftype
*                            changing /sie/hr_idp_qvf1t-ftype_text.
* endif.

  IF NOT ( /SIE/HR_IDP_VF1T-RTLGART IS INITIAL ).
    SELECT SINGLE * FROM  T512T
           WHERE  SPRSL  = SY-LANGU
           AND    MOLGA  = '01'
           AND    LGART  = /SIE/HR_IDP_VF1T-RTLGART.
    /SIE/HR_IDP_QVF1T-LGART_TEXT = T512T-LGTXT.
  ENDIF.

  IF NOT ( /SIE/HR_IDP_VF1T-RTKZ IS INITIAL ).
    PERFORM READ_DOMA_VALUE USING '/SIE/HR_IDP_RTKZ'
                                  /SIE/HR_IDP_VF1T-RTKZ
                             CHANGING /SIE/HR_IDP_QVF1T-RTFLD_TEXT.
  ENDIF.

*  if not ( /sie/hr_idp_vf1t-konvstrg is initial ).
  PERFORM READ_DOMA_VALUE USING '/SIE/HR_IDP_KSTRG'
                                /SIE/HR_IDP_VF1T-KONVSTRG
                           CHANGING /SIE/HR_IDP_QVF1T-CONV_TEXT.
*  endif.
  IF /SIE/HR_IDP_VF1T-DPFTYPE = 4.
    PERFORM READ_DOMA_VALUE USING '/SIE/HR_IDP_AGGREGATE'
                                  /SIE/HR_IDP_VF1T-AGGREGATE
                             CHANGING /SIE/HR_IDP_QVF1T-AGGR_TEXT.
  ENDIF.

ENDFORM.                    " READ_QFIELDS

*&---------------------------------------------------------------------*
*&      Form  READ_DOMA_VALUE
*&---------------------------------------------------------------------*
*       Liest aus dem DDIC die Domänenfestwerte
*----------------------------------------------------------------------*
*      -->P_0310   text
*      -->P_/SIE/HR_IDP_VF1T_DPFTYPE  text
*      <--P_/SIE/HR_IDP_QVF1T_FTYPE_TEXT  text
*----------------------------------------------------------------------*
FORM READ_DOMA_VALUE USING    VALUE(DOMAIN_NAME) TYPE DD07L-DOMNAME
                              VALUE(FIELD_VALUE)
                     CHANGING P_TEXT.

  DATA:
    DD07V_WA  LIKE DD07V,
    L_VALUE TYPE DD07L-DOMVALUE_L,
    RC  LIKE SY-SUBRC.

  L_VALUE = FIELD_VALUE.
  CALL FUNCTION 'DD_DOMVALUE_TEXT_GET'
       EXPORTING
            DOMNAME  = DOMAIN_NAME
            VALUE    = L_VALUE
       IMPORTING
            DD07V_WA = DD07V_WA
            RC       = RC
       EXCEPTIONS
            OTHERS   = 1.
  IF SY-SUBRC NE 0.
    CLEAR DD07V_WA.
  ENDIF.
  P_TEXT = DD07V_WA-DDTEXT.

ENDFORM.                    " READ_DOMA_VALUE

*&---------------------------------------------------------------------*
*&      Module  READ_TEXT  OUTPUT
*&---------------------------------------------------------------------*
MODULE READ_TEXT OUTPUT.
  PERFORM READ_TEXT_VF0T.
ENDMODULE.

*---------------------------------------------------------------------*
*       FORM READ_TEXT_VF0T                                           *
*---------------------------------------------------------------------*
FORM READ_TEXT_VF0T.

  DATA: WA_F0T TYPE /SIE/HR_IDP_F0T.

  IF NOT ( /SIE/HR_IDP_VF0T-GRTYP IS INITIAL ).
    PERFORM READ_DOMA_VALUE USING '/SIE/HR_IDP_GRTYP'
                                  /SIE/HR_IDP_VF0T-GRTYP
                             CHANGING /SIE/HR_IDP_QF0T-GRTYP_TEXT.
  ENDIF.

  IF NOT ( /SIE/HR_IDP_VF0T-PARENT IS INITIAL ).
    SELECT SINGLE * FROM /SIE/HR_IDP_F0T
                    INTO WA_F0T
                    WHERE SPRAS = SY-LANGU
                    AND   GRTYP = /SIE/HR_IDP_VF0T-GRTYP
                    AND   GRKEY = /SIE/HR_IDP_VF0T-PARENT.
    /SIE/HR_IDP_QF0T-GROUP_TEXT = WA_F0T-IDENT.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  ADMIN_INCLUDE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ADMIN_INCLUDE INPUT.

  CHECK VIM_MARKED = 'X'.

  CASE FUNCTION.
    WHEN 'YADM'.
      FUNCTION = SPACE.
      PERFORM EXIT_CODE_ADM.
    WHEN OTHERS.
* do nothing
  ENDCASE.

ENDMODULE.                 " ADMIN_INCLUDE  INPUT

*---------------------------------------------------------------------*
*       FORM EXIT_CODE_ADM                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM EXIT_CODE_ADM.
  DATA: L_S_ADMIN LIKE /SIE/HR_IDP_ADM.

* Für 2 seitige Dynpros ok!
  CASE X_HEADER-MAINTVIEW.
    WHEN '/SIE/HR_IDP_VC1T'.
      MOVE-CORRESPONDING /SIE/HR_IDP_VC1T TO L_S_ADMIN.
    WHEN '/SIE/HR_IDP_VF0T'.
      MOVE-CORRESPONDING /SIE/HR_IDP_VF0T TO L_S_ADMIN.
    WHEN '/SIE/HR_IDP_VF1T'.
      MOVE-CORRESPONDING /SIE/HR_IDP_VF1T TO L_S_ADMIN.
    WHEN '/SIE/HR_IDP_VS0T'.
      MOVE-CORRESPONDING /SIE/HR_IDP_VS0T TO L_S_ADMIN.
    WHEN '/SIE/HR_IDP_VF1S'.
      MOVE-CORRESPONDING /SIE/HR_IDP_VF1S TO L_S_ADMIN.
    WHEN OTHERS.
  ENDCASE.

  CALL FUNCTION '/SIE/HR_IDP_SHOW_ADMIN_INFO'
       EXPORTING
            ADMIN = L_S_ADMIN.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  SHOW_ADM_BUTTON  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_ADM_BUTTON OUTPUT.
  IF STATUS-ACTION EQ AENDERN
  OR STATUS-ACTION EQ ANZEIGEN.
    DOCU_BUTTON = ICON_INFORMATION.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'DOCU_BUTTON'.
        SCREEN-ACTIVE = 1.
        SCREEN-INPUT = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    CLEAR DOCU_BUTTON.
    LOOP AT SCREEN.
      IF SCREEN-NAME EQ 'DOCU_BUTTON'.
        SCREEN-INPUT  = '0'.
        SCREEN-ACTIVE = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " SHOW_ADM_BUTTON  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  ADMIN_SHOW  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ADMIN_SHOW INPUT.
  PERFORM ADMIN_SHOW.
ENDMODULE.                 " ADMIN_SHOW  INPUT

*---------------------------------------------------------------------*
*       FORM ADMIN_SHOW                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM ADMIN_SHOW.

  LOCAL: /SIE/HR_IDP_VC1T,
         /SIE/HR_IDP_VF0T,
         /SIE/HR_IDP_VF1T,
         /SIE/HR_IDP_VF1S,
         /SIE/HR_IDP_VS0T.


  DATA:  CINDEX LIKE SY-INDEX,
         CFUNCT(3) TYPE C.
  DATA: L_S_ADMIN LIKE /SIE/HR_IDP_ADM.

  CHECK FUNCTION CP '0*'.

  CFUNCT = FUNCTION+1(3).
  CHECK CFUNCT CO '0123456789'.        " numeric
  CINDEX = CFUNCT + NEXTLINE - 1.      " line number + top line - 1
  FUNCTION = SPACE.
  IF SY-SUBRC <> 0.
  ELSE.
    CASE X_HEADER-MAINTVIEW.
      WHEN '/SIE/HR_IDP_VC1T'.
        READ TABLE EXTRACT INTO /SIE/HR_IDP_VC1T INDEX CINDEX.
        MOVE-CORRESPONDING /SIE/HR_IDP_VC1T TO L_S_ADMIN.
      WHEN '/SIE/HR_IDP_VF0T'.
        READ TABLE EXTRACT INTO /SIE/HR_IDP_VF0T INDEX CINDEX.
        MOVE-CORRESPONDING /SIE/HR_IDP_VF0T TO L_S_ADMIN.
      WHEN '/SIE/HR_IDP_VF1T'.
        READ TABLE EXTRACT INTO /SIE/HR_IDP_VF1T INDEX CINDEX.
        MOVE-CORRESPONDING /SIE/HR_IDP_VF1T TO L_S_ADMIN.
      WHEN '/SIE/HR_IDP_VS0T'.
        READ TABLE EXTRACT INTO /SIE/HR_IDP_VS0T INDEX CINDEX.
        MOVE-CORRESPONDING /SIE/HR_IDP_VS0T TO L_S_ADMIN.
      WHEN '/SIE/HR_IDP_VF1S'.
        READ TABLE EXTRACT INTO /SIE/HR_IDP_VF1S INDEX CINDEX.
        MOVE-CORRESPONDING /SIE/HR_IDP_VF1S TO L_S_ADMIN.
      WHEN OTHERS.
    ENDCASE.

    CALL FUNCTION '/SIE/HR_IDP_SHOW_ADMIN_INFO'
         EXPORTING
              ADMIN = L_S_ADMIN.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  INFTYFELD_F4  INPUT
*&---------------------------------------------------------------------*
*       Suchhilfe für Felder der Infotypen
*----------------------------------------------------------------------*
MODULE INFTYFELD_F4 INPUT.

  PERFORM INFTYFELD_F4.

ENDMODULE.                 " INFTYFELD_F4  INPUT

*---------------------------------------------------------------------*
*       MODULE TABLFELD_F4 INPUT                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE TABLFELD_F4 INPUT.

  PERFORM TABLFIELD_F4.

ENDMODULE.   " TABLFELD_F4 Input

*&---------------------------------------------------------------------*
*&      Form  INFTYFELD_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INFTYFELD_F4.

  DATA: H_TABLE LIKE DD02L-TABNAME
      , H_FIELD LIKE  DD03L-FIELDNAME
      , H_PROG LIKE D020S-PROG
      , DYNPFIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE
      .

  H_PROG = SY-REPID.

  REFRESH DYNPFIELDS.
  CLEAR DYNPFIELDS.
  DYNPFIELDS-FIELDNAME = '/SIE/HR_IDP_VF1T-INFTY'.
  APPEND DYNPFIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
       EXPORTING
            DYNAME     = H_PROG
            DYNUMB     = '0004'
       TABLES
            DYNPFIELDS = DYNPFIELDS.

  READ TABLE DYNPFIELDS WITH KEY FIELDNAME = '/SIE/HR_IDP_VF1T-INFTY'.
  /SIE/HR_IDP_VF1T-INFTY = DYNPFIELDS-FIELDVALUE.

  IF NOT ( /SIE/HR_IDP_VF1T-FL_MODIF IS INITIAL ).
    IF NOT ( /SIE/HR_IDP_VF1T-STRU_VAL IS INITIAL ).
      H_TABLE = /SIE/HR_IDP_VF1T-STRU_VAL.
    ENDIF.
  ELSE.
    CONCATENATE 'PS' /SIE/HR_IDP_VF1T-INFTY INTO H_TABLE.
  ENDIF.

  IF NOT ( /SIE/HR_IDP_VF1T-INFTY = SPACE ).

    CALL FUNCTION 'SD_F4_HELP_FELD'
         EXPORTING
              SEL_TABNAME = H_TABLE
         IMPORTING
              FIELDNAME   = H_FIELD.

    /SIE/HR_IDP_VF1T-FELDNAME = H_FIELD.

  ENDIF.

ENDFORM.                    " INFTYFELD_F4

*---------------------------------------------------------------------*
*       FORM TABLFIELD_F4                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM TABLFIELD_F4.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  CHECK_CONVERSION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_CONVERSION INPUT.

  IF /SIE/HR_IDP_VF1T-KONVSTRG = 3.
    IF NOT ( /SIE/HR_IDP_VF1T-KONVNAME IS INITIAL ).
      MESSAGE E501(/SIE/HR_IDP_MESSAGES).
    ENDIF.
  ENDIF.

ENDMODULE.                 " CHECK_CONVERSION  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_INFTY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INFTY INPUT.

  IF /SIE/HR_IDP_VF1T-INFTY IS INITIAL.
  ELSE.
    PERFORM CHECK_INFTY.
  ENDIF.

ENDMODULE.                 " CHECK_INFTY  INPUT

*&---------------------------------------------------------------------*
*&      Form  CHECK_INFTY
*&---------------------------------------------------------------------*
*       Prüft, ob ein Feld in der Infotypstruktur existiert
*----------------------------------------------------------------------*
FORM CHECK_INFTY.

  DATA: L_TABNAME LIKE DCOBJDEF-NAME
      , L_FIELD LIKE DFIES-FIELDNAME
      .

* Evtl. Sonderbehandlung Strukturmodifikationen
  IF NOT ( /SIE/HR_IDP_VF1T-FL_MODIF IS INITIAL ).
    IF NOT ( /SIE/HR_IDP_VF1T-STRU_VAL IS INITIAL ).
      L_TABNAME = /SIE/HR_IDP_VF1T-STRU_VAL.
    ENDIF.
  ELSE.
    CONCATENATE 'PS' /SIE/HR_IDP_VF1T-INFTY INTO L_TABNAME.
  ENDIF.

  L_FIELD = /SIE/HR_IDP_VF1T-INFTYFELD.

* Sonderbehandlung PERNR. Wir definieren PERNR als zum PS0001 gehörend
  IF /SIE/HR_IDP_VF1T-INFTY = '0001' AND
     /SIE/HR_IDP_VF1T-INFTYFELD = 'PERNR'.
* Do nothing
  ELSE.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
         EXPORTING
              TABNAME        = L_TABNAME
              FIELDNAME      = L_FIELD
         EXCEPTIONS
              NOT_FOUND      = 1
              INTERNAL_ERROR = 2
              OTHERS         = 3.
    IF SY-SUBRC <> 0.
      MESSAGE E502(/SIE/HR_IDP_MESSAGES)
              WITH L_FIELD /SIE/HR_IDP_VF1T-INFTY.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_INFTY
*&---------------------------------------------------------------------*
*&      Module  DISABLE_CONV  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISABLE_CONV OUTPUT.

  CASE /SIE/HR_IDP_VF1T-KONVSTRG.
    WHEN '3'.
      LOOP AT SCREEN.
        CHECK SCREEN-NAME = '/SIE/HR_IDP_VF1T-KONVNAME'.
        SCREEN-ACTIVE = '0'.
        SCREEN-REQUIRED = '0'.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN '1'.
      LOOP AT SCREEN.
        CHECK SCREEN-NAME = '/SIE/HR_IDP_VF1T-KONVNAME'.
        SCREEN-REQUIRED = '0'.
        SCREEN-ACTIVE = '1'.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN '2'.
      LOOP AT SCREEN.
        CHECK SCREEN-NAME = '/SIE/HR_IDP_VF1T-KONVNAME'.
        SCREEN-REQUIRED = '1'.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN OTHERS.
      LOOP AT SCREEN.
        CHECK SCREEN-NAME = '/SIE/HR_IDP_VF1T-KONVNAME'.
        SCREEN-ACTIVE = '1'.
        SCREEN-REQUIRED = '0'.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.

ENDMODULE.                 " DISABLE_CONV  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_FELDNAME  INPUT
*&---------------------------------------------------------------------*
*       Prüft, ob eine Eingabe erfolgt ist
*----------------------------------------------------------------------*
MODULE CHECK_FELDNAME INPUT.
  IF /SIE/HR_IDP_VF1T-FELDNAME IS INITIAL.
    MESSAGE E503(/SIE/HR_IDP_MESSAGES).
  ENDIF.
ENDMODULE.                 " CHECK_FELDNAME  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_CONSISTENCY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_CONSISTENCY INPUT.

  CASE /SIE/HR_IDP_VF1T-DPFTYPE.
    WHEN 1.   " Infotyp
      IF NOT ( /SIE/HR_IDP_VF1T-RTKZ IS INITIAL )
      OR NOT  ( /SIE/HR_IDP_VF1T-RTLGART IS INITIAL )
      OR NOT  ( /SIE/HR_IDP_VF1T-ACLFELD IS INITIAL )
      OR NOT  ( /SIE/HR_IDP_VF1T-ACLTAB IS INITIAL )
      OR NOT  ( /SIE/HR_IDP_VF1T-BEGRIFF IS INITIAL ).
        MESSAGE E504(/SIE/HR_IDP_MESSAGES).
      ENDIF.
    WHEN 2.
      IF NOT  ( /SIE/HR_IDP_VF1T-RTKZ IS INITIAL )
      OR NOT  ( /SIE/HR_IDP_VF1T-RTLGART IS INITIAL )
      OR NOT  ( /SIE/HR_IDP_VF1T-ACLFELD IS INITIAL )
      OR NOT  ( /SIE/HR_IDP_VF1T-ACLTAB IS INITIAL )
      OR  NOT ( /SIE/HR_IDP_VF1T-INFTY IS INITIAL )
      OR NOT ( /SIE/HR_IDP_VF1T-INFTYFELD IS INITIAL )
      OR  NOT ( /SIE/HR_IDP_VF1T-SUBTY IS INITIAL ).
        MESSAGE E505(/SIE/HR_IDP_MESSAGES).
      ENDIF.
    WHEN 3.  " Feld aus Abrechnungstabelle
      IF  NOT ( /SIE/HR_IDP_VF1T-RTKZ IS INITIAL )
      OR  NOT ( /SIE/HR_IDP_VF1T-RTLGART IS INITIAL )
      OR  NOT ( /SIE/HR_IDP_VF1T-BEGRIFF IS INITIAL )
      OR  NOT ( /SIE/HR_IDP_VF1T-INFTY IS INITIAL )
      OR NOT ( /SIE/HR_IDP_VF1T-INFTYFELD IS INITIAL )
      OR  NOT ( /SIE/HR_IDP_VF1T-SUBTY IS INITIAL ).
        MESSAGE E506(/SIE/HR_IDP_MESSAGES).
      ENDIF.
    WHEN 4.  " Lohnart
      IF  NOT ( /SIE/HR_IDP_VF1T-BEGRIFF IS INITIAL )
      OR  NOT ( /SIE/HR_IDP_VF1T-ACLFELD IS INITIAL )
      OR  NOT ( /SIE/HR_IDP_VF1T-ACLTAB IS INITIAL )
      OR  NOT ( /SIE/HR_IDP_VF1T-INFTY IS INITIAL )
      OR NOT ( /SIE/HR_IDP_VF1T-INFTYFELD IS INITIAL )
      OR  NOT ( /SIE/HR_IDP_VF1T-SUBTY IS INITIAL ).
        MESSAGE E507(/SIE/HR_IDP_MESSAGES).
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " CHECK_CONSISTENCY  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_AGGREGATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_AGGREGATE INPUT.

  IF /SIE/HR_IDP_VF1T-DPFTYPE = 4.

    CASE /SIE/HR_IDP_VF1T-RTKZ.
      WHEN 'A'.
        CASE /SIE/HR_IDP_VF1T-AGGREGATE.
          WHEN 'A' OR SPACE.   " Addieren oder Durschnitt OK
          WHEN OTHERS.
            MESSAGE E508(/SIE/HR_IDP_MESSAGES).
        ENDCASE.
      WHEN 'N'.
        CASE /SIE/HR_IDP_VF1T-AGGREGATE.
          WHEN SPACE.   " Durschnitt OK
          WHEN OTHERS.
            MESSAGE E509(/SIE/HR_IDP_MESSAGES).
        ENDCASE.
      WHEN 'R'.
        CASE /SIE/HR_IDP_VF1T-AGGREGATE.
          WHEN 'A' OR 'F' OR 'L' OR 'X' OR 'M' OR SPACE.
          WHEN OTHERS.
            MESSAGE E510(/SIE/HR_IDP_MESSAGES).
        ENDCASE.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.

ENDMODULE.                 " CHECK_AGGREGATE  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_MODIF  INPUT
*&---------------------------------------------------------------------*
*       Prüft ob das Flag modifikation gesetzt ist und das feld
*       struktur leer oder umgekehrt
*----------------------------------------------------------------------*
MODULE CHECK_MODIF INPUT.

  IF NOT ( /SIE/HR_IDP_VF1T-FL_MODIF IS INITIAL )
     AND ( /SIE/HR_IDP_VF1T-STRU_VAL IS INITIAL ).
    MESSAGE E511(/SIE/HR_IDP_MESSAGES).
  ENDIF.

  IF ( /SIE/HR_IDP_VF1T-FL_MODIF IS INITIAL )
     AND NOT ( /SIE/HR_IDP_VF1T-STRU_VAL IS INITIAL ).
    MESSAGE E511(/SIE/HR_IDP_MESSAGES).
  ENDIF.

ENDMODULE.                 " CHECK_MODIF  INPUT
