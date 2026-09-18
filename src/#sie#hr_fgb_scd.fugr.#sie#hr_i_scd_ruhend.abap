function /sie/hr_i_scd_ruhend.
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
*"     VALUE(GB_BEGDA_RUHEND) TYPE  BEGDA
*"     VALUE(GB_ENDDA_RUHEND) TYPE  ENDDA
*"----------------------------------------------------------------------
***********************************************************************************
*Funktionsbaustein für die Merkmale Beginn- und Endedatum des ruhenden Beschäfti
*-gungsverhältnisses (GB_BEGDA_RUHEND / GB_ENDDA_RUHEND).
*Hierbei kann es sich um ein derzeit aktuelles, wie auch ein zukünftiges ruhendes Beschäfti
*-gungsverhältnis handeln.*Für den Zeitraum des auszugebenden Datensatzes ist zu ermitteln ob der Status Kundenindi
*-viduell (STAT1) =1 ist.
*Wenn STAT1 = 1 ist das Beginn- und Endedatum des ruhenden Beschäftigungsverhältnisses
*in den Merkmalen GB_BEGDA_RUHEND bzw. GB_ENDDA_RUHEND zu übergeben.
***********************************************************************************
  data p0001 type table of p0001 with header line.
  data p0000 type table of p0000 with header line.

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

  clear p0001.
*  neu anfang
  rp-provide-from-last p0001 space begda endda.
  data lv_sel_begda type begda.
*  data lv_sel_endda type endda.
  if p0001-begda le sy-datum.
    lv_sel_begda = sy-datum.
*    lv_sel_endda = sy-datum.
*    rp-provide-from-last p0001 space sy-datum sy-datum.
  else.
    lv_sel_begda = p0001-begda.
*    lv_sel_endda = p0001-endda.
*    rp-provide-from-last p0001 space begda endda.
  endif.
*  rp-provide-from-last p0001 space lv_sel_begda lv_sel_endda.
*  neu ende



*  neu anfang
*data lv_0000_sel_date type begda.
*if lv_sel_begda le sy-datum.
*  lv_0000_sel_date = sy-datum.
*  else.
* lv_0000_sel_date = p0001-begda.
*endif.
*  loop at p0000 where endda ge p0001-begda.
  loop at p0000 where endda ge lv_sel_begda.
*  neu ende

    if p0000-stat1 eq '1' and gb_begda_ruhend is initial.
      gb_begda_ruhend = p0000-begda.
    endif.

    if p0000-stat1 eq '1'.
      gb_endda_ruhend = p0000-endda.
    endif.

    if p0000-stat1 ne '1' and gb_begda_ruhend is not initial.
      gb_endda_ruhend = p0000-begda - 1.
      exit.
    endif.

  endloop.

  if gb_begda_ruhend is not initial.

    sort p0000 by begda descending.

    loop at p0000 where endda lt gb_begda_ruhend.
      if p0000-stat1 eq '1'.
        gb_begda_ruhend = p0000-begda.
      else.
        exit.
      endif.
    endloop.

  else.
    clear gb_endda_ruhend.
  endif.

*  neu anfang
  clear p0001.
  rp-provide-from-last p0001 space begda endda.
  if p0001-begda is not initial.
    if gb_endda_ruhend lt p0001-begda.
      clear: gb_endda_ruhend, gb_begda_ruhend.
    endif.
  endif.
*  if gb_endda_ruhend is not initial. "existiert ein ruhendes BV mit ende in endde in zukunft oder heute
*    if p0001-begda le gb_endda_ruhend and p0001-endda ge gb_begda_ruhend.
*    else.
*      clear: gb_endda_ruhend, gb_begda_ruhend.
*    endif.
*  endif.
*  neu ende


endfunction.
