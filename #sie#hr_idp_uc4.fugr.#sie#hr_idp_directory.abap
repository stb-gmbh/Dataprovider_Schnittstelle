FUNCTION /SIE/HR_IDP_DIRECTORY.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(DIRECTORY) TYPE  TEXT256
*"  EXCEPTIONS
*"      DIRECTORY_NOT_FOUND
*"----------------------------------------------------------------------
*" 20141106 ML    Unicode-Umstellung (INC5560081)                  ML001
*"----------------------------------------------------------------------

  DATA: PARAMETERS LIKE SXPGCOLIST-PARAMETERS.

  DATA: STATUS LIKE EXTCMDEXEX-STATUS
      , EXITCODE LIKE EXTCMDEXEX-EXITCODE
      , T_PROT LIKE BTCXPM OCCURS 100 WITH HEADER LINE
      .

  OPEN DATASET DIRECTORY FOR INPUT IN TEXT MODE ENCODING DEFAULT. "ML001
  IF SY-SUBRC = 0.
* alles ok.
  ELSE.
* Directory muß angelegt werden.
    CONCATENATE '-p' DIRECTORY                              "#EC NOTEXT
                INTO PARAMETERS
                SEPARATED BY SPACE.

    CALL FUNCTION 'SXPG_COMMAND_EXECUTE'
         EXPORTING
              COMMANDNAME                   = 'ZMKDIR'      "#EC NOTEXT
              ADDITIONAL_PARAMETERS         = PARAMETERS
              OPERATINGSYSTEM               = 'UNIX'        "#EC NOTEXT
         IMPORTING
              STATUS                        = STATUS
              EXITCODE                      = EXITCODE
         TABLES
              EXEC_PROTOCOL                 = T_PROT
         EXCEPTIONS
              NO_PERMISSION                 = 1
              COMMAND_NOT_FOUND             = 2
              PARAMETERS_TOO_LONG           = 3
              SECURITY_RISK                 = 4
              WRONG_CHECK_CALL_INTERFACE    = 5
              PROGRAM_START_ERROR           = 6
              PROGRAM_TERMINATION_ERROR     = 7
              X_ERROR                       = 8
              PARAMETER_EXPECTED            = 9
              TOO_MANY_PARAMETERS           = 10
              ILLEGAL_COMMAND               = 11
              WRONG_ASYNCHRONOUS_PARAMETERS = 12
              CANT_ENQ_TBTCO_ENTRY          = 13
              JOBCOUNT_GENERATION_ERROR     = 14
              OTHERS                        = 15.
    IF SY-SUBRC >< 0.
      RAISE DIRECTORY_NOT_FOUND.
    ENDIF.
  ENDIF.

  COMMIT WORK.

ENDFUNCTION.
