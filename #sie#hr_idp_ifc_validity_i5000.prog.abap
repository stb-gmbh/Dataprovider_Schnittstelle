*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_MONITOR_GD_I5000                               *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.
  CASE OKCODE.
    WHEN  'RTRN'.                                           "#EC NOTEXT
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'END'.                                             "#EC NOTEXT
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'BREA'.                                            "#EC NOTEXT
      SET SCREEN 0. LEAVE SCREEN.
    WHEN OTHERS.
*     do nothing.
  ENDCASE.
ENDMODULE.

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
*&      Module  USER_COMMAND_5000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_5000 INPUT.
  CASE SVCODE.
    WHEN 'LEGE'.                                            "#EC NOTEXT
      CALL SCREEN 510 STARTING AT 30 5
                      ENDING   AT 90 10.
    WHEN 'OPTI'.                                            "#EC NOTEXT
      CALL SCREEN 5100 STARTING AT 30 5.
    WHEN 'EXT'.                                             "#EC NOTEXT
      PERFORM GET_CURRENT_LINE.
    WHEN 'P-' OR 'P--' OR 'P+' OR 'P++'.                    "#EC NOTEXT
      PERFORM SCROLL USING SVCODE.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_5000  INPUT
