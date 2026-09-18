FUNCTION /SIE/HR_IDP_GENERATE_NAME.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(INTERFACE) TYPE  /SIE/HR_IDP_IFC_DB
*"             VALUE(VERSION) TYPE  /SIE/HR_IDP_VERS_NR
*"             VALUE(FL_TEST) TYPE  XFLAG DEFAULT SPACE
*"       EXPORTING
*"             VALUE(REPORT_NAME) TYPE  PROGRAMM
*"             VALUE(VARIANT_NAME) TYPE  VARIANT
*"             VALUE(SUBRC) TYPE  SYSUBRC
*"----------------------------------------------------------------------

  DATA: REPORT LIKE SYSUUID-C22.

  IF FL_TEST IS INITIAL.
    CONCATENATE '/SIE/HR_IDP'                               " +11
                SY-MANDT                 " +3
                INTERFACE-S1-IFCID       " +15 -> geändert auf 12
                VERSION                  " +4          = 33 -> 30
                INTO REPORT_NAME.
  ELSE.   " TESTLAUF!
*    call function 'SYSTEM_UUID_C22_CREATE'
*         importing
*              uuid_c22 = report.
*    concatenate '/SIE/'
*                report
*                  into report_name.
    CONCATENATE '/SIE/HR_IDP'                               " +11
                SY-MANDT                 " +3
                INTERFACE-S1-IFCID       " +15 -> geändert auf 12
                'TEST'                   " +4 = 33 -> 30
                INTO REPORT_NAME.
  ENDIF.

  CONDENSE REPORT_NAME NO-GAPS.

  CALL FUNCTION '/SIE/HR_IDP_CONVERT_ACCENTS'
       EXPORTING
            IN_TEXT             = REPORT_NAME
            SW_UPPER_CASE       = YES
            SW_CONVERT          = YES
            SW_FIXED_LENGTH     = NO
            SW_STRIP_APOSTROPHE = YES
            SW_STRIP_DOT        = YES
            SW_STRIP_SLASH      = NO
            SW_STRIP_COMMA      = YES
            SW_STRIP_HIFEN      = YES
       IMPORTING
            OUT_TEXT            = REPORT_NAME
       EXCEPTIONS
            CANNOT_CONVERT      = 1
            LANGU_NOT_SUPPORTED = 2
            OTHERS              = 3.
  IF SY-SUBRC <> 0.
    SUBRC = 8.
  ENDIF.

*  variant_name = interface-s1-act_vers_nr.
  VARIANT_NAME = VERSION.

  SELECT SINGLE * FROM  TRDIR
         WHERE  NAME  = REPORT_NAME.
  IF SY-SUBRC = 0.
    SUBRC = 8.
  ENDIF.

ENDFUNCTION.
