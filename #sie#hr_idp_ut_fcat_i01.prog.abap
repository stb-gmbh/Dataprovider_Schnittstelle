*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_UT_FCAT_I01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE SVCODE.
    WHEN 'RUN '.
      PERFORM  UPDATE_DB.
      LEAVE PROGRAM.
* table control navigation
   WHEN 'P--' OR 'P-' OR 'P+' OR 'P++'.
     PERFORM PAGING USING SVCODE.
    WHEN OTHERS.
* Do nothing.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       Exit codes.
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.
  CASE OKCODE.
    WHEN  'BACK'.
      PERFORM BACK.
    WHEN 'CANC'.
      PERFORM BREA.
    WHEN 'XEND'.
      PERFORM XEND.
    WHEN OTHERS.
*      do nothing.
  ENDCASE.

ENDMODULE.                 " EXIT  INPUT
