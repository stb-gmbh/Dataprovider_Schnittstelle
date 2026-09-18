FUNCTION /sie/hr_fgb_lbu_sapdp.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(PERNR) TYPE  PERSNO
*"     VALUE(BEGDA) TYPE  BEGDA DEFAULT '18000101'
*"     VALUE(ENDDA) TYPE  ENDDA DEFAULT '99991231'
*"     VALUE(PPARAM) TYPE  CHAR30 DEFAULT 1
*"  EXPORTING
*"     VALUE(MUSTER) TYPE  OBJEKTID
*"     VALUE(BEZEICHNUNG) TYPE  STEXT
*"     VALUE(ANZAHL_KRITERIEN) TYPE  /SIE/HR_PM_EFA_COUNT
*"     VALUE(MUSTERKLASSE) TYPE  /SIE/HR_PM_EFA_CLASS
*"----------------------------------------------------------------------
************************************************************************
*  Änderungen
************************************************************************
  DATA lbu_info TYPE /sie/hr_pm_efa_lbu_inft.
  DATA: ls_lbu_info TYPE LINE OF /sie/hr_pm_efa_lbu_inft,
       error_a  TYPE /sie/hr_pm_efa_errt.

  CALL FUNCTION '/SIE/HR_PM_EFA_LBU'
    EXPORTING
      ppernr         = pernr
*   IMPORTING
*     ERRSTAT        =
    TABLES
      lbu_info       = lbu_info
      error          = error_a.

  READ TABLE lbu_info INTO ls_lbu_info INDEX pparam.
  MUSTER = ls_lbu_info-MUSTER.
BEZEICHNUNG = ls_lbu_info-BEZEICHNUNG.
ANZAHL_KRITERIEN = ls_lbu_info-ANZAHL_KRITERIEN.
MUSTERKLASSE = ls_lbu_info-MUSTERKLASSE.

ENDFUNCTION.
