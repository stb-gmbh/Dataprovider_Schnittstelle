*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_SE54_ADMI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1000 INPUT.

  CASE SY-UCOMM.
    WHEN 'OK'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'CANC'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'EXIT'.
      SET SCREEN 0. LEAVE SCREEN.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1000  INPUT
