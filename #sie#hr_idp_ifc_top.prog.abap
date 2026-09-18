*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_TOP                                        *
*----------------------------------------------------------------------*
*SIE003 17.06.2004 Hierl  Neue Tabelle S1PS für Filter auf
*                         Feldebene eingebaut CR 4258
*SIE006 18.03.2005 Hierl  neues Selektionskriterium P0203-ZZSEL CR4697
*                         (für SCD-Schnittstelle benötigt)

REPORT /sie/hr_idp_ifc MESSAGE-ID /sie/hr_idp_messages.

TABLES: /sie/hr_idp_s1
      , /sie/hr_idp_v1
      , /sie/hr_idp_copy_fields
      , /sie/hr_idp_s1t
      , /sie/hr_idp_s0
      , /sie/hr_idp_s1r
      , /sie/hr_idp_s1df
      , /sie/hr_idp_s1lt
      , /sie/hr_idp_s1vn
      , /sie/hr_idp_s1dl    " Delimiter und andere Attribute der Version
      , /sie/hr_idp_s1pc    " Pricing
      , /sie/hr_idp_s1vt
      , /sie/hr_idp_f1t
      , /sie/hr_idp_f1
      , /sie/hr_idp_c1
      , /sie/hr_idp_c1t
      , /sie/hr_idp_conv
      , /sie/hr_idp_f1s
      , /sie/hr_idp_s1pg
      , /sie/hr_idp_s1ps    "Feldfilter                    "SIE003
      , /sie/hr_idp_s1f
      , /sie/hr_idp_s1pr
      , /sie/hr_idp_s1sa
      , /sie/hr_idp_felder_tc
      , /sie/hr_idp_db_sel
      , /sie/hr_idp_ifc_roles
      , /sie/hr_idp_satzarten_tc
      , pernr
      , /sie/hr_idp_s0t
      , /sie/hr_idp_ifc_versions
      , /sie/hr_idp_head
      , /sie/hr_idp_released
      , /sie/hr_idp_vardata
      , qppnp
      , t001p                             " Personalbereich zur Namens
                                          " ausgabesteuerung
      , tadir                             " Programme
      , varit                             " Varianten
      , user_addr                         " Benutzerverwaltung
      , /sie/hr_idp_qifc                  " Q Felder in den Dynpros
      , /sie/hr_idp_a1
      .

DATA  idx TYPE i.
DATA: step_lines LIKE sy-tabix.

INCLUDE: <color>
       , <icon>
       .

DATA  l_owndf.
DATA  l_day.
CONTROLS: s1df TYPE TABSTRIP.
DATA:  dynpronr(4) TYPE c,
       old_activetab LIKE s1df-activetab.
DATA  l_fixfm.
DATA  l_delim.
DATA  l_error.
DATA: l_reference TYPE icons-text.                 "SIE002

DATA  g_target_ifcid LIKE /sie/hr_idp_s1-ifcid.
DATA  cursor_line TYPE i.
DATA  cursor_field LIKE /sie/hr_idp_s1vt-feldname.
DATA  content(20).
DATA  count TYPE i.
DATA  set_cursor TYPE xflag.

* Konstanten
INCLUDE /sie/hr_idp_types.

* Macros
INCLUDE /sie/hr_idp_ut_fcat_mac.   " Macros

* Bildschirm OK Code
DATA: okcode TYPE syucomm
    , svcode TYPE syucomm
    .

DATA: feldsel TYPE STANDARD TABLE OF feldname INITIAL SIZE 0.

* Globale Variablen, die für alle Dynpros gedacht sind (außer _1000).
DATA: g_ifvers_type TYPE ty_ifvers
    , g_ifdata_1000 TYPE /sie/hr_idp_ifc_head      " Dynpro 1000
* Globale Datenstruktur, um die Daten der gesamten Transaktion zu
* halten. Hier finden sich alle zu einer Schnittstelle benötigten
* Daten wieder (zu einer einzigen VERSION).
    , g_ifdata_tran TYPE /sie/hr_idp_ifc_db        " andere Dynpros
* Globale Datenfelder, um die aktuelle Schnittstelle und die
* vorhergehende zu unterscheiden. Wird hauptsächlich dazu benutzt,
* um das Einlesen der Versionen und Texte auf dem Übersichtsbild
* zu triggern und die Sperre auf die alte Schnittstelle aufzuheben.
    , g_ifdata_vers LIKE /sie/hr_idp_s1vn-vrsnr    " Versionsnummer
    , g_ifdata_oldv LIKE /sie/hr_idp_s1-ifcid      " Vorgängerschnitts.
    , old_version  LIKE /sie/hr_idp_s1vn-vrsnr

* Globales Datenfeld, um anzuzeigen, in welchem Status sich die
* Transaktion befindet. Status ist nicht gleich Dynpro, da sich evtl.
* Detailbilder auf versch. Dynpros dieselben Stati haben können.
    , g_status_tran TYPE ty_status
* Globales Datenfeld, um zwischen Dynpro 1000 und 1001 beim Anlegen
* einer neuen Schnittstelle zu kommunizieren. Dient dazu, die SS inner-
* halb es Dynpros 1001 zu sperren.
    , g_ifcid_new TYPE ty_yesno
* Globales Datenfeld zur kommunikation zwischen Dynpro 1000 und anderen
* Dynpros. Stellt fest, ob die Transaktion zu derselben Schnittstelle
* und Version die Daten schon eingelesen hat.
    , g_ifdata_modi TYPE ty_yesno
* Beim scrollen in Table controls benutzt man die g_line_count
    , g_line_count TYPE i
* Prozess Vektor. Welche Daten haben wir schon eingelesen bzw. wollen
* wir ändern?
    , g_proc_vec TYPE /sie/hr_idp_db_sel
    , g_excl_commands TYPE ty_t_excmd
    , g_pf_title TYPE ty_pfmenu.
    .


*{ Definitionen für das Table Control der Versionen (Dynpro 1000)
*  und der Selektionen (Dynpro 1002)
DATA: record_vers TYPE /sie/hr_idp_ifc_versions
    , g_t_vers_0100 TYPE STANDARD TABLE OF /sie/hr_idp_ifc_versions
                    INITIAL SIZE 0
                    WITH HEADER LINE
    , selection TYPE xflag
    .

CONTROLS: tc_vers TYPE TABLEVIEW USING SCREEN 0200
        , tc_var  TYPE TABLEVIEW USING SCREEN 0300
        , tc_released TYPE TABLEVIEW USING SCREEN 0500
        .
DATA wa_cols LIKE screen.
*}

* Daten zum Fuellen des TC auf Dynpro 1002
TYPES: BEGIN OF ty_vardata
     ,   mark TYPE xflag
     ,   feldname TYPE /sie/hr_idp_fname
     ,   ident    TYPE /sie/hr_idp_f1t-ident
     ,   icon     TYPE icon_l4
     , END OF ty_vardata
     .
DATA: wa_tran_s1vt LIKE LINE OF g_ifdata_tran-s1vt
    , wa_tran_f1t TYPE /sie/hr_idp_f1t
    , wa_tran_s1pg LIKE LINE OF g_ifdata_tran-s1pg
    , g_vardata TYPE ty_vardata OCCURS 0 WITH HEADER LINE
    .
* Daten für FB COMPLEX_SELECTIONS_DIALOG
FIELD-SYMBOLS: <range> TYPE STANDARD TABLE.
.
RANGES: pnppernr FOR pernr-pernr                             "#EC *
      , pnpmassn FOR pernr-massn                             "#EC *
      , pnpmassg FOR pernr-massg                             "#EC *
      , pnpstat1 FOR pernr-stat1                             "#EC *
      , pnpstat2 FOR pernr-stat2                             "#EC *
      , pnpstat3 FOR pernr-stat3                             "#EC *
      , pnpbukrs FOR pernr-bukrs                             "#EC *
      , pnpwerks FOR pernr-werks                             "#EC *
      , pnppersg FOR pernr-persg                             "#EC *
      , pnppersk FOR pernr-persk                             "#EC *
      , pnpvdsk1 FOR pernr-vdsk1                             "#EC *
      , pnpgsber FOR pernr-gsber                             "#EC *
      , pnpbtrtl FOR pernr-btrtl                             "#EC *
      , pnpjuper FOR pernr-juper                             "#EC *
      , pnpabkrs FOR pernr-abkrs                             "#EC *
      , pnpansvh FOR pernr-ansvh                             "#EC *
      , pnpkostl FOR pernr-kostl                             "#EC *
      , pnporgeh FOR pernr-orgeh                             "#EC *
      , pnpplans FOR pernr-plans                             "#EC *
      , pnpstell FOR pernr-stell                             "#EC *
      , pnpmstbr FOR pernr-mstbr                             "#EC *
      , pnpsacha FOR pernr-sacha                             "#EC *
      , pnpsachp FOR pernr-sachp                             "#EC *
      , pnpsachz FOR pernr-sachz                             "#EC *
      , pnpsname FOR pernr-sname                             "#EC *
      , pnpename FOR pernr-ename                             "#EC *
      , pnpotype FOR pernr-otype                             "#EC *
      , pnpsbmod FOR pernr-sbmod                             "#EC *
      , pnpkokrs FOR pernr-kokrs                             "#EC *
      , pnpfistl FOR pernr-fistl                             "#EC *
      , pnpgeber FOR pernr-geber                             "#EC *
      , pnpmasng FOR pernr-masng                             "#EC *
      , pnpstatu FOR pernr-statu                             "#EC *
      , pnpxbwbk FOR pernr-xbwbk                             "#EC *
      , pnpkoktl FOR pernr-koktl                             "#EC *
      , pnpxpgpk FOR pernr-xpgpk                             "#EC *
      , pnpsasba FOR pernr-sasba                             "#EC *
      , pnpsasbp FOR pernr-sasbp                             "#EC *
      , pnpsasbz FOR pernr-sasbz                             "#EC *
      , pnpdayps FOR pernr-dayps                             "#EC *
      , zzstando FOR p0001-zzstando
      , zzbreinh FOR p0001-zzbreinh
      , zzpkat   FOR p9008-pkat
      , zzhansp  FOR p0263-hansp
      , zzsel    FOR p0203-zzsel                             "SIE006
      , zz_pbbr  FOR /sie/hr_idp_sel_gb-pbbr                 "SIE007
      , zz_brpb  FOR /SIE/HR_IDP_SEL_BR_PB_PTBKOSTL-BRPBPTBKOSTL  "AH002
      , ZZENTKTO for P9008-ZZENTG_KTO                        "SIE008
      .

************************************************************************

*{ Table control Dynpro 0400
CONTROLS: tc_matrix TYPE TABLEVIEW USING SCREEN 0400.

DATA: g_matrix TYPE STANDARD TABLE OF /sie/hr_idp_s1r INITIAL SIZE 0
               WITH HEADER LINE.

DATA: g_itab_s1r TYPE STANDARD TABLE OF /sie/hr_idp_ifc_roles
                 INITIAL SIZE 7.

DATA  tab_lines TYPE i.

*} XFT

* Dynpro 1004
CONTROLS: tc_prog TYPE TABLEVIEW USING SCREEN 1004.
DATA  g_1004_loaded TYPE xflag.
DATA  g_1004_satzart_changed TYPE xflag.
DATA  g_1004_dont_load TYPE xflag.
*DATA: BEGIN OF g_itab_s1pg OCCURS 0,
*        mark TYPE xfeld,
*        fields TYPE /sie/hr_idp_s1pg,
*        ident TYPE /sie/hr_idp_nutzbez,
*      END OF g_itab_s1pg.


*SIE003_BEG
*DATA: g_itab_s1pg TYPE STANDARD TABLE OF /sie/hr_idp_felder_tc
*      INITIAL SIZE 0 WITH HEADER LINE.

DATA: BEGIN OF g_itab_s1pg OCCURS 0.
        INCLUDE STRUCTURE /sie/hr_idp_felder_tc.
DATA:   s1ps LIKE g_ifdata_tran-s1ps.
DATA: END OF g_itab_s1pg.
*SIE003_END


DATA: g_itab_satzart TYPE /sie/hr_idp_record_name OCCURS 0
                     WITH HEADER LINE.
DATA: g_satzart_old TYPE /sie/hr_idp_record_name.
DATA: g_itab_satzart_values TYPE vrm_values WITH HEADER LINE.
DATA: i TYPE int4.
* Dynpro 600
DATA: g_700_satzart TYPE /sie/hr_idp_record_name
    , g_feldname(20)
    , g_feldname_idx TYPE i
    .

* Dynpro 0500
DATA: g_released TYPE STANDARD TABLE OF /sie/hr_idp_released
      INITIAL SIZE 0 WITH HEADER LINE.

DATA: wa_s1f LIKE /sie/hr_idp_s1f.

DATA: show_field TYPE text60.

DATA: fl_accpt TYPE ty_yesno.

DATA  h_s1 LIKE /sie/hr_idp_s1.

INCLUDE dbpnpcom.
INCLUDE dbpnpmac.

DATA  fl_new_version TYPE ty_yesno.

DATA: BEGIN OF ic
    , sa_pp
    , sa_p
    , sa_m
    , sa_mm
    , saf_pp
    , saf_p
    , saf_m
    , saf_mm
    , END OF ic.

CONTROLS: tc_sa TYPE TABLEVIEW USING SCREEN 1006
        , tc_saf TYPE TABLEVIEW USING SCREEN 1006
        .

DATA: g_itab_sa TYPE STANDARD TABLE OF /sie/hr_idp_satzarten_tc
      INITIAL SIZE 0 WITH HEADER LINE.

DATA: f1 TYPE i
    , f2 TYPE i
    , f3 TYPE i
    , f4 TYPE i
    .

DATA: step_lines_b LIKE sy-loopc
    , step_lines_a LIKE sy-loopc
    .

DATA: g_tabix LIKE sy-tabix.

DATA: g_itab_s1pg_help_1006 LIKE g_itab_s1pg OCCURS 0 WITH HEADER LINE.

DATA: g_buffer_s1pg LIKE g_itab_s1pg.
DATA: g_buffer_s1ps LIKE g_ifdata_tran-s1ps WITH HEADER LINE."SIE003

DATA: infty_text TYPE STANDARD TABLE OF t777t INITIAL SIZE 0
      WITH HEADER LINE
    , subty_text TYPE STANDARD TABLE OF t777u INITIAL SIZE 0
      WITH HEADER LINE
    .

DATA: gv_flag_newversion TYPE ty_yesno.
