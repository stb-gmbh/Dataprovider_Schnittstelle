FUNCTION /SIE/HR_IDP_JOB_END_GET.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(INTERVALL) DEFAULT 30
*"             VALUE(DURATION) DEFAULT 600
*"             VALUE(MANDT) LIKE  SY-MANDT DEFAULT SY-MANDT
*"             VALUE(ABAP_PROGRAM_NAME) LIKE  SY-REPID
*"             VALUE(ABAP_VARIANT_NAME) LIKE  RALDB-VARIANT
*"                             DEFAULT SPACE
*"       EXPORTING
*"             VALUE(RUNTIME)
*"             VALUE(CANCEL)
*"       EXCEPTIONS
*"              NO_JOBS_FOUND
*"----------------------------------------------------------------------

DATA : STARTZEIT LIKE SY-UZEIT,
       ENDZEIT   LIKE SY-UZEIT,
       START     LIKE SY-UZEIT,
       DELTA     TYPE I.

DATA:
      L_JOB_ABORTED LIKE TBTCV-ABORT,                "abgebrochen
      L_JOB_FINISHED LIKE TBTCV-FIN,                 "beendet
      L_JOB_RUNNING  LIKE TBTCV-RUN.                 "running



* Jobliste
DATA: XJOBS LIKE TBTCJOB OCCURS 5 WITH HEADER LINE.

* Potentielle Jobs ermitteln.
  CALL FUNCTION 'BP_FIND_JOBS_WITH_PROGRAM'
       EXPORTING
            ABAP_PROGRAM_NAME             = ABAP_PROGRAM_NAME
            ABAP_VARIANT_NAME             = ABAP_VARIANT_NAME
            DIALOG                        = 'N'
       TABLES
            JOBLIST                       = XJOBS
       EXCEPTIONS
            NO_JOBS_FOUND                 = 1.

  CASE SY-SUBRC.
    WHEN 0.
    WHEN 1.
      MESSAGE S145(BT) RAISING NO_JOBS_FOUND.
  ENDCASE.

* Relevanten Hintergrund-Job ermitteln ->Neuester Job
  SORT XJOBS BY STRTDATE STRTTIME.
  READ TABLE XJOBS INDEX 1.

  GET TIME FIELD STARTZEIT.
  GET TIME FIELD START.

  DO.
*   Zustandsabfrage erfolgt alle Intervall-Sekunden
    GET TIME FIELD ENDZEIT.
    DELTA = ENDZEIT - STARTZEIT.
    IF DELTA GE INTERVALL.
*     Jobstatus ermitteln.
      CALL FUNCTION 'SHOW_JOBSTATE'
           EXPORTING
                JOBCOUNT         = XJOBS-JOBCOUNT
                JOBNAME          = XJOBS-JOBNAME
           IMPORTING
                ABORTED          = L_JOB_ABORTED
                FINISHED         = L_JOB_FINISHED
                RUNNING          = L_JOB_RUNNING.
*     Job abgebrochen oder beendet.
      IF NOT L_JOB_ABORTED IS INITIAL OR
         NOT L_JOB_FINISHED IS INITIAL.
        RUNTIME = ENDZEIT - START.
        CANCEL = 0.
        EXIT.
      ENDIF.
      GET TIME FIELD STARTZEIT.
    ENDIF.

*   Überprüfen, ob maximale Gesamtabfragezeit überschritten wurde
    DELTA = ENDZEIT - START.
    IF DELTA GE DURATION.
      RUNTIME = DELTA.
      CANCEL = 1.
      EXIT.
    ENDIF.
  ENDDO.

ENDFUNCTION.
