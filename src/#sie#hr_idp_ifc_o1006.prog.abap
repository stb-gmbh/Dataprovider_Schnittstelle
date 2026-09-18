*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_O1006 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  D1006_PBO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE d1006_pbo OUTPUT.

  f1 = tc_sa-top_line.
  DESCRIBE TABLE g_itab_sa LINES f2.
  tc_sa-lines = f2.

  f3 = tc_saf-top_line.
  DESCRIBE TABLE g_itab_s1pg LINES f4.
  tc_saf-lines = f4.

ENDMODULE.                 " D1006_PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  R1006_PBO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE r1006_pbo OUTPUT.

  DATA: fl_double_field TYPE ty_yesno
      , idx_loop TYPE i
      .

  IF g_satzart_old <> g_700_satzart.
    CLEAR g_buffer_s1pg.
    CLEAR g_feldname. CLEAR g_feldname_idx.
    g_satzart_old = g_700_satzart.
    tc_saf-top_line = 1.
  ENDIF.

* Finde alle Felder die zur Satzart gehören und Speichere Sie in die
* Anzeigetabelle g_itab_sa.
  CLEAR g_itab_sa[].

  LOOP AT g_ifdata_tran-s1sa INTO /sie/hr_idp_s1sa
                             WHERE vrsnr = g_ifdata_vers.
    MOVE-CORRESPONDING /sie/hr_idp_s1sa TO /sie/hr_idp_satzarten_tc.
    IF g_1004_loaded IS INITIAL.
      g_1004_loaded = yes.
      g_700_satzart = /sie/hr_idp_satzarten_tc-recna.
      g_satzart_old = g_700_satzart.
    ENDIF.

    IF g_700_satzart = /sie/hr_idp_satzarten_tc-recna.
      /sie/hr_idp_satzarten_tc-mark = yes.
    ELSE.
      /sie/hr_idp_satzarten_tc-mark = no.
    ENDIF.

    PERFORM read_doma_text USING '/SIE/HR_IDP_RECORD_TYPE'
                                 /sie/hr_idp_satzarten_tc-recty
                        CHANGING /sie/hr_idp_satzarten_tc-ident_recty.

    PERFORM read_doma_text USING '/SIE/HR_IDP_DBAHD'
                                 /sie/hr_idp_satzarten_tc-dbahd
                        CHANGING /sie/hr_idp_satzarten_tc-ident_dbahd.

    PERFORM read_doma_text USING '/SIE/HR_IDP_DBAOC'
                                 /sie/hr_idp_satzarten_tc-dbaoc
                        CHANGING /sie/hr_idp_satzarten_tc-ident_dbaoc.

    IF /sie/hr_idp_satzarten_tc-recty = 3.
      CLEAR: /sie/hr_idp_satzarten_tc-ident_infty
           , /sie/hr_idp_satzarten_tc-infty
           , /sie/hr_idp_satzarten_tc-subty
           , /sie/hr_idp_satzarten_tc-ident_subty
           .
    ENDIF.

    PERFORM read_infty_text.

    APPEND /sie/hr_idp_satzarten_tc TO g_itab_sa.

  ENDLOOP.

  CLEAR g_itab_s1pg[].

  CLEAR fl_double_field. CLEAR idx_loop.
  LOOP AT g_ifdata_tran-s1pg INTO /sie/hr_idp_s1pg
                             WHERE recna = g_700_satzart
                             AND   vrsnr = g_ifdata_vers.

    MOVE-CORRESPONDING /sie/hr_idp_s1pg TO /sie/hr_idp_felder_tc.

    idx_loop = idx_loop + 1.
    IF idx_loop = g_feldname_idx.
      /sie/hr_idp_felder_tc-mark = yes.
    ELSE.
      /sie/hr_idp_felder_tc-mark = no.
    ENDIF.

    IF /sie/hr_idp_felder_tc-feldname = g_700_satzart.
      /sie/hr_idp_felder_tc-ident = 'Satzart'.
    ELSEIF /sie/hr_idp_felder_tc-feldname = 'PERNR'.
      /sie/hr_idp_felder_tc-ident = 'Personalnummer'.
    ELSE.
      PERFORM read_f1t USING /sie/hr_idp_felder_tc-feldname
                       CHANGING /sie/hr_idp_felder_tc-ident.
    ENDIF.

    CLEAR /sie/hr_idp_felder_tc-ident_konvname.
    IF NOT /sie/hr_idp_felder_tc-konvnam IS INITIAL.
      SELECT SINGLE * FROM /sie/hr_idp_c1t WHERE spras = sy-langu
               AND   konvnam = /sie/hr_idp_felder_tc-konvnam.
      IF sy-subrc = 0.
        /sie/hr_idp_felder_tc-ident_konvname = /sie/hr_idp_c1t-ident.
      ELSE.
        CLEAR /sie/hr_idp_felder_tc-ident_konvname.
      ENDIF.
    ENDIF.

    IF NOT /sie/hr_idp_felder_tc-konvnam IS INITIAL.
      IF /sie/hr_idp_felder_tc-param IS INITIAL.
        SELECT SINGLE * FROM /sie/hr_idp_c1
                        WHERE konvnam = /sie/hr_idp_felder_tc-konvnam.
        /sie/hr_idp_felder_tc-param = /sie/hr_idp_c1-konvpara.
      ENDIF.
    ENDIF.

    IF /sie/hr_idp_felder_tc-keypos = '001'.
      /sie/hr_idp_felder_tc-kzkey = yes.
    ELSE.
      /sie/hr_idp_felder_tc-kzkey = no.
    ENDIF.

*SIE003_BEG
*    APPEND /sie/hr_idp_felder_tc TO g_itab_s1pg.

    CLEAR g_itab_s1pg.
*    refresh g_itab_s1pg-s1ps.

*   Filter für entsprechende Felder übernehmen
    LOOP AT g_ifdata_tran-s1ps INTO /sie/hr_idp_s1ps
                   WHERE recna = /sie/hr_idp_felder_tc-recna
                     AND fldps = /sie/hr_idp_felder_tc-fldps.
       APPEND /sie/hr_idp_s1ps TO g_itab_s1pg-s1ps.
    ENDLOOP.

    MOVE-CORRESPONDING /sie/hr_idp_felder_tc TO g_itab_s1pg.
    APPEND g_itab_s1pg.
*SIE003_END

  ENDLOOP.

ENDMODULE.                 " R1006_PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  CREATE_SATZART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_recna.

  CLEAR /sie/hr_idp_s1sa.                       "SIE005
  CALL SCREEN 0700 STARTING AT 7 7.

  IF okcode EQ 'OK'.
    MOVE g_ifdata_vers TO /sie/hr_idp_s1sa-vrsnr.
    MOVE g_ifdata_tran-s1-ifcid TO /sie/hr_idp_s1sa-ifcid.
    MOVE g_700_satzart TO /sie/hr_idp_s1sa-recna.
    /sie/hr_idp_s1sa-mandt = sy-mandt.
    APPEND /sie/hr_idp_s1sa TO g_ifdata_tran-s1sa.

*standardzeilen für satzart eintragen
    IF ( /sie/hr_idp_s1sa-recty >< 1 ) AND
      ( /sie/hr_idp_s1sa-recty >< 5 ).

      CLEAR /sie/hr_idp_s1pg.
      /sie/hr_idp_s1pg-ifcid = g_ifdata_tran-s1-ifcid.
      /sie/hr_idp_s1pg-vrsnr = g_ifdata_vers.
      /sie/hr_idp_s1pg-recna = g_700_satzart.
      /sie/hr_idp_s1pg-fldps = 1.
      /sie/hr_idp_s1pg-feldname = g_700_satzart.
      /sie/hr_idp_s1pg-konvnam  = space.
      /sie/hr_idp_s1pg-keypos  = '001'.
      APPEND /sie/hr_idp_s1pg TO g_ifdata_tran-s1pg.

      CLEAR /sie/hr_idp_s1pg.
      /sie/hr_idp_s1pg-ifcid = g_ifdata_tran-s1-ifcid.
      /sie/hr_idp_s1pg-vrsnr = g_ifdata_vers.
      /sie/hr_idp_s1pg-recna = g_700_satzart.
      /sie/hr_idp_s1pg-fldps = 2.
      /sie/hr_idp_s1pg-feldname = 'PERNR'.
      /sie/hr_idp_s1pg-konvnam  = space.
      /sie/hr_idp_s1pg-keypos  = '001'.

      APPEND /sie/hr_idp_s1pg TO g_ifdata_tran-s1pg.
    ELSE.
      CLEAR /sie/hr_idp_s1pg.
      /sie/hr_idp_s1pg-ifcid = g_ifdata_tran-s1-ifcid.
      /sie/hr_idp_s1pg-vrsnr = g_ifdata_vers.
      /sie/hr_idp_s1pg-recna = g_700_satzart.
      /sie/hr_idp_s1pg-fldps = 1.
      /sie/hr_idp_s1pg-feldname = g_700_satzart.
      /sie/hr_idp_s1pg-konvnam  = space.
      /sie/hr_idp_s1pg-keypos  = '001'.

      APPEND /sie/hr_idp_s1pg TO g_ifdata_tran-s1pg.
    ENDIF.

  ELSE.
    CLEAR g_700_satzart.
  ENDIF.
ENDFORM.                    " CREATE_SATZART

*&---------------------------------------------------------------------*
*&      Form  copy_recna                          "SIE005
*&---------------------------------------------------------------------*
FORM copy_recna.

  DATA: old_recna LIKE g_700_satzart.

  old_recna = g_700_satzart.

  CLEAR /sie/hr_idp_s1sa-recna.
  CALL SCREEN 0700 STARTING AT 7 7.

  IF okcode EQ 'OK'.

*  Satzart anlegen
    MOVE g_ifdata_vers TO /sie/hr_idp_s1sa-vrsnr.
    MOVE g_ifdata_tran-s1-ifcid TO /sie/hr_idp_s1sa-ifcid.
    MOVE g_700_satzart TO /sie/hr_idp_s1sa-recna.
    /sie/hr_idp_s1sa-mandt = sy-mandt.
    APPEND /sie/hr_idp_s1sa TO g_ifdata_tran-s1sa.

*  Daten kopieren
    LOOP AT g_ifdata_tran-s1pg
                   INTO /sie/hr_idp_s1pg
                   WHERE recna = old_recna.

        IF /sie/hr_idp_s1pg-recna = /sie/hr_idp_s1pg-feldname.
           /sie/hr_idp_s1pg-feldname = g_700_satzart.
        ENDIF.
        /sie/hr_idp_s1pg-recna = g_700_satzart.
        APPEND /sie/hr_idp_s1pg TO g_ifdata_tran-s1pg.

    ENDLOOP.
    LOOP AT g_ifdata_tran-s1ps
                    INTO /sie/hr_idp_s1ps
                    WHERE recna = old_recna.
        /sie/hr_idp_s1ps-recna = g_700_satzart.
        APPEND /sie/hr_idp_s1ps TO g_ifdata_tran-s1ps.
   ENDLOOP.

  ELSE.
    CLEAR g_700_satzart.
  ENDIF.
ENDFORM.                    " copy_recna


*&---------------------------------------------------------------------*
*&      Module  PAGE_INDEX  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE page_index_f1 INPUT.
  tc_sa-top_line = f1.
ENDMODULE.                 " PAGE_INDEX  INPUT

*&---------------------------------------------------------------------*
*&      Module  PAGE_INDEX_F1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE page_index_f3 INPUT.
  tc_saf-top_line = f3.
ENDMODULE.                 " PAGE_INDEX_F1  INPUT

*&---------------------------------------------------------------------*
*&      Module  SWITCH_MONTH  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE switch_month OUTPUT.

  IF NOT ( /sie/hr_idp_felder_tc-feldname IS INITIAL ).
    IF /sie/hr_idp_felder_tc-recna <> /sie/hr_idp_felder_tc-feldname.

      SELECT SINGLE * FROM  /sie/hr_idp_f1
             WHERE  feldname  = /sie/hr_idp_felder_tc-feldname.

      IF /sie/hr_idp_f1-dpftype >< 4.
        LOOP AT SCREEN.
          CHECK screen-name = '/SIE/HR_IDP_FELDER_TC-MTHBK'.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " SWITCH_MONTH  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  READ_DOMA_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DOMAIN   Domäne
*      -->P_VALUE    Wert
*      <--P_IDENT    Text
*----------------------------------------------------------------------*
FORM read_doma_text USING    value(p_domain) TYPE c
                             value(p_value)
                    CHANGING p_ident TYPE c.

DATA: dd07v_tab TYPE STANDARD TABLE OF dd07v INITIAL SIZE 0 WITH HEADER
                                                                   LINE
                                          , l_domain TYPE dcobjdef-name
                                                                       .

  l_domain = p_domain.

  CALL FUNCTION 'DDIF_DOMA_GET'
       EXPORTING
            name          = l_domain
            langu         = sy-langu
       TABLES
            dd07v_tab     = dd07v_tab
       EXCEPTIONS
            illegal_input = 1
            OTHERS        = 2.
  IF sy-subrc <> 0.
    CLEAR p_ident.
  ELSE.
    READ TABLE dd07v_tab WITH KEY domname = l_domain
                                  domvalue_l = p_value.
    IF sy-subrc = 0.
      p_ident = dd07v_tab-ddtext.
    ELSE.
      CLEAR p_ident.
    ENDIF.
  ENDIF.

ENDFORM.                    " READ_DOMA_TEXT

*&---------------------------------------------------------------------*
*&      Form  DEL_RECNA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM del_recna.

  DATA: answer(1) TYPE c
      , text(70) TYPE c VALUE 'Soll die Satzart <SA> gelöscht werden?'
      .

  REPLACE '<SA>' WITH g_700_satzart INTO text.

  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
       EXPORTING
            defaultoption  = 'N'
            textline1      = text
            titel          = 'Satzart löschen?'
            start_column   = 25
            start_row      = 6
            cancel_display = no
       IMPORTING
            answer         = answer.

  IF answer = 'J'.
    DELETE g_ifdata_tran-s1pg WHERE recna = g_700_satzart.
    DELETE g_ifdata_tran-s1ps WHERE recna = g_700_satzart. "SIE003
    DELETE g_ifdata_tran-s1sa WHERE recna = g_700_satzart.
    CLEAR g_itab_s1pg[].
    READ TABLE g_ifdata_tran-s1sa INTO /sie/hr_idp_s1sa INDEX 1.
    IF sy-subrc = 0.
      CLEAR g_satzart_old.
      MESSAGE s131 WITH g_700_satzart.
      g_700_satzart = /sie/hr_idp_s1sa-recna.
    ELSE.
      CLEAR g_700_satzart.
    ENDIF.
  ELSE.
    MESSAGE s139 WITH g_700_satzart.
  ENDIF.

ENDFORM.                    " DEL_RECNA

*---------------------------------------------------------------------*
*       FORM REN_RECNA                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM ren_recna.

  DATA: l_recna LIKE /sie/hr_idp_s1sa-recna
      , answer(1) TYPE c
      .

  CALL FUNCTION 'POPUP_TO_GET_VALUE'
       EXPORTING
            fieldname           = 'RECNA'
            tabname             = '/SIE/HR_IDP_S1SA'
            titel               = 'Neuer Name'
            valuein             = g_700_satzart
       IMPORTING
            answer              = answer
            valueout            = l_recna
       EXCEPTIONS
            fieldname_not_found = 1
            OTHERS              = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF g_700_satzart = l_recna.
  ELSE.
    LOOP AT g_ifdata_tran-s1pg INTO /sie/hr_idp_s1pg
                               WHERE recna = g_700_satzart.
      /sie/hr_idp_s1pg-recna = l_recna.
      IF g_700_satzart = /sie/hr_idp_s1pg-feldname.
        /sie/hr_idp_s1pg-feldname = l_recna.
      ENDIF.
      MODIFY g_ifdata_tran-s1pg FROM /sie/hr_idp_s1pg.
    ENDLOOP.

    READ TABLE g_ifdata_tran-s1sa INTO /sie/hr_idp_s1sa
                                  WITH KEY recna = g_700_satzart.
    /sie/hr_idp_s1sa-recna = l_recna.
    MODIFY g_ifdata_tran-s1sa INDEX sy-tabix
                              FROM /sie/hr_idp_s1sa.

    g_700_satzart = l_recna.
  ENDIF.

ENDFORM.                    " REN_RECNA

*&---------------------------------------------------------------------*
*&      Module  CALC_STEP_LINES_A  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE calc_step_lines_a OUTPUT.
  step_lines_a = sy-loopc.
ENDMODULE.                 " CALC_STEP_LINES_A  OUTPUT

*---------------------------------------------------------------------*
*       MODULE CALC_STEP_LINES_B OUTPUT                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE calc_step_lines_b OUTPUT.
  step_lines_b = sy-loopc.
ENDMODULE.                 " CALC_STEP_LINES_B  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  HIDE_KEYS_1006  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE hide_keys_1006 OUTPUT.

  LOOP AT SCREEN.
    IF screen-group1 EQ '001'.
      IF sy-tcode EQ c_disp_tcod.
        screen-input = '0'.
      ELSE.
        screen-input = '1'.
      ENDIF.
    ENDIF.

    READ TABLE g_ifdata_tran-s1sa INTO /sie/hr_idp_s1sa
                                  WITH KEY recna = g_700_satzart.
    CASE /sie/hr_idp_s1sa-recty.
      WHEN 1 OR 5.
        IF screen-name CP '/SIE/HR_IDP_FELDER_TC*'.
          IF /sie/hr_idp_felder_tc-fldps EQ '001' OR
             tc_saf-lines < 2 OR
             g_700_satzart IS INITIAL.
            IF screen-name = '/SIE/HR_IDP_FELDER_TC-KZKEY'
            OR screen-name = '/SIE/HR_IDP_FELDER_TC-NOSEP'. "SIE001
            ELSE.
              screen-input = '0'.
            ENDIF.
          ENDIF.
        ENDIF.
      WHEN OTHERS.
        IF screen-name CP '/SIE/HR_IDP_FELDER_TC*'.
          IF /sie/hr_idp_felder_tc-fldps EQ '001' OR
             /sie/hr_idp_felder_tc-fldps EQ '002' OR
             tc_saf-lines < 3 OR
             g_700_satzart IS INITIAL.
            IF screen-name = '/SIE/HR_IDP_FELDER_TC-KZKEY'
            OR screen-name = '/SIE/HR_IDP_FELDER_TC-NOSEP'. "SIE001
            ELSE.
              screen-input = '0'.
            ENDIF.
          ENDIF.
        ENDIF.
    ENDCASE.

    IF ( screen-name = '/SIE/HR_IDP_FELDER_TC-KONVNAM' ) AND
       NOT ( /sie/hr_idp_felder_tc-feldname IS INITIAL ).
      SELECT SINGLE * FROM /sie/hr_idp_f1
               WHERE feldname = /sie/hr_idp_felder_tc-feldname.
      IF sy-subrc = 0.
        CASE /sie/hr_idp_f1-konvstrg.
          WHEN 2.
            screen-input = 0.
          WHEN 3.
            screen-active = 0.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDIF.


    IF screen-name = '/SIE/HR_IDP_FELDER_TC-FELDNAME'.
      IF /sie/hr_idp_felder_tc-feldname IS INITIAL.
      ELSE.
        screen-input = '0'.
      ENDIF.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " HIDE_KEYS_1006  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  HIDE_KEYS_SA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE hide_keys_sa OUTPUT.

  LOOP AT SCREEN.
    IF screen-name(24) = '/SIE/HR_IDP_SATZARTEN_TC'.
      IF /sie/hr_idp_satzarten_tc-recna IS INITIAL.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " HIDE_KEYS_SA  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  DEACTIVATE_FUNCTIONS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE deactivate_functions OUTPUT.

  LOOP AT SCREEN.
    CASE screen-name.
      WHEN 'L_DEL' OR 'L_NEW' OR 'L_PASTE' OR 'L_CUT' OR 'L_LNEW' OR
           'L_COPY' OR 'DEL_RECNAM' OR 'RECNA_CHANGED' OR
           'IC-SA_MM' OR 'IC-SA_M' OR 'IC-SA_P' OR 'IC-SA_PP' OR
           'IC-SAF_MM' OR 'IC-SAF_M' OR 'IC-SAF_P' OR 'IC-SAF_PP'
           OR 'COPY_RECNAM'.                                   "SIE005
        IF g_700_satzart IS INITIAL.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

    ENDCASE.
  ENDLOOP.

  IF g_700_satzart IS INITIAL.
    MESSAGE s147.
  ENDIF.
ENDMODULE.                 " DEACTIVATE_FUNCTIONS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  MODIFY_SA_SCREEN  INPUT
*&---------------------------------------------------------------------*
MODULE modify_sa_screen OUTPUT.

  LOOP AT SCREEN.
    CASE /sie/hr_idp_satzarten_tc-recty.
      WHEN 3.
        CASE screen-name.
          WHEN '/SIE/HR_IDP_SATZARTEN_TC-INFTY'.
            screen-input = 0.
            CLEAR /sie/hr_idp_satzarten_tc-infty.
            CLEAR /sie/hr_idp_satzarten_tc-ident_infty.
            MODIFY SCREEN.
          WHEN '/SIE/HR_IDP_SATZARTEN_TC-SUBTY'.
            screen-input = 0.
            CLEAR /sie/hr_idp_satzarten_tc-subty.
            CLEAR /sie/hr_idp_satzarten_tc-ident_subty.
            MODIFY SCREEN.
          WHEN '/SIE/HR_IDP_SATZARTEN_TC-OPERAN' OR
               '/SIE/HR_IDP_SATZARTEN_TC-OPERAT' OR
               '/SIE/HR_IDP_SATZARTEN_TC-OPEVAL' OR
               '/SIE/HR_IDP_SATZARTEN_TC-KZSPN'.
            screen-input = 1.
            MODIFY SCREEN.

          WHEN OTHERS.
        ENDCASE.
      WHEN 1 OR 5.
        CASE screen-name.
          WHEN '/SIE/HR_IDP_SATZARTEN_TC-INFTY'.
            screen-input = 0.
            CLEAR /sie/hr_idp_satzarten_tc-infty.
            CLEAR /sie/hr_idp_satzarten_tc-ident_infty.
            MODIFY SCREEN.
          WHEN '/SIE/HR_IDP_SATZARTEN_TC-SUBTY'.
            screen-input = 0.
            CLEAR /sie/hr_idp_satzarten_tc-subty.
            CLEAR /sie/hr_idp_satzarten_tc-ident_subty.
            MODIFY SCREEN.
          WHEN '/SIE/HR_IDP_SATZARTEN_TC-OPERAN' OR
               '/SIE/HR_IDP_SATZARTEN_TC-OPERAT' OR
               '/SIE/HR_IDP_SATZARTEN_TC-OPEVAL' OR
               '/SIE/HR_IDP_SATZARTEN_TC-KZSPN'.
            screen-input = 0.
            CLEAR /sie/hr_idp_satzarten_tc-subty.
            CLEAR /sie/hr_idp_satzarten_tc-ident_subty.
            MODIFY SCREEN.
          WHEN OTHERS.
        ENDCASE.

      WHEN 4.
        CASE screen-name.
          WHEN '/SIE/HR_IDP_SATZARTEN_TC-INFTY'.
            screen-input = 1.
            screen-required = 1.
            MODIFY SCREEN.
          WHEN '/SIE/HR_IDP_SATZARTEN_TC-SUBTY'.
            screen-input = 1.
            MODIFY SCREEN.
          WHEN '/SIE/HR_IDP_SATZARTEN_TC-OPERAN' OR
               '/SIE/HR_IDP_SATZARTEN_TC-OPERAT' OR
               '/SIE/HR_IDP_SATZARTEN_TC-OPEVAL' OR
               '/SIE/HR_IDP_SATZARTEN_TC-KZSPN'.
            screen-input = 1.
            MODIFY SCREEN.
          WHEN OTHERS.
        ENDCASE.

      WHEN OTHERS.

    ENDCASE.

  ENDLOOP.
ENDMODULE.                 " MODIFY_SA_SCREEN  INPUT

DATA: int_type TYPE c.
*&---------------------------------------------------------------------*
*&      Module  HIDE_PARAM  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE hide_param OUTPUT.

* Schlüsselangaben nur bei Deltalieferungen möglich
  LOOP AT SCREEN.
    CASE screen-name.
      WHEN '/SIE/HR_IDP_FELDER_TC-KZKEY'.
        IF g_ifdata_tran-s1df-delta = no.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.
  ENDLOOP.

* Parameter sind nur für Gebildete Begriffen nötig
  IF /sie/hr_idp_f1-dpftype >< 2.
    LOOP AT SCREEN.
      CHECK screen-name = '/SIE/HR_IDP_FELDER_TC-PARAM'.
      IF /sie/hr_idp_felder_tc-konvnam IS INITIAL.
        screen-input = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF /sie/hr_idp_f1-dpftype >< 2.
    LOOP AT SCREEN.
      CHECK screen-name = '/SIE/HR_IDP_FELDER_TC-PARAMGB'.
      IF /sie/hr_idp_felder_tc-paramgb IS INITIAL.
        screen-input = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

* Bei Initialzeilen sollte alles außer der Feldname eingabebereit
* sein?!
  IF /sie/hr_idp_felder_tc-feldname IS INITIAL.
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN '/SIE/HR_IDP_FELDER_TC-FELDNAME'.
        WHEN OTHERS.
          screen-input = '0'.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
  ENDIF.

* Gepackte Felder müssen eine Konvertierung haben
  CALL FUNCTION '/SIE/HR_IDP_GET_TYPE'
       EXPORTING
            logical_field  = /sie/hr_idp_felder_tc-feldname
       IMPORTING
            internal_type  = int_type
       EXCEPTIONS
            type_undefined = 1
            type_not_found = 2
            OTHERS         = 3.
  IF sy-subrc <> 0.
    int_type = space.
  ENDIF.

  IF int_type = 'P'.
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN '/SIE/HR_IDP_FELDER_TC-KONVNAM'.
          screen-required = '1'.
          MODIFY SCREEN.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
  ENDIF.


ENDMODULE.                 " HIDE_PARAM  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_KEYPOS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_keypos OUTPUT.
  IF g_itab_s1pg-keypos  = '001'.
    /sie/hr_idp_felder_tc-kzkey = yes.
  ENDIF.
ENDMODULE.                 " SET_KEYPOS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  HIDE_NOSEP  OUTPUT         SIE001
*&---------------------------------------------------------------------*
*       Eingabebereitschaft für NOSEP-Parameter steuern
*----------------------------------------------------------------------*
MODULE hide_nosep OUTPUT.

* NoSep nur bei CSV und nicht bei Schlüsselfeldern möglich
  LOOP AT SCREEN.
    CASE screen-name.
      WHEN '/SIE/HR_IDP_FELDER_TC-NOSEP'.

       IF /sie/hr_idp_felder_tc-kzkey = yes AND
          g_ifdata_tran-s1df-delta = yes.
          screen-input = '0'.
          MODIFY SCREEN.
       ENDIF.
       IF g_ifdata_tran-s1dl-fixfm <> '2'.
          screen-input = '0'.
          MODIFY SCREEN.
       ENDIF.
    ENDCASE.
  ENDLOOP.



ENDMODULE.                 " HIDE_NOSEP  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_FILTER_ICON  OUTPUT "SIE003
*&---------------------------------------------------------------------*

MODULE set_filter_icon OUTPUT.

* Prüfen ob mindestens eine Filterzeile vorhanden
  READ TABLE g_itab_s1pg-s1ps INDEX 1
                              TRANSPORTING NO FIELDS.
*                    with key IFCID = /sie/hr_idp_felder_tc-IFCID
*                             VRSNR = /sie/hr_idp_felder_tc-VRSNR
*                             RECNA = /sie/hr_idp_felder_tc-RECNA
*                             FLDPS = /sie/hr_idp_felder_tc-FLDPS.
  IF sy-subrc = 0.

*   Icon "Mehrfachselektion aktiviert" setzen
    /sie/hr_idp_felder_tc-icfilter = icon_display_more.

  ELSE.

*   Icon "Mehrfachselektion nicht aktiviert" setzen
    /sie/hr_idp_felder_tc-icfilter = icon_enter_more.

  ENDIF.

** Informationen zur Satzart holen
*  read table g_ifdata_tran-s1sa into /sie/hr_idp_s1sa
*                                with key recna = g_700_satzart.


* Filtermöglichkeit bei den ersten beiden Schlüsselfeldern
* Leerfeldern und Konstanten, sowie bei Header-/Trailersätzen
* unterdrücken
  LOOP AT SCREEN.

    IF screen-name = '/SIE/HR_IDP_FELDER_TC-ICFILTER'.

      IF /sie/hr_idp_felder_tc-fldps = '001'
      OR /sie/hr_idp_felder_tc-fldps = '002'
      OR /sie/hr_idp_felder_tc-feldname = c_constant
      OR /sie/hr_idp_felder_tc-feldname IS INITIAL
      OR (     /sie/hr_idp_s1sa-recty <> '3'
           AND /sie/hr_idp_s1sa-recty <> '4' ).

        screen-invisible = 1.
        screen-active = 0.
        MODIFY SCREEN.

      ENDIF.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " SET_FILTER_ICON OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_REFERENCE  OUTPUT "SIE002
*&---------------------------------------------------------------------*
MODULE set_reference OUTPUT.

  PERFORM set_reference_icon USING    g_ifdata_tran-s1dl-referenz
                             CHANGING l_reference.

ENDMODULE.                 " SET_REFERENCE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  modify_screen_1006  OUTPUT"SIE002
*&---------------------------------------------------------------------*
*&      Wenn Referenzschnittstelle angegeben wurde, dann alles auf
*&      nicht änderbar setzen
*&---------------------------------------------------------------------*
MODULE modify_screen_1006 OUTPUT.

 IF NOT g_ifdata_tran-s1dl-referenz IS INITIAL.
    LOOP AT SCREEN.
       IF screen-group1 = '001'.
          screen-input = '0'.
          MODIFY SCREEN.
       ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " modify_screen_1006  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_struc_felder_tc  OUTPUT                "SIE003
*&---------------------------------------------------------------------*

MODULE set_struc_felder_tc OUTPUT.

   MOVE-CORRESPONDING g_itab_s1pg TO /sie/hr_idp_felder_tc.

ENDMODULE.                 " set_struc_felder_tc  OUTPUT
