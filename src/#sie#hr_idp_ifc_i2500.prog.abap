*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_I2500 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_2500  INPUT
*&---------------------------------------------------------------------*
*       User-Exit Command im Dyanpro 2500
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND_2500 INPUT.

  PERFORM DEQUEUE.
  SET SCREEN 0. LEAVE SCREEN.

ENDMODULE.                 " EXIT_COMMAND_2500  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2500  INPUT
*&---------------------------------------------------------------------*
*       User Command im Dynpro 2500
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2500 INPUT.

  CHECK NOT ( /SIE/HR_IDP_S1-IFCID IS INITIAL ).
  CASE SVCODE.
    WHEN C_ADHOC_CODE.
      PERFORM ADHOC_EXECUTION.
    WHEN OTHERS.
  ENDCASE.

 PERFORM HANDLE_DOCUMENTATION.

ENDMODULE.                 " USER_COMMAND_2500  INPUT
