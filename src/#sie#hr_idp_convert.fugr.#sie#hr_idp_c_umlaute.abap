FUNCTION /SIE/HR_IDP_C_UMLAUTE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(P_IN)
*"             VALUE(P_PARAMETERS) TYPE  /SIE/HR_IDP_KONVPARA
*"                             OPTIONAL
*"       EXPORTING
*"             VALUE(P_OUT)
*"----------------------------------------------------------------------

  DATA: SW_UPPER_CASE TYPE TY_YESNO VALUE NO
      , T_PARAM TYPE TY_TPAIR
      , WA_VALUE TYPE TY_PARAM
      .

  CONSTANTS: C_UPPER_CASE TYPE TY_PARAM VALUE 'UC'.

  PERFORM PARSE_PARAMETERS USING P_PARAMETERS
                           CHANGING T_PARAM.

  PERFORM PARSE_VALUES USING T_PARAM
                             C_UPPER_CASE
                  CHANGING WA_VALUE.

  IF WA_VALUE = 'YES' OR WA_VALUE = 'JA'.
    SW_UPPER_CASE = YES.
  ELSE.
    SW_UPPER_CASE = NO.
  ENDIF.

  CALL FUNCTION '/SIE/HR_IDP_CONVERT_ACCENTS'
       EXPORTING
            IN_TEXT             = P_IN
            SW_UPPER_CASE       = SW_UPPER_CASE
            SW_CONVERT          = YES
            SW_FIXED_LENGTH     = YES
            SW_STRIP_APOSTROPHE = NO
            SW_STRIP_DOT        = NO
            SW_STRIP_SLASH      = NO
            SW_STRIP_COMMA      = NO
            SW_STRIP_HIFEN      = NO
       IMPORTING
            OUT_TEXT            = P_OUT
       EXCEPTIONS
            CANNOT_CONVERT      = 1
            LANGU_NOT_SUPPORTED = 2
            OTHERS              = 3.
  IF SY-SUBRC <> 0.
* ?? Ist dieses Verhalten richtig?
    P_OUT = P_IN.
  ENDIF.

ENDFUNCTION.
