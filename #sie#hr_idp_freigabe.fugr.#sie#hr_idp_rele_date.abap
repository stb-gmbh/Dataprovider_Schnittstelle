FUNCTION /SIE/HR_IDP_RELE_DATE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(VRSNR) TYPE  /SIE/HR_IDP_VERS_NR
*"             VALUE(S1F) TYPE  /SIE/HR_IDP_TT_S1F
*"       EXPORTING
*"             VALUE(RELEASE_UNAME) TYPE  SYUNAME
*"             VALUE(RELEASE_DATE) TYPE  SYDATUM
*"             VALUE(ACCEPT_UNAME) TYPE  SYUNAME
*"             VALUE(ACCEPT_DATE) TYPE  SYDATUM
*"----------------------------------------------------------------------

  DATA: WA TYPE /SIE/HR_IDP_S1F.
* Freigabe
  READ TABLE S1F WITH KEY VRSNR = VRSNR
                          TROLE = '06'  " 'EC NOTEXT
                 INTO WA.
  IF SY-SUBRC = 0.
    RELEASE_DATE = WA-CH_DATUM.
    RELEASE_UNAME = WA-CH_UNAME.
  ELSE.
    CLEAR: RELEASE_DATE, RELEASE_UNAME.
  ENDIF.

* Abnahme
  READ TABLE S1F WITH KEY VRSNR = VRSNR
                          TROLE = '07'  " 'EC NOTEXT
                 INTO WA.
  IF SY-SUBRC = 0.
    ACCEPT_DATE = WA-CH_DATUM.
    ACCEPT_UNAME = WA-CH_UNAME.
  ELSE.
    CLEAR: ACCEPT_DATE, ACCEPT_UNAME.
  ENDIF.

ENDFUNCTION.
