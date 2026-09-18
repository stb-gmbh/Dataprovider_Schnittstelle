FUNCTION /SIE/HR_IDP_PRESELECTION.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------

  DATA BEGIN OF h_itab OCCURS 0.
  DATA position TYPE dd03l-position.
  DATA fieldname TYPE dd03l-fieldname.
  DATA END OF h_itab.

  DATA  tabname1 TYPE tabname.
  DATA  fieldname1 TYPE dd03l-fieldname.
  DATA  pattern1 TYPE dd03l-fieldname.

  IF callcontrol-step = 'SELECT'.

    h_itab-position = '0'.
    h_itab-fieldname = '&PNPBEGDA&'.
    APPEND h_itab.

    h_itab-position = '0'.
    h_itab-fieldname = '&PNPENDDA&'.
    APPEND h_itab.

    h_itab-position = '0'.
    h_itab-fieldname = '&PNPBEGPS&'.
    APPEND h_itab.

    h_itab-position = '0'.
    h_itab-fieldname = '&PNPENDPS&'.
    APPEND h_itab.

    h_itab-position = '0'.
    h_itab-fieldname = '&PIF_DATE&'.
    APPEND h_itab.
    CALL FUNCTION 'F4UT_RESULTS_MAP'
      TABLES
        shlp_tab          = shlp_tab
        record_tab        = record_tab
        source_tab        = h_itab
      CHANGING
        shlp              = shlp
        callcontrol       = callcontrol
      EXCEPTIONS
        illegal_structure = 1
        OTHERS            = 2.
    IF sy-subrc <> 0.
      callcontrol-step = 'EXIT'.
    ELSE.
      callcontrol-step = 'DISP'.
    ENDIF.
    EXIT.
  ENDIF.

ENDFUNCTION.
