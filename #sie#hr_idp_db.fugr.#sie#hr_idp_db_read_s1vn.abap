FUNCTION /SIE/HR_IDP_DB_READ_S1VN.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(INTERFACE) TYPE  /SIE/HR_IDP_INTERFACE_ID
*"       EXPORTING
*"             VALUE(INTERFACE_DATA) TYPE  /SIE/HR_IDP_IFC_HEAD
*"       EXCEPTIONS
*"              NO_DATA
*"----------------------------------------------------------------------

  DATA: ITAB_S1VN TYPE /SIE/HR_IDP_TT_S1VN
      , ITAB_S1F TYPE /SIE/HR_IDP_TT_S1F
      .

  CLEAR ITAB_S1VN[].
  SELECT * FROM /SIE/HR_IDP_S1VN INTO TABLE ITAB_S1VN
           WHERE IFCID = INTERFACE.
  IF SY-SUBRC = 0.
    SORT ITAB_S1VN BY VRSNR DESCENDING.
    INTERFACE_DATA-S1VN = ITAB_S1VN.
  ELSE.
    CLEAR ITAB_S1VN[].
    MESSAGE E101(/SIE/HR_IDP_MESSAGES) WITH INTERFACE RAISING NO_DATA.
*   Die Schnittstelle &1 wurde noch nicht angelegt.
  ENDIF.

  CLEAR ITAB_S1F[].
  SELECT * FROM /SIE/HR_IDP_S1F INTO TABLE ITAB_S1F
           WHERE IFCID = INTERFACE
           ORDER BY PRIMARY KEY. " wg Hana
  IF SY-SUBRC = 0.
    INTERFACE_DATA-S1F = ITAB_S1F.
  ELSE.
    CLEAR ITAB_S1F.
    MESSAGE E101(/SIE/HR_IDP_MESSAGES) WITH INTERFACE RAISING NO_DATA.
*   Die Schnittstelle &1 wurde noch nicht angelegt.
  ENDIF.

ENDFUNCTION.
