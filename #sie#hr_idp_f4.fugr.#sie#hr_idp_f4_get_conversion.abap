FUNCTION /SIE/HR_IDP_F4_GET_CONVERSION.
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

  DATA: L_FELDNAME LIKE /SIE/HR_IDP_F1-FELDNAME
      , L_CONVERSION LIKE /SIE/HR_IDP_C1-KONVNAM
      , OFF LIKE SY-FDPOS                 " Offset
      , LEN LIKE SY-FDPOS
      , FAILURE TYPE C
      , BEGIN OF CONVERSION OCCURS 0
      ,  FELDNAME LIKE /SIE/HR_IDP_F1-FELDNAME
      ,  KONVNAM LIKE /SIE/HR_IDP_C1-KONVNAM
      ,  IDENT LIKE /SIE/HR_IDP_C1T-IDENT
      , END OF CONVERSION
      .

  IF CALLCONTROL-STEP = 'SELECT'.
*break-point.
*    call function 'F4UT_PARAMETER_ALLOCATE'
*         exporting
*              parameter   = 'FELDNAME'
*         tables
*              shlp_tab    = shlp_tab
*              record_tab  = record_tab
*         changing
*              shlp        = shlp
*              callcontrol = callcontrol
*         exceptions
*              others      = 3.
*
  ENDIF.

  IF  CALLCONTROL-STEP = 'DISP'.
* break-point.
    CALL FUNCTION 'F4UT_PARAMETER_VALUE_GET'
         EXPORTING
              PARAMETER         = 'FELDNAME'
              OFF_RESULT        = OFF
              LEN_RESULT        = LEN
         TABLES
              SHLP_TAB          = SHLP_TAB
              RECORD_TAB        = RECORD_TAB
              RESULTS_TAB       = CONVERSION
         CHANGING
              SHLP              = SHLP
              CALLCONTROL       = CALLCONTROL
         EXCEPTIONS
              PARAMETER_UNKNOWN = 1
              OTHERS            = 2.
    IF SY-SUBRC <> 0.
      FAILURE = 'X'.
    ENDIF.

*    clear record_tab[].
*
*    select /sie/hr_idp_c1~konvnam /sie/hr_idp_c1t~ident
*      into (record_tab(20), record_tab+20(60))
*      from /sie/hr_idp_c1 inner join /sie/hr_idp_c1t
*      on   /sie/hr_idp_c1t~konvnam = /sie/hr_idp_c1~konvnam
*      where /sie/hr_idp_c1t~spras eq sy-langu.
*      l_conversion = record_tab(20).
*      call function '/SIE/HR_IDP_CHECK_CONVERSION'
*           exporting
*                logical_field  = l_feldname
*                conversion     = l_conversion
*           exceptions
*                not_allowed    = 1
*                type_not_found = 2
*                others         = 3.
*      if sy-subrc <> 0.
*        clear record_tab.
*      else.
*        append record_tab.
*      endif.
*
*    endselect.
*
*
  ENDIF.
* Wenn OK, dann soll die Hilfefunktion mit der Anzeige fortfahren
*  describe table record_tab.
*  if sy-tfill eq 0.
*    callcontrol-step = 'EXIT'.
*  else.
*    callcontrol-step = 'DISP'.
*    if sy-tcode eq c_disp_tcod.
*      callcontrol-disponly = 'X'.
*    endif.
*  endif.

ENDFUNCTION.
