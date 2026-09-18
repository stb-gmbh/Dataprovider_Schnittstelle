FUNCTION /SIE/HR_IDP_SHLP_BAUMSUCHE.
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

  DATA: L_SELECTED_FIELDS
        TYPE STANDARD TABLE OF /SIE/HR_IDP_F4_SEL_FIELDS
        INITIAL SIZE 0 WITH HEADER LINE
      , WA_SHLP TYPE DDSHFPROP
      , GRTYP TYPE /SIE/HR_IDP_GRKEY
      , DPFTYPE TYPE /SIE/HR_IDP_FTYPE
      , L_FL TYPE XFLAG
      .

  STATICS: SHOW_FIELD TYPE TEXT60.

  CHECK CALLCONTROL-STEP = 'SELECT' OR CALLCONTROL-STEP = 'DISP'.

*"----------------------------------------------------------------------
* STEP SELECT    (Select values)
*"----------------------------------------------------------------------
  IF CALLCONTROL-STEP = 'SELECT'.

    READ TABLE SHLP-FIELDPROP INTO WA_SHLP WITH KEY FIELDNAME = 'GRTYP'.
    CASE WA_SHLP-DEFAULTVAL+1(1).
      WHEN 1.
        GRTYP = '1'.
      WHEN 2.
        GRTYP = '2'.
      WHEN OTHERS.
    ENDCASE.

    READ TABLE SHLP-FIELDPROP INTO WA_SHLP
                              WITH KEY FIELDNAME = 'DPFTYPE'.
    DPFTYPE = WA_SHLP-DEFAULTVAL+1(1).

    READ TABLE SHLP-FIELDPROP INTO WA_SHLP
                              WITH KEY FIELDNAME = 'KZHDFT'.
    G_KZHDFT = WA_SHLP-DEFAULTVAL+1(1).

    L_FL = CALLCONTROL-DISPONLY.

    EXPORT SHOW_FIELD TO MEMORY ID '/SIE/HR_IDP_IFC'.

    CALL FUNCTION '/SIE/HR_IDP_F4_TREE'
         EXPORTING
              GRTYP           = GRTYP
              FL_DISPLAY      = L_FL
              FL_HEADER       = G_KZHDFT
         TABLES
              SELECTED_FIELDS = L_SELECTED_FIELDS.
    DESCRIBE TABLE L_SELECTED_FIELDS.
    IF SY-TFILL = 0.
      CALLCONTROL-STEP = 'EXIT'.
    ELSE.
* Nur einen Eintrag einlesen. Es sollte auch nur einen übergeben
* worden sein.
      CLEAR RECORD_TAB.
      READ TABLE L_SELECTED_FIELDS INDEX 1 INTO RECORD_TAB-STRING.
      APPEND RECORD_TAB.
      SHOW_FIELD = RECORD_TAB-STRING.
      CALLCONTROL-RETALLFLDS = 'X'.
      CALLCONTROL-STEP = 'RETURN'.
    ENDIF.
    EXIT.
  ENDIF.
ENDFUNCTION.
