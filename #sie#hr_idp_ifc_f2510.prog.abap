*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_F2510 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  EXEC_INTERFACE
*&---------------------------------------------------------------------*
*       Führt eine Schnittstelle aus und zwar mit allem Drum und
*       dran, mit dem einen Unterschied, daß die UC4 Parameter nicht
*       aus der /SIE/HR_IDP_S1DF stammen, sondern aus der /SIE/HR_IDP_A1
*----------------------------------------------------------------------*
FORM EXEC_INTERFACE.

  CONSTANTS: COMMANDNAME LIKE SXPGCOLIST-NAME VALUE 'ZPERL' "#EC NOTEXT
           , LOGICAL_NAME TYPE FILEINTERN VALUE '/SIE/HR_IHOME'
           .

  DATA:
       ADDITIONAL_PARAMETERS LIKE SXPGCOLIST-PARAMETERS
       VALUE 'SHELL/SAPDP_Adhoc.pl &1'                      "#EC NOTEXT
     , COMMAND LIKE SXPGCOLIST-PARAMETERS
     , STATUS LIKE EXTCMDEXEX-STATUS
     , EXITCODE LIKE EXTCMDEXEX-EXITCODE
     , EXEC_PROTOCOL TYPE STANDARD TABLE OF BTCXPM INITIAL SIZE 0
       WITH HEADER LINE
     , SD TYPE TEXT256
     , VARIANT LIKE /SIE/HR_IDP_A1-VARIA
    .

  DATA: RUNTIME TYPE I
      , CANCEL TYPE I
      .

  DATA: RC LIKE SY-SUBRC.

  CLEAR VARIANT.

* Die Parameter für die Schnittstelle speichern.
  FILL_ADM_INFO /SIE/HR_IDP_A1.
  MODIFY /SIE/HR_IDP_A1.

* Die Schnittstelle ausführen, falls keine Variante vorgegeben worden
* ist, dann soll man noch die Selektionen eingeben!
  IF /SIE/HR_IDP_A1-VARIA IS INITIAL.
    MESSAGE S164 WITH SPACE.
  ELSE.
    CONCATENATE /SIE/HR_IDP_A1-VARIA '_AH' INTO VARIANT.
* Prüfen, ob die Schnittstelle die nötige Variante hat!
    CALL FUNCTION 'RS_VARIANT_EXISTS'
         EXPORTING
              REPORT              = /SIE/HR_IDP_A1-PROGR
              VARIANT             = VARIANT
         IMPORTING
              R_C                 = RC
         EXCEPTIONS
              NOT_AUTHORIZED      = 1
              NO_REPORT           = 2
              REPORT_NOT_EXISTENT = 3
              REPORT_NOT_SUPPLIED = 4
              OTHERS              = 5.
    IF RC <> 0 OR SY-SUBRC >< 0.
      MESSAGE S164 WITH VARIANT.
    ELSE.

      CLEAR SD.
      EXPORT SD TO MEMORY ID 'SAP_DP'.

* Prüfen, ob die Variante aktuell ist!
      PERFORM CHECK_VARIANT_UP_TO_DATE USING /SIE/HR_IDP_A1-PROGR
                                             /SIE/HR_IDP_A1-PROGR
                                             VARIANT
                                       CHANGING RC.
      IF RC = 0.

        SUBMIT (/SIE/HR_IDP_A1-PROGR)
        USING SELECTION-SET VARIANT
        EXPORTING LIST TO MEMORY
        AND RETURN.
* Vor der Ausführung des Perl Scripts muß noch der Pfad zur Sendedatei
* gefunden werden.
        CALL FUNCTION 'FILE_GET_NAME'
             EXPORTING
                  CLIENT           = SY-MANDT
                  LOGICAL_FILENAME = LOGICAL_NAME
                  OPERATING_SYSTEM = SY-OPSYS
             IMPORTING
                  FILE_NAME        = COMMAND
             EXCEPTIONS
                  FILE_NOT_FOUND   = 1
                  OTHERS           = 2.
        IF SY-SUBRC <> 0.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

        IMPORT SD FROM MEMORY ID 'SAP_DP'.                  "#EC NOTEXT

        CONCATENATE COMMAND ADDITIONAL_PARAMETERS INTO COMMAND.
        REPLACE '&1' WITH SD INTO COMMAND.
        CALL FUNCTION '/SIE/HR_ICOMMAND_EXECUTE_HOST'
             EXPORTING
                  COMMANDNAME                   = COMMANDNAME
                  ADDITIONAL_PARAMETERS         = COMMAND
             IMPORTING
                  STATUS                        = STATUS
                  EXITCODE                      = EXITCODE
             TABLES
                  EXEC_PROTOCOL                 = EXEC_PROTOCOL
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
      ENDIF.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ELSE.
        IF EXITCODE >< 0.
* Fehler bei der Verarbeitung
          MESSAGE S165.
        ELSE.
* Success!
          MESSAGE S166.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  SET SCREEN 0. LEAVE SCREEN.

ENDFORM.                    " EXEC_INTERFACE

*---------------------------------------------------------------------*
*       FORM CHECK_VARIANT_UP_TO_DATE                                 *
*---------------------------------------------------------------------*
*       Lädt das auszuführende Programm in den Speicher um die        *
*       aktuellste Variante im Speicher zu haben.
*---------------------------------------------------------------------*
*  -->  P_REPORT      Report                                          *
*  -->  P_VARI_PROG   Report                                          *
*  -->  P_VARIANT     Variante                                        *
*  -->  P_SUBRC       Return code                                     *
*---------------------------------------------------------------------*
FORM CHECK_VARIANT_UP_TO_DATE USING P_REPORT LIKE SY-CPROG
                                    P_VARI_PROG LIKE SY-CPROG
                                    P_VARIANT LIKE SY-SLSET
                              CHANGING P_SUBRC LIKE SY-SUBRC.

  DATA L_RKEY LIKE RSVARKEY.
  DATA L_SSCR LIKE RSSCR OCCURS 30.
  DATA L_VARI LIKE RVARI OCCURS 20.
  DATA L_VARIVDAT LIKE RSVARIVDAT OCCURS 5.
  DATA L_VARIDYN  LIKE RSVARIDYN  OCCURS 5.
  DATA L_VDATDYN  LIKE RSVDATDYN  OCCURS 5.

  MOVE P_VARI_PROG TO L_RKEY-REPORT.
  MOVE P_VARIANT   TO L_RKEY-VARIANT.

  PERFORM LOAD_SSCR(RSDBRUNT) TABLES   L_SSCR
                              USING    P_REPORT
                              CHANGING P_SUBRC.

  IF P_SUBRC NE 0.
    P_SUBRC = 4.
    EXIT.
  ENDIF.

* Importiert 'statischen' Teil einer Variante
*     0: Variante aktuell                                              *
*     2: Veraltet, aber reparabel                                      *
*     4: Variante nicht vorhanden                                      *
*     8: Nicht reparabel, da sich Art, Typ oder Länge geändert hat.    *
  PERFORM IMPORT_VARIANT_STATIC(RSDBSPVD) USING L_SSCR[]
                                                L_VARI[]
                                                L_VARIVDAT
                                                L_VARIDYN
                                                L_VDATDYN
                                                L_RKEY
                                                P_SUBRC.

  IF P_SUBRC < 4.
    P_SUBRC = 0.
  ENDIF.

ENDFORM.
