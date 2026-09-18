*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_FELDER_F01                                     *
*----------------------------------------------------------------------*

*sie001 Darstellung der Länge bei gebildeten Begriffen wurde korrigiert
*sie001 bei gebildeten Feldern wurde bisher die interne Länge (= Länge
*sie001 in Bytes) dargestellt; dies wurde nun geändert und bei den
*sie001 gebildeten Begriffen wird jetzt die Länge in Stellen angezeit
*sie001 17.06.2004, Hn
*sie002 23.03.2023 COL-22048 - C2C - Bearb. ATC-Check-Findings


TABLES: /sie/hr_fuba_kat.                                   "sie001

*&---------------------------------------------------------------------*
*&      Form  SEARCH_INFTY
*&---------------------------------------------------------------------*
*       Suche in den Tabellen nach Infotyp Felder
*----------------------------------------------------------------------*
FORM search_infty.

  DATA: wa_data TYPE /sie/hr_idp_fieldsearch
      , h_data TYPE STANDARD TABLE OF /sie/hr_idp_fieldsearch
        INITIAL SIZE 0
        .

* Zunächst werden alle angegebenen Felder eingelesen.

  SELECT DISTINCT a~feldname dpftype infty inftyfeld ident
           UP TO loopc ROWS
           INTO (/sie/hr_idp_f1-feldname,
                 /sie/hr_idp_f1-dpftype,
                 /sie/hr_idp_f1-infty,
                 /sie/hr_idp_f1-inftyfeld,
                 /sie/hr_idp_f1t-ident)
           FROM /sie/hr_idp_f1 AS a
           LEFT JOIN /sie/hr_idp_f1t AS b
           ON a~feldname = b~feldname
           WHERE a~feldname IN p_key1
           AND  dpftype = '1'
           AND   cr_uname IN p_crnam
           AND   datum IN    p_datum
           AND   uname IN    p_uname
           AND   infty IN    p_infot
           AND   subty IN   p_subty
           AND inftyfeld IN p_ifeld
           AND konvname IN p_kvname
      ORDER BY a~feldname dpftype infty inftyfeld ident. "sie002

    CHECK: NOT ( /sie/hr_idp_f1-infty IS INITIAL ) .

    MOVE-CORRESPONDING /sie/hr_idp_f1 TO wa_data.
    MOVE /sie/hr_idp_f1t-ident TO wa_data-ident.
    CLEAR /sie/hr_idp_f1t.
    APPEND wa_data TO g_infty.
  ENDSELECT.

* Nun wird geschaut, ob die Texte auch stimmen.
  CLEAR h_data[].
  LOOP AT g_infty INTO wa_data
                  WHERE ident IN p_xtext.
    APPEND wa_data TO h_data.
  ENDLOOP.

  CLEAR g_infty. g_infty[] = h_data[].

ENDFORM.                    " SEARCH_INFTY

*&---------------------------------------------------------------------*
*&      Form  SEARCH_KTO
*&---------------------------------------------------------------------*
*       Suche in den Tabellen nach Lohnkontofelder
*----------------------------------------------------------------------*
FORM search_kto.

  DATA: wa_data TYPE /sie/hr_idp_fieldsearch
      , h_data TYPE STANDARD TABLE OF /sie/hr_idp_fieldsearch
        INITIAL SIZE 0
        .

* Zunächst werden alle angegebenen Felder eingelesen.

  SELECT DISTINCT a~feldname dpftype infty inftyfeld ident
           UP TO loopc ROWS
           INTO (/sie/hr_idp_f1-feldname,
                 /sie/hr_idp_f1-dpftype,
                 /sie/hr_idp_f1-infty,
                 /sie/hr_idp_f1-inftyfeld,
                 /sie/hr_idp_f1t-ident)
           FROM /sie/hr_idp_f1 AS a
           LEFT JOIN /sie/hr_idp_f1t AS b
           ON a~feldname = b~feldname
           WHERE a~feldname IN p_key1
           AND  dpftype = '3'
           AND   cr_uname IN p_crnam
           AND   datum IN    p_datum
           AND   uname IN    p_uname
           AND   acltab IN   p_acltab
           AND   aclfeld IN   p_aclfld
           AND konvname IN p_kvname
    ORDER BY a~feldname dpftype infty inftyfeld ident.

    MOVE-CORRESPONDING /sie/hr_idp_f1 TO wa_data.
    MOVE /sie/hr_idp_f1t-ident TO wa_data-ident.
    CLEAR /sie/hr_idp_f1t.
    APPEND wa_data TO g_kto.
  ENDSELECT.

* Nun wird geschaut, ob die Texte auch stimmen.
  CLEAR h_data[].
  LOOP AT g_kto INTO wa_data
                  WHERE ident IN p_xtext.
    APPEND wa_data TO h_data.
  ENDLOOP.

  CLEAR g_kto. g_kto[] = h_data[].

ENDFORM.                    " SEARCH_INFTY

*&---------------------------------------------------------------------*
*&      Form  SEARCH_LGART
*&---------------------------------------------------------------------*
*       Suche nach Lohnarten Texten
*----------------------------------------------------------------------*
FORM search_lgart.

  DATA: wa_data TYPE /sie/hr_idp_fieldsearch
      , h_data TYPE STANDARD TABLE OF /sie/hr_idp_fieldsearch
        INITIAL SIZE 0
      .

* Zunächst werden alle angegeben Felder eingelesen.
  SELECT DISTINCT a~feldname dpftype acltab aclfeld rtlgart rtkz ident
           UP TO loopc ROWS
           INTO (/sie/hr_idp_f1-feldname,
                 /sie/hr_idp_f1-dpftype,
                 /sie/hr_idp_f1-acltab,
                 /sie/hr_idp_f1-aclfeld,
                 /sie/hr_idp_f1-rtlgart,
                 /sie/hr_idp_f1-rtkz,
                 /sie/hr_idp_f1t-ident)
           FROM /sie/hr_idp_f1 AS a
           LEFT JOIN /sie/hr_idp_f1t AS b
           ON a~feldname = b~feldname
           WHERE a~feldname IN p_key1
          AND  dpftype = '4'
          AND   cr_uname IN p_crnam
          AND   datum IN    p_datum
          AND   uname IN    p_uname
          AND   acltab IN    p_acltab
          AND   aclfeld IN   p_aclfld
          AND rtlgart IN p_rtlgrt
          AND rtkz IN p_rtkz
          AND konvname IN p_kvname
    ORDER BY a~feldname dpftype acltab aclfeld rtlgart rtkz ident.

    CHECK: NOT ( /sie/hr_idp_f1-rtlgart IS INITIAL ) .

    MOVE-CORRESPONDING /sie/hr_idp_f1 TO wa_data.
    MOVE /sie/hr_idp_f1t-ident TO wa_data-ident.
    CLEAR /sie/hr_idp_f1t.
    APPEND wa_data TO g_lgart.
  ENDSELECT.

* Nun wird geschaut, ob die Texte auch stimmen.
  CLEAR h_data[].
  LOOP AT g_lgart INTO wa_data
                  WHERE ident IN p_xtext.
    APPEND wa_data TO h_data.
  ENDLOOP.

  CLEAR g_lgart. g_lgart[] = h_data[].

ENDFORM.                    " SEARCH_LGART

*&---------------------------------------------------------------------*
*&      Form  SEARCH_BEGRIFFE
*&---------------------------------------------------------------------*
*       Suche nach Gebildeten Begriffe
*----------------------------------------------------------------------*
FORM search_begriffe.

  DATA: wa_data TYPE /sie/hr_idp_fieldsearch
      , h_data TYPE STANDARD TABLE OF /sie/hr_idp_fieldsearch
        INITIAL SIZE 0
        .

  SELECT DISTINCT a~feldname dpftype ident
           UP TO loopc ROWS
           INTO (/sie/hr_idp_f1-feldname,
                 /sie/hr_idp_f1-dpftype,
                 /sie/hr_idp_f1t-ident)
           FROM /sie/hr_idp_f1 AS a
           LEFT JOIN /sie/hr_idp_f1t AS b
           ON a~feldname = b~feldname
           WHERE a~feldname IN p_key1
           AND  dpftype = '2'
           AND   cr_uname IN p_crnam
           AND   datum IN    p_datum
           AND   uname IN    p_uname
    ORDER BY a~feldname dpftype ident.

    MOVE-CORRESPONDING /sie/hr_idp_f1 TO wa_data.
    MOVE /sie/hr_idp_f1t-ident TO wa_data-ident.
    CLEAR /sie/hr_idp_f1t.
    APPEND wa_data TO g_gebil.
  ENDSELECT.

* nun wird geschaut, ob die texte auch stimmen.
  CLEAR h_data[].
  LOOP AT g_gebil INTO wa_data
                  WHERE ident IN p_xtext.
    APPEND wa_data TO h_data.
  ENDLOOP.

  CLEAR g_gebil. g_gebil[] = h_data[].

ENDFORM.                    " SEARCH_BEGRIFFE

*&---------------------------------------------------------------------*
*&      Form  ADDITIONAL_SEARCH
*&---------------------------------------------------------------------*
*       Es werden zusätzliche Daten wie Feldlänge und Typ geprüft
*----------------------------------------------------------------------*
FORM additional_search.
  DATA: wa_data TYPE /sie/hr_idp_fieldsearch
      , l_infty_name(6) TYPE c VALUE 'Pxxxx'
      , l_data TYPE STANDARD TABLE OF  /sie/hr_idp_fieldsearch
               INITIAL SIZE 0
      , l_length TYPE ddleng
      , l_dtype TYPE dynptype
      , l_itype TYPE inttype
      , l_decimals TYPE decimals
      , l_signflag TYPE signflag
      .

  DATA:   l_begriff TYPE /sie/hr_idp_f1-begriff.            "sie001

  RANGES: lr_felder FOR /sie/hr_idp_f1-feldname.

  CLEAR l_data[].
  LOOP AT g_data INTO wa_data.

* Haben wir es mit Infotyp Felder zu tun, dann die Namen aufbauen
    IF ( wa_data-dpftype = '1' ).
      WRITE wa_data-infty TO l_infty_name+1(4).

* Sonderfall Feld PERNR im Infotyp 0001 (wurde von uns so definiert).
      IF wa_data-inftyfeld = 'PERNR' AND l_infty_name = 'PS0001'.
        PERFORM get_ddic USING 'PA0003'
                               wa_data-inftyfeld
                         CHANGING wa_data-datatype
                                  wa_data-leng
                                  wa_data-decimals
                                  wa_data-signflag.
      ELSE.
        PERFORM get_ddic USING l_infty_name
                               wa_data-inftyfeld
                         CHANGING wa_data-datatype
                                  wa_data-leng
                                  wa_data-decimals
                                  wa_data-signflag.
      ENDIF.
    ENDIF.

* Lohnartenbehandlung
    IF ( wa_data-dpftype = '4' ).
      wa_data-leng = 15.   " Ist bei allen drei 15.
      wa_data-decimals = 2.   " Ist bei allen drei 2.
      wa_data-signflag = 'X'.   " Vorzeichen ist immer gegeben
      CASE wa_data-rtkz.
        WHEN 'A'.
          wa_data-datatype = 'CURR'.
        WHEN 'N'.
          wa_data-datatype = 'DEC'.
        WHEN 'R'.
          wa_data-datatype = 'CURR'.
        WHEN OTHERS.
* Sollte es nicht geben.
      ENDCASE.
    ENDIF.

* Gebildete Begriffe und Lohnkonto
    IF ( wa_data-dpftype = '2' ) OR ( wa_data-dpftype = '3' ).
      CALL FUNCTION '/SIE/HR_IDP_GET_TYPE'
           EXPORTING
                logical_field  = wa_data-feldname
           IMPORTING
                external_type  = l_dtype
                length      = l_length  "aha003 wg unicode
                internal_type  = l_itype
                decimals       = l_decimals
                signflag       = l_signflag
           EXCEPTIONS
                type_undefined = 1
                type_not_found = 2
                OTHERS         = 3.
      IF sy-subrc <> 0.
        CLEAR: wa_data-datatype, wa_data-leng.
      ELSE.
        wa_data-datatype = l_dtype.
        wa_data-leng = l_length.
        wa_data-decimals = l_decimals.
        wa_data-signflag = l_signflag.
      ENDIF.

*sie001 da oben die interne Länge statt die Länge in Stellen im Feld
*sie001 wa_data-leng abgelegt wird, wird hier nochmal korrigiert, um
*sie001 die Länge in Stellen ausgeben zu können
      SELECT SINGLE * FROM /sie/hr_idp_f1                   "sie001
                      WHERE feldname = wa_data-feldname.    "sie001

      l_begriff = /sie/hr_idp_f1-begriff.                   "sie001

      PERFORM find_gbegriff_type_neu                        "sie001
              USING l_begriff                               "sie001
              CHANGING l_dtype                              "sie001
                       l_length                             "sie001
                       l_itype                              "sie001
                       l_decimals                           "sie001
                       l_signflag.                          "sie001

      wa_data-leng = l_length.                              "sie001

    ENDIF.

* Prüfen ob die Typenangabe und Länge stimmen.
    IF ( wa_data-datatype IN p_type ).
      IF ( wa_data-leng IN p_len ).
        APPEND wa_data TO l_data.
      ENDIF.
    ENDIF.

  ENDLOOP.
  CLEAR g_data[]. g_data[] = l_data[]. CLEAR l_data[].

* Langtextsuche.
  CLEAR lr_felder[].
  LOOP AT g_data INTO wa_data.
    lr_felder-sign = 'I'.
    lr_felder-option = 'EQ'.
    lr_felder-low = wa_data-feldname.
    APPEND lr_felder.
  ENDLOOP.

  CLEAR wa_data.
  SELECT * FROM /sie/hr_idp_f1lt WHERE tline IN p_text.
*                                 and tline in p_text.
    wa_data-feldname = /sie/hr_idp_f1lt-feldname.
    APPEND wa_data TO l_data.
  ENDSELECT.

* Nun werden die gefundenen Texte und felder abgemischt.
  DELETE ADJACENT DUPLICATES FROM l_data.

  LOOP AT g_data INTO wa_data.
    READ TABLE l_data WITH KEY feldname = wa_data-feldname
                      TRANSPORTING NO FIELDS.
    IF sy-subrc >< 0.
* Vor dem Löschen sollte aber noch geprüft werden, ob das Feld
* überhaupt Dokumentation besitzt. Ansonsten wird es gelöscht.
SELECT SINGLE * FROM /sie/hr_idp_f1lt WHERE feldname = wa_data-feldname.
      IF sy-subrc >< 0.
* Feld existiert nicht in der Datenbank. Das Feld behalten.
      ELSE.
        DELETE g_data.
      ENDIF.
    ELSE.
* Alles in Ordnung. Das Feld behalten.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " ADDITIONAL_SEARCH

*&---------------------------------------------------------------------*
*&      Form  GET_DDIC
*&---------------------------------------------------------------------*
*       Holt aus dem DDIC die Informationen zu einem Feld wie typ
*       und Länge
*----------------------------------------------------------------------*
*      -->P_L_INFTY_NAME  text
*      -->P_WA_DATA_INFTYFELD  text
*----------------------------------------------------------------------*
FORM get_ddic USING    p_name
                       p_feld
              CHANGING p_type
                       p_length
                       p_decimals TYPE decimals
                       p_signflag TYPE signflag.

  DATA: l_dfies TYPE dfies
      , l_fieldname TYPE  dfies-lfieldname
      , l_tabname TYPE dcobjdef-name
      .

  l_tabname = p_name.
  l_fieldname = p_feld.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
       EXPORTING
            tabname        = l_tabname
            langu          = sy-langu
            lfieldname     = l_fieldname
       IMPORTING
            dfies_wa       = l_dfies
       EXCEPTIONS
            not_found      = 1
            internal_error = 2
            OTHERS         = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    p_type = l_dfies-datatype.
    p_length = l_dfies-leng.
    p_decimals = l_dfies-decimals.
    p_signflag = l_dfies-sign.
  ENDIF.


ENDFORM.                    " GET_DDIC

*&---------------------------------------------------------------------*
*&      Form  CONSOLIDATE_DATA
*&---------------------------------------------------------------------*
*       Diese Form routine konsolidiert die Daten in eine einzige
*       Tabelle und löscht alle Einträge die über loopc sind.
*----------------------------------------------------------------------*
FORM consolidate_data.

  DATA: wa_data TYPE /sie/hr_idp_fieldsearch.

  APPEND LINES OF g_infty TO g_data.
  APPEND LINES OF g_lgart TO g_data.
  APPEND LINES OF g_gebil TO g_data.
  APPEND LINES OF g_kto TO g_data.

  LOOP AT g_data INTO wa_data.
    IF sy-tabix > loopc. DELETE g_data. ENDIF.
  ENDLOOP.

* brauchen wir diese zeile??
*  delete adjacent duplicates from g_data.

  SORT g_data BY feldname.

ENDFORM.                    " CONSOLIDATE_DATA


*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       Anzeigen der gefunden Informationen
*----------------------------------------------------------------------*
FORM display_data.

  PERFORM variant_init.
  PERFORM fill_layout CHANGING gs_layout.
  PERFORM fill_fieldcat CHANGING gt_fieldcat.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
       EXPORTING
            i_callback_program       = g_repid
            i_callback_pf_status_set = 'CALLBACK_PF_STATUS_SET'
            i_callback_user_command  = 'CALLBACK_USER_COMMAND'
*            i_structure_name         = '/SIE/HR_IDP_FIELDSEARCH'
            is_layout                = gs_layout
            it_fieldcat              = gt_fieldcat
       TABLES
            t_outtab                 = g_data
       EXCEPTIONS
            program_error            = 1
            OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " DISPLAY_DATA

*---------------------------------------------------------------------*
*       FORM CALLBACK_PF_STATUS_SET                                   *
*---------------------------------------------------------------------*
*       Setzt den PF Status bzw. erlaubt das löschen von FCodes       *
*---------------------------------------------------------------------*
FORM callback_pf_status_set USING extab TYPE slis_t_extab.

  DATA: h_value(5) TYPE c.
  DESCRIBE TABLE g_data.
  WRITE sy-tfill TO h_value NO-ZERO LEFT-JUSTIFIED.

  SET PF-STATUS 'MAIN' EXCLUDING extab.
  SET TITLEBAR 'MAIN' WITH h_value.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM CALLBACK_USER_COMMAND                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM callback_user_command USING r_ucomm LIKE sy-ucomm
                           rs_selfield TYPE slis_selfield.

  DATA: l_data TYPE /sie/hr_idp_fieldsearch.

  CASE r_ucomm.
    WHEN '%IC1'.
      READ TABLE g_data INTO l_data INDEX rs_selfield-tabindex.
      CALL FUNCTION '/SIE/HR_IDP_F1LT_SHOW'
           EXPORTING
                feldname = l_data-feldname.
      CLEAR r_ucomm.
    WHEN 'AUFF'.
      CLEAR g_data.
      PERFORM search_data.
      rs_selfield-refresh = yes.
      rs_selfield-row_stable = 'X'.
      CLEAR r_ucomm.
    WHEN 'NEW'.
      SUBMIT /sie/hr_idp_felder AND RETURN VIA SELECTION-SCREEN.
      CLEAR r_ucomm.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  VARIANT_INIT
*&---------------------------------------------------------------------*
*       Die Anzeigevariante wird gesetzt
*----------------------------------------------------------------------*
FORM variant_init.
  CLEAR g_variant.
  g_variant-report = g_repid.
ENDFORM.                    " VARIANT_INIT


*&---------------------------------------------------------------------*
*&      Form  FILL_LAYOUT
*&---------------------------------------------------------------------*
*       Füllt die Layout Feldleiste
*----------------------------------------------------------------------*
*      <--P_GS_LAYOUT  Layout
*----------------------------------------------------------------------*
FORM fill_layout CHANGING p_gs_layout TYPE slis_layout_alv.

  p_gs_layout-zebra = yes.
  p_gs_layout-colwidth_optimize = yes.
* p_gs_layout-box_fieldname = 'MARK'.

ENDFORM.                    " FILL_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  FILL_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM fill_fieldcat CHANGING p_gt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

  CLEAR p_gt_fieldcat[].

  ls_fieldcat-tabname       = g_tabname.
  ls_fieldcat-fieldname     = 'FELDNAME'.
  ls_fieldcat-key           = 'X'.        "sets key field
  APPEND ls_fieldcat TO p_gt_fieldcat.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
       EXPORTING
            i_program_name         = g_repid
            i_internal_tabname     = g_tabname
            i_structure_name       = '/SIE/HR_IDP_FIELDSEARCH'
            i_client_never_display = 'X'
       CHANGING
            ct_fieldcat            = p_gt_fieldcat
       EXCEPTIONS
            inconsistent_interface = 1
            program_error          = 2
            OTHERS                 = 3.

  DELETE p_gt_fieldcat WHERE fieldname = 'DPFTYPE'.
  DELETE p_gt_fieldcat WHERE fieldname = 'INFTY'.
  DELETE p_gt_fieldcat WHERE fieldname = 'INFTYFELD'.
  DELETE p_gt_fieldcat WHERE fieldname = 'ACLTAB'.
  DELETE p_gt_fieldcat WHERE fieldname = 'ACLFELD'.
  DELETE p_gt_fieldcat WHERE fieldname = 'RTLGART'.
  DELETE p_gt_fieldcat WHERE fieldname = 'RTKZ'.

ENDFORM.                    " FILL_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  SEARCH_DATA
*&---------------------------------------------------------------------*
*       Diese Form routine bildet das Herzstück des Programmes. Es
*       sucht einfach die DB nach den Begriffen und liefert diese
*       in der Tabelle g_data.
*----------------------------------------------------------------------*
FORM search_data.

  CLEAR: g_data[], g_infty[], g_lgart, g_gebil[], g_kto[].

* Nach den Infotyp-Felder suchen
  IF NOT ( p_infty IS INITIAL ).
    PERFORM search_infty.
  ENDIF.

* Nach den Lohnarten-Felder suchen
  IF NOT ( p_lgart IS INITIAL ).
    PERFORM search_lgart.
  ENDIF.

* Nach den Gebildeten Begriffen suchen
  IF NOT ( p_gebil IS INITIAL ).
    PERFORM search_begriffe.
  ENDIF.

* Nach den Gebildeten Begriffen suchen
  IF NOT ( p_kto IS INITIAL ).
    PERFORM search_kto.
  ENDIF.

* Nun werden die zusätzlichen Optionen geprüft.
* Aber zuerst werden die Daten Konsolidiert.
  PERFORM consolidate_data.

  PERFORM additional_search.

ENDFORM.                    " SEARCH_DATA


*&---------------------------------------------------------------------*
*&      Form  FIND_GBEGRIFF_TYPE_NEU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_/SIE/HR_IDP_F1_BEGRIFF  text
*      <--P_P_FIELD  text
*----------------------------------------------------------------------*
*wurde kopiert aus Include find_gbegriff_type

FORM find_gbegriff_type_neu USING l_begriff LIKE /sie/hr_idp_f1-begriff
                            CHANGING l_dtype
                                     l_length
                                     l_itype
                                     l_decimals
                                     l_signflag.       "Beginn sie001

  DATA: funcname LIKE rs38l-name
      , itab_rsexp TYPE STANDARD TABLE OF rsexp   INITIAL SIZE 0 WITH
        HEADER LINE
      , dtel LIKE dcobjdef-name
      , dtel_l(40) TYPE c
      , dfies_wa LIKE dfies
      , itab_rsexc TYPE STANDARD TABLE OF rsexc INITIAL SIZE 0 WITH
        HEADER LINE
      , itab_rsimp TYPE STANDARD TABLE OF rsimp INITIAL SIZE 0 WITH
        HEADER LINE
      , itab_rstbl TYPE STANDARD TABLE OF rstbl INITIAL SIZE 0 WITH
        HEADER LINE
      , l_table  LIKE dcobjdef-name
      , l_field  LIKE dcobjdef-name
      , l_t_dfies TYPE STANDARD TABLE OF dfies INITIAL SIZE 0 WITH
        HEADER LINE.

  SELECT SINGLE * FROM /sie/hr_fuba_kat
                  WHERE begriff = l_begriff.

  IF sy-subrc = 0.
    funcname = /sie/hr_fuba_kat-fuba.
    CALL FUNCTION 'FUNCTION_IMPORT_INTERFACE'
         EXPORTING
              funcname           = funcname
         TABLES
              exception_list     = itab_rsexc
              import_parameter   = itab_rsimp
              export_parameter   = itab_rsexp
              tables_parameter   = itab_rstbl
         EXCEPTIONS
              error_message      = 1
              function_not_found = 2
              invalid_name       = 3
              OTHERS             = 4.
    IF sy-subrc <> 0.
      l_dtype = space.
    ELSE.
      LOOP AT itab_rsexp WHERE parameter = /sie/hr_fuba_kat-exparam.
        dtel = itab_rsexp-typ.
        dtel_l = itab_rsexp-typ.

* Check if this is a dataelement or a table?
        CASE dtel.
          WHEN 'P'. l_dtype = 'P'. l_length = 8.  l_itype = 'DEC'.
          WHEN 'I'. l_dtype = 'I'. l_length = 10. l_itype = 'INT4'. "?
          WHEN 'C'. l_dtype = 'C'. l_length = 1.  l_itype = 'CHAR'.
          WHEN 'N'. l_dtype = 'N'. l_length = 1.  l_itype = 'NUMC'.
          WHEN 'D'. l_dtype = 'D'. l_length = 8.  l_itype = 'DATS'.
          WHEN 'T'. l_dtype = 'T'. l_length = 6.  l_itype = 'TIMS'.
          WHEN OTHERS.
            IF dtel CA '-'.                                 "#EC NOTEXT
              CLEAR: l_table, l_field.
              SPLIT dtel_l AT '-' INTO l_table l_field.
              CALL FUNCTION 'DDIF_FIELDINFO_GET'
                   EXPORTING
                        tabname        = l_table
                        fieldname      = l_field
                        all_types      = 'X'
                   TABLES
                        dfies_tab      = l_t_dfies
                   EXCEPTIONS
                        not_found      = 1
                        internal_error = 2
                        OTHERS         = 3.
              IF sy-subrc <> 0.
                l_dtype = space.
              ELSE.
                READ TABLE l_t_dfies INDEX 1.
                l_dtype = l_t_dfies-inttype.
                l_length = l_t_dfies-leng.
                l_itype = l_t_dfies-datatype.
                l_decimals = l_t_dfies-decimals.
                l_signflag = l_t_dfies-sign.
                EXIT.
              ENDIF.
            ELSE.
              CALL FUNCTION 'DDIF_FIELDINFO_GET'
                   EXPORTING
                        tabname        = dtel
                        all_types      = 'X'
                   IMPORTING
                        dfies_wa       = dfies_wa
                   EXCEPTIONS
                        not_found      = 1
                        internal_error = 2
                        OTHERS         = 3.
              IF sy-subrc <> 0.
                l_dtype = space.
              ELSE.
                l_dtype = dfies_wa-inttype.
                l_length = dfies_wa-leng.
                l_itype = dfies_wa-datatype.
                l_decimals = dfies_wa-decimals.
                l_signflag = dfies_wa-sign.
                EXIT.
              ENDIF.
            ENDIF.
        ENDCASE.
      ENDLOOP.
      IF sy-subrc <> 0.
        l_dtype = space.
      ENDIF.
    ENDIF.
  ELSE.
    l_dtype = space.
  ENDIF.

ENDFORM.                    " FIND_GBEGRIFF_TYPE_NEU        "Ende sie001
