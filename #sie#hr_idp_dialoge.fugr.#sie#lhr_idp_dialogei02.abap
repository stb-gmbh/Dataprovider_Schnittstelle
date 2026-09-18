*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_DIALOGEI02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2000 INPUT.
  CASE OKCODE.

    WHEN 'CANCEL'.
      PERFORM EXIT_CONTROL.
      RAISE USER_CANCELLED.

    WHEN 'OKAY'.
* retrieve table from control
      call method editor->get_text_as_r3table
              importing table = mytable
      exceptions
          others = 1.

      if sy-subrc ne 0.
        CALL FUNCTION 'POPUP_TO_INFORM'
             EXPORTING
                  TITEL = repid
                  TXT2  = ' '
                  TXT1  = 'Error in get_text_as_r3table'.
      ELSE.
        MOVE MYTABLE[] TO GL_TEXTLINES[].
      ENDIF.
      PERFORM EXIT_CONTROL.
      LEAVE TO SCREEN 0.

  endcase.

  clear OKCODE.


ENDMODULE.                 " USER_COMMAND_2000  INPUT
