FUNCTION /sie/hr_idp_new_version.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IFCID) TYPE  /SIE/HR_IDP_INTERFACE_ID
*"  EXPORTING
*"     VALUE(DBSEL) TYPE  /SIE/HR_IDP_DB_SEL
*"  EXCEPTIONS
*"      NOT_RELEASED
*"      NO_ENQUEUE
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
      .

  dbsel = c_all_tabl.

  PERFORM enqueue USING ifcid
                  CHANGING rc.

  IF ( rc = 0 ) OR ( rc = 4 ).

  ELSE.
    MESSAGE w111 WITH ifcid RAISING no_enqueue.
  ENDIF.

  PERFORM ifc_curr_vers USING ifcid
                        CHANGING rc
                                 version.

  interface-s1-ifcid = ifcid.

  PERFORM ifc_read CHANGING interface
                            version
                            dbsel.

* Prüfen, ob die Schnittstelle schon freigegeben worden ist, ansonsten
* gibt es ein Fehler.
*  if interface-s1vn-release_date is initial.
  READ TABLE interface-s1f WITH KEY trole = '06'
                           INTO wa_s1f.
  IF wa_s1f-ch_datum IS INITIAL.
    MESSAGE w110 WITH interface-s1-ifcid RAISING not_released.
  ENDIF.

* Prüfen, ob die Schnittstelle schon abgenommen worden ist, ansonsten
* gibt es eind Fehler
*  read table interface-s1f with key trole = '07'
*                           into wa_s1f.
*  if wa_s1f-ch_datum is initial .
**  if interface-s1vn-accept_date is initial.
*    message w112 with interface-s1-ifcid raising not_released.
*  endif.

* Aktuelle Version als 'ALT' markieren und abspeichern
  interface-s1-new_version = yes.
  PERFORM ifc_save CHANGING interface
                            version
                            dbsel.

* 'Neue' Version abspeichern
  old_version = version.
  version = version + 1.

  CALL FUNCTION '/SIE/HR_IDP_IFC_COPY'
       EXPORTING
            old_interface = interface
            new_id        = interface-s1-ifcid
            new_version   = version
            act_version   = old_version
            dbsel         = dbsel
       IMPORTING
            new_interface = new_interface.

  PERFORM ifc_refresh_reference
                   CHANGING new_interface.

  PERFORM ifc_save CHANGING new_interface
                            version
                            dbsel.

  PERFORM dequeue USING ifcid.

ENDFUNCTION.
