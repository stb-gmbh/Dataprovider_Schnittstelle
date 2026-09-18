FUNCTION /SIE/HR_IDP_CONVERT_ACCENTS.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(IN_TEXT)
*"             VALUE(SW_UPPER_CASE) TYPE  XFLAG DEFAULT 'X'
*"             VALUE(SW_CONVERT) TYPE  XFLAG DEFAULT 'X'
*"             VALUE(SW_FIXED_LENGTH) TYPE  XFLAG DEFAULT 'X'
*"             VALUE(SW_STRIP_APOSTROPHE) TYPE  XFLAG DEFAULT 'X'
*"             VALUE(SW_STRIP_DOT) TYPE  XFLAG DEFAULT 'X'
*"             VALUE(SW_STRIP_SLASH) TYPE  XFLAG DEFAULT 'X'
*"             VALUE(SW_STRIP_COMMA) TYPE  XFLAG DEFAULT 'X'
*"             VALUE(SW_STRIP_HIFEN) TYPE  XFLAG DEFAULT 'X'
*"       EXPORTING
*"             VALUE(OUT_TEXT)
*"       EXCEPTIONS
*"              CANNOT_CONVERT
*"              LANGU_NOT_SUPPORTED
*"----------------------------------------------------------------------

  DATA: HELP_LANGU LIKE SY-LANGU
      , TEXT_LENGTH TYPE I
      .

  TEXT_LENGTH = STRLEN( IN_TEXT ).
  CLEAR OUT_TEXT.
  CHECK TEXT_LENGTH NE 0.

* Conversion of "strange" characters
  IF SW_CONVERT = YES.
    CALL FUNCTION 'SCP_REPLACE_STRANGE_CHARS'
         EXPORTING
              INTEXT            = IN_TEXT
         IMPORTING
              OUTTEXT           = OUT_TEXT
         EXCEPTIONS
              INVALID_CODEPAGE  = 1
              CODEPAGE_MISMATCH = 2
              INTERNAL_ERROR    = 3
              CANNOT_CONVERT    = 4
              FIELDS_NOT_TYPE_C = 5
              OTHERS            = 6.
    IF SY-SUBRC <> 0.
      RAISE CANNOT_CONVERT.
    ELSE.
      IF SW_FIXED_LENGTH = YES.
*       out_text = out_text(text_length).
      ENDIF.
    ENDIF.
  ELSE.
    OUT_TEXT = IN_TEXT.
  ENDIF.
* Translation to upper case
  IF SW_UPPER_CASE = YES.
    HELP_LANGU = SY-LANGU.
*  Yes! First, check if language is supported by the application
*  server.
    CALL FUNCTION 'STRN_SUBMIT_RSTXR3TR'
         EXPORTING
              LANGU     = SY-LANGU
         IMPORTING
              EXECLANGU = HELP_LANGU
         EXCEPTIONS
              OTHERS    = 0.
    IF NOT ( HELP_LANGU IS INITIAL ) AND SY-SUBRC EQ 0.
* yes, it is.
      SET LOCALE LANGUAGE HELP_LANGU.
    ELSE.
* Logon language could be supported, but the result might be wrong!
* Thus, we generate an error message.
      RAISE LANGU_NOT_SUPPORTED.
    ENDIF.

    TRANSLATE OUT_TEXT TO UPPER CASE.
    SET LOCALE LANGUAGE SPACE.
  ENDIF.

  PERFORM STRIP_TEXT USING SW_STRIP_APOSTROPHE
                           TEXT-APO
                     CHANGING OUT_TEXT.
  .
  PERFORM STRIP_TEXT USING SW_STRIP_DOT
                           '...'
                     CHANGING OUT_TEXT.

  PERFORM STRIP_TEXT USING SW_STRIP_SLASH
                           '/'
                     CHANGING OUT_TEXT.

  PERFORM STRIP_TEXT USING SW_STRIP_COMMA
                           ','
                     CHANGING OUT_TEXT.

  PERFORM STRIP_TEXT USING SW_STRIP_HIFEN
                           '-'
                     CHANGING OUT_TEXT.

ENDFUNCTION.

*---------------------------------------------------------------------*
*       FORM STRIP_TEXT                                               *
*---------------------------------------------------------------------*
*       Strips certain characters from the string                     *
*---------------------------------------------------------------------*
*  -->  SW_CHARACTER Character is to  be replaced                     *
*  -->  WA_CHARACTER Character to be replaced                         *
*  -->  OUT_TEXT     String to search and destroy characters          *
*---------------------------------------------------------------------*
FORM STRIP_TEXT USING SW_CHARACTER TYPE XFLAG
                      WA_CHARACTER TYPE C
                CHANGING OUT_TEXT.

  DATA: FL_CHARACTER TYPE XFLAG.

  IF SW_CHARACTER = YES.
    FL_CHARACTER = YES.
    WHILE FL_CHARACTER = YES.
      SEARCH OUT_TEXT FOR WA_CHARACTER.
      IF SY-SUBRC = 0.
        IF WA_CHARACTER = '...'.
          REPLACE '.' WITH '_' INTO OUT_TEXT.
        ELSE.
          REPLACE WA_CHARACTER WITH '_' INTO OUT_TEXT.
        ENDIF.
      ELSE.
        FL_CHARACTER = NO.
      ENDIF.
    ENDWHILE.
  ENDIF.

ENDFORM.
