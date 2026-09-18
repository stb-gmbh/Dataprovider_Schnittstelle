FUNCTION /SIE/HR_IDP_F4_GET_IDENT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       TABLES
*"              SHLP_TAB TYPE  SHLP_DESCR_TAB_T
*"              RECORD_TAB STRUCTURE  SEAHLPRES
*"       CHANGING
*"             VALUE(SHLP) TYPE  SHLP_DESCR_T
*"             VALUE(CALLCONTROL) LIKE  DDSHF4CTRL
*"                             STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------

  CHECK CALLCONTROL-STEP = 'SELECT'.

  CLEAR RECORD_TAB[].

  SELECT /SIE/HR_IDP_F1T~FELDNAME /SIE/HR_IDP_F1T~IDENT
    INTO  (RECORD_TAB(20), RECORD_TAB+20(60))
    FROM  /SIE/HR_IDP_F1T INNER JOIN /SIE/HR_IDP_F1S
    ON    /SIE/HR_IDP_F1T~FELDNAME = /SIE/HR_IDP_F1S~FELDNAME
    WHERE /SIE/HR_IDP_F1T~SPRAS EQ SY-LANGU.
    APPEND RECORD_TAB.
  ENDSELECT.

* Wenn OK, dann soll die Hilfefunktion mit der Anzeige fortfahren
  DESCRIBE TABLE RECORD_TAB.
  IF SY-TFILL EQ 0.
    CALLCONTROL-STEP = 'EXIT'.
  ELSE.
    CALLCONTROL-STEP = 'DISP'.
    IF SY-TCODE EQ C_DISP_TCOD.
      CALLCONTROL-DISPONLY = 'X'.
    ENDIF.
  ENDIF.

ENDFUNCTION.
