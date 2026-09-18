*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_FREIGABEO01 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_1000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1000 OUTPUT.
  SET TITLEBAR 'REL'.
  IF G_SW_TEST = YES.
    SET PF-STATUS 'RELEASE' EXCLUDING 'SAVE'.
  ELSE.
    SET PF-STATUS 'RELEASE' EXCLUDING 'TEST'.
  ENDIF.
ENDMODULE.                 " STATUS_1000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PLAUSI_CHECK_LIST  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PLAUSI_CHECK_LIST OUTPUT.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM PLAUSI_CHECK_LIST.
  LEAVE SCREEN.
ENDMODULE.                 " PLAUSI_CHECK_LIST  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0800  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0800 OUTPUT.
  SET PF-STATUS 'IFC_POPUP'.
  SET TITLEBAR 'IFC_ACCP'.
  CLEAR /SIE/HR_IDP_S1F-LTEXT.
ENDMODULE.                 " STATUS_0800  OUTPUT
