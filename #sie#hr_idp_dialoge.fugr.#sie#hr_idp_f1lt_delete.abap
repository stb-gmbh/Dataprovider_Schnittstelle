FUNCTION /SIE/HR_IDP_F1LT_DELETE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(FELDNAME) TYPE  /SIE/HR_IDP_FNAME
*"----------------------------------------------------------------------
    DELETE FROM /SIE/HR_IDP_F1LT WHERE FELDNAME = FELDNAME.

ENDFUNCTION.
