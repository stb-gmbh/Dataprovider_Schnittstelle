*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_F08                                        *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT_FOR_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_FIELD_INPUT  text
*----------------------------------------------------------------------*
FORM CHECK_INPUT_FOR_FIELD CHANGING P_FIELD_INPUT TYPE C.

  DATA: FIELDNAME(50) TYPE C.

  P_FIELD_INPUT = 'X'.
  get cursor field fieldname.
  loop at screen.
    if screen-name = fieldname.
      if screen-input = 1.
        P_FIELD_INPUT = 'X'.
      else.
        CLEAR  P_FIELD_INPUT.
      endif.
      exit.
    endif.
  endloop.

ENDFORM.                    " CHECK_INPUT_FOR_FIELD
