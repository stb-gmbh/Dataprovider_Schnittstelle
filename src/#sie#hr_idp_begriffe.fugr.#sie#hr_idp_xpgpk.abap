FUNCTION /SIE/HR_IDP_XPGPK.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(PERNR) TYPE  PERSNO
*"             VALUE(BEGDA) TYPE  BEGDA DEFAULT '18000101'
*"             VALUE(ENDDA) TYPE  ENDDA DEFAULT '99991231'
*"             REFERENCE(PP0001) TYPE  /SIE/HR_FTT_P0001 OPTIONAL
*"             VALUE(PP0001_IS_SUPPLIED) TYPE  XFELD DEFAULT SPACE
*"       EXPORTING
*"             VALUE(XPGPK) TYPE  XPGPK
*"----------------------------------------------------------------------
*INFOTYPES: 0008.
DATA BEGIN OF P0001 OCCURS 10.
  INCLUDE STRUCTURE P0001.
DATA END OF P0001 VALID BETWEEN BEGDA AND ENDDA.


  RP-LOW-HIGH.
  IF PP0001_IS_SUPPLIED IS INITIAL.
    CALL FUNCTION 'HR_READ_INFOTYPE'
         EXPORTING
              PERNR           = PERNR
              INFTY           = '0001'
              BEGDA           = LOW_DATE
              ENDDA           = HIGH_DATE
         TABLES
              INFTY_TAB       = P0001
         EXCEPTIONS
              INFTY_NOT_FOUND = 1
              OTHERS          = 2.
  ELSE.
    LOOP AT PP0001 INTO P0001.
      APPEND P0001.
    ENDLOOP.
  ENDIF.
  PROVIDE PERSG PERSK FROM P0001 BETWEEN BEGDA AND ENDDA.
    CONCATENATE P0001-PERSG P0001-PERSK INTO XPGPK.
  ENDPROVIDE.
ENDFUNCTION.
