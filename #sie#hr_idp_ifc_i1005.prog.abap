*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_I1005 .
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Module  CONVERT_DATES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CONVERT_DATES INPUT.

  IF QPPNP-TIMR1 EQ 'X'.
    PERFORM CHECK_DATE_INPUT.
    PERFORM CHECK_XABKRS.
    /SIE/HR_IDP_S1PR-TIMED = 'D'.
  ELSE.
    IF QPPNP-TIMR2 EQ 'X'.
      PERFORM CHECK_DATE_INPUT.
      PERFORM CHECK_XABKRS.
      /SIE/HR_IDP_S1PR-TIMED = 'M'.
    ELSE.
      IF QPPNP-TIMR3 EQ 'X'.
        PERFORM CHECK_DATE_INPUT.
        PERFORM CHECK_XABKRS.
        /SIE/HR_IDP_S1PR-TIMED = 'Y'.
      ELSE.
        IF QPPNP-TIMR4 EQ 'X'.
          PERFORM CHECK_DATE_INPUT.
          PERFORM CHECK_XABKRS.
          /SIE/HR_IDP_S1PR-TIMED = 'P'.
        ELSE.
          IF QPPNP-TIMR5 EQ 'X'.
            PERFORM CHECK_DATE_INPUT.
            PERFORM CHECK_XABKRS.
            /SIE/HR_IDP_S1PR-TIMED = 'F'.
          ELSE.
            IF QPPNP-TIMR6 EQ 'X'.
              PERFORM CHECK_XABKRS.
              /SIE/HR_IDP_S1PR-TIMED = 'Z'.
            ELSE.
              IF QPPNP-TIMR7 EQ 'X'.
                PERFORM CHECK_DATE_INPUT.
                /SIE/HR_IDP_S1PR-TIMED = 'A'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " CONVERT_DATES  INPUT

*---------------------------------------------------------------------*
*       FORM CHECK_DATE_INPUT                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM CHECK_DATE_INPUT.

  IF NOT ( /SIE/HR_IDP_S1PR-BEGDT IS INITIAL )
  OR NOT ( /SIE/HR_IDP_S1PR-BEGDO IS INITIAL )
  OR NOT ( /SIE/HR_IDP_S1PR-BEGPT IS INITIAL )
  OR NOT ( /SIE/HR_IDP_S1PR-BEGPO IS INITIAL )
  OR NOT ( /SIE/HR_IDP_S1PR-ENDPO IS INITIAL )
  OR NOT ( /SIE/HR_IDP_S1PR-ENDPT IS INITIAL )
  OR NOT ( /SIE/HR_IDP_S1PR-ENDDT IS INITIAL )
  OR NOT ( /SIE/HR_IDP_S1PR-ENDDO IS INITIAL ).
    MESSAGE E016(PN) WITH 'bitte keine Tage/Monate eingeben'(127).
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM CHECK_XABKRS                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM CHECK_XABKRS.

  IF NOT ( /SIE/HR_IDP_S1PR-XABKR IS INITIAL ).
    MESSAGE E016(PN) WITH 'bitte kein Abrechnungskreis eingeben'(129).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  FILL_1005  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FILL_1005 INPUT.

  MOVE-CORRESPONDING /SIE/HR_IDP_S1PR TO G_IFDATA_TRAN-S1PR.

ENDMODULE.                 " FILL_1005  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_DATES_1005  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_DATES_1005_DATA INPUT.
  PERFORM CHECK_DATES_1005_DATA.
ENDMODULE.                 " CHECK_DATES_1005_DATA  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_DATES_1005  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_DATES_1005_PERSON INPUT.
  PERFORM CHECK_DATES_1005_PERSON.
ENDMODULE.                 " CHECK_DATES_1005_DATA  INPUT
