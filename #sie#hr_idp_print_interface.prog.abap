* XFT20020208 Performance Verbesserung beim lesen der DDIC Texte
*             da Abbrüche bei der Laufzeit! Nicht Zeiolenweise markiert

REPORT /SIE/HR_IDP_PRINT_INTERFACE MESSAGE-ID /SIE/HR_IDP_MESSAGES
  NO STANDARD PAGE HEADING LINE-SIZE 80 LINE-COUNT 65.

*&---------------------------------------------------------------------*
*&                                                                     *
*& Schnittstellenbeschreibung drucken                                  *
*&                                                                     *
*&---------------------------------------------------------------------*

RP-LOW-HIGH.

TABLES: /SIE/HR_IDP_S1,
        /SIE/HR_IDP_S1T,
        /SIE/HR_IDP_S1VN,
        /SIE/HR_IDP_S1F,
        /SIE/HR_IDP_S1LT,
        /SIE/HR_IDP_S1DF,
        /SIE/HR_IDP_S1PC,
        /SIE/HR_IDP_F1T,
        /SIE/HR_IDP_REPA,
        /SIE/HR_IDP_S1SA,
        T001P,
        T582S,
        T591S.

TYPES TY_THEMA(30).

DATA: BEGIN OF S1 OCCURS 0,
        IFCID TYPE /SIE/HR_IDP_S1-IFCID,
        IDENT TYPE /SIE/HR_IDP_S1T-IDENT,
      END OF S1.
DATA: BEGIN OF S1F OCCURS 0,
        IFCID TYPE /SIE/HR_IDP_S1-IFCID,
        VRSNR TYPE /SIE/HR_IDP_S1VN-VRSNR,
        TROLE TYPE /SIE/HR_IDP_S1F-TROLE,
        CH_DATUM LIKE /SIE/HR_IDP_S1F-CH_DATUM,
      END OF S1F.
DATA: BEGIN OF IFACE OCCURS 0,
        IFCID TYPE /SIE/HR_IDP_S1-IFCID,
        VRSNR TYPE /SIE/HR_IDP_S1VN-VRSNR,
      END OF IFACE.
DATA: BEGIN OF AUSGABE_FOLGE OCCURS 0,
        LTEXT TYPE TY_THEMA,
        SRTNR(2) TYPE N,
      END OF AUSGABE_FOLGE.
DATA: BEGIN OF SRTTB OCCURS 0,
       SRTNR(1),
      END OF SRTTB.

DATA  LTEXT TYPE /SIE/HR_IDP_S1LT OCCURS 0 WITH HEADER LINE.
DATA  ROLLE TYPE /SIE/HR_IDP_S1R  OCCURS 0 WITH HEADER LINE.
DATA  UC4PA TYPE /SIE/HR_IDP_S1DF OCCURS 0 WITH HEADER LINE.
DATA  SELOP TYPE /SIE/HR_IDP_S1VT OCCURS 0 WITH HEADER LINE.
DATA  PRMTR TYPE /SIE/HR_IDP_S1PR OCCURS 0 WITH HEADER LINE.
DATA  SARTN TYPE /SIE/HR_IDP_S1PG OCCURS 0 WITH HEADER LINE.
DATA  S1SA TYPE /SIE/HR_IDP_S1SA OCCURS 0 WITH HEADER LINE.
DATA  S1DL TYPE /SIE/HR_IDP_S1DL OCCURS 0 WITH HEADER LINE.
DATA  S1PC TYPE /SIE/HR_IDP_S1PC OCCURS 0 WITH HEADER LINE.
DATA  SRTNR1(3) TYPE N.
DATA  SRTNR2(3) TYPE N.
DATA  OLD_IFCID LIKE /SIE/HR_IDP_S1-IFCID.
DATA  STRLN TYPE I.
DATA  OLD_VRSNR LIKE /SIE/HR_IDP_S1VN-VRSNR.
DATA  PRINT_VRSNR LIKE /SIE/HR_IDP_S1VN-VRSNR.
DATA  SW_KOPFZ TYPE XFELD.
DATA  C_LTEXT TYPE TY_THEMA VALUE 'Dokumentation'.
DATA  C_ROLLE TYPE TY_THEMA VALUE 'Schnittstellenverantwortliche'.
DATA  C_UC4PA TYPE TY_THEMA VALUE 'Allgemeine Parameter'.
DATA  C_SELOP TYPE TY_THEMA VALUE 'Selektionen'.
DATA  C_PARAM TYPE TY_THEMA VALUE 'Zeitparameter'.
DATA  C_SARTN TYPE TY_THEMA VALUE 'Satzarten und Felder'.
DATA  C_PRIC TYPE TY_THEMA VALUE 'Pricing'.
DATA  C_VRTRG TYPE TY_THEMA VALUE 'Vertrag'.
DATA  SORTN(7) VALUE 'P_SORT0'.
DATA  PARAM(7) VALUE 'P_PARM0'.
DATA  DNAME LIKE  DD07V-DOMNAME.
DATA  RTEXT TYPE DD07V-DDTEXT.
DATA  DD_TEXT TYPE DD04T-SCRTEXT_L.
DATA  TEXT TYPE DD07V-DDTEXT.

*{ XFT20020208
TYPES: BEGIN OF TS_TEXT
     , TABLE TYPE TABNAME
     , FIELD TYPE FIELDNAME
     , TEXT TYPE DD04T-SCRTEXT_L
     , END OF TS_TEXT
     .

DATA: WA_TEXT TYPE TS_TEXT.

DATA: GT_TEXT TYPE STANDARD TABLE OF TS_TEXT INITIAL SIZE 0.
*} XFT20020208

DATA:  GT_LISTE TYPE STANDARD TABLE OF ABAPLIST INITIAL SIZE 0 WITH
       HEADER LINE.

FIELD-SYMBOLS: <SORTNR>,
               <PARAMETER>.

DEFINE FILL_FOLGE.
  AUSGABE_FOLGE-LTEXT = &1.
  AUSGABE_FOLGE-SRTNR = &2.
  APPEND AUSGABE_FOLGE.
END-OF-DEFINITION.

RANGES S_IFACE FOR /SIE/HR_IDP_S1-IFCID.

SELECTION-SCREEN BEGIN OF BLOCK SEL WITH FRAME TITLE TEXT-S00.

SELECT-OPTIONS: S_AUTHC FOR /SIE/HR_IDP_S1-AUTH_CLASS.

SELECT-OPTIONS: S_IFCID FOR /SIE/HR_IDP_S1-IFCID,
                S_VRSNR FOR /SIE/HR_IDP_S1VN-VRSNR.

SELECTION-SCREEN BEGIN OF BLOCK RADIO WITH FRAME TITLE TEXT-S13.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 1.
PARAMETERS P_INARB LIKE /SIE/HR_IDP_REPA-INARB.
SELECTION-SCREEN COMMENT 4(19) TEXT-S17 FOR FIELD P_INARB.
SELECTION-SCREEN POSITION 25.
PARAMETERS P_FREIG LIKE /SIE/HR_IDP_REPA-FREIG.
SELECTION-SCREEN COMMENT 28(19) TEXT-S14 FOR FIELD P_FREIG.
SELECTION-SCREEN POSITION 48.
PARAMETERS P_ABGEN LIKE /SIE/HR_IDP_REPA-ABGEN.
SELECTION-SCREEN COMMENT 51(19) TEXT-S15 FOR FIELD P_ABGEN.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK RADIO.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) TEXT-S01.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS P_VLIDF LIKE /SIE/HR_IDP_S1-VALID_FROM.
SELECTION-SCREEN POSITION 45.
SELECTION-SCREEN COMMENT 52(4) TEXT-S02.
SELECTION-SCREEN POSITION POS_HIGH.
PARAMETERS P_VLIDT LIKE /SIE/HR_IDP_S1-VALID_TO.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK SEL.

SELECTION-SCREEN BEGIN OF BLOCK AUS WITH FRAME TITLE TEXT-S03.

SELECTION-SCREEN COMMENT 1(20) TEXT-S19.
SELECTION-SCREEN COMMENT 30(15) TEXT-S04.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS P_PARM1 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT 4(20) TEXT-S05 FOR FIELD P_PARM1.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS P_SORT1 TYPE /SIE/HR_IDP_SORT1 DEFAULT '1'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS P_PARM2 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT 4(29) TEXT-S06 FOR FIELD P_PARM2.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS P_SORT2 TYPE /SIE/HR_IDP_SORT1 DEFAULT '2'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS P_PARM3 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT 4(20) TEXT-S07 FOR FIELD P_PARM3.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS P_SORT3 TYPE /SIE/HR_IDP_SORT1 DEFAULT '3'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS P_PARM4 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT 4(20) TEXT-S08 FOR FIELD P_PARM4.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS P_SORT4 TYPE /SIE/HR_IDP_SORT1 DEFAULT '4'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS P_PARM5 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT 4(20) TEXT-S09 FOR FIELD P_PARM5.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS P_SORT5 TYPE /SIE/HR_IDP_SORT1 DEFAULT '5'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS P_PARM6 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT 4(20) TEXT-S10 FOR FIELD P_PARM6.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS P_SORT6 TYPE /SIE/HR_IDP_SORT1 DEFAULT '6'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS P_PARM7 AS CHECKBOX DEFAULT 'X'.                 "#EC NOTEXT
SELECTION-SCREEN COMMENT 4(20) TEXT-S18 FOR FIELD P_PARM8.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS P_SORT7 TYPE /SIE/HR_IDP_SORT1 DEFAULT '7'.      "#EC NOTEXT
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS P_PARM8 AS CHECKBOX.
SELECTION-SCREEN COMMENT 4(20) TEXT-S11 FOR FIELD P_PARM8.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(25) TEXT-S12.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS P_ANZHL(1) TYPE N DEFAULT '1'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK AUS.

AT SELECTION-SCREEN ON BLOCK SEL.
  IF NOT S_VRSNR[] IS INITIAL
    AND ( ( NOT P_INARB IS INITIAL ) OR ( NOT P_FREIG IS INITIAL ) OR
    ( NOT P_ABGEN IS INITIAL ) ).
    SET CURSOR FIELD 'S_VRSNR-LOW'.
    MESSAGE E230.
  ENDIF.
  IF P_VLIDF GT P_VLIDT.
    SET CURSOR FIELD 'P_VLIDF'.
    MESSAGE E239 WITH P_VLIDF P_VLIDT.
  ENDIF.

AT SELECTION-SCREEN ON BLOCK AUS.
  CLEAR SRTTB. REFRESH SRTTB.
  DO 7 TIMES.
    SORTN+6(1) = SY-INDEX.
    PARAM+6(1) = SY-INDEX.
    ASSIGN (SORTN) TO <SORTNR>.
    ASSIGN (PARAM) TO <PARAMETER>.
    IF <PARAMETER> EQ 'X'.
      SRTTB-SRTNR = <SORTNR>.
      APPEND SRTTB.
    ENDIF.
  ENDDO.
  SORT SRTTB.
  DELETE ADJACENT DUPLICATES FROM SRTTB.
  IF SY-SUBRC EQ 0.
    MESSAGE E238.
  ENDIF.
  LOOP AT SRTTB WHERE SRTNR GT 7.
    EXIT.
  ENDLOOP.
  IF SY-SUBRC EQ 0.
    MESSAGE E240.
  ENDIF.

START-OF-SELECTION.

  IF P_VLIDF IS INITIAL.
    P_VLIDF = LOW_DATE.
  ENDIF.
  IF P_VLIDT IS INITIAL.
    P_VLIDT = HIGH_DATE.
  ENDIF.

  IF P_PARM1 EQ 'X'.
    FILL_FOLGE C_LTEXT P_SORT1.
  ENDIF.
  IF P_PARM2 EQ 'X'.
    FILL_FOLGE C_ROLLE P_SORT2.
  ENDIF.
  IF P_PARM3 EQ 'X'.
    FILL_FOLGE C_UC4PA P_SORT3.
  ENDIF.
  IF P_PARM4 EQ 'X'.
    FILL_FOLGE C_SELOP P_SORT4.
  ENDIF.
  IF P_PARM5 EQ 'X'.
    FILL_FOLGE C_PARAM P_SORT5.
  ENDIF.
  IF P_PARM6 EQ 'X'.
    FILL_FOLGE C_SARTN P_SORT6.
  ENDIF.
  IF P_PARM7 EQ 'X'.
    FILL_FOLGE C_PRIC 7.
  ENDIF.
  IF P_PARM8 EQ 'X'.
    FILL_FOLGE C_VRTRG 8.
  ENDIF.

  SORT AUSGABE_FOLGE BY SRTNR.

  PERFORM FILL_TABLE_S1 TABLES S1.
  DESCRIBE TABLE S1.
  IF SY-TFILL = 0.
  EXIT.
  ENDIF.

  PERFORM FILL_SEL_OPTION_IFACE TABLES S_IFACE
                                       S1.

* Auswertung der Bestimmungsoptionen der Versionsnummer
  IF S_VRSNR[] IS INITIAL AND
    ( P_INARB EQ 'X' OR P_FREIG EQ 'X' OR P_ABGEN EQ 'X' ).
    PERFORM FILL_TABLE_S1F TABLES S1F.
* in Arbeit
    IF P_INARB EQ 'X'.
      PERFORM IN_ARBEIT TABLES S1F
                               IFACE.
    ENDIF.
* freigegebenen
    IF P_FREIG EQ 'X'.
      PERFORM AKTUELL_FREIGEGEBEN TABLES IFACE.
    ENDIF.
* abgenommen
    IF P_ABGEN EQ 'X'.
      PERFORM ABGENOMMEN TABLES S1F
                                IFACE.
    ENDIF.
  ELSE.
    PERFORM FILL_TABLE_IFACE TABLES IFACE.
  ENDIF.

  DESCRIBE TABLE IFACE.
  IF SY-TFILL EQ 0.
    MESSAGE I234.
    LEAVE PROGRAM.
  ENDIF.

  SORT IFACE DESCENDING BY IFCID VRSNR.
  IF NOT P_PARM1 IS INITIAL.
    PERFORM FILL_LTEXT TABLES LTEXT
                              IFACE.
  ENDIF.
  IF NOT P_PARM2 IS INITIAL.
    PERFORM FILL_ROLLE TABLES ROLLE
                              IFACE.
  ENDIF.
  IF NOT P_PARM3 IS INITIAL.
    PERFORM FILL_UC4PA TABLES UC4PA
                              IFACE.
    PERFORM FILL_S1DL TABLES S1DL
                              IFACE.
  ENDIF.
  IF NOT P_PARM4 IS INITIAL.
    PERFORM FILL_SELOP TABLES SELOP
                              IFACE.
  ENDIF.
  IF NOT P_PARM5 IS INITIAL.
    PERFORM FILL_PRMTR TABLES PRMTR
                              IFACE.
  ENDIF.
  IF NOT P_PARM6 IS INITIAL.
    PERFORM FILL_SARTN TABLES SARTN
                              IFACE.
    PERFORM FILL_S1SA TABLES S1SA
                             IFACE.
  ENDIF.
  IF NOT P_PARM7 IS INITIAL.
    PERFORM FILL_S1PC TABLES S1PC
                             IFACE.
  ENDIF.

END-OF-SELECTION.

  DO P_ANZHL TIMES.
    LOOP AT IFACE.
      PERFORM DRUCKE_SSTELLE.
    ENDLOOP.
  ENDDO.

TOP-OF-PAGE.
  PERFORM KOPF.

*&---------------------------------------------------------------------*
*&      Routinen
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FILL_SEL_OPTION_IFACE
*&---------------------------------------------------------------------*
FORM FILL_SEL_OPTION_IFACE TABLES P_IFACE STRUCTURE S_IFACE
                                  P_S1 STRUCTURE S1.
  P_IFACE-SIGN = 'I'.
  P_IFACE-OPTION = 'EQ'.
  LOOP AT P_S1.
    P_IFACE-LOW = P_S1-IFCID.
    APPEND P_IFACE.
  ENDLOOP.
ENDFORM.                    " FILL_SEL_OPTION_IFACE

*&---------------------------------------------------------------------*
*&      Form  ABGENOMMEN
*&---------------------------------------------------------------------*
*&      Selektion der zuletzt abgenommenen Schnittstelle
*&---------------------------------------------------------------------*
FORM ABGENOMMEN TABLES P_S1F   STRUCTURE S1F
                       P_IFACE STRUCTURE IFACE.
  SORT P_S1F BY CH_DATUM DESCENDING.
  LOOP AT P_S1F WHERE TROLE EQ 07
                AND ( NOT CH_DATUM IS INITIAL ).
    P_IFACE-IFCID = P_S1F-IFCID.
    P_IFACE-VRSNR = P_S1F-VRSNR.
    APPEND P_IFACE.
    EXIT.
  ENDLOOP.
ENDFORM.                    " ABGENOMMEN

*&---------------------------------------------------------------------*
*&      Form  AKTUELL_FREIGEGEBEN
*&---------------------------------------------------------------------*
FORM AKTUELL_FREIGEGEBEN TABLES P_IFACE STRUCTURE IFACE.
  SELECT IFCID ACT_VERS_NR APPENDING TABLE P_IFACE FROM /SIE/HR_IDP_S1
    WHERE IFCID IN S_IFACE AND NOT ACT_VERS_NR IS NULL.
ENDFORM.                    " AKTUELL_FREIGEGEBEN

*&---------------------------------------------------------------------*
*&      Form  IN_ARBEIT
*&---------------------------------------------------------------------*
FORM IN_ARBEIT TABLES P_S1F   STRUCTURE S1F
                      P_IFACE STRUCTURE IFACE.
  LOOP AT P_S1F WHERE TROLE EQ 06
                AND   CH_DATUM IS INITIAL.
    P_IFACE-IFCID = P_S1F-IFCID.
    P_IFACE-VRSNR = P_S1F-VRSNR.
    APPEND P_IFACE.
  ENDLOOP.
ENDFORM.                    " IN_ARBEIT

*&---------------------------------------------------------------------*
*&      Form  KOPF
*&---------------------------------------------------------------------*
FORM KOPF.
  FORMAT COLOR COL_NORMAL INTENSIFIED ON.
  ULINE.
  WRITE: /01 SY-DATUM DD/MM/YYYY,
          25 TEXT-K01,
          70 'Seite', (05) SY-PAGNO.
  FORMAT RESET.
  ULINE.
  SKIP.
ENDFORM.                    " KOPF

*&---------------------------------------------------------------------*
*&      Form  FILL_LTEXT
*&---------------------------------------------------------------------*
FORM FILL_LTEXT TABLES  P_LTEXT STRUCTURE LTEXT
                        P_IFACE STRUCTURE IFACE.
  SELECT * INTO TABLE P_LTEXT FROM /SIE/HR_IDP_S1LT
    FOR ALL ENTRIES IN P_IFACE WHERE IFCID EQ P_IFACE-IFCID.
  IF SY-SUBRC EQ 0.
    SORT P_LTEXT BY IFCID SEQNR.
  ENDIF.
ENDFORM.                    " FILL_LTEXT

*&---------------------------------------------------------------------*
*&      Form  GET_DOMA_TEXT
*&---------------------------------------------------------------------*
FORM GET_DOMA_TEXT USING    VALUE(FELD)
                            VALUE(DNAME)
                   CHANGING TEXT TYPE DD07V-DDTEXT.

  STATICS: L_FELD TYPE DD07V-DOMVALUE_L,
           L_TEXT TYPE DD07V-DDTEXT.
  L_FELD = FELD.
  CALL FUNCTION 'DOMAIN_VALUE_GET'
       EXPORTING
            I_DOMNAME  = DNAME
            I_DOMVALUE = L_FELD
       IMPORTING
            E_DDTEXT   = L_TEXT
       EXCEPTIONS
            NOT_EXIST  = 1
            OTHERS     = 2.
  IF SY-SUBRC <> 0.
    CLEAR TEXT.
  ELSE.
    TEXT = L_TEXT.
  ENDIF.
ENDFORM.                    " GET_DOMA_TEXT

*&---------------------------------------------------------------------*
*&      Form  FILL_ROLLE
*&---------------------------------------------------------------------*
FORM FILL_ROLLE TABLES P_ROLLE STRUCTURE ROLLE
                       P_IFACE STRUCTURE IFACE.
  SELECT * INTO TABLE P_ROLLE FROM /SIE/HR_IDP_S1R
    FOR ALL ENTRIES IN P_IFACE WHERE IFCID EQ P_IFACE-IFCID
                               AND   VRSNR EQ P_IFACE-VRSNR.
  IF SY-SUBRC EQ 0.
    SORT P_ROLLE BY IFCID VRSNR DESCENDING TROLE.
  ENDIF.
ENDFORM.                    " FILL_ROLLE

*&---------------------------------------------------------------------*
*&      Form  DRUCKE_SSTELLE
*&---------------------------------------------------------------------*
FORM DRUCKE_SSTELLE.
  PERFORM INIT.
  IF IFACE-IFCID NE OLD_IFCID.
    NEW-PAGE.
    WRITE: /1 TEXT-A03, IFACE-IFCID.
    STRLN = STRLEN( TEXT-A03 ) + STRLEN( S1-IFCID ) + STRLEN( 'X' ).
    ULINE AT /1(STRLN).
    SKIP.
    OLD_IFCID = IFACE-IFCID.
  ENDIF.
  PRINT_VRSNR = IFACE-VRSNR.
  SHIFT PRINT_VRSNR LEFT DELETING LEADING '0'.
  WRITE: /1 TEXT-A02, PRINT_VRSNR.
  LOOP AT AUSGABE_FOLGE.
    CASE AUSGABE_FOLGE-LTEXT.
      WHEN C_LTEXT.
        PERFORM PRINT_LTEXT TABLES LTEXT.
      WHEN C_ROLLE.
        PERFORM PRINT_ROLLE TABLES ROLLE.
      WHEN C_UC4PA.
        PERFORM PRINT_UC4PA TABLES UC4PA.
        PERFORM PRINT_S1DL TABLES S1DL.
      WHEN C_SELOP.
        PERFORM PRINT_SELOP TABLES SELOP.
      WHEN C_PARAM.
        PERFORM PRINT_PARAM TABLES PRMTR.
      WHEN C_SARTN.
        PERFORM PRINT_SARTN TABLES SARTN
                                   S1SA.
      WHEN C_PRIC.
        PERFORM PRINT_PRIC TABLES S1PC.
      WHEN C_VRTRG.
        PERFORM PRINT_VRTRG.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " DRUCKE_SSTELLE

*&---------------------------------------------------------------------*
*&      Form  PRINT_LTEXT
*&---------------------------------------------------------------------*
*       Ausgabe Langtext
*----------------------------------------------------------------------*
FORM PRINT_LTEXT TABLES P_LTEXT STRUCTURE LTEXT.
  CHECK P_PARM1 EQ 'X'.
  SKIP.
  PERFORM UEBERSCHRIFT.
  SKIP.
  LOOP AT P_LTEXT WHERE IFCID EQ IFACE-IFCID.
    RESERVE 2 LINES.
    WRITE: /1 P_LTEXT-TLINE.
  ENDLOOP.
ENDFORM.                                          " PRINT_LTEXT

*&---------------------------------------------------------------------*
*&      Form  PRINT_ROLLE
*&---------------------------------------------------------------------*
*       Ausgabe Rollen
*----------------------------------------------------------------------*
FORM PRINT_ROLLE TABLES P_ROLLE STRUCTURE ROLLE.
  CHECK P_PARM2 EQ 'X'.
  DATA PERNR_LTEXT(55).
  DATA USERN_LTEXT(55).
  DATA ORGTX_LTEXT(55).
  DATA ENAME(40).
  DATA UNAME(40).
  DATA ORGTX(40).
  SKIP.
  PERFORM UEBERSCHRIFT.
  SKIP.
  LOOP AT P_ROLLE WHERE IFCID EQ IFACE-IFCID
                  AND   VRSNR EQ IFACE-VRSNR.
    RESERVE 4 LINES.
    PERFORM GET_DOMA_TEXT USING P_ROLLE-TROLE
                                '/SIE/HR_IDP_TRANS_ROLE'
                       CHANGING RTEXT.
    WRITE: /1 RTEXT.
    IF NOT P_ROLLE-PERNR IS INITIAL.
      PERFORM GET_ENAME USING P_ROLLE-PERNR
                     CHANGING ENAME.
      SHIFT P_ROLLE-PERNR LEFT DELETING LEADING '0'.
      CONCATENATE P_ROLLE-PERNR ENAME INTO PERNR_LTEXT
        SEPARATED BY SPACE.
      WRITE: /3 TEXT-A32, 23 PERNR_LTEXT.
    ENDIF.
    IF NOT P_ROLLE-USERN IS INITIAL.
      PERFORM GET_UNAME USING P_ROLLE-USERN
                     CHANGING UNAME.
      CONCATENATE P_ROLLE-USERN UNAME INTO USERN_LTEXT
        SEPARATED BY SPACE.
      WRITE: /3 TEXT-A33, 23 USERN_LTEXT.
    ENDIF.
    IF NOT P_ROLLE-ORGEH IS INITIAL.
      PERFORM GET_ORGTX USING P_ROLLE-ORGEH
                     CHANGING ORGTX.
      SHIFT P_ROLLE-ORGEH LEFT DELETING LEADING '0'.
      CONCATENATE P_ROLLE-ORGEH ORGTX INTO ORGTX_LTEXT
        SEPARATED BY SPACE.
      WRITE: /3 TEXT-A34, 23 ORGTX_LTEXT.
    ENDIF.
    IF NOT P_ROLLE-EMAIL IS INITIAL.
      WRITE: /3 TEXT-A01, 23 P_ROLLE-EMAIL.
    ENDIF.
  ENDLOOP.
ENDFORM.                                          " PRINT_ROLLE

*&---------------------------------------------------------------------*
*&      Form  GLIEDERUNGSNR
*&---------------------------------------------------------------------*
FORM GLIEDERUNGSNR USING    VALUE(P_SRTNR)
                   CHANGING VALUE(P_SRTNR2).
  SRTNR1 = P_SRTNR.
  SHIFT SRTNR1 LEFT DELETING LEADING '0'.
  CONCATENATE SRTNR1 '.' INTO P_SRTNR2.
ENDFORM.                    " GLIEDERUNGSNR

*&---------------------------------------------------------------------*
*&      Form  ÜBERSCHRIFT
*&---------------------------------------------------------------------*
FORM UEBERSCHRIFT.
  PERFORM GLIEDERUNGSNR USING AUSGABE_FOLGE-SRTNR
                     CHANGING SRTNR2.
  RESERVE 4 LINES.
  WRITE: /1 SRTNR2, 4 AUSGABE_FOLGE-LTEXT.
ENDFORM.                    " ÜBERSCHRIFT

*&---------------------------------------------------------------------*
*&      Form  INIT
*&---------------------------------------------------------------------*
FORM INIT.
  CLEAR: OLD_IFCID,
         OLD_VRSNR.
ENDFORM.                    " INIT

*&---------------------------------------------------------------------*
*&      Form  FILL_UC4PA
*&---------------------------------------------------------------------*
FORM FILL_UC4PA TABLES P_UC4PA STRUCTURE UC4PA
                       P_IFACE STRUCTURE IFACE.

  SELECT * INTO TABLE P_UC4PA FROM /SIE/HR_IDP_S1DF
    FOR ALL ENTRIES IN P_IFACE WHERE IFCID EQ P_IFACE-IFCID
                               AND   VRSNR EQ P_IFACE-VRSNR.
  IF SY-SUBRC EQ 0.
    SORT P_UC4PA BY IFCID VRSNR DESCENDING.
  ENDIF.
ENDFORM.                    " FILL_UC4PA

*---------------------------------------------------------------------*
*       FORM FILL_S1DL                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_S1DL                                                        *
*  -->  P_IFACE                                                       *
*---------------------------------------------------------------------*
FORM FILL_S1DL TABLES P_S1DL STRUCTURE S1DL
                       P_IFACE STRUCTURE IFACE.
  SELECT * INTO TABLE P_S1DL FROM /SIE/HR_IDP_S1DL
    FOR ALL ENTRIES IN P_IFACE WHERE IFCID EQ P_IFACE-IFCID
                               AND   VRSNR EQ P_IFACE-VRSNR.
  IF SY-SUBRC EQ 0.
    SORT P_S1DL BY IFCID VRSNR DESCENDING.
  ENDIF.
ENDFORM.                    " FILL_UC4PA

*&---------------------------------------------------------------------*
*&      Form  PRINT_UC4PA
*&---------------------------------------------------------------------*
FORM PRINT_UC4PA TABLES P_UC4PA STRUCTURE UC4PA.
  CHECK P_PARM3 EQ 'X'.
  DATA: FIELDNAME TYPE DD03L-FIELDNAME,
        DATUM(10),
        UC4NR(15).
  SKIP.
  PERFORM UEBERSCHRIFT.
  SKIP.
  LOOP AT P_UC4PA WHERE IFCID EQ IFACE-IFCID
                  AND   VRSNR EQ IFACE-VRSNR.
    RESERVE 4 LINES.
    PERFORM GET_FIELDINFO USING 'GNRTD'
                                '/SIE/HR_IDP_S1DF'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 30 P_UC4PA-GNRTD.
    PERFORM GET_FIELDINFO USING 'PROGR'
                                '/SIE/HR_IDP_S1DF'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 30 P_UC4PA-PROGR.
    PERFORM GET_FIELDINFO USING 'GNRVT'
                                '/SIE/HR_IDP_S1DF'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 30 P_UC4PA-GNRVT.
    PERFORM GET_FIELDINFO USING 'VARIA'
                                '/SIE/HR_IDP_S1DF'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 30 P_UC4PA-VARIA.
    PERFORM GET_FIELDINFO USING 'UC4FR'
                                '/SIE/HR_IDP_S1DF'
                       CHANGING DD_TEXT.
    WRITE P_UC4PA-UC4FR TO DATUM.
    WRITE: / DD_TEXT, 30 DATUM.
    PERFORM GET_FIELDINFO USING 'UC4TO'
                                '/SIE/HR_IDP_S1DF'
                       CHANGING DD_TEXT.
    WRITE P_UC4PA-UC4TO TO DATUM.
    WRITE: /1 DD_TEXT, 30 DATUM.
    PERFORM GET_FIELDINFO USING 'UC4DY'
                                '/SIE/HR_IDP_S1DF'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 30 P_UC4PA-UC4DY.
    PERFORM GET_FIELDINFO USING 'UC4NR'
                                '/SIE/HR_IDP_S1DF'
                       CHANGING DD_TEXT.
    IF P_UC4PA-UC4NR IS INITIAL.
      WRITE: /1 DD_TEXT.
    ELSE.
      SHIFT P_UC4PA-UC4NR LEFT DELETING LEADING '0'.
      CONCATENATE TEXT-A35 P_UC4PA-UC4NR TEXT-A36 INTO UC4NR
        SEPARATED BY SPACE.
      WRITE: /1 DD_TEXT, 30 UC4NR.
    ENDIF.
    PERFORM GET_FIELDINFO USING 'UC4PR'
                                '/SIE/HR_IDP_S1DF'
                       CHANGING DD_TEXT.
    IF P_UC4PA-UC4PR IS INITIAL.
      WRITE: /1 DD_TEXT.
    ELSE.
      PERFORM GET_DOMA_TEXT USING P_UC4PA-UC4PR
                                  '/SIE/HR_IDP_UC4_PERIOD'
                         CHANGING RTEXT.
      WRITE: /1 DD_TEXT, 30 RTEXT.
    ENDIF.
    PERFORM GET_FIELDINFO USING 'FILEN'
                                '/SIE/HR_IDP_S1DF'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 30 P_UC4PA-FILEN.
    PERFORM GET_FIELDINFO USING 'HOSTN'
                                '/SIE/HR_IDP_S1DF'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 30 P_UC4PA-HOSTN.
    PERFORM GET_FIELDINFO USING 'TCPIP'
                                '/SIE/HR_IDP_S1DF'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 30 P_UC4PA-TCPIP.
    PERFORM GET_FIELDINFO USING 'PORTN'
                                '/SIE/HR_IDP_S1DF'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 30 P_UC4PA-PORTN.
    PERFORM GET_FIELDINFO USING 'TRFAD'
                                '/SIE/HR_IDP_S1DF'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 30 P_UC4PA-TRFAD.
    PERFORM GET_FIELDINFO USING 'ENCRY'
                                '/SIE/HR_IDP_S1DF'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 30 P_UC4PA-ENCRY.
*    PERFORM GET_FIELDINFO USING 'FIXFM'
*                                '/SIE/HR_IDP_S1DL'
*                       CHANGING DD_TEXT.
*    WRITE: /1 DD_TEXT, 30 P_S1DL-FIXFM.
*    PERFORM GET_FIELDINFO USING 'DELIM'
*                                '/SIE/HR_IDP_S1DL'
*                       CHANGING DD_TEXT.
*    WRITE: /1 DD_TEXT, 30 P_S1DL-DELIM.
    PERFORM GET_FIELDINFO USING 'EMSUC'
                                '/SIE/HR_IDP_S1DF'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 30 P_UC4PA-EMSUC.
    PERFORM GET_FIELDINFO USING 'EMERR'
                                '/SIE/HR_IDP_S1DF'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 30 P_UC4PA-EMERR.
    PERFORM GET_FIELDINFO USING 'UC4NM'
                                '/SIE/HR_IDP_S1DF'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 30 P_UC4PA-UC4NM.
  ENDLOOP.
ENDFORM.                    " PRINT_UC4PA

*---------------------------------------------------------------------*
*       FORM PRINT_S1DL                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_S1DL                                                        *
*---------------------------------------------------------------------*
FORM PRINT_S1DL TABLES P_S1DL STRUCTURE S1DL.
  CHECK P_PARM3 EQ 'X'.
  DATA: FIELDNAME TYPE DD03L-FIELDNAME,
        DATUM(10),
        UC4NR(15).
  LOOP AT P_S1DL WHERE IFCID EQ IFACE-IFCID
                  AND   VRSNR EQ IFACE-VRSNR.
    RESERVE 4 LINES.
    PERFORM GET_FIELDINFO USING 'FIXFM'
                                '/SIE/HR_IDP_S1DL'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 30 P_S1DL-FIXFM.
    PERFORM GET_FIELDINFO USING 'DELIM'
                                '/SIE/HR_IDP_S1DL'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 30 P_S1DL-DELIM.
  ENDLOOP.
ENDFORM.                    " PRINT_UC4PA

*&---------------------------------------------------------------------*
*&      Form  GET_FIELDINFO
*&---------------------------------------------------------------------*
FORM GET_FIELDINFO USING    P_FIELDNAME
                            VALUE(DNAME)
                   CHANGING P_TEXT.
*{ XFT20020208
* statics: lt_dd03l type dd03l occurs 0 with header line,
*          lt_dd04v type dd04v occurs 0 with header line.
 DATA: LT_DD03L TYPE DD03L OCCURS 0 WITH HEADER LINE,
          LT_DD04V TYPE DD04V OCCURS 0 WITH HEADER LINE.
 READ TABLE GT_TEXT INTO WA_TEXT
                    WITH KEY TABLE = DNAME
                             FIELD = P_FIELDNAME.
 IF SY-SUBRC = 0.
   P_TEXT = WA_TEXT-TEXT.
 ELSE.
  CALL FUNCTION 'FIELDNAME_ROLLNAME_TEXT'
       EXPORTING
            I_FIELDNAME         = P_FIELDNAME
            I_TABNAME           = DNAME
       TABLES
            E_DD03L             = LT_DD03L
            E_DD04V             = LT_DD04V
       EXCEPTIONS
            ERROR_IN_PARAMETERS = 1
            NOT_FOUND           = 2
            OTHERS              = 3.
  IF SY-SUBRC <> 0.
    CLEAR P_TEXT.
*   message e001.
  ELSE.
    IF LT_DD04V-SCRTEXT_L IS INITIAL.
      P_TEXT = LT_DD04V-SCRTEXT_M.
    ELSE.
      P_TEXT = LT_DD04V-SCRTEXT_L.
    ENDIF.
  ENDIF.
    WA_TEXT-TABLE = DNAME.
    WA_TEXT-FIELD = P_FIELDNAME.
    WA_TEXT-TEXT = P_TEXT.
    APPEND WA_TEXT TO GT_TEXT.
  ENDIF.
*} XFT20020208
ENDFORM.                    " GET_FIELDINFO

*&---------------------------------------------------------------------*
*&      Form  FILL_SELOP
*&---------------------------------------------------------------------*
FORM FILL_SELOP TABLES   P_SELOP STRUCTURE SELOP
                         P_IFACE STRUCTURE IFACE.
  SELECT * INTO TABLE P_SELOP FROM /SIE/HR_IDP_S1VT
    FOR ALL ENTRIES IN P_IFACE WHERE IFCID EQ P_IFACE-IFCID
                               AND   VRSNR EQ P_IFACE-VRSNR.
  IF SY-SUBRC EQ 0.
    SORT P_SELOP BY IFCID VRSNR DESCENDING FELDNAME SEQNO.
  ENDIF.
ENDFORM.                    " FILL_SELOP

*&---------------------------------------------------------------------*
*&      Form  PRINT_SELOP
*&---------------------------------------------------------------------*
FORM PRINT_SELOP TABLES   P_SELOP STRUCTURE SELOP.
  CHECK P_PARM4 EQ 'X'.
  DATA: FELDN_OLD TYPE /SIE/HR_IDP_S1VT-FELDNAME,
        ZEILE(60).
  SKIP.
  PERFORM UEBERSCHRIFT.
  SKIP.
  LOOP AT P_SELOP WHERE IFCID EQ IFACE-IFCID
                  AND   VRSNR EQ IFACE-VRSNR.
    IF P_SELOP-FELDNAME NE FELDN_OLD.
      SELECT SINGLE IDENT INTO /SIE/HR_IDP_F1T-IDENT
        FROM  /SIE/HR_IDP_F1T
        WHERE SPRAS EQ 'D'
        AND   FELDNAME EQ P_SELOP-FELDNAME.
      IF SY-SUBRC EQ 0.
        CONCATENATE TEXT-A08 P_SELOP-FELDNAME '-'
          /SIE/HR_IDP_F1T-IDENT INTO ZEILE SEPARATED BY SPACE.
      ELSE.
        CONCATENATE TEXT-A08 P_SELOP-FELDNAME INTO ZEILE
          SEPARATED BY SPACE.
      ENDIF.
    ENDIF.
    RESERVE 2 LINES.
    IF P_SELOP-FELDNAME NE FELDN_OLD.
      WRITE: /1 ZEILE.
    ENDIF.
    WRITE: /3 TEXT-A11.
    WRITE: /5 TEXT-A30, 29 P_SELOP-SSIGN.
    WRITE: /3 TEXT-A12, 29 P_SELOP-SOPTI.
    IF P_SELOP-SLLOW+0(1) CO '0'.
      SHIFT P_SELOP-SLLOW LEFT DELETING LEADING '0'.
    ENDIF.
    WRITE: /3 TEXT-A13, 29 P_SELOP-SLLOW.
    IF P_SELOP-SHIGH+0(1) CO '0'.
      SHIFT P_SELOP-SHIGH LEFT DELETING LEADING '0'.
    ENDIF.
    WRITE: /3 TEXT-A14, 29 P_SELOP-SHIGH.
    FELDN_OLD = P_SELOP-FELDNAME.
  ENDLOOP.
ENDFORM.                    " PRINT_SELOP

*&---------------------------------------------------------------------*
*&      Form  PRINT_PARAM
*&---------------------------------------------------------------------*
FORM PRINT_PARAM TABLES P_PRMTR STRUCTURE PRMTR.
  DATA ZEILE(50).
  CHECK P_PARM5 EQ 'X'.
  SKIP.
  PERFORM UEBERSCHRIFT.
  SKIP.
  LOOP AT P_PRMTR WHERE IFCID EQ IFACE-IFCID
                  AND   VRSNR EQ IFACE-VRSNR.
    PERFORM GET_DOMA_TEXT USING P_PRMTR-TIMED
                                '/SIE/HR_IDP_TIMED'
                       CHANGING RTEXT.
    CONCATENATE P_PRMTR-TIMED '-' RTEXT INTO ZEILE
      SEPARATED BY SPACE.
    WRITE: /1 TEXT-A16, 27 ZEILE.
    PERFORM GET_FIELDINFO USING 'BEGDT'
                                '/SIE/HR_IDP_S1PR'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 27 P_PRMTR-BEGDT.
    PERFORM GET_FIELDINFO USING 'BEGDO'
                                '/SIE/HR_IDP_S1PR'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 27 P_PRMTR-BEGDO.
    PERFORM GET_FIELDINFO USING 'ENDDT'
                                '/SIE/HR_IDP_S1PR'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 27 P_PRMTR-ENDDT.
    PERFORM GET_FIELDINFO USING 'ENDDO'
                                '/SIE/HR_IDP_S1PR'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 27 P_PRMTR-ENDDO.
    PERFORM GET_FIELDINFO USING 'BEGPT'
                                '/SIE/HR_IDP_S1PR'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 27 P_PRMTR-BEGPT.
    PERFORM GET_FIELDINFO USING 'BEGPO'
                                '/SIE/HR_IDP_S1PR'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 27 P_PRMTR-BEGPO.
    PERFORM GET_FIELDINFO USING 'ENDPT'
                                '/SIE/HR_IDP_S1PR'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 27 P_PRMTR-ENDPT.
    PERFORM GET_FIELDINFO USING 'ENDPO'
                                '/SIE/HR_IDP_S1PR'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 27 P_PRMTR-ENDPO.
    WRITE: /1 TEXT-A18.
    WRITE: /3 TEXT-A19, 27 P_PRMTR-XABKR.
    PERFORM GET_FIELDINFO USING 'ABKRO'
                                '/SIE/HR_IDP_S1PR'
                       CHANGING DD_TEXT.
    SHIFT P_PRMTR-ABKRO LEFT DELETING LEADING '0'.
    WRITE: /1 DD_TEXT, 27 P_PRMTR-ABKRO.
  ENDLOOP.
ENDFORM.                    " PRINT_PARAM

*&---------------------------------------------------------------------*
*&      Form  FILL_PRMTR
*&---------------------------------------------------------------------*
FORM FILL_PRMTR TABLES   P_PRMTR STRUCTURE PRMTR
                         P_IFACE STRUCTURE IFACE.
  SELECT * INTO TABLE P_PRMTR FROM /SIE/HR_IDP_S1PR
    FOR ALL ENTRIES IN P_IFACE WHERE IFCID EQ P_IFACE-IFCID
                               AND   VRSNR EQ P_IFACE-VRSNR.
  IF SY-SUBRC EQ 0.
    SORT P_PRMTR BY IFCID VRSNR DESCENDING.
  ENDIF.
ENDFORM.                    " FILL_PRMTR

*&---------------------------------------------------------------------*
*&      Form  FILL_SARTN
*&---------------------------------------------------------------------*
FORM FILL_SARTN TABLES   P_SARTN STRUCTURE SARTN
                         P_IFACE STRUCTURE IFACE.
  SELECT * INTO TABLE P_SARTN FROM /SIE/HR_IDP_S1PG
    FOR ALL ENTRIES IN P_IFACE WHERE IFCID EQ P_IFACE-IFCID
                               AND   VRSNR EQ P_IFACE-VRSNR.
  IF SY-SUBRC EQ 0.
    SORT P_SARTN BY IFCID VRSNR DESCENDING RECNA FLDPS.
  ENDIF.

ENDFORM.                    " FILL_SARTN

*&---------------------------------------------------------------------*
*&      Form  PRINT_SARTN
*&---------------------------------------------------------------------*
FORM PRINT_SARTN TABLES P_SARTN STRUCTURE SARTN
                        P_S1SA  STRUCTURE S1SA.
  CHECK P_PARM6 EQ 'X'.
  DATA: OLD_RECNA TYPE /SIE/HR_IDP_S1PG-RECNA,
        ZEILE(60),
        INFTY TYPE INFTY,
        SUBTY TYPE SUBTY.
  SKIP.
  PERFORM UEBERSCHRIFT.
  SKIP.
  LOOP AT P_SARTN WHERE IFCID EQ IFACE-IFCID.
    IF P_SARTN-RECNA NE OLD_RECNA.
      RESERVE 4 LINES.
      WRITE: /1 TEXT-A21, P_SARTN-RECNA.
      OLD_RECNA = P_SARTN-RECNA.
      PERFORM GET_FIELDINFO USING 'RECTY'
                                  '/SIE/HR_IDP_S1SA'
                         CHANGING DD_TEXT.
      READ TABLE P_S1SA WITH KEY IFCID = IFACE-IFCID
                                 VRSNR = IFACE-VRSNR
                                 RECNA = P_SARTN-RECNA.
      PERFORM GET_DOMA_TEXT USING P_S1SA-RECTY
                                  '/SIE/HR_IDP_RECORD_TYPE'
                         CHANGING RTEXT.
      IF RTEXT IS INITIAL.
        ZEILE = P_S1SA-RECTY.
      ELSE.
        CONCATENATE P_S1SA-RECTY '-' RTEXT INTO ZEILE
          SEPARATED BY SPACE.
      ENDIF.
      WRITE: /3 DD_TEXT, 25 ZEILE.
      PERFORM GET_FIELDINFO USING 'INFTY'
                                  '/SIE/HR_IDP_S1SA'
                         CHANGING DD_TEXT.
      IF P_S1SA-INFTY IS INITIAL.
        CLEAR ZEILE.
      ELSE.
        INFTY = P_S1SA-INFTY.
        SHIFT INFTY LEFT DELETING LEADING '0'.
        SELECT SINGLE ITEXT INTO T582S-ITEXT FROM T582S
          WHERE SPRSL EQ 'D'
          AND   INFTY EQ S1SA-INFTY
          AND   ITBLD EQ SPACE.
        IF SY-SUBRC EQ 0.
          CONCATENATE INFTY '-' T582S-ITEXT
            INTO ZEILE SEPARATED BY SPACE.
        ELSE.
          ZEILE = INFTY.
        ENDIF.
      ENDIF.
      WRITE: /3 DD_TEXT, 25 ZEILE.
      PERFORM GET_FIELDINFO USING 'SUBTY'
                                  '/SIE/HR_IDP_S1SA'
                         CHANGING DD_TEXT.
      IF P_S1SA-SUBTY IS INITIAL.
        CLEAR ZEILE.
      ELSE.
        SUBTY = P_S1SA-SUBTY.
        SHIFT SUBTY LEFT DELETING LEADING '0'.
        SELECT SINGLE STEXT INTO T591S-STEXT FROM T591S
          WHERE SPRSL EQ 'D'
          AND   INFTY EQ S1SA-INFTY
          AND   SUBTY EQ S1SA-SUBTY.
        IF SY-SUBRC EQ 0.
          CONCATENATE SUBTY '-' T591S-STEXT
            INTO ZEILE SEPARATED BY SPACE.
        ELSE.
          ZEILE = SUBTY.
        ENDIF.
      ENDIF.
      WRITE: /3 DD_TEXT, 25 ZEILE.
      PERFORM GET_FIELDINFO USING 'KZSRN'
                                  '/SIE/HR_IDP_S1SA'
                         CHANGING DD_TEXT.
      WRITE: /3 DD_TEXT, 25 P_S1SA-KZSRN.
      PERFORM GET_FIELDINFO USING 'KZSPN'
                                  '/SIE/HR_IDP_S1SA'
                         CHANGING DD_TEXT.
      WRITE: /3 DD_TEXT, 25 P_S1SA-KZSPN.
    ENDIF.
    PERFORM GET_FIELDINFO USING 'FELDNAME'
                                '/SIE/HR_IDP_S1PG'
                       CHANGING DD_TEXT.
    SELECT SINGLE IDENT INTO /SIE/HR_IDP_F1T-IDENT
      FROM  /SIE/HR_IDP_F1T
      WHERE SPRAS EQ 'D'
      AND   FELDNAME EQ P_SARTN-FELDNAME.
    IF SY-SUBRC EQ 0.
      CONCATENATE P_SARTN-FELDNAME '-' /SIE/HR_IDP_F1T-IDENT INTO ZEILE
        SEPARATED BY SPACE.
    ELSE.
      ZEILE = P_SARTN-FELDNAME.
      CLEAR /SIE/HR_IDP_F1T-IDENT.
    ENDIF.
    RESERVE 4 LINES.
    WRITE: /3 DD_TEXT, 25 ZEILE.
    PERFORM GET_FIELDINFO USING 'FLDPS'
                                '/SIE/HR_IDP_S1PG'
                       CHANGING DD_TEXT.
    SHIFT P_SARTN-FLDPS LEFT DELETING LEADING '0'.
    WRITE: /3 DD_TEXT, 25 P_SARTN-FLDPS.
    IF NOT P_SARTN-MTHBK IS INITIAL.
      PERFORM GET_FIELDINFO USING 'MTHBK'
                                  '/SIE/HR_IDP_S1PG'
                         CHANGING DD_TEXT.
      SHIFT P_SARTN-MTHBK LEFT DELETING LEADING '0'.
      WRITE: /5 DD_TEXT, 25 P_SARTN-MTHBK.
    ENDIF.
    IF NOT P_SARTN-KONVNAM IS INITIAL.
      PERFORM GET_FIELDINFO USING 'KONVNAM'
                                  '/SIE/HR_IDP_S1PG'
                         CHANGING DD_TEXT.
      WRITE: /5 DD_TEXT, 25 P_SARTN-KONVNAM.
    ENDIF.
    IF NOT P_SARTN-KEYPOS IS INITIAL.
      PERFORM GET_FIELDINFO USING 'KEYPOS'
                                  '/SIE/HR_IDP_S1PG'
                         CHANGING DD_TEXT.
      WRITE: /5 DD_TEXT, 25 P_SARTN-KEYPOS.
    ENDIF.
    IF NOT P_SARTN-PARAM IS INITIAL.
      PERFORM GET_FIELDINFO USING 'PARAM'
                                  '/SIE/HR_IDP_S1PG'
                         CHANGING DD_TEXT.
      WRITE: /5 DD_TEXT, 25 P_SARTN-PARAM.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " PRINT_SARTN

*---------------------------------------------------------------------*
*       FORM PRINT_PRIC                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_SARTN                                                       *
*  -->  P_S1PC                                                        *
*---------------------------------------------------------------------*
FORM PRINT_PRIC TABLES P_S1PC  STRUCTURE S1PC.

  CHECK P_PARM7 EQ 'X'.                                     "#EC NOTEXT
  DATA: ZEILE(60).

  SKIP.
  PERFORM UEBERSCHRIFT.
  SKIP.

  LOOP AT P_S1PC WHERE IFCID EQ IFACE-IFCID
                       AND   VRSNR EQ IFACE-VRSNR.

    PERFORM GET_FIELDINFO USING 'KSTORGID'
                                '/SIE/HR_IDP_S1PC'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 27 P_S1PC-KSTORGID.

    PERFORM GET_FIELDINFO USING 'KSTBSTLN'
                                '/SIE/HR_IDP_S1PC'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 27 P_S1PC-KSTBSTLN.

    PERFORM GET_FIELDINFO USING 'VERWZWCK'
                                '/SIE/HR_IDP_S1PC'
                       CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 27 P_S1PC-VERWZWCK.

    PERFORM GET_FIELDINFO USING 'KOSTKATE'
                                '/SIE/HR_IDP_S1PC'
                          CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 27 P_S1PC-KOSTKATE.

    PERFORM GET_FIELDINFO USING 'KOSTKATP'
                                '/SIE/HR_IDP_S1PC'
                          CHANGING DD_TEXT.
    WRITE: /1 DD_TEXT, 27 P_S1PC-KOSTKATP.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PRINT_VRTRG
*&---------------------------------------------------------------------*
FORM PRINT_VRTRG.
  CHECK P_PARM8 EQ 'X'.
  NEW-PAGE.
  SKIP 5.
  WRITE: /5 TEXT-A26.
  SKIP.
  WRITE: /30 TEXT-A27.
  SKIP.
  WRITE: /5 TEXT-A28.
  SKIP 3.
  WRITE: /5 TEXT-A29.
  WRITE: /5 'stelle(n) gemäss dieser Schnittstellenbeschreibung zu'.
  WRITE:    'liefern.'.
  SKIP 15.
  WRITE: /5 'München, den', SY-DATUM.
  SKIP 5.
  WRITE: /5 'Auftraggeber', 50 'Auftragnehmer'.
ENDFORM.                    " PRINT_VRTRG

*&---------------------------------------------------------------------*
*&      Form  FILL_TABLE_S1
*&---------------------------------------------------------------------*
FORM FILL_TABLE_S1 TABLES P_S1 STRUCTURE S1.
  SELECT  /SIE/HR_IDP_S1~IFCID /SIE/HR_IDP_S1T~IDENT
    INTO  TABLE P_S1 FROM /SIE/HR_IDP_S1 INNER JOIN /SIE/HR_IDP_S1T
    ON    /SIE/HR_IDP_S1~IFCID EQ /SIE/HR_IDP_S1T~IFCID
    WHERE /SIE/HR_IDP_S1~IFCID IN S_IFCID
    AND   AUTH_CLASS IN S_AUTHC
    AND   VALID_FROM LE P_VLIDT
    AND   VALID_TO   GE P_VLIDF.
ENDFORM.                    " FILL_TABLE_S1

*&---------------------------------------------------------------------*
*&      Form  FILL_TABLE_S1F
*&---------------------------------------------------------------------*
FORM FILL_TABLE_S1F TABLES P_S1F STRUCTURE S1F.
  SELECT IFCID VRSNR TROLE CH_DATUM INTO TABLE P_S1F
    FROM /SIE/HR_IDP_S1F WHERE IFCID IN S_IFACE.
ENDFORM.                    " FILL_TABLE_S1F

*&---------------------------------------------------------------------*
*&      Form  FILL_TABLE_IFACE
*&---------------------------------------------------------------------*
FORM FILL_TABLE_IFACE TABLES   P_IFACE STRUCTURE IFACE.
  SELECT IFCID VRSNR INTO TABLE P_IFACE FROM /SIE/HR_IDP_S1VN
    WHERE IFCID IN S_IFCID
    AND   VRSNR IN S_VRSNR.
ENDFORM.                    " FILL_TABLE_IFACE

*&---------------------------------------------------------------------*
*&      Form  GET_ENAME
*&---------------------------------------------------------------------*
FORM GET_ENAME USING    P_PERNR
               CHANGING P_ENAME.

  DATA: PERSONNEL_NUMBER TYPE  PRELP-PERNR
      , RC TYPE SYSUBRC
      , EDIT_NAME(80)
      .
  DATA: BEGIN OF ITAB_0001 OCCURS 0.
          INCLUDE STRUCTURE P0001.
  DATA: END OF ITAB_0001 VALID BETWEEN BEGDA AND ENDDA.
  DATA: BEGIN OF ITAB_0002 OCCURS 0.
          INCLUDE STRUCTURE P0002.
  DATA: END OF ITAB_0002 VALID BETWEEN BEGDA AND ENDDA.

  RP-LOW-HIGH.

  RP-SET-NAME-FORMAT.
  PERSONNEL_NUMBER = P_PERNR.

  CALL FUNCTION 'HR_READ_INFOTYPE'
       EXPORTING
            PERNR           = PERSONNEL_NUMBER
            INFTY           = '0001'
       IMPORTING
            SUBRC           = RC
       TABLES
            INFTY_TAB       = ITAB_0001
       EXCEPTIONS
            INFTY_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
    CLEAR EDIT_NAME.
  ELSE.
    SORT ITAB_0001 BY ENDDA DESCENDING.
    READ TABLE ITAB_0001 INDEX 1.
    SELECT SINGLE MOLGA INTO T001P-MOLGA FROM T001P
       WHERE WERKS EQ ITAB_0001-WERKS
       AND   BTRTL EQ ITAB_0001-BTRTL.

    CALL FUNCTION 'HR_READ_INFOTYPE'
         EXPORTING
              PERNR           = PERSONNEL_NUMBER
              INFTY           = '0002'
         IMPORTING
              SUBRC           = RC
         TABLES
              INFTY_TAB       = ITAB_0002
         EXCEPTIONS
              INFTY_NOT_FOUND = 1
              OTHERS          = 2.
    IF RC = 0.
      CALL FUNCTION 'RP_EDIT_NAME'
           EXPORTING
                PP0002    = ITAB_0002
                FORMAT    = $$FORMAT
                LANGU     = SY-LANGU
                MOLGA     = T001P-MOLGA
           IMPORTING
                EDIT_NAME = EDIT_NAME.
    ELSE.
      CLEAR EDIT_NAME.
    ENDIF.
  ENDIF.
  P_ENAME = EDIT_NAME.
ENDFORM.                    " GET_ENAME

*&---------------------------------------------------------------------*
*&      Form  GET_UNAME
*&---------------------------------------------------------------------*
FORM GET_UNAME USING    P_UNAME
               CHANGING P_XUNAME.

  DATA: USER_NAME LIKE  USR01-BNAME
      , USR03 LIKE USR03.

  USER_NAME = P_UNAME.

  CALL FUNCTION 'SUSR_USER_ADDRESS_READ'
       EXPORTING
            USER_NAME              = P_UNAME
       IMPORTING
            USER_USR03             = USR03
       EXCEPTIONS
            USER_ADDRESS_NOT_FOUND = 1
            OTHERS                 = 2.
  IF SY-SUBRC <> 0.
    CLEAR P_XUNAME.
  ELSE.
    CONCATENATE USR03-NAME1 USR03-NAME2 INTO P_XUNAME
                SEPARATED BY SPACE.
  ENDIF.
ENDFORM.                    " GET_UNAME

*&---------------------------------------------------------------------*
*&      Form  GET_ORGTX
*&---------------------------------------------------------------------*
FORM GET_ORGTX USING    P_ORGEH
               CHANGING P_ORGTX.
  DATA: STEXT LIKE P1000-STEXT
      , HR_SUBRC LIKE STRUC-SUBRC
      , REPID LIKE SY-REPID
      , OBJID LIKE PLOG-OBJID
      .

  REPID = SY-REPID.
  OBJID = P_ORGEH.

  CALL FUNCTION 'RH_READ_OBJECT'
       EXPORTING
            PLVAR     = '01'
            OTYPE     = 'O'
            OBJID     = OBJID
       IMPORTING
            STEXT     = STEXT
       EXCEPTIONS
            NOT_FOUND = 1
            OTHERS    = 2.
  IF SY-SUBRC <> 0.
    CLEAR P_ORGTX.
  ELSE.
    P_ORGTX = STEXT.
  ENDIF.
ENDFORM.                    " GET_ORGTX

*&---------------------------------------------------------------------*
*&      Form  FILL_S1SA
*&---------------------------------------------------------------------*
FORM FILL_S1SA TABLES   P_S1SA STRUCTURE S1SA
                        P_IFACE STRUCTURE IFACE.
  SELECT * INTO TABLE P_S1SA FROM /SIE/HR_IDP_S1SA
    FOR ALL ENTRIES IN P_IFACE WHERE IFCID EQ P_IFACE-IFCID
                               AND   VRSNR EQ P_IFACE-VRSNR.
  IF SY-SUBRC EQ 0.
    SORT P_S1SA BY IFCID VRSNR DESCENDING RECNA.
  ENDIF.
ENDFORM.                                                    " FILL_S1SA

*---------------------------------------------------------------------*
*       FORM FILL_S1PC                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_S1SA                                                        *
*  -->  P_IFACE                                                       *
*---------------------------------------------------------------------*
FORM FILL_S1PC TABLES   P_S1PC STRUCTURE S1PC
                        P_IFACE STRUCTURE IFACE.
  SELECT * INTO TABLE P_S1PC FROM /SIE/HR_IDP_S1PC
    FOR ALL ENTRIES IN P_IFACE WHERE IFCID EQ P_IFACE-IFCID.
  IF SY-SUBRC EQ 0.
    SORT P_S1PC BY IFCID.
  ENDIF.
ENDFORM.                                                    " FILL_S1PC
