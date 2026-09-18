*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_F12                                        *
*----------------------------------------------------------------------*

DATA: l_display(1) TYPE c VALUE space
      , l_title LIKE sy-title
      , l_text LIKE rsselint-text
      , l_shelp LIKE ddshdescr-shlpname
      , l_hfield LIKE rsscr-dbfield
      .

*&---------------------------------------------------------------------*
*&      Form  GET_DIALOG
*&---------------------------------------------------------------------*
*       Fuellen des Popups Mehrfachselektion und Speichern der         *
*       Benutzereingaben                                               *
*----------------------------------------------------------------------*
FORM get_dialog.
  FIELD-SYMBOLS <wa_range>.
*    data: h_char(10) type c value 'PNPxxxxx[]'
  DATA: h_char(10) TYPE c
     , length TYPE i
     , off TYPE i
     , rollname LIKE dfies-fieldname
     , l_dummy(10) TYPE c
     .

  DATA: lr_range TYPE REF TO data.

  CLEAR: l_title
       , l_shelp
       , l_display
       , l_hfield
       , length
       , off
       .

  GET CURSOR LINE cursor_line.
  idx = tc_var-top_line + cursor_line - 1.
  READ TABLE g_vardata INDEX idx.
  CHECK NOT g_vardata-feldname IS INITIAL.

  PERFORM fill_dialog_values USING    g_vardata-ident
                             CHANGING l_display
                                      l_title
                                      l_text.

  SELECT SINGLE slnam INTO /sie/hr_idp_f1s-slnam FROM /sie/hr_idp_f1s
    WHERE feldname EQ g_vardata-feldname.
  IF sy-subrc NE 0.
    MESSAGE e209 WITH g_vardata-feldname.
* Name der Select-Option &1 unbekannt.
  ENDIF.

  CASE /sie/hr_idp_f1s-slnam(2).
    WHEN 'ZZ'.
      h_char = /sie/hr_idp_f1s-slnam.
      CONCATENATE h_char '[]' INTO h_char.
    WHEN OTHERS.
      CONCATENATE 'PNP' /sie/hr_idp_f1s-slnam+3(5) '[]' INTO h_char.
*       h_char+3(5) = /sie/hr_idp_f1s-slnam+3(5).
  ENDCASE.

  ASSIGN (h_char) TO <range>.
  IF sy-subrc NE 0.
    MESSAGE e211.
* Feld konnte dem Feldsymbol nicht zugewiesen werden.
  ENDIF.

  CREATE DATA lr_range LIKE LINE OF <range>.
  ASSIGN lr_range->* TO <wa_range>.
  IF sy-subrc NE 0.
    MESSAGE e210.
* Arbeitsbereich konnte dem Feldsymbol nicht zugewiesen werden.
  ENDIF.

  LOOP AT g_ifdata_tran-s1vt INTO wa_tran_s1vt
    WHERE feldname = g_vardata-feldname.
    CHECK NOT wa_tran_s1vt-ssign IS INITIAL.
    CONCATENATE wa_tran_s1vt-ssign wa_tran_s1vt-sopti
      wa_tran_s1vt-sllow wa_tran_s1vt-shigh INTO <wa_range>.
    APPEND <wa_range> TO <range>.
  ENDLOOP.
  IF NOT <range> IS INITIAL.
    SORT <range>.
  ENDIF.

  IF /sie/hr_idp_f1s-slnam(2) = 'ZZ'.
    PERFORM get_ddic_info USING    /sie/hr_idp_f1s-slnam
                          CHANGING l_hfield
                                   length.
  ELSE.
    PERFORM get_ddic_info USING    /sie/hr_idp_f1s-slnam+3(5)
                          CHANGING l_hfield
                                   length.
  ENDIF.

  IF l_hfield EQ 'PERNR-PERNR'.
    l_shelp = 'PREM'.
  ENDIF.

  CALL FUNCTION 'COMPLEX_SELECTIONS_DIALOG'
    EXPORTING
      title          = l_title
      text           = l_text
      search_help    = l_shelp
      just_display   = l_display
      help_field     = l_hfield
    TABLES
      range          = <range>
    EXCEPTIONS
      no_range_tab   = 1
      cancelled      = 2
      internal_error = 3
      OTHERS         = 4.
  IF sy-subrc <> 0.
    MESSAGE s201.
* Die eingegebenen Abgrenzungen wurden nicht übernommen.
  ELSE.
*    clear: <wa_range>
*         , wa_tran_s1vt
*    clear: wa_tran_s1vt
    .

    DELETE g_ifdata_tran-s1vt WHERE mandt  = sy-mandt
                              AND ifcid    = g_ifdata_tran-s1-ifcid
                              AND vrsnr    = g_ifdata_vers
                              AND feldname = g_vardata-feldname.
    CLEAR wa_tran_s1vt.
    wa_tran_s1vt-mandt    = sy-mandt.
    wa_tran_s1vt-ifcid    = g_ifdata_tran-s1-ifcid.
    wa_tran_s1vt-vrsnr    = g_ifdata_vers.
    wa_tran_s1vt-feldname = g_vardata-feldname.
    IF NOT <range> IS INITIAL.
      off = length + 3.
      LOOP AT <range> INTO <wa_range>.
        wa_tran_s1vt-ssign = <wa_range>+0(1).
        wa_tran_s1vt-sopti = <wa_range>+1(2).
        wa_tran_s1vt-sllow = <wa_range>+3(length).
        wa_tran_s1vt-shigh = <wa_range>+off(length).
        wa_tran_s1vt-seqno = wa_tran_s1vt-seqno + 1.
        APPEND wa_tran_s1vt TO g_ifdata_tran-s1vt.
      ENDLOOP.
    ELSE.
      APPEND wa_tran_s1vt TO g_ifdata_tran-s1vt.
    ENDIF.
  ENDIF.
  CLEAR <wa_range>.
  REFRESH <range>.

ENDFORM.                    " GET_DIALOG

*&---------------------------------------------------------------------*
*&      Form  GET_IDENT
*&---------------------------------------------------------------------*
*       Ermittle Bezeichner
*----------------------------------------------------------------------*
FORM get_ident USING    VALUE(p_feldname)
               CHANGING VALUE(p_ident).

  SELECT SINGLE ident INTO p_ident FROM /sie/hr_idp_f1t
    WHERE spras    = sy-langu
    AND   feldname = p_feldname.
  IF sy-subrc NE 0.
    CLEAR p_ident.
  ENDIF.
ENDFORM.                    " GET_IDENT

*&---------------------------------------------------------------------*
*&      Form  FILL_DIALOG_VALUES
*&---------------------------------------------------------------------*
FORM fill_dialog_values USING    VALUE(p_ident)
                        CHANGING VALUE(p_display)
                                 VALUE(p_title)
                                 VALUE(p_text).

  CLEAR wa_s1f.
  READ TABLE g_ifdata_tran-s1f INTO wa_s1f WITH KEY trole = '06'.
  IF sy-tcode = c_disp_tcod                        "XFT 31-08-2001
  OR NOT                                           "XFT 31-08-2001
*     ( g_ifdata_tran-s1vn-release_date is initial ). "XFT 31-08-2001
    ( wa_s1f-ch_datum IS INITIAL ).
    p_display = 'X'.
  ENDIF.
  CONCATENATE 'Mehrfachselektion für' p_ident INTO
    p_title SEPARATED BY space.
  p_text = p_ident.
ENDFORM.                    " FILL_DIALOG_VALUES

*&---------------------------------------------------------------------*
*&      Form  CHECK_SELEKTIONSFELD_VALID
*&---------------------------------------------------------------------*
FORM check_selektionsfeld_valid USING VALUE(p_feldname).
  SELECT SINGLE feldname INTO /sie/hr_idp_f1s-feldname FROM
    /sie/hr_idp_f1s WHERE feldname EQ p_feldname.
  IF sy-subrc NE 0.
    MESSAGE e204 WITH p_feldname.
* Feld &1 ist kein Selektionsfeld.
  ELSE.
    CLEAR /sie/hr_idp_f1s-feldname.
  ENDIF.
ENDFORM.                    " CHECK_SELEKTIONSFELD_VALID

*&---------------------------------------------------------------------*
*&      Form  CHECK_DUPLIKATE
*&---------------------------------------------------------------------*
FORM check_duplikate USING VALUE(p_feldname).
  READ TABLE g_ifdata_tran-s1vt INTO wa_tran_s1vt WITH KEY
    feldname = p_feldname.
  IF sy-subrc EQ 0.
    CLEAR wa_tran_s1vt.
    MESSAGE e206 WITH p_feldname.
* Feld &1 ist bereits vorhanden.
  ENDIF.
ENDFORM.                    " CHECK_DUPLIKATE

*&---------------------------------------------------------------------*
*&      Form  GET_DDIC_INFO
*&---------------------------------------------------------------------*
FORM get_ddic_info USING    VALUE(p_feldname)
                   CHANGING VALUE(p_hfield)
                            VALUE(p_length).

  DATA: dfies_table LIKE dfies OCCURS 0 WITH HEADER LINE
      , feldname LIKE dfies-fieldname
      , structure LIKE dcobjdef-name
      .

  feldname = p_feldname.

  CASE feldname.
    WHEN 'ZZBREINH'. structure = 'P0001'.
    WHEN 'ZZSTANDO'. structure = 'P0001'.
    WHEN 'ZZHANSP'.  structure = 'P0263'. SHIFT feldname BY 2 PLACES.
    WHEN 'ZZPKAT'.   structure = 'P9008'. SHIFT feldname BY 2 PLACES.
    WHEN 'ZZSEL'.    structure = 'P0203'.                      "SIE006
    WHEN 'ZZ_PBBR'.
      structure = '/SIE/HR_IDP_SEL_GB'.         "SIE007
      feldname  = 'PBBR'.                       "SIE007
    WHEN 'ZZ_BRPB'.
      structure = '/SIE/HR_IDP_SEL_BR_PB_PTBKOSTL'.     "AH002
      feldname  = 'BRPBPTBKOSTL'.                       "AH002
    WHEN 'ZZENTKTO'.
      structure = 'P9008'.                      "SIE008
      feldname  = 'ZZENTG_KTO'.                 "SIE008
    WHEN OTHERS.
      structure = 'PERNR'.
* do nothing.
  ENDCASE.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = structure
      fieldname      = feldname
      langu          = sy-langu
    TABLES
      dfies_tab      = dfies_table
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    MESSAGE w001.
  ENDIF.
  LOOP AT dfies_table TO 1.
  ENDLOOP.
  CONCATENATE dfies_table-tabname dfies_table-fieldname
    INTO p_hfield SEPARATED BY '-'.
  p_length = dfies_table-leng.
ENDFORM.                    " GET_DDIC_INFO
