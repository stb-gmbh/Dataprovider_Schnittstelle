*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_GENERATORF12 .
FORM process_transfer_routinen_fix.
  DATA:
    tag1       TYPE /sie/hr_idp_tt_coding,
    tag2       TYPE /sie/hr_idp_tt_coding,
    tag3       TYPE /sie/hr_idp_tt_coding,
    result     TYPE /sie/hr_idp_tt_coding,
    input      TYPE /sie/hr_idp_tt_coding,
    sa         LIKE LINE OF it_satzart,
    field      LIKE LINE OF it_felder,
    comment,
    BEGIN OF offset,
      sign VALUE '+',
      val(4) TYPE n,
    END OF offset.

  PERFORM get_tag USING 'transfer_routine_fix1' CHANGING tag1.
  PERFORM get_tag USING 'transfer_routine_fix2' CHANGING tag2.
  PERFORM get_tag USING 'transfer_routine_fix3' CHANGING tag3.
  LOOP AT it_satzart INTO sa.
    comment = '*'.
    IF sa-recty = '3' OR sa-recty = '4'. CLEAR comment. ENDIF.
    PERFORM replace_param USING 'SA' sa-sname tag1
                          CHANGING result.
    PERFORM insert_code USING result.
    LOOP AT it_felder INTO field WHERE recna = sa-recna.
      PERFORM replace_param USING 'SA' sa-sname tag2
                            CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'FNAME' field-selname input
                            CHANGING result.
      MOVE result[] TO input[].
      IF field-offst IS INITIAL OR
         field-internal_type = 'I' OR
         field-internal_type = 'P'.
         PERFORM replace_param USING 'OFFSET' space input
                              CHANGING result.
      ELSE.
        offset-val = field-offst.
        PERFORM replace_param USING 'OFFSET' offset input
                              CHANGING result.
      ENDIF.
 if field-conf_funcname ne '/SIE/HR_IDP_FIELD_NOT_OUT'. "HAN001
      PERFORM insert_code USING result.
 endif.                                                "HAN001
    ENDLOOP.
    PERFORM replace_param USING 'SA' sa-sname tag3
                          CHANGING result.
    MOVE result[] TO input[].
    PERFORM replace_param USING 'COMMENT' comment input
                          CHANGING result.
    PERFORM insert_code USING result.
  ENDLOOP.

*$<transfer_routine_fix1>
*$form trans_&sa using itab_out_&sa like itab_out_&sa.
*$data len type i.
*$</transfer_routine_fix1>

*$<transfer_routine_fix2>
*$  move itab_out_&sa-&fname&offset
*$    to trans_&sa-&fname.
*$</transfer_routine_fix2>

*$<transfer_routine_fix3>
*$  describe field trans_&sa length len in CHARACTER MODE.
*$  transfer trans_&sa to dsn length len.
*$&comment  add len to g_filesize.
*$&comment  add 1 to g_recordcount.
*$endform.
*$</transfer_routine_fix3>

ENDFORM.                    " PROCESS_TRANSFER_ROUTINEN

*FORM PROCESS_TRANSFER_ROUTINEN_CSVN.
**Basis zum erstellen von csv Routinen unter verwendung der trans strukt
*
*  DATA:
*    TAG1       TYPE /SIE/HR_IDP_TT_CODING,
*    TAG2       TYPE /SIE/HR_IDP_TT_CODING,
*    TAG3       TYPE /SIE/HR_IDP_TT_CODING,
*    RESULT     TYPE /SIE/HR_IDP_TT_CODING,
*    INPUT      TYPE /SIE/HR_IDP_TT_CODING,
*    SA         LIKE LINE OF IT_SATZART,
*    FIELD      LIKE LINE OF IT_FELDER.
*
*
*  PERFORM GET_TAG USING 'transfer_routine_csv1' CHANGING TAG1.
*  PERFORM GET_TAG USING 'transfer_routine_csv2' CHANGING TAG2.
*  PERFORM GET_TAG USING 'transfer_routine_csv3' CHANGING TAG3.
*  LOOP AT IT_SATZART INTO SA.
*    PERFORM REPLACE_PARAM USING 'SA' SA-SNAME TAG1
*                          CHANGING RESULT.
*    PERFORM INSERT_CODE USING RESULT.
*    LOOP AT IT_FELDER INTO FIELD WHERE RECNA = SA-RECNA.
*      PERFORM REPLACE_PARAM USING 'SA' SA-SNAME TAG2
*                            CHANGING RESULT.
*      MOVE RESULT[] TO INPUT[].
*      PERFORM REPLACE_PARAM USING 'FNAME' FIELD-SELNAME INPUT
*                            CHANGING RESULT.
*      MOVE RESULT[] TO INPUT[].
*      PERFORM REPLACE_PARAM USING 'OFFSET' FIELD-OFFST INPUT
*                            CHANGING RESULT.
*      PERFORM INSERT_CODE USING RESULT.
*    ENDLOOP.
*    PERFORM REPLACE_PARAM USING 'SA' SA-SNAME TAG3
*                          CHANGING RESULT.
*    PERFORM INSERT_CODE USING RESULT.
*  ENDLOOP.
*
**$<transfer_routine_csv1>
**$form trans_&sa using itab_out_&sa like itab_out_&sa.
**$data len type i.
**$</transfer_routine_csv1>
*
**$<transfer_routine_csv2>
**$  move itab_out_&sa-&fname+&offset
**$    to trans_&sa-&fname.
**$</transfer_routine_csv2>
*
**$<transfer_routine_csv3>
**$  describe field trans_&sa length len.
**$  transfer trans_&sa to dsn length len.
**$endform.
**$</transfer_routine_csv3>
*
*ENDFORM.





*---------------------------------------------------------------------*
*       FORM PROCESS_TRANSFER_ROUTINEN_CSV                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_transfer_routinen_csv.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    tag2      TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    sa        LIKE LINE OF it_satzart,
    comment.


  PERFORM get_tag USING 'transfer_routine_csv' CHANGING tag.
  PERFORM get_tag USING 'transfer_routine_csv_end' CHANGING tag2.
  LOOP AT it_satzart INTO sa.
    comment = '*'.
    IF sa-recty = '3' OR sa-recty = '4'. CLEAR comment. ENDIF.
    PERFORM replace_param USING 'SA' sa-sname tag
                          CHANGING result.
    PERFORM insert_code USING result.
    PERFORM process_csv_innerpart USING sa-recna sa-sname.
    PERFORM replace_param USING 'DELIMITER' g_delimiter tag2
                          CHANGING result.
    MOVE result[] TO input[].
    PERFORM replace_param USING 'COMMENT' comment input
                          CHANGING result.
    PERFORM insert_code USING result.
  ENDLOOP.
*$<transfer_routine_csv>
*$form trans_&sa using itab_out_&sa like itab_out_&sa.
*$data len type i.
*$data buffer(5120) type c.
*$data help(5120) type c.
**$  concatenate
*$</transfer_routine_csv>
*$<transfer_routine_csv_end>
**$  into buffer separated by '&delimiter'.
"SIE001 *$  concatenate buffer '&delimiter' into buffer.
*$  len = strlen( buffer ).
*$  transfer buffer to dsn length len.
*$&comment  add len to g_filesize.
*$&comment  add 1 to g_recordcount.
*$endform.
*$</transfer_routine_csv_end>
ENDFORM.                    " PROCESS_TRANSFER_ROUTINEN

*---------------------------------------------------------------------*
*       FORM PROCESS_CSV_INNERPART                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_RECNA                                                       *
*  -->  P_SNAME                                                       *
*---------------------------------------------------------------------*
FORM process_csv_innerpart USING p_recna TYPE /sie/hr_idp_record_name
                                 p_sname.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    t_write   TYPE /sie/hr_idp_tt_coding,
    t_write_1 TYPE /sie/hr_idp_tt_coding,
    t_move    TYPE /sie/hr_idp_tt_coding,
    t_move_1  TYPE /sie/hr_idp_tt_coding,
    tag       TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    field     LIKE LINE OF it_felder,
*    HELP      TYPE STRING, "SIE002
    help(72)  TYPE c,       "SIE002
*   I         TYPE I,        SIE001
    offset(4)    TYPE c,
    length(4)    TYPE c,
    conv         TYPE c.


  PERFORM get_tag USING 'csv_write'  CHANGING t_write.
*  PERFORM GET_TAG USING 'csv_write1' CHANGING T_WRITE_1. SIE001
  PERFORM get_tag USING 'csv_move'   CHANGING t_move.
*  PERFORM GET_TAG USING 'csv_move1'  CHANGING T_MOVE_1.  SIE001

  LOOP AT it_felder INTO field WHERE recna = p_recna.
    help = field-selname.
    IF NOT field-offst IS INITIAL.
      WRITE field-offst TO offset LEFT-JUSTIFIED.
      CONCATENATE help '+' offset INTO help.
    ENDIF.
    IF NOT field-length IS INITIAL.
*Achtung falls length > tatsächliche länge.
      WRITE field-length TO length  LEFT-JUSTIFIED.
      CONCATENATE help '(' length ')' INTO help.
    ENDIF.

    IF field-conf_funcname IS INITIAL AND
      ( ( field-internal_type = 'P' ) OR
        ( field-internal_type = 'I' ) ). "write left-justified
*      IF NOT I IS INITIAL.            SIE001
        MOVE t_write[] TO tag[].
*      ELSE.                           SIE001
*        MOVE T_WRITE_1[] TO TAG[].    SIE001
*      ENDIF.                          SIE001
    ELSE.
*      IF NOT I IS INITIAL.
        MOVE t_move[] TO tag[].
*      ELSE.                           SIE001
*        MOVE T_MOVE_1[] TO TAG[].     SIE001
*      ENDIF.                          SIE001
    ENDIF.

    PERFORM replace_param USING 'FNAME' help tag
                          CHANGING result.
    MOVE result[] TO input[].
    PERFORM replace_param USING 'SA' p_sname input
                          CHANGING result.
    MOVE result[] TO input[].
    IF field-nosep = 'X'.                                      "SIE001
       PERFORM replace_param USING 'DELIMITER' '' input
                             CHANGING result.
    ELSE.                                                      "SIE001
       PERFORM replace_param USING 'DELIMITER' g_delimiter input
                             CHANGING result.
    ENDIF.                                                     "SIE001

    MOVE result[] TO input[].
    PERFORM replace_param USING 'OPTION' 'left-justified' input
                          CHANGING result.
    PERFORM insert_code USING result.
*    ADD 1 TO I. SIE001
  ENDLOOP.

*SIE001_BEG

******$<csv_write1>
******$   write itab_out_&SA-&FNAME
******$         to buffer &OPTION.
******$</csv_write1>
******$<csv_write>
******$   write itab_out_&SA-&FNAME
******$         to help &OPTION.
******$   concatenate buffer help into buffer separated by '&delimiter'.
******$</csv_write>
******$<csv_move1>
******$   move itab_out_&SA-&FNAME
******$         to buffer.
******$</csv_move1>
******$<csv_move>
******$   move itab_out_&SA-&FNAME
******$        to help.
******$   concatenate buffer help into buffer separated by '&delimiter'.
******$</csv_move>

* Delimiter direkt nach Feld schreiben:
*$<csv_write>
*$   write itab_out_&SA-&FNAME
*$         to help &OPTION.
*$   concatenate buffer help '&delimiter' into buffer.
*$</csv_write>
*$<csv_move>
*$   move itab_out_&SA-&FNAME
*$        to help.
*$   concatenate buffer help '&delimiter' into buffer.
*$</csv_move>
*SIE001_END


ENDFORM.                    " PROCESS_TRANSFER_ROUTINEN








*&---------------------------------------------------------------------*
*&      Form  PROCESS_END_OF_SELECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_end_of_selection.
  DATA:
    tag       TYPE /sie/hr_idp_tt_coding.

  PERFORM get_tag USING 'EOS' CHANGING tag.
  PERFORM insert_code USING tag.

*$<eos>
*$end-of-selection.
*$  PERFORM pnp_skipped_pernr(sapdbpnp)
*$          TABLES locked_pernr
*$          USING 'Y'
*$          CHANGING auth_skipped_count
*$                   locked_skipped_count
*$                   locked_occurs_params.
*$   if auth_skipped_count gt 0.
*$     MESSAGE i804.
*$   endif.
*$   perform append_log using '&IFCID'
*$                            'S'
*$                            'End of selection'.
*$</eos>
ENDFORM.                    " PROCESS_END_OF_SELECTION

FORM process_close_dataset.
  DATA:
    tag       TYPE /sie/hr_idp_tt_coding.

  PERFORM get_tag USING 'CLOSE' CHANGING tag.
  PERFORM insert_code USING tag.

*$<close>
*$  close dataset dsn.
*$ if ( sy-tcode = '/SIE/HR_IDP_IFC_MOD' )  or    "#EC NOTEXT
*$    ( sy-tcode = '/SIE/HR_IDP_IFC_DISP' ) or    "#EC NOTEXT
*$    ( sy-tcode = '/SIE/HR_IDP_IFC_RELE' ).      "#EC NOTEXT
*$
*$  if sy-sysid = 'HC1' or sy-sysid = 'HVB'.
*$*   data buffer type string.
*$    open dataset dsn for input in text mode ENCODING DEFAULT.
*$    do.
*$      read dataset dsn into buffer.
*$      if not sy-subrc = 0.
*$        exit.
*$      endif.
*$      write: / buffer.
*$    enddo.
*$    close dataset dsn.
*$  endif.
*$ endif.
*$</close>
ENDFORM.                    " PROCESS_END_OF_SELECTION




*---------------------------------------------------------------------*
*       FORM PROCESS_COMPUTE_DATE                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_compute_date.
  DATA: tag  TYPE /sie/hr_idp_tt_coding.
  PERFORM get_tag USING 'compute_date' CHANGING tag.
  PERFORM insert_code USING tag.
*$<compute_date>
*$FORM compute_date USING datum TYPE d
*$                        dayfix TYPE /SIE/HR_IDP_BEG_DAY_FIX
*$                        offset TYPE /sie/hr_idp_month_offset
*$                        CHANGING p_goal TYPE d.
*$DATA: month(2) TYPE n,
*$      year(4) TYPE n,
*$      month_total(6) TYPE n,
*$      goal type d.
*$    if offset = '99'. p_goal = '99991231'. exit. endif.
*$    if offset = '99-'. p_goal = '18000101'. exit. endif.
*$    year = datum(4).
*$    month = datum+4(2).
*$    month_total = year * 12 +  month + offset. " - 1 + 1.
*$    year = month_total DIV 12.
*$    month = ( month_total MOD 12 ) + 1.
*$    CONCATENATE year month '01 ' INTO goal.
*$    SUBTRACT 1 FROM goal.
*$    IF dayfix LT goal+6(2).
*$      MOVE dayfix TO goal+6(2).
*$    ENDIF.
*$    p_goal = goal.
*$ENDFORM.
*$</compute_date>
ENDFORM.                    " PROCESS_COMPUTE_DATE

*---------------------------------------------------------------------*
*       FORM PROCESS_FORM_FILL_FILTER                      SIE002     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_form_fill_filter.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_coding,
    tag1      TYPE /sie/hr_idp_tt_coding,
    tag2      TYPE /sie/hr_idp_tt_coding,
    tag3      TYPE /sie/hr_idp_tt_coding,
    tag_rem   TYPE /sie/hr_idp_tt_coding,
    input     TYPE /sie/hr_idp_tt_coding,
    result    TYPE /sie/hr_idp_tt_coding,
    wa_filter LIKE LINE OF it_filter.

* Nur prozessieren, wenn Feldfilter überhaupt verwendet wurden
  READ TABLE it_filter INDEX 1 TRANSPORTING NO FIELDS.
  CHECK sy-subrc = 0.

  PERFORM get_tag USING 'form_fill_filter' CHANGING tag1.
  PERFORM insert_code USING tag1.

* Ranges

  LOOP AT it_filter INTO wa_filter.

    AT NEW feldname."Nur einmal Kommentar schreiben

      refresh tag_rem.
      PERFORM get_tag USING 'rem_filter' CHANGING tag_rem.

      PERFORM replace_param USING 'LRECNA' wa_filter-recna tag_rem
                          CHANGING result.
      MOVE result[] TO input[].
      PERFORM replace_param USING 'LFNAME' wa_filter-feldname input
                          CHANGING result.
      PERFORM insert_code USING result.

    ENDAT.

    REFRESH tag2.
    PERFORM get_tag USING 'add2range' CHANGING tag2.

*   Rangename
    PERFORM replace_param USING 'RNAME' wa_filter-rangename tag2
                          CHANGING result.
    MOVE result[] TO input[].
*   SIGN
    PERFORM replace_param USING 'SIGN' wa_filter-ssign input
                          CHANGING result.
    MOVE result[] TO input[].
*   OPTION
    PERFORM replace_param USING 'OPTI' wa_filter-sopti input
                          CHANGING result.
    MOVE result[] TO input[].
*   LOW
    PERFORM replace_param USING 'LOW' wa_filter-sllow input
                          CHANGING result.
    MOVE result[] TO input[].
*   HIGH
    PERFORM replace_param USING 'HIGH' wa_filter-shigh input
                          CHANGING result.
    PERFORM insert_code USING result.

  ENDLOOP.

  PERFORM get_tag USING 'endform_fill_filter' CHANGING tag3.
  PERFORM insert_code USING tag3.


*$<form_fill_filter>
*$
*$FORM FILL_FILTER.
*$
*$DEFINE ADD2RANGE.
*$
*$  &1-SIGN   = &2.
*$  &1-OPTION = &3.
*$  &1-LOW    = &4.
*$  &1-HIGH   = &5.
*$  APPEND &1.
*$
*$END-OF-DEFINITION.
*$
*$</form_fill_filter>

*$<rem_filter>
*$* &LRECNA-&LFNAME
*$</rem_filter>

*$<add2range>
*$   ADD2RANGE &RNAME '&SIGN' '&OPTI'
*$             '&LOW'
*$             '&HIGH'.
*$</add2range>

*$<endform_fill_filter>
*$
*$ENDFORM. "FILL_FILTER
*$
*$</endform_fill_filter>

ENDFORM.                    " PROCESS_FORM_FILL_FILTER
