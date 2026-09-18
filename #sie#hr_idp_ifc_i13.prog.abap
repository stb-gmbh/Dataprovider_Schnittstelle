*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_I13                                        *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  DISPLAY_SELECTION_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_SELECTION_DATA OUTPUT.
ENDMODULE.                 " DISPLAY_SELECTION_DATA  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_UC4_RADIO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_UC4_RADIO INPUT.
  CLEAR L_ERROR.
  IF L_DAY IS INITIAL AND NOT /SIE/HR_IDP_S1DF-UC4DY IS INITIAL.
    L_ERROR = 'X'.
    S1DF-ACTIVETAB = OLD_ACTIVETAB.
    MESSAGE E010.
  ENDIF.
  IF L_OWNDF IS INITIAL AND NOT /SIE/HR_IDP_S1DF-UC4PR IS INITIAL.
    L_ERROR = 'X'.
    S1DF-ACTIVETAB = OLD_ACTIVETAB.
    MESSAGE E011.
  ENDIF.

  IF NOT L_DAY IS INITIAL AND /SIE/HR_IDP_S1DF-UC4DY IS INITIAL.
    L_ERROR = 'X'.
    S1DF-ACTIVETAB = OLD_ACTIVETAB.
    MESSAGE E014.
  ENDIF.
  IF NOT L_OWNDF IS INITIAL AND ( /SIE/HR_IDP_S1DF-UC4PR IS INITIAL
                            OR    /SIE/HR_IDP_S1DF-UC4NR IS INITIAL ).
    CHECK /SIE/HR_IDP_S1DF-UC4PR >< '10'.
    L_ERROR = 'X'.
    S1DF-ACTIVETAB = OLD_ACTIVETAB.
    MESSAGE E015.
  ENDIF.

*  LOOP AT SCREEN.
*    IF SY-TCODE = C_MODI_TCOD
*        OR G_IFVERS_TYPE = C_INEW_VERS.
** Umschalten zwischen Anzeigen und Ändern
*      IF SCREEN-GROUP2 = 'DAY'.
*        IF L_DAY IS INITIAL.
*          SCREEN-INPUT = '0'.
*        ELSE.
*          SCREEN-INPUT = '1'.
*        ENDIF.
*        MODIFY SCREEN.
*      ENDIF.
*
*      IF SCREEN-GROUP2 = 'PER'.
*        IF L_OWNDF IS INITIAL.
*          SCREEN-INPUT = '0'.
*        ELSE.
*          SCREEN-INPUT = '1'.
*        ENDIF.
*        MODIFY SCREEN.
*      ENDIF.
*
*    ELSE.
**     do nothing
*    ENDIF.
*
*  ENDLOOP.

ENDMODULE.                 " CHECK_UC4_RADIO  INPUT
*&---------------------------------------------------------------------*
*&      Module  WRITE_1003  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE WRITE_1003 INPUT.
  MOVE-CORRESPONDING /SIE/HR_IDP_S1DF TO G_IFDATA_TRAN-S1DF.
  MOVE G_IFDATA_VERS TO G_IFDATA_TRAN-S1DF-VRSNR.
  MOVE G_IFDATA_TRAN-S1-IFCID TO G_IFDATA_TRAN-S1DF-IFCID.
ENDMODULE.                 " WRITE_1003  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SUB_1003  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_SUB_1003 INPUT.
  IF L_ERROR = 'X'.
    CLEAR SVCODE.
*    CLEAR: l_error, dynpronr.
    EXIT.
  ENDIF.
  OLD_ACTIVETAB = S1DF-ACTIVETAB.
  CASE SVCODE.
    WHEN 'UC4'.
      DYNPRONR = '1103'.
      S1DF-ACTIVETAB = SVCODE.
      CLEAR SVCODE.
    WHEN 'TRANS'.
      DYNPRONR = '1203'.
      S1DF-ACTIVETAB = SVCODE.
      CLEAR SVCODE.
*    when 'FRMT'.
*      dynpronr = '1303'.
*      s1df-activetab = svcode.
*      clear svcode.
    WHEN 'MAIL'.
      DYNPRONR = '1403'.
      S1DF-ACTIVETAB = SVCODE.
      CLEAR SVCODE.
  ENDCASE.

ENDMODULE.                 " SET_SUB_1003  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_FORMAT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_FORMAT INPUT.

  IF L_FIXFM = YES.
    G_IFDATA_TRAN-S1DL-FIXFM = 1.
  ELSE.
    G_IFDATA_TRAN-S1DL-FIXFM = 2.
  ENDIF.

  IF L_DELIM IS INITIAL AND NOT ( /SIE/HR_IDP_S1DL-DELIM IS INITIAL ).
    MESSAGE E012.
  ELSE.
    G_IFDATA_TRAN-S1DL-DELIM = /SIE/HR_IDP_S1DL-DELIM.
  ENDIF.

  IF L_DELIM = YES AND ( /SIE/HR_IDP_S1DL-DELIM IS INITIAL ).
    MESSAGE E013.
  ENDIF.


ENDMODULE.                 " CHECK_FORMAT  INPUT

MODULE WRITE_DELIM INPUT.
* Falls das Subobjekt UC4 (Allg. Parameter noch nicht besucht worden
* ist, dann sollten wir hier noch die Schlüssel noch definieren.
  IF G_IFDATA_TRAN-S1DL-IFCID IS INITIAL.
    G_IFDATA_TRAN-S1DL-IFCID = G_IFDATA_TRAN-S1-IFCID.
    G_IFDATA_TRAN-S1DL-VRSNR = G_IFDATA_VERS.
  ENDIF.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  CHECK_DATES_1103  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_DATES_1103 INPUT.
  PERFORM CHECK_DATES_1103.
ENDMODULE.                 " CHECK_DATES_1103  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_PROGR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_PROGR INPUT.

  IF NOT ( /SIE/HR_IDP_S1DF-GNRTD IS INITIAL ).
    IF NOT ( /SIE/HR_IDP_S1DF-PROGR IS INITIAL ) OR
       NOT ( /SIE/HR_IDP_S1DF-VARIA IS INITIAL ).
      MESSAGE E123.
    ENDIF.
  ENDIF.

  IF ( /SIE/HR_IDP_S1DF-GNRTD IS INITIAL ).
    IF ( /SIE/HR_IDP_S1DF-PROGR IS INITIAL ) OR
       ( /SIE/HR_IDP_S1DF-VARIA IS INITIAL ).
      MESSAGE E123.
    ENDIF.
  ENDIF.
ENDMODULE.                 " CHECK_PROGR  INPUT
