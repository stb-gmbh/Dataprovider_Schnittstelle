FUNCTION /sie/hr_idp_ifc_accept.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(IFCID) TYPE  /SIE/HR_IDP_INTERFACE_ID
*"             VALUE(VRSNR) TYPE  /SIE/HR_IDP_VERS_NR
*"       EXPORTING
*"             VALUE(DBSEL) LIKE  /SIE/HR_IDP_DB_SEL
*"                             STRUCTURE  /SIE/HR_IDP_DB_SEL
*"       EXCEPTIONS
*"              ENQUEUE
*"              NOT_RELEASED
*"              DB_INCONSISTENT
*"              WAS_ACCEPTED
*"----------------------------------------------------------------------

  DATA: new_interface TYPE /sie/hr_idp_ifc_db
      , interface TYPE /sie/hr_idp_ifc_db
      , version TYPE /sie/hr_idp_vers_nr
      , wa_s1r TYPE /sie/hr_idp_s1r
      , wa_s1pg TYPE /sie/hr_idp_s1pg
      , wa_s1vt TYPE /sie/hr_idp_s1vt
      , wa_s1f TYPE /sie/hr_idp_s1f
      , rc TYPE x
      , fl_accpt TYPE ty_yesno
      .

  DATA: lv_tabix TYPE sy-tabix.

  PERFORM enqueue USING ifcid
                  CHANGING rc.
  IF ( rc = 0 ) OR ( rc = 4 ).

  ELSE.
    "Die Verarbeitung muss abgebrochen werden.
    "Hier sollte der user davon unterrichtet werden. Danach abbruch.
    EXIT.
  ENDIF.

  version = vrsnr.
  interface-s1-ifcid = ifcid.

  dbsel-s1 = yes.
  dbsel-s1vn = yes.
  dbsel-s1f = yes.
  dbsel-s1f = yes.

  PERFORM ifc_read CHANGING interface
                            version
                            dbsel.

  "Prüfen ob die Schnittstelle schon vorher freigegeben wurde
  READ TABLE interface-s1f WITH KEY trole = '06'
                           INTO wa_s1f.
  IF wa_s1f-ch_datum IS INITIAL.
    MESSAGE s110 WITH interface-s1-ifcid RAISING not_released.
  ELSE.
    "Prüfen ob die Schnittstelle evtl. auch schon freigegeben wurde!
    READ TABLE interface-s1f WITH KEY trole = '07'
                             INTO wa_s1f.
    IF NOT ( wa_s1f-ch_datum IS INITIAL ).
      MESSAGE s119 WITH interface-s1-ifcid RAISING was_accepted.
    ELSE.

      "Abnahmeinformationen ändern
      READ TABLE interface-s1f INTO wa_s1f WITH KEY trole = '07'.
      IF sy-subrc = 0.
        wa_s1f-ch_datum = sy-datum.
        wa_s1f-ch_uname = sy-uname.
        wa_s1f-ch_uzeit = sy-uzeit.
        "TABIX vor CALL SCREEN speichern
        lv_tabix = sy-tabix.
        "Kommentarzeile einfügen
        fl_accept = no.
        CALL SCREEN 0800 STARTING AT 10 10.
        IF fl_accept >< yes.    " Wird auf Dynpro 0800 gesetzt.
          MESSAGE s118 RAISING not_released.
        ENDIF.
        IF NOT ( /sie/hr_idp_s1f-ltext IS INITIAL ).
          wa_s1f-ltext = /sie/hr_idp_s1f-ltext.
        ENDIF.
        MODIFY interface-s1f FROM wa_s1f INDEX lv_tabix.
      ELSE.
        RAISE db_inconsistent.
      ENDIF.

      "Abspeichern
      PERFORM ifc_save CHANGING interface
                                version
                                dbsel.

    ENDIF.
  ENDIF.
  PERFORM dequeue USING ifcid.

ENDFUNCTION.
