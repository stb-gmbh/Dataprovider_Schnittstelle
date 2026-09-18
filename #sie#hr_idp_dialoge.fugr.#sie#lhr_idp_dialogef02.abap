*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_DIALOGEF02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  EXIT_CONTROL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM EXIT_CONTROL.
* Destroy Control.
  CALL METHOD EDITOR->DESTROY_CONTROL
      exceptions
          others = 1.

  if sy-subrc ne 0.
    CALL FUNCTION 'POPUP_TO_INFORM'
         EXPORTING
              TITEL = repid
              TXT2 = ' '
              TXT1  = 'Failure while destroying TextEdit control!'.
  endif.
  CALL FUNCTION 'CONTROL_FLUSH'
      EXCEPTIONS
          OTHERS = 1.

  if sy-subrc ne 0.
    CALL FUNCTION 'POPUP_TO_INFORM'
         EXPORTING
              TITEL = repid
              TXT2 = ' '
              TXT1  = 'Error in FLUSH'.
  endif.

  CLEAR EDITOR.

ENDFORM.                    " EXIT_CONTROL
