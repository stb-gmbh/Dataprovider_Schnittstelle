*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_STAT_DB                                        *
*----------------------------------------------------------------------*
*  M. Przygocki 20230111 ATC findings C2C correction
*---------------------------------------------------------------------*
*       FORM READ_DB                                                  *
*---------------------------------------------------------------------*
FORM READ_DB.
  PERFORM READ_S1.  SORT GT_S1.
  PERFORM READ_S1P. SORT GT_S1P.
  PERFORM READ_S1L. SORT GT_S1L.
  PERFORM READ_S1S. SORT GT_S1S.
  PERFORM FILTER_DB.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM READ_S1S                                                 *
*---------------------------------------------------------------------*
FORM READ_S1.

  SELECT * FROM /SIE/HR_IDP_S1 INTO TABLE GT_S1
                                WHERE IFCID IN SO_IFCID.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM READ_S1P                                                 *
*---------------------------------------------------------------------*
FORM READ_S1P.
  DATA: RC LIKE SY-SUBRC.
  SELECT * FROM /SIE/HR_IDP_S1P INTO TABLE GT_S1P
                                WHERE IFCID IN SO_IFCID
                                AND   SEQNO IN SO_SEQNO
                                AND   BEGDA IN SO_BEGDA
                                AND   ENDDA IN SO_BEGDA
                                AND   BEGUZ IN SO_BEGUZ
                                AND   ENDUZ IN SO_BEGUZ.
  LOOP AT GT_S1P INTO WA_S1P.
    PERFORM CHECK_AUTHORITY USING WA_S1P-IFCID
                                  'S1P'
                            CHANGING RC.
    IF RC >< 0.
      DELETE TABLE GT_S1P FROM WA_S1P.
    ELSE.
* NOP
    ENDIF.
  ENDLOOP.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM READ_S1P                                                 *
*---------------------------------------------------------------------*
FORM READ_S1S.

  DATA: RC LIKE SY-SUBRC.
  SELECT * FROM /SIE/HR_IDP_S1S INTO TABLE GT_S1S
                                WHERE IFCID IN SO_IFCID
                                AND   SEQNO IN SO_SEQNO.
  LOOP AT GT_S1S INTO WA_S1S.
    PERFORM CHECK_AUTHORITY USING WA_S1S-IFCID
                                  'S1S'
                            CHANGING RC.
    IF RC >< 0.
      DELETE TABLE GT_S1S FROM WA_S1S.
    ELSE.
* nop
    ENDIF.
  ENDLOOP.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM READ_S1L                                                 *
*---------------------------------------------------------------------*
FORM READ_S1L.
  DATA: RC LIKE SY-SUBRC.
  SELECT * FROM /SIE/HR_IDP_S1L INTO TABLE GT_S1L
                                WHERE IFCID IN SO_IFCID
                                AND   SEQNO IN SO_SEQNO.
  LOOP AT GT_S1L INTO WA_S1L.
    PERFORM CHECK_AUTHORITY USING WA_S1P-IFCID
                                  'S1L'
                            CHANGING RC.
    IF RC >< 0.
      DELETE TABLE GT_S1L FROM WA_S1L.
    ELSE.
* nop
    ENDIF.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  READ_TEXT
*&---------------------------------------------------------------------*
FORM READ_TEXT.

  SELECT * FROM /SIE/HR_JUP_TAB WHERE JUPER = WA_S1S-JUPER
                                AND   ENDDA => SY-DATUM
                                AND   BEGDA <= SY-DATUM.
    EXIT.                                                   "#EC CI_NOORDER         M. Przygocki 20230111
  ENDSELECT.
  IF SY-SUBRC = 0.
* Do nothing
  ELSE.
    CLEAR /SIE/HR_JUP_TAB-LANGTEXT.
  ENDIF.

  SELECT * FROM T500P WHERE PERSA = WA_S1S-WERKS
                       AND   ZZ_ENDDA => SY-DATUM
                       AND   ZZ_BEGDA <= SY-DATUM.
    EXIT.
  ENDSELECT.
  IF SY-SUBRC = 0.
* do nothing.
  ELSE.
    CLEAR T500P.
  ENDIF.

  SELECT SINGLE * FROM /SIE/HR_BR_EITXT WHERE BREINH = WA_S1S-BREIN
                                        AND   SPRSL = SY-LANGU.
  IF SY-SUBRC = 0.
* do nothing
  ELSE.
    CLEAR /SIE/HR_BR_EITXT.
  ENDIF.

ENDFORM.                    " READ_TEXT

*&---------------------------------------------------------------------*
*&      Form  FILTER_DB
*&---------------------------------------------------------------------*
*       Die eingelesenen Daten werden nun mit den weiteren Selektionen
*       gefiltert
*----------------------------------------------------------------------*
FORM FILTER_DB.

  DATA: FL_DRIN TYPE TY_YESNO.

  CLEAR FL_DRIN.
  LOOP AT GT_S1P INTO WA_S1P.
    LOOP AT GT_S1S INTO WA_S1S
                   WHERE    IFCID = WA_S1S-IFCID
                   AND      SEQNO = WA_S1S-SEQNO.
      IF WA_S1S-BREIN IN SO_BREIN
         AND WA_S1S-JUPER IN SO_JUPER
         AND WA_S1S-WERKS IN SO_WERKS.
        FL_DRIN = YES.
      ENDIF.
    ENDLOOP.
    IF FL_DRIN = YES.
    ELSE.
* Den Eintrag löschen. Es genügt die s1p zu löschen, da diese
* die Ausgabe steuert.
      DELETE GT_S1P.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " FILTER_DB
