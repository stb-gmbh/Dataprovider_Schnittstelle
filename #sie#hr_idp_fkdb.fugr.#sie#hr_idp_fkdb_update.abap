FUNCTION /SIE/HR_IDP_FKDB_UPDATE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(FELDNAME) TYPE  /SIE/HR_IDP_FNAME
*"             VALUE(SW_COMMIT_WORK) TYPE  XFLAG
*"             VALUE(TRANSACTION_DATA) TYPE  /SIE/HR_IDP_IFC_FKDB
*"       CHANGING
*"             VALUE(DBSEL) LIKE  /SIE/HR_IDP_FKDB_SEL
*"                             STRUCTURE  /SIE/HR_IDP_FKDB_SEL
*"----------------------------------------------------------------------

* Macro zum füllen von Arbeitsleisten
  DEFINE: MODIFY_WORKAREA.
    IF &1 EQ YES.
      KEY_LENGTH = &2.
      TABLE_NAME = &3.
      PERFORM MOD_WA CHANGING &4
                              &5
                              &1
                              &6
                              &7.
      IF &1 NE YES.   " Fehler!
        CLEAR &1.  " Ja, dann nichts tun.
        EXIT.
      ENDIF.
    ENDIF.
  END-OF-DEFINITION.

* Macro zum füllen von Tabellen
  DEFINE: MODIFY_TABLE.
    IF &1 EQ YES.
      KEY_LENGTH = &2.
      TABLE_NAME = &3.
      PERFORM MOD_TAB TABLES &4 " Alte Daten
                             &5 " Neue Daten
                      CHANGING &1
                              &6
                              &7.
      IF &1 NE YES.   " Fehler!
        CLEAR &1.  " Ja, dann nichts tun.
        EXIT.
      ENDIF.
    ENDIF.
  END-OF-DEFINITION.

* Prüfe ob die diesselbe Schnittstelle angesprochen wird.
  IF ( FELDNAME NE OLD_FELDNAME ).
    PERFORM RESET_BUFFER.
    OLD_FELDNAME = FELDNAME.
  ENDIF.

* Prüfe ob ich überhaupt was zu tun habe..
  CHECK DBSEL NE SPACE.

*  modify_workarea:

  MODIFY_TABLE:
      DBSEL-F1LT PROG_KEY_LENGTH '/SIE/HR_IDP_F1LT'
      DB_DATA-F1LT[] TRANSACTION_DATA-F1LT[] BUFFERED-F1LT FOUND-F1LT
  .
  CHECK SW_COMMIT_WORK = YES.
  COMMIT WORK.

ENDFUNCTION.
