FUNCTION /SIE/HR_IDP_IFC_PRINT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(INTERFACE) TYPE  /SIE/HR_IDP_INTERFACE_ID
*"             VALUE(FORM) TYPE  TDFORM DEFAULT '/SIE/HR_IDP_IFCB'
*"             VALUE(RECEIVERS) LIKE  /SIE/HR_IDP_ROLES
*"                             STRUCTURE  /SIE/HR_IDP_ROLES
*"----------------------------------------------------------------------

  SUBMIT /SIE/HR_IDP_IFC_ALERT
              WITH SO_IFCID EQ INTERFACE        SIGN 'I'
              WITH P_ONLY   EQ 'X'              SIGN 'I'
              WITH P_01     EQ RECEIVERS-R01    SIGN 'I'
              WITH R_01_TO  EQ RECEIVERS-R01_TO SIGN 'I'
              WITH R_01_CC  EQ RECEIVERS-R01_CC SIGN 'I'
              WITH P_02     EQ RECEIVERS-R02    SIGN 'I'
              WITH R_02_TO  EQ RECEIVERS-R02_TO SIGN 'I'
              WITH R_02_CC  EQ RECEIVERS-R02_CC SIGN 'I'
              WITH P_03     EQ RECEIVERS-R03    SIGN 'I'
              WITH R_03_TO  EQ RECEIVERS-R03_TO SIGN 'I'
              WITH R_03_CC  EQ RECEIVERS-R03_CC SIGN 'I'
              WITH P_04     EQ RECEIVERS-R04    SIGN 'I'
              WITH R_04_TO  EQ RECEIVERS-R04_TO SIGN 'I'
              WITH R_04_CC  EQ RECEIVERS-R04_CC SIGN 'I'
              WITH P_05     EQ RECEIVERS-R05    SIGN 'I'
              WITH R_05_TO  EQ RECEIVERS-R05_TO SIGN 'I'
              WITH R_05_CC  EQ RECEIVERS-R05_CC SIGN 'I'
              WITH P_06     EQ RECEIVERS-R06    SIGN 'I'
              WITH R_06_TO  EQ RECEIVERS-R06_TO SIGN 'I'
              WITH R_06_CC  EQ RECEIVERS-R06_CC SIGN 'I'
              WITH P_07     EQ RECEIVERS-R07    SIGN 'I'
              WITH R_07_TO  EQ RECEIVERS-R07_TO SIGN 'I'
              WITH R_07_CC  EQ RECEIVERS-R07_CC SIGN 'I'
              WITH CC       EQ RECEIVERS-CC     SIGN 'I'
              WITH FORM     EQ FORM             SIGN 'I'
              WITH P_SCREEN EQ SPACE            SIGN 'I'
              WITH P_EMAIL  EQ 'X'              SIGN 'I'
              AND RETURN.

ENDFUNCTION.
