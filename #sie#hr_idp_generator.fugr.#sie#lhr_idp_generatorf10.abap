*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_GENERATORF10 .
*----------------------------------------------------------------------*
*       P R O C E S S R O U T I N E N
*       D E K L A R A T I O N S T E I L
*&---------------------------------------------------------------------*
* Änderungen Hierl:  Dynse/Selektionsoption von HANSP nach ZZHANSP
*                                       und von PKAT  nach ZZPKAT

FORM process_infotypes.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    tag2      TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    infty_nr  TYPE infty,
    value LIKE LINE OF it_infotypes,
    occ(4) TYPE n.

  PERFORM get_tag USING 'infotypes' CHANGING tag.
  PERFORM get_tag USING 'infotype24' CHANGING tag2.

  LOOP AT it_infotypes INTO value.
    IF value = '0024'.
      PERFORM insert_code USING tag2.
      g_it24 = 'X'.
    ELSE.
      PERFORM replace_param USING 'INFTYNR' value tag
                            CHANGING result.
      MOVE result[] TO input[].
      CASE value.
        WHEN '0000'. occ = '10'.
        WHEN '0001'. occ = '10'.
        WHEN '0002'. occ = '2'.
        WHEN '0003'. occ = '1'.
        WHEN OTHERS. occ = '0'.
      ENDCASE.
      PERFORM replace_param USING 'OCCURS' occ input
                            CHANGING result.

      PERFORM insert_code USING result.
    ENDIF.
  ENDLOOP.
*$<infotypes>
*$INFOTYPES: &INFTYNR OCCURS &OCCURS.
*$</infotypes>
*$<infotype24>
*$DATA BEGIN OF p0024 OCCURS 10.
*$  INCLUDE STRUCTURE BAPIQUALIFIC_TAB.
*$DATA END OF p0024 VALID BETWEEN begda AND endda.
*$data help_pernr type sobid.
*$</infotype24>
ENDFORM. "process_infotypes

*---------------------------------------------------------------------*
*       FORM PROCESS_REPORT_STATEMENT                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_report_statement.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding.

  PERFORM get_tag USING 'report' CHANGING tag.
  PERFORM replace_param USING 'NAME'
                              g_repid
                              tag
                        CHANGING result.
  PERFORM insert_code USING result.

*$<report>
*$REPORT &NAME
*$   MESSAGE-ID /sie/hr_idp_messages
*$   LINE-SIZE 255.
*$TABLES pernr.
*$DATA: drange   TYPE rsds_trange WITH HEADER LINE,
*$      frange   TYPE rsds_frange OCCURS 0 WITH HEADER LINE,
*$      optline  TYPE rsdsselopt,
*$      g_filesize TYPE /sie/hr_idp_filesz,
*$      g_recordcount(10) type n,
*$      g_pernrcount(10) type n,
*$      g_perid(6) type c.
*$ DATA: it_pbwla TYPE TABLE OF pbwla WITH HEADER LINE,
*$      betrag TYPE pad_amt7s,
*$      lohnart TYPE lgart,
*$      lgart_name(15) TYPE c,
*$      betrg_name(15) TYPE c,
*$      lganr(2) TYPE n.
*$  FIELD-SYMBOLS: <lgart>, <betrg>.
*$  DATA: BEGIN OF locked_pernr OCCURS 50,
*$          pernr LIKE pernr-pernr,
*$        END OF locked_pernr.
*$  DATA: auth_skipped_count TYPE i,
*$        locked_skipped_count TYPE i,
*$        locked_occurs_params TYPE i.
*$DATA:
*$  BEGIN OF it_rd OCCURS 0,
*$     mthbk        TYPE /sie/hr_idp_months_back,
*$     payde_result TYPE payde_result,
*$  END OF it_rd,
*$  payroll_result type payde_result,
*$  rgdir type standard table of pc261 initial size 0 with header line,
*$  p_perid type faper,
*$  p_delta type i.
*SIE007_BEG
*$* Hilfsfelder für zusätzliche Selektion
*$  DATA: h_reject   TYPE flag1.
*$  DATA: wa_sel     TYPE /SIE/HR_IDP_SEL_GB.
*SIE007_END
*AH002_BEG
*$* Hilfsfelder für zusätzliche Selektion
*$  DATA: wa_sel_brpb type /SIE/HR_IDP_SEL_BR_PB_PTBKOSTL.
*AH002_END
*SIE008_BEG
*$  DATA: h_rec_date TYPE begda.
*SIE008_END
*$</report>
ENDFORM. "process_report_statement.

*---------------------------------------------------------------------*
*       FORM PROCESS_PARAMETERS                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_parameters.
  DATA: tag TYPE /sie/hr_idp_tt_coding.
  PERFORM get_tag USING 'parameters' CHANGING tag.
  PERFORM insert_code USING tag.

*$<parameters>
*$SELECTION-SCREEN BEGIN OF BLOCK blocks with frame.
*$SELECT-OPTIONS:
*$  zzbreinh FOR p0001-zzbreinh,
*$  zzstando FOR p0001-zzstando,
*$  zzhansp  FOR p0263-hansp,
*$  zzpkat   FOR p9008-pkat,
*SIE004_BEG
*$  zzsel    FOR p0203-zzsel,
*SIE004_END
*SIE007_BEG
*$  ZZ_PBBR  FOR wa_sel-PBBR,
*SIE007_END
*AH002_BEG
*$  ZZ_BRPB FOR wa_sel_BRPB-BRPBPTBKOSTL,
*AH002_END
*SIE008_BEG
*$  zzentkto FOR P9008-zzentg_kto.
*SIE008_END
*$SELECTION-SCREEN end OF BLOCK blocks.
*$SELECTION-SCREEN BEGIN OF BLOCK blockp with frame.
*$parameters:
*$  p_rel as checkbox,
*$  begdt type /SIE/HR_IDP_BEG_DAY_FIX,
*$  begdo type /SIE/HR_IDP_MONTH_OFFSET,
*$  enddt type /SIE/HR_IDP_end_DAY_FIX,
*$  enddo type /SIE/HR_IDP_MONTH_OFFSET,
*$  begpt type /SIE/HR_IDP_BEGps_DAY_FIX,
*$  begpo type /SIE/HR_IDP_MONTH_OFFSET,
*$  endpt type /SIE/HR_IDP_endps_DAY_FIX,
*$  endpo type /SIE/HR_IDP_MONTH_OFFSET.
**$  abkro type /SIE/HR_IDP_ABKRO.
*$SELECTION-SCREEN end OF BLOCK blockp.
*$
*$*Parameter für Ad_hoc Läufe. Wird dieser Parameter gesetzt, so werden
*$*alternative UC4 Parameter benutzt
*$Parameters: p_adhoc no-display.
*$
*$</parameters>
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_DSN_DECLARATION                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_FILENAME                                                    *
*---------------------------------------------------------------------*
FORM process_dsn_declaration USING p_filename.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding.

  PERFORM get_tag USING 'dsn' CHANGING tag.

  PERFORM insert_code USING tag.

*$<dsn>
*$DATA DSN TYPE text256.
*$DATA SD type text256.
*$data buffer type string.
*$data meta_buffer(10240) type c.
*$data len type i.
*$data g_datum type d.
*$</dsn>
ENDFORM. "process_report_statement.

*---------------------------------------------------------------------*
*       FORM PROCESS_STRUCTURE_DECLARATION                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_structure_declaration.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    tag3      TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    sa        LIKE LINE OF it_satzart.

  PERFORM get_tag USING 'structure1' CHANGING tag.
  PERFORM get_tag USING 'structure3' CHANGING tag3.
  LOOP AT it_satzart INTO sa.
    PERFORM replace_param USING 'RECNA' sa-sname tag
                          CHANGING result.
    PERFORM insert_code USING result.
    PERFORM process_structure_declaration2 USING sa-recna.
    PERFORM replace_param USING 'RECNA' sa-sname tag3
                          CHANGING result.
    PERFORM insert_code USING result.
  ENDLOOP.
*$<structure1>
*$*Satzart: &RECNA
*$DATA BEGIN OF ITAB_&RECNA OCCURS 0.
*$</structure1>
*$<structure3>
*$DATA END OF ITAB_&RECNA.
*$
*$</structure3>
ENDFORM.                    " PROCESS_STRUCTURE_DECLARATION

*---------------------------------------------------------------------*
*       FORM PROCESS_STRUCTURE_DECLARATION2                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_RECNA                                                       *
*---------------------------------------------------------------------*
FORM process_structure_declaration2
     USING p_recna TYPE /sie/hr_idp_record_name.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    tag1      TYPE /sie/hr_idp_tt_coding,
    tag2      TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    fields    LIKE LINE OF it_felder.

  PERFORM get_tag USING 'structure2' CHANGING tag1.
  PERFORM get_tag USING 'structure2_2' CHANGING tag2.
  LOOP AT it_felder INTO fields WHERE recna = p_recna.
    IF fields-structure IS INITIAL.
      MOVE tag2[] TO tag[].
    ELSE.
      MOVE tag1[] TO tag[].
    ENDIF.
    PERFORM replace_param USING 'FNAME' fields-selname tag
                          CHANGING result.
    MOVE result[] TO input[].
    IF fields-type IS INITIAL.
      PERFORM replace_param USING 'KIND' 'LIKE' input
                            CHANGING result.
    ELSE.
      PERFORM replace_param USING 'KIND' 'TYPE' input
                            CHANGING result.
    ENDIF.
    MOVE result[] TO input[].
    PERFORM replace_param USING 'STRUCTURE' fields-structure input
                          CHANGING result.
    MOVE result[] TO input[].
    PERFORM replace_param USING 'LENGTH' fields-db_length input
                          CHANGING result.
    MOVE result[] TO input[].
    PERFORM replace_param USING 'TYPE' fields-internal_type input
                          CHANGING result.
    PERFORM insert_code USING result.
    CLEAR fields.
  ENDLOOP.
*$<structure2>
*$DATA   &FNAME &KIND &STRUCTURE.
*$</structure2>
*$<structure2_2>
*$DATA   &FNAME(&LENGTH) TYPE &TYPE.
*$</structure2_2>

ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_FILTER_DECLARATION                    SIE002     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_filter_declaration.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag_rem   TYPE /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    wa_filter LIKE LINE OF it_filter.

* Nur prozessieren, wenn Feldfilter überhaupt verwendet wurden
  READ TABLE it_filter INDEX 1 TRANSPORTING NO FIELDS.
  CHECK sy-subrc = 0.

* Kommentar
  PERFORM get_tag USING 'filter_remark' CHANGING tag_rem.
  PERFORM insert_code USING tag_rem.

* Ranges

  LOOP AT it_filter INTO wa_filter.

    AT NEW feldname."Nur einmal definieren

      REFRESH tag.
      PERFORM get_tag USING 'filter_decl' CHANGING tag.

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

*$<filter_remark>
*$*Filter auf Feldebene
*$</filter_remark>

*$<filter_decl>
*$*&LRECNA-&LFNAME
*$RANGES &RNAME FOR ITAB_&RECNA-&FNAME.
*$</filter_decl>

ENDFORM.                    " PROCESS_FILTER_DECLARATION

*---------------------------------------------------------------------*
*       FORM PROCESS_OUT_STRUCTURE_DECL                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_out_structure_decl.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    tag3      TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    sa        LIKE LINE OF it_satzart.

  PERFORM get_tag USING 'out_structure1' CHANGING tag.
  PERFORM get_tag USING 'out_structure3' CHANGING tag3.
  LOOP AT it_satzart INTO sa.
    PERFORM replace_param USING 'RECNA' sa-sname tag
                          CHANGING result.
    PERFORM insert_code USING result.
    PERFORM process_out_structure_decl2 USING sa-recna.
    PERFORM replace_param USING 'RECNA' sa-sname tag3
                          CHANGING result.
    PERFORM insert_code USING result.
  ENDLOOP.
*$<out_structure1>
*$*Satzart: out_&RECNA
*$DATA BEGIN OF ITAB_out_&RECNA OCCURS 0.
*$</out_structure1>
*$<out_structure3>
*$DATA END OF ITAB_out_&RECNA.
*$
*$</out_structure3>
ENDFORM.                    " PROCESS_STRUCTURE_DECLARATION

*---------------------------------------------------------------------*
*       FORM PROCESS_OUT_STRUCTURE_DECL2                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_RECNA                                                       *
*---------------------------------------------------------------------*
FORM process_out_structure_decl2
     USING p_recna TYPE /sie/hr_idp_record_name.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    tag1       TYPE /sie/hr_idp_tt_coding,
    tag2       TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    fields    LIKE LINE OF it_felder,
*    HELP      TYPE STRING, "SIE001
    help(72)  TYPE c,       "SIE001
    len TYPE i.

  PERFORM get_tag USING 'structure2' CHANGING tag1.
  PERFORM get_tag USING 'structure2_2' CHANGING tag2.
  LOOP AT it_felder INTO fields WHERE recna = p_recna.
    MOVE tag1[] TO tag[].
    IF fields-conf_funcname IS INITIAL.
      IF fields-semcls = '2'.

        len = strlen( fields-param ).
        IF len = 0. len = 255. ENDIF.
        WRITE len TO help LEFT-JUSTIFIED.
        CONCATENATE  fields-selname '(' help ')' INTO help.
        PERFORM replace_param USING 'FNAME' help tag
                              CHANGING result.
        MOVE result[] TO input[].
        PERFORM replace_param USING 'KIND' 'TYPE' input
                              CHANGING result.
        MOVE result[] TO input[].
        PERFORM replace_param USING 'STRUCTURE' 'C' input
                              CHANGING result.
      ELSE.

        IF fields-structure IS INITIAL.
          MOVE tag2[] TO tag[].
        ELSE.
          MOVE tag1[] TO tag[].
        ENDIF.
        PERFORM replace_param USING 'FNAME' fields-selname tag
                              CHANGING result.
        MOVE result[] TO input[].
        IF fields-type IS INITIAL.
          PERFORM replace_param USING 'KIND' 'LIKE' input
                                CHANGING result.
        ELSE.
          PERFORM replace_param USING 'KIND' 'TYPE' input
                                CHANGING result.
        ENDIF.
        MOVE result[] TO input[].
        PERFORM replace_param USING 'STRUCTURE' fields-structure input
                              CHANGING result.
        MOVE result[] TO input[].
        PERFORM replace_param USING 'LENGTH' fields-db_length input
                              CHANGING result.
        MOVE result[] TO input[].
        PERFORM replace_param USING 'TYPE' fields-internal_type input
                              CHANGING result.

****************************************************

*        PERFORM REPLACE_PARAM USING 'FNAME' FIELDS-SELNAME TAG
*                              CHANGING RESULT.
*        MOVE RESULT[] TO INPUT[].
*        IF FIELDS-TYPE IS INITIAL.
*          PERFORM REPLACE_PARAM USING 'KIND' 'LIKE' INPUT
*                                CHANGING RESULT.
*        ELSE.
*          PERFORM REPLACE_PARAM USING 'KIND' 'TYPE' INPUT
*                                CHANGING RESULT.
*        ENDIF.
*        MOVE RESULT[] TO INPUT[].
*        PERFORM REPLACE_PARAM USING 'STRUCTURE' FIELDS-STRUCTURE INPUT
*                              CHANGING RESULT.
      ENDIF.
    ELSE.
      WRITE fields-conf_out_length TO help LEFT-JUSTIFIED.
      IF fields-conf_out_length = 0.
        help = 255.
      ENDIF.
      CONCATENATE fields-selname '(' help ')' INTO help.
      PERFORM replace_param USING 'FNAME' help tag
                            CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'KIND' 'TYPE' input
                            CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'STRUCTURE' 'C' input
                            CHANGING result.
    ENDIF.
    PERFORM insert_code USING result.
    CLEAR fields.
  ENDLOOP.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_OUT_STRUCTURE_DECL                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_trans_structure_decl.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    tag3      TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    sa        LIKE LINE OF it_satzart.

  PERFORM get_tag USING 'trans_structure1' CHANGING tag.
  PERFORM get_tag USING 'trans_structure3' CHANGING tag3.
  LOOP AT it_satzart INTO sa.
    PERFORM replace_param USING 'RECNA' sa-sname tag
                          CHANGING result.
    PERFORM insert_code USING result.
    PERFORM process_trans_structure_decl2 USING sa-recna.
    PERFORM replace_param USING 'RECNA' sa-sname tag3
                          CHANGING result.
    PERFORM insert_code USING result.
  ENDLOOP.
*$<trans_structure1>
*$*Satzart: trans_&RECNA
*$DATA BEGIN OF trans_&RECNA.
*$</trans_structure1>
*$<trans_structure3>
*$DATA END OF trans_&RECNA.
*$
*$</trans_structure3>
ENDFORM.                    " PROCESS_STRUCTURE_DECLARATION

*---------------------------------------------------------------------*
*       FORM PROCESS_OUT_STRUCTURE_DECL2                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_RECNA                                                       *
*---------------------------------------------------------------------*
FORM process_trans_structure_decl2
     USING p_recna TYPE /sie/hr_idp_record_name.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    fields    LIKE LINE OF it_felder,
*    HELP      TYPE STRING, "SIE001
    help(72)  TYPE c,       "SIE001
    len TYPE i.

  PERFORM get_tag USING 'trans_structure2' CHANGING tag.
  LOOP AT it_felder INTO fields WHERE recna = p_recna.
    IF fields-length IS INITIAL.
      IF fields-conf_funcname IS INITIAL.
        IF fields-semcls = '2'.
          len = strlen( fields-param ).
        ELSEIF fields-selname = 'FSA_'.
          len = 8.
        ELSEIF fields-feldname = 'PERNR'.
          len = 8.
        ELSE.
          IF fields-internal_type = 'P'.
            len = fields-db_length * 2 + 2.
          ELSE.
            len = fields-db_length.
          ENDIF.
        ENDIF.
      ELSE.
        len = fields-conf_out_length.
      ENDIF.
    ELSE.
      len = fields-length.
    ENDIF.
    IF len = 0. len = 1. ENDIF.
    WRITE len TO help LEFT-JUSTIFIED.
    PERFORM replace_param USING 'FNAME' fields-selname  tag
                          CHANGING result.
    MOVE result[] TO input[].
    PERFORM replace_param USING 'LEN' help input
                          CHANGING result.
 if fields-conf_funcname ne '/SIE/HR_IDP_FIELD_NOT_OUT'. "HAN001
    PERFORM insert_code USING result.
 endif.                                                  "HAN001
    CLEAR fields.
  ENDLOOP.

*$<trans_structure2>
*$DATA   &FNAME(&LEN) type c.
*$</trans_structure2>
ENDFORM.



*---------------------------------------------------------------------*
*       FORM PROCESS_SOS                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_sos.
  DATA tag TYPE /sie/hr_idp_tt_coding.
  PERFORM get_tag USING 'sos_init' CHANGING tag.
  PERFORM insert_code USING tag.
*$<sos_init>
*$
*$START-OF-SELECTION.
*$</sos_init>
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_START_OF_SELECTION                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_FILENAME                                                    *
*---------------------------------------------------------------------*
FORM process_start_of_selection USING p_param1
                                      p_param2
                                      p_param3
                                      p_param4.

  DATA:
    tag TYPE /sie/hr_idp_tt_coding,
    input TYPE /sie/hr_idp_tt_coding,
    result TYPE /sie/hr_idp_tt_coding.

  PERFORM get_tag USING 'sos' CHANGING tag.
  IF g_fixformat IS INITIAL.
    PERFORM replace_param USING 'MODE' 'TEXT' tag
                          CHANGING result.
  ELSE.
    PERFORM replace_param USING 'MODE' 'TEXT' tag
                          CHANGING result.
  ENDIF.
  MOVE result[] TO input[].
  PERFORM replace_param USING 'ITYPE' p_param3 input CHANGING result.
  MOVE result[] TO input[].
  PERFORM replace_param USING 'IFCID' p_param1 input CHANGING result.
  MOVE result[] TO input[].
  PERFORM replace_param USING 'VRSNR' p_param2 input CHANGING result.
  MOVE result[] TO input[].
  PERFORM replace_param USING 'FILEIN' p_param4 input CHANGING result.

  PERFORM insert_code USING result.

*$<sos>
*$ data: repid like sy-repid.
*$ repid = sy-repid.
*$
*$ CALL FUNCTION '/SIE/HR_IDP_FILENAMES'
*$      EXPORTING  IFCID = '&IFCID'
*$                 vrsnr = '&VRSNR'
*$                 ITYPE = '&ITYPE'
*$                 program_name = repid
*$                 logical_filename = '&FILEIN'
*$      importing FILEN_DATA = DSN
*$                FILEN_SD   = SD
*$      exceptions FILE_NOT_FOUND = 1
*$                 others = 2.
*$      IF sy-subrc <> 0 OR ( DSN IS INITIAL ).
*$*        DSN = 'SAP_DP_TEST'.
*$         message e803 with '&ITYPE'.
*$      ENDIF.
*$
*$*  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
*$*       EXPORTING program  = sy-repid
*$*                 activity = 'WRITE'
*$*                 filename = DSN
*$*       exceptions no_authority = 1
*$*                  others = 2.
*$*       if sy-subrc ne 0.
*$*          message e802 with dsn.
*$*       endif.
*$ OPEN DATASET DSN FOR OUTPUT IN &MODE MODE ENCODING DEFAULT.
*$       if sy-subrc ne 0.
*$          message e804 with dsn.
*$       endif.
*$
*$</sos>
ENDFORM.                    " PROCESS_START_OF_SELECTION

*---------------------------------------------------------------------*
*       FORM PROCESS_TIME_PARAMETERS                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_time_parameters.
  DATA:
    tag TYPE /sie/hr_idp_tt_coding.
  PERFORM get_tag USING 'sos_time' CHANGING tag.
  PERFORM insert_code USING tag.
*$<sos_time>
*$ get time.
*$ g_datum = sy-datum.
*$ IF sy-uzeit lt '060000'.
*$   subtract 1 from g_datum.
*$ endif.
*$ IF not p_rel is initial.
*$*
*$   if begdt is initial. begdt = g_datum+6(2). endif.
*$   if enddt is initial. enddt = g_datum+6(2). endif.
*$   if begpt is initial. begpt = g_datum+6(2). endif.
*$   if endpt is initial. endpt = g_datum+6(2). endif.
*$
*$   PERFORM compute_date USING g_datum begdt begdo CHANGING pn-begda.
*$   PERFORM compute_date USING g_datum enddt enddo CHANGING pn-endda.
*$   if begpt is initial.
*$     PERFORM compute_date USING g_datum begdt begdo CHANGING pn-begps.
*$   else.
*$     PERFORM compute_date USING g_datum begpt begpo CHANGING pn-begps.
*$   endif.
*$   if endpt is initial.
*$     PERFORM compute_date USING g_datum enddt endpo CHANGING pn-endps.
*$   else.
*$     PERFORM compute_date USING g_datum endpt endpo CHANGING pn-endps.
*$   endif.
*$ elseif pnptimed = 'M'.
*$   PERFORM compute_date USING g_datum '1' '0' CHANGING pn-begda.
*$   PERFORM compute_date USING g_datum '31' '0' CHANGING pn-endda.
*$   PERFORM compute_date USING g_datum '1' '0' CHANGING pn-begps.
*$   PERFORM compute_date USING g_datum '31' '0' CHANGING pn-endps.
*$ elseif pnptimed = 'M'.
*$   concatenate g_datum(4) '0101' into pn-begda.
*$   concatenate g_datum(4) '1231' into pn-endda.
*$   concatenate g_datum(4) '0101' into pn-begps.
*$   concatenate g_datum(4) '1231' into pn-endps.
*$ else.
*$   if pn-begda = sy-datum. pn-begda = g_datum. endif.
*$   if pn-endda = sy-datum. pn-endda = g_datum. endif.
*$   if pn-begps = sy-datum. pn-begps = g_datum. endif.
*$   if pn-endps = sy-datum. pn-endps = g_datum. endif.
*$ ENDIF.
*$</sos_time>
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_DYNSE                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_dynse.
  DATA:
    tag TYPE /sie/hr_idp_tt_coding.
  PERFORM get_tag USING 'sos_dynse' CHANGING tag.
  PERFORM insert_code USING tag.
*$<sos_dynse>
*$  IF NOT zzstando IS INITIAL.
*$  CLEAR frange.
*$    CLEAR frange[]. CLEAR drange.
*$    frange-fieldname = 'ZZSTANDO'.
*$*    frange-selopt_t = zzstando[].
*$    LOOP AT zzstando.
*$      MOVE-CORRESPONDING zzstando TO optline.
*$      APPEND optline TO frange-selopt_t.
*$    ENDLOOP.
*$    APPEND frange.
*$    drange-tablename = 'PA0001'.
*$    drange-frange_t = frange[].
*$    APPEND drange.
*$  ENDIF.
*$  IF NOT zzbreinh IS INITIAL.
*$    CLEAR frange. CLEAR frange[]. CLEAR drange.
*$    frange-fieldname = 'ZZBREINH'.
*$*     frange-selopt_t = zzbreinh[].
*$    LOOP AT zzbreinh.
*$      MOVE-CORRESPONDING zzbreinh TO optline.
*$      APPEND optline TO frange-selopt_t.
*$    ENDLOOP.
*$    APPEND frange.
*$    drange-tablename = 'PA0001'.
*$    drange-frange_t = frange[].
*$    APPEND drange.
*$  ENDIF.
*$  IF NOT zzhansp IS INITIAL.
*$    CLEAR frange. CLEAR frange[]. CLEAR drange.
*$    frange-fieldname = 'HANSP'.
*$*   frange-selopt_t = zzhansp[].
*$    LOOP AT zzhansp.
*$      MOVE-CORRESPONDING zzhansp TO optline.
*$      APPEND optline TO frange-selopt_t.
*$    ENDLOOP.
*$    APPEND frange.
*$    drange-tablename = 'PA0263'.
*$    drange-frange_t = frange[].
*$    APPEND drange.
*$  ENDIF.
*$  IF NOT zzpkat IS INITIAL.
*$    CLEAR frange. CLEAR frange[]. CLEAR drange.
*$    frange-fieldname = 'PKAT'.
*$*   frange-selopt_t = zzpkat[].
*$    LOOP AT zzpkat.
*$      MOVE-CORRESPONDING zzpkat TO optline.
*$      APPEND optline TO frange-selopt_t.
*$    ENDLOOP.
*$    APPEND frange.
*SIE008_BEG
*$  ENDIF.
*$  IF NOT zzentkto IS INITIAL.
*$    CLEAR frange. CLEAR frange[].
*$    frange-fieldname = 'ZZENTG_KTO'.
*$*   frange-selopt_t = zzentkto[].
*$    LOOP AT zzentkto.
*$      MOVE-CORRESPONDING zzentkto TO optline.
*$      APPEND optline TO frange-selopt_t.
*$    ENDLOOP.
*$    APPEND frange.
*$  ENDIF.
*$  IF NOT zzpkat IS INITIAL OR NOT zzentkto IS INITIAL.
*SIE008_END
*$  CLEAR drange.
*$    drange-tablename = 'PA9008'.
*$    drange-frange_t = frange[].
*$    APPEND drange.
*$  ENDIF.
*$  IF NOT drange[] IS INITIAL.
*$  CALL FUNCTION 'FREE_SELECTIONS_RANGE_2_EX'
*$       EXPORTING
*$            field_ranges = drange[]
*$       IMPORTING
*$            expressions  = pnpdynse.
*$  ENDIF.

*SIE004_BEG

*$  IF NOT zzsel IS INITIAL.
*$    CLEAR frange. CLEAR frange[]. CLEAR drange.
*$    frange-fieldname = 'ZZSEL'.
*$*   frange-selopt_t = zzsel[].
*$    LOOP AT zzsel.
*$      MOVE-CORRESPONDING zzsel TO optline.
*$      APPEND optline TO frange-selopt_t.
*$    ENDLOOP.
*$    APPEND frange.
*$    drange-tablename = 'PA0203'.
*$    drange-frange_t = frange[].
*$    APPEND drange.
*$  ENDIF.
*$  IF NOT drange[] IS INITIAL.
*$  CALL FUNCTION 'FREE_SELECTIONS_RANGE_2_EX'
*$       EXPORTING
*$            field_ranges = drange[]
*$       IMPORTING
*$            expressions  = pnpdynse.
*$  ENDIF.

*SIE004_END

*$</sos_dynse>
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PROCESS_METADATEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_metadaten.
  DATA:
    tag_v TYPE /sie/hr_idp_tt_coding,
    tag_f TYPE /sie/hr_idp_tt_coding,
    tag_d TYPE /sie/hr_idp_tt_coding,
    tag_h TYPE /sie/hr_idp_tt_coding,
    tag_sa TYPE /sie/hr_idp_tt_coding,
    tag_t TYPE /sie/hr_idp_tt_coding,
    tag_s TYPE /sie/hr_idp_tt_coding,
    tag_field TYPE /sie/hr_idp_tt_coding,
    tag_trans TYPE /sie/hr_idp_tt_coding,
    result TYPE /sie/hr_idp_tt_coding,
    input TYPE /sie/hr_idp_tt_coding,
    sa LIKE LINE OF it_satzart,
    field LIKE LINE OF it_felder,
    len(4) TYPE n.

  PERFORM get_tag USING 'META_TRANS' CHANGING tag_trans.

  PERFORM get_tag USING 'META_V' CHANGING tag_v.
  PERFORM insert_code USING tag_v.
  PERFORM insert_code USING tag_trans.

  PERFORM get_tag USING 'META_F' CHANGING tag_f.
  IF g_fixformat IS INITIAL.
    PERFORM replace_param USING 'FORMAT' 'CSV' tag_f
                          CHANGING result.
    PERFORM insert_code USING result.
    PERFORM insert_code USING tag_trans.
    IF g_delimiter NE ';'.
      PERFORM get_tag USING 'META_D' CHANGING tag_d.
      PERFORM replace_param USING 'DELIMITER' g_delimiter tag_d
                            CHANGING result.
      PERFORM insert_code USING result.
      PERFORM insert_code USING tag_trans.
    ENDIF.
  ELSE.
    PERFORM replace_param USING 'FORMAT' 'FIX' tag_f CHANGING result.
    PERFORM insert_code USING result.
    PERFORM insert_code USING tag_trans.
  ENDIF.

  PERFORM get_tag USING 'META_SA' CHANGING tag_sa.
  PERFORM get_tag USING 'META_H' CHANGING tag_h.
  PERFORM insert_code USING tag_h.
  LOOP AT it_satzart INTO sa WHERE recty = 1.
    PERFORM replace_param USING 'SA' sa-recna tag_sa CHANGING result.
    PERFORM insert_code USING result.
  ENDLOOP.
  PERFORM insert_code USING tag_trans.

  PERFORM get_tag USING 'META_T' CHANGING tag_t.
  PERFORM insert_code USING tag_t.
  LOOP AT it_satzart INTO sa WHERE recty = 5.
    PERFORM replace_param USING 'SA' sa-recna tag_sa CHANGING result.
    PERFORM insert_code USING result.
  ENDLOOP.
  PERFORM insert_code USING tag_trans.

  PERFORM get_tag USING 'META_S' CHANGING tag_s.
  PERFORM get_tag USING 'META_FIELD' CHANGING tag_field.
  LOOP AT it_satzart INTO sa WHERE recty = 3 OR recty = 4.
    PERFORM replace_param USING 'SA' sa-recna tag_s CHANGING result.
    PERFORM insert_code USING result.
    LOOP AT it_felder INTO field WHERE recna = sa-recna.
* Bestimmen der Länge
      IF field-length IS INITIAL.
        IF field-conf_funcname IS INITIAL.
          IF field-semcls = '2'.
            len = strlen( field-param ).
          ELSEIF field-selname = 'FSA_'.
            len = 8.
          ELSEIF field-feldname = 'PERNR'.
            len = 8.
          ELSE.
            IF field-internal_type = 'P'.
              len = field-db_length * 2 + 2.
            ELSE.
              len = field-db_length.
            ENDIF.
          ENDIF.
        ELSE.
          len = field-conf_out_length.
        ENDIF.
      ELSE.
        len = field-length.
      ENDIF.
      IF len = 0. len = 1. ENDIF.

* Ende bestimmen der länge


      PERFORM replace_param USING 'FNAME' field-feldname tag_field
                            CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'KEYPOS' field-keypos input
                            CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'LENGTH' len input
                            CHANGING result.
      MOVE result[] TO input[].
      PERFORM insert_code USING result.
    ENDLOOP.

    PERFORM insert_code USING tag_trans.
  ENDLOOP.
*$<meta_v>
*$  concatenate '//' space 'V' '1.0'
*$     into meta_buffer separated by ';'.
*$</meta_v>

*$<meta_f>
*$  concatenate '//' space 'F' dsn '&FORMAT'
*$    into meta_buffer separated by ';'.
*$</meta_f>

*$<meta_d>
*$  concatenate '//' space 'D' '&DELIMITER'
*$    into meta_buffer separated by ';'.
*$</meta_d>

*$<meta_h>
*$  concatenate '//' space 'H'
*$    into meta_buffer separated by ';'.
*$</meta_h>

*$<meta_t>
*$  concatenate '//' space 'T'
*$    into meta_buffer separated by ';'.
*$</meta_t>

*$<meta_sa>
*$  concatenate meta_buffer '&SA'
*$    into meta_buffer separated by ';'.
*$</meta_sa>

*$<meta_s>
*$  concatenate '//' '&SA' 'S'
*$    into meta_buffer separated by ';'.
*$</meta_s>

*$<meta_field>
*$  concatenate meta_buffer '&FNAME:&KEYPOS:&LENGTH'
*$    into meta_buffer separated by ';'.
*$</meta_field>

*$<meta_trans>
*$  len = strlen( meta_buffer ).
*$* DESCRIBE FIELD meta_buffer LENGTH len.
*$  TRANSFER meta_buffer TO dsn LENGTH len.
*$</meta_trans>

ENDFORM.                    " PROCESS_METADATEN

*---------------------------------------------------------------------*
*       FORM PROCESS_PERFORM_FILL_FILTER                   "SIE002    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_perform_fill_filter.
  DATA tag TYPE /sie/hr_idp_tt_coding.

* Nur wenn Filter benutzt wurden
  READ TABLE it_filter INDEX 1 TRANSPORTING NO FIELDS.

  IF sy-subrc = 0.
     PERFORM get_tag USING 'perform_fill_filter' CHANGING tag.
     PERFORM insert_code USING tag.
  ENDIF.

*$<perform_fill_filter>
*$
*$PERFORM FILL_FILTER.
*$
*$</perform_fill_filter>
ENDFORM.
