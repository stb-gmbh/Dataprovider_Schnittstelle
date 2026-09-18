FUNCTION /sie/hr_fgb_grip_position_51.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(PERNR) TYPE  PERSNO
*"     VALUE(BEGDA) TYPE  BEGDA DEFAULT '18000101'
*"     VALUE(ENDDA) TYPE  ENDDA DEFAULT '99991231'
*"     VALUE(PP0001) TYPE  /SIE/HR_FTT_P0001 OPTIONAL
*"     VALUE(PP0001_IS_SUPPLIED) TYPE  XFELD DEFAULT SPACE
*"     VALUE(PP0000) TYPE  /SIE/HR_FTT_P0000 OPTIONAL
*"     VALUE(PP0000_IS_SUPPLIED) TYPE  XFELD DEFAULT SPACE
*"  EXPORTING
*"     VALUE(GRIP_POSITION) TYPE  TEXT20
*"----------------------------------------------------------------------


  DATA  pnp-sw-found(1).
  DATA  pnp-sy-tabix TYPE sy-tabix.


  CONSTANTS: c_default_grip_position(20) TYPE c VALUE 'ZZ-ZZ-ZZZZZZZ-ZZ999',
             c_aplvar                    TYPE plvar VALUE '01',         "Planvariante
             c_gr_stelle                 TYPE objid VALUE '00070000',  "erste GRIP-Stelle
             c_gr_otype                  TYPE otype VALUE 'C',          "Objekttyp Stelle
             c_gr_infty                  TYPE infty VALUE '1000'.       "GRIP Infotyp

  DATA v_stichtag TYPE begda.
  DATA: lt_1000 TYPE TABLE OF p1000,
        ls_1000 LIKE LINE OF lt_1000.

  rp-low-high.
  DATA: p0001 TYPE TABLE OF p0001 WITH HEADER LINE.
  DATA: p0000 TYPE TABLE OF p0000 WITH HEADER LINE.

  IF pp0001_is_supplied IS INITIAL.
    CALL FUNCTION '/SIE/HR_READ_INFOTYPE'
      EXPORTING
        pernr           = pernr
        infty           = '0001'
      TABLES
        infty_tab       = p0001
      EXCEPTIONS
        infty_not_found = 1
        OTHERS          = 2.
  ELSE.
    LOOP AT pp0001 INTO p0001.
      APPEND p0001.
    ENDLOOP.
  ENDIF.

  IF pp0000_is_supplied IS INITIAL.
    CALL FUNCTION '/SIE/HR_READ_INFOTYPE'
      EXPORTING
        pernr           = pernr
        infty           = '0000'
      TABLES
        infty_tab       = p0000
      EXCEPTIONS
        infty_not_found = 1
        OTHERS          = 2.
  ELSE.
    LOOP AT pp0000 INTO p0000.
      APPEND p0000.
    ENDLOOP.
  ENDIF.

  v_stichtag = endda.
  rp-provide-from-last p0000 space begda endda.

*dann letzten arbeitstag suchen
  IF p0000-stat1 = '0'.
*    dann ist das ein austritt
    v_stichtag = p0000-begda - 1.
    SORT p0000 DESCENDING BY endda.
    LOOP AT p0000 WHERE stat1 NE '0' AND begda LE v_stichtag.
      v_stichtag = p0000-endda.
      EXIT.
    ENDLOOP.

  ENDIF.

*vorbelegung
  grip_position = c_default_grip_position.

  " letztgültigen Aktien DS in die Kopfzeile
  rp-provide-from-last p0001 '' v_stichtag v_stichtag.
  "falls IT 1 Datensatz gelesen werden konnte
  IF pnp-sw-found EQ '1'.
    IF p0001-stell >= c_gr_stelle.
      "GRIP Infotyp 1000 lesen mit der ermittelten Stelle
      CALL FUNCTION 'RH_PM_READ_INFTY'
        EXPORTING
          act_plvar        = c_aplvar
          act_otype        = c_gr_otype
          act_objid        = p0001-stell
          act_begda        = '20210930'
          act_endda        = '20210930'
          act_infty        = c_gr_infty
        TABLES
          innnn            = lt_1000
        EXCEPTIONS
          no_active_plvar  = 1
          object_not_found = 2
          nothing_found    = 3
          OTHERS           = 4.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      READ TABLE lt_1000 INDEX 1 INTO ls_1000.
      grip_position = ls_1000-stext.
      ENDIF.
    ENDIF.
  ENDFUNCTION.
