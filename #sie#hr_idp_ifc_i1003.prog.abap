*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_I1003                                      *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  CHECK_UC4NM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_UC4NM INPUT.
ENDMODULE.                 " CHECK_UC4NM  INPUT

*&---------------------------------------------------------------------*
*&      Module  MODIFY_CHECKBOXES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_CHECKBOXES OUTPUT.

  LOOP AT SCREEN.
    CASE SCREEN-NAME.
      WHEN '/SIE/HR_IDP_S1DF-PROGR'.
        IF NOT ( /SIE/HR_IDP_S1DF-GNRTD IS INITIAL ).
*         screen-active = '0'.
          SCREEN-INPUT = '0'.
          MODIFY SCREEN.
        ENDIF.
      WHEN '/SIE/HR_IDP_S1DF-VARIA'.
        IF NOT ( /SIE/HR_IDP_S1DF-GNRVT IS INITIAL ).
*         screen-active = '0'.
          SCREEN-INPUT = '0'.
          MODIFY SCREEN.
        ENDIF.
      WHEN OTHERS.
* do nothing.
    ENDCASE.
  ENDLOOP.

ENDMODULE.                 " MODIFY_CHECKBOXES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_PROGRAM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_PROGRAM INPUT.

  IF ( /SIE/HR_IDP_S1DF-GNRTD IS INITIAL ).
* check existance of program
    SELECT SINGLE * FROM  TADIR
           WHERE  PGMID     = 'R3TR'
           AND    OBJECT    = 'PROG'
           AND    OBJ_NAME  = /SIE/HR_IDP_S1DF-PROGR.
    IF SY-SUBRC NE 0.
      MESSAGE E136.
    ENDIF.

  ENDIF.

  IF ( /SIE/HR_IDP_S1DF-GNRVT IS INITIAL ).
* check existance of variant
    SELECT SINGLE * FROM VARIT WHERE
                             LANGU      = SY-LANGU               AND
                             REPORT     = /SIE/HR_IDP_S1DF-PROGR AND
                             VARIANT    = /SIE/HR_IDP_S1DF-VARIA.
    IF SY-SUBRC NE 0.
      MESSAGE E137.
    ENDIF.
  ENDIF.
ENDMODULE.                 " CHECK_PROGRAM  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_BNAME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_BNAME INPUT.
  CHECK NOT ( /SIE/HR_IDP_S1DF-UC4NM IS INITIAL ).
  SELECT SINGLE * FROM  USER_ADDR
           WHERE  BNAME  = /SIE/HR_IDP_S1DF-UC4NM.
  IF SY-SUBRC >< 0.
    MESSAGE E314 WITH /SIE/HR_IDP_S1DF-UC4NM.
  ENDIF.

ENDMODULE.                 " CHECK_BNAME  INPUT
