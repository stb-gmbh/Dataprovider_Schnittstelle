*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_F4O01 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  PBO_1000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_1000 OUTPUT.

  IF TREE_CONTROL_CREATED IS INITIAL.
    PERFORM CREATE_AND_INIT_TREE.
    PERFORM ASSIGN_CALLBACKS.
    TREE_CONTROL_CREATED = 'X'.
  ENDIF.

ENDMODULE.                 " PBO_1000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_1100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1100 OUTPUT.
  SET PF-STATUS 'SUCHHILFEWAHL'.
  SET TITLEBAR 'SUCHHILFEWAHL'.
ENDMODULE.                 " STATUS_1100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_STATUS OUTPUT.

  CLEAR G_COMMAND[].

  IF G_GRTYPE = 1.
    WA_COMMAND = 'DOCU'.                                    "#EC NOTEXT
    APPEND WA_COMMAND TO G_COMMAND.
  ENDIF.

  IF G_DISPLAY = YES OR SY-TCODE = 'SM30'.
    WA_COMMAND = 'ERTN'.                                    "#EC NOTEXT
    APPEND WA_COMMAND TO G_COMMAND.
  ENDIF.

  SET PF-STATUS 'MAIN' EXCLUDING G_COMMAND.
  SET TITLEBAR 'MAIN'.
ENDMODULE.                 " SET_STATUS  OUTPUT
