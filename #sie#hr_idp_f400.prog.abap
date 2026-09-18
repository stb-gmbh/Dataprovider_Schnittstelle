*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_F400 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHECK_USERN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_USERN.

  IF /SIE/HR_IDP_IFC_ROLES-USERN IS INITIAL.
  ELSE.

    SELECT SINGLE * FROM  USER_ADDR
             WHERE  BNAME  = /SIE/HR_IDP_IFC_ROLES-USERN.
    IF SY-SUBRC NE 0.
      MESSAGE E314 WITH /SIE/HR_IDP_IFC_ROLES-USERN.
*   Der Benutzer &1 existiert nicht.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_USERN
