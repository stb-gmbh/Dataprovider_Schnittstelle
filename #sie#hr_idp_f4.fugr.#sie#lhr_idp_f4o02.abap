*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_F4O02 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  PBO_1010  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_1010 OUTPUT.

  IF TREE_CONTROL_CREATED IS INITIAL.
    PERFORM CREATE_AND_INIT_TREE_1010.
    PERFORM ASSIGN_CALLBACKS.
    TREE_CONTROL_CREATED = 'X'.
  ENDIF.

ENDMODULE.                 " PBO_1010  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_1110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1110 OUTPUT.
  SET PF-STATUS 'SUCHHILFEWAHL'.
  SET TITLEBAR 'SUCHHILFEWAHL'.
ENDMODULE.                 " STATUS_1110  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*MODULE SET_STATUS OUTPUT.
*  IF G_DISPLAY = YES.
*    WA_COMMAND = 'ERTN'.                                    "#EC NOTEXT
*    APPEND WA_COMMAND TO G_COMMAND.
*  ELSE.
** Do nothing.
*  ENDIF.
*
*  SET PF-STATUS 'MAIN' EXCLUDING G_COMMAND.
*  SET TITLEBAR 'MAIN'.
*ENDMODULE.                 " SET_STATUS  OUTPUT
