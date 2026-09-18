FUNCTION /SIE/HR_IDP_C_SATZART.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(P_IN)
*"             VALUE(P_PARAMETERS) TYPE  /SIE/HR_IDP_KONVPARA
*"                             OPTIONAL
*"       EXPORTING
*"             VALUE(P_OUT)
*"----------------------------------------------------------------------

  MOVE P_IN TO P_OUT.
ENDFUNCTION.
