function /sie/hr_i_scd_account.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(PERNR) TYPE  PERSNO
*"     REFERENCE(BEGDA) TYPE  BEGDA DEFAULT '18000101'
*"     REFERENCE(ENDDA) TYPE  ENDDA DEFAULT '99991231'
*"     REFERENCE(PP0001) TYPE  /SIE/HR_FTT_P0001
*"     REFERENCE(PP0001_IS_SUPPLIED) TYPE  XFELD DEFAULT SPACE
*"  EXPORTING
*"     VALUE(GB_IT_ACCOUNT) TYPE  CHAR1
*"----------------------------------------------------------------------
***********************************************************************************
* Funktionsbaustein für das Merkmale Kennzeichen Account / non Account (GB_IT_ACCOUNT).
* Die Belegung des Merkmals GB_IT_ACCOUNT erfolgt nur für Mitarbeiter des Sectors Energy
*  (VDSK1 = E*), für alle anderen Sectoren bleibt das Merkmal unbelegt.
* Zu betrachten sind der aktuelle wie auch zukünftige Beschäftigungszeiträume.
* Mit der für den Ausgabezeitraum gültigen Planstelle ist in der OrgManagement-Tabelle
* HRP1002 im Subtyp 0001 die TABNR zu ermitteln.
* Mit dieser TABNR ist in der Tabelle HRT1002 die zugehörige TLINE zu ermitteln.
* Wenn in der 1. Stelle der TLINE = #a *# gefunden wird ist das Merkmal GB_IT_ACCOUNT
* mit #a# für Account zu belegen ansonsten ist das Merkmal GB_IT_ACCOUNT mit #n# für
* non Ac-count zu belegen.
* CR 48391 Der Funktionsbaustein /SIE/HR_I_SCD_ACCOUNT  für das Kennzeichen
*  #Account# / #non Account# Ist zu erweitern um die Abfrage auf
*  VDSK1 = DWP*, DEM*, DPS*, DPG*, YSE* und Z*.
***********************************************************************************

  data p0001 type table of p0001 with header line.
  data lv_tline type hrt1002-tline.
  data lv_tabnr type hrp1002-tabnr.
  rp-low-high.

* Infotyp 0000 bei Bedarf nachlesen
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
  rp-provide-from-last p0001 space begda endda.

*  check p0001-vdsk1 cp 'E*'. "fall kein Energy MA dann bleibt leer
* check p0001-vdsk1 cp 'DWP*'.
* check p0001-vdsk1 cp 'DEM*'.
* check p0001-vdsk1 cp 'DPS*'.
* check p0001-vdsk1 cp 'DPG*'.
* check p0001-vdsk1 cp 'YSE*'.
* check p0001-vdsk1 cp 'Z*'.

  if  p0001-vdsk1 cp 'E*' or
      p0001-vdsk1 cp 'DWP*' or
      p0001-vdsk1 cp 'DEM*' or
      p0001-vdsk1 cp 'DPS*' or
      p0001-vdsk1 cp 'DPG*' or
      p0001-vdsk1 cp 'YSE*' or
      p0001-vdsk1 cp 'Z*'.

    data lv_select_date type begda.
    if p0001-begda le sy-datum and p0001-endda ge sy-datum.
      lv_select_date = sy-datum.
    elseif begda gt sy-datum.
      lv_select_date = p0001-begda.
    else.
      lv_select_date = p0001-endda.
    endif.

    clear lv_tabnr.
"<<<< BEG of conversion
  "  select single tabnr from hrp1002 into lv_tabnr
  "    where plvar = '01' and
  "          otype = 'S' and
  "          objid = p0001-plans and
  "          subty = '0001' and
  "          begda le lv_select_date  and
  "          endda ge lv_select_date.
    select tabnr
      from hrp1002
      into lv_tabnr
      UP TO 1 ROWS
      where plvar = '01'
        and otype = 'S'
        and objid = p0001-plans
        and subty = '0001'
        and begda le lv_select_date
        and endda ge lv_select_date
      ORDER BY PRIMARY KEY.
     ENDSELECT.
">>>> END of conversion
" 15.02.2023 M.Krzywda ATC findings C2C correction
    if lv_tabnr is not initial.
      select tline from hrt1002 into lv_tline
        where tabnr eq lv_tabnr.
        if lv_tline cp 'a *' or lv_tline eq 'a'.
          gb_it_account = 'a'.
          exit.                                       "#EC CI_NOORDER
        endif.
      endselect.
    endif.

    if gb_it_account is initial.
      gb_it_account = 'n'.
    endif.

  endif.

endfunction.
