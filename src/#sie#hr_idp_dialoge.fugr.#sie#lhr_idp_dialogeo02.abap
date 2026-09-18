*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_DIALOGEO02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_2000 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
  IF EDITOR IS INITIAL.

* set status
    SET PF-STATUS 'EDIT_100'.
*   set titlebar  'EDIT_100' with gl_title.

* initilize local variable with sy-repid, since sy-repid doesn't work
*  as parameter directly.
    repid = sy-repid.

* create calls constructor, which initializes, creats and links
*  a TextEdit Control
    create object editor
      exporting
         repid = repid
         DYNNR = '2000'
         DYNPRO_CONTAINER = 'TEXTEDITOR1'
         WORDWRAP_MODE = C_TEXTEDIT_CONTROL=>WORDWRAP_AT_FIXED_POSITION
         WORDWRAP_POSITION          = 80
         WORDWRAP_TO_LINEBREAK_MODE = C_TEXTEDIT_CONTROL=>TRUE
      exceptions
          others = 1.

    if sy-subrc ne 0.
      CALL FUNCTION 'POPUP_TO_INFORM'
           EXPORTING
                TITEL = repid
                TXT2  = SPACE
                TXT1  = 'The control could not be created'.
    endif.

    CALL METHOD EDITOR->SET_TEXT_AS_R3TABLE
            EXPORTING TABLE = MYTABLE
    EXCEPTIONS
        OTHERS = 1.

    CALL METHOD EDITOR->SET_WORDWRAP_BEHAVIOR
            EXPORTING WORDWRAP_MODE              = '2'
                      WORDWRAP_POSITION          = '80'
                      WORDWRAP_TO_LINEBREAK_MODE = '1'
    EXCEPTIONS
        OTHERS = 1.
    IF NOT GL_READONLY IS INITIAL.
      CALL METHOD EDITOR->SET_READONLY_MODE
              EXPORTING READONLY_MODE              = '1'
      EXCEPTIONS
          OTHERS = 1.
    ENDIF.


  ENDIF.                               " Editor is initial

* finally perform a flush to execute the calls in the control queue
  CALL FUNCTION 'CONTROL_FLUSH'
       EXCEPTIONS
            OTHERS = 1.

  if sy-subrc ne 0.
    CALL FUNCTION 'POPUP_TO_INFORM'
         EXPORTING
              TITEL = repid
              TXT2  = ' '
              TXT1  = 'Error in FLUSH'.
  endif.


ENDMODULE.                 " STATUS_2000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0040  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0040 OUTPUT.
   DATA NC1 LIKE SY-CUCOL.
   DATA LIN  TYPE P.
   SUPPRESS DIALOG.
   LEAVE TO LIST-PROCESSING.
*   if infoflag0 ne space.
*       set pf-status '040'.
*   else.
       SET PF-STATUS '040' EXCLUDING 'INFO'.
*   endif.
   SET TITLEBAR '010' WITH SPOP-TITEL.
   DESCRIBE TABLE LINESH LINES LIN.
   IF LIN EQ 0.
      LOOP AT LINESB.
              IF LINESB-TEXT EQ SPACE. SKIP.
              ELSE.
                 IF LINESB-HELL NE SPACE.
                    WRITE: / LINESB-TEXT INTENSIFIED ON.
                 ELSE.
                    WRITE: / LINESB-TEXT INTENSIFIED OFF.
                 ENDIF.
              ENDIF.
      ENDLOOP.
   ELSE.
      NC1 = NCOL - 2.
      LOOP AT LINESB.
           WRITE: / SY-VLINE NO-GAP.
                 IF LINESB-HELL NE SPACE.
                    WRITE: AT (NC1)  LINESB-TEXT INTENSIFIED ON NO-GAP.
                 ELSE.
                    WRITE: AT (NC1)  LINESB-TEXT INTENSIFIED OFF NO-GAP.
                 ENDIF.
          WRITE: AT NCOL SY-VLINE.
      ENDLOOP.
      ULINE AT /1(NCOL).
   ENDIF.
   SET SCREEN 0.
   LEAVE SCREEN.

ENDMODULE.                 " STATUS_0040  OUTPUT
