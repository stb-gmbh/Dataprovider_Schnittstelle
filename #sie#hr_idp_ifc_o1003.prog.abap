*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_O1003 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  FILL_DEFAULTS_1003  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FILL_DEFAULTS_1003 OUTPUT.
  IF /SIE/HR_IDP_S1DF IS INITIAL.
    /SIE/HR_IDP_S1DF-GNRTD = 'X'.
    /SIE/HR_IDP_S1DF-GNRVT = 'X'.
  ENDIF.
ENDMODULE.                 " FILL_DEFAULTS_1003  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_CRYPT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CRYPT OUTPUT.

  /SIE/HR_IDP_S1DF-ENCRY = YES.
  IF /SIE/HR_IDP_S1DF-FILEN IS INITIAL.
    /SIE/HR_IDP_S1DF-FILEN = '/SIE/HR_IDP'.  "#EC NOTEXT
  ENDIF.

  LOOP AT SCREEN.
    IF SCREEN-NAME = '/SIE/HR_IDP_S1DF-ENCRY'.
      SCREEN-INPUT = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " SET_CRYPT  OUTPUT
