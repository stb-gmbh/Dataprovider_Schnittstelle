*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_STAT_AUTH                                      *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM CHECK_AUTHORITY                                          *
*---------------------------------------------------------------------*
*       Prüft auf Berechtigung. Falls diese schon geprüft wurde       *
*       wird es hier nicht wiederholt, ansonsten wird geprüft.        *
*---------------------------------------------------------------------*
FORM CHECK_AUTHORITY USING VALUE(P_IFCID) TYPE /SIE/HR_IDP_INTERFACE_ID
                          VALUE(P_SUB) TYPE /SIE/HR_IDP_SUBOBJECT
                     CHANGING RC TYPE SYSUBRC.

  READ TABLE GT_AUTH_IFCID WITH KEY IFCID = P_IFCID
                                    SUBOBJECT = P_SUB.
  IF SY-SUBRC = 0.
    IF GT_AUTH_IFCID-AUTH = YES.
      RC = 0.
    ELSE.
      RC = 8.
    ENDIF.
  ELSE.
    READ TABLE GT_S1 INTO WA_S1 WITH KEY IFCID = P_IFCID.
    IF SY-SUBRC >< 0.
      GT_AUTH_IFCID-IFCID = P_IFCID.
      GT_AUTH_IFCID-AUTH = NO.
      APPEND GT_AUTH_IFCID.
    ELSE.
      PERFORM CHECK_AUTHORITY_INTERN USING P_IFCID
                                          WA_S1-AUTH_CLASS
                                          P_SUB
                                     CHANGING RC.
      CLEAR GT_AUTH_IFCID.
      GT_AUTH_IFCID-IFCID = P_IFCID.
      GT_AUTH_IFCID-SUBOBJECT = P_SUB.
      IF RC = 0.
        GT_AUTH_IFCID-AUTH = YES.
      ELSE.
        GT_AUTH_IFCID-AUTH = NO.
      ENDIF.
      APPEND GT_AUTH_IFCID.
    ENDIF.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM CHECK_AUTHORITY                                          *
*---------------------------------------------------------------------*
*       Berechtigungsprüfung                                           *
*---------------------------------------------------------------------*
*  -->  VALUE(P_IFCID) Schnittstelle                                  *
*  -->  VALUE(P_CLASS) Berechtigungsklasse                            *
*---------------------------------------------------------------------*
FORM CHECK_AUTHORITY_INTERN
                     USING VALUE(P_IFCID) TYPE /SIE/HR_IDP_INTERFACE_ID
                           VALUE(P_CLASS) TYPE /SIE/HR_IDP_AUTH_CLASS
                           VALUE(P_SUB) TYPE /SIE/HR_IDP_SUBOBJECT
                     CHANGING RC TYPE SY-SUBRC.

  DATA: L_OBJECT TYPE /SIE/HR_IDP_AUTH_CLASS.

* Datenkonvertierung vor Aufruf
  L_OBJECT = P_IFCID.

  CALL FUNCTION '/SIE/HR_IDP_AUTH_CHECK'
       EXPORTING
            ACTIVITY     = '90'                             "#EC NOTEXT
            IF_CLASS     = P_CLASS
            OBJECT       = P_IFCID
            SUBOBJECT    = P_SUB
       EXCEPTIONS
            NO_AUTHORITY = 1
            OTHERS       = 2.
  RC = SY-SUBRC.

ENDFORM.
