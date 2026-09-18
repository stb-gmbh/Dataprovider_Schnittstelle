*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_ERR                                            *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*       Form  APPEND_ERROR
*----------------------------------------------------------------------*
FORM APPEND_ERROR USING P_MSGTY        LIKE SY-MSGTY
                        P_ERROR_NUMBER LIKE SY-MSGNO
                        P_MSGV1
                        P_MSGV2
                        P_MSGV3
                        P_MSGV4.

  CALL FUNCTION 'HR_APPEND_ERROR_LIST'
       EXPORTING
            ARBGB  = '/SIE/HR_IDP_MESSAGES'
            MSGTY  = P_MSGTY
            MSGNO  = P_ERROR_NUMBER
            MSGV1  = P_MSGV1
            MSGV2  = P_MSGV2
            MSGV3  = P_MSGV3
            MSGV4  = P_MSGV4
       EXCEPTIONS
            OTHERS = 1.

  CHECK SY-SUBRC NE 0.
  WRITE: / 'Fehler beim anlegen eines Fehlers'.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM print_error_list                                         *
*---------------------------------------------------------------------*
FORM print_ERROR_LIST.

  CALL FUNCTION 'HR_DISPLAY_ERROR_LIST'.

  CHECK SY-SUBRC NE 0.

  WRITE:/ 'Fehler beim anzeigen der Fehlermeldungen'.

ENDFORM.
