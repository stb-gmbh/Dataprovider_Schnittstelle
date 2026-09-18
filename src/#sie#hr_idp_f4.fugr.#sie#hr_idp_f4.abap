FUNCTION /SIE/HR_IDP_F4.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       TABLES
*"              SELECTED_FIELDS STRUCTURE  /SIE/HR_IDP_F4_SEL_FIELDS
*"                             OPTIONAL
*"----------------------------------------------------------------------

  CALL SCREEN 1100 STARTING AT 10 10.

  SELECTED_FIELDS[] = G_SEL_FIELDS[].
ENDFUNCTION.
