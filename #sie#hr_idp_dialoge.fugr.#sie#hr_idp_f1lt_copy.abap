FUNCTION /SIE/HR_IDP_F1LT_COPY.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(FELDNAME) TYPE  /SIE/HR_IDP_FNAME
*"             VALUE(VORLAGE) TYPE  /SIE/HR_IDP_FNAME
*"----------------------------------------------------------------------
  DATA: WA_F1LT   TYPE /SIE/HR_IDP_F1LT.
  SELECT * FROM /SIE/HR_IDP_F1LT INTO WA_F1LT
           WHERE FELDNAME = FELDNAME
    ORDER BY PRIMARY KEY.
  ENDSELECT.
  CHECK SY-SUBRC = 4.
  SELECT * FROM /SIE/HR_IDP_F1LT INTO WA_F1LT
           WHERE FELDNAME = VORLAGE
        ORDER BY PRIMARY KEY.
    WA_F1LT-FELDNAME = FELDNAME.
    INSERT INTO /SIE/HR_IDP_F1LT  VALUES WA_F1LT.
  ENDSELECT.
ENDFUNCTION.
