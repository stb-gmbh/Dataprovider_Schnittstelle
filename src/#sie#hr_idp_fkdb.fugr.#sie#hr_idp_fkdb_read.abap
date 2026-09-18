FUNCTION /SIE/HR_IDP_FKDB_READ.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(FELDNAME) TYPE  /SIE/HR_IDP_FNAME
*"       CHANGING
*"             VALUE(TRANSACTION_DATA) TYPE  /SIE/HR_IDP_IFC_FKDB
*"             VALUE(DBSEL) TYPE  /SIE/HR_IDP_FKDB_SEL
*"----------------------------------------------------------------------

* Prüfe ob die diesselbe Schnittstelle angesprochen wird.
  IF ( FELDNAME NE OLD_FELDNAME ).
    PERFORM RESET_BUFFER.
    OLD_FELDNAME = FELDNAME.
  ENDIF.

* Prüfe ob ich überhaupt was zu tun habe..
  CHECK DBSEL NE SPACE.

  DEFINE GET_DATA.
    IF &1 EQ YES.                  " Lesen angefordert?
      TABLE_NAME = &2.               " Tabellenname
      PERFORM GET_DATA CHANGING &3   " Schnittstellendatentabelle Neu
                                &4   " Schnittstellendatentabelle Alt
                                &1   " dbsel-xx
                                &5   " buffered-xx
                                &6.  " found-xx
    ENDIF.
  END-OF-DEFINITION.

  DEFINE GET_DATAX.
    IF &1 EQ YES.                  " Lesen angefordert?
      TABLE_NAME = &2.               " Tabellenname
      PERFORM GET_DATAX TABLES &3   " Schnittstellendatentabelle Neu
                               &4   " Schnittstellendatentabelle Alt
                        CHANGING &1   " dbsel-xx
                                 &5   " buffered-xx
                                 &6.  " found-xx
    ENDIF.
  END-OF-DEFINITION.

  GET_DATAX:
    DBSEL-F1LT '/SIE/HR_IDP_F1LT' TRANSACTION_DATA-F1LT DB_DATA-F1LT
    BUFFERED-F1LT FOUND-F1LT
  .
*  get_datax:

ENDFUNCTION.
