function /sie/hr_i_scd_delegate.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(PERNR) TYPE  PERSNO
*"     REFERENCE(BEGDA) TYPE  BEGDA DEFAULT '18000101'
*"     REFERENCE(ENDDA) TYPE  ENDDA DEFAULT '99991231'
*"     REFERENCE(PP0000) TYPE  /SIE/HR_FTT_P0000
*"     REFERENCE(PP0000_IS_SUPPLIED) TYPE  XFELD DEFAULT SPACE
*"     REFERENCE(PP0001) TYPE  /SIE/HR_FTT_P0001
*"     REFERENCE(PP0001_IS_SUPPLIED) TYPE  XFELD DEFAULT SPACE
*"  EXPORTING
*"     VALUE(GB_DELEGATION) TYPE  CHAR1
*"----------------------------------------------------------------------
***********************************************************************************
* Zu betrachten sind der aktuelle wie auch zukünftige Beschäftigungszeiträume.
* Bei Belegung des Status Sonderzahlung (STAT3) = 2 ist das Merkmal GB_DELEGATION
* mit #X# zu belegen. In allen anderen Fällen bleibt das Merkmal unbelegt.
***********************************************************************************

  data p0000 type table of p0000 with header line.
    data p0001 type table of p0001 with header line.
  rp-low-high.

* Infotyp 0000 bei Bedarf nachlesen
  if pp0000_is_supplied is initial.
    call function '/SIE/HR_READ_INFOTYPE'
      exporting
        pernr           = pernr
        infty           = '0000'
      tables
        infty_tab       = p0000
      exceptions
        infty_not_found = 1
        others          = 2.
  else.
    loop at pp0000 into p0000.
      append p0000.
    endloop.
  endif.


* Infotyp 0001 bei Bedarf nachlesen
  if pp0001_is_supplied is initial.
    call function '/SIE/HR_READ_INFOTYPE'
      exporting
        pernr           = pernr
        infty           = '0001'
      tables
        infty_tab       = p0001
      exceptions
        infty_not_found = 1
        others          = 2.
  else.
    loop at pp0001 into p0001.
      append p0001.
    endloop.
  endif.

  rp-provide-from-last p0001 space begda endda.
* neu begin

*  data lv_select_date type begda.
*  if p0001-begda le sy-datum and p0001-endda ge sy-datum.
*    lv_select_date = sy-datum.
*  elseif p0001-begda gt sy-datum.
*    lv_select_date = p0001-begda.
*  else.
*    lv_select_date = p0001-endda.
*  endif.
*
*
*  loop at p0000 where endda ge lv_select_date and begda le lv_select_date.
*    if p0000-stat3 eq '2'.
*      gb_delegation = 'X'.
*      exit.
*    endif.
*  endloop.

  data lv_select_date type begda.
  if p0001-begda le sy-datum and p0001-endda ge sy-datum.
    lv_select_date = sy-datum.
  elseif p0001-begda gt sy-datum.
    lv_select_date = p0001-begda.
  else.
    lv_select_date = p0001-endda.
  endif.


  loop at p0000 where endda ge lv_select_date. " and begda le lv_select_date.
    if p0000-stat3 eq '2'.
      gb_delegation = 'X'.
      exit.
    endif.
  endloop.

*neu ende

endfunction.
