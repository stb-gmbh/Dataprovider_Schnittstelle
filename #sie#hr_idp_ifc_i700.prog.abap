*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_I700 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0500 INPUT.

ENDMODULE.                 " USER_COMMAND_0500  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_0700  INPUT
*&---------------------------------------------------------------------*
*       Prüft ob für Headersatzarten die Infotypen gefüllt sind
*----------------------------------------------------------------------*
MODULE CHECK_0700 INPUT.

  CASE /SIE/HR_IDP_S1SA-RECTY.
    WHEN 1 OR 3 OR 5.
      IF NOT ( /SIE/HR_IDP_S1SA-INFTY IS INITIAL ) OR
         NOT ( /SIE/HR_IDP_S1SA-SUBTY IS INITIAL ).
        MESSAGE E145.
      ENDIF.
    WHEN 4.
      IF ( /SIE/HR_IDP_S1SA-INFTY IS INITIAL ).
        MESSAGE E146.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " CHECK_0700  INPUT
