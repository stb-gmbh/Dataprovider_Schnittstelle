*SIE001 29.03.2004 Hierl  Neue Option "kein Trennzeichen" CR 4199
*SIE002 12.05.2004 Hierl  Neue Funktion "Schnittstelle referenzieren"
*                         CR 4258
*SIE003 17.06.2004 Hierl  Neue Funktion "Filter auf Feldebene"
*                         CR 4258
*SIE005 14.03.2005 Hierl  Neue Funktion "Satzarten kopieren" CR4258
*                         Korrektur, dass die Eingabe einer fehlerhaften
*                         Referenzschnittstelle auf entsprechendem Popup
*                         trotz Abbrechen übernommen wird

PROCESS BEFORE OUTPUT.
 MODULE init.                               " Wird von allen aufgerufen
 MODULE set_status.                         " Wird von allen aufgerufen
 CALL SUBSCREEN subscr_title INCLUDING '/SIE/HR_IDP_IFC' c_titl_sdyn.
 MODULE read_s1lt.
 MODULE read_s1vn.
 MODULE read_s1pg.
 MODULE read_s1ps.                                         "SIE003
 MODULE read_s1dl.
 MODULE read_s1df.
 MODULE read_s1f.
 MODULE read_s1sa.
 MODULE set_radiob2.
 MODULE set_reference.                                     "SIE002
 MODULE r1006_pbo.
 MODULE d1006_pbo.

  LOOP AT g_itab_sa
     INTO /sie/hr_idp_satzarten_tc
     WITH CONTROL tc_sa
     CURSOR tc_sa-current_line.

     MODULE calc_step_lines_a.
     MODULE hide_keys_sa.
     MODULE modify_sa_screen.
  ENDLOOP.

   LOOP AT g_itab_s1pg
*     INTO /sie/hr_idp_felder_tc                           "SIE003
      WITH CONTROL tc_saf
      CURSOR tc_saf-current_line.
       MODULE set_struc_felder_tc.                         "SIE003

       MODULE hide_keys_1006.
       MODULE switch_month.          " Monatsoffset-Eingabebereitschaft
       MODULE hide_param.
       MODULE calc_step_lines_b.
       MODULE set_keypos.
       MODULE hide_nosep.                                  "SIE001
       MODULE set_filter_icon.                             "SIE003
  ENDLOOP.

 MODULE modify_screen.
 MODULE modify_screen_1006.                                "SIE002
 MODULE deactivate_functions.


*****


PROCESS AFTER INPUT.
 MODULE exit_command AT EXIT-COMMAND.       " Wird von allen aufgerufen
 MODULE copy_ok_code.                       " Wird von allen aufgerufen
 CHAIN.
   FIELD l_fixfm.
   FIELD l_delim.
   FIELD /sie/hr_idp_s1dl-delim.
 ENDCHAIN.

 CALL SUBSCREEN subscr_title.

  LOOP AT g_itab_sa.
    CHAIN.
      FIELD /sie/hr_idp_satzarten_tc-mark.
      FIELD /sie/hr_idp_satzarten_tc-recna.
      FIELD /sie/hr_idp_satzarten_tc-recty.
      FIELD /sie/hr_idp_satzarten_tc-infty.
      FIELD /sie/hr_idp_satzarten_tc-subty.
      FIELD /sie/hr_idp_satzarten_tc-kzsrn.
      FIELD /sie/hr_idp_satzarten_tc-kzspn.
      FIELD /sie/hr_idp_satzarten_tc-operan.
      FIELD /sie/hr_idp_satzarten_tc-operat.
      FIELD /sie/hr_idp_satzarten_tc-opeval.
      MODULE write_recna_matrix ON CHAIN-REQUEST.
      MODULE check_recna ON CHAIN-REQUEST.
      MODULE current_recna ON CHAIN-REQUEST.
    ENDCHAIN.
  ENDLOOP.

  LOOP AT g_itab_s1pg.
   CHAIN.
     FIELD: /sie/hr_idp_felder_tc-feldname.
     FIELD: /sie/hr_idp_felder_tc-konvnam.
     MODULE check_conversion ON CHAIN-REQUEST.
    ENDCHAIN.
    CHAIN.
     FIELD: /sie/hr_idp_felder_tc-mark.
     FIELD: /sie/hr_idp_felder_tc-feldname.
     FIELD: /sie/hr_idp_felder_tc-mthbk.
     FIELD: /sie/hr_idp_felder_tc-konvnam.
     FIELD: /sie/hr_idp_felder_tc-param.
     FIELD /sie/hr_idp_felder_tc-offst.
     FIELD /sie/hr_idp_felder_tc-length.
     FIELD /sie/hr_idp_felder_tc-kzkey.
     FIELD /sie/hr_idp_felder_tc-nosep.                    "SIE001
     FIELD /sie/hr_idp_felder_tc-paramgb.
     MODULE write_fldps.
     MODULE write_fields_matrix ON CHAIN-REQUEST.
   ENDCHAIN.
   CHAIN.
     FIELD: /sie/hr_idp_felder_tc-feldname.
     FIELD: /sie/hr_idp_felder_tc-konvnam.
     MODULE check_field_types ON CHAIN-REQUEST.
     MODULE check_field_singularity ON CHAIN-REQUEST.
   ENDCHAIN.
   FIELD /sie/hr_idp_felder_tc-param MODULE check_apo ON REQUEST.
   FIELD /sie/hr_idp_felder_tc-feldname MODULE check_rec ON REQUEST.
  ENDLOOP.

  CHAIN.
    FIELD: l_fixfm, l_delim, /sie/hr_idp_s1dl-delim.
    MODULE check_format ON CHAIN-REQUEST.
  ENDCHAIN.

  MODULE field_user_command_tc.                            "SIE003

  FIELD f1 MODULE page_index_f1 ON REQUEST.
  FIELD f3 MODULE page_index_f3 ON REQUEST.

  MODULE field_user_command.
  MODULE update_s1pg_data.
  MODULE write_delim.

  MODULE user_command.                       " Wird von allen aufgerufen


PROCESS ON VALUE-REQUEST.
  FIELD /sie/hr_idp_felder_tc-konvnam MODULE f4_conversion.
  FIELD /sie/hr_idp_felder_tc-feldname MODULE f4_feldname.
  FIELD /sie/hr_idp_satzarten_tc-operan MODULE f4_operan.


















