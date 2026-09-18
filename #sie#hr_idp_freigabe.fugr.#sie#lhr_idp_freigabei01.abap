*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_FREIGABEI01 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0800  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND_0800 INPUT.
  SET SCREEN 0. LEAVE SCREEN.
ENDMODULE.                 " EXIT_COMMAND_0800  INPUT

*&---------------------------------------------------------------------*
*&      Module  COPY_OK_CODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE COPY_OK_CODE INPUT.
 SVCODE = OKCODE.
 CLEAR OKCODE.
ENDMODULE.                 " COPY_OK_CODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0800  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0800 INPUT.

 CASE SVCODE.
   WHEN 'OK'.
     FL_ACCEPT = YES.
     SET SCREEN 0. LEAVE SCREEN.
   WHEN 'BREA'.
     FL_ACCEPT = NO.
     SET SCREEN 0. LEAVE SCREEN.
   WHEN OTHERS.
 ENDCASE.

ENDMODULE.                 " USER_COMMAND_0800  INPUT
