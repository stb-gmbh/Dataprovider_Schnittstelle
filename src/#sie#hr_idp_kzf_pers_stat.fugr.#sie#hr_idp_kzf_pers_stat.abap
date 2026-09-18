function /sie/hr_idp_kzf_pers_stat.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(PERNR) TYPE  PERSNO
*"     VALUE(BEGDA) TYPE  BEGDA DEFAULT '18000101'
*"     VALUE(ENDDA) TYPE  ENDDA DEFAULT '99991231'
*"     VALUE(PP0001) TYPE  /SIE/HR_FTT_P0001 OPTIONAL
*"     VALUE(PP0001_IS_SUPPLIED) TYPE  XFELD DEFAULT SPACE
*"  EXPORTING
*"     VALUE(KZF_PERS_STAT) TYPE  CHAR1
*"----------------------------------------------------------------------

  data p0001 type table of p0001 with header line.


  rp-low-high.

* Infotyp 0001 bei Bedarf nachlesen
  if pp0001_is_supplied is initial.
    call function '/SIE/HR_READ_INFOTYPE'
      exporting
        pernr           = pernr
        infty           = '0001'
        begda           = begda
        endda           = endda
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
  perform get_empl_type
              using
                 p0001-persg
                 p0001-persk
              changing
                 kzf_pers_stat.

endfunction.

*&---------------------------------------------------------------------*
*&      Form  get_empl_type
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PERSG        Mitarbeitergruppe
*      -->P_PERSK        Mitarbeiterkreis
*      -->p_ma_kennz Kennzeichnung der Zugehörigkeit des Mitarbeiters
*----------------------------------------------------------------------*
form get_empl_type
                using
                   p_persg
                   p_persk
                changing
                   p_ma_kennz.

  data:    wa_map_empl_type type /sie/hr_iempkenz.
  statics: ta_map_empl_type type table of /sie/hr_iempkenz.

*  Mappingtabelle für  lesen und puffern
  if ta_map_empl_type[] is initial.
    select * from /sie/hr_iempkenz
             into table ta_map_empl_type.
  endif.

  read table ta_map_empl_type into wa_map_empl_type
                             with key persg = p_persg
                                      persk = p_persk.

  if sy-subrc = 0.
    p_ma_kennz = wa_map_empl_type-kzf_pers_stat.
  else.
*    falls nicht gefunden dann mit Stern versuchen
    read table ta_map_empl_type into wa_map_empl_type
                               with key persg = p_persg
                                        persk = '*'.
    if sy-subrc = 0.
      p_ma_kennz = wa_map_empl_type-kzf_pers_stat.
    else.
      p_ma_kennz = 0.
    endif.
  endif.

endform.                    "get_empl_type
