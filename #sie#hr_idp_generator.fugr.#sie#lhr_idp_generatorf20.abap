*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_GENERATORF20 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  TRANSLATE_FIXFM
*&---------------------------------------------------------------------*
*       Übersetzung der Datenbankinternen Darstellung des fixformats
*       in Generatorformat.
*----------------------------------------------------------------------*
FORM TRANSLATE_FIXFM USING VALUE(P_FIXFM) TYPE C
                           VALUE(P_DELIM) TYPE C.

  CASE P_FIXFM.
    WHEN '1'.
      G_FIXFORMAT = YES.
      CLEAR G_DELIMITER.
    WHEN '2'.
      G_FIXFORMAT = NO.
      IF P_DELIM = 'A'.
        G_DELIMITER = '!'.
      ELSE.
        G_DELIMITER = P_DELIM.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " TRANSLATE_FIXFM

*&---------------------------------------------------------------------*
*&      Form  CHECK_VARIANT_UP_TO_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_REPORT_NAME  text
*      -->P_REPORT_NAME  text
*      -->P_VARI_NAME  text
*      <--P_SUBRC  text
*----------------------------------------------------------------------*
FORM CHECK_VARIANT_UP_TO_DATE USING P_REPORT LIKE SY-CPROG
                                    P_VARI_PROG LIKE SY-CPROG
                                    P_VARIANT LIKE SY-SLSET
                              CHANGING P_SUBRC LIKE SY-SUBRC.

  DATA L_RKEY LIKE RSVARKEY.
  DATA L_SSCR LIKE RSSCR OCCURS 30.
  DATA L_VARI LIKE RVARI OCCURS 20.
  DATA L_VARIVDAT LIKE RSVARIVDAT OCCURS 5.
  DATA L_VARIDYN  LIKE RSVARIDYN  OCCURS 5.
  DATA L_VDATDYN  LIKE RSVDATDYN  OCCURS 5.

  MOVE P_VARI_PROG TO L_RKEY-REPORT.
  MOVE P_VARIANT   TO L_RKEY-VARIANT.

  PERFORM LOAD_SSCR(RSDBRUNT) TABLES   L_SSCR
                              USING    P_REPORT
                              CHANGING P_SUBRC.

  IF P_SUBRC NE 0.
    P_SUBRC = 4.
    EXIT.
  ENDIF.

* Importiert 'statischen' Teil einer Variante
*     0: Variante aktuell                                              *
*     2: Veraltet, aber reparabel                                      *
*     4: Variante nicht vorhanden                                      *
*     8: Nicht reparabel, da sich Art, Typ oder Länge geändert hat.    *
  PERFORM IMPORT_VARIANT_STATIC(RSDBSPVD) USING L_SSCR[]
                                                L_VARI[]
                                                L_VARIVDAT
                                                L_VARIDYN
                                                L_VDATDYN
                                                L_RKEY
                                                P_SUBRC.

  IF P_SUBRC < 4.
    P_SUBRC = 0.
  ENDIF.

ENDFORM.                    " CHECK_VARIANT_UP_TO_DATE
