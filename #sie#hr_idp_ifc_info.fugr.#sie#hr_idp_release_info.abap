FUNCTION /SIE/HR_IDP_RELEASE_INFO.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(INTERFACE_ID) TYPE  /SIE/HR_IDP_INTERFACE_ID
*"             VALUE(VERSION) TYPE  /SIE/HR_IDP_VERS_NR
*"                             DEFAULT '0001'
*"       EXPORTING
*"             VALUE(CURRENT_VERSION) TYPE  /SIE/HR_IDP_VERS_NR
*"             VALUE(CURRENT_RELEASED_VERSION) TYPE
*"                             /SIE/HR_IDP_VERS_NR
*"             VALUE(CURRENT_ACCEPTED_VERSION) TYPE
*"                             /SIE/HR_IDP_VERS_NR
*"----------------------------------------------------------------------

  DATA: DBSEL TYPE /SIE/HR_IDP_DB_SEL
      , INTERFACE TYPE /SIE/HR_IDP_IFC_DB
      , IT_S1VN TYPE STANDARD TABLE OF /SIE/HR_IDP_S1VN INITIAL SIZE 0
      , WA_S1VN TYPE /SIE/HR_IDP_S1VN
      .

*  clear: dbsel, interface.
  DBSEL-S1 = YES.
  DBSEL-S1VN = YES.
  DBSEL-S1F = YES.

  INTERFACE-S1-IFCID = INTERFACE_ID.
  PERFORM IFC_READ CHANGING INTERFACE
                            VERSION
                            DBSEL.

  CURRENT_VERSION = INTERFACE-S1-ACT_VERS_NR.

  SELECT * FROM /SIE/HR_IDP_S1VN INTO TABLE IT_S1VN
                                 WHERE IFCID = INTERFACE_ID.

  SORT IT_S1VN BY VRSNR DESCENDING.

  CLEAR: CURRENT_ACCEPTED_VERSION
       , CURRENT_RELEASED_VERSION
       .

  LOOP AT IT_S1VN INTO WA_S1VN.
    SELECT SINGLE * FROM /SIE/HR_IDP_S1F WHERE IFCID = INTERFACE_ID
                                         AND VRSNR = WA_S1VN-VRSNR
                                         AND TROLE = '07'.
    IF SY-SUBRC = 0.
      IF NOT ( /SIE/HR_IDP_S1F-CH_DATUM IS INITIAL ).
        IF ( CURRENT_ACCEPTED_VERSION IS INITIAL ).
          CURRENT_ACCEPTED_VERSION = WA_S1VN-VRSNR.
        ENDIF.
      ENDIF.

      SELECT SINGLE * FROM /SIE/HR_IDP_S1F WHERE IFCID = INTERFACE_ID
                                           AND VRSNR = WA_S1VN-VRSNR
                                           AND TROLE = '06'.
      IF SY-SUBRC = 0.
        IF NOT ( /SIE/HR_IDP_S1F-CH_DATUM IS INITIAL ).
          IF ( CURRENT_RELEASED_VERSION IS INITIAL ).
            CURRENT_RELEASED_VERSION = WA_S1VN-VRSNR.
          ENDIF.
        ELSE.
* Do nothing
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFUNCTION.
