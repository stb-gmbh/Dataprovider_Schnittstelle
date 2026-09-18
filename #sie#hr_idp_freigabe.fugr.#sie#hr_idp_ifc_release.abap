FUNCTION /sie/hr_idp_ifc_release.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(IFCID) TYPE  /SIE/HR_IDP_INTERFACE_ID
*"             VALUE(FL_NEW_VERSION) TYPE  XFLAG DEFAULT SPACE
*"             VALUE(FL_EXE_WO_RELEASE) TYPE  XFLAG DEFAULT SPACE
*"       EXPORTING
*"             VALUE(DBSEL) LIKE  /SIE/HR_IDP_DB_SEL
*"                             STRUCTURE  /SIE/HR_IDP_DB_SEL
*"       EXCEPTIONS
*"              ENQUEUE
*"              WAS_RELEASED
*"              DB_INCONSISTENT
*"              PROGRAM_EXISTS
*"              PROGRAM_ERROR
*"              RELEASE_CANCELLED
*"----------------------------------------------------------------------

  DATA: new_interface TYPE /sie/hr_idp_ifc_db
      , interface TYPE /sie/hr_idp_ifc_db
      , version TYPE /sie/hr_idp_vers_nr
      , old_version TYPE /sie/hr_idp_vers_nr
      , wa_s1r TYPE /sie/hr_idp_s1r
      , wa_s1pg TYPE /sie/hr_idp_s1pg
      , wa_s1vt TYPE /sie/hr_idp_s1vt
      , wa_s1f TYPE /sie/hr_idp_s1f
      , rc TYPE x
      , fl_release TYPE ty_yesno
      , subrc TYPE sysubrc
      .

  DATA: f(240),
        g TYPE i,
        h(72).
  DATA: program LIKE sy-repid VALUE 'PROGNAME',
        BEGIN OF t OCCURS 500,
          line(72),
        END   OF t.


  PERFORM enqueue USING ifcid
                  CHANGING rc.
  IF ( rc = 0 ) OR ( rc = 4 ).

  ELSE.
* Die Verarbeitung muss abgebrochen werden.
* Hier sollte der user davon unterrichtet werden. Danach abbruch.
    EXIT.
  ENDIF.

* Alles nachlesen
  PERFORM ifc_curr_vers USING ifcid
                        CHANGING rc
                                 version.

  interface-s1-ifcid = ifcid.

  dbsel = c_all_tabl.
  PERFORM ifc_read CHANGING interface
                            version
                            dbsel.

  PERFORM ifc_refresh_reference CHANGING interface.

* Ist die Schnittstelle schon freigegeben?
  IF ( fl_exe_wo_release IS INITIAL ).
    READ TABLE interface-s1f WITH KEY trole = '06'
                             INTO wa_s1f.
    IF NOT ( wa_s1f-ch_datum IS INITIAL ).
      MESSAGE s302 RAISING was_released.
    ENDIF.
  ENDIF.

  IF ( interface-s1df-gnrtd = yes ).
    CALL FUNCTION '/SIE/HR_IDP_GENERATE_NAME'
         EXPORTING
              interface    = interface
              version      = version
         IMPORTING
              report_name  = interface-s1df-progr
              variant_name = interface-s1df-varia
              subrc        = subrc
         EXCEPTIONS
              OTHERS       = 1.
    IF fl_exe_wo_release IS INITIAL.
      IF subrc <> 0.
*        message s303 raising program_exists.
      ENDIF.
    ENDIF.
  ENDIF.

* Schnittstelle überprüfen
  PERFORM ifc_check USING no
                    CHANGING interface
                             version
                             fl_release.

  IF ( fl_release = yes ).   " Alles perfekt

* Freigabeinformationen
    READ TABLE interface-s1f INTO wa_s1f WITH KEY trole = '06'.
    IF sy-subrc = 0.
      wa_s1f-ch_datum = sy-datum.
      wa_s1f-ch_uname = sy-uname.
      wa_s1f-ch_uzeit = sy-uzeit.
      MODIFY interface-s1f FROM wa_s1f INDEX sy-tabix.
    ELSE.
      RAISE db_inconsistent.
    ENDIF.

* Aufruf der Generierung.
    PERFORM enq_report USING interface-s1df-progr.
    CALL FUNCTION '/SIE/HR_IDP_GENERATE_REPORT'
         EXPORTING
              p_trans_data  = interface
              p_proc_vector = dbsel.

    PERFORM deq_report USING interface-s1df-progr.

    READ REPORT interface-s1df-progr INTO t.
    SYNTAX-CHECK FOR t MESSAGE f LINE g WORD h
                 PROGRAM interface-s1df-progr.
    IF sy-subrc >< 0.
* Das Program ist syntaktisch nicht fehlerfrei
      MESSAGE e610 WITH sy-msgv1 space space space
                      RAISING program_error.
    ELSE.
      IF ( interface-s1df-gnrvt = yes ).
        CALL FUNCTION '/SIE/HR_IDP_GENERATE_VARIANT'
             EXPORTING
                  ifcid     = interface-s1-ifcid
                  vrsnr     = version
             CHANGING
                  interface = interface.
      ENDIF.
      IF ( fl_exe_wo_release IS INITIAL ).
* Aktuelle Version als 'ALT' markieren und abspeichern
        interface-s1-new_version = no.
        interface-s1-act_vers_nr = version.
        dbsel-s1lt = no.
        PERFORM ifc_save CHANGING interface
                                  version
                                  dbsel.
      ENDIF.

* Es soll standardmäßig keine Neue version gezogen werden.
      IF fl_new_version = yes.

* 'Neue' Version abspeichern
        old_version = version.
        version = version + 1.

*      clear interface-s1vn-release_date.
*      clear interface-s1vn-release_time.

        CALL FUNCTION '/SIE/HR_IDP_IFC_COPY'
             EXPORTING
                  old_interface = interface
                  new_id        = interface-s1-ifcid
                  new_version   = version
                  act_version   = old_version
                  dbsel         = dbsel
             IMPORTING
                  new_interface = new_interface.

        PERFORM ifc_save CHANGING new_interface
                                  version
                                  dbsel.
      ELSE.
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE s072 WITH ifcid RAISING release_cancelled.
  ENDIF.

  PERFORM dequeue USING ifcid.

ENDFUNCTION.
