*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_F1006 .
*----------------------------------------------------------------------*
**************************************************************************************
*Änderungen:
*            "HAN002  FUBA HR_COMPLEX_SELECTIONS ist nicht mit ERP2005 ausgeliefert
*
**************************************************************************************
*&---------------------------------------------------------------------*
*&      Form  PAGE_RECNA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form page_recna.

  data: min type i
      , max type i
      , idx type i
      .

  min = 1.
  describe table g_itab_sa lines max.

  case svcode.
    when 'R--'.
      idx = min.
      read table g_itab_sa index idx
                           into /sie/hr_idp_satzarten_tc.
      if sy-subrc = 0.
        g_700_satzart = /sie/hr_idp_satzarten_tc-recna.
      else.
      endif.

    when 'R-'.
      read table g_itab_sa transporting no fields
                           with key recna = g_700_satzart.
      idx = sy-tabix - 1.
      if idx < min.
        idx = min.
      endif.

      read table g_itab_sa index idx
                           into /sie/hr_idp_satzarten_tc.
      if sy-subrc = 0.
        g_700_satzart = /sie/hr_idp_satzarten_tc-recna.
      else.
      endif.

    when 'R+'.
      read table g_itab_sa transporting no fields
                           with key recna = g_700_satzart.
      idx = sy-tabix + 1.

      if idx > max.
        idx = max.
      endif.

      read table g_itab_sa index idx
                           into /sie/hr_idp_satzarten_tc.
      if sy-subrc = 0.
        g_700_satzart = /sie/hr_idp_satzarten_tc-recna.
      else.
      endif.

    when 'R++'.
      idx = max.
      read table g_itab_sa index idx
                           into /sie/hr_idp_satzarten_tc.
      if sy-subrc = 0.
        g_700_satzart = /sie/hr_idp_satzarten_tc-recna.
      else.
      endif.
    when others.

  endcase.

endform.                    " PAGE_RECNA

*&---------------------------------------------------------------------*
*&      Form  FIELD_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form field_user_command.
  data: l_admin type /sie/hr_idp_adm
      , cursor_offset     like sy-stepl
      , cursor_line       like sy-stepl
      , cursor_field(70) type c
      , l_idx like sy-tabix
      , fl type ty_yesno
      .

  case svcode.

    when 'PICK'.
      get cursor field cursor_field
                 line  cursor_line
                 offset  cursor_offset.

      case cursor_field(21).
        when '/SIE/HR_IDP_SATZARTEN'.
          cursor_line = cursor_line + tc_sa-top_line - 1.
          read table g_itab_sa into /sie/hr_idp_satzarten_tc
                                    index cursor_line.
          g_satzart_old = g_700_satzart.
          clear: g_feldname, g_feldname_idx.
          g_700_satzart = /sie/hr_idp_satzarten_tc-recna.

        when '/SIE/HR_IDP_FELDER_TC'.
          cursor_line = cursor_line + tc_saf-top_line - 1.

*          READ TABLE g_itab_s1pg INTO /sie/hr_idp_felder_tc "SIE003
*                                    INDEX cursor_line.      "SIE003
          read table g_itab_s1pg index cursor_line.          "SIE003
          move-corresponding
               g_itab_s1pg to /sie/hr_idp_felder_tc.         "SIE003

          g_feldname = /sie/hr_idp_felder_tc-feldname.

        when others.
      endcase.

    when 'L_LNEW'.
      check not ( g_700_satzart is initial ).
      describe table g_itab_s1pg lines step_lines.
      tc_saf-top_line = step_lines.

      step_lines = step_lines_b - 1.
      clear /sie/hr_idp_felder_tc.
* Wir setzen den Mandanten hier damit die Sortierung
* in der Anzeige stimmt.
      /sie/hr_idp_felder_tc-mandt = sy-mandt.
      /sie/hr_idp_felder_tc-ifcid = g_ifdata_tran-s1-ifcid.
      /sie/hr_idp_felder_tc-vrsnr = g_ifdata_vers.
      /sie/hr_idp_felder_tc-recna = g_700_satzart.

      describe table g_itab_s1pg lines /sie/hr_idp_felder_tc-fldps.

      do step_lines times.
        add 1 to /sie/hr_idp_felder_tc-fldps.

*        APPEND /sie/hr_idp_felder_tc TO g_itab_s1pg.      "SIE003
        perform append_itab_s1pg_from_tc.                  "SIE003

      enddo.
      message s129.

    when 'L_NEW'.
*      CHECK NOT ( G_700_SATZART IS INITIAL ).
*      IF G_FELDNAME IS INITIAL.
*        DESCRIBE TABLE G_ITAB_S1PG LINES L_IDX.
*        L_IDX = L_IDX + 1.
*      ELSE.
*        READ TABLE G_ITAB_S1PG TRANSPORTING NO FIELDS
*                               WITH KEY FELDNAME = G_FELDNAME.
*        IF SY-SUBRC = 0.
*          L_IDX = SY-TABIX + 1.
*        ELSE.
*          DESCRIBE TABLE G_ITAB_S1PG LINES L_IDX.
*          L_IDX = L_IDX + 1.
*        ENDIF.
*      ENDIF.
*
*      CLEAR /SIE/HR_IDP_FELDER_TC.
*      /SIE/HR_IDP_FELDER_TC-MANDT = SY-MANDT.
*      /SIE/HR_IDP_FELDER_TC-IFCID = G_IFDATA_TRAN-S1-IFCID.
*      /SIE/HR_IDP_FELDER_TC-VRSNR = G_IFDATA_VERS.
*      /SIE/HR_IDP_FELDER_TC-RECNA = G_700_SATZART.
*
*      INSERT /SIE/HR_IDP_FELDER_TC INTO G_ITAB_S1PG INDEX L_IDX.
*      IF SY-SUBRC = 0.
*        MESSAGE S124.
*      ELSE.
*      ENDIF.
      check not ( g_700_satzart is initial ).
      loop at g_itab_s1pg where not ( mark is initial ).

        clear /sie/hr_idp_felder_tc.
        /sie/hr_idp_felder_tc-mandt = sy-mandt.
        /sie/hr_idp_felder_tc-ifcid = g_ifdata_tran-s1-ifcid.
        /sie/hr_idp_felder_tc-vrsnr = g_ifdata_vers.
        /sie/hr_idp_felder_tc-recna = g_700_satzart.

*        INSERT /sie/hr_idp_felder_tc INTO g_itab_s1pg
*                                     INDEX sy-tabix.      "SIE003
        perform insert_itab_s1pg_from_tc using sy-tabix.   "SIE003

        if sy-subrc = 0.
          message s124.
          exit.
        else.
        endif.
      endloop.
      if sy-subrc >< 0.    " Eine Zeile ist nicht markiert gewesen
        if g_feldname is initial.
          describe table g_itab_s1pg lines l_idx.
          l_idx = l_idx + 1.
          clear /sie/hr_idp_felder_tc.
          /sie/hr_idp_felder_tc-mandt = sy-mandt.
          /sie/hr_idp_felder_tc-ifcid = g_ifdata_tran-s1-ifcid.
          /sie/hr_idp_felder_tc-vrsnr = g_ifdata_vers.
          /sie/hr_idp_felder_tc-recna = g_700_satzart.
*          INSERT /sie/hr_idp_felder_tc INTO g_itab_s1pg
*                                       INDEX l_idx.       "SIE003
          perform insert_itab_s1pg_from_tc using l_idx.    "SIE003

          if sy-subrc = 0.
            message s124.
            exit.
          else.
          endif.
        endif.
      endif.

    when 'L_CUT'.
      check not ( g_700_satzart is initial ).
      loop at g_itab_s1pg.
        if not g_itab_s1pg-mark is initial.
          perform fill_field_clipboard.
          clear g_buffer_s1pg-mark.
          perform del_field_filter using g_itab_s1pg-recna
                                         g_itab_s1pg-fldps.
          delete g_itab_s1pg.
          message s126.
          fl = yes.
        endif.
      endloop.
      if fl = no.
        message s134.
      endif.

    when 'L_COPY'.
      check not ( g_700_satzart is initial ).
      loop at g_itab_s1pg.
        if not g_itab_s1pg-mark is initial.
          perform fill_field_clipboard.
          clear g_buffer_s1pg-mark.
          message s127.
          fl = yes.
        endif.
      endloop.
      if fl = no.
        message s134.
      endif.

    when 'L_PASTE'.
      check not ( g_700_satzart is initial ).
      if not g_buffer_s1pg is initial.
        refresh g_itab_s1pg_help_1006.
        loop at g_itab_s1pg.
* Die markierte Zeile ist nicht vom Feld mark abhängig, sondern von
* dem feld g_feldname_idx (siehe write_fields_matrix).
*          if not g_itab_s1pg-mark is initial.
          if sy-tabix gt 2.
            if sy-tabix = g_feldname_idx.
              append g_buffer_s1pg to g_itab_s1pg_help_1006.
*             Filter übernehmen(Not yet implemented)
              message s128.
              fl = yes.
            endif.
          endif.
          append g_itab_s1pg to g_itab_s1pg_help_1006.
        endloop.
        if fl = no.
          message s134.
        endif.
        g_itab_s1pg[] = g_itab_s1pg_help_1006[].
      endif.

    when 'L_FDEL'.
      check not ( g_700_satzart is initial ).
      loop at g_itab_s1pg.
        if not g_itab_s1pg-mark is initial.
          delete g_itab_s1pg.
          message s125.
          fl = yes.
        endif.
      endloop.
      if fl = no.
        message s134.
      endif.

    when 'L_UNDO'.
    when others.
  endcase.


endform.                    " FIELD_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  READ_INFTY_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form read_infty_text.

  clear: infty_text[]
       , subty_text[].

  if not ( /sie/hr_idp_satzarten_tc-infty is initial ).
    call function 'RH_INFTY_SUBTY_TEXT_PA'
      exporting
        infotype                = /sie/hr_idp_satzarten_tc-infty
      tables
        infotypes_text          = infty_text
        infotypes_subtypes_text = subty_text.

    read table infty_text index 1.
    if /sie/hr_idp_satzarten_tc-recty <> 3.
      /sie/hr_idp_satzarten_tc-ident_infty = infty_text-itext.
    else.
      clear /sie/hr_idp_satzarten_tc-ident_infty.
    endif.
    if /sie/hr_idp_satzarten_tc-subty <> space.
      read table subty_text
                      with key subty = /sie/hr_idp_satzarten_tc-subty.
      if sy-subrc = 0.
        if /sie/hr_idp_satzarten_tc-recty <> 3.
          /sie/hr_idp_satzarten_tc-ident_subty = subty_text-sutxt.
        else.
          clear /sie/hr_idp_satzarten_tc-ident_subty.
        endif.
      else.
        clear /sie/hr_idp_satzarten_tc-ident_subty.
      endif.
    else.
      clear /sie/hr_idp_satzarten_tc-ident_subty.
    endif.
  else.
    clear: /sie/hr_idp_satzarten_tc-ident_infty,
           /sie/hr_idp_satzarten_tc-ident_subty.
  endif.

endform.                    " READ_INFTY_TEXT

*&---------------------------------------------------------------------*
*&      Form  FIELD_CHECK_CONVERT
*&---------------------------------------------------------------------*
*       Prüft anhand des Feldkatalogs, ob ein Feld konvertiert
*       werden muß oder nicht.
*----------------------------------------------------------------------*
form field_check_convert.

  select single * from /sie/hr_idp_f1
                  where feldname = /sie/hr_idp_felder_tc-feldname.
  if sy-subrc = 0.
    case /sie/hr_idp_f1-konvstrg.
      when space. "alle zulässigen konvertierungen möglich
*       Alles mögliche ist in Ordnung.
      when 1.  "genau eine konvertierung erlaubt
*       Inhalt von /sie/hr_idp_felder_tc-konvna ist entweder initial
*       oder gefüllt, also sind beide in Ordnung.
      when 2. "genau eine konvertierung vorgeschrieben
* Die Konvertierung wird automatisch vom Feldkatalog gelesen
        if /sie/hr_idp_felder_tc-konvnam is initial.
*         message e141 with /sie/hr_idp_felder_tc-feldname.
          /sie/hr_idp_felder_tc-konvnam = /sie/hr_idp_f1-konvname.
          if /sie/hr_idp_felder_tc-param is initial.
            select single * from /sie/hr_idp_c1
                     where konvnam = /sie/hr_idp_f1-konvname.
            if sy-subrc = 0.
              /sie/hr_idp_felder_tc-param = /sie/hr_idp_c1-konvpara.
            else.
*            Do nothing
            endif.
          endif.
        endif.
      when 3. "keine konvertierung erlaubt
        if not ( /sie/hr_idp_felder_tc-konvnam is initial ).
          message e142 with /sie/hr_idp_felder_tc-feldname.
        endif.
      when others.
    endcase.

  endif.
endform.                    " FIELD_CHECK_CONVERT

*&---------------------------------------------------------------------*
*&      Module  CHECK_FIELD_TYPES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module check_field_types input.

  perform check_field_types.

endmodule.                 " CHECK_FIELD_TYPES  INPUT

*&---------------------------------------------------------------------*
*&      Form  CHECK_FIELD_TYPES
*&---------------------------------------------------------------------*
form check_field_types.

  if not ( /sie/hr_idp_felder_tc-feldname is initial ).
    call function '/SIE/HR_IDP_CHECK_CONVERSION'
      exporting
        logical_field  = /sie/hr_idp_felder_tc-feldname
        conversion     = /sie/hr_idp_felder_tc-konvnam
      exceptions
        not_allowed    = 1
        type_not_found = 2
        others         = 3.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.

endform.                    " CHECK_FIELD_TYPES

*&---------------------------------------------------------------------*
*&      Form  CHECK_FIELD_SINGULARITY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_field_singularity.

  read table g_itab_sa with key recna = g_700_satzart.
  if sy-subrc = 0.
    case g_itab_sa-recty.
      when 3.
        select single * from /sie/hr_idp_f1
                    where feldname = /sie/hr_idp_felder_tc-feldname.
        if /sie/hr_idp_f1-singular = 'X'.
        else.
          message w143 with g_700_satzart.
        endif.
      when 4.
        select single * from /sie/hr_idp_f1
                    where feldname = /sie/hr_idp_felder_tc-feldname.
        if /sie/hr_idp_f1-singular = 'X'.
        else.
          if /sie/hr_idp_f1-infty = g_itab_sa-infty.
          else.
            message w144 with g_700_satzart.
          endif.
        endif.

      when others.

    endcase.
  endif.
endform.                    " CHECK_FIELD_SINGULARITY
*&---------------------------------------------------------------------*
*&      Form  RECOUNT_SA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM F4_KONVNAM                                               *
*---------------------------------------------------------------------*
*       Find allowed conversions for logical fields                   *
*---------------------------------------------------------------------*
*  -->  P_KONVNAM  Conversion name                                    *
*---------------------------------------------------------------------*
form f4_konvnam changing p_konvnam type /sie/hr_idp_konvnam.

  types: begin of t_values
       ,  konvnam type /sie/hr_idp_konvnam
       ,  ident like /sie/hr_idp_c1t-ident
       , end of t_values
       .

  data: l_dynnr like sy-dynnr value '1006'
      , l_repid like sy-repid value '/SIE/HR_IDP_IFC'
      , l_itab_dynpfields type standard table of dynpread initial size 0
        with header line
      , l_wa_dynpfields like dynpread
      , l_itab_values type standard table of t_values initial size 0
         with header line
      , l_conversion type /sie/hr_idp_konvnam
      , l_fieldname like /sie/hr_idp_felder_tc-feldname
      .

  call function 'DYNP_GET_STEPL'
    importing
      povstepl        = l_wa_dynpfields-stepl
    exceptions
      stepl_not_found = 1
      others          = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    l_wa_dynpfields-fieldname = '/SIE/HR_IDP_FELDER_TC-FELDNAME'.
    append l_wa_dynpfields to l_itab_dynpfields.
  endif.

  call function 'DYNP_VALUES_READ'
    exporting
      dyname               = l_repid
      dynumb               = l_dynnr
    tables
      dynpfields           = l_itab_dynpfields
    exceptions
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      others               = 10.
  if sy-subrc <> 0.
    l_fieldname = space.
  else.
    read table  l_itab_dynpfields
         with key fieldname = '/SIE/HR_IDP_FELDER_TC-FELDNAME'.
    l_fieldname =  l_itab_dynpfields-fieldvalue.
  endif.

  if l_conversion is initial.
    l_conversion = '%'.
  else.
    l_conversion = p_konvnam.
    translate l_conversion using '*%+_'.
  endif.

  select * from /sie/hr_idp_conv where konvnam like l_conversion.

    call function '/SIE/HR_IDP_CHECK_CONVERSION'
      exporting
        logical_field  = l_fieldname
        conversion     = /sie/hr_idp_conv-konvnam
      exceptions
        not_allowed    = 1
        type_not_found = 2
        others         = 3.
    if sy-subrc <> 0.
* Do nothing.
    else.
      l_itab_values-konvnam = /sie/hr_idp_conv-konvnam.
      l_itab_values-ident = /sie/hr_idp_conv-ident.
      append l_itab_values.
    endif.

  endselect.

  check not ( l_itab_values[] is initial ).

  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield        = 'KONVNAM'
      dynpprog        = l_repid
      dynpnr          = l_dynnr
      dynprofield     = '/SIE/HR_IDP_FELDER_TC-KONVNAM'
      value_org       = 'S'
      multiple_choice = no
    tables
      value_tab       = l_itab_values
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.

*&---------------------------------------------------------------------*
*&      Form  MODIFY_REFERENCE "SIE002
*&---------------------------------------------------------------------*
*       Dialog zum Eintragen der Referenzschnittstelle
*----------------------------------------------------------------------*
form modify_reference.

  data: save_head like /sie/hr_idp_head.

*  Struktur ...IDP_HEAD sichern, da ebenfalls in Popup benötigt.
  save_head = /sie/hr_idp_head.
  clear /sie/hr_idp_head.
  /sie/hr_idp_s1dl-referenz = g_ifdata_tran-s1dl-referenz.

*  Dialog zur Eingabe der Referenzschnittstelle aufrufen
  call screen 0750 starting at 7 7.
  /sie/hr_idp_head = save_head.

  if okcode = 'OK'.

*     Daten aus Referenzschnittstelle übernehmen
    g_ifdata_tran-s1dl-referenz = /sie/hr_idp_s1dl-referenz.
    perform refresh_reference.

*     Satzartenzeiger zurücksetzen, da die markierte Satzart ja nicht
*     in der Referenzschnittstelle vorkommen muss
    clear g_700_satzart.
  else.                                                        "SIE005
    /sie/hr_idp_s1dl-referenz = g_ifdata_tran-s1dl-referenz.  "SIE005

  endif.

endform.                    " MODIFY_REFERENCE
*&---------------------------------------------------------------------*
*&      Form  set_reference_icon"SIE002
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_IFDATA_TRAN_S1DL_REFERENZ  text
*      <--P_L_REFERENCE  text
*----------------------------------------------------------------------*
form set_reference_icon using    referenz like /sie/hr_idp_s1dl-referenz
                        changing icon_reference.

  data: icon(4).

  if referenz is initial.
    icon = icon_enter_more.
  else.
    icon = icon_display_more.
  endif.

  call function 'ICON_CREATE'
    exporting
      name       = icon
      text       = 'Referenz'
      info       = 'Schnittstelle referenzieren'
      add_stdinf = 'X'
    importing
      result     = icon_reference
*   EXCEPTIONS
*     ICON_NOT_FOUND              = 1
*     OUTPUTFIELD_TOO_SHORT       = 2
*     OTHERS     = 3
    .
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.


endform.                    " set_reference_icon
*&---------------------------------------------------------------------*
*&      Form  set_field_filter                             "SIE003
*&---------------------------------------------------------------------*
form set_field_filter.

  data: cursor_line type i,
        dummy_c45   type char45,
        description type rsfldesc,
        wa_s1ps     like line of g_ifdata_tran-s1ps,
        trans_mode  type c,
        h_display   type c,

        begin of h_desc,
          length   type ddleng,
          type     type inttype,
          decimals type decimals,
          sign     type signflag,
        end of h_desc,

        h_title like sy-title.

  ranges: sl_sel for dummy_c45.

*  Ausgewähltes Feld ermitteln
  get cursor line cursor_line.

  cursor_line = cursor_line + tc_saf-top_line - 1.
  read table g_itab_s1pg index cursor_line.
  move-corresponding g_itab_s1pg to /sie/hr_idp_felder_tc.

*  Feldinformationen holen

  call function '/SIE/HR_IDP_GET_TYPE'
    exporting
      logical_field  = /sie/hr_idp_felder_tc-feldname
    importing
*     EXTERNAL_TYPE  =
      db_length      = h_desc-length
      internal_type  = h_desc-type
      decimals       = h_desc-decimals
      signflag       = h_desc-sign
    exceptions
      type_undefined = 1
      type_not_found = 2
      others         = 3.

  if sy-subrc <> 0.

    message s170."Fehler beim Ermitteln der Feldinformationen
    exit.

  endif.

*   Daten konvertieren
  move-corresponding h_desc to description.
  description-lower = 'X'.

*   Ausgabelänge selbst errechnen, da nicht vom Fuba geliefert
  perform calc_output_length using    description-type
                                      description-length
                             changing description-olength.

*  Daten aus Filter-Tabelle in Range übernehmen
  refresh sl_sel.
  clear sl_sel.

  loop at g_itab_s1pg-s1ps into wa_s1ps.

    sl_sel-sign   = wa_s1ps-ssign.
    sl_sel-option = wa_s1ps-sopti.
    sl_sel-low    = wa_s1ps-sllow.
    sl_sel-high   = wa_s1ps-shigh.

    append sl_sel.

  endloop.

*  Kennzeichen setzen, ob Filter nur angezeigt werden dürfen
  perform get_transaction_mode changing trans_mode.

  if trans_mode <> 'M' or not g_ifdata_tran-s1dl-referenz is initial.
    h_display = 'X'.
  endif.

*  Titel für Dialog zusammensetzen
  concatenate 'Filter für' /sie/hr_idp_felder_tc-feldname
              into h_title separated by space.

*  Dynamischen Dialog zur Mehrfachselektion aufrufen
*   CALL FUNCTION 'HR_COMPLEX_SELECTIONS'             "HAN002
*  call function '/SIE/HR_I_COMPLEX_SELECTIONS'      "HAN002
*    EXPORTING
*      tclas                   = 'A'
*      infty                   = '0001'
*      fieldname               = 'ZZ_SAPDP_45'
*      fieldkind               = 'AF'
*      window_title            = h_title
*      TEXT                    = ''
*      SIGNED                  = 'X'
*      lower_case              = 'X'
*      NO_INTERVAL_CHECK       = ' '
*      just_display            = h_display
*      JUST_INCL               =
*      EXCLUDED_OPTIONS        =
*      description             = description
*      HELP_FIELD              =
*      SEARCH_HELP             =
*    TABLES
*      range                   = sl_sel
*     EXCEPTIONS
*       action_cancelled        = 1
*       OTHERS                  = 2
*            .

  data: ls_selfield type rstabfield.

  ls_selfield-tablename   = 'P0001'.
  ls_selfield-fieldname = 'JUPER'.

  call function 'COMPLEX_SELECTIONS_DIALOG'
    exporting
      title             = h_title
      text              = ''
      signed            = 'X'
      lower_case        = 'X'
      no_interval_check = ' '
      just_display      = h_display
*     JUST_INCL         = ' '
*     EXCLUDED_OPTIONS  =
      description       = description
*     HELP_FIELD        =
*     SEARCH_HELP       =
      tab_and_field     = ls_selfield
    tables
      range             = sl_sel
    exceptions
      no_range_tab      = 1
      cancelled         = 2
      internal_error    = 3
      invalid_fieldname = 4
      others            = 5.


  if sy-subrc = 0.

*     zuerst Feld aus Filtertabelle rausschmeissen
    refresh g_itab_s1pg-s1ps.
*      PERFORM del_field_filter USING /sie/hr_idp_felder_tc-recna
*                                  /sie/hr_idp_felder_tc-fldps.

*     dann aktuelle Daten aus Range in Filter-Tabelle übernehmen
    clear wa_s1ps.
    move-corresponding /sie/hr_idp_felder_tc to wa_s1ps.

    loop at sl_sel.

      wa_s1ps-seqno = sy-tabix.

      wa_s1ps-ssign = sl_sel-sign.
      wa_s1ps-sopti = sl_sel-option.
      wa_s1ps-sllow = sl_sel-low.
      wa_s1ps-shigh = sl_sel-high.

      append wa_s1ps to g_itab_s1pg-s1ps.

    endloop.

    if h_display is initial.
      if sy-subrc = 0.

        message s171."Filter übernommen

      else.

        message s172."Filter wurde gelöscht

      endif.

*        Änderungen zurückschreiben
      modify g_itab_s1pg index cursor_line.

    endif.
  else.
    if h_display is initial.

      message s173."Filter nicht übernommen

    endif.
  endif.

endform.                    " set_field_filter

*&---------------------------------------------------------------------*
*&      Form  DEL_FIELD_FILTER                             "SIE003
*&---------------------------------------------------------------------*
form del_field_filter using recna type /sie/hr_idp_record_name
                            fldps type /sie/hr_idp_field_pos.

  delete g_ifdata_tran-s1ps where recna = recna
                              and fldps = fldps.

endform. "DEL_FIELD_FILTER
*&---------------------------------------------------------------------*
*&      Form  calc_output_length
*&---------------------------------------------------------------------*
*       Errechnet Ausgabelänge aus internem Datentyp und interner Länge
*----------------------------------------------------------------------*

form calc_output_length using    itype   type c
                                 ilength type i
                        changing olength type i.

  case itype.
    when 'P'.
      olength = ilength * 2 - 1.

    when 'D'.
      olength = '10'.

    when 'T'.
      olength = '8'.

    when others.
      olength = ilength.
  endcase.

endform.                    " calc_output_length
*&---------------------------------------------------------------------*
*&      Form  fill_field_clipboard                         "SIE003
*&---------------------------------------------------------------------*
*       Füllt den Zwischenspeicher mit einer Feldzeile
*----------------------------------------------------------------------*

form fill_field_clipboard.

  g_buffer_s1pg = g_itab_s1pg.

  refresh g_buffer_s1ps.
  loop at g_ifdata_tran-s1ps into g_buffer_s1ps
                         where recna = g_itab_s1pg-recna
                               and fldps = g_itab_s1pg-fldps.
    append g_buffer_s1ps.
  endloop.

endform.                    " fill_field_clipboard
*&---------------------------------------------------------------------*
*&      Form  append_itab_s1pg_from_TC                     "SIE003
*&---------------------------------------------------------------------*
*       Fügt Zeile in g_itab_s1pg aus /sie/hr_idp_felder_tc an
*----------------------------------------------------------------------*
form append_itab_s1pg_from_tc.

  refresh g_itab_s1pg-s1ps.
  move-corresponding /sie/hr_idp_felder_tc
                     to g_itab_s1pg.
  append g_itab_s1pg.

endform.                    " append_itab_s1pg_from_TC
*&---------------------------------------------------------------------*
*&      Form  insert_itab_s1pg_from_TC                     "SIE003
*&---------------------------------------------------------------------*
*       Fügt Zeile in g_itab_s1pg aus /sie/hr_idp_felder_tc ein
*----------------------------------------------------------------------*
form insert_itab_s1pg_from_tc using idx like sy-index.

  refresh g_itab_s1pg-s1ps.
  move-corresponding /sie/hr_idp_felder_tc
                     to g_itab_s1pg.
  insert g_itab_s1pg index idx.

endform.                    " insert_itab_s1pg_from_TC
