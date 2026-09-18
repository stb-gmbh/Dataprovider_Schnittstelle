FUNCTION /SIE/HR_IDP_LANGTEXTEDITOR.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(TITEL) DEFAULT 'Langtext'
*"             VALUE(READONLY) DEFAULT SPACE
*"       TABLES
*"              TEXTLINES
*"       EXCEPTIONS
*"              USER_CANCELLED
*"----------------------------------------------------------------------

  MOVE TEXTLINES[] TO GL_TEXTLINES[].
  MOVE TITEL       TO GL_TITLE.
  MOVE GL_TEXTLINES TO MYTABLE.
  MOVE READONLY TO GL_READONLY.
  CALL SCREEN 2000 STARTING AT 5 5.
  MOVE GL_TEXTLINES[] TO TEXTLINES[].
  FREE: EDITOR,
        GL_TEXTLINES.

ENDFUNCTION.
