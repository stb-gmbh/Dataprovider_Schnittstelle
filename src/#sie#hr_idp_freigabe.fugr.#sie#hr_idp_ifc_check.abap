FUNCTION /SIE/HR_IDP_IFC_CHECK.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(IFCID) TYPE  /SIE/HR_IDP_INTERFACE_ID
*"             VALUE(SW_WITH_RELEASE) TYPE  XFELD DEFAULT 'X'
*"             VALUE(SW_TEST) TYPE  XFELD DEFAULT SPACE
*"       EXPORTING
*"             VALUE(SUBRC) TYPE  SYSUBRC
*"       CHANGING
*"             VALUE(INTERFACE) TYPE  /SIE/HR_IDP_IFC_DB OPTIONAL
*"             VALUE(VERSION) TYPE  /SIE/HR_IDP_VERS_NR OPTIONAL
*"       EXCEPTIONS
*"              IFCID_WITH_ERROR
*"----------------------------------------------------------------------


  DATA: DBSEL TYPE /SIE/HR_IDP_DB_SEL
      , FL_ALL_OK TYPE X
      .
* Bei Bedarf die Version ermitteln
  IF NOT ( VERSION IS REQUESTED ) .
    PERFORM IFC_CURR_VERS USING IFCID
                          CHANGING FL_ALL_OK
                                   VERSION.
  ENDIF.

* Bei Bedarf die Schnittstelle einlesen.
  IF NOT ( INTERFACE IS REQUESTED ).
    DBSEL = C_ALL_TABL.
    INT_INTERFACE-S1-IFCID = IFCID.
    PERFORM IFC_READ CHANGING INT_INTERFACE
                              VERSION
                              DBSEL.
  ELSE.
* Die Schnittstelle wird global bekanntgegeben
    INT_INTERFACE = INTERFACE.
  ENDIF.

  G_SW_RELEASE_DIALOG = SW_WITH_RELEASE.
  G_SW_TEST = SW_TEST.

  CALL SCREEN 1000 STARTING AT 05 1 ENDING AT 100 11.
  IF SW_WITH_RELEASE = NO.
    SUBRC = 8.
  ELSE.
    IF SW_RELEASE = YES.
      SUBRC = 0.   " Freigeben
    ELSE.
      SUBRC = 8.   " Nicht freigeben
    ENDIF.
  ENDIF.
ENDFUNCTION.
