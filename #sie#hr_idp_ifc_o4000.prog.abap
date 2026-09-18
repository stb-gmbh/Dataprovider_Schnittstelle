*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_O4000 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  INIT_4000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_4000 OUTPUT.

  PERFORM CHECK_AUTHORITY USING SY-TCODE
                             C_UTILITY
                             G_IFDATA_TRAN-S1-AUTH_CLASS
                             G_IFDATA_TRAN-S1-IFCID
                             'RCHA'
                        CHANGING RC.

  CLEAR: OKCODE, SVCODE.
  G_STATUS_TRAN = C_4000_STAT.

  IF ( /SIE/HR_IDP_S1-IFCID IS INITIAL ).
    GET PARAMETER ID '/SIE/HR_IDP_IFCID' FIELD /SIE/HR_IDP_S1-IFCID.
  ENDIF.

  IF G_IFDATA_OLDV NE /SIE/HR_IDP_S1-IFCID.
    PERFORM DEQUEUE.
  ENDIF.

* alles nochmal einlesen.
  CLEAR G_PROC_VEC.
  CLEAR G_IFDATA_TRAN.

  G_IFDATA_OLDV = /SIE/HR_IDP_S1-IFCID.
  CLEAR /SIE/HR_IDP_S1T.
  G_IFDATA_TRAN-S1-IFCID = /SIE/HR_IDP_S1-IFCID.
  /SIE/HR_IDP_HEAD-IFCID = /SIE/HR_IDP_S1-IFCID.
*  endif.

ENDMODULE.                 " INIT_4000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_STATUS_4000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_STATUS_4000 OUTPUT.
*  set pf-status 'IFC_CHANGE_RELE' excluding 'SAVE'.
*  set titlebar 'IFC_CHANGE_RELE'.
ENDMODULE.                 " SET_STATUS_4000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_4000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_SCREEN_4000 OUTPUT.

ENDMODULE.                 " MODIFY_SCREEN_4000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_4001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_4001 OUTPUT.
  CLEAR: OKCODE, SVCODE.
  G_STATUS_TRAN = C_4001_STAT.
ENDMODULE.                 " INIT_4001  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_STATUS_4001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_STATUS_4001 OUTPUT.
*  set pf-status 'IFC_CHANGE_RELE'.
*  set titlebar 'IFC_CHANGE_RELE'.
ENDMODULE.                 " SET_STATUS_4001  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  READ_4000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_4000 OUTPUT.

  CALL FUNCTION '/SIE/HR_IDP_IFC_CURR_VERSION'
       EXPORTING
            INTERFACE         = /SIE/HR_IDP_S1-IFCID
            ACTIVE            = YES
       IMPORTING
            VERSION           = /SIE/HR_IDP_S1-ACT_VERS_NR
       EXCEPTIONS
            NO_ACTIVE_VERSION = 1
            OTHERS            = 2.
  IF SY-SUBRC >< 0.
    CLEAR /SIE/HR_IDP_S1-ACT_VERS_NR.
    CLEAR G_IFDATA_VERS.
    MESSAGE S110 WITH /SIE/HR_IDP_S1-IFCID.
  ELSE.
    G_IFDATA_VERS = /SIE/HR_IDP_S1-ACT_VERS_NR.
    IF NOT ( /SIE/HR_IDP_S1-IFCID IS INITIAL ).

      SELECT SINGLE * FROM /SIE/HR_IDP_S1T
               WHERE IFCID = /SIE/HR_IDP_S1-IFCID
               AND   SPRAS = SY-LANGU.
    ENDIF.
  ENDIF.

ENDMODULE.                 " READ_4000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_4001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_4001 OUTPUT.
  MOVE-CORRESPONDING G_IFDATA_TRAN-S1DF TO /SIE/HR_IDP_S1DF.
ENDMODULE.                 " READ_4001  OUTPUT
