*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_GENERATORF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  READ_TEMPLATE
*&---------------------------------------------------------------------*
*       liefert alle Template-Zeilen des Reports
*       löst includes auf (Achtung Rekursiv!)
*----------------------------------------------------------------------*
*      -->P_TEMPLATE  text
*      -->P_SY_REPID  text
*----------------------------------------------------------------------*
FORM GET_TEMPLATE USING    P_SY_REPID LIKE SY-REPID
                  CHANGING P_TEMPLATE TYPE /SIE/HR_IDP_TT_CODING.

  DATA:
    RI      TYPE /SIE/HR_IDP_TT_CODING,
    L       LIKE LINE OF RI,
    INCL_ID LIKE SY-REPID,
    NAME2 LIKE TRDIR-NAME,
    DUMMY TYPE C.                                           "#EC NEEDED

  CLEAR RI.
  READ REPORT P_SY_REPID INTO RI.
  LOOP AT RI INTO L.
* <XFT Begin Insert Lines 7.9.2001>
    IF L+0(1) >< '*'.                                       "#EC NOTEXT
* Normalisieren der Codingzeile
      TRANSLATE L TO UPPER CASE.
      CONDENSE  L.
* Kommentare ausblenden
      SHIFT L UP TO '"' RIGHT.                              "#EC NOTEXT
* Includes aufloesen
      SHIFT L UP TO 'INCLUDE'.                              "#EC NOTEXT
      IF L(7) EQ 'INCLUDE'.                                 "#EC NOTEXT
        SHIFT L BY 8 PLACES.
        TRANSLATE L USING '. '.                             "#EC NOTEXT
        IF    L(9) NE 'STRUCTURE'                           "#EC NOTEXT
          AND L(4) NE 'TYPE'                                "#EC NOTEXT
          AND L(7) NE 'METHODS'.                            "#EC NOTEXT
          SPLIT L AT SPACE INTO NAME2 DUMMY.
        ENDIF.
        PERFORM GET_TEMPLATE USING NAME2 CHANGING P_TEMPLATE.
      ENDIF.
    ENDIF.
* </XFT End Insert Lines 7.9.2001>

    IF L+0(2) EQ '*$'.
      SHIFT L BY 2 PLACES.
      APPEND L TO P_TEMPLATE.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " READ_TEMPLATE
*&---------------------------------------------------------------------*
*&      Form  GET_TAG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TAGNAME  text
*      <--P_TAG  text
*----------------------------------------------------------------------*
FORM GET_TAG USING    P_TAGNAME
             CHANGING P_TAG TYPE /SIE/HR_IDP_TT_CODING.
  DATA:
    L TYPE LINE OF /SIE/HR_IDP_TT_CODING,
    START_MARK(72),
    END_MARK(72),
    FOUND.

  CONCATENATE '<' P_TAGNAME '>' INTO START_MARK.
  CONCATENATE '</' P_TAGNAME '>' INTO END_MARK.
  LOOP AT G_TEMPLATE INTO L.
    IF L CS START_MARK.
      FOUND = 'X'.
    ELSEIF L CS END_MARK.
      EXIT.
    ELSEIF NOT FOUND IS INITIAL.
      TRANSLATE L TO UPPER CASE.
      APPEND L TO P_TAG.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " GET_TAG
*&---------------------------------------------------------------------*
*&      Form  REPLACE_PARAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0045   text
*      <--P_TAG  text
*----------------------------------------------------------------------*
FORM REPLACE_PARAM USING    P_PARAM
                            P_VALUE
                            P_TAG    TYPE /SIE/HR_IDP_TT_CODING
                   CHANGING P_RESULT TYPE /SIE/HR_IDP_TT_CODING.
  FIELD-SYMBOLS: <FS>.
  DATA:
    L TYPE LINE OF /SIE/HR_IDP_TT_CODING,
    P TYPE LINE OF /SIE/HR_IDP_TT_CODING,
    PARTS TYPE /SIE/HR_IDP_TT_CODING,
    LEN_VALUE TYPE I,
    LEN_PARAM TYPE I,
    POS TYPE I,
    PARAM(72).
  CLEAR P_RESULT.
*  TRANSLATE p_param TO UPPER CASE.
  CONCATENATE '&' P_PARAM INTO PARAM.

  LEN_VALUE = STRLEN( P_VALUE ).
  LEN_PARAM = STRLEN( PARAM ).
  LOOP AT P_TAG INTO L.
    DO.
      IF LEN_VALUE GT 0.
        ASSIGN P_VALUE+0(LEN_VALUE) TO <FS>.
        REPLACE PARAM LENGTH LEN_PARAM WITH <FS> INTO L.
      ELSE.
        REPLACE PARAM LENGTH LEN_PARAM WITH '' INTO L.
      ENDIF.
      IF SY-SUBRC NE 0. EXIT. ENDIF.
    ENDDO.
    APPEND L TO P_RESULT.
  ENDLOOP.
ENDFORM.                    " REPLACE_PARAM
*&---------------------------------------------------------------------*
*&      Form  INSERT_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TAG  text
*----------------------------------------------------------------------*
FORM INSERT_CODE USING    P_TAG TYPE /SIE/HR_IDP_TT_CODING.
  DATA:
    L TYPE LINE OF /SIE/HR_IDP_TT_CODING.
  LOOP AT P_TAG INTO L.
    APPEND L TO CODE.
  ENDLOOP.
ENDFORM.                    " INSERT_CODE
*&---------------------------------------------------------------------*
*&      Form  SHOW_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SHOW_CODE.
  DATA:
    L TYPE LINE OF /SIE/HR_IDP_TT_CODING.
  LOOP AT CODE INTO L.
    WRITE: / L.
  ENDLOOP.
ENDFORM.                    " SHOW_CODE
*&---------------------------------------------------------------------*
*&      Form  INSERT_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_REPORT.
  INSERT REPORT G_REPID FROM CODE.
  SELECT SINGLE * FROM TRDIR WHERE NAME = G_REPID.
  TRDIR-LDBNAME = 'PNP'.
  TRDIR-APPL = 'P'.
  TRDIR-EDTX ='X'.
  MODIFY TRDIR.
  T599B-REPID = G_REPID.
  T599B-REPCL = '9_IDPTST'.
  MODIFY T599B.
  T599R-REPID = G_REPID.
  T599R-ARYFB = '3'.
  T599R-ARYFO = '3'.
  MODIFY T599R.
ENDFORM.                    " INSERT_REPORT
*&---------------------------------------------------------------------*
*&      Form  INSERT_TEXTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_TEXTE.
DATA: TAB LIKE TEXTPOOL OCCURS 10 WITH HEADER LINE.
  TAB-ID = 'S'.
  TAB-KEY = 'P_REL'.
  TAB-ENTRY+8 = 'Relativ zum Tagesdatum'.
  TAB-LENGTH = STRLEN( TAB-ENTRY ) .
  APPEND TAB.
  TAB-KEY = 'BEGDT'.
  TAB-ENTRY+8 = 'Beginntag Datenauswahl'.
  TAB-LENGTH = STRLEN( TAB-ENTRY ) .
  APPEND TAB.
  TAB-KEY = 'ENDDT'.
  TAB-ENTRY+8 = 'Endetag Datenauswahl'.
  TAB-LENGTH = STRLEN( TAB-ENTRY ) .
  APPEND TAB.
  TAB-KEY = 'BEGPT'.
  TAB-ENTRY+8 = 'Beginntag Personenauswahl'.
  TAB-LENGTH = STRLEN( TAB-ENTRY ) .
  APPEND TAB.
  TAB-KEY = 'ENDPT'.
  TAB-ENTRY+8 = 'Endetag Personenauswahl'.
  TAB-LENGTH = STRLEN( TAB-ENTRY ) .
  APPEND TAB.
  TAB-KEY = 'BEGDO'.
  TAB-ENTRY+8 = 'Monatsoffset Beginn Daten'.
  TAB-LENGTH = STRLEN( TAB-ENTRY ) .
  APPEND TAB.
  TAB-KEY = 'ENDDO'.
  TAB-ENTRY+8 = 'Monatsoffset Ende Daten'.
  TAB-LENGTH = STRLEN( TAB-ENTRY ) .
  APPEND TAB.
  TAB-KEY = 'BEGPO'.
  TAB-ENTRY+8 = 'Monatsoffset Beginn Personen'.
  TAB-LENGTH = STRLEN( TAB-ENTRY ) .
  APPEND TAB.
  TAB-KEY = 'ENDPO'.
  TAB-ENTRY+8 = 'Monatsoffset Ende Personen'.
  TAB-LENGTH = STRLEN( TAB-ENTRY ) .
  APPEND TAB.

  TAB-KEY = 'ZZPKAT'.
  TAB-ENTRY+8 = 'Personalkategorie'.
  TAB-LENGTH = STRLEN( TAB-ENTRY ) .
  APPEND TAB.
  TAB-KEY = 'ZZHANSP'.
  TAB-ENTRY+8 = 'Versorgungsanspruch'.
  TAB-LENGTH = STRLEN( TAB-ENTRY ) .
  APPEND TAB.
  TAB-KEY = 'ZZBREINH'.
  TAB-ENTRY+8 = 'Betriebsratseinheit'.
  TAB-LENGTH = STRLEN( TAB-ENTRY ) .
  APPEND TAB.
  TAB-KEY = 'ZZSTANDO'.
  TAB-ENTRY+8 = 'Standort'.
  TAB-LENGTH = STRLEN( TAB-ENTRY ) .
  APPEND TAB.
  TAB-KEY = 'ZZSEL'.                                       "SIE004
  TAB-ENTRY+8 = 'Selektion Errechnung'.                    "SIE004
  TAB-LENGTH = STRLEN( TAB-ENTRY ) .                       "SIE004
  APPEND TAB.                                              "SIE004

* Ad-Hoc Läufe
 TAB-KEY = 'P_ADHOC'.
 TAB-ENTRY+8 = 'Ad-Hoc Lauf'.
 TAB-LENGTH = STRLEN( TAB-ENTRY ) .
 APPEND TAB.

  SORT TAB BY ID KEY.
  INSERT TEXTPOOL G_REPID FROM TAB LANGUAGE SY-LANGU.
ENDFORM.                    " INSERT_TEXTE
