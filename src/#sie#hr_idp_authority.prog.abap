*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_AUTHORITY                                      *
*----------------------------------------------------------------------*
*   Änderungen: SIE001 24.09.2002 Abbruch bei ungenügender Berechtigung

FORM CHECK_AUTHORITY USING VALUE(P_TRANSACTION) LIKE SY-TCODE
                           VALUE(P_ACTIVITY) TYPE /SIE/HR_IDP_ACTIVITY
                          VALUE(P_CLASS) TYPE /SIE/HR_IDP_AUTH_CLASS
                           VALUE(P_OBJECT) TYPE /SIE/HR_IDP_INTERFACE_ID
                           VALUE(P_SUBOBJECT) TYPE C
                     CHANGING RC TYPE SY-SUBRC.

  CALL FUNCTION '/SIE/HR_IDP_AUTH_CHECK'
       EXPORTING
            TRANSACTION  = P_TRANSACTION
            ACTIVITY     = P_ACTIVITY
            IF_CLASS     = P_CLASS
            OBJECT       = P_OBJECT
            SUBOBJECT    = P_SUBOBJECT
       EXCEPTIONS
            NO_AUTHORITY = 1
            OTHERS       = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID   SY-MSGID
*           TYPE 'I'                            "SIE001
           TYPE 'E'                             "SIE001
*        sy-msgty
            NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    RC = 8.
  ELSE.
    RC = 0.
  ENDIF.

ENDFORM.
