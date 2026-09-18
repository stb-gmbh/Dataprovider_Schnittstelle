FUNCTION /sie/hr_idp_generate_report.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(P_TRANS_DATA) TYPE  /SIE/HR_IDP_IFC_DB
*"     VALUE(P_PROC_VECTOR) TYPE  /SIE/HR_IDP_DB_SEL
*"     VALUE(P_FLAG_TESTLAUF) TYPE  XFELD DEFAULT SPACE
*"----------------------------------------------------------------------
*SIE001: 29.03.2004 Hierl Neue Option "kein Trennzeichen" CR 4199
*SIE002: 28.06.2004 Hierl Neue Funktion Filter auf Feldebene CR 4258
*SIE003: 12.10.2004 Hierl Globale Selektion auf gültige GID CR 4708
*SIE004: 18.03.2005 Hierl neues Selektionskriterium P0203-ZZSEL CR4697
*                         (für SCD-Schnittstelle benötigt)
*SIE005: 04.05.2005 Hierl Globale Selektion auf Ministammsätze von
*                         ausländischen Mitarbeitern CR 4185
*SIE006: 06.12.2005 Hierl Zusätzliche Importingparameter bei
*                         geb. Begriffen ignorieren
*SIE007: 30.03.2006 Hierl neues zusätzliches Selektionskriterium
*                         PB/BR/PG/PK konkateniert; wird für
*                         ONTARIO-Schnittstelle benötigt CR 5978
*SIE008: 18.01.2007 Hierl Neues Selektionskriterium P9008-ZZENTG_KTO
*                         Neue Semantikklasse 0005 für geb. Begriffe,
*                         welche dann nicht einfach immer nur mit dem
*                         Endedatum des IT-Satzes aufgerufen werden,
*                         sondern bei zukünftigen Sätzen mit dem
*                         Beginndatum.
*SIE009 07.03.2008 Hierl  Neue Funktionalität der Vorselektion über ein
*                         externes Programm bei den Selektionsvorgaben.
*                         CR 3076
*SIE010 04.04.2008 Hierl  In der Vorselektion wird jetzt automatisch
*                         sortiert, um einen sauber sortierten Output
*                         für z.B. Deltagenerator zu generieren
*                         SLF 900042102
*AH001: 10.08.2009 Hannemann Globale Selektion auf DC Ministammsatz
*                            CRQ 23149
*AH002: 18.10.2010 Hannemann neues zusätzliches Selektionskriterium
*                         BRE/PB/PTB/Kostl konkateniert;
*ah003: 08.02.2011 Hannemann globale Selektion auf ZAK MA
*                            CRQ 25795
*DW001: 28.02.2012 Wastl  Im Loop über einen Infotyp muss der Subtyp
*                         ein Zeichenliteral sein (und kein
*                         Zahlenliteral: '$SUBTY' statt $SUBTY),
*                         CRQ 28342

  DATA i TYPE i.
  CHECK NOT p_proc_vector IS INITIAL.

  g_repid = p_trans_data-s1df-progr.
  g_variant = p_trans_data-s1df-varia.
  g_version = p_trans_data-s1df-vrsnr.

  PERFORM translate_fixfm USING p_trans_data-s1dl-fixfm
                                p_trans_data-s1dl-delim.

  g_variant = p_trans_data-s1df-varia.
  g_fileintern = p_trans_data-s1df-filen.
  g_delta = p_trans_data-s1df-delta.

  REFRESH code.
  PERFORM get_template USING sy-repid CHANGING g_template.
  PERFORM get_fields USING p_trans_data
                     CHANGING it_felder it_sa_infty it_infotypes.
  PERFORM get_satzarten USING p_trans_data CHANGING it_satzart.
  PERFORM get_filter    USING p_trans_data
                              it_satzart
                              it_felder
                     CHANGING it_filter.                   "SIE002

*  PERFORM change_fields CHANGING it_felder it_sa_infty it_satzart.

  PERFORM process_report_statement.
  PERFORM process_log_declarations.   " Daten für Protokolle
  PERFORM process_infotypes.
  PERFORM process_parameters.
  PERFORM process_dsn_declaration USING g_fileintern.
  PERFORM process_structure_declaration.
  PERFORM process_out_structure_decl.
  PERFORM process_trans_structure_decl.
  PERFORM process_filter_declaration.                      "SIE002
  PERFORM process_sos.
  PERFORM process_sos_stat USING p_trans_data-s1-ifcid.
  IF p_flag_testlauf = yes.
   PERFORM process_testlauf.
  ENDIF.
  PERFORM process_authority_check USING p_trans_data-s1-ifcid
                                        p_trans_data-s1-auth_class.
  PERFORM process_perform_fill_filter.                     "SIE002

  PERFORM process_start_of_selection
    USING p_trans_data-s1df-ifcid
          p_trans_data-s1df-vrsnr
          p_trans_data-s1df-itype
          p_trans_data-s1df-filen.
  PERFORM process_dynse.
  PERFORM process_time_parameters.
  IF NOT g_delta IS INITIAL. PERFORM process_metadaten. ENDIF.
  PERFORM process_header_satzart.
  PERFORM process_header_convert.
  PERFORM process_header_transfer.

  PERFORM process_pre_selection                        "SIE009
          USING p_trans_data.                          "SIE009

  PERFORM process_get_pernr.
  PERFORM process_global_selection
          USING p_trans_data-s1df.                      "SIE003


  PERFORM process_pernr_stat USING p_trans_data-s1-ifcid.
  IF g_indbw8  = 'X'. PERFORM process_indbw USING '0008'. ENDIF.
*  IF g_indbw14 = 'X'. PERFORM process_indbw USING '0014'. ENDIF.
*  IF g_indbw15 = 'X'. PERFORM process_indbw USING '0015'. ENDIF.
*Es gibt zur Zeit keine Indirekt bewerteteten Lohnarten im IT 14
*Es gibt keine Felder aus dem IT15 im Feldkatalog
*Für IT 14 und 15 ist die Logik noch Fehlerhaft
  IF g_indbw52 = 'X'. PERFORM process_indbw USING '0052'. ENDIF.
  IF g_it24 = 'X'. PERFORM process_it24 . ENDIF.
  DESCRIBE TABLE it_monthback LINES i.
  IF i GT 0. PERFORM process_rd_buffer. ENDIF.
  PERFORM process_satzart.
  PERFORM process_convert.
  PERFORM process_transfer.

  PERFORM process_are_statistic
          USING p_trans_data-s1df.

  PERFORM process_end_of_selection.
  PERFORM process_trailer_satzart.
  PERFORM process_trailer_convert.
  PERFORM process_trailer_transfer.
  PERFORM process_close_dataset.
  PERFORM process_eos_stat USING p_trans_data-s1-ifcid
                                 p_trans_data-s1df-vrsnr.
  PERFORM process_sd USING p_trans_data-s1-ifcid
                           p_trans_data-s1df-vrsnr.

  IF g_fixformat = no.
    PERFORM process_transfer_routinen_csv.
  ELSE.
    PERFORM process_transfer_routinen_fix.
  ENDIF.
  PERFORM process_compute_date.

  PERFORM process_form_fill_filter.

* Forms für Abrechnungsergebnisse generieren
  PERFORM process_payroll_include.
* Forms für Statistik und Protokollierung
  PERFORM process_log_include.

  PERFORM insert_report.
  PERFORM insert_texte.
* PERFORM show_code. "
* SUBMIT (g_repid) USING SELECTION-SET g_variant AND RETURN.
  COMMIT WORK.

ENDFUNCTION.
