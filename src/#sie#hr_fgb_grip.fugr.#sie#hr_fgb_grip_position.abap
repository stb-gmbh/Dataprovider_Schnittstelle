function /sie/hr_fgb_grip_position.
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
*"     VALUE(FUNCTION_TYPE) TYPE  CHAR1
*"     VALUE(SUB_JOB_FAMILY) TYPE  CHAR3
*"     VALUE(FUNCTION) TYPE  /SIE/HR_PM_POSLANGBEZ
*"----------------------------------------------------------------------
*
*  CRQ37417 Colorado-CHCM-Schnittstelle aha 16.04.2014
*   Bei Austritten ist die Prüfung P0001-STELL < 70000 im Infotyp 0001
*  im dem Zeitraum durchzuführen, wo der Mitarbeiter zuletzt noch
*  aktiv war.
**************************************************************************

  data  pnp-sw-found(1).
  data  pnp-sy-tabix type sy-tabix.
  constants c_default_grip_position(20) type c value 'ZZ-ZZ-ZZZZZZZ-ZZ999'.
  constants: c_aplvar type plvar value '01'.          "Planvariante
  constants: c_dummy type objid value '99999999'.     "Planstelle CR26006

  constants: c_gr_stelle type objid value '00070000',  "erste GRIP-Stelle
             c_gr_otype type otype value 'C',          "Objekttyp Stelle
             c_gr_infty type infty value '9124'.       "GRIP Infotyp

  data v_stichtag type begda.
  data: lt_9124 type table of p9124,
      ls_9124 like line of lt_9124.

  rp-low-high.
  data: p0001 type table of p0001 with header line.
  data: p0000 type table of p0000 with header line.

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

  v_stichtag = endda.
  rp-provide-from-last p0000 space begda endda.

*dann letzten arbeitstag suchen
  if p0000-stat1 = '0'.
*    dann ist das ein austritt
    v_stichtag = p0000-begda - 1.
    sort p0000 descending by endda.
    loop at p0000 where stat1 ne '0' and begda le v_stichtag.
      v_stichtag = p0000-endda.
      exit.
    endloop.

  endif.

*vorbelegung
  grip_position = c_default_grip_position.

  " letztgültigen Aktien DS in die Kopfzeile
  rp-provide-from-last p0001 '' v_stichtag v_stichtag.
  "falls IT 1 Datensatz gelesen werden konnte
  if pnp-sw-found eq '1'.
    if p0001-stell >= c_gr_stelle.
      "GRIP Infotyp 9124 lesen mit der ermittelten Stelle
      call function 'RH_PM_READ_INFTY'
        exporting
          act_plvar        = c_aplvar
          act_otype        = c_gr_otype
          act_objid        = p0001-stell
          act_begda        = v_stichtag
          act_endda        = v_stichtag
          act_infty        = c_gr_infty
        tables
          innnn            = lt_9124
        exceptions
          no_active_plvar  = 1
          object_not_found = 2
          nothing_found    = 3
          others           = 4.
      if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      endif.
        read table lt_9124 index 1 into ls_9124.
        grip_position = ls_9124-grip_smart_code.
        perform get_func_type using grip_position changing function_type.
        perform get_sub_job_family using grip_position changing sub_job_family.
        function = ls_9124-grip_position_lg.
        if function is initial.
          function = 'NOT_APPLICABLE'.
        endif.
    else. "dann handelt es sich doch um die IJS ermittlung ...  p0001-stell < c_gr_stelle.
*      dann hier die ijs felder holen
      data ls_pa0001 type /SIE/HR_FTT_P0001.
*      umschiften, da die untere fubas abweichende tabellenstruktur erwarten
      ls_pa0001[] = p0001[].

      call function '/SIE/HR_FGB_INT_JOBSTRUCTURE_N'
        exporting
          persn                    = pernr
         pp0001                   = ls_pa0001
         pp0001_is_supplied       = 'X'
          begda                    = v_stichtag
         endda                    = v_stichtag
 importing
         e_functype_chcm          = function_type
   E_SUBGROUP_CHCM          = sub_job_family.
      call function '/SIE/HR_CHCM_FUNCTION'
        exporting
          persn              = pernr
          begda              = v_stichtag
          endda              = v_stichtag
          pp0001             = ls_pa0001
          pp0001_is_supplied = 'X'
        importing
          chcm_function      = function.


    endif.
  endif.
endfunction.

*&---------------------------------------------------------------------*
*&      Form  map_func_type
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->GRIP_POSITION  text
*      -->FUNCTION_TYPE  text
*----------------------------------------------------------------------*
form get_func_type using p_grip_position type any  p_function_type type any.
*das Feld Function Typ aus dem Feld GRIP-Position
*(1. bis 2. Stelle nach dem 3. Bindestrich)
*über eine Mapping-Tabelle abzuleiten

  statics st_functtype type sorted table of /sie/hr_mapfunct
                   with unique default key.
  data ls_functtype like line of st_functtype.
  if st_functtype is initial.
    "read mapping table into buffer
    select * from /sie/hr_mapfunct into table st_functtype
      ORDER BY PRIMARY KEY. "HANA Anpassung
  endif.

  data: lv_temp1(20) type c,
        lv_temp2(20) type c,
        lv_temp3(20) type c,
        lv_temp4(20) type c.


  "get components
  split p_grip_position at '-' into lv_temp1
                                     lv_temp2
                                     lv_temp3
                                    lv_temp4.
* länge von lv_temp ermitteln und fals länger wie 2 dann

  if strlen( lv_temp4 ) gt 2.

    loop at st_functtype into ls_functtype
                    where postype = lv_temp4(2).
    endloop.
    if sy-subrc = 0.
      p_function_type = ls_functtype-functype.
    else.
      "supplied Job Family not valid
      clear p_function_type.
    endif.

  endif.


endform.                    "map_func_type

*&---------------------------------------------------------------------*
*&      Form  get_sub_job_family
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->GRIP_POSITION  text
*      -->FUNCTION_TYPE  text
*----------------------------------------------------------------------*
form get_sub_job_family using p_grip_position type any
                              p_sub_job_family type any.
  statics st_sjf type sorted table of /sie/hr_mapsjf
                   with unique default key.
  data ls_sjf like line of st_sjf.
  if st_sjf is initial.
    "read mapping table into buffer
    select * from /sie/hr_mapsjf into table st_sjf
      ORDER BY PRIMARY KEY. "HANA Anpassung
  endif.

  data: lv_temp1(20) type c,
        lv_temp2(20) type c,
        lv_temp3(20) type c,
        lv_temp4(20) type c.


  "get components
  split p_grip_position at '-' into lv_temp1
                                  lv_temp2 "hier steht schlüsselchen
                                  lv_temp3
                                  lv_temp4.
* länge von lv_temp ermitteln und fals länger wie 2 dann

  loop at st_sjf into ls_sjf
                  where grip_sjf = lv_temp2.
  endloop.
  if sy-subrc = 0.
    p_sub_job_family = ls_sjf-sjf.
  else.
    "supplied Job Family not valid
    clear p_sub_job_family.
  endif.
endform.                    "map_func_type
