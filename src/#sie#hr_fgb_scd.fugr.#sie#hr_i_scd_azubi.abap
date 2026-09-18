function /sie/hr_i_scd_azubi.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(PERNR) TYPE  PERSNO
*"     REFERENCE(BEGDA) TYPE  BEGDA DEFAULT '18000101'
*"     REFERENCE(ENDDA) TYPE  ENDDA DEFAULT '99991231'
*"     REFERENCE(PP0001) TYPE  /SIE/HR_FTT_P0001
*"     REFERENCE(PP0001_IS_SUPPLIED) TYPE  XFELD DEFAULT SPACE
*"     REFERENCE(PP0016) TYPE  /SIE/HR_FTT_P0016
*"     REFERENCE(PP0016_IS_SUPPLIED) TYPE  XFELD DEFAULT SPACE
*"  EXPORTING
*"     VALUE(GB_ENDDA_AZUBI) TYPE  BEGDA
*"----------------------------------------------------------------------
***********************************************************************************
*Funktionsbaustein für Merkmal Endedatum Ausbildungsverhältnis (GB_ENDDA_AZUBI).
*Für den Zeitraum des auszugebenden Datensatzes ist die zugehörige Mitarbeitergruppe zu ermitteln.
*Bei Mitarbeitergruppe = 4 bzw. Konkatenation von MAGR/MAKR = 9/85 und 9/89 ist das
*Vertragsendedatum des befristeten Arbeitsvertrages aus dem IT0016 (Vertragsbestandteile)
*im Merkmal GB_ENDDA_AZUBI zu übergeben.
*In allen anderen Fällen wird das Datum nicht belegt.
***********************************************************************************

  data p0001 type table of p0001 with header line.
  data p0016 type table of p0016 with header line.

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

  if p0001-persg eq '4' or
    ( p0001-persg eq '9' and p0001-persk eq '85' ) or
    ( p0001-persg eq '9' and p0001-persk eq '89' ).

* Infotyp 0016 bei Bedarf nachlesen
    if pp0001_is_supplied is initial.
      call function '/SIE/HR_READ_INFOTYPE'
        exporting
          pernr           = pernr
          infty           = '0016'
        tables
          infty_tab       = p0016
        exceptions
          infty_not_found = 1
          others          = 2.
    else.
      loop at pp0016 into p0016.
        append p0016.
      endloop.
    endif.
    clear p0016.
    rp-provide-from-last p0016 space p0001-begda p0001-endda. "letztgültigen DS aus IT16 zum gültigen IT1-Azubisatz
    GB_ENDDA_AZUBI = p0016-ctedt.
  endif.
endfunction.
