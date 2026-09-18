*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_I800 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0800  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0800 INPUT.

  CASE SVCODE.
    WHEN 'OK'.
      FL_ACCPT = YES.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'BREA'.
      FL_ACCPT = NO.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0800  INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0800  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND_0800 INPUT.
  SET SCREEN 0. LEAVE SCREEN.
ENDMODULE.                 " EXIT_COMMAND_0800  INPUT
