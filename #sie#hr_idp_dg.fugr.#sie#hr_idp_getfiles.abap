FUNCTION /SIE/HR_IDP_GETFILES.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(INTERFACE) TYPE  /SIE/HR_IDP_INTERFACE_ID
*"             VALUE(INCL_TESTFILES) TYPE  FLAG1 DEFAULT ' '
*"             VALUE(ALLOW_INITIAL) TYPE  FLAG1 DEFAULT ' '
*"       EXPORTING
*"             VALUE(CURRENT) TYPE  TEXT256
*"             VALUE(PREVIOUS) TYPE  TEXT256
*"       EXCEPTIONS
*"              INTERFACE_NOT_FOUND
*"              NOT_DELTA
*"              CANNOT_COMPUTE
*"----------------------------------------------------------------------
*Änderungen Hierl 24.10.2002 SIE001: Keine Testdateien berücksichtigen
*           Hierl 24.02.2002 SIE002: Kein Abbruch bei fehlender
*                                    Previous-Datei

TABLES: /SIE/HR_IDP_S1P,
        /SIE/HR_IDP_S1DF,
        /SIE/HR_IDP_S1.

DATA: S1P LIKE /SIE/HR_IDP_S1P OCCURS 0 WITH HEADER LINE.

  SELECT SINGLE * FROM /SIE/HR_IDP_S1 WHERE IFCID = INTERFACE.
  IF SY-SUBRC = 4.
    RAISE INTERFACE_NOT_FOUND.
  ENDIF.

  SELECT * FROM /SIE/HR_IDP_S1P INTO TABLE S1P
                                WHERE IFCID = INTERFACE
                                ORDER BY SEQNO DESCENDING.
  IF SY-SUBRC NE 0. RAISE CANNOT_COMPUTE. ENDIF.

  IF INCL_TESTFILES IS INITIAL.                       "SIE001
     LOOP AT S1P.                                     "SIE001
        CHECK S1P-PROGR CP '*TEST'.                   "SIE001
        DELETE S1P.                                   "SIE001
     ENDLOOP.                                         "SIE001
  ENDIF.                                              "SIE001

  READ TABLE S1P INDEX 1.
  IF SY-SUBRC NE 0. RAISE CANNOT_COMPUTE. ENDIF.
  CURRENT = S1P-PFNAM.
  SELECT SINGLE * FROM /SIE/HR_IDP_S1DF WHERE IFCID = INTERFACE
                                          AND VRSNR = S1P-VRSNR.
  IF SY-SUBRC NE 0. RAISE CANNOT_COMPUTE. ENDIF.
  IF /SIE/HR_IDP_S1DF-DELTA IS INITIAL.
    RAISE NOT_DELTA.
  ENDIF.

  READ TABLE S1P INDEX 2.
  IF SY-SUBRC NE 0.
     IF ALLOW_INITIAL IS INITIAL.  "SIE002
        RAISE CANNOT_COMPUTE.
     ENDIF.
     CLEAR PREVIOUS.    "SIE002
  ELSE.   "SIE002
     SELECT SINGLE * FROM /SIE/HR_IDP_S1DF WHERE IFCID = INTERFACE
                                             AND VRSNR = S1P-VRSNR.
     IF SY-SUBRC NE 0. RAISE CANNOT_COMPUTE. ENDIF.
     IF NOT /SIE/HR_IDP_S1DF-DELTA IS INITIAL.
        PREVIOUS = S1P-PFNAM.
     ENDIF.
  ENDIF.   "SIE002
ENDFUNCTION.
