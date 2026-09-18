FUNCTION /sie/hr_idp_preselect_tab4.
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
*  DATA tabname TYPE dd03l-tabname.
  DATA fieldname TYPE dd03l-fieldname.
  DATA END OF h_itab.

  DATA  tabname4 TYPE tabname.

  IF callcontrol-step = 'SELECT'.
    IMPORT tabname4 FROM MEMORY ID '/SIE/HR_IDP_PRESEL4'.
*    IMPORT tabname4  FROM MEMORY ID '/SIE/HR_IDP_PRESEL'.
    IF tabname4 CP 'PA*'.
      SELECT * FROM dd03l
          INTO CORRESPONDING FIELDS OF TABLE h_itab
        WHERE tabname = tabname4 AND
              fieldname NOT IN
        ('.INCLUDE', 'HISTO', 'ITXEX', 'REFEX', 'ORDEX', 'ITBLD', 'FLAG1',
         'FLAG2', 'FLAG3', 'FLAG4', 'RESE1', 'RESE2', 'GRPVL')
        ORDER BY position.
    ELSE.
      SELECT * FROM dd03l
        INTO CORRESPONDING FIELDS OF TABLE h_itab
      WHERE tabname = tabname4 AND
            fieldname NE '.INCLUDE'
      ORDER BY position.
    ENDIF.

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
