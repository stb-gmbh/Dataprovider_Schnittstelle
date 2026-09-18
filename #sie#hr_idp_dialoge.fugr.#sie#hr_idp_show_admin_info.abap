FUNCTION /SIE/HR_IDP_SHOW_ADMIN_INFO.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(ADMIN) TYPE  /SIE/HR_IDP_ADM
*"----------------------------------------------------------------------

  MOVE-CORRESPONDING ADMIN TO /SIE/HR_IDP_ADM.

  CALL SCREEN 1000 STARTING AT 7 7.

ENDFUNCTION.
