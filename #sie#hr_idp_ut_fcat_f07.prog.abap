*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_UT_FCAT_F07 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  BACK
*&---------------------------------------------------------------------*
*       BACK (Grüner Pfeil)
*----------------------------------------------------------------------*
FORM BACK.

  STATICS: EXIT(1) TYPE C.

  IF EXIT EQ YES. EXIT. ENDIF. "operation abgebrochen
  SET SCREEN 0. LEAVE SCREEN.

ENDFORM.                    " BACK

*---------------------------------------------------------------------*
*       FORM BREA                                                     *
*---------------------------------------------------------------------*
*       Break (Gelber Pfeil)                                          *
*---------------------------------------------------------------------*
FORM BREA.
  STATICS: EXIT(1) TYPE C.
  IF EXIT EQ YES. EXIT. ENDIF. "operation abgebrochen
      LEAVE PROGRAM.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM XEND                                                     *
*---------------------------------------------------------------------*
*       Cancel (Rotes Kreuz)                                          *
*---------------------------------------------------------------------*
FORM XEND.
  STATICS: EXIT(1) TYPE C.
  IF EXIT EQ YES. EXIT. ENDIF. "operation abgebrochen
  LEAVE PROGRAM.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  UPDATE_ITAB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE UPDATE_ITAB INPUT.

MODIFY TABLE G_FIELDS FROM /SIE/HR_IDP_FIELDCAT_SEL.

ENDMODULE.                 " UPDATE_ITAB  INPUT
*&---------------------------------------------------------------------*
*&      Form  PAGING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SVCODE  text
*----------------------------------------------------------------------*
FORM PAGING USING    P_SVCODE.
      PERFORM SCROLL_AT_TC USING P_SVCODE
                                 TC_FIELDS-LINES
                                 TAB_LINES
                            CHANGING TC_FIELDS-TOP_LINE.
ENDFORM.                    " PAGING

*---------------------------------------------------------------------*
*       FORM scroll_at_tc                                             *
*---------------------------------------------------------------------*
*       Generische Implementation eines Scrollmechanismus fur         *
*       beliebige Table Controls.                                     *
*---------------------------------------------------------------------*
form scroll_at_tc using value(scroll)
                        VALUE(LINES)
                        VALUE(TC_LINE_COUNT)
               changing top_line.
  statics: i type i, j type i.
  case scroll.
    when 'P--'.
      top_line = 1.
    when 'P-'.
      if top_line le tc_line_count.
        top_line = 1.
      else.
        top_line = top_line - tc_line_count.
      endif.
    when 'P+'.
      i = top_line + tc_line_count.
      j = lines - sy-loopc + 1.
      if j le 0. j = 1. endif.
      if i le j.
        top_line = i.
      else.
        top_line = j.
      endif.
    when 'P++'.
      top_line = lines - tc_line_count + 1.
      if top_line le 0.
        top_line = 1.
      endif.
  endcase.
endform.                    " SCROLL_AT_TC
