FUNCTION /SIE/HR_IDP_FKDB_CHECK.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(FELDNAME) TYPE  /SIE/HR_IDP_FNAME
*"             VALUE(TRANSACTION_DATA) TYPE  /SIE/HR_IDP_IFC_FKDB
*"       CHANGING
*"             VALUE(DBSEL) TYPE  /SIE/HR_IDP_FKDB_SEL
*"----------------------------------------------------------------------

* Prüfe ob die diesselbe Schnittstelle angesprochen wird.
  IF ( FELDNAME NE OLD_FELDNAME ).
    PERFORM RESET_BUFFER.
    OLD_FELDNAME = FELDNAME.
  ENDIF.

* Prüfe ob ich überhaupt was zu tun habe..
  CHECK DBSEL NE SPACE.

* Langtext
  IF DBSEL-F1LT = YES.
    IF TRANSACTION_DATA-F1LT = DB_DATA-F1LT.
      CLEAR DBSEL-F1LT.
    ENDIF.
  ENDIF.


ENDFUNCTION.
