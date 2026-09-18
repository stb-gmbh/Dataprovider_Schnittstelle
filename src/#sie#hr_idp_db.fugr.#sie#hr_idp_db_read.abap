FUNCTION /SIE/HR_IDP_DB_READ.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(INTERFACE) TYPE  /SIE/HR_IDP_INTERFACE_ID
*"     VALUE(VERSION) TYPE  /SIE/HR_IDP_VERS_NR
*"  CHANGING
*"     VALUE(TRANSACTION_DATA) TYPE  /SIE/HR_IDP_IFC_DB
*"     VALUE(DBSEL) TYPE  /SIE/HR_IDP_DB_SEL
*"----------------------------------------------------------------------

  IF ( INTERFACE = OLD_IFCID ) AND ( VERSION NE OLD_VRSNR ).
* Rücksetzung aller Versionsabhängigen Informationen.
    PERFORM RESET_BUFFER_VERS.
    OLD_VRSNR = VERSION.
  ELSE.
* Prüfe ob die diesselbe Schnittstelle angesprochen wird.
    IF ( INTERFACE NE OLD_IFCID ) OR ( VERSION NE OLD_VRSNR ).
      PERFORM RESET_BUFFER.
      OLD_IFCID = INTERFACE.
      OLD_VRSNR = VERSION.
    ENDIF.
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

  GET_DATA:
    DBSEL-S1 '/SIE/HR_IDP_S1' TRANSACTION_DATA-S1 DB_DATA-S1
    BUFFERED-S1 FOUND-S1
*
  , DBSEL-S1T '/SIE/HR_IDP_S1T' TRANSACTION_DATA-S1T DB_DATA-S1T
    BUFFERED-S1T FOUND-S1T
*
  , DBSEL-S1PC '/SIE/HR_IDP_S1PC' TRANSACTION_DATA-S1PC DB_DATA-S1PC
    BUFFERED-S1PC FOUND-S1PC
*
  , DBSEL-S1VN '/SIE/HR_IDP_S1VN' TRANSACTION_DATA-S1VN DB_DATA-S1VN
    BUFFERED-S1VN FOUND-S1VN
*
  , DBSEL-S1DF '/SIE/HR_IDP_S1DF' TRANSACTION_DATA-S1DF DB_DATA-S1DF
    BUFFERED-S1DF FOUND-S1DF
*
 , DBSEL-S1PR '/SIE/HR_IDP_S1PR' TRANSACTION_DATA-S1PR DB_DATA-S1PR
   BUFFERED-S1PR FOUND-S1PR
*
 , DBSEL-S1DL '/SIE/HR_IDP_S1DL' TRANSACTION_DATA-S1DL DB_DATA-S1DL
   BUFFERED-S1DL FOUND-S1DL
*
  .

  GET_DATAX:
      DBSEL-S1PG '/SIE/HR_IDP_S1PG' TRANSACTION_DATA-S1PG  DB_DATA-S1PG
      BUFFERED-S1PG FOUND-S1PG
*
*SIE001_BEG
    , DBSEL-S1PS '/SIE/HR_IDP_S1PS' TRANSACTION_DATA-S1PS  DB_DATA-S1PS
      BUFFERED-S1PS FOUND-S1PS
*SIE001_END
*
    , DBSEL-S1VT '/SIE/HR_IDP_S1VT' TRANSACTION_DATA-S1VT  DB_DATA-S1VT
      BUFFERED-S1VT FOUND-S1VT
*
    , DBSEL-S1R '/SIE/HR_IDP_S1R' TRANSACTION_DATA-S1R  DB_DATA-S1R
      BUFFERED-S1R FOUND-S1R
*
    , DBSEL-S1LT '/SIE/HR_IDP_S1LT' TRANSACTION_DATA-S1LT  DB_DATA-S1LT
      BUFFERED-S1LT FOUND-S1LT
*
    , DBSEL-S1F '/SIE/HR_IDP_S1F' TRANSACTION_DATA-S1F DB_DATA-S1F
      BUFFERED-S1F FOUND-S1F
*
   , DBSEL-S1SA '/SIE/HR_IDP_S1SA' TRANSACTION_DATA-S1SA DB_DATA-S1SA
     BUFFERED-S1SA FOUND-S1SA
*
.

ENDFUNCTION.
