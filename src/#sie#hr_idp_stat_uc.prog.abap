*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_STAT_UC                                        *
*----------------------------------------------------------------------*

*at user-command.
*  perform handle_ok_codes.

*---------------------------------------------------------------------*
*       FORM HANDLE_OK_CODES                                          *
*---------------------------------------------------------------------*
FORM HANDLE_OK_CODES.

  CASE SY-UCOMM.
    WHEN 'DMAR'.                                            "#EC NOTEXT
      PERFORM SET_MULTI_SELECTION USING NO.
    WHEN 'REFR'.                                            "#EC NOTEXT
      PERFORM READ_DB.
      PERFORM WRITE_LOGS.
    WHEN 'MARK'.
      PERFORM SET_MULTI_SELECTION USING YES.
    WHEN 'DEL'.                                             "#EC NOTEXT
      PERFORM SET_MULTI_SELECTION USING YES.
      PERFORM DELETE_LOGS.
      PERFORM CLEAR_ALL.
      PERFORM READ_DB.
      PERFORM WRITE_LOGS.
    WHEN 'DEL2'.                                            "#EC NOTEXT
      PERFORM DELETE_LOGS.
      PERFORM CLEAR_ALL.
      PERFORM READ_DB.
      PERFORM WRITE_LOGS.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM RESET_MULTI_SELECTION                                    *
*---------------------------------------------------------------------*
FORM SET_MULTI_SELECTION USING P_BOOL.

  DO.
    READ LINE SY-INDEX FIELD VALUE G_MARK.
    IF SY-SUBRC NE 0. EXIT. ENDIF.
    MODIFY CURRENT LINE FIELD VALUE G_MARK FROM P_BOOL.
  ENDDO.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM DELETE_LOG                                               *
*---------------------------------------------------------------------*
FORM DELETE_LOGS.

  DATA: POPUP_ANSWER TYPE C
      , ID(10).

  CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_VALUE'
       EXPORTING
            TEXT_BEFORE   = 'Sollen die Protokolle'(023)
            TEXT_AFTER    = ' wirklich gelöscht werden?'(024)
            TITEL         = 'Protokolle: Löschen'(025)
            DEFAULTOPTION = 'N'                             "#EC NOTEXT
            OBJECTVALUE   = ID
       IMPORTING
            ANSWER        = POPUP_ANSWER.

  IF POPUP_ANSWER NE 'J'.                                   "#EC NOTEXT
    EXIT.
  ELSE.

    DO.
      READ LINE SY-INDEX FIELD VALUE G_MARK WA_S1P-IFCID
                                     WA_S1P-SEQNO.
      IF SY-SUBRC NE 0. EXIT. ENDIF.
      IF G_MARK = YES.
        PERFORM DELETE_LOG USING WA_S1P-IFCID WA_S1P-SEQNO.
        CLEAR G_MARK.
      ENDIF.
    ENDDO.

  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM DELETE_LOG                                               *
*---------------------------------------------------------------------*
FORM DELETE_LOG USING P_IFCID TYPE /SIE/HR_IDP_INTERFACE_ID
                      P_SEQNO TYPE /SIE/HR_IDP_SEQNO.

  SELECT SINGLE * FROM /SIE/HR_IDP_S1 WHERE IFCID = P_IFCID.
  IF SY-SUBRC = 0.
    CALL FUNCTION '/SIE/HR_IDP_AUTH_CHECK'
         EXPORTING
              ACTIVITY     = C_DELETE_EXE                   "#EC NOTEXT
              IF_CLASS     = /SIE/HR_IDP_S1-AUTH_CLASS
              OBJECT       = P_IFCID
              SUBOBJECT    = 'S1S'                          "#EC NOTEXT
         EXCEPTIONS
              NO_AUTHORITY = 1
              OTHERS       = 2.
    IF SY-SUBRC <> 0.
    ELSE.
      DELETE FROM /SIE/HR_IDP_S1S WHERE IFCID = P_IFCID
                                  AND   SEQNO = P_SEQNO.
    ENDIF.

    CALL FUNCTION '/SIE/HR_IDP_AUTH_CHECK'
         EXPORTING
              ACTIVITY     = C_DELETE_EXE                   "#EC NOTEXT
              IF_CLASS     = /SIE/HR_IDP_S1-AUTH_CLASS
              OBJECT       = P_IFCID
              SUBOBJECT    = 'S1P'                          "#EC NOTEXT
         EXCEPTIONS
              NO_AUTHORITY = 1
              OTHERS       = 2.
    IF SY-SUBRC <> 0.
    ELSE.
      DELETE FROM /SIE/HR_IDP_S1P WHERE IFCID = P_IFCID
                                  AND   SEQNO = P_SEQNO.
    ENDIF.

    CALL FUNCTION '/SIE/HR_IDP_AUTH_CHECK'
         EXPORTING
              ACTIVITY     = C_DELETE_EXE                   "#EC NOTEXT
              IF_CLASS     = /SIE/HR_IDP_S1-AUTH_CLASS
              OBJECT       = P_IFCID
              SUBOBJECT    = 'S1L'                          "#EC NOTEXT
         EXCEPTIONS
              NO_AUTHORITY = 1
              OTHERS       = 2.
    IF SY-SUBRC <> 0.
    ELSE.
      DELETE FROM /SIE/HR_IDP_S1L WHERE IFCID = P_IFCID
                                  AND   SEQNO = P_SEQNO.
    ENDIF.
  ENDIF.
ENDFORM.
