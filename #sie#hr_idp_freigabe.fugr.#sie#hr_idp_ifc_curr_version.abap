FUNCTION /SIE/HR_IDP_IFC_CURR_VERSION.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(INTERFACE) TYPE  /SIE/HR_IDP_INTERFACE_ID
*"             VALUE(ACTIVE) TYPE  CHAR1 DEFAULT SPACE
*"       EXPORTING
*"             VALUE(VERSION) TYPE  /SIE/HR_IDP_VERS_NR
*"       EXCEPTIONS
*"              NO_ACTIVE_VERSION
*"----------------------------------------------------------------------

  DATA: FL_ALL_OK TYPE X.
  FL_ALL_OK = 0.
  IF ACTIVE = SPACE.
    PERFORM IFC_CURR_VERS USING INTERFACE
                          CHANGING FL_ALL_OK
                                   VERSION.

    IF FL_ALL_OK = 8.
    ELSE.
    ENDIF.
  ELSE.
    SELECT SINGLE * FROM /SIE/HR_IDP_S1 WHERE IFCID = INTERFACE.
    IF SY-SUBRC = 0.
* Überprüfen ob die Version auch freigegeben worden ist.
      SELECT SINGLE * FROM /SIE/HR_IDP_S1F WHERE IFCID = INTERFACE
                                 AND VRSNR = /SIE/HR_IDP_S1-ACT_VERS_NR
                                     AND TROLE = '06'.
      IF SY-SUBRC >< 0.
        RAISE NO_ACTIVE_VERSION.
      ELSE.
        IF NOT ( /SIE/HR_IDP_S1F-CH_DATUM IS INITIAL ).
          VERSION = /SIE/HR_IDP_S1-ACT_VERS_NR.
        ELSE.
          RAISE NO_ACTIVE_VERSION.
        ENDIF.
      ENDIF.
    ELSE.
      RAISE NO_ACTIVE_VERSION.
    ENDIF.
  ENDIF.
ENDFUNCTION.
