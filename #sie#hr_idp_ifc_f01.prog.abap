*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_F01                                        *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  RETURN
*&---------------------------------------------------------------------*
*       BACK (Grüner Pfeil)
*----------------------------------------------------------------------*
FORM back.

  STATICS: exit(1) TYPE c.

  PERFORM check_loss_of_data USING okcode
                             CHANGING exit.

  IF exit EQ yes. EXIT. ENDIF. "operation abgebrochen

  CASE g_status_tran.
    WHEN c_1000_stat.
      CLEAR g_proc_vec.
      CLEAR g_ifdata_tran.
*     Beim Verlassen des Einstiegsbildes die Sperre aufheben.
      PERFORM dequeue.
    WHEN c_1006_stat.
      CLEAR: g_feldname, g_700_satzart, g_satzart_old,
             g_feldname_idx.

    WHEN OTHERS.
*     do nothing
  ENDCASE.

  SET SCREEN 0. LEAVE SCREEN.

ENDFORM.                    " BACK

*---------------------------------------------------------------------*
*       FORM BREA                                                     *
*---------------------------------------------------------------------*
*       Break (Gelber Pfeil)                                          *
*---------------------------------------------------------------------*
FORM brea.
  STATICS: exit(1) TYPE c.
  PERFORM check_loss_of_data USING okcode CHANGING exit.
  IF exit EQ yes. EXIT. ENDIF. "operation abgebrochen

  CLEAR g_proc_vec.
  CLEAR g_ifdata_tran.

  CASE g_status_tran.
    WHEN c_1000_stat.
      PERFORM dequeue.
      LEAVE PROGRAM.
    WHEN OTHERS.
      CLEAR: g_feldname, g_700_satzart, g_satzart_old,
             g_feldname_idx.
      IF sy-tcode = '/SIE/HR_IDP_IFC_NEW'.
        PERFORM dequeue.
        LEAVE PROGRAM.
      ELSE.
        CALL SCREEN c_main_dynp.
      ENDIF.
  ENDCASE.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM XEND                                                     *
*---------------------------------------------------------------------*
*       Cancel (Rotes Kreuz)                                          *
*---------------------------------------------------------------------*
FORM xend.
  STATICS: exit(1) TYPE c.
  PERFORM check_loss_of_data USING okcode CHANGING exit.
  IF exit EQ yes. EXIT. ENDIF. "operation abgebrochen

  CLEAR g_proc_vec.
  CLEAR g_ifdata_tran.
  CLEAR: g_feldname, g_700_satzart, g_satzart_old,
             g_feldname_idx.

  PERFORM dequeue.
  LEAVE PROGRAM.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_VERSION
*&---------------------------------------------------------------------*
*       Dieses Form überprüft die aktuell selektierte Version
*       danach, ob diese die aktuellste ist.
*       Dabei bedeutet N, daß es sich um die aktuellste Version handelt
*       und O um eine alte, die nicht verändert werden darf.
*----------------------------------------------------------------------*
FORM check_version.
  IF g_ifdata_tran-s1-act_vers_nr = g_ifdata_vers.
    g_ifvers_type = c_inew_vers.
  ELSE.
    g_ifvers_type = c_iold_vers.
  ENDIF.
ENDFORM.                    " CHECK_VERSION

*&---------------------------------------------------------------------*
*&      Form  DEQUEUE
*&---------------------------------------------------------------------*
*       Dieses FORM entsperrt die Schnittstelle
*----------------------------------------------------------------------*
FORM dequeue.
  IF g_ifdata_oldv IS INITIAL.
  ELSE.
    CALL FUNCTION 'DEQUEUE_/SIE/HR_IDPIFCID'
      EXPORTING
        mode_/sie/hr_idp_s1 = 'E'
        mandt               = sy-mandt
        ifcid               = g_ifdata_oldv
        _synchron           = yes.
  ENDIF.
ENDFORM.                    " DEQUEUE

*---------------------------------------------------------------------*
*       FORM ENQUEUE                                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM enqueue.

  DATA: user LIKE sy-msgv1.

  CHECK g_ifdata_tran-s1-ifcid >< space.

  CALL FUNCTION 'ENQUEUE_/SIE/HR_IDPIFCID'
    EXPORTING
      mode_/sie/hr_idp_s1 = 'E'
      mandt               = sy-mandt
      ifcid               = g_ifdata_tran-s1-ifcid
    EXCEPTIONS
      foreign_lock        = 1
      system_failure      = 2
      OTHERS              = 3.
  CASE sy-subrc.
    WHEN 0.
* Do nothing!
    WHEN 1.
* Überprüfen, ob der Benutzer sich selbst sperrt oder nicht.
      IF sy-msgv1 = sy-uname.
        CLEAR: svcode, okcode.
        MESSAGE w106 WITH sy-msgv1.
      ELSE.
        CLEAR: svcode, okcode.
        user = sy-msgv1.
        MESSAGE w105 WITH TEXT-001 g_ifdata_tran-s1-ifcid
                          user.
      ENDIF.
    WHEN OTHERS.
      CLEAR: svcode, okcode.
      user = sy-msgv1.
      MESSAGE w105 WITH TEXT-001 g_ifdata_tran-s1-ifcid
                          user.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PAGING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SVCODE  text
*----------------------------------------------------------------------*
FORM paging USING p_svcode LIKE sy-ucomm.

  DATA: l_display LIKE sy-tabix.
  FIELD-SYMBOLS: <c> TYPE cxtab_control.

  CASE g_status_tran.
    WHEN c_1000_stat.
      ASSIGN tc_vers TO <c>.
    WHEN c_1001_stat OR c_4001_stat.
      ASSIGN tc_matrix TO <c>.
    WHEN c_1002_stat.
      ASSIGN tc_var TO <c>.
    WHEN c_1004_stat.
      ASSIGN tc_prog TO <c>.
    WHEN c_3000_stat.
      ASSIGN tc_released TO <c>.
    WHEN OTHERS.
  ENDCASE.

  CALL FUNCTION 'SCROLLING_IN_TABLE'
    EXPORTING
      ok_code     = p_svcode
      entry_act   = <c>-top_line
      entry_to    = <c>-lines
      loops       = step_lines
      overlapping = 'X'
    IMPORTING
      entry_new   = <c>-top_line
    EXCEPTIONS
      OTHERS      = 1.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*  CASE G_STATUS_TRAN.
*    WHEN C_1000_STAT.
*      PERFORM SCROLL_AT_TC USING P_SVCODE
*                                 TC_VERS-LINES
**                                 tab_lines
*                                  STEP_LINES
*                            CHANGING TC_VERS-TOP_LINE.
*    WHEN C_1001_STAT.
*      PERFORM SCROLL_AT_TC USING P_SVCODE
*                                 TC_MATRIX-LINES
**                                 tab_lines
*                                  STEP_LINES
*                            CHANGING TC_MATRIX-TOP_LINE.
*    WHEN C_1002_STAT.
*      PERFORM SCROLL_AT_TC USING P_SVCODE
*                                 TC_VAR-LINES
**                                 tab_lines
*                                  STEP_LINES
*                            CHANGING TC_VAR-TOP_LINE.
*    WHEN C_1004_STAT.
*      PERFORM SCROLL_AT_TC USING P_SVCODE
*                                 TC_PROG-LINES
**                                 tab_lines
*                                  STEP_LINES
*                            CHANGING TC_PROG-TOP_LINE.
*    WHEN C_3000_STAT.
*      PERFORM SCROLL_AT_TC USING P_SVCODE
*                                 TC_RELEASED-LINES
**                                 tab_lines
*                                  STEP_LINES
*                            CHANGING TC_RELEASED-TOP_LINE.
*    WHEN OTHERS.
*  ENDCASE.
ENDFORM.                    " PAGING

*---------------------------------------------------------------------*
*       FORM scroll_at_tc                                             *
*---------------------------------------------------------------------*
*       Generische Implementation eines Scrollmechanismus fur         *
*       beliebige Table Controls.                                     *
*---------------------------------------------------------------------*
FORM scroll_at_tc USING VALUE(scroll)
                        VALUE(lines)
                        VALUE(step_lines)
               CHANGING top_line.

*  STATICS: OFFSET TYPE I.
*  case scroll.
*    WHEN 'P+'.
*      OFFSET = LINES - STEP_LINES.
*      IF TOP_LINE LT OFFSET.
*        TOP_LINE = TOP_LINE + STEP_LINES.
*      ENDIF.
*    WHEN 'P-'.
*      OFFSET = STEP_LINES.
*      IF TOP_LINE GT OFFSET.
*        TOP_LINE = TOP_LINE - STEP_LINES.
*      ELSE.
*        TOP_LINE = 1.
*      ENDIF.
*    when 'P++'.
*      TOP_LINE = LINES - STEP_LINES + 1.
*      IF TOP_LINE LE 0.
*        TOP_LINE = 1.
*      ENDIF.
*    when 'P--'.
*      top_line = 1.
*  endcase.
  CALL FUNCTION 'SCROLLING_IN_TABLE'
    EXPORTING
*     ENTRY_ACT             = 0
*     ENTRY_FROM            = 1
      entry_to              = step_lines
      last_page_full        = space
      loops                 = lines
      ok_code               = scroll
*     OVERLAPPING           = ' '
*     PAGE_ACT              = 0
*     PAGE_GO               = 0
    IMPORTING
*     ENTRIES_SUM           =
      entry_new             = top_line
*     PAGES_SUM             =
*     PAGE_NEW              =
    EXCEPTIONS
      no_entry_or_page_act  = 1
      no_entry_to           = 2
      no_ok_code_or_page_go = 3
      OTHERS                = 4.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " SCROLL_AT_TC

*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_COMMANDS
*&---------------------------------------------------------------------*
*       Verändert je nach status der Transaktion den GUI Status
*----------------------------------------------------------------------*
FORM exclude_commands.

  DATA: l_work_excl_cmd TYPE ty_excmd
      , l_pf_title TYPE ty_pfmenu
      , wa_s1f LIKE /sie/hr_idp_s1f
      , l_d1 TYPE d
      .

  DEFINE exclude_command.
    l_work_excl_cmd-func = &1.
    APPEND l_work_excl_cmd TO g_excl_commands.
  END-OF-DEFINITION.

  DEFINE exclude_save.
    IF sy-tcode = '/SIE/HR_IDP_IFC_DISP'.
      exclude_command 'SAVE'.
    ELSE.
      PERFORM read_s1f.
      CALL FUNCTION '/SIE/HR_IDP_RELE_DATE'
           EXPORTING
                vrsnr        = g_ifdata_vers
                s1f          = g_ifdata_tran-s1f
           IMPORTING
                release_date = l_d1.
      IF NOT ( l_d1 IS INITIAL ).
        exclude_command 'SAVE'.
      ENDIF.
    ENDIF.
  END-OF-DEFINITION.

  DEFINE exclude_navigation.
    exclude_command: c_ppp__code
                   , c_pp___code
                   , c_pm___code
                   , c_pmm__code
                   .
  END-OF-DEFINITION.

  DEFINE exclude_upload.

    exclude_command: 'DOWNLOAD'
                   , 'UPLOAD'
                   .
  END-OF-DEFINITION.


  DEFINE exclude_rele.
    exclude_command: 'CHECK'
                   , 'RELE'
                   , 'ACCP'
                   , 'TRUN'
*                   , c_adhoc_code
                   , c_vdel_code
                   , c_vers_code
                   .
  END-OF-DEFINITION.

  DEFINE exclude_lineedit.
    IF ( sy-tcode >< '/SIE/HR_IDP_IFC_MOD' )
    OR ( sy-tcode ><  '/SIE/HR_IDP_IFC_NEW' ).
      exclude_command: 'L_NEW'
                     , 'L_CUT'
                     , 'L_COPY'
                     , 'L_PASTE'
                     , 'L_LNEW'
                     , 'L_DEL'
                     , 'L_LDEL'.
      .
    ENDIF.
  END-OF-DEFINITION.

  DEFINE exclude_line_show.
    IF sy-tcode = '/SIE/HR_IDP_IFC_DISP'.
      exclude_command: 'L_NEW'
                     , 'L_DEL'
                     , 'L_CUT'
                     , 'L_COPY'
                     , 'L_PASTE'
                     , 'L_LNEW'
                     , 'L_DEL'
                     , 'L_LDEL'
                           .
    ENDIF.
  END-OF-DEFINITION.

  DEFINE exclude_transactions.
    exclude_command: '/SIE/HR_IDP_IFC_NEW'
                   , '/SIE/HR_IDP_IFC_MOD'
                   , '/SIE/HR_IDP_IFC_DISP'
                   , '/SIE/HR_IDP_IFC_RELE'
                   , '/SIE/HR_IDP_IFC_CONF'
                   .
  END-OF-DEFINITION.

  DEFINE exclude_details.
    exclude_command: c_head_code
                   , c_vari_code
                   , c_prog_code
                   , c_copy_code
                   , c_defi_code
*                  , c_docu_code
                   , c_admi_code
                   , c_time_code
                   .
  END-OF-DEFINITION.

  DEFINE exclude_documentation.
    PERFORM modify_docu_buttons.
  END-OF-DEFINITION.

  DEFINE exclude_adhoc.
    exclude_command: 'ADHOC'.
  END-OF-DEFINITION.

* Hier wird der Status der Transaktion festgesetzt. Status in diesem
* Sinne soll bedeuten: wir pflegen (1) die Kopfdaten, (2) die Varianten,
* etc. Der Status ist nicht gleich Dynpronummer, da unter den
* 3 Hauptdynpros weitere Detail-Dynpros auftauchen können.
  CLEAR g_excl_commands[].

  exclude_command 'OPTI'.                                   "#EC NOTEXT

  CASE sy-dynnr.
    WHEN c_main_dynp.
      l_pf_title = c_modi_must.
      g_status_tran = c_1000_stat.
      exclude_documentation.
      exclude_command c_save_code.
      exclude_command c_admi_code.
      exclude_lineedit.
      exclude_command c_rmod_code.
      exclude_command c_find_code.
      exclude_command:
                      'RELE'
                     , 'TRUN'
                     , 'ACCP'
                     .
      IF sy-tcode = '/SIE/HR_IDP_IFC_DISP'.
        exclude_command: c_vdel_code
                       , c_copy_code
                       , c_vers_code
                       .
      ENDIF.
      exclude_upload.
      exclude_adhoc.

    WHEN c_head_dynp.
      g_status_tran = c_1001_stat.
      l_pf_title = c_head_must.
      exclude_documentation.
      exclude_save.
      exclude_command c_prin_code.
      exclude_command c_rmod_code.
      exclude_command c_ifcf_code.
      exclude_command c_new__code.
      exclude_command c_copy_code.
      exclude_command c_tran_code.
      exclude_command c_head_code.
      exclude_lineedit.
      exclude_command c_find_code.
      exclude_transactions.
      exclude_rele.
      exclude_upload.
      exclude_adhoc.

    WHEN c_vari_dynp.
      l_pf_title = c_vari_must.
      g_status_tran = c_1002_stat.
      exclude_save.
      exclude_command c_prin_code.
      exclude_documentation.
      exclude_command c_rmod_code.
      exclude_command c_ifcf_code.
*      exclude_navigation.
      exclude_command c_find_code.
      exclude_command: c_new__code
                     , c_copy_code
                     , c_tran_code
                     , c_vari_code.
      exclude_command c_tran_code.
      exclude_command c_vari_code.
      exclude_transactions.
      IF ( sy-tcode >< '/SIE/HR_IDP_IFC_MOD' )
      OR ( sy-tcode ><  '/SIE/HR_IDP_IFC_NEW' ).
        exclude_command 'L_LDEL'.
        exclude_command: 'L_CUT'
                       , 'L_COPY'
                       , 'L_PASTE'
                       , 'L_LNEW'
                       , 'L_NEW'
                       .
      ENDIF.
      exclude_rele.
      READ TABLE g_ifdata_tran-s1f INTO wa_s1f WITH KEY trole = '06'.
      IF NOT ( wa_s1f-ch_datum IS INITIAL ).
        exclude_lineedit.
      ENDIF.
      IF sy-tcode = '/SIE/HR_IDP_IFC_DISP'.
        exclude_command 'L_DEL'.
      ENDIF.
      exclude_upload.
      exclude_adhoc.

    WHEN c_prog_dynp.
      l_pf_title = c_para_must.
      g_status_tran = c_1003_stat.
      exclude_save.
      exclude_documentation.
      exclude_command c_prin_code.
      exclude_command c_rmod_code.
      exclude_command c_ifcf_code.
      exclude_command c_new__code.
      exclude_command c_copy_code.
      exclude_command c_tran_code.
      exclude_command c_prog_code.
      exclude_lineedit.
      exclude_command c_find_code.
      exclude_transactions.
      exclude_rele.
      exclude_navigation.
      exclude_upload.
      exclude_adhoc.

    WHEN c_defi_dynp.
      l_pf_title = c_prog_must.
      g_status_tran = c_1004_stat.
      exclude_save.
      exclude_documentation.
      exclude_command c_prin_code.
      exclude_command c_rmod_code.
      exclude_command c_new__code.
      exclude_command c_copy_code.
      exclude_command c_tran_code.
      exclude_line_show.
      exclude_command c_defi_code.
      exclude_transactions.
      exclude_command c_ifcf_code.
      exclude_rele.
*      if not ( g_ifdata_tran-s1vn-release_date is initial ).
      READ TABLE g_ifdata_tran-s1f INTO wa_s1f WITH KEY trole = '06'.
      IF NOT ( wa_s1f-ch_datum IS INITIAL ).
        exclude_lineedit.
      ENDIF.
      exclude_upload.
      exclude_adhoc.

    WHEN c_accp_sdyn.
      l_pf_title = c_modi_must.
      g_status_tran = c_3000_stat.
      exclude_save.
      exclude_command c_prin_code.
      exclude_documentation.
      exclude_lineedit.
      exclude_command c_rmod_code.
      exclude_details.
      exclude_command 'CHECK'.
      exclude_command 'RELE'.
      exclude_command 'TRUN'.
      exclude_command c_save_code.
      exclude_command c_find_code.
      exclude_command 'TRUN'.
      exclude_command 'IFVS'.
      exclude_command '%PRI'.
      exclude_command 'VDEL'.
      exclude_command c_pric_code.
      exclude_upload.
      exclude_adhoc.

    WHEN c_frei_sdyn.
      l_pf_title = c_modi_must.
      g_status_tran = c_2000_stat.
      exclude_command 'VDEL'.
      exclude_command 'IFVS'.
      exclude_command '%PRI'.
      exclude_save.
      exclude_documentation.
      exclude_navigation.
      exclude_command c_rmod_code.
      exclude_lineedit.
      exclude_details.
      exclude_command 'ACCP'.
      exclude_command 'LEGE'.
      exclude_command 'TRUN'.
      exclude_command c_save_code.
      exclude_command c_find_code.
      exclude_command c_vdel_code.
      exclude_command c_pric_code.
      exclude_upload.
      exclude_adhoc.

    WHEN c_time_dynp.
      g_status_tran = c_1005_stat.
      l_pf_title = c_time_must.
      exclude_save.
      exclude_documentation.
      exclude_command c_prin_code.
      exclude_command c_rmod_code.
      exclude_command c_ifcf_code.
      exclude_command c_new__code.
      exclude_command c_copy_code.
      exclude_command c_tran_code.
      exclude_command c_time_code.
      exclude_lineedit.
      exclude_command c_find_code.
      exclude_transactions.
      exclude_rele.
      exclude_navigation.
      exclude_upload.
      exclude_adhoc.

    WHEN c_rmod_sdyn.
      l_pf_title = c_rmod_must.
      g_status_tran = c_4000_stat.
      exclude_save.
      exclude_command c_pric_code.
      exclude_command c_prin_code.
      exclude_documentation.
      exclude_navigation.
      exclude_lineedit.
      exclude_details.
      exclude_command 'ACCP'.
      exclude_command 'LEGE'.
      exclude_command c_save_code.
      exclude_command c_find_code.
      exclude_command 'CHECK'.
      exclude_command 'RELE'.
      exclude_command 'TRUN'.
      exclude_command: c_vdel_code
                     , c_copy_code
                     , c_vers_code
                     .
      exclude_command c_pric_code.
      exclude_upload.

    WHEN c_modr_sdyn.
      l_pf_title = c_rmod_must.
      g_status_tran = c_4001_stat.
      exclude_command c_prin_code.
      exclude_documentation.
      exclude_lineedit.
      exclude_details.
      exclude_transactions.
      exclude_command 'ACCP'.
      exclude_command 'LEGE'.
      exclude_command c_find_code.
      exclude_command 'CHECK'.
      exclude_command 'RELE'.
      exclude_command 'TRUN'.
      exclude_command c_pric_code.
      exclude_command c_rmod_code.
      exclude_command: c_vdel_code
                     , c_copy_code
                     , c_vers_code
                     .
      exclude_upload.
      exclude_adhoc.

    WHEN '1006'.
      l_pf_title = c_prog_must.
      g_status_tran = c_1004_stat.
      exclude_save.
      exclude_documentation.
      exclude_command c_prin_code.
      exclude_command c_rmod_code.
      exclude_command c_new__code.
      exclude_command c_copy_code.
      exclude_command c_tran_code.
      exclude_line_show.
      exclude_command c_defi_code.
      exclude_transactions.
      exclude_command c_ifcf_code.
      exclude_rele.
      exclude_navigation.
      exclude_adhoc.
      READ TABLE g_ifdata_tran-s1f INTO wa_s1f WITH KEY trole = '06'.
      IF NOT ( wa_s1f-ch_datum IS INITIAL ).
        exclude_lineedit.
      ENDIF.
      exclude_command: 'L_NEW'
                     , 'L_DEL'
                     , 'L_CUT'
                     , 'L_COPY'
                     , 'L_PASTE'
                     , 'L_LNEW'
                     , 'L_DEL'
                     , 'L_LDEL'
                     .

      IF ( sy-tcode >< '/SIE/HR_IDP_IFC_MOD' )
      AND ( sy-tcode ><  '/SIE/HR_IDP_IFC_NEW' ).
        exclude_command 'UPLOAD'.                           "#EC NOTEXT
      ELSE.
        READ TABLE g_ifdata_tran-s1f INTO wa_s1f WITH KEY trole = '06'.
        IF NOT ( wa_s1f-ch_datum IS INITIAL ).
          exclude_command 'UPLOAD'.                         "#EC NOTEXT
        ENDIF.
      ENDIF.

    WHEN c_1007_dynp.
      l_pf_title = c_pric_must.
      g_status_tran = c_1007_stat.
      exclude_save.
      exclude_documentation.
      exclude_command c_prin_code.
      exclude_command c_rmod_code.
      exclude_command c_ifcf_code.
      exclude_command c_pric_code.
      exclude_command c_new__code.
      exclude_command c_copy_code.
      exclude_command c_tran_code.
      exclude_lineedit.
      exclude_command c_find_code.
      exclude_transactions.
      exclude_rele.
      exclude_navigation.
      exclude_upload.
      exclude_adhoc.

    WHEN c_adhoc_sdyn.   " Ad-Hoc Testlauf
      l_pf_title = c_modi_must.
      g_status_tran = c_2500_stat.
      exclude_save.
      exclude_documentation.
      exclude_navigation.
      exclude_command c_rmod_code.
      exclude_lineedit.
      exclude_details.
      exclude_command c_save_code.
      exclude_command c_find_code.
      exclude_command c_vdel_code.
      exclude_command c_pric_code.
      exclude_upload.
      exclude_rele.
      exclude_command 'VDEL'.
      exclude_command 'IFVS'.
      exclude_command '%PRI'.
      exclude_command 'ACCP'.
      exclude_command 'LEGE'.
      exclude_command 'TRUN'.

    WHEN OTHERS.
*     Setzte keins, erbe vom letzten Dynpro.
  ENDCASE.

  CASE sy-tcode.
    WHEN '/SIE/HR_IDP_IFC_NEW'.
      exclude_command '/SIE/HR_IDP_IFC_NEW'.
    WHEN '/SIE/HR_IDP_IFC_MOD'.
      exclude_command '/SIE/HR_IDP_IFC_MOD'.
    WHEN '/SIE/HR_IDP_IFC_DISP'.
      exclude_command '/SIE/HR_IDP_IFC_DISP'.
    WHEN '/SIE/HR_IDP_IFC_RELE'.
      exclude_command '/SIE/HR_IDP_IFC_RELE'.
    WHEN '/SIE/HR_IDP_IFC_CONF'.
      exclude_command '/SIE/HR_IDP_IFC_CONF'.
    WHEN OTHERS.
  ENDCASE.

  g_pf_title = l_pf_title.

ENDFORM.                    " EXCLUDE_COMMANDS

*&---------------------------------------------------------------------*
*&      Form  NEW_VERSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM new_version.
  CALL FUNCTION '/SIE/HR_IDP_NEW_VERSION'
    EXPORTING
      ifcid        = g_ifdata_tran-s1-ifcid
    EXCEPTIONS
      not_released = 1
      no_enqueue   = 2
      OTHERS       = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR g_proc_vec.
    CLEAR g_ifdata_tran.
    CLEAR g_ifdata_vers.
    CALL FUNCTION '/SIE/HR_IDP_DB_INIT'.
    PERFORM dequeue.
  ENDIF.

ENDFORM.                    " NEW_VERSION

*&---------------------------------------------------------------------*
*&      Form  INIT_S1R
*&---------------------------------------------------------------------*
FORM init_s1f.

  DATA: wa_s1f TYPE /sie/hr_idp_s1f.
  CLEAR g_ifdata_tran-s1f[].
  wa_s1f-ifcid = g_ifdata_tran-s1-ifcid.
  wa_s1f-vrsnr = '0001'.
  wa_s1f-trole = '06'.
  APPEND wa_s1f TO g_ifdata_tran-s1f.
  wa_s1f-trole = '07'.
  APPEND wa_s1f TO g_ifdata_tran-s1f.

ENDFORM.                                                    " INIT_S1R

*&---------------------------------------------------------------------*
*&      Form  MODIFY_DOCU_BUTTONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_docu_buttons.
  DATA:  fl_display TYPE xflag
        , vrsnr LIKE /sie/hr_idp_s1vn-vrsnr
  .

  DATA: l_work_excl_cmd TYPE ty_excmd
      , l_pf_title TYPE ty_pfmenu
      , wa_s1f LIKE /sie/hr_idp_s1f
      .

  DEFINE exclude_command.
    l_work_excl_cmd-func = &1.
    APPEND l_work_excl_cmd TO g_excl_commands.
  END-OF-DEFINITION.

  SELECT MAX( vrsnr ) FROM /sie/hr_idp_s1vn
                      INTO vrsnr
                      WHERE ifcid = /sie/hr_idp_s1-ifcid.

  SELECT SINGLE * FROM /sie/hr_idp_s1f
               WHERE ifcid = /sie/hr_idp_s1-ifcid
           AND vrsnr = vrsnr
           AND trole = '06'.
  IF sy-subrc = 0.
    IF NOT ( /sie/hr_idp_s1f-ch_datum IS INITIAL ).
      fl_display = 'X'.
    ELSE.
      CLEAR fl_display.
    ENDIF.
  ELSE.
    CLEAR fl_display.
  ENDIF.

  IF sy-tcode = '/SIE/HR_IDP_IFC_DISP' OR fl_display = 'X'
     OR sy-tcode = '/SIE/HR_IDP_IFC_RELE'
     OR sy-tcode = '/SIE/HR_IDP_IFC_CONF'
     OR sy-tcode = '/SIE/HR_IDP_ADHOC'.
    exclude_command 'DOCU'.
    exclude_command 'DOCU2'.
  ELSE.
    SELECT SINGLE * FROM  /sie/hr_idp_s1lt
           WHERE  spras  = sy-langu
*<XFT>
*           and    ifcid  = /sie/hr_idp_s1-ifcid.
            AND ifcid = g_ifdata_tran-s1-ifcid.
*<XFT>
    IF sy-subrc >< 0.
      exclude_command 'DOCU'.
      exclude_command 'DOCU3'.
    ELSE.
      exclude_command 'DOCU2'.
      exclude_command 'DOCU3'.
    ENDIF.
  ENDIF.

ENDFORM.                    " MODIFY_DOCU_BUTTONS

*&---------------------------------------------------------------------*
*&      Form  refresh_reference "SIE002
*&---------------------------------------------------------------------*
*       Aktuelle Daten aus Referenzschnittstelle übernehmen
*----------------------------------------------------------------------*
FORM refresh_reference.
  DATA: l_d1 TYPE d.

  CHECK NOT g_ifdata_tran-s1dl-referenz IS INITIAL.

*  Nur wenn Version nicht freigegeben ist
  CHECK sy-tcode = c_modi_tcod OR sy-tcode = c_new__tcod.
  CALL FUNCTION '/SIE/HR_IDP_RELE_DATE'
    EXPORTING
      vrsnr        = g_ifdata_vers
      s1f          = g_ifdata_tran-s1f
    IMPORTING
      release_date = l_d1.

  CHECK l_d1 IS INITIAL.

*  Schnittstellendaten aktualisieren
  CALL FUNCTION '/SIE/HR_IDP_REFRESH_REFERENCE'
    CHANGING
      transaction_data  = g_ifdata_tran
    EXCEPTIONS
      no_active_version = 1
      OTHERS            = 2.

  IF sy-subrc <> 0.
    MESSAGE i452.
  ENDIF.


ENDFORM.                    " refresh_reference
*&---------------------------------------------------------------------*
*&      Form  modify_screen                                "SIE003
*&---------------------------------------------------------------------*
FORM modify_screen.

  DATA: mode.

  PERFORM get_transaction_mode CHANGING mode.

  IF mode = 'D'.



*    Felder nur anzeigen
    LOOP AT SCREEN.
      IF screen-group1 = '001'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

    LOOP AT SCREEN.
      IF screen-group1 = '002'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ENDIF.


   IF /sie/hr_idp_s1df-sftp_transfer = ''.

    LOOP AT SCREEN.
      IF screen-group2 = '102'.
*         screen-INVISIBLE = '1'.
        screen-active = '0'.
*         screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF /sie/hr_idp_s1df-sftp_transfer = 'X'.

    LOOP AT SCREEN.
      IF screen-group2 = '101'.
*         screen-INVISIBLE = '1'.
        screen-active = '0'.
*         screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.


ENDFORM.                    " modify_screen
*&---------------------------------------------------------------------*
*&      Form  get_transaction_mode             "SIE003
*&---------------------------------------------------------------------*
*       Ermittelt aktuellen Bearbeitungsmodus der Schnittstelle
*----------------------------------------------------------------------*
*      <--Mode
*         'M' = Bearbeiten
*         'D' = Anzeigen
*----------------------------------------------------------------------*
FORM get_transaction_mode CHANGING mode TYPE c.

  DATA: l_d1 TYPE d.

  mode = 'M'.

* In folgenden Fällen nur Anzeigemodus
  CASE sy-tcode.
    WHEN c_disp_tcod OR c_rele_tcod OR c_accp_tcod.
      mode = 'D'.
    WHEN  c_modi_tcod OR c_new__tcod.
      CALL FUNCTION '/SIE/HR_IDP_RELE_DATE'
        EXPORTING
          vrsnr        = g_ifdata_vers
          s1f          = g_ifdata_tran-s1f
        IMPORTING
          release_date = l_d1.
      IF NOT ( l_d1 IS INITIAL ).
*        Umschalten zwischen Anzeigen und Ändern
        mode = 'D'.
      ELSE.
*     do nothing
      ENDIF.
    WHEN c_rmod_tcod.
* Alles änderbar machen
    WHEN OTHERS.
      mode = 'D'.
  ENDCASE.


ENDFORM.                    " get_transaction_mode
*&---------------------------------------------------------------------*
*&      Form  check_db_consistency
*&---------------------------------------------------------------------*
*       Prüft, ob Tabellen S1PG und S1PS zusammenpassen
*----------------------------------------------------------------------*
FORM check_db_consistency.

  LOOP AT g_ifdata_tran-s1ps INTO /SIE/HR_IDP_s1ps.
    READ TABLE g_ifdata_tran-s1pg TRANSPORTING NO FIELDS
                       WITH KEY recna = /SIE/HR_IDP_s1ps-recna
                                fldps = /SIE/HR_IDP_s1ps-fldps.
    IF sy-subrc <> 0.
      DELETE g_ifdata_tran-s1ps.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " check_db_consistency
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen INPUT.

if svcode = c_save_code.
  IF /sie/hr_idp_s1df-sftp_transfer = 'X'.
    CLEAR /sie/hr_idp_s1df-trfad.
   else.
     CLEAR /sie/hr_idp_s1df-sftp_user.
     CLEAR /sie/hr_idp_s1df-sftp_publickey.
     CLEAR /sie/hr_idp_s1df-sftp_zielverzeichnis.
     CLEAR /sie/hr_idp_s1df-sftp_configfile.
    endif.
endif.


ENDMODULE.
