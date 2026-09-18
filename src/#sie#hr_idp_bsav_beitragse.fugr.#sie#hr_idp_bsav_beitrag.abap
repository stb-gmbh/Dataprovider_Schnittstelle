FUNCTION /sie/hr_idp_bsav_beitrag.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(PERSN) TYPE  PERSNO
*"     VALUE(BEGDA) TYPE  BEGDA DEFAULT '18000101'
*"     VALUE(ENDDA) TYPE  ENDDA DEFAULT '99991231'
*"     REFERENCE(PP0202) TYPE  /SIE/HR_FTT_P0202 OPTIONAL
*"     VALUE(PP0202_IS_SUPPLIED) TYPE  XFELD OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_STDBEIT) TYPE  MAXBT
*"     REFERENCE(E_STDBEIT_RAW) TYPE  MAXBT
*"     REFERENCE(BBVON) TYPE  /SIE/HR_BAV_BSAV_BBVON
*"     REFERENCE(BBBIS) TYPE  /SIE/HR_BAV_BSAV_BBBIS
*"     REFERENCE(BGPRZ) TYPE  /SIE/HR_BAV_BSAV_BGPRZ
*"----------------------------------------------------------------------

  DATA: p0202 TYPE TABLE OF p0202 WITH HEADER LINE,
  ewa_bgw TYPE /sie/hr_bav_bgw,
  v_geper TYPE p01c_geper,
  v_ltrgr TYPE p0202-ltrgr.

* Infotyp 0035 bei Bedarf nachlesen
  IF pp0202_is_supplied IS INITIAL.
    CALL FUNCTION '/SIE/HR_READ_INFOTYPE'
      EXPORTING
        pernr           = persn
        infty           = '0202'
      TABLES
        infty_tab       = p0202
      EXCEPTIONS
        infty_not_found = 1
        OTHERS          = 2.
  ELSE.
    LOOP AT pp0202 INTO p0202.
      APPEND p0202.
    ENDLOOP.
  ENDIF.

*Schritt 1
*Ermittlung Leistungsträger pro PERNR aus IT0202
*Selektion für heutigen Tag (pn-begda, pn-endda aus SAP DP Programm) Feld mitst = 1
*subtyp im Range 6000 bis 7005
*Leistungsträger kann ermittelt werden, ansonsten
*für die Lieferung von BSAV-Daten nicht relevant.

  LOOP AT p0202 WHERE mitst EQ '1' AND
                      subty GE '6000' AND
                      subty LE '7005' AND
                      begda LE endda AND
                      endda GE begda.
    IF p0202-ltrgr IS NOT INITIAL.
      v_ltrgr = p0202-ltrgr.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF v_ltrgr IS INITIAL.
    RETURN. "fuba gibt nichts aus
  ENDIF.

*2) Ermittlung Geschäftsperiode für den im oberen Schritt ermittelten Leistungsträger mit Fuba  /SIE/HR_BAV_BSAV_LTRGR2GJAHR


  CALL FUNCTION '/SIE/HR_BAV_BSAV_LTRGR2GJAHR'
    EXPORTING
      i_ltrgr               = v_ltrgr
      i_begda               = begda
      i_endda               = endda
   IMPORTING
*   E_GJBEG               =
*   E_GJEND               =
     e_geper               = v_geper
   EXCEPTIONS
     intervall_error       = 1
     t5dc3_error           = 2
     multi_gjahr           = 3
     OTHERS                = 4.
  IF sy-subrc <> 0.

  ENDIF.

*3) anschließend Ermittlung Anfang und Ende des GJ für Leistungsträger
*und Geschäftsperiode mit Funktionsbaustein   /SIE/HR_BAV_BSAV_READ_VWS

  DATA chg_table TYPE /sie/hr_bav_vws.

  CALL FUNCTION '/SIE/HR_BAV_BSAV_READ_VWS'
    EXPORTING
      imp_geper      = v_geper
      imp_lursp      = v_ltrgr
    CHANGING
      chg_table      = chg_table
    EXCEPTIONS
      no_entry_found = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*
*4) Aufruf des Fuba /sie/hr_bav_bsav_uet_stdbeit mit Parametern Ende und Beginn des Geschäftsjahres
  CALL FUNCTION '/SIE/HR_BAV_BSAV_UET_STDBEIT'
    EXPORTING
     it_p0202               = p0202[]
      i_stichtag             = chg_table-endbe
      i_begda                = chg_table-begbe
      i_endda                = chg_table-endbe
      i_pernr                = persn
  IMPORTING
     e_stdbeit              = e_stdbeit
     e_stdbeit_raw          = e_stdbeit_raw
     ewa_bgw                = ewa_bgw
 EXCEPTIONS
   no_jze                 = 1
   besi_error             = 2
   no_vgrgl               = 3
   no_vggrp               = 4
   no_bgw                 = 5
   no_uet                 = 6
   OTHERS                 = 7.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  bbvon = ewa_bgw-bbvon.
  bbbis = ewa_bgw-bbbis.
  bgprz = ewa_bgw-bgprz.



ENDFUNCTION.
