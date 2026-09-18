FUNCTION /SIE/HR_IDP_TEST_GENERATOR.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(IFCID) TYPE  /SIE/HR_IDP_INTERFACE_ID
*"       EXPORTING
*"             VALUE(DBSEL) LIKE  /SIE/HR_IDP_DB_SEL
*"                             STRUCTURE  /SIE/HR_IDP_DB_SEL
*"       EXCEPTIONS
*"              ENQUEUE
*"              WAS_RELEASED
*"              DB_INCONSISTENT
*"              PROGRAM_EXISTS
*"----------------------------------------------------------------------

  DATA: INTERFACE TYPE /SIE/HR_IDP_IFC_DB
      , VERSION TYPE /SIE/HR_IDP_VERS_NR
      , RC TYPE X
      , SUBRC TYPE SYSUBRC
      , FL_RELEASE TYPE C
      .

  PERFORM ENQUEUE USING IFCID
                  CHANGING RC.
  IF ( RC = 0 ) OR ( RC = 4 ).

  ELSE.
* Die Verarbeitung muss abgebrochen werden.
* Hier sollte der user davon unterrichtet werden. Danach abbruch.
    EXIT.
  ENDIF.

* Alles nachlesen
  PERFORM IFC_CURR_VERS USING IFCID
                        CHANGING RC
                                 VERSION.

  INTERFACE-S1-IFCID = IFCID.

  DBSEL = C_ALL_TABL.
  PERFORM IFC_READ CHANGING INTERFACE
                            VERSION
                            DBSEL.

  CALL FUNCTION '/SIE/HR_IDP_GENERATE_NAME'
       EXPORTING
            INTERFACE    = INTERFACE
            VERSION      = VERSION
            FL_TEST      = YES
       IMPORTING
            REPORT_NAME  = INTERFACE-S1DF-PROGR
            VARIANT_NAME = INTERFACE-S1DF-VARIA
            SUBRC        = SUBRC
       EXCEPTIONS
            OTHERS       = 1.

* schnittstelle überprüfen
  PERFORM IFC_CHECK USING    YES
                    CHANGING INTERFACE
                             VERSION
                             FL_RELEASE.

  IF ( FL_RELEASE = YES ).   " Alles perfekt
* Aufruf der Generierung.
    PERFORM ENQ_REPORT USING INTERFACE-S1DF-PROGR.

    CALL FUNCTION '/SIE/HR_IDP_GENERATE_REPORT'
         EXPORTING
              P_TRANS_DATA    = INTERFACE
              P_PROC_VECTOR   = DBSEL
              P_FLAG_TESTLAUF = YES.

    PERFORM DEQ_REPORT USING INTERFACE-S1DF-PROGR.
    IF ( INTERFACE-S1DF-GNRVT = YES ).
      CALL FUNCTION '/SIE/HR_IDP_GENERATE_VARIANT'
           EXPORTING
                IFCID     = INTERFACE-S1-IFCID
                VRSNR     = VERSION
                TEST_EXEC = YES
           CHANGING
                INTERFACE = INTERFACE.
    ENDIF.
    PERFORM DEQUEUE USING IFCID.

    IF INTERFACE-S1DF-VARIA IS INITIAL.
      SUBMIT (INTERFACE-S1DF-PROGR)
             VIA SELECTION-SCREEN
             AND RETURN.
    ELSE.
*      submit (interface-s1df-progr)
*             via selection-screen
*             using selection-set interface-s1df-varia
*             and return.

* Der aufruf folgt in diesem Funktionsbaustein, der die aktualität der
* Version nochmal überprüft!
      CALL FUNCTION 'SUBMIT_REPORT'
           EXPORTING
                REPORT           = INTERFACE-S1DF-PROGR
                VARIANT          = INTERFACE-S1DF-VARIA
           EXCEPTIONS
                JUST_VIA_VARIANT = 1
                NO_SUBMIT_AUTH   = 2
                OTHERS           = 3.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.

    IF ( INTERFACE-S1DF-GNRVT = YES ).
      CALL FUNCTION 'RS_VARIANT_DELETE'
           EXPORTING
                REPORT               = INTERFACE-S1DF-PROGR
                VARIANT              = INTERFACE-S1DF-VARIA
                FLAG_CONFIRMSCREEN   = YES
                FLAG_DELALLCLIENT    = YES
           EXCEPTIONS
                NOT_AUTHORIZED       = 1
                NOT_EXECUTED         = 2
                NO_REPORT            = 3
                REPORT_NOT_EXISTENT  = 4
                REPORT_NOT_SUPPLIED  = 5
                VARIANT_LOCKED       = 6
                VARIANT_NOT_EXISTENT = 7
                NO_CORR_INSERT       = 8
                VARIANT_PROTECTED    = 9
                OTHERS               = 10.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

    ENDIF.

    IF NOT ( INTERFACE-S1DF-PROGR IS INITIAL ).
      CALL FUNCTION 'RS_DELETE_PROGRAM'
           EXPORTING
                PROGRAM            = INTERFACE-S1DF-PROGR
                SUPPRESS_CHECKS    = 'X'
                SUPPRESS_POPUP     = 'X'
                WITH_VARIANTS      = 'X'
           EXCEPTIONS
                ENQUEUE_LOCK       = 1
                OBJECT_NOT_FOUND   = 2
                PERMISSION_FAILURE = 3
                REJECT_DELETION    = 4
                OTHERS             = 5.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

    ENDIF.
  ENDIF.
ENDFUNCTION.
