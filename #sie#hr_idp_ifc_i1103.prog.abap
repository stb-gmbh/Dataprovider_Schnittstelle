*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_I1103 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  VALIDATE_DAY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_DAY INPUT.
  IF L_DAY = YES.
    IF /SIE/HR_IDP_S1DF-UC4DY IS INITIAL.
      MESSAGE E150.
    ENDIF.
  ENDIF.

  IF L_OWNDF = YES.
    IF ( /SIE/HR_IDP_S1DF-UC4PR IS INITIAL )
       OR ( /SIE/HR_IDP_S1DF-UC4NR IS INITIAL ).
      MESSAGE E151.
    ENDIF.
  ENDIF.

ENDMODULE.                 " VALIDATE_DAY  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_NO_PERIOD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_NO_PERIOD INPUT.

  IF /SIE/HR_IDP_S1DF-UC4PR = '10'.
    IF NOT ( /SIE/HR_IDP_S1DF-UC4NR IS INITIAL ).
      MESSAGE E154.
    ENDIF.
  ENDIF.

ENDMODULE.                 " CHECK_NO_PERIOD  INPUT
