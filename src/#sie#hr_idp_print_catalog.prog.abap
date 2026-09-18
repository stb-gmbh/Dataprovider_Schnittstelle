*&---------------------------------------------------------------------*
*& Report  /SIE/HR_IDP_PRINT_FELDKATALOG                               *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Feldkatalog drucken                                                 *
*&                                                                     *
*&---------------------------------------------------------------------*
************************************************************************
* Änderungen:
*           MCH0800 20070613 Grund SLF 900035548 Selektion nach
*                            Feldkataloggruppe ist auskommentiert.
************************************************************************
REPORT  /sie/hr_idp_print_catalog MESSAGE-ID /sie/hr_idp_messages
  NO STANDARD PAGE HEADING LINE-SIZE 80
                           LINE-COUNT 65.

TABLES: /sie/hr_idp_f0
      , /sie/hr_idp_f0t
      , /sie/hr_idp_f1
      , /sie/hr_idp_f1t
      , t512t
      .

DATA  zeile1(100).
DATA  zeile2(100).
DATA  header(10).
DATA  zae TYPE i VALUE 1.
DATA  save_grkey LIKE /sie/hr_idp_f0-grkey.
DATA  begriff(60).

* Tabelle der Feldkataloggruppen
DATA: BEGIN OF kaptl OCCURS 0
    ,   grkey LIKE /sie/hr_idp_f0-grkey
    , END OF kaptl
    .

* Feldkataloggruppen
DATA: BEGIN OF g_f0 OCCURS 0
    ,   grtyp    LIKE /sie/hr_idp_f0-grtyp
    ,   grkey    LIKE /sie/hr_idp_f0-grkey
    ,   parent   LIKE /sie/hr_idp_f0-parent
    ,   sortn    LIKE /sie/hr_idp_f0-sortn
    ,   ebene(2) TYPE n
    ,   ident    LIKE /sie/hr_idp_f1t-ident
    , END OF g_f0
    .

DATA: g_hf0 LIKE g_f0 OCCURS 0 WITH HEADER LINE
    , g_f1lt LIKE /sie/hr_idp_f1lt OCCURS 0 WITH HEADER LINE
    , i512t LIKE t512t OCCURS 0 WITH HEADER LINE
    , grup LIKE g_f0 OCCURS 0 WITH HEADER LINE
    .

* Selektionsfelder
DATA: BEGIN OF g_f1s OCCURS 0
    ,  feldname LIKE /sie/hr_idp_f1s-feldname
    , END OF g_f1s
    .

* Nutzfelder
DATA: BEGIN OF g_fields OCCURS 0
    ,   feldname  LIKE /sie/hr_idp_f1-feldname
    ,   grkey     LIKE /sie/hr_idp_f1-grkey
    ,   sortn     LIKE /sie/hr_idp_f1-sortn
    ,   dpftype   LIKE /sie/hr_idp_f1-dpftype
    ,   infty     LIKE /sie/hr_idp_f1-infty
    ,   subty     LIKE /sie/hr_idp_f1-subty
    ,   inftyfeld LIKE /sie/hr_idp_f1-inftyfeld
    ,   begriff   LIKE /sie/hr_idp_f1-begriff
    ,   acltab    LIKE /sie/hr_idp_f1-acltab
    ,   aclfeld   LIKE /sie/hr_idp_f1-aclfeld
    ,   rtlgart   LIKE /sie/hr_idp_f1-rtlgart
    ,   rtkz      LIKE /sie/hr_idp_f1-rtkz
    ,   konvstrg  LIKE /sie/hr_idp_f1-konvstrg
    ,   konvname  LIKE /sie/hr_idp_f1-konvname
    ,   ident     LIKE /sie/hr_idp_f1t-ident
    ,   selfd     TYPE xflag
    ,   type      TYPE dynptype
    ,   leng      TYPE ddleng
    , END OF g_fields
    .

DATA: sel_fields TYPE STANDARD TABLE OF /sie/hr_idp_f4_sel_fields
      INITIAL SIZE 0 WITH HEADER LINE.

** Selektion nach Feldkataloggruppe                           "HAN001
*SELECTION-SCREEN BEGIN OF BLOCK sel1 WITH FRAME TITLE text-s00."HAN001
*SELECTION-SCREEN BEGIN OF LINE.                             "HAN001
*PARAMETERS p_struc AS CHECKBOX DEFAULT 'X'.                 "HAN001
PARAMETERS p_struc  NO-DISPLAY .                            "HAN001
*SELECTION-SCREEN COMMENT 4(20) text-r05 FOR FIELD p_struc.  "HAN001
*SELECTION-SCREEN END OF LINE.                               "HAN001
*SELECT-OPTIONS s_grkey FOR /sie/hr_idp_f0-grkey.            "HAN001
SELECT-OPTIONS s_grkey FOR /sie/hr_idp_f0-grkey NO-DISPLAY. "HAN001
*PARAMETERS p_ukaptl TYPE /sie/hr_idp_repa-ext_grkey DEFAULT 'X'."HAN001
PARAMETERS p_ukaptl TYPE /sie/hr_idp_repa-ext_grkey NO-DISPLAY."HAN001
*SELECTION-SCREEN END OF BLOCK sel1.                         "HAN001

* Selektion nach Feldtyp
SELECTION-SCREEN BEGIN OF BLOCK sel2 WITH FRAME TITLE text-s01.
* Infotypen
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_infty AS CHECKBOX.
SELECTION-SCREEN COMMENT 4(10) text-r01 FOR FIELD p_infty.
SELECTION-SCREEN END OF LINE.
SELECT-OPTIONS s_infot FOR /sie/hr_idp_f1-infty.
SELECT-OPTIONS s_subty FOR /sie/hr_idp_f1-subty.
* Gebildete Begriffe
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_gebil AS CHECKBOX.
SELECTION-SCREEN COMMENT 4(20) text-r03 FOR FIELD p_gebil.
SELECTION-SCREEN END OF LINE.
* Feld aus Abrechnungsclustertabelle
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_kto AS CHECKBOX.
SELECTION-SCREEN COMMENT 4(10) text-r04 FOR FIELD p_kto.
SELECTION-SCREEN END OF LINE.
SELECT-OPTIONS s_acltab FOR /sie/hr_idp_f1-acltab.
SELECT-OPTIONS s_aclfld FOR /sie/hr_idp_f1-aclfeld NO-DISPLAY.
* Lohnart aus der RT im Abrechnungscluster
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_lgart AS CHECKBOX.
SELECTION-SCREEN COMMENT 4(10) text-r02 FOR FIELD p_lgart.
SELECTION-SCREEN END OF LINE.
SELECT-OPTIONS s_rtlgrt FOR /sie/hr_idp_f1-rtlgart.
SELECTION-SCREEN END OF BLOCK sel2.

SELECTION-SCREEN BEGIN OF BLOCK ausgabe WITH FRAME TITLE text-a01.
SELECTION-SCREEN BEGIN OF BLOCK frm2 WITH FRAME TITLE text-a02.
PARAMETERS: p_sliste RADIOBUTTON GROUP self DEFAULT 'X'
          , p_ssep RADIOBUTTON GROUP self
          .
SELECTION-SCREEN END OF BLOCK frm2.
SELECTION-SCREEN BEGIN OF BLOCK frm3 WITH FRAME TITLE text-a03.
PARAMETERS: p_lno RADIOBUTTON GROUP ltxt
          , p_lliste RADIOBUTTON GROUP ltxt
          , p_lanh RADIOBUTTON GROUP ltxt DEFAULT 'X'
          .
SELECTION-SCREEN END OF BLOCK frm3.
SELECTION-SCREEN END OF BLOCK ausgabe.

RANGES s_ext_grkey FOR /sie/hr_idp_f1-grkey.

AT SELECTION-SCREEN.
* Plausibilität überprüfen
  IF p_infty IS INITIAL AND p_gebil IS INITIAL AND p_lgart IS
    INITIAL AND p_kto IS INITIAL.
    MESSAGE e241.
  ENDIF.
  IF p_struc EQ 'X' AND ( p_infty EQ 'X' OR p_gebil EQ 'X'
    OR p_lgart EQ 'X' OR p_kto EQ 'X' ).
    MESSAGE e222.
* Bitte für Kapitel- oder Feldtyp-Selektion entscheiden.
  ENDIF.

START-OF-SELECTION.

* Bei Feldtyp-Selektion muss P_UKAPTL initial sein
  IF ( NOT p_infty IS INITIAL OR NOT p_gebil IS INITIAL OR NOT p_lgart
    IS INITIAL OR NOT p_kto IS INITIAL ) AND p_ukaptl EQ 'X'.
    p_ukaptl = space.
  ENDIF.

  IF p_struc EQ 'X' AND s_grkey[] IS INITIAL AND p_ukaptl EQ space.
    p_ukaptl = 'X'.
  ENDIF.

  PERFORM select_feldgruppierung TABLES g_hf0.

* Untergruppen auslösen und Select Option aufblasen
  IF p_struc EQ 'X' AND p_ukaptl EQ 'X'.
    PERFORM fill_table_kaptl TABLES kaptl.
    PERFORM blow_up_select_option TABLES kaptl.
  ENDIF.

  PERFORM select_selektionsfelder TABLES g_f1s.
  PERFORM select_lohnarten_texte TABLES i512t.

* Bei Selektion nach Feldtyp darf die Select Option der Feldgruppen
* nicht gefüllt sein
  IF  p_infty EQ 'X' OR p_gebil EQ 'X' OR p_lgart EQ 'X'
    OR p_kto EQ 'X'.
    REFRESH s_grkey.
  ENDIF.

* Selektion nach Feldkataloggruppe
  IF p_struc EQ 'X'.
    IF p_ukaptl EQ 'X'.
      PERFORM select_struc TABLES s_ext_grkey.
    ELSE.
      PERFORM select_struc TABLES s_grkey.
    ENDIF.
  ENDIF.

* Selektion nach Feldtyp
  IF p_infty EQ 'X'.
    PERFORM select_infty.
  ENDIF.
  IF p_lgart EQ 'X'.
    PERFORM select_lgart.
  ENDIF.
  IF p_gebil EQ 'X'.
    PERFORM select_gebil.
  ENDIF.
  IF p_kto EQ 'X'.
    PERFORM select_kto.
  ENDIF.
  IF p_lno NE 'X'.
    PERFORM select_langtxt.
  ENDIF.

END-OF-SELECTION.

  PERFORM get_ausgabe_folge.
  PERFORM modify_g_fields.

* Ausgabe der Felder
  IF p_ssep EQ 'X'.
    IF p_ukaptl EQ 'X'.
      PERFORM selektionsfeldausgabe TABLES s_ext_grkey.
    ELSE.
      PERFORM selektionsfeldausgabe TABLES s_grkey.
    ENDIF.
  ENDIF.
  IF p_ukaptl EQ 'X'.
    PERFORM ausgabe_struktur TABLES s_ext_grkey.
  ELSE.
    PERFORM ausgabe_struktur TABLES s_grkey.
  ENDIF.

* Ausgabe der Langtextdokumentation im Anhang
  IF p_lanh EQ 'X'.
    IF p_ukaptl EQ 'X'.
      PERFORM langtext_im_anhang TABLES s_ext_grkey.
    ELSE.
      PERFORM langtext_im_anhang TABLES s_grkey.
    ENDIF.
  ENDIF.

TOP-OF-PAGE.
  PERFORM main_header.

*&---------------------------------------------------------------------*
*&      Form  APPEND_FOLGEEBENE
*&---------------------------------------------------------------------*
FORM append_folgeebene USING value(p_grkey).
  zae = zae + 1.
  LOOP AT g_hf0 WHERE parent EQ p_grkey.
    g_f0 = g_hf0.
    g_f0-ebene = zae.
    APPEND g_f0.
    DELETE g_hf0.
    PERFORM append_folgeebene USING g_hf0-grkey.
  ENDLOOP.
  zae = zae - 1.
ENDFORM.                    " APPEND_FOLGEEBENE

*&---------------------------------------------------------------------*
*&      Form  GET_AUSGABE_FOLGE
*&---------------------------------------------------------------------*
*       Bestimmung der Ausgabereihenfolge
*----------------------------------------------------------------------*
FORM get_ausgabe_folge.
  CLEAR g_f0. REFRESH g_f0.
  SORT g_hf0 BY parent sortn grkey.
  LOOP AT g_hf0.
    IF g_hf0-grkey EQ g_hf0-parent.
      g_f0 = g_hf0.
      g_f0-ebene = 0.
      APPEND g_f0.
      save_grkey = g_hf0-grkey.
      DELETE g_hf0.
    ENDIF.
  ENDLOOP.
  LOOP AT g_hf0 WHERE parent EQ save_grkey.
    g_f0 = g_hf0.
    g_f0-ebene = 1.
    APPEND g_f0.
    DELETE g_hf0.
    zae = 1.
    PERFORM append_folgeebene USING g_hf0-grkey.
  ENDLOOP.
ENDFORM.                    " GET_AUSGABE_FOLGE

*&---------------------------------------------------------------------*
*&      Form  SELECT_FELDGRUPPIERUNG
*&---------------------------------------------------------------------*
*       Feldgrupperierungen lesen
*----------------------------------------------------------------------*
FORM select_feldgruppierung TABLES p_g_hf0 STRUCTURE g_hf0.
  SELECT
    /sie/hr_idp_f0~grtyp /sie/hr_idp_f0~grkey
    /sie/hr_idp_f0~sortn /sie/hr_idp_f0~parent
    /sie/hr_idp_f0t~ident
    APPENDING CORRESPONDING FIELDS OF TABLE p_g_hf0
    FROM  /sie/hr_idp_f0 INNER JOIN /sie/hr_idp_f0t
    ON    /sie/hr_idp_f0~grtyp EQ /sie/hr_idp_f0t~grtyp
    AND   /sie/hr_idp_f0~grkey EQ /sie/hr_idp_f0t~grkey
    WHERE /sie/hr_idp_f0t~spras EQ sy-langu.
  IF sy-subrc NE 0.
    MESSAGE i216.
* Keine Feldgruppierungen vorhanden.
  ENDIF.
ENDFORM.                    " SELECT_FELDGRUPPIERUNG

*&---------------------------------------------------------------------*
*&      Form  SELECT_LANGTXT
*&---------------------------------------------------------------------*
*       Langtextdaten lesen
*----------------------------------------------------------------------*
FORM select_langtxt.
  SELECT * INTO TABLE g_f1lt FROM /sie/hr_idp_f1lt.
  IF sy-subrc NE 0.
    MESSAGE i217.
* Keine Langtexte vorhanden.
  ENDIF.
ENDFORM.                    " SELECT_LANGTXT

*&---------------------------------------------------------------------*
*&      Form  SELECT_SELEKTIONSFELDER
*&---------------------------------------------------------------------*
*       Selektionsfelddaten lesen
*----------------------------------------------------------------------*
FORM select_selektionsfelder TABLES p_f1s STRUCTURE g_f1s.
  SELECT feldname INTO TABLE p_f1s FROM /sie/hr_idp_f1s.
  IF sy-subrc NE 0.
    MESSAGE i219.
* Keine Selektionsfelder vorhanden.
  ENDIF.
ENDFORM.                    " SELECT_SELEKTIONSFELDER

*&---------------------------------------------------------------------*
*&      Form  SELECT_INFTY
*&---------------------------------------------------------------------*
*       Infotypdaten lesen
*----------------------------------------------------------------------*
FORM select_infty.
  SELECT
    /sie/hr_idp_f1~feldname  /sie/hr_idp_f1~grkey
    /sie/hr_idp_f1~sortn     /sie/hr_idp_f1~dpftype
    /sie/hr_idp_f1~infty     /sie/hr_idp_f1~subty
    /sie/hr_idp_f1~inftyfeld /sie/hr_idp_f1t~ident
    APPENDING CORRESPONDING FIELDS OF TABLE g_fields
    FROM  /sie/hr_idp_f1 INNER JOIN /sie/hr_idp_f1t
    ON    /sie/hr_idp_f1~feldname EQ /sie/hr_idp_f1t~feldname
    WHERE /sie/hr_idp_f1~dpftype EQ '1'
    AND   /sie/hr_idp_f1t~spras EQ sy-langu
    AND   /sie/hr_idp_f1~infty IN s_infot
    AND   /sie/hr_idp_f1~subty IN s_subty.
  IF sy-subrc NE 0.
    MESSAGE i212.
* Kein Infotypfeld vorhanden.
  ENDIF.
ENDFORM.                    " SELECT_INFTY

*&---------------------------------------------------------------------*
*&      Form  SELECT_LGART
*&---------------------------------------------------------------------*
*       Lohnartendaten lesen
*----------------------------------------------------------------------*
FORM select_lgart.
  SELECT
    /sie/hr_idp_f1~feldname  /sie/hr_idp_f1~grkey
    /sie/hr_idp_f1~sortn     /sie/hr_idp_f1~dpftype
    /sie/hr_idp_f1~rtlgart   /sie/hr_idp_f1~rtkz
    /sie/hr_idp_f1t~ident
    APPENDING CORRESPONDING FIELDS OF TABLE g_fields
    FROM  /sie/hr_idp_f1 INNER JOIN /sie/hr_idp_f1t
    ON    /sie/hr_idp_f1~feldname EQ /sie/hr_idp_f1t~feldname
    WHERE /sie/hr_idp_f1~dpftype EQ '4'
    AND   /sie/hr_idp_f1t~spras EQ sy-langu
    AND   /sie/hr_idp_f1~rtlgart IN s_rtlgrt.
  IF sy-subrc NE 0.
    MESSAGE i215.
* Keine Lohnart aus RT vorhanden.
  ENDIF.
ENDFORM.                    " SELECT_LGART

*&---------------------------------------------------------------------*
*&      Form  SELECT_GEBIL
*&---------------------------------------------------------------------*
*       Daten der Gebildeten Begriffe lesen
*----------------------------------------------------------------------*
FORM select_gebil.
  SELECT
    /sie/hr_idp_f1~feldname  /sie/hr_idp_f1~grkey
    /sie/hr_idp_f1~sortn     /sie/hr_idp_f1~dpftype
    /sie/hr_idp_f1~begriff   /sie/hr_idp_f1~konvstrg
    /sie/hr_idp_f1~konvname  /sie/hr_idp_f1t~ident
    APPENDING CORRESPONDING FIELDS OF TABLE g_fields
    FROM  /sie/hr_idp_f1 INNER JOIN /sie/hr_idp_f1t
    ON    /sie/hr_idp_f1~feldname EQ /sie/hr_idp_f1t~feldname
    WHERE /sie/hr_idp_f1~dpftype EQ '2'
    AND   /sie/hr_idp_f1t~spras EQ sy-langu.
  IF sy-subrc NE 0.
    MESSAGE i213.
* Kein gebildeter Begriff vorhanden.
  ENDIF.
ENDFORM.                    " SELECT_GEBIL

*&---------------------------------------------------------------------*
*&      Form  SELECT_KTO
*&---------------------------------------------------------------------*
*       Daten Abrechnungsclustertabelle lesen
*----------------------------------------------------------------------*
FORM select_kto.
  SELECT
    /sie/hr_idp_f1~feldname  /sie/hr_idp_f1~grkey
    /sie/hr_idp_f1~sortn     /sie/hr_idp_f1~dpftype
    /sie/hr_idp_f1~acltab    /sie/hr_idp_f1~aclfeld
    /sie/hr_idp_f1t~ident
    APPENDING CORRESPONDING FIELDS OF TABLE g_fields
    FROM  /sie/hr_idp_f1 INNER JOIN /sie/hr_idp_f1t
    ON    /sie/hr_idp_f1~feldname EQ /sie/hr_idp_f1t~feldname
    WHERE /sie/hr_idp_f1~dpftype EQ '3'
    AND   /sie/hr_idp_f1t~spras EQ sy-langu
    AND   /sie/hr_idp_f1~acltab IN s_acltab
    AND   /sie/hr_idp_f1~aclfeld IN s_aclfld.
  IF sy-subrc NE 0.
    MESSAGE i214.
* Kein Feld aus Abrechnungsclustertabelle vorhanden.
  ENDIF.
ENDFORM.                    " SELECT_KTO

*&---------------------------------------------------------------------*
*&      Form  MODIFY_G_FIELDS
*&---------------------------------------------------------------------*
*       Bei Selektionsfeldern Kennzeichen setzen
*----------------------------------------------------------------------*
FORM modify_g_fields.
  SORT g_fields BY grkey sortn feldname.
  LOOP AT g_fields.
    READ TABLE g_f1s WITH KEY feldname = g_fields-feldname.
    IF sy-subrc EQ 0.
      g_fields-selfd = 'X'.
    ELSE.
      g_fields-selfd = space.
    ENDIF.
*   Datentyp und Länge bestimmen
    CALL FUNCTION '/SIE/HR_IDP_GET_TYPE'
         EXPORTING
              logical_field  = g_fields-feldname
         IMPORTING
              external_type  = g_fields-type
*              db_length      = g_fields-leng  "aha003
                 length      = g_fields-leng  "aha003
*              INTERNAL_TYPE  =
         EXCEPTIONS
              type_undefined = 1
              type_not_found = 2
              OTHERS         = 3.
    IF sy-subrc <> 0. ENDIF.
    MODIFY g_fields.
  ENDLOOP.
ENDFORM.                    " MODIFY_G_FIELDS

*&---------------------------------------------------------------------*
*&      Form  MAIN_HEADER
*&---------------------------------------------------------------------*
FORM main_header.
  TRANSLATE g_f0-ident TO UPPER CASE.
  ULINE.
  FORMAT COLOR COL_NORMAL INTENSIFIED ON.
  CASE header.
    WHEN 'ALLG'.
      WRITE: /01  sy-datum DD/MM/YYYY,
              30  g_f0-ident,
              70 'Seite', (05) sy-pagno.
    WHEN 'SELFELDER'.
      WRITE: /01  sy-datum DD/MM/YYYY,
              22  text-t12, 40 g_f0-ident,
              70 'Seite', (05) sy-pagno.
    WHEN 'ANHANG'.
      WRITE: /01  sy-datum DD/MM/YYYY,
              26  text-t11, 34 g_f0-ident,
              70 'Seite', (05) sy-pagno.
  ENDCASE.
  FORMAT COLOR OFF.
  ULINE.
  SKIP.
ENDFORM.                    " MAIN_HEADER

*&---------------------------------------------------------------------*
*&      Form  TEILBAUM_AUFBAUEN
*&---------------------------------------------------------------------*
FORM teilbaum_aufbauen USING value(p_grkey).
  SORT grup BY parent sortn grkey.
  LOOP AT grup WHERE grkey EQ p_grkey.
    g_f0 = grup.
    APPEND g_f0.
    DELETE grup.
    PERFORM append_naechste_ebene USING grup-grkey.
  ENDLOOP.
  PERFORM fill_select_option TABLES g_f0
                                    s_ext_grkey.
ENDFORM.                    " TEILBAUM_AUFBAUEN

*&---------------------------------------------------------------------*
*&      Form  BLOW_UP_SELECT_OPTION
*&---------------------------------------------------------------------*
*       Erweitern der Select Option um Kapitel vor Feldebene
*----------------------------------------------------------------------*
FORM blow_up_select_option TABLES p_kaptl STRUCTURE kaptl.
  LOOP AT p_kaptl.
    grup[] = g_hf0[].
    PERFORM teilbaum_aufbauen USING p_kaptl-grkey.
    PERFORM init.
  ENDLOOP.
ENDFORM.                    " BLOW_UP_SELECT_OPTION

*&---------------------------------------------------------------------*
*&      Form  APPEND_NAECHSTE_EBENE
*&---------------------------------------------------------------------*
*       Nächste Ebene in die Tabelle stellen
*----------------------------------------------------------------------*
FORM append_naechste_ebene USING value(p_grkey).
  LOOP AT grup WHERE parent EQ p_grkey.
    g_f0 = grup.
    APPEND g_f0.
    DELETE grup.
    PERFORM append_naechste_ebene USING grup-grkey.
  ENDLOOP.
ENDFORM.                    " APPEND_NAECHSTE_EBENE

*&---------------------------------------------------------------------*
*&      Form  FILL_TABLE_KAPTL
*&---------------------------------------------------------------------*
*       Select Options seqentiell auflisten
*----------------------------------------------------------------------*
FORM fill_table_kaptl TABLES p_kaptl STRUCTURE kaptl.
  LOOP AT g_hf0 WHERE grkey IN s_grkey.
    p_kaptl-grkey = g_hf0-grkey.
    APPEND p_kaptl.
  ENDLOOP.
  IF sy-subrc EQ 4.
    MESSAGE s237.
    LEAVE PROGRAM.
  ENDIF.
ENDFORM.                    " FILL_TABLE_KAPTL

*&---------------------------------------------------------------------*
*&      Form  INIT
*&---------------------------------------------------------------------*
*       Initialisieren
*----------------------------------------------------------------------*
FORM init.
  CLEAR: grup
       , g_f0
       .
  REFRESH: grup
         , g_f0
         .
ENDFORM.                    " INIT

*&---------------------------------------------------------------------*
*&      Form  FILL_SELECT_OPTION
*&---------------------------------------------------------------------*
*       Füllen der Select-Option-Tabelle
*----------------------------------------------------------------------*
FORM fill_select_option TABLES p_f0 STRUCTURE g_f0
                               p_grkey STRUCTURE s_grkey.
  p_grkey-sign = 'I'.
  p_grkey-option = 'EQ'.
  LOOP AT p_f0.
    p_grkey-low = p_f0-grkey.
    APPEND p_grkey.
  ENDLOOP.
  SORT p_grkey BY low.
  DELETE ADJACENT DUPLICATES FROM p_grkey.
ENDFORM.                    " FILL_SELECT_OPTION

*&---------------------------------------------------------------------*
*&      Form  SELECT_STRUC
*&---------------------------------------------------------------------*
FORM select_struc TABLES p_grkey STRUCTURE s_grkey.
  SELECT
    /sie/hr_idp_f1~feldname  /sie/hr_idp_f1~grkey
    /sie/hr_idp_f1~sortn     /sie/hr_idp_f1~dpftype
    /sie/hr_idp_f1~infty     /sie/hr_idp_f1~subty
    /sie/hr_idp_f1~inftyfeld /sie/hr_idp_f1~begriff
    /sie/hr_idp_f1~acltab    /sie/hr_idp_f1~aclfeld
    /sie/hr_idp_f1~rtlgart   /sie/hr_idp_f1~rtkz
    /sie/hr_idp_f1~konvstrg  /sie/hr_idp_f1~konvname
    /sie/hr_idp_f1t~ident
    APPENDING CORRESPONDING FIELDS OF TABLE g_fields
    FROM  /sie/hr_idp_f1 INNER JOIN /sie/hr_idp_f1t
    ON    /sie/hr_idp_f1~feldname EQ /sie/hr_idp_f1t~feldname
    WHERE /sie/hr_idp_f1~grkey IN p_grkey
    AND   /sie/hr_idp_f1t~spras EQ sy-langu.
  IF sy-subrc NE 0.
    MESSAGE i221.
* Kein Katalogfeld vorhanden.
  ENDIF.
ENDFORM.                    " SELECT_STRUC

*&---------------------------------------------------------------------*
*&      Form  AUSGABE_STRUKTUR
*&---------------------------------------------------------------------*
*       Ausgabe der Feldgruppen
*----------------------------------------------------------------------*
FORM ausgabe_struktur TABLES p_grkey STRUCTURE s_grkey.
  DATA grkey_old LIKE g_f0-grkey.
  header = 'ALLG'.
  LOOP AT g_f0 WHERE grtyp EQ '2'
               AND   grkey IN p_grkey.
    IF g_f0-grkey EQ g_f0-parent.
      CONTINUE.
    ENDIF.
    READ TABLE g_fields WITH KEY grkey = g_f0-grkey.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.
    IF g_f0-grkey NE grkey_old.
      grkey_old = g_f0-grkey.
      NEW-PAGE.
    ENDIF.
    FORMAT RESET.
    IF p_sliste EQ 'X'.
      PERFORM ausgabe_mit_selfelder.
    ELSE.
      PERFORM ausgabe_ohne_selfelder.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " AUSGABE_STRUKTUR

*&---------------------------------------------------------------------*
*&      Form  SELECT_LOHNARTEN_TEXTE
*&---------------------------------------------------------------------*
*       Lesen der Lohnartentexte.
*----------------------------------------------------------------------*
FORM select_lohnarten_texte TABLES p_i512t STRUCTURE t512t.
  SELECT * INTO TABLE p_i512t FROM t512t.
  IF sy-subrc NE 0.
    MESSAGE e223.
* Keine Lohnartentexte vorhanden.
  ENDIF.
ENDFORM.                    " SELECT_LOHNARTEN_TEXTE

*&---------------------------------------------------------------------*
*&      Form  LANGTEXT_IM_ANHANG
*&---------------------------------------------------------------------*
*       Ausgabe der Langtextdokumentation. Es wird die Langtext-
*       dokumentation der selektierten Kapitel ausgegeben
*----------------------------------------------------------------------*
FORM langtext_im_anhang TABLES p_grkey STRUCTURE s_grkey.
  DATA grkey_old LIKE g_f0-grkey.
  header = 'ANHANG'.
  LOOP AT g_f0 WHERE grtyp EQ '2'
               AND   grkey IN p_grkey.
    IF g_f0-grkey EQ g_f0-parent.
      CONTINUE.
    ENDIF.
    READ TABLE g_fields WITH KEY grkey = g_f0-grkey.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.
    IF g_f0-grkey NE grkey_old.
      grkey_old = g_f0-grkey.
      NEW-PAGE.
    ENDIF.
    FORMAT RESET.
    LOOP AT g_fields WHERE grkey EQ g_f0-grkey.
      READ TABLE g_f1lt WITH KEY spras = sy-langu
                                 feldname = g_fields-feldname.
      IF sy-subrc EQ 0.
        RESERVE 3 LINES.
        CONCATENATE g_fields-feldname
          g_fields-ident INTO zeile1 SEPARATED BY ': '.
        WRITE: /5 zeile1.
        LOOP AT g_f1lt WHERE feldname EQ g_fields-feldname.
          WRITE /8 g_f1lt-tline.
        ENDLOOP.
        SKIP.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " LANGTEXT_IM_ANHANG

*&---------------------------------------------------------------------*
*&      Form  SELEKTIONSFELDAUSGABE
*&---------------------------------------------------------------------*
*       Ausgabe der Seleketionsfelder vor Liste der Nutzfelder
*----------------------------------------------------------------------*
FORM selektionsfeldausgabe TABLES p_grkey STRUCTURE s_grkey.
  DATA grkey_old LIKE g_f0-grkey.
  header = 'SELFELDER'.
  LOOP AT g_f0 WHERE grtyp EQ '2'
               AND   grkey IN p_grkey.
    IF g_f0-grkey EQ g_f0-parent.
      CONTINUE.
    ENDIF.
    READ TABLE g_fields WITH KEY grkey = g_f0-grkey
                                 selfd = 'X'.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.
    IF g_f0-grkey NE grkey_old.
      grkey_old = g_f0-grkey.
      NEW-PAGE.
    ENDIF.
    FORMAT RESET.
    LOOP AT g_fields WHERE grkey EQ g_f0-grkey
                     AND   selfd EQ 'X'.
      IF p_lliste EQ 'X'.
        RESERVE 3 LINES.
      ELSE.
        RESERVE 2 LINES.
      ENDIF.
      CONCATENATE g_fields-feldname
        g_fields-ident INTO zeile1 SEPARATED BY ': '.
      WRITE: /5 zeile1.
      SHIFT g_fields-leng LEFT DELETING LEADING '0'.
      IF NOT g_fields-subty IS INITIAL.
        CONCATENATE text-t01 g_fields-inftyfeld text-t02
          g_fields-infty text-t03 g_fields-subty g_fields-type
          g_fields-leng INTO zeile2 SEPARATED BY space.
      ELSE.
        CONCATENATE text-t01 g_fields-inftyfeld text-t02
          g_fields-infty g_fields-type g_fields-leng INTO
          zeile2 SEPARATED BY space.
      ENDIF.
      WRITE: /8 zeile2.
      IF g_fields-selfd EQ 'X' AND p_sliste EQ 'X'.
        WRITE: /8 text-t04.
      ENDIF.
      IF p_lliste EQ  'X'.
        LOOP AT g_f1lt WHERE feldname EQ g_fields-feldname.
          WRITE /8 g_f1lt-tline.
        ENDLOOP.
      ENDIF.
      SKIP.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " SELEKTIONSFELDAUSGABE

*&---------------------------------------------------------------------*
*&      Form  AUSGABE_MIT_SELFELDER
*&---------------------------------------------------------------------*
FORM ausgabe_mit_selfelder.
  LOOP AT g_fields WHERE grkey EQ g_f0-grkey.
    CASE g_fields-dpftype.
      WHEN '1'.
        IF g_fields-selfd EQ 'X' AND p_lliste EQ 'X'.
          RESERVE 4 LINES.
        ELSEIF g_fields-selfd EQ 'X'.
          RESERVE 3 LINES.
        ELSE.
          RESERVE 2 LINES.
        ENDIF.
        CONCATENATE g_fields-feldname
          g_fields-ident INTO zeile1 SEPARATED BY ': '.
        WRITE: /5 zeile1.
        SHIFT g_fields-leng LEFT DELETING LEADING '0'.
        IF NOT g_fields-subty IS INITIAL.
          CONCATENATE text-t01 g_fields-inftyfeld text-t02
            g_fields-infty text-t03 g_fields-subty g_fields-type
            g_fields-leng INTO zeile2 SEPARATED BY space.
        ELSE.
          CONCATENATE text-t01 g_fields-inftyfeld text-t02
            g_fields-infty g_fields-type g_fields-leng INTO
            zeile2 SEPARATED BY space.
        ENDIF.
        WRITE: /8 zeile2.
        IF g_fields-selfd EQ 'X' AND p_sliste EQ 'X'.
          WRITE: /8 text-t04.
        ENDIF.
        IF p_lliste EQ  'X'.
          LOOP AT g_f1lt WHERE feldname EQ g_fields-feldname.
            WRITE /8 g_f1lt-tline.
          ENDLOOP.
        ENDIF.
        SKIP.
      WHEN '2'.
        IF p_lliste EQ 'X' AND NOT g_fields-konvstrg IS INITIAL.
          RESERVE 4 LINES.
        ELSEIF NOT g_fields-konvstrg IS INITIAL.
          RESERVE 3 LINES.
        ELSE.
          RESERVE 2 LINES.
        ENDIF.
        CONCATENATE g_fields-feldname
          g_fields-ident INTO zeile1 SEPARATED BY ': '.
        WRITE: /5 zeile1.
        SHIFT g_fields-leng LEFT DELETING LEADING '0'.
        CONCATENATE text-t13 g_fields-begriff g_fields-type
          g_fields-leng INTO begriff SEPARATED BY space.
        WRITE: /8 begriff.
        IF NOT g_fields-konvstrg IS INITIAL.
          CONCATENATE text-t05 g_fields-konvname INTO zeile2
            SEPARATED BY space.
          WRITE: /8 zeile2.
        ENDIF.
        IF p_lliste EQ  'X'.
          LOOP AT g_f1lt WHERE feldname EQ g_fields-feldname.
            WRITE /8 g_f1lt-tline.
          ENDLOOP.
        ENDIF.
        SKIP.
      WHEN '3'.
* Feld aus Abrechnungsclustertabelle
        IF p_lliste EQ 'X'.
          RESERVE 3 LINES.
        ELSE.
          RESERVE 2 LINES.
        ENDIF.
        CONCATENATE g_fields-feldname g_fields-ident INTO zeile1
          SEPARATED BY ': '.
        WRITE: /5 zeile1.
        SHIFT g_fields-leng LEFT DELETING LEADING '0'.
        CONCATENATE text-t01 g_fields-aclfeld text-t06
          g_fields-acltab g_fields-type g_fields-leng INTO
          zeile2 SEPARATED BY space.
        WRITE: /8 zeile2.
        IF p_lliste EQ  'X'.
          LOOP AT g_f1lt WHERE feldname EQ g_fields-feldname.
            WRITE /8 g_f1lt-tline.
          ENDLOOP.
        ENDIF.
        SKIP.
      WHEN '4'.
* Lohnart aus der RT im Abrechnungscluster
        IF p_lliste EQ 'X'.
          RESERVE 3 LINES.
        ELSE.
          RESERVE 2 LINES.
        ENDIF.
        CONCATENATE g_fields-feldname g_fields-ident INTO zeile1
          SEPARATED BY ': '.
        WRITE: /5 zeile1.
        READ TABLE i512t WITH KEY sprsl = sy-langu
                                  molga = '01'
                                  lgart = g_fields-rtlgart.
        IF sy-subrc NE 0.
          CLEAR i512t.
        ENDIF.
        SHIFT g_fields-leng LEFT DELETING LEADING '0'.
        CASE g_fields-rtkz.
          WHEN 'A'.
            CONCATENATE text-t01 text-t07 text-t08 g_fields-rtlgart
              i512t-lgtxt g_fields-type g_fields-leng INTO
              zeile2 SEPARATED BY space.
          WHEN 'N'.
            CONCATENATE text-t01 text-t09 text-t08 g_fields-rtlgart
              i512t-lgtxt  g_fields-type g_fields-leng INTO
              zeile2 SEPARATED BY space.
          WHEN 'R'.
            CONCATENATE text-t01 text-t10 text-t08 g_fields-rtlgart
              i512t-lgtxt  g_fields-type g_fields-leng INTO
              zeile2 SEPARATED BY space.
        ENDCASE.
        WRITE: /8 zeile2.
        IF p_lliste EQ  'X'.
          LOOP AT g_f1lt WHERE feldname EQ g_fields-feldname.
            WRITE /8 g_f1lt-tline.
          ENDLOOP.
        ENDIF.
        SKIP.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " AUSGABE_MIT_SELFELDER

*&---------------------------------------------------------------------*
*&      Form  AUSGABE_OHNE_SELFELDER
*&---------------------------------------------------------------------*
FORM ausgabe_ohne_selfelder.
  LOOP AT g_fields WHERE grkey EQ g_f0-grkey
                   AND   selfd EQ space.
    CASE g_fields-dpftype.
      WHEN '1'.
        IF p_lliste EQ 'X'.
          RESERVE 3 LINES.
        ELSE.
          RESERVE 2 LINES.
        ENDIF.
        CONCATENATE g_fields-feldname
          g_fields-ident INTO zeile1 SEPARATED BY ': '.
        WRITE: /5 zeile1.
        SHIFT g_fields-leng LEFT DELETING LEADING '0'.
        IF NOT g_fields-subty IS INITIAL.
          CONCATENATE text-t01 g_fields-inftyfeld text-t02
            g_fields-infty text-t03 g_fields-subty g_fields-type
            g_fields-leng INTO zeile2 SEPARATED BY space.
        ELSE.
          CONCATENATE text-t01 g_fields-inftyfeld text-t02
            g_fields-infty g_fields-type g_fields-leng INTO
            zeile2 SEPARATED BY space.
        ENDIF.
        WRITE: /8 zeile2.
        IF g_fields-selfd EQ 'X' AND p_sliste EQ 'X'.
          WRITE: /8 text-t04.
        ENDIF.
        IF p_lliste EQ  'X'.
          LOOP AT g_f1lt WHERE feldname EQ g_fields-feldname.
            WRITE /8 g_f1lt-tline.
          ENDLOOP.
        ENDIF.
        SKIP.
      WHEN '2'.
        IF p_lliste EQ 'X' AND NOT g_fields-konvstrg IS INITIAL.
          RESERVE 4 LINES.
        ELSEIF NOT g_fields-konvstrg IS INITIAL.
          RESERVE 3 LINES.
        ELSE.
          RESERVE 2 LINES.
        ENDIF.
        CONCATENATE g_fields-feldname
          g_fields-ident INTO zeile1 SEPARATED BY ': '.
        WRITE: /5 zeile1.
        SHIFT g_fields-leng LEFT DELETING LEADING '0'.
        CONCATENATE text-t13 g_fields-begriff g_fields-type
          g_fields-leng INTO begriff SEPARATED BY space.
        WRITE: /8 begriff.
        IF NOT g_fields-konvstrg IS INITIAL.
          CONCATENATE text-t05 g_fields-konvname INTO zeile2
            SEPARATED BY space.
          WRITE: /8 zeile2.
        ENDIF.
        IF p_lliste EQ  'X'.
          LOOP AT g_f1lt WHERE feldname EQ g_fields-feldname.
            WRITE /8 g_f1lt-tline.
          ENDLOOP.
        ENDIF.
        SKIP.
      WHEN '3'.
* Feld aus Abrechnungsclustertabelle
        IF p_lliste EQ 'X'.
          RESERVE 3 LINES.
        ELSE.
          RESERVE 2 LINES.
        ENDIF.
        CONCATENATE g_fields-feldname g_fields-ident INTO zeile1
          SEPARATED BY ': '.
        WRITE: /5 zeile1.
        SHIFT g_fields-leng LEFT DELETING LEADING '0'.
        CONCATENATE text-t01 g_fields-aclfeld text-t06
          g_fields-acltab g_fields-type g_fields-leng INTO
          zeile2 SEPARATED BY space.
        WRITE: /8 zeile2.
        IF p_lliste EQ  'X'.
          LOOP AT g_f1lt WHERE feldname EQ g_fields-feldname.
            WRITE /8 g_f1lt-tline.
          ENDLOOP.
        ENDIF.
        SKIP.
      WHEN '4'.
* Lohnart aus der RT im Abrechnungscluster
        IF p_lliste EQ 'X'.
          RESERVE 3 LINES.
        ELSE.
          RESERVE 2 LINES.
        ENDIF.
        CONCATENATE g_fields-feldname g_fields-ident INTO zeile1
          SEPARATED BY ': '.
        WRITE: /5 zeile1.
        READ TABLE i512t WITH KEY sprsl = sy-langu
                                  molga = '01'
                                  lgart = g_fields-rtlgart.
        IF sy-subrc NE 0.
          CLEAR i512t.
        ENDIF.
        SHIFT g_fields-leng LEFT DELETING LEADING '0'.
        CASE g_fields-rtkz.
          WHEN 'A'.
            CONCATENATE text-t01 text-t07 text-t08 g_fields-rtlgart
              i512t-lgtxt g_fields-type g_fields-leng INTO
              zeile2 SEPARATED BY space.
          WHEN 'N'.
            CONCATENATE text-t01 text-t09 text-t08 g_fields-rtlgart
              i512t-lgtxt g_fields-type g_fields-leng INTO
              zeile2 SEPARATED BY space.
          WHEN 'R'.
            CONCATENATE text-t01 text-t10 text-t08 g_fields-rtlgart
              i512t-lgtxt g_fields-type g_fields-leng INTO
              zeile2 SEPARATED BY space.
        ENDCASE.
        WRITE: /8 zeile2.
        IF p_lliste EQ  'X'.
          LOOP AT g_f1lt WHERE feldname EQ g_fields-feldname.
            WRITE /8 g_f1lt-tline.
          ENDLOOP.
        ENDIF.
        SKIP.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " AUSGABE_OHNE_SELFELDER

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_grkey-low.       "HAN001
*  PERFORM f4_tree USING 'L'.                                "HAN001
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_grkey-high.      "HAN001
*  PERFORM f4_tree USING 'H'.                                "HAN001

*---------------------------------------------------------------------*
*       FORM F4_TREE                                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f4_tree USING value(sw_grkey).
  CALL FUNCTION '/SIE/HR_IDP_F4_TREE_GRKEY_ONLY'
      EXPORTING
           grtyp           = '2'
*           FL_DISPLAY      = ' '
       TABLES
            selected_fields = sel_fields.
  READ TABLE sel_fields INDEX 1.
  CASE sw_grkey.
    WHEN 'L'.
      s_grkey-low = sel_fields-feldname.
    WHEN 'H'.
      s_grkey-high = sel_fields-feldname.
  ENDCASE.
ENDFORM.                                                    " f4_tree
