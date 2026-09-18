*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_F1203 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  VALIDATE_IP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_/SIE/HR_IDP_S1DF_TCPIP  text
*----------------------------------------------------------------------*
FORM VALIDATE_IP USING P_IP LIKE /SIE/HR_IDP_S1DF-TCPIP.

  DATA: I1(3) TYPE N
      , I2(3) TYPE N
      , I3(3) TYPE N
      , I4(3) TYPE N
      , P_IP_OUT(16)
      .

  CALL FUNCTION 'CONVERSION_EXIT_TCPIP_OUTPUT'
       EXPORTING
            INPUT  = P_IP
       IMPORTING
            OUTPUT = P_IP_OUT.

  SPLIT P_IP_OUT AT '.' INTO I1 I2 I3 I4.

  IF  ( I1 > 255 ).
    MESSAGE E135.
  ELSE.
    IF ( I2 > 255 ).
      MESSAGE E135.
    ELSE.
      IF ( I3 > 255 ).
        MESSAGE E135.
      ELSE.
        IF ( I4 > 255 ).
          MESSAGE E135.
        ELSE.
* do nothing, test successfull
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " VALIDATE_IP

*&---------------------------------------------------------------------*
*&      Form  VALIDATE_ITYPE
*&---------------------------------------------------------------------*
*       Prüft ob der Schnittstellentyp korrekt ist
*----------------------------------------------------------------------*
*      -->P_ITYPE  Typ
*----------------------------------------------------------------------*
FORM VALIDATE_ITYPE USING P_ITYPE LIKE /SIE/HR_IDP_S1DF-ITYPE.

  DATA: VALID(67) TYPE C VALUE
  ' ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-'
  , L_LENGTH TYPE I
  .

* Gültigkeit der Buchstaben
  IF P_ITYPE CN VALID.
    MESSAGE E152.
  ENDIF.

* Spaces nur am Ende zulassen
  IF P_ITYPE CA SPACE.
    L_LENGTH = STRLEN( P_ITYPE ).
    IF SY-FDPOS < L_LENGTH.
      MESSAGE E153.
    ENDIF.
  ENDIF.

ENDFORM.                    " VALIDATE_ITYPE
