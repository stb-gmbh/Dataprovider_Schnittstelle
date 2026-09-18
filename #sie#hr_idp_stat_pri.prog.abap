*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_STAT_PRI                                       *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM WRITE_LOGS                                               *
*---------------------------------------------------------------------*
FORM WRITE_LOGS.
  FORMAT RESET.
  MOVE 0 TO SY-LSIND.
  CLEAR G_MARK.
  LOOP AT GT_S1P INTO WA_S1P.
    PERFORM PRINT_HEADER.
    PERFORM PRINT_S1P.
    PERFORM PRINT_S1S.
    PERFORM PRINT_S1L.
  ENDLOOP.
  IF SY-SUBRC >< 0.
    MESSAGE S558.
  ENDIF.
ENDFORM.

* Makrodefinitionen
DEFINE PRINT_INFO.
  CLEAR DD_TEXT.
  PERFORM GET_FIELDINFO USING &2
                              &1
                     CHANGING DD_TEXT.
  IF &4 IS INITIAL.
    WRITE: /1 DD_TEXT, 30 &3 COLOR COL_NORMAL.
  ELSE.
    WRITE: /1 DD_TEXT, 30 &3, 40 &4 COLOR COL_NORMAL.
  ENDIF.
END-OF-DEFINITION.

* Druckroutinen
*---------------------------------------------------------------------*
*       FORM PRINT_S1L                                                *
*---------------------------------------------------------------------*
FORM PRINT_S1L.
  IF NOT ( P_S1L IS INITIAL ).
    CHECK WA_S1P-SWLOG = YES.
    SKIP.
    WRITE: / 'Protokoll der Bewegungsdaten'.
    ULINE.

    LOOP AT GT_S1L INTO WA_S1L WHERE IFCID = WA_S1P-IFCID
                               AND   SEQNO = WA_S1P-SEQNO.
      SKIP.
      IF WA_S1L-LOGTP = 'E'.                                "#EC NOTEXT
        WRITE: / ICON_RED_LIGHT.
      ELSE.
        WRITE: / ICON_GREEN_LIGHT.
      ENDIF.
      WRITE: WA_S1L-TEXT.
    ENDLOOP.
    IF SY-SUBRC = 4.
      WRITE: / '<Leeres Protokoll>'(002).
    ENDIF.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PRINT_S1P                                                *
*---------------------------------------------------------------------*
FORM PRINT_S1P.
  IF NOT ( P_S1P IS INITIAL ).

    SKIP.

    PRINT_INFO: '/SIE/HR_IDP_S1P' 'PROGR' WA_S1P-PROGR  SPACE
             ,  '/SIE/HR_IDP_S1P' 'VARIA' WA_S1P-VARIA  SPACE
             ,  '/SIE/HR_IDP_S1P' 'BEGDA' WA_S1P-BEGDA  SPACE
             ,  '/SIE/HR_IDP_S1P' 'BEGUZ' WA_S1P-BEGUZ  SPACE
             ,  '/SIE/HR_IDP_S1P' 'ENDDA' WA_S1P-ENDDA  SPACE
             ,  '/SIE/HR_IDP_S1P' 'ENDUZ' WA_S1P-ENDUZ  SPACE
             ,  '/SIE/HR_IDP_S1P' 'ERROR' WA_S1P-ERROR  SPACE
             ,  '/SIE/HR_IDP_S1P' 'EMAIL' WA_S1P-EMAIL  SPACE
             ,  '/SIE/HR_IDP_S1P' 'NUMBR' WA_S1P-NUMBR  SPACE
             ,  '/SIE/HR_IDP_S1P' 'PFNAM' WA_S1P-PFNAM  SPACE
             ,  '/SIE/HR_IDP_S1P' 'UC4NAM' WA_S1P-UC4NAM  SPACE
             .
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PRINT_S1S                                                *
*---------------------------------------------------------------------*
FORM PRINT_S1S.
  IF NOT ( P_S1S IS INITIAL ).

    SKIP.
    WRITE: / 'Anzahl der selektierten Personalnummern'.

    LOOP AT GT_S1S INTO WA_S1S
                   WHERE IFCID = WA_S1P-IFCID
                   AND   SEQNO = WA_S1P-SEQNO.
      AT NEW SEQNO.
        SKIP.
        ULINE AT /3(113).
        WRITE: /3 SY-VLINE
             ,   5(35) 'Juristische Person'(010) COLOR COL_HEADING
             ,   40 SY-VLINE
             ,   42(35) 'Personalbereich'(011) COLOR COL_HEADING
             ,   70 SY-VLINE
             ,   72(35) 'Betriebsratseinheit'(012) COLOR COL_HEADING
             ,   100 SY-VLINE
             ,   102(14) 'Anzahl PNR'(013) COLOR COL_HEADING
             ,   115 SY-VLINE
             .
        ULINE AT /3(113).
      ENDAT.
      PERFORM READ_TEXT.
      WRITE: /3 SY-VLINE
           , 5 WA_S1S-JUPER(4) COLOR COL_NORMAL
           , /SIE/HR_JUP_TAB-LANGTEXT(28) COLOR COL_NORMAL
           , 40 SY-VLINE
           , 42 WA_S1S-WERKS(4) COLOR COL_NORMAL
           , T500P-NAME1(22) COLOR COL_NORMAL
           , 70 SY-VLINE
           , 72 WA_S1S-BREIN(3) COLOR  COL_NORMAL
           , /SIE/HR_BR_EITXT-TEXT(22) COLOR COL_NORMAL
           , 100 SY-VLINE
           , 102 WA_S1S-SELPN COLOR COL_NORMAL INTENSIFIED OFF
           , 115 SY-VLINE
           .
      AT END OF SEQNO.
        SUM.
        ULINE AT /3(113).
        WRITE: /3 SY-VLINE
               ,4(100) 'Summe der selektierten Personalnummern'(014)
               COLOR COL_TOTAL INTENSIFIED
               , 100 SY-VLINE
               , 102 WA_S1S-SELPN COLOR COL_TOTAL INTENSIFIED
               , 115 SY-VLINE.
        ULINE AT /3(113).
      ENDAT.
    ENDLOOP.
    IF SY-SUBRC = 4.
      WRITE: / '<Keine Personalnummern verarbeitet>'(002).
    ENDIF.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM GET_FIELDINFO                                            *
*---------------------------------------------------------------------*
FORM GET_FIELDINFO USING    P_FIELDNAME
                            VALUE(DNAME)
                   CHANGING P_TEXT.

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

ENDFORM.                    " GET_FIELDINFO
