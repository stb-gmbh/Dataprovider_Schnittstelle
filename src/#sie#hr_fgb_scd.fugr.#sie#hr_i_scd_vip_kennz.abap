function /sie/hr_i_scd_vip_kennz.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(PERNR) TYPE  PERSNO
*"     REFERENCE(BEGDA) TYPE  BEGDA DEFAULT '18000101'
*"     REFERENCE(ENDDA) TYPE  ENDDA DEFAULT '99991231'
*"     REFERENCE(PP0001) TYPE  /SIE/HR_FTT_P0001
*"     REFERENCE(PP0001_IS_SUPPLIED) TYPE  XFELD DEFAULT SPACE
*"  EXPORTING
*"     VALUE(GB_VIP) TYPE  CHAR1
*"----------------------------------------------------------------------
***********************************************************************************
* Funktionsbaustein für  das Merkmal Kennzeichen VIP (GB_VIP).
* Zu betrachten sind der aktuelle wie auch zukünftige Beschäftigungszeiträume.
* Belegung des Merkmals mit #X# erfolgt, wenn
* - VDSK1 = C* und Stelle = 63669
*  oder
* - VDSK1 = V*

***********************************************************************************

  data p0001 type table of p0001 with header line.
  data lv_energy_ma type flag.
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

  rp-provide-from-last p0001 space begda endda.
  if p0001-vdsk1 cp 'V*' or
    ( p0001-vdsk1 cp 'C*' and p0001-stell eq '63669' ) or
    ( p0001-vdsk1 cp 'C*' and p0001-stell eq '70784' ) or
    ( p0001-vdsk1 cp 'C*' and p0001-stell eq '00070784' ) or
    ( p0001-vdsk1 cp 'C*' and p0001-stell eq '00063669' ).
    gb_vip = 'X'.
  endif.

endfunction.
