*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_F1001 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  READ_AUTH  OUTPUT
*&---------------------------------------------------------------------*
*       Liest den Berechtigungsklassentext
*----------------------------------------------------------------------*
MODULE READ_AUTH OUTPUT.

  CLEAR /SIE/HR_IDP_S0T-IDENT.

  IF NOT ( /SIE/HR_IDP_S1-AUTH_CLASS IS INITIAL ).
    SELECT SINGLE * FROM /SIE/HR_IDP_S0T
                    WHERE AUTH_CLASS = /SIE/HR_IDP_S1-AUTH_CLASS
                    AND   SPRAS = SY-LANGU.
    IF SY-SUBRC = 0.
* Do nothing, text is allready present in the structure
    ELSE.
* Do nothing, field is allready initialised
    ENDIF.
  ENDIF.

ENDMODULE.                 " READ_AUTH  OUTPUT
