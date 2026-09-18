*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_O20 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_2000 OUTPUT.

* set titlebar 'IFC_RELE'.

ENDMODULE.                 " STATUS_2000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_3000  OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_3000 OUTPUT.

*  set titlebar c_accp_must.

  G_STATUS_TRAN = C_3000_STAT.

ENDMODULE.                 " STATUS_2000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_2000 OUTPUT.

  RC = 0.
  PERFORM CHECK_AUTHORITY USING SY-TCODE
                             C_RELEASE
                             G_IFDATA_TRAN-S1-AUTH_CLASS
                             G_IFDATA_TRAN-S1-IFCID
                             SPACE
                    CHANGING RC.

  CLEAR: OKCODE, SVCODE.

  IF ( /SIE/HR_IDP_S1-IFCID IS INITIAL ).
    GET PARAMETER ID '/SIE/HR_IDP_IFCID' FIELD /SIE/HR_IDP_S1-IFCID.
  ENDIF.

  G_STATUS_TRAN = C_2000_STAT.
  IF G_IFDATA_OLDV NE /SIE/HR_IDP_S1-IFCID.

* alles nochmal einlesen.
    CLEAR G_PROC_VEC.
    CLEAR G_IFDATA_TRAN.

    G_IFDATA_OLDV = /SIE/HR_IDP_S1-IFCID.
    CLEAR /SIE/HR_IDP_S1T.
    G_IFDATA_TRAN-S1-IFCID = /SIE/HR_IDP_S1-IFCID.

  ENDIF.

  /SIE/HR_IDP_HEAD-IFCID = /SIE/HR_IDP_S1-IFCID.

ENDMODULE.                 " INIT_2000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  READ_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_2000 OUTPUT.

  CALL FUNCTION '/SIE/HR_IDP_IFC_CURR_VERSION'
       EXPORTING
            INTERFACE         = /SIE/HR_IDP_S1-IFCID
*            active            = yes
             ACTIVE           = NO
       IMPORTING
            VERSION           = /SIE/HR_IDP_S1-ACT_VERS_NR
       EXCEPTIONS
            NO_ACTIVE_VERSION = 1
            OTHERS            = 2.
  IF SY-SUBRC <> 0.
    CLEAR /SIE/HR_IDP_S1-ACT_VERS_NR.
  ENDIF.

  IF NOT ( /SIE/HR_IDP_S1-IFCID IS INITIAL ).

    SELECT SINGLE * FROM /SIE/HR_IDP_S1T
             WHERE IFCID = /SIE/HR_IDP_S1-IFCID
             AND   SPRAS = SY-LANGU.
  ENDIF.

  G_IFDATA_VERS = /SIE/HR_IDP_S1-ACT_VERS_NR.

  IF G_IFDATA_VERS = 0.
    LOOP AT SCREEN.
      IF SCREEN-NAME = '/SIE/HR_IDP_S1-ACT_VERS_NR'.
        SCREEN-INVISIBLE = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " READ_2000  OUTPUT

MODULE READ_3000 OUTPUT.

  CALL FUNCTION '/SIE/HR_IDP_IFC_CURR_VERSION'
       EXPORTING
            INTERFACE         = /SIE/HR_IDP_S1-IFCID
            ACTIVE            = YES
*             active           = no
       IMPORTING
            VERSION           = /SIE/HR_IDP_S1-ACT_VERS_NR
       EXCEPTIONS
            NO_ACTIVE_VERSION = 1
            OTHERS            = 2.
  IF SY-SUBRC <> 0.
    CLEAR /SIE/HR_IDP_S1-ACT_VERS_NR.
  ENDIF.

  IF NOT ( /SIE/HR_IDP_S1-IFCID IS INITIAL ).

    SELECT SINGLE * FROM /SIE/HR_IDP_S1T
             WHERE IFCID = /SIE/HR_IDP_S1-IFCID
             AND   SPRAS = SY-LANGU.
  ENDIF.

  G_IFDATA_VERS = /SIE/HR_IDP_S1-ACT_VERS_NR.

  IF G_IFDATA_VERS = 0.
    LOOP AT SCREEN.
      IF SCREEN-NAME = '/SIE/HR_IDP_S1-ACT_VERS_NR'.
        SCREEN-INVISIBLE = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " READ_2000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  ENQUEUE  INPUT
*&---------------------------------------------------------------------*
MODULE ENQUEUE INPUT.

  IF SY-TCODE >< C_DISP_TCOD.
    IF ( SY-DYNNR = '1000' )
    OR ( SY-DYNNR = '2000' )
    OR ( SY-DYNNR = '4000' )
    OR ( SY-DYNNR = '2500' ).
      PERFORM ENQUEUE.
    ENDIF.
  ENDIF.
ENDMODULE.                 " ENQUEUE  INPUT

*&---------------------------------------------------------------------*
*&      Module  SET_RADIOB2  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_RADIOB2 OUTPUT.
  CLEAR: L_DELIM, L_FIXFM.

* Default: l_fixfm.
  IF ( G_IFDATA_TRAN-S1DL-FIXFM IS INITIAL ).
* <XFT20020204 BUG FIXFORMAT>
*   l_fixfm = yes.
    G_IFDATA_TRAN-S1DL-FIXFM = 1.
* <XFT20020204 BUG FIXFORMAT>
  ENDIF.

  /SIE/HR_IDP_S1DL-MANDT = SY-MANDT.
  /SIE/HR_IDP_S1DL-IFCID = G_IFDATA_TRAN-S1-IFCID.
  /SIE/HR_IDP_S1DL-VRSNR = G_IFDATA_VERS.
  /SIE/HR_IDP_S1DL-DELIM = G_IFDATA_TRAN-S1DL-DELIM.

  CASE G_IFDATA_TRAN-S1DL-FIXFM.
    WHEN 1.
      L_FIXFM = YES.
    WHEN 2.
      L_DELIM = YES.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " SET_RADIOB2  OUTPUT
