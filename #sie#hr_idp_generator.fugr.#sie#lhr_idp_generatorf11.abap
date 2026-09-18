*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_GENERATORF11 .
*       P R O C E S S R O U T I N E N
*       G E T  P E R N R
*----------------------------------------------------------------------*
FORM process_get_pernr.

  DATA:
    tag TYPE /sie/hr_idp_tt_coding.

  PERFORM get_tag USING 'get' CHANGING tag.
  PERFORM insert_code USING tag.

*$<get>
*$GET PERNR.
*$  commit work.
*$</get>
ENDFORM.                    " PROCESS_GET_PERNR

*---------------------------------------------------------------------*
*       FORM PROCESS_GLOBAL_SELECTION                      "SIE003    *
*---------------------------------------------------------------------*
*       Globale Selektionskriterien                                   *
*---------------------------------------------------------------------*
FORM process_global_selection USING p_s1df LIKE /sie/hr_idp_s1df.

  DATA:
    tag TYPE /sie/hr_idp_tt_coding.

* Selektion auf GID
  IF p_s1df-nogsel <> 'X'.
     PERFORM get_tag USING 'global_selection' CHANGING tag.
     PERFORM insert_code USING tag.
  ENDIF.

*SIE005_BEG
** Ministammsatz oberster Führungskreis
*  IF p_s1df-gsel_mini1 <> 'X'.
*     REFRESH tag.
*     PERFORM get_tag USING 'glsel_minisatz1' CHANGING tag.
*     PERFORM insert_code USING tag.
*  ENDIF.

* Ministammsatz Ministammsatz Sonstige (PGV u. VIP)
  IF p_s1df-gsel_mini2 <> 'X'.
     REFRESH tag.
     PERFORM get_tag USING 'glsel_minisatz2' CHANGING tag.
     PERFORM insert_code USING tag.
  ENDIF.
*SIE005_END

     REFRESH tag. "AH002

*SIE007_BEG
* Selektion auf konkateniertes Feld PB/BR/PG/PK
  PERFORM get_tag USING 'glsel_zzsel_pb' CHANGING tag.
  PERFORM insert_code USING tag.
*SIE007_END

*AH002_BEG
* Selektion auf konkateniertes Feld BR/PB/PTB/KOSTL
  REFRESH tag.
  PERFORM get_tag USING 'glsel_zzsel_brpb' CHANGING tag.
  PERFORM insert_code USING tag.
*AH002_END

*AH001_BEG
* Ministammsatz DC
  IF p_s1df-gsel_mini4 <> 'X'.
     REFRESH tag.
     PERFORM get_tag USING 'glsel_minisatz4' CHANGING tag.
     PERFORM insert_code USING tag.
  ENDIF.
*AH001_END

* ah002 begin
* Ministammsatz Vorstand
  IF p_s1df-gsel_mini1 <> 'X'.
     REFRESH tag.
     PERFORM get_tag USING 'glsel_minisatz1' CHANGING tag.
     PERFORM insert_code USING tag.
  ENDIF.

* Ministammsatz Executives
  IF p_s1df-gsel_mini5 <> 'X'.
     REFRESH tag.
     PERFORM get_tag USING 'glsel_executives' CHANGING tag.
     PERFORM insert_code USING tag.
  ENDIF.

* ah003 begin
* Ministammsatz Zeitarbeitskraefte ZAK

*COL-27098 begin of delete
*  IF p_s1df-gsel_mini6 <> 'X'.
*     REFRESH tag.
*     PERFORM get_tag USING 'glsel_zak' CHANGING tag.
*     PERFORM insert_code USING tag.
*  ENDIF.
*COL-27098 end of delete

*  früher                and abkrs = '9K' statt and persg = 'A'.
*$<glsel_zak>
*$* heutige ZAK ausschließen
*$  LOOP AT p0001 WHERE begda le sy-datum
*$                  and endda ge sy-datum
*$                  and persg = 'A'.
*$     REJECT.
*$  ENDLOOP.
*$</glsel_zak>
* ah003 end

*$<glsel_executives>
*$* heutige und künftige Executives ausschließen
*$  LOOP AT p0001 WHERE begda le sy-datum
*$                  and endda ge sy-datum
*$                  and abkrs = 'CD'.
*$     REJECT.
*$  ENDLOOP.
*$</glsel_executives>
* ah002 end

*$<global_selection>
*$  RP-PROVIDE-FROM-LAST P0003 SPACE PN-BEGDA PN-ENDDA.
*$* nur Mitarbeiter mit gültiger GID berücksichtigen
*$  IF P0003-ZZGID IS INITIAL OR P0003-ZZGID = '00000001'.
*$     REJECT.
*$  ENDIF.
*$</global_selection>

*SIE005_BEG
*$<glsel_minisatz1>
*$  LOOP AT p0001 WHERE begda le sy-datum
*$                  and endda ge sy-datum
*AK001 BEG: Abrechnungskreis '9T' zusätzlich aufnehmen
*$                  and ( abkrs = '9W' or abkrs = '9T' ).
*AK001 END
*$     REJECT.
*$  ENDLOOP.
*$</glsel_minisatz1>

*$<glsel_minisatz2>
*$* Ministammsatz Sonstige (PGV u. VIP) ausschliessen.
*$  LOOP AT p0001 WHERE begda le sy-datum
*$                  and endda ge sy-datum
*$                  and abkrs = '9Y'.
*$     REJECT.
*$  ENDLOOP.
*$</glsel_minisatz2>
*SIE005_END

*SIE007_BEG
*$<glsel_zzsel_pb>
*$* Selektion auf konkateniertes Feld PB/BR/PG/PK
*$  DESCRIBE TABLE ZZ_PBBR.
*$  IF sy-tfill > 0.
*$     h_reject = 'X'.
*$     LOOP AT p0001 WHERE BEGDA <= PN-ENDPS
*$                     AND ENDDA >= PN-BEGPS.
*$        CALL FUNCTION '/SIE/HR_FGB_PB_BR_PG_PK'
*$          EXPORTING
*$            pernr                    = pernr-pernr
*$            BEGDA                    = p0001-begda
*$            ENDDA                    = p0001-endda
*$            PP0001                   = p0001[]
*$            PP0001_IS_SUPPLIED       = 'X'
*$          IMPORTING
*$            E_CONCATENATION          = wa_sel-pbbr
*$                  .
*$        IF wa_sel-pbbr IN zz_pbbr.
*$           CLEAR h_reject.
*$        ENDIF.
*$     ENDLOOP.
*$     IF h_reject = 'X'. REJECT. ENDIF.
*$  ENDIF.
*$</glsel_zzsel_pb>
*SIE007_END

*AH002_BEG
*$<glsel_zzsel_brpb>
*$* Selektion auf konkateniertes Feld BR/PB/PTB/KOSTL
*$  DESCRIBE TABLE ZZ_BRPB.
*$  IF sy-tfill > 0.
*$     h_reject = 'X'.
*$     LOOP AT p0001 WHERE BEGDA <= PN-ENDPS
*$                     AND ENDDA >= PN-BEGPS.
*$        CALL FUNCTION '/SIE/HR_FGB_BR_PB_PTB_KOSTL'
*$          EXPORTING
*$            pernr                    = pernr-pernr
*$            BEGDA                    = p0001-begda
*$            ENDDA                    = p0001-endda
*$            PP0001                   = p0001[]
*$            PP0001_IS_SUPPLIED       = 'X'
*$          IMPORTING
*$  E_CONCATENATION = wa_sel_BRPB-BRPBPTBKOSTL
*$                  .
*$        IF wa_sel_BRPB-BRPBPTBKOSTL IN ZZ_BRPB.
*$           CLEAR h_reject.
*$        ENDIF.
*$     ENDLOOP.
*$     IF h_reject = 'X'. REJECT. ENDIF.
*$  ENDIF.
*$</glsel_zzsel_brpb>
*AH002_END

*AH001_BEG
*$<glsel_minisatz4>
*$* Ministammsatz DC ausschließen
*$  LOOP AT p9020 WHERE art = '4'.
*$     REJECT.
*$  ENDLOOP.
*$</glsel_minisatz4>
*AH001_END


ENDFORM. "process_global_selection


*---------------------------------------------------------------------*
*       FORM PROCESS_RD_BUFFER                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_rd_buffer.

  DATA:
    mthbk       LIKE LINE OF it_monthback,
    tag_rgdir   TYPE /sie/hr_idp_tt_coding,
    tag_cluster TYPE /sie/hr_idp_tt_coding,
    result      TYPE /sie/hr_idp_tt_coding.

  PERFORM get_tag USING 'read_rgdir' CHANGING tag_rgdir.
  PERFORM get_tag USING 'read_cluster' CHANGING tag_cluster.

  PERFORM insert_code USING tag_rgdir.
  LOOP AT it_monthback INTO mthbk.
    PERFORM replace_param USING 'MTHBK' mthbk tag_cluster
                          CHANGING result.
  PERFORM insert_code USING result.
  ENDLOOP.
*$<read_rgdir>
*$*Puffern der Daten aus dem Cluster RD
*$  clear: rgdir, rgdir[],
*$         it_rd, it_rd[],
*$         payroll_result.
*$  CALL FUNCTION 'CU_READ_RGDIR'
*$       EXPORTING
*$            persnr             = pernr-pernr
*$       TABLES
*$            in_rgdir           = rgdir
*$       EXCEPTIONS
*$            no_record_found    = 1
*$            OTHERS             = 2.
*$  IF sy-subrc <> 0. ENDIF.
*$</read_rgdir>

*$<read_cluster>
*$  p_perid = pn-endda(6).
*$  p_delta = &mthbk * ( -1 ).
*$  CALL FUNCTION 'HR_CALC_MONTH'
*$       EXPORTING
*$            delta           = p_delta
*$       CHANGING
*$            periode         = p_perid
*$       EXCEPTIONS
*$            invalid_period  = 1
*$            undefined_point = 2
*$            OTHERS          = 3.
*$  IF sy-subrc <> 0. ENDIF.
*$  LOOP AT rgdir WHERE srtza = 'A' AND fpper = p_perid.
*$    CALL FUNCTION 'PYXX_READ_PAYROLL_RESULT'
*$         EXPORTING
*$              clusterid                    = 'RD'
*$              employeenumber               = pernr-pernr
*$              sequencenumber               = rgdir-seqnr
*$         changing
*$              payroll_result               = payroll_result
*$         exceptions
*$              illegal_isocode_or_clusterid = 1
*$              error_generating_import      = 2
*$              import_mismatch_error        = 3
*$              subpool_dir_full             = 4
*$              no_read_authority            = 5
*$              no_record_found              = 6
*$              versions_do_not_match        = 7
*$              others                       = 8.
*$    IF sy-subrc <> 0. ENDIF.
*$  ENDLOOP.
*$  it_rd-mthbk = &mthbk.
*$  it_rd-payde_result = payroll_result.
*$  append it_rd.
*$</read_cluster>
ENDFORM.

FORM process_it24.
DATA:
  tag TYPE /sie/hr_idp_tt_coding.
  PERFORM get_tag USING 'get_it24' CHANGING tag.
  PERFORM insert_code USING tag.
*$<get_it24>
*$ clear: p0024, p0024[].
*$ help_pernr = pernr-pernr.
*$CALL FUNCTION 'BAPI_QUALIFIC_GETLIST'
*$     EXPORTING
*$          plvar                = '01'
*$          otype                = 'P '
*$          sobid                = help_pernr
*$*         FROM_DATE            = '19000101'
*$*         TO_DATE              = '99990101'
*$*         NO_HALFVALUE         =
*$*    IMPORTING
*$*         RETURN               =
*$     TABLES
*$          qualificationprofile = p0024.
*$          .
*$</get_it24>
ENDFORM.
*---------------------------------------------------------------------*
*       FORM PROCESS_INDBW                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_INFTY                                                       *
*---------------------------------------------------------------------*
FORM process_indbw USING p_infty TYPE infty.

  DATA:
    tag TYPE /sie/hr_idp_tt_coding,
    result TYPE /sie/hr_idp_tt_coding.

  PERFORM get_tag USING 'indbw' CHANGING tag.
  PERFORM replace_param USING 'INFTY' p_infty tag CHANGING result.
  PERFORM insert_code USING result.
  CLEAR: tag, result.
  CASE p_infty.
    WHEN '0008' OR '0052'.
      PERFORM get_tag USING 'indbw_2_1' CHANGING tag.
      PERFORM replace_param USING 'INFTY' p_infty tag CHANGING result.
      PERFORM insert_code USING result.
    WHEN '0014' OR '0015'.
      PERFORM get_tag USING 'indbw_2_2' CHANGING tag.
      PERFORM replace_param USING 'INFTY' p_infty tag CHANGING result.
      PERFORM insert_code USING result.
    WHEN OTHERS.
      APPEND 'endif. endloop.' TO code.
  ENDCASE.
*$<indbw>
*$* Indirekte Bewertung für IT&INFTY
*$  LOOP AT p&INFTY.
*$    CALL FUNCTION 'RP_FILL_WAGE_TYPE_TABLE_EXT'
*$         EXPORTING
*$*         APPLI                        = 'E'
*$              begda                        = p&INFTY-begda
*$              endda                        = p&INFTY-endda
*$              infty                        = '&INFTY'
*$*         OBJPS                        = '  '
*$              pernr                        = pernr-pernr
*$*         SEQNR                        = '   '
*$              subty                        = p&INFTY-subty
*$*         DLSPL                        = 'X'
*$         tables
*$              pp0001                       = p0001
*$              pp0007                       = p0007
*$              pp0008                       = p0008
*$              ppbwla                       = it_pbwla
*$*         PP0230                       =
*$        exceptions
*$             error_at_indirect_evaluation = 1
*$             others                       = 2
*$              .
*$    IF sy-subrc = 0.
*$</indbw>
*$<indbw_2_2>
*$      LOOP AT it_pbwla WHERE lgart = P&INFTY-LGART
*$                         and endda ge P&INFTY-endda
*$                         and begda le P&INFTY-endda.
*$        P&INFTY-BETRG = it_pbwla-betrg.
*$        MODIFY p&INFTY.
*$      ENDLOOP.
*$    ENDIF.
*$  ENDLOOP.
*$* Ende der Indirekten Bewertung für IT&INFTY
*$
*$</indbw_2_2>

*$<indbw_2_1>
*$      DO 20 TIMES.
*$        MOVE sy-index TO lganr.
*$        CONCATENATE 'P&INFTY-LGA' lganr INTO lgart_name.
*$        CONCATENATE 'P&INFTY-BET' lganr INTO betrg_name.
*$        ASSIGN (lgart_name) TO <lgart>.
*$        ASSIGN (betrg_name) TO <betrg>.
*$        IF <lgart> IS INITIAL. EXIT. ENDIF.
*$        LOOP AT it_pbwla WHERE lgart = <lgart>
*$                           and endda ge P&INFTY-endda
*$                           and begda le P&INFTY-endda.
*$          <betrg> = it_pbwla-betrg.
*$          MODIFY p&INFTY.
*$        ENDLOOP.
*$      ENDDO.
*$    ENDIF.
*$  ENDLOOP.
*$* Ende der Indirekten Bewertung für IT&INFTY
*$
*$</indbw_2_1>
ENDFORM.


*---------------------------------------------------------------------*
*       FORM PROCESS_SATZART                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_satzart.
  DATA:
    l           TYPE LINE OF /sie/hr_idp_tt_coding,
    tag         TYPE /sie/hr_idp_tt_coding,
    tag_append1 TYPE /sie/hr_idp_tt_coding,
    tag_append2 TYPE /sie/hr_idp_tt_coding,                "SIE002
    tag3        TYPE /sie/hr_idp_tt_coding,
    result      TYPE /sie/hr_idp_tt_coding,
    input       TYPE /sie/hr_idp_tt_coding,
    sa          LIKE LINE OF it_satzart,
    feld        LIKE LINE OF it_felder,
    comment,
    vglwert(62) TYPE c.



  PERFORM get_tag USING 'satzart1' CHANGING tag.
  PERFORM get_tag USING 'satzart_append1' CHANGING tag_append1."SIE002
  PERFORM get_tag USING 'satzart_append2' CHANGING tag_append2.
  PERFORM get_tag USING 'satzart3' CHANGING tag3.
  LOOP AT it_satzart INTO sa.
    CASE sa-recty.
      WHEN '3' OR '4'. "Einmaldaten, Wiederholdaten
        PERFORM replace_param USING 'RECNA' sa-sname tag
                              CHANGING result.
        MOVE result[] TO input[].
        PERFORM replace_param USING 'RECTY' sa-recty input
                              CHANGING result.
        PERFORM insert_code USING result.
        PERFORM process_satzart_satzart USING sa-recna sa-sname.
        PERFORM process_satzart_pernr   USING sa-recna sa-sname.
        IF sa-recty = 3. "Einmaldaten - Append obligatorisch
          PERFORM process_satzart_infotyp USING sa.
          PERFORM process_satzart_kto     USING sa-recna sa-sname.
          PERFORM process_satzart_lgart   USING sa-recna sa-sname.
          PERFORM process_satzart_begriff USING sa.

          PERFORM insert_code USING tag_append1.           "SIE002

          PERFORM process_field_filter USING sa-recna.

          PERFORM replace_param USING 'RECNA' sa-sname tag_append2
                                CHANGING result.
          CLEAR comment.
          IF sa-operan IS INITIAL.
            comment = '*'.
          ELSE.
            MOVE result[] TO input[].
            READ TABLE it_felder WITH KEY recna = sa-recna
                                          feldname = sa-operan
                                 INTO feld
                                 TRANSPORTING selname.
            IF sy-subrc > 0. comment = '*'. ENDIF.
            IF sa-operat IS INITIAL. comment = '*'. ENDIF.
            PERFORM replace_param USING 'OPERAN' feld-selname input
                                  CHANGING result.
            MOVE result[] TO input[].
            PERFORM replace_param USING 'OPERAT' sa-operat input
                                  CHANGING result.
            MOVE result[] TO input[].
            MOVE sa-opeval TO vglwert.
            TRANSLATE vglwert TO UPPER CASE.
            IF vglwert = 'SYDATUM'.
              PERFORM replace_param USING 'OPEVAL' 'g_datum' input
                                    CHANGING result.
            ELSE.
              CONCATENATE '''' sa-opeval '''' INTO vglwert.
              PERFORM replace_param USING 'OPEVAL' vglwert input
                                    CHANGING result.
            ENDIF.
          ENDIF.
          MOVE result[] TO input[].
          PERFORM replace_param USING 'COMMENT' comment input
                                CHANGING result.
          PERFORM insert_code USING result.
        ELSEIF sa-recty = 4. "Wiederholdaten
          PERFORM process_satzart_it_loop USING sa-recna.
        ENDIF.
        PERFORM replace_param USING 'RECNA' sa-sname tag3
                              CHANGING result.
        PERFORM insert_code USING result.
    ENDCASE.
  ENDLOOP.

*Vorsicht, Tags satzart1 satzart2 und satzart_append werden auch von
*Header-/Trailersatzarten verwendet

*$<satzart1>
*$*Satzart: &RECNA
*$*    Typ: &RECTY
*$  CLEAR ITAB_&RECNA.
*$  REFRESH ITAB_&RECNA.
*$  CLEAR ITAB_OUT_&RECNA.
*$  REFRESH ITAB_OUT_&RECNA.
*$</satzart1>

*SIE002_BEG
**$<satzart_append>
**$*Append bei Einmaldaten
**$*Hier kann ein Filter auf Satzartebene eingebaut werden
**$&COMMENT if ITAB_&RECNA-&OPERAN &OPERAT &OPEVAL.
**$    APPEND ITAB_&RECNA. "Einmaldaten
**$&COMMENT endif.
**$</satzart_append>

*$<satzart_append1>
*$*Append bei Einmaldaten
*$  DO 1 TIMES.
*$</satzart_append1>

*$<satzart_append2>
*$
*$*Hier kann ein Filter auf Satzartebene eingebaut werden
*$&COMMENT CHECK ITAB_&RECNA-&OPERAN &OPERAT &OPEVAL.
*$    APPEND ITAB_&RECNA. "Einmaldaten
*$  ENDDO.
*$</satzart_append2>

**Tag wird noch weiterhin für header und Trailersätze benötigt!
*$<satzart_append>
*$
*$    APPEND ITAB_&RECNA. "Header-/Trailer
*$</satzart_append>

*SIE002_END

*$<satzart3>
*$*END OF SATZART &RECNA.
*$*
*$</satzart3>
ENDFORM.                    " PROCESS_SATZART

*---------------------------------------------------------------------*
*       FORM PROCESS_FIELD_FILTER                          SIE002     *
*---------------------------------------------------------------------*
*       Generiert die feldbezogenen Filter mit Check-Befehlen         *
*---------------------------------------------------------------------*

FORM process_field_filter
     USING p_recna TYPE /sie/hr_idp_record_name.

  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    wa_filter LIKE LINE OF it_filter.

* Nur prozessieren, wenn Feldfilter überhaupt verwendet wurden
  READ TABLE it_filter INDEX 1 TRANSPORTING NO FIELDS.
  CHECK sy-subrc = 0.

  LOOP AT it_filter INTO wa_filter WHERE recna = p_recna.

    AT NEW feldname."Nur einmal definieren

      REFRESH tag.
      PERFORM get_tag USING 'field_filter' CHANGING tag.

      PERFORM replace_param USING 'RNAME' wa_filter-rangename tag
                          CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'LRECNA' wa_filter-recna input
                          CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'LFNAME' wa_filter-feldname input
                          CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'RECNA' wa_filter-sname input
                          CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'FNAME' wa_filter-selname input
                          CHANGING result.
      PERFORM insert_code USING result.

    ENDAT.

  ENDLOOP.

*$<field_filter>
*$* Filter für &LRECNA-&LFNAME
*$  CHECK ITAB_&RECNA-&FNAME IN &RNAME.
*$</field_filter>

ENDFORM. "PROCESS_FIELD_FILTER

*---------------------------------------------------------------------*
*       FORM PROCESS_SATZART_SATZART                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_RECNA                                                       *
*---------------------------------------------------------------------*
FORM process_satzart_satzart
     USING p_recna TYPE /sie/hr_idp_record_name p_sname.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    fields    LIKE LINE OF it_felder,
    sai       LIKE LINE OF it_sa_infty.                                .

  PERFORM get_tag USING 'sa_satzart' CHANGING tag.
  LOOP AT it_felder INTO fields WHERE recna = p_recna
                                  AND selname = 'FSA_'. "satzart

    PERFORM replace_param USING 'RECNA' p_recna  tag
                          CHANGING result.
    MOVE result[] TO input[].
    PERFORM replace_param USING 'SNAME' p_sname  input CHANGING result.
    PERFORM insert_code USING result.
  ENDLOOP.
*$<sa_satzart>
*$* Konstante Satzart &recna
*$  move '&recna' to itab_&sname-fsa_.
*$</sa_satzart>
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_SATZART_HTFIELDS                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_RECNA                                                       *
*  -->  P_SNAME                                                       *
*---------------------------------------------------------------------*
FORM process_satzart_htfields
     USING p_recna TYPE /sie/hr_idp_record_name p_sname.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    fields    LIKE LINE OF it_felder,
    sai       LIKE LINE OF it_sa_infty,
    value(256).

  PERFORM get_tag USING 'ht_fields' CHANGING tag.
  LOOP AT it_felder INTO fields WHERE recna = p_recna.
    CLEAR value.

    CASE fields-feldname.
      WHEN 'HT_DATUM'. value = 'sy-datum'.
      WHEN 'HT_URZEIT'. value = 'sy-uzeit'.
      WHEN 'HT_SYSTEM'. value = 'sy-sysid'.
      WHEN 'HT_MANDANT'. value = 'sy-mandt'.
      WHEN 'HT_BEZUGSDATUM'. value = 'g_datum'.
      WHEN 'HT_RECORD_COUNT'. value = 'g_recordcount'.
      WHEN 'HT_PERNR_COUNT'. value = 'g_pernrcount'.
      WHEN 'HT_FILESIZE'. value = 'g_filesize'.
      WHEN 'HT_VERSION'. CONCATENATE '''' g_version '''' INTO value.
      WHEN 'HT_FILENAME'. value = 'DSN'.
    ENDCASE.
    PERFORM replace_param USING 'VALUE' value  tag
                          CHANGING result.
    MOVE result[] TO input[].
    PERFORM replace_param USING 'SNAME' p_sname  input CHANGING result.
    MOVE result[] TO input[].
    PERFORM replace_param USING 'FNAME' fields-selname  input
                          CHANGING result.
    IF NOT value IS INITIAL.
      PERFORM insert_code USING result.
    ENDIF.
  ENDLOOP.
*$<ht_fields>
*$  move &value
*$    to itab_&sname-&fname.
*$</ht_fields>
ENDFORM.


*---------------------------------------------------------------------*
*       FORM PROCESS_SATZART_PERNR                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_RECNA                                                       *
*---------------------------------------------------------------------*
FORM process_satzart_pernr
     USING p_recna TYPE /sie/hr_idp_record_name p_sname.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    fields    LIKE LINE OF it_felder,
    sai       LIKE LINE OF it_sa_infty.                                .

  PERFORM get_tag USING 'sa_pernr' CHANGING tag.
  LOOP AT it_felder INTO fields WHERE recna = p_recna
                                  AND feldname = 'PERNR '. "satzart

    PERFORM replace_param USING 'RECNA' p_sname  tag
                          CHANGING result.
    PERFORM insert_code USING result.
  ENDLOOP.
*$<sa_pernr>
*$* Konstante Personalnummer
*$  move pernr-pernr to itab_&recna-f_pernr.
*$</sa_pernr>
ENDFORM.




*---------------------------------------------------------------------*
*       FORM PROCESS_SATZART_INFOTYP                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_RECNA                                                       *
*---------------------------------------------------------------------*
FORM process_satzart_infotyp
     USING p_sa LIKE LINE OF it_satzart.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    tag2      TYPE /sie/hr_idp_tt_coding,
    tag_endif TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    fields    LIKE LINE OF it_felder,
    sai       LIKE LINE OF it_sa_infty.                                .

  PERFORM get_tag USING 'sa_infty' CHANGING tag.
  PERFORM get_tag USING 'endif' CHANGING tag_endif.
  LOOP AT it_sa_infty INTO sai WHERE recna = p_sa-recna.
    IF NOT ( p_sa-recty = '4' AND
             p_sa-infty = sai-infty ).
*            and p_sa-subty = sai-subty ).
      IF p_sa-recty EQ '4'.
        PERFORM replace_param USING 'STRUC' p_sa-infty tag
                              CHANGING result.
      ELSE.
        PERFORM replace_param USING 'STRUC' 'N' tag
                              CHANGING result.
      ENDIF.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'INFTY' sai-infty input
                            CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'SUBTY' sai-subty input
                           CHANGING result.
      PERFORM insert_code USING result.
      PERFORM process_sa_infty_feld USING p_sa-recna
                                         sai-infty sai-subty.
      PERFORM insert_code USING tag_endif.
    ENDIF.
  ENDLOOP.

*$<sa_infty>
*$*Einmaldaten aus Infotyp: &INFTY - Subtyp: &SUBTY
*$    RP_PROVIDE_FROM_LAST P&INFTY '&SUBTY' P&STRUC-BEGDA P&STRUC-ENDDA.
*$    IF PNP-SW-FOUND EQ '1'.
*$</sa_infty>
*$<endif>
*$    endif.
*$</endif>
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_SATZART_IT_LOOP                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_RECNA                                                       *
*---------------------------------------------------------------------*
FORM process_satzart_it_loop
     USING p_recna TYPE /sie/hr_idp_record_name.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    tag2      TYPE /sie/hr_idp_tt_coding,
    tag3      TYPE /sie/hr_idp_tt_coding,
    tag4      TYPE /sie/hr_idp_tt_coding,                  "SIE008
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    fields    LIKE LINE OF it_felder,
    wsa       LIKE LINE OF it_satzart,
    comment,
    vglwert(62) TYPE c.

  PERFORM get_tag USING 'sa_infty_loop'       CHANGING tag.
  PERFORM get_tag USING 'sa_infty_subty_loop' CHANGING tag2.
  PERFORM get_tag USING 'sa_infty_loop_end'   CHANGING tag3.
  PERFORM get_tag USING 'sa_infty_loop_date'  CHANGING tag4."SIE008
  READ TABLE it_satzart WITH KEY recna = p_recna INTO wsa.
  IF wsa-subty IS INITIAL.
    PERFORM replace_param USING 'INFTY' wsa-infty tag
                          CHANGING result.
  ELSE.
    PERFORM replace_param USING 'INFTY' wsa-infty tag2
                          CHANGING result.
    MOVE result[] TO input[].
    PERFORM replace_param USING 'SUBTY' wsa-subty input
                          CHANGING result.
  ENDIF.
  PERFORM insert_code USING result.

* Berechnung des Hilfsdatums für Semantikklasse 0005       "SIE008
  PERFORM replace_param USING 'INFTY' wsa-infty tag4       "SIE008
                        CHANGING result.                   "SIE008
  PERFORM insert_code USING result.                        "SIE008

* einfügen der gebildeten Begriffe - zum jeweiligen Endedatum
  PERFORM process_satzart_begriff USING wsa.

* einfügen der singulären Felder aus anderen Infotypen
* wird an dieser Stelle jetzt doch unterstützt
  PERFORM process_satzart_infotyp USING wsa.


  PERFORM process_sa_infty_feld USING p_recna wsa-infty wsa-subty.

  PERFORM process_field_filter USING p_recna.              "SIE002

  PERFORM replace_param USING 'RECNA' wsa-sname tag3
                        CHANGING result.
  CLEAR comment.
  IF wsa-operan IS INITIAL.
    comment = '*'.
  ELSE.
    MOVE result[] TO input[].
    READ TABLE it_felder WITH KEY recna = wsa-recna
                                  feldname = wsa-operan
                         INTO fields
                         TRANSPORTING selname.
    IF sy-subrc > 0. comment = '*'. ENDIF.
    IF wsa-operat IS INITIAL. comment = '*'. ENDIF.
    PERFORM replace_param USING 'OPERAN' fields-selname input
                          CHANGING result.
    MOVE result[] TO input[].
    PERFORM replace_param USING 'OPERAT' wsa-operat input
                          CHANGING result.
    MOVE result[] TO input[].

    MOVE wsa-opeval TO vglwert.
    TRANSLATE vglwert TO UPPER CASE.
    IF vglwert = 'SYDATUM'.
      PERFORM replace_param USING 'OPEVAL' 'g_datum' input
                            CHANGING result.
    ELSE.
      CONCATENATE '''' wsa-opeval '''' INTO vglwert.
      PERFORM replace_param USING 'OPEVAL' vglwert input
                            CHANGING result.
    ENDIF.

  ENDIF.
  MOVE result[] TO input[].
  PERFORM replace_param USING 'COMMENT' comment input
                        CHANGING result.


  PERFORM insert_code USING result.

* DW001
*$<sa_infty_loop>
*$* Wiederholdaten aus Infotyp: &INFTY - Alle Subtypen
*$  LOOP AT P&INFTY WHERE ENDDA GE PN-BEGDA AND BEGDA LE PN-ENDDA.
*$</sa_infty_loop>

*$<sa_infty_subty_loop>
*$* Wiederholdaten aus Infotyp: &INFTY - Subtyp: &SUBTY
*$  LOOP AT P&INFTY
*$       WHERE subty EQ '&SUBTY'
*$         and ENDDA GE PN-BEGDA AND BEGDA LE PN-ENDDA.
*$</sa_infty_subty_loop>

*SIE008_BEG
*$<sa_infty_loop_date>
*$* Lesedatum für geb. Begriffe mit SEMCLS 5 ermitteln
*$  IF P&INFTY-ENDDA < SY-DATUM.
*$     H_REC_DATE = P&INFTY-ENDDA.
*$  ELSEIF P&INFTY-BEGDA > SY-DATUM.
*$     H_REC_DATE = P&INFTY-BEGDA.
*$  ELSE.
*$     H_REC_DATE = SY-DATUM.
*$  ENDIF.
*$* An Schnittstellendatum anpassen
*$  IF H_REC_DATE < PN-BEGDA.
*$     H_REC_DATE = PN-BEGDA.
*$  ENDIF.
*$  IF H_REC_DATE > PN-ENDDA.
*$     H_REC_DATE = PN-ENDDA.
*$  ENDIF.
*$</sa_infty_loop_date>
*SIE008_END

*$<sa_infty_loop_end>
*&*Append bei Wiederholdaten.
*$*Hier kann ein Filter auf Satzartebene eingebaut werden
*$&COMMENT   if ITAB_&RECNA-&OPERAN &OPERAT &OPEVAL.
*$        APPEND ITAB_&RECNA. "Wiederholdaten
*$&COMMENT   endif.
*$  ENDLOOP.
*$</sa_infty_loop_end>
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_SATZART_IT_PROVIDE                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_RECNA                                                       *
*---------------------------------------------------------------------*
FORM process_satzart_it_provide
     USING p_recna TYPE /sie/hr_idp_record_name.
  DATA:
    l           TYPE LINE OF /sie/hr_idp_tt_coding,
    tag_provide TYPE /sie/hr_idp_tt_coding,
    tag_it      TYPE /sie/hr_idp_tt_coding,
    tag_between TYPE /sie/hr_idp_tt_coding,
    tag_end     TYPE /sie/hr_idp_tt_coding,
    input       TYPE /sie/hr_idp_tt_coding,
    result      TYPE /sie/hr_idp_tt_coding,
    fields      LIKE LINE OF it_felder,
  sai         LIKE LINE OF it_sa_infty.                                .

  PERFORM get_tag USING 'sa_infty_provide' CHANGING tag_provide.
  PERFORM get_tag USING 'sa_infty_provide_it' CHANGING tag_it.
  PERFORM get_tag USING 'sa_infty_provide_between' CHANGING tag_between.
  PERFORM get_tag USING 'sa_infty_provide_end' CHANGING tag_end.
  PERFORM insert_code USING tag_provide.
  LOOP AT it_sa_infty INTO sai WHERE recna = p_recna.
    PERFORM process_sa_provide_feld USING p_recna sai-infty.
    PERFORM replace_param USING 'INFTY' sai-infty tag_it
                          CHANGING result.
    PERFORM insert_code USING result.
  ENDLOOP.
  PERFORM insert_code USING tag_between.
  LOOP AT it_sa_infty INTO sai WHERE recna = p_recna.
    PERFORM process_sa_infty_feld USING p_recna sai-infty sai-subty.
  ENDLOOP.
  PERFORM replace_param USING 'RECNA' p_recna tag_end
                        CHANGING result.
  PERFORM insert_code USING result.
*$<sa_infty_provide>
*$  PROVIDE
*$</sa_infty_provide>
*$<sa_infty_provide_it>
*$  FROM P&INFTY
*$</sa_infty_provide_it>
*$<sa_infty_provide_between>
*$  BETWEEN pn-begda AND pn-endda.
*$</sa_infty_provide_between>
*$<sa_infty_provide_end>
*$    APPEND ITAB_&RECNA.
*$  ENDPROVIDE.
*$</sa_infty_provide_end>
ENDFORM.


*---------------------------------------------------------------------*
*       FORM PROCESS_SA_INFTY_FELD                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_RECNA                                                       *
*  -->  P_INFTY                                                       *
*---------------------------------------------------------------------*
FORM process_sa_infty_feld
     USING p_recna TYPE /sie/hr_idp_record_name
           p_infty TYPE infty
           p_subty TYPE subty.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    fields    LIKE LINE OF it_felder,
    sai       LIKE LINE OF it_sa_infty,
    sa        LIKE LINE OF it_satzart.

  PERFORM get_tag USING 'sa_infty_feld' CHANGING tag.
  LOOP AT it_felder INTO fields WHERE recna = p_recna
                                  AND dpftype = '1' "Infotypfelder
                                  AND infty = p_infty.
    CHECK fields-subty = p_subty OR p_subty IS INITIAL.

    PERFORM replace_param USING 'INFTY' fields-infty tag
                          CHANGING result.
    MOVE result[] TO input[].
    PERFORM replace_param USING 'FELD' fields-inftyfeld input
                          CHANGING result.
    MOVE result[] TO input[].
    READ TABLE it_satzart WITH KEY recna = fields-recna INTO sa.
    PERFORM replace_param USING 'RECNA' sa-sname input
                          CHANGING result.
    MOVE result[] TO input[].
    PERFORM replace_param USING 'FNAME' fields-selname input
                          CHANGING result.
    PERFORM insert_code USING result.
  ENDLOOP.
*$<sa_infty_feld>
*$    MOVE P&INFTY-&FELD
*$      TO ITAB_&RECNA-&FNAME.
*$</sa_infty_feld>
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_SA_PROVIDE_FELD                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_RECNA                                                       *
*  -->  P_INFTY                                                       *
*---------------------------------------------------------------------*
FORM process_sa_provide_feld
     USING p_recna TYPE /sie/hr_idp_record_name
           p_infty TYPE infty.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    fields    LIKE LINE OF it_felder,
    sai       LIKE LINE OF it_sa_infty.                                .

  PERFORM get_tag USING 'sa_provide_feld' CHANGING tag.
  LOOP AT it_felder INTO fields WHERE recna = p_recna
                                  AND dpftype = '1' "Infotypfelder
                                  AND infty = p_infty
                                  AND NOT (    inftyfeld EQ 'BEGDA'
                                            OR inftyfeld EQ 'ENDDA' ).
    PERFORM replace_param USING 'FELD' fields-inftyfeld tag
                          CHANGING result.
    PERFORM insert_code USING result.
  ENDLOOP.
*$<sa_provide_feld>
*$    &FELD
*$</sa_provide_feld>
ENDFORM.


*---------------------------------------------------------------------*
*       FORM PROCESS_SATZART_BEGRIFF                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_RECNA                                                       *
*---------------------------------------------------------------------*
FORM process_satzart_begriff
     USING p_sa LIKE LINE OF it_satzart.
  DATA: fields LIKE LINE OF it_felder.
  DATA fieldname(70) TYPE c.
  LOOP AT it_felder INTO fields WHERE recna = p_sa-recna
                                  AND dpftype = '2'. "gebildete Begriffe
    CONCATENATE 'ITAB_' p_sa-sname '-' fields-selname INTO fieldname.
    CASE fields-semcls.
      WHEN '0001'
        OR '0005'.                                         "SIE008
        PERFORM process_satzart_begriff_0001
          USING fields fieldname p_sa.
      WHEN '0002'.
        PERFORM process_satzart_begriff_0002 USING fields fieldname.
      WHEN '0003'.
        PERFORM process_satzart_begriff_0003 USING fields fieldname.
      WHEN '0004'.
        PERFORM process_satzart_begriff_0004 USING fields fieldname.
    ENDCASE.
  ENDLOOP.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_SATZART_BEGRIFF_0001                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FIELDS                                                        *
*---------------------------------------------------------------------*
FORM process_satzart_begriff_0001
     USING fields LIKE LINE OF it_felder fieldname
           p_sa LIKE LINE OF it_satzart.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    tag2      TYPE /sie/hr_idp_tt_coding,
    tag3      TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    sai       LIKE LINE OF it_sa_infty.                                .

  PERFORM get_tag USING 'begriff' CHANGING tag.
  PERFORM get_tag USING 'begriff2' CHANGING tag2.
  PERFORM get_tag USING 'begriff3' CHANGING tag3.

  PERFORM replace_param USING 'FUBA' fields-funcname tag
                        CHANGING result.
  MOVE result[] TO input[].
  PERFORM replace_param USING 'BEGRIFF' fields-feldname input
                        CHANGING result.
  PERFORM insert_code USING result.
  PERFORM process_begriff_exportliste USING fields p_sa.
  PERFORM insert_code USING tag2.
  PERFORM process_begriff_importliste USING fields fieldname.
  PERFORM insert_code USING tag3.

*$<begriff>
*$* Gebildeter Begriff &BEGRIFF
*$  CALL FUNCTION '&FUBA'
*$       EXPORTING
*$</begriff>
*$<begriff2>
*$       IMPORTING
*$</begriff2>
*$<begriff3>
*$  .
*$</begriff3>

ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_BEGRIFF_EXPORTLISTE                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_FIELDS                                                      *
*---------------------------------------------------------------------*
FORM process_begriff_exportliste
     USING p_fields LIKE LINE OF it_felder
           p_sa LIKE LINE OF it_satzart.

  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    value     TYPE LINE OF /sie/hr_idp_tt_coding,
    nval(2)   TYPE n.

  PERFORM get_tag USING 'begriff_exportliste' CHANGING tag.
  SELECT * FROM fupararef WHERE funcname = p_fields-funcname
                            AND r3state = 'A'
                            AND paramtype  = 'I'.
    PERFORM replace_param USING 'PARAM' fupararef-parameter tag
                          CHANGING result.
    MOVE result[] TO input[].
    value = ''' '''.
    CASE fupararef-structure.
      WHEN 'PERSNO'.
        value = 'PERNR-PERNR'.
      WHEN 'BEGDA' OR 'ENDDA' OR 'DATUM'.
        IF p_sa-recty = '4'.
           IF p_fields-semcls = '0005'.                    "SIE008
*             Berechnetes Datum                            "SIE008
              value = 'H_REC_DATE'.                        "SIE008
           ELSE.                                           "SIE008
              CONCATENATE 'P' p_sa-infty '-ENDDA' INTO value.
           ENDIF.                                          "SIE008
        ELSE.
          value = 'PN-ENDDA'.
        ENDIF.
      WHEN 'LGART'.
        IF p_sa-recty = '4'.
          CONCATENATE 'P' p_sa-infty '-lgart' INTO value.
        ENDIF.
      WHEN 'XFELD'.
        IF fupararef-parameter(2) EQ 'PP'.
          value = '''X'''.
        ELSE.
          value = ''' '''.
        ENDIF.
      WHEN 'PA0003-ABRDT'.
        value = 'PN-ENDDA'.
      WHEN 'PNAFO'.
        IF  p_fields-paramgb IS INITIAL.
          value = '0'.
        ELSE.
          nval = p_fields-paramgb.
          value = nval.
*           CONCATENATE '''' p_fields-paramgb '''' INTO value.
        ENDIF.
      WHEN OTHERS.
        IF fupararef-parameter EQ 'SUMID'.
          CONCATENATE '''' p_fields-paramgb '''' INTO value.
        ELSEIF fupararef-parameter EQ 'PPARAM'.
          CONCATENATE '''' p_fields-paramgb '''' INTO value.
*       ELSE                                               "SIE006
        ELSEIF fupararef-structure CP '/SIE/HR_FTT_P++++'. "SIE006
          value = fupararef-structure+12(5).
          CONCATENATE value '[]' INTO value.
        ELSE.                                              "SIE006
          CONTINUE.                                        "SIE006
        ENDIF.
    ENDCASE.
    PERFORM replace_param USING 'VALUE' value input
                          CHANGING result.
    PERFORM insert_code USING result.
  ENDSELECT.
*$<begriff_exportliste>
*$          &PARAM =
*$&VALUE
*$</begriff_exportliste>
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_BEGRIFF_IMPORTLISTE                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_FIELDS                                                      *
*---------------------------------------------------------------------*
FORM process_begriff_importliste
     USING p_fields LIKE LINE OF it_felder fieldname.

  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    value     TYPE LINE OF /sie/hr_idp_tt_coding.

  PERFORM get_tag USING 'begriff_importliste' CHANGING tag.
  SELECT * FROM fupararef WHERE funcname = p_fields-funcname
                            AND r3state = 'A'
                            AND paramtype  = 'E'
                            AND parameter = p_fields-parameter.
    PERFORM replace_param USING 'PARAM' fupararef-parameter tag
                          CHANGING result.
    MOVE result[] TO input[].
    PERFORM replace_param USING 'FIELDNAME' fieldname input
                          CHANGING result.
    PERFORM insert_code USING result.
  ENDSELECT.
*$<begriff_importliste>
*$          &PARAM = &FIELDNAME
*$</begriff_importliste>
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_SATZART_BEGRIFF_0002                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FIELDS                                                        *
*---------------------------------------------------------------------*
FORM process_satzart_begriff_0002
     USING fields LIKE LINE OF it_felder fieldname.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    tag2      TYPE /sie/hr_idp_tt_coding,
    tag3      TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    sai       LIKE LINE OF it_sa_infty.                                .

  PERFORM get_tag USING 'begriff_0002' CHANGING tag.
  PERFORM get_tag USING 'begriff2' CHANGING tag2.
  PERFORM get_tag USING 'begriff3' CHANGING tag3.

  PERFORM replace_param USING 'FUBA' fields-funcname tag
                        CHANGING result.
  MOVE result[] TO input[].
  PERFORM replace_param USING 'BEGRIFF' fields-feldname input
                        CHANGING result.
  MOVE result[] TO input[].
  PERFORM replace_param USING 'PARAM' fields-paramgb input
                 CHANGING result.
  PERFORM insert_code USING result.
  PERFORM insert_code USING tag2.
  PERFORM process_begriff_importliste USING fields fieldname.
  PERFORM insert_code USING tag3.

*$<begriff_0002>
*$* Gebildeter Begriff &BEGRIFF
*$  CALL FUNCTION '&FUBA'
*$       EXPORTING PARAM =
*$'&PARAM'
*$</begriff_0002>
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_SATZART_BEGRIFF_0003                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FIELDS                                                        *
*  -->  FIELDNAME                                                     *
*---------------------------------------------------------------------*
FORM process_satzart_begriff_0003
     USING fields LIKE LINE OF it_felder fieldname.
    DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    tag2      TYPE /sie/hr_idp_tt_coding,
    tag3      TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    sai       LIKE LINE OF it_sa_infty,
    param     TYPE /sie/hr_f_sname,
    delta(3)  TYPE n.

   data:
    tag_lgartsum      TYPE /sie/hr_idp_tt_coding,
    tag_lgartsum_crt  TYPE /sie/hr_idp_tt_coding,
    tag_awartsum      TYPE /sie/hr_idp_tt_coding.

  PERFORM get_tag USING 'begriff_0003' CHANGING tag.
  PERFORM get_tag USING 'begriff2' CHANGING tag2.
  PERFORM get_tag USING 'begriff3' CHANGING tag3.

  PERFORM get_tag USING 'begriff_lgartsum'     CHANGING tag_lgartsum.
  PERFORM get_tag USING 'begr_lgartsum_crt' CHANGING tag_lgartsum_crt.
  PERFORM get_tag USING 'begriff_awartsum'     CHANGING tag_awartsum.

  case fields-funcname.
   when '/SIE/HR_FGB_LGARTSUM'.
        PERFORM replace_param
                USING 'FUBA' fields-funcname tag_lgartsum
                CHANGING result.
   when '/SIE/HR_FGB_LGARTSUM_CRT'.
        PERFORM replace_param
                USING 'FUBA' fields-funcname tag_lgartsum_crt
                CHANGING result.
   when '/SIE/HR_FGB_AWARTSUM'.
        PERFORM replace_param
                USING 'FUBA' fields-funcname tag_awartsum
                CHANGING result.
  when others.
   PERFORM replace_param
                USING 'FUBA' fields-funcname tag
                CHANGING result.
endcase.

  MOVE result[] TO input[].
  PERFORM replace_param USING 'BEGRIFF' fields-feldname input
                        CHANGING result.
  MOVE result[] TO input[].
  PERFORM replace_param USING 'DELTA' fields-mthbk input
                 CHANGING result.
  MOVE result[] TO input[].
  PERFORM replace_param USING 'PARAM' fields-paramgb input
                 CHANGING result.
  PERFORM insert_code USING result.
  PERFORM insert_code USING tag2.
  PERFORM process_begriff_importliste USING fields fieldname.



 PERFORM insert_code USING tag3.

*$<begriff_0003>
*$* Gebildeter Begriff &BEGRIFF
*$  g_perid = pn-endda(6).
*$  read table it_rd with key mthbk = '&DELTA'.
*$  CALL FUNCTION '&FUBA'
*$       EXPORTING persn = pernr-pernr
*$                 perid = g_perid
*$                 delta = '&DELTA'
*$                 sumid =
*$'&PARAM'
*$                 aab = it_rd-payde_result-inter-ab
*$                 aab_is_supplied = 'X'
*$                 rrt = it_rd-payde_result-inter-rt
*$                 RRT_IS_SUPPLIED = 'X'
*$                 RCRT = it_rd-payde_result-inter-crt
*$                 RCRT_IS_SUPPLIED = 'X'
*$</begriff_0003>



*$<begriff_lgartsum>
*$* Gebildeter Begriff &BEGRIFF
*$  g_perid = pn-endda(6).
*$  read table it_rd with key mthbk = '&DELTA'.
*$  CALL FUNCTION '&FUBA'
*$       EXPORTING persn = pernr-pernr
*$                 perid = g_perid
*$                 delta = '&DELTA'
*$                 sumid =
*$'&PARAM'
*$                 rrt = it_rd-payde_result-inter-rt
*$                 RRT_IS_SUPPLIED = 'X'
*$</begriff_lgartsum>

*$<begr_lgartsum_crt>
*$* Gebildeter Begriff &BEGRIFF
*$  g_perid = pn-endda(6).
*$  read table it_rd with key mthbk = '&DELTA'.
*$  CALL FUNCTION '&FUBA'
*$       EXPORTING persn = pernr-pernr
*$                 perid = g_perid
*$                 delta = '&DELTA'
*$                 sumid =
*$'&PARAM'
*$                 RCRT = it_rd-payde_result-inter-crt
*$                 RCRT_IS_SUPPLIED = 'X'
*$</begr_lgartsum_crt>


*$<begriff_awartsum>
*$* Gebildeter Begriff &BEGRIFF
*$  g_perid = pn-endda(6).
*$  read table it_rd with key mthbk = '&DELTA'.
*$  CALL FUNCTION '&FUBA'
*$       EXPORTING persn = pernr-pernr
*$                 perid = g_perid
*$                 delta = '&DELTA'
*$                 sumid =
*$'&PARAM'
*$                 aab = it_rd-payde_result-inter-ab
*$                 aab_is_supplied = 'X'
*$</begriff_awartsum>

ENDFORM.

FORM process_satzart_begriff_0004
     USING fields LIKE LINE OF it_felder fieldname.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    tag2      TYPE /sie/hr_idp_tt_coding,
    tag3      TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    sai       LIKE LINE OF it_sa_infty,
    param     TYPE /sie/hr_f_sname,
    lgart     TYPE lgart,
    lgafd.

  PERFORM get_tag USING 'begriff_0004' CHANGING tag.
  PERFORM get_tag USING 'begriff2' CHANGING tag2.
  PERFORM get_tag USING 'begriff3' CHANGING tag3.

  PERFORM replace_param USING 'FUBA' fields-funcname tag
                        CHANGING result.
  MOVE result[] TO input[].
  PERFORM replace_param USING 'BEGRIFF' fields-feldname input
                        CHANGING result.
  MOVE result[] TO input[].
  SPLIT fields-paramgb AT ';' INTO lgart lgafd.
  PERFORM replace_param USING 'LGART' lgart input
                 CHANGING result.
  MOVE result[] TO input[].
  PERFORM replace_param USING 'LGAFD' lgafd input
                 CHANGING result.
  PERFORM insert_code USING result.
  PERFORM insert_code USING tag2.
  PERFORM process_begriff_importliste USING fields fieldname.
  PERFORM insert_code USING tag3.

*$<begriff_0004>
*$* Gebildeter Begriff &BEGRIFF
*$  g_perid = pn-endda(6).
*$  CALL FUNCTION '&FUBA'
*$       EXPORTING persn = pernr-pernr
*$                 perid = g_perid
*$                 LGART = '&LGART'
*$                 LGAFD = '&LGAFD'
*$</begriff_0004>
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_CONVERT                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_convert.
  DATA:
    l          TYPE LINE OF /sie/hr_idp_tt_coding,
    tag_copy   TYPE /sie/hr_idp_tt_coding,
    tag_move   TYPE /sie/hr_idp_tt_coding,
    tag_conv   TYPE /sie/hr_idp_tt_coding,
    tag_append TYPE /sie/hr_idp_tt_coding,
    tag        TYPE /sie/hr_idp_tt_coding,
    result     TYPE /sie/hr_idp_tt_coding,
    input      TYPE /sie/hr_idp_tt_coding,
    fields     LIKE LINE OF it_felder,
*    HELP      TYPE STRING, "SIE002
    help(72)  TYPE c,       "SIE002
    sa         LIKE LINE OF it_satzart.


  PERFORM get_tag USING 'copy' CHANGING tag_copy.
  PERFORM get_tag USING 'move' CHANGING tag_move.
  PERFORM get_tag USING 'convert' CHANGING tag_conv.
  PERFORM get_tag USING 'append' CHANGING tag_append.
  LOOP AT it_satzart INTO sa WHERE recty = '3' OR recty = '4'.
    PERFORM replace_param USING 'SA' sa-sname tag_copy
                          CHANGING result.
    PERFORM insert_code USING result.
    LOOP AT it_felder INTO fields
                      WHERE recna = sa-recna.
      IF fields-conf_funcname NE ' '.
        MOVE tag_conv[] TO tag[].
      ELSE.
        MOVE tag_move[] TO tag[].
      ENDIF.
      PERFORM replace_param USING 'FUBA' fields-conf_funcname tag
                            CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'SA' sa-sname input
                              CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'PARAMETERS'
*                                   fields-conf_ctrl_value input
                                  fields-param input
                            CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'FNAME' fields-selname input
                            CHANGING result.
      PERFORM insert_code USING result.
    ENDLOOP.
    PERFORM replace_param USING 'SA' sa-sname tag_append
                          CHANGING result.
    PERFORM insert_code USING result.
  ENDLOOP.
*$<copy>
*$
*$* Aufbereitung für Ausgabe Satzart: &sa
*$  loop at itab_&sa.
*$</copy>

*$<move>
*$    move itab_&sa-&fname
*$    to itab_out_&sa-&fname.
*$
*$</move>

*$<convert>
*$    CALL FUNCTION '&fuba'
*$         EXPORTING
*$              p_in         = itab_&sa-&fname
*$              p_parameters =
*$'&parameters'
*$        IMPORTING
*$              P_OUT        = itab_out_&sa-&fname.
*$
*$</convert>

*$<append>
*$    append itab_out_&sa.
*$  endloop.
*$* Ende der Aufbereitung Satzart: &sa
*$
*$</append>

ENDFORM.

*FORM PROCESS_CONVERT_ALT.
*  DATA:
*    L         TYPE LINE OF /SIE/HR_IDP_TT_CODING,
*    TAG       TYPE /SIE/HR_IDP_TT_CODING,
*    TAG2      TYPE /SIE/HR_IDP_TT_CODING,
*    TAG3      TYPE /SIE/HR_IDP_TT_CODING,
*    RESULT    TYPE /SIE/HR_IDP_TT_CODING,
*    INPUT     TYPE /SIE/HR_IDP_TT_CODING,
*    FIELDS    LIKE LINE OF IT_FELDER,
*    HELP      TYPE STRING,
*    SA        LIKE LINE OF IT_SATZART.
*
*
*  PERFORM GET_TAG USING 'copy' CHANGING TAG.
*  PERFORM GET_TAG USING 'convert' CHANGING TAG2.
*  PERFORM GET_TAG USING 'append' CHANGING TAG3.
*  LOOP AT IT_SATZART INTO SA.
*    PERFORM REPLACE_PARAM USING 'SA' SA-SNAME TAG
*                          CHANGING RESULT.
*    PERFORM INSERT_CODE USING RESULT.
*    LOOP AT IT_FELDER INTO FIELDS
*                      WHERE RECNA = SA-RECNA
*                      AND CONF_FUNCNAME NE ' '.
*      PERFORM REPLACE_PARAM USING 'FNAME' FIELDS-CONF_FUNCNAME TAG2
*                            CHANGING RESULT.
*      MOVE RESULT[] TO INPUT[].
*      CONCATENATE 'itab_' SA-SNAME '-' FIELDS-SELNAME INTO HELP.
*      PERFORM REPLACE_PARAM USING 'IN' HELP INPUT
*                            CHANGING RESULT.
*      MOVE RESULT[] TO INPUT[].
*      PERFORM REPLACE_PARAM USING 'PARAMETERS'
*                                   FIELDS-CONF_CTRL_VALUE INPUT
*                            CHANGING RESULT.
*      MOVE RESULT[] TO INPUT[].
*      CONCATENATE 'itab_out_' SA-SNAME '-C_' FIELDS-SELNAME
*             INTO HELP.
*      PERFORM REPLACE_PARAM USING 'OUT' HELP INPUT
*                            CHANGING RESULT.
*      PERFORM INSERT_CODE USING RESULT.
*    ENDLOOP.
*    PERFORM REPLACE_PARAM USING 'SA' SA-SNAME TAG3
*                          CHANGING RESULT.
*    PERFORM INSERT_CODE USING RESULT.
*  ENDLOOP.
**$<copy>
**$
**$* Aufbereitung für Ausgabe Satzart: &sa
**$  loop at itab_&sa.
**$*   Felder ohne Konvertierung
**$    move-corresponding itab_&sa
**$    to itab_out_&sa.
**$
**$*   Aufrufe der Konvertierungsbausteine
**$</copy>
*
**$<convert>
**$    CALL FUNCTION '&fname'
**$         EXPORTING
**$              p_in         = &in
**$              p_parameters =
**$'&parameters'
**$        IMPORTING
**$              P_OUT        = &out.
**$
**$</convert>
*
**$<append>
**$    append itab_out_&sa.
**$  endloop.
**$* Ende der Aufbereitung Satzart: &sa
**$
**$</append>
*
*ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_END_OF_GET                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_transfer.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    sa        LIKE LINE OF it_satzart.


  PERFORM get_tag USING 'transfer' CHANGING tag.
  LOOP AT it_satzart INTO sa WHERE recty = '3' OR recty = '4'.
    PERFORM replace_param USING 'SA' sa-sname tag
                          CHANGING result.
    PERFORM insert_code USING result.
  ENDLOOP.
*$<transfer>
*$  loop at itab_out_&sa.
*$    perform trans_&sa
*$       using itab_out_&sa.
*$  endloop.
*$  commit work.
*$</transfer>

ENDFORM.                    " PROCESS_END_OF_GET

*---------------------------------------------------------------------*
*       FORM PROCESS_HEADER_TRANSFER                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_header_transfer.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    sa        LIKE LINE OF it_satzart.


  PERFORM get_tag USING 'transfer' CHANGING tag.
  LOOP AT it_satzart INTO sa WHERE recty = '1'.
    PERFORM replace_param USING 'SA' sa-sname tag
                          CHANGING result.
    PERFORM insert_code USING result.
  ENDLOOP.
ENDFORM.                    " PROCESS_END_OF_GET

*---------------------------------------------------------------------*
*       FORM PROCESS_HEADER_SATZART                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_header_satzart.
  DATA:
    l           TYPE LINE OF /sie/hr_idp_tt_coding,
    tag         TYPE /sie/hr_idp_tt_coding,
    tag_append  TYPE /sie/hr_idp_tt_coding,
    tag3        TYPE /sie/hr_idp_tt_coding,
    result      TYPE /sie/hr_idp_tt_coding,
    input       TYPE /sie/hr_idp_tt_coding,
    sa          LIKE LINE OF it_satzart,
    feld        LIKE LINE OF it_felder,
    comment,
    vglwert(62) TYPE c.
  PERFORM get_tag USING 'satzart1' CHANGING tag.
  PERFORM get_tag USING 'satzart_append' CHANGING tag_append.
  PERFORM get_tag USING 'satzart3' CHANGING tag3.
  LOOP AT it_satzart INTO sa.
    CASE sa-recty.
      WHEN '1'. "Headersatz
        PERFORM replace_param USING 'RECNA' sa-sname tag
                              CHANGING result.
        MOVE result[] TO input[].
        PERFORM replace_param USING 'RECTY' sa-recty input
                              CHANGING result.
        PERFORM insert_code USING result.
        PERFORM process_satzart_satzart USING sa-recna sa-sname.
        PERFORM process_satzart_begriff USING sa.
        PERFORM process_satzart_htfields USING sa-recna sa-sname.
        comment = '*'.
        PERFORM replace_param USING 'RECNA' sa-sname tag_append
                              CHANGING result.
        MOVE result[] TO input[].
        PERFORM replace_param USING 'COMMENT' comment input
                             CHANGING result.
        PERFORM insert_code USING result.
        PERFORM replace_param USING 'RECNA' sa-sname tag3
                              CHANGING result.
        PERFORM insert_code USING result.
    ENDCASE.
  ENDLOOP.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_HEADER_CONVERT                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_header_convert.
  DATA:
    l          TYPE LINE OF /sie/hr_idp_tt_coding,
    tag_copy   TYPE /sie/hr_idp_tt_coding,
    tag_move   TYPE /sie/hr_idp_tt_coding,
    tag_conv   TYPE /sie/hr_idp_tt_coding,
    tag_append TYPE /sie/hr_idp_tt_coding,
    tag        TYPE /sie/hr_idp_tt_coding,
    result     TYPE /sie/hr_idp_tt_coding,
    input      TYPE /sie/hr_idp_tt_coding,
    fields     LIKE LINE OF it_felder,
*    HELP      TYPE STRING, "SIE002
    help(72)  TYPE c,       "SIE002
    sa         LIKE LINE OF it_satzart.


  PERFORM get_tag USING 'copy' CHANGING tag_copy.
  PERFORM get_tag USING 'move' CHANGING tag_move.
  PERFORM get_tag USING 'convert' CHANGING tag_conv.
  PERFORM get_tag USING 'append' CHANGING tag_append.
  LOOP AT it_satzart INTO sa WHERE recty = '1'.
    PERFORM replace_param USING 'SA' sa-sname tag_copy
                          CHANGING result.
    PERFORM insert_code USING result.
    LOOP AT it_felder INTO fields
                      WHERE recna = sa-recna.
      IF fields-conf_funcname NE ' '.
        MOVE tag_conv[] TO tag[].
      ELSE.
        MOVE tag_move[] TO tag[].
      ENDIF.
      PERFORM replace_param USING 'FUBA' fields-conf_funcname tag
                            CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'SA' sa-sname input
                              CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'PARAMETERS'
                                   fields-conf_ctrl_value input
                            CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'FNAME' fields-selname input
                            CHANGING result.
      PERFORM insert_code USING result.
    ENDLOOP.
    PERFORM replace_param USING 'SA' sa-sname tag_append
                          CHANGING result.
    PERFORM insert_code USING result.
  ENDLOOP.

ENDFORM.


*---------------------------------------------------------------------*
*       FORM PROCESS_TRAILER_SATZART                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_trailer_satzart.
  DATA:
    l           TYPE LINE OF /sie/hr_idp_tt_coding,
    tag         TYPE /sie/hr_idp_tt_coding,
    tag_append  TYPE /sie/hr_idp_tt_coding,
    tag3        TYPE /sie/hr_idp_tt_coding,
    result      TYPE /sie/hr_idp_tt_coding,
    input       TYPE /sie/hr_idp_tt_coding,
    sa          LIKE LINE OF it_satzart,
    feld        LIKE LINE OF it_felder,
    comment,
    vglwert(62) TYPE c.
  PERFORM get_tag USING 'satzart1' CHANGING tag.
  PERFORM get_tag USING 'satzart_append' CHANGING tag_append.
  PERFORM get_tag USING 'satzart3' CHANGING tag3.
  LOOP AT it_satzart INTO sa.
    CASE sa-recty.
      WHEN '5'. "Trailersatz
        PERFORM replace_param USING 'RECNA' sa-sname tag
                              CHANGING result.
        MOVE result[] TO input[].
        PERFORM replace_param USING 'RECTY' sa-recty input
                              CHANGING result.
        PERFORM insert_code USING result.
        PERFORM process_satzart_satzart USING sa-recna sa-sname.
        PERFORM process_satzart_begriff USING sa.
        PERFORM process_satzart_htfields USING sa-recna sa-sname.
        comment = '*'.
        PERFORM replace_param USING 'RECNA' sa-sname tag_append
                              CHANGING result.
        MOVE result[] TO input[].
        PERFORM replace_param USING 'COMMENT' comment input
                             CHANGING result.
        PERFORM insert_code USING result.
        PERFORM replace_param USING 'RECNA' sa-sname tag3
                              CHANGING result.
        PERFORM insert_code USING result.
    ENDCASE.
  ENDLOOP.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_TRAILER_CONVERT                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_trailer_convert.
  DATA:
    l          TYPE LINE OF /sie/hr_idp_tt_coding,
    tag_copy   TYPE /sie/hr_idp_tt_coding,
    tag_move   TYPE /sie/hr_idp_tt_coding,
    tag_conv   TYPE /sie/hr_idp_tt_coding,
    tag_append TYPE /sie/hr_idp_tt_coding,
    tag        TYPE /sie/hr_idp_tt_coding,
    result     TYPE /sie/hr_idp_tt_coding,
    input      TYPE /sie/hr_idp_tt_coding,
    fields     LIKE LINE OF it_felder,
*    HELP      TYPE STRING, "SIE002
    help(72)  TYPE c,       "SIE002
    sa         LIKE LINE OF it_satzart.


  PERFORM get_tag USING 'copy' CHANGING tag_copy.
  PERFORM get_tag USING 'move' CHANGING tag_move.
  PERFORM get_tag USING 'convert' CHANGING tag_conv.
  PERFORM get_tag USING 'append' CHANGING tag_append.
  LOOP AT it_satzart INTO sa WHERE recty = '5'.
    PERFORM replace_param USING 'SA' sa-sname tag_copy
                          CHANGING result.
    PERFORM insert_code USING result.
    LOOP AT it_felder INTO fields
                      WHERE recna = sa-recna.
      IF fields-conf_funcname NE ' '.
        MOVE tag_conv[] TO tag[].
      ELSE.
        MOVE tag_move[] TO tag[].
      ENDIF.
      PERFORM replace_param USING 'FUBA' fields-conf_funcname tag
                            CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'SA' sa-sname input
                              CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'PARAMETERS'
                                   fields-conf_ctrl_value input
                            CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'FNAME' fields-selname input
                            CHANGING result.
      PERFORM insert_code USING result.
    ENDLOOP.
    PERFORM replace_param USING 'SA' sa-sname tag_append
                          CHANGING result.
    PERFORM insert_code USING result.
  ENDLOOP.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_TRAILER_TRANSFER                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_trailer_transfer.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    sa        LIKE LINE OF it_satzart.


  PERFORM get_tag USING 'transfer' CHANGING tag.
  LOOP AT it_satzart INTO sa WHERE recty = '5'.
    PERFORM replace_param USING 'SA' sa-sname tag
                          CHANGING result.
    PERFORM insert_code USING result.
  ENDLOOP.
ENDFORM.                    " PROCESS_END_OF_GET
*&---------------------------------------------------------------------*
*&      Form  PROCESS_PRE_SELECTION                         "SIE009
*&---------------------------------------------------------------------*
*       Vorselektionsprogramm aufrufen und Daten übernehmen
*----------------------------------------------------------------------*
form PROCESS_PRE_SELECTION using p_trans type /SIE/HR_IDP_IFC_DB."SIE009

  DATA:
    tag TYPE /sie/hr_idp_tt_coding,
    result type /sie/hr_idp_tt_coding.

* Nur wenn Vorselektionsprogramm eingestellt
  check not p_trans-s1df-psel_report  is INITIAL and
        not p_trans-s1df-psel_variant is initial.

  PERFORM get_tag USING 'pre_selection' CHANGING tag.

* Parameter Programmname *
  perform replace_param using 'REPORT'
                              p_trans-s1df-psel_report
                              tag
                     changing result.
  move result[] to tag[].

* Parameter Variantenname *
  perform replace_param using 'VARIANT'
                              p_trans-s1df-psel_variant
                              tag
                     changing result.
  move result[] to tag[].


  PERFORM insert_code USING tag.

*
*$<pre_selection>
*$*** PRE SELECTION ***
*$   DATA: lt_persn type table of persno.
*$
*$* Call Preselection Program
*$   SUBMIT &REPORT USING SELECTION-SET '&VARIANT'
*$                  WITH pnptimed = ' '
*$                  WITH pnpbegda = pn-begda
*$                  WITH pnpendda = pn-endda
*$                  WITH pnpbegps = pn-begps
*$                  WITH pnpendps = pn-endps
*$                  WITH pif_date = g_datum
*$                  WITH pif_file = dsn
*$                  AND RETURN.
*$
*$* Import selected employees from pre-selection program via memory
*$   IMPORT t_persno = lt_persn FROM MEMORY ID 'IDP_SELECTION'.
*$
*SIE010_BEG
*$* Sort imported table to ensure clean sorted output
*$   SORT lt_persn.
*$   DELETE ADJACENT DUPLICATES FROM lt_persn.
*SIE010_END
*$
*$* Transfer selected employees to PNPINDEX
*$   REFRESH pnpindex.
*$   CLEAR pnpindex.
*$   pnpindex-sign   = 'I'.
*$   pnpindex-option = 'EQ'.
*$   pnpindex-low    = '00000000'.
*$   APPEND pnpindex.  "Dummy entry, to ensure a no-hit selection
*$                     "in case of an empty pre-selection
*$
*$   LOOP AT lt_persn INTO pnpindex-low.
*$      APPEND pnpindex.
*$   ENDLOOP.
*$
*$*** PRE SELECTION END ***
*$</pre_selection>

endform.                    " PROCESS_PRE_SELECTION
*&---------------------------------------------------------------------*
*&      Form  PROCESS_ARE_STATISTIC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TRANS_DATA_S1DF  text
*----------------------------------------------------------------------*
FORM PROCESS_ARE_STATISTIC  USING p_s1df LIKE /sie/hr_idp_s1df.
  DATA:
    tag TYPE /sie/hr_idp_tt_coding,
    result type /sie/hr_idp_tt_coding,
    lv_interface(30).

CONCATENATE p_s1df-IFCID p_s1df-VRSNR INTO lv_interface
                         SEPARATED BY ';'.
PERFORM get_tag USING 'are_statistic' CHANGING tag.

PERFORM replace_param USING 'LV_INTERFACE' LV_INTERFACE tag
                          CHANGING result.
move result[] to tag[].
PERFORM insert_code USING tag.

*$<are_statistic>
*$ if fl_testlf <> 'X'.
*$ CALL FUNCTION '/SIE/HR_FGB_ARE_SST_ANALYSE'
*$  EXPORTING
*$    PERNR                    = pernr-pernr
*$    BEGDA                    = pn-begda
*$    ENDDA                    = pn-endda
*$*   PP0001                   = p0001[]
*$*   PP0001_IS_SUPPLIED       = 'X'
*$    PPARAM                   = '&LV_INTERFACE'
*$          .
*$
*$ endif.
*$</are_statistic>

ENDFORM.
