*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_I1203 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  VALIDATE_IP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_ip INPUT.
  PERFORM validate_ip USING /sie/hr_idp_s1df-tcpip.
ENDMODULE.                 " VALIDATE_IP  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALIDATE_TRFAD  INPUT
*&---------------------------------------------------------------------*
*       Validate Transferadmission. There are no umlauts allowed
*----------------------------------------------------------------------*
MODULE validate_trfad INPUT.

  IF /sie/hr_idp_s1df-trfad CA 'äÄöÖüÜ?'.
    MESSAGE e149.
  ENDIF.

ENDMODULE.                 " VALIDATE_TRFAD  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_ITYPE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_itype INPUT.

  PERFORM validate_itype USING /sie/hr_idp_s1df-itype.

ENDMODULE.                 " CHECK_ITYPE  INPUT
