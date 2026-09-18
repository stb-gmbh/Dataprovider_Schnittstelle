FUNCTION /SIE/HR_I_COMPLEX_SELECTIONS.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(TCLAS) TYPE  TCLAS
*"     VALUE(INFTY) TYPE  INFTY
*"     VALUE(FIELDNAME) TYPE  FIELDNAME
*"     VALUE(FIELDKIND) TYPE  HR_FIELD_KIND
*"     VALUE(WINDOW_TITLE) TYPE  SY-TITLE DEFAULT SPACE
*"     VALUE(TEXT) TYPE  RSSELINT-TEXT OPTIONAL
*"     VALUE(SIGNED) TYPE  RSCONVERT-SIGN DEFAULT 'X'
*"     VALUE(LOWER_CASE) TYPE  RSCONVERT-LOWER DEFAULT SPACE
*"     VALUE(NO_INTERVAL_CHECK) DEFAULT SPACE
*"     VALUE(JUST_DISPLAY) DEFAULT SPACE
*"     VALUE(JUST_INCL) TYPE  C OPTIONAL
*"     VALUE(EXCLUDED_OPTIONS) TYPE  RSOPTIONS OPTIONAL
*"     VALUE(DESCRIPTION) TYPE  RSFLDESC OPTIONAL
*"     VALUE(HELP_FIELD) TYPE  RSSCR-DBFIELD OPTIONAL
*"     VALUE(SEARCH_HELP) TYPE  DDSHDESCR-SHLPNAME OPTIONAL
*"  TABLES
*"      RANGE STRUCTURE  HRRANGES
*"  EXCEPTIONS
*"      ACTION_CANCELLED
*"----------------------------------------------------------------------


* data declerations
  DATA: hstr(78),
        progname LIKE sy-repid,
        cancelled(1),
        ltabname TYPE tabname,
        lfieldname TYPE fieldname,
        lstrucname TYPE ppnnn.

  DATA: chk_entry LIKE trdir,          " attribute
        chk_mess(160),                 " syntax-error message
        chk_line TYPE i,
        chk_word(30).                  "#EC NEEDED


* clear the table containing the dynamically generated coding
  CLEAR:   repcode, repcode[].

* get the real table or structure name for the DDIC-reference
  lfieldname = fieldname.
  call function 'HR_GET_DBNAME'
       exporting
            obj_clas  = tclas
            infty     = infty
            fieldname = fieldname
            fieldkind = fieldkind
       importing
            tabname   = ltabname
            strucname = lstrucname
       exceptions
            not_found = 1
            others    = 2.
  IF sy-subrc NE 0.
    EXIT.
  ENDIF.
* note 0394863
  IF ltabname EQ 'PB0001' and
     lfieldname eq 'PERSG'.
        ltabname   = 'Q0001'.
        lfieldname = 'APGRP'.
        lstrucname = 'Q0001'.
    concatenate ltabname '-' lfieldname into help_field.
  elseif ltabname EQ 'PB0001' and
     lfieldname eq 'PERSK'.
        ltabname   = 'Q0001'.
        lfieldname = 'APTYP'.
        lstrucname = 'Q0001'.
    concatenate ltabname '-' lfieldname into help_field.
  endif.


* create the coding:
* first hte ranges structure
  rappend-0 'REPORT COMPLEX_SELECTION.' 0.
  if not ( lstrucname is initial ).
    CONCATENATE lstrucname '-' lfieldname '.' INTO hstr.
  elseif not ( ltabname is initial ).
    CONCATENATE ltabname '-' lfieldname '.' INTO hstr.
  else.
    exit.
  endif.
  rappend-0 'RANGES: RFIELDS FOR' 0.
  rappend-0 hstr 0.
* FORM 'Complex_Selection'
  rappend-0 'FORM COMPLEX_SELECTION' 0.
  rappend-0 'TABLES P_RANGE STRUCTURE HRRANGES' 5.
  rappend-0 'USING P_TITLE' 5.
  rappend-0 'P_TEXT'                11.
  rappend-0 'P_SIGNED'              11.
  rappend-0 'P_LOWER_CASE'          11.
  rappend-0 'P_NO_INTERVAL_CHECK'   11.
  rappend-0 'P_JUST_DISPLAY'        11.
  rappend-0 'P_JUST_INCL'           11.
  rappend-0 'P_EXCLUDED_OPTIONS'    11.
  rappend-0 'P_DESCRIPTION'         11.
  rappend-0 'P_HELP_FIELD'          11.
  rappend-0 'P_SEARCH_HELP'         11.
  rappend-0 'CHANGING P_CANCELLED.' 5.

  rappend-0 ' ' 0.
  rappend-0 'LOOP AT P_RANGE.' 2.
  rappend-0 'RFIELDS-SIGN   = P_RANGE-SIGN.' 4.
  rappend-0 'RFIELDS-OPTION = P_RANGE-OPTI.' 4.
  rappend-0 'RFIELDS-LOW    = P_RANGE-LOW.' 4.
  rappend-0 'RFIELDS-HIGH   = P_RANGE-HIGH.' 4.
  rappend-0 'APPEND RFIELDS.' 4.
  rappend-0 'ENDLOOP.' 2.

  rappend-0 ' ' 0.
* Function Complex_Selection_Dialog
  CONCATENATE 'CALL FUNCTION' '''' INTO hstr SEPARATED BY space.
  CONCATENATE hstr 'COMPLEX_SELECTIONS_DIALOG' '''' INTO hstr.
  rappend-0 hstr 2.
  rappend-0 'EXPORTING' 8.
  rappend-0 'TITLE             = P_TITLE'             13.
  rappend-0 'TEXT              = P_TEXT'              13.
  rappend-0 'SIGNED            = P_SIGNED'            13.
  rappend-0 'LOWER_CASE        = P_LOWER_CASE'        13.
  rappend-0 'NO_INTERVAL_CHECK = P_NO_INTERVAL_CHECK' 13.
  rappend-0 'JUST_DISPLAY      = P_JUST_DISPLAY'      13.
  rappend-0 'JUST_INCL         = P_JUST_INCL'         13.
  rappend-0 'EXCLUDED_OPTIONS  = P_EXCLUDED_OPTIONS'  13.
  rappend-0 'DESCRIPTION       = P_DESCRIPTION'       13.
  rappend-0 'HELP_FIELD        = P_HELP_FIELD'        13.
  rappend-0 'SEARCH_HELP       = P_SEARCH_HELP'       13.
  rappend-0 'TABLES' 8.
  rappend-0 'RANGE             = RFIELDS' 13.
  rappend-0 'EXCEPTIONS' 8.
  rappend-0 'NO_RANGE_TAB      = 1'  13.
  rappend-0 'CANCELLED         = 2'  13.
  rappend-0 'INTERNAL_ERROR    = 3'  13.
  rappend-0 'OTHERS            = 4.' 13.
  rappend-0 'IF SY-SUBRC <> 0.' 2.
  CONCATENATE 'P_CANCELLED = ' '''' INTO hstr SEPARATED BY space.
  CONCATENATE hstr 'X' '''' '.' INTO hstr.
  rappend-0 hstr 4.
  rappend-0 'EXIT.' 4.
  rappend-0 'ENDIF.' 2.
  rappend-0 'CLEAR   P_RANGE.' 2.
  rappend-0 'REFRESH P_RANGE.' 2.
  rappend-0 'LOOP AT RFIELDS.' 2.
  rappend-0 'P_RANGE-SIGN = RFIELDS-SIGN.' 4.
  rappend-0 'P_RANGE-OPTI = RFIELDS-OPTION.' 4.
  rappend-0 'P_RANGE-LOW  = RFIELDS-LOW.' 4.
  rappend-0 'P_RANGE-HIGH = RFIELDS-HIGH.' 4.
  rappend-0 'APPEND P_RANGE.' 4.
  rappend-0 'ENDLOOP.' 2.
  rappend-0 'ENDFORM.' 0.

* syntax check at the end
  SYNTAX-CHECK FOR repcode MESSAGE chk_mess
                           LINE    chk_line
                           WORD    chk_word
                           DIRECTORY ENTRY chk_entry.
  IF sy-subrc NE 0.
*   Sorry, you got a syntax error in the generated coding
    BREAK-POINT.                       "#EC *
  ENDIF.


* now generate the coding
  GENERATE SUBROUTINE POOL repcode NAME progname.

* execute the function
  PERFORM complex_selection IN PROGRAM (progname) IF FOUND
                            TABLES range
                            USING  window_title
                                   text
                                   signed
                                   lower_case
                                   no_interval_check
                                   just_display
                                   just_incl
                                   excluded_options
                                   description
                                   help_field
                                   search_help
                            CHANGING cancelled.
  IF cancelled NE ' '.
    RAISE action_cancelled.
  ENDIF.
ENDFUNCTION.
* 05.04.2001 note 0394863 multiple selections for PB0001-PERSG and PERSK
