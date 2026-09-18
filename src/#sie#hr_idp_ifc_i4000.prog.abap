*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_I4000 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_4000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_4000 INPUT.
  PERFORM HANDLE_OKCODES_4000.
ENDMODULE.                 " USER_COMMAND_4000  INPUT

*&---------------------------------------------------------------------*
*&      Module  HANDLE_OKCODES_4001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HANDLE_OKCODES_4001 INPUT.

  CASE SVCODE.
    WHEN 'SAVE'.
      PERFORM ADD_NOTE.
      PERFORM IFC_SAVE.
      CASE SY-TCODE.
*        when c_rmod_tcod.
*          leave program.
        WHEN OTHERS.
          SET SCREEN 0. LEAVE SCREEN.
      ENDCASE.
    WHEN OTHERS.
  ENDCASE.
  PERFORM HANDLE_MAIN_OK_CODES.

ENDMODULE.                 " HANDLE_OKCODES_4001  INPUT
*&---------------------------------------------------------------------*
*&      Module  WRITE_4000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE WRITE_4000 INPUT.

  /SIE/HR_IDP_HEAD-IFCID = /SIE/HR_IDP_S1-IFCID.

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
    MESSAGE E110 WITH /SIE/HR_IDP_S1-IFCID.
  ELSE.
    G_IFDATA_VERS = /SIE/HR_IDP_S1-ACT_VERS_NR.
  ENDIF.

ENDMODULE.                 " WRITE_4000  INPUT
*&---------------------------------------------------------------------*
*&      Module  WRITE_4001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE WRITE_4001 INPUT.
  MOVE-CORRESPONDING /SIE/HR_IDP_S1DF TO G_IFDATA_TRAN-S1DF.
ENDMODULE.                 " WRITE_4001  INPUT
