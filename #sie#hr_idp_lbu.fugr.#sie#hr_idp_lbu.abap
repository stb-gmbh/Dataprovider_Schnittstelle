FUNCTION /SIE/HR_IDP_LBU.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(PERSN) TYPE  PERSNO
*"     VALUE(BEGDA) TYPE  BEGDA DEFAULT '18000101'
*"     VALUE(ENDDA) TYPE  ENDDA DEFAULT '99991231'
*"     VALUE(PPARAM) TYPE  CHAR4 DEFAULT 'H'
*"     VALUE(NO_NUMERIC) TYPE  CHAR1 DEFAULT SPACE
*"  EXPORTING
*"     VALUE(OBJID) TYPE  OBJEKTID
*"     VALUE(STEXT) TYPE  STEXT
*"     VALUE(GUELTIG_AB) TYPE  BEGDA
*"     VALUE(GUELTIG_BIS) TYPE  ENDDA
*"     VALUE(PNKTE) TYPE  /SIE/HR_LB_PUNKTE
*"     VALUE(ERGEBNIS) TYPE  RATING1
*"     VALUE(BEWERTUNG) TYPE  /SIE/HR_FD_LBU_BEWERTUNG
*"     VALUE(BEWERTUNG_LANG) TYPE  /SIE/HR_FD_LBU_BEWERTUNG_LANG
*"     VALUE(PUNKTE_INDGEW) TYPE  APP_CALC_RESULT
*"     VALUE(STATUS) TYPE  APPRAISAL_STATUS
*"     VALUE(BEURTEILUNG) TYPE  /SIE/HR_FT_PT1045
*"----------------------------------------------------------------------
TRY.
CALL METHOD /sie/hr_pm_cl_lbu=>get_last_lb
  EXPORTING
    persn          = PERSN
    begda          = begda
    endda          = endda
    pparam         = pparam
    no_numeric     = NO_NUMERIC
  IMPORTING
    objid          = objid
    stext          = stext
    gueltig_ab     = gueltig_ab
    gueltig_bis    = gueltig_bis
    pnkte          = pnkte
    ergebnis       = ergebnis
    bewertung      = bewertung
    bewertung_lang = bewertung_lang
    punkte_indgew  = punkte_indgew
    status         = status
    beurteilung    = beurteilung.
 CATCH zcx_sie_pm_lbu_error .
ENDTRY.
ENDFUNCTION.
