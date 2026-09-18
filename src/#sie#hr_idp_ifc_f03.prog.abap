*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_F03 .
*----------------------------------------------------------------------*

* Dieses Include beinhaltet form routinen zur OK Code Verwaltung

*&---------------------------------------------------------------------*
*&      Form  HANDLE_MAIN_OK_CODES
*&---------------------------------------------------------------------*
*       Dieses FORM zweigt in die verschiedenen Detailansichten
*       einer Schnittstelle.
*----------------------------------------------------------------------*
FORM handle_main_ok_codes.

  DATA: l_call_method TYPE ty_callm
      , l_call_screen TYPE sydynnr
      .

  DATA: answer(1)
      , rc LIKE sy-subrc
      .

* Setze die Aufrufart fest. Bei gleichen Ebenen wird SET SCREEN x
* und LEAVE SCREEN benutzt, ansonsten CALL SCREEN.
  CASE g_status_tran.
    WHEN c_1000_stat.
      l_call_method = c_cals_callm.
    WHEN OTHERS.
      l_call_method = c_sets_callm.
  ENDCASE.

* S1 als Kopf muß immer behandelt werden.
* Wohin geht der User?
  CASE svcode.

* Abspeichern
    WHEN c_save_code.
      PERFORM refresh_reference.                            "SIE002
      PERFORM eliminate_initial_lines.
      PERFORM check_db_consistency.                         "SIE003
      PERFORM ifc_save.
      CASE sy-tcode.
        WHEN c_new__tcod.
          LEAVE PROGRAM.
        WHEN OTHERS.
          SET SCREEN 0. LEAVE SCREEN.
      ENDCASE.

* Kopfdaten
    WHEN c_head_code.
      l_call_screen = c_head_dynp.
      PERFORM mux_check_authority USING c_1001_stat
                                  CHANGING rc.
      IF rc = 0.
        PERFORM call_screen USING l_call_screen l_call_method.
      ENDIF.

* Zeitliche Parameter
    WHEN c_time_code.
      l_call_screen = c_time_dynp.
      PERFORM mux_check_authority USING c_1005_stat
                                 CHANGING rc.
      IF rc = 0.
        PERFORM call_screen USING l_call_screen l_call_method.
      ENDIF.

* Program
    WHEN c_prog_code.
      l_call_screen = c_prog_dynp.
      PERFORM mux_check_authority USING c_1003_stat
                                 CHANGING rc.
      IF rc = 0.
        PERFORM call_screen USING l_call_screen l_call_method.
      ENDIF.
* Programvarianten
    WHEN c_vari_code.
      l_call_screen = c_vari_dynp.
      PERFORM mux_check_authority USING c_1002_stat
      CHANGING rc.
      IF rc = 0.
        PERFORM call_screen USING l_call_screen l_call_method.
      ENDIF.

* Schnittstellendefinition
    WHEN c_defi_code.
      l_call_screen = c_1006_dynp.
      PERFORM mux_check_authority USING c_1006_stat
      CHANGING rc.
      IF rc = 0.
        PERFORM call_screen USING l_call_screen l_call_method.
      ENDIF.

* Langtexte
    WHEN c_docu_code OR c_doc2_code OR c_doc3_code.
      PERFORM mux_check_authority USING c_docu_stat
      CHANGING rc.
      IF rc = 0.
        PERFORM handle_documentation.
      ENDIF.

    WHEN c_pric_code.
      l_call_screen = c_1007_dynp.
      PERFORM mux_check_authority USING c_1007_stat
                                  CHANGING rc.
      IF rc = 0.
        PERFORM call_screen USING l_call_screen l_call_method.
      ENDIF.

* Suchen nach Felder
    WHEN c_find_code.
      SUBMIT /sie/hr_idp_find_field AND RETURN VIA SELECTION-SCREEN.
      IMPORT feldsel FROM MEMORY ID '/SIE/HR_IDP_FELDER'.
      FREE MEMORY ID '/SIE/HR_IDP_FELDER'.

* Suchen nach Schnittstellen
    WHEN  c_ifcf_code.
      PERFORM handle_ifcf.

* Nicht freigegebene Version Löschen
    WHEN c_vdel_code.
      PERFORM vdel.

    WHEN 'CHECK'.

      PERFORM check_existance CHANGING rc.
      IF rc >< 0.
        MESSAGE s104.
      ELSE.
        PERFORM ifcid_check.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

  PERFORM handle_tc_navigation.
  PERFORM handle_lege_code.
  PERFORM handle_printing.

ENDFORM.                    " HANDLE_MAIN_OK_CODES

*---------------------------------------------------------------------*
*       FORM CALL_SCREEN                                              *
*---------------------------------------------------------------------*
*       Verzweigt in die verschiedenen Dynpros und unterscheidet      *
*       zwischen den Aufrufarten                                      *
*---------------------------------------------------------------------*
*  -->  L_CALL_SCREEN  In das zu verzweigende Dynpro                  *
*  -->  L_CALL_METHOD  Aufrufart                                      *
*---------------------------------------------------------------------*
FORM call_screen USING l_call_screen
                       l_call_method.
  CASE l_call_method.
    WHEN c_sets_callm.
      SET SCREEN l_call_screen. LEAVE SCREEN.
    WHEN c_cals_callm.
      CALL SCREEN l_call_screen.
    WHEN OTHERS.
*  do nothing
  ENDCASE.

ENDFORM.



*&---------------------------------------------------------------------*
*&      Form  PROCESS_OK_CODES_1000
*&---------------------------------------------------------------------*
*       Die OKCodes vom Dynpro 1000 werden hier behandelt. Vor der
*       eigentlichen Abspüngen wird allerdings noch der Datensatz
*       gesperrt und geschaut, ob eine Version ausgewählt wurde.
*----------------------------------------------------------------------*
FORM process_ok_codes_1000.

  DATA: rc LIKE sy-subrc
      .

  PERFORM check_version_selection.

* Behandlung von Head, Defi und Vari
  PERFORM handle_main_ok_codes.

  CASE svcode.
    WHEN c_tran_code.
* TODO Transportieren
    WHEN c_copy_code.
      CALL SCREEN 0600 STARTING AT 7 7.

* Version ziehen
    WHEN c_vers_code.
      PERFORM new_version.

    WHEN c_new__code.
      PERFORM check_existance CHANGING rc.
      IF rc = 0.
        MESSAGE s109 WITH g_ifdata_tran-s1-ifcid.
      ELSE.
        g_proc_vec-s1vn = yes.
        g_ifvers_type = c_inew_vers.
        g_ifcid_new = yes.
        CALL SCREEN c_head_dynp.
      ENDIF.
    WHEN c_catk_code.
      CALL FUNCTION 'RS_TASK_OVERVIEW'
           EXPORTING
                suppress_dialog  = space
                user             = sy-uname
           EXCEPTIONS
                suppress_message = 1
                OTHERS           = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.


    WHEN OTHERS.
* do nothing
  ENDCASE.

  PERFORM handle_lege_code.


ENDFORM.                    " PROCESS_OK_CODES_1000

*&---------------------------------------------------------------------*
*&      Form  PROCESS_OK_CODES_1001
*&---------------------------------------------------------------------*
*       Es werden die OK Codes vom Dynpro 1001 hier behandelt
*----------------------------------------------------------------------*
FORM process_ok_codes_1001.

  DATA: l_admin TYPE /sie/hr_idp_adm.

* Die Schnittstelle ist nicht mehr als NEU zu betrachten:
* (1) Sperren (2) Dynprofelder als nichteingabebereit setzten.
*perform enqueue.
*  g_ifcid_new = no.

  PERFORM handle_main_ok_codes.

  CASE svcode.
    WHEN c_admi_code.
      PERFORM find_last_change_1001 CHANGING l_admin.
      CALL FUNCTION '/SIE/HR_IDP_SHOW_ADMIN_INFO'
           EXPORTING
                admin = l_admin.
    WHEN OTHERS.
*     Do nothing.
  ENDCASE.

ENDFORM.                    " PROCESS_OK_CODES_1001

*&---------------------------------------------------------------------*
*&      Form  PROCESS_OK_CODES_1002
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM process_ok_codes_1002.

  DATA: l_admin TYPE /sie/hr_idp_adm.

  DATA: rc TYPE sysubrc.

  PERFORM handle_main_ok_codes.

  CASE svcode.
* Zeile löschen
    WHEN c_ldel_code.
      PERFORM delete_line.
* Info
    WHEN c_admi_code.
      SORT g_ifdata_tran-s1vt BY cr_datum DESCENDING
        cr_uzeit DESCENDING.
      READ TABLE g_ifdata_tran-s1vt INTO wa_tran_s1vt INDEX 1.
      MOVE-CORRESPONDING wa_tran_s1vt TO l_admin.
      CALL FUNCTION '/SIE/HR_IDP_SHOW_ADMIN_INFO'
           EXPORTING
                admin = l_admin.
    WHEN 'SELO'.    " Selektionsfelderauswahl

   DATA: tab_selection TYPE STANDARD TABLE OF /sie/hr_idp_f4_sel_fields
                                        INITIAL SIZE 0 WITH HEADER LINE
                               , tabix LIKE sy-tabix
                               .

      CLEAR tab_selection[].
      LOOP AT g_vardata.
        tab_selection-feldname = g_vardata-feldname.
        APPEND tab_selection.
      ENDLOOP.
      DELETE ADJACENT DUPLICATES FROM tab_selection.

      CALL FUNCTION '/SIE/HR_IDP_F4_TREE'
           EXPORTING
                grtyp           = '1'
           IMPORTING
                rc              = rc
           TABLES
                selected_fields = tab_selection.

      CHECK rc = 0.

      LOOP AT tab_selection.
        READ TABLE g_ifdata_tran-s1vt INTO /sie/hr_idp_s1vt
                    WITH KEY feldname = tab_selection-feldname.
        IF sy-subrc = 0.
*         no op.
        ELSE.
          CLEAR /sie/hr_idp_s1vt.
          /sie/hr_idp_s1vt-mandt = sy-mandt.
          /sie/hr_idp_s1vt-ifcid = g_ifdata_tran-s1-ifcid.
          /sie/hr_idp_s1vt-vrsnr = g_ifdata_vers.
          /sie/hr_idp_s1vt-feldname = tab_selection-feldname.
          /sie/hr_idp_s1vt-seqno = 1.
          APPEND /sie/hr_idp_s1vt TO g_ifdata_tran-s1vt.
        ENDIF.
      ENDLOOP.

      LOOP AT g_ifdata_tran-s1vt INTO /sie/hr_idp_s1vt.
        tabix = sy-tabix.
        READ TABLE tab_selection
             WITH KEY feldname = /sie/hr_idp_s1vt-feldname.
        IF sy-subrc = 0.
*         no op.
        ELSE.
*         Zeile ist zuviel.
          DELETE g_ifdata_tran-s1vt INDEX tabix.
        ENDIF.
      ENDLOOP.

    WHEN OTHERS.
*     Do nothing
  ENDCASE.
ENDFORM.                    " PROCESS_OK_CODES_1002

*&---------------------------------------------------------------------*
*&      Form  PROCESS_OK_CODES_1003
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_ok_codes_1003.
  DATA: l_admin TYPE /sie/hr_idp_adm
      , f(60)
      .

  PERFORM handle_main_ok_codes.
  CASE svcode.
    WHEN c_admi_code.
      MOVE-CORRESPONDING g_ifdata_tran-s1 TO l_admin.
      CALL FUNCTION '/SIE/HR_IDP_SHOW_ADMIN_INFO'
           EXPORTING
                admin = l_admin.
    WHEN 'PICK'.
      GET CURSOR FIELD f.
      CASE f.
        WHEN '/SIE/HR_IDP_S1DF-PROGR'.
          CHECK NOT ( g_ifdata_tran-s1df-progr IS INITIAL ).
          CALL FUNCTION 'RS_TOOL_ACCESS'
               EXPORTING
                    operation           = 'SHOW'
                    object_name         = g_ifdata_tran-s1df-progr
                    object_type         = 'P'
               EXCEPTIONS
                    not_executed        = 1
                    invalid_object_type = 2
                    OTHERS              = 3.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        WHEN '/SIE/HR_IDP_S1DF-VARIA'.
          CHECK NOT ( g_ifdata_tran-s1df-varia IS INITIAL ).
          CALL FUNCTION 'RS_VARIANT_DISPLAY'
               EXPORTING
                    report               = g_ifdata_tran-s1df-progr
                    variant              = g_ifdata_tran-s1df-varia
               EXCEPTIONS
                    no_report            = 1
                    report_not_existent  = 2
                    report_not_supplied  = 3
                    variant_not_existent = 4
                    variant_not_supplied = 5
                    variant_protected    = 6
                    OTHERS               = 7.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.

        WHEN OTHERS.
      ENDCASE.

    WHEN OTHERS.
*     Do nothing.
  ENDCASE.

ENDFORM.                    " PROCESS_OK_CODES_1003

*&---------------------------------------------------------------------*
*&      Form  PROCESS_OK_CODES_1003
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_ok_codes_1004.
  DATA: l_admin TYPE /sie/hr_idp_adm.

  PERFORM handle_main_ok_codes.

  CASE svcode.
    WHEN c_admi_code.
      PERFORM find_last_change_1004 CHANGING l_admin.
      CALL FUNCTION '/SIE/HR_IDP_SHOW_ADMIN_INFO'
           EXPORTING
                admin = l_admin.
    WHEN OTHERS.
*     Do nothing.
  ENDCASE.

ENDFORM.                    " PROCESS_OK_CODES_1003

*---------------------------------------------------------------------*
*       FORM PROCESS_OK_CODES_1005                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_ok_codes_1005.
  DATA: l_admin TYPE /sie/hr_idp_adm.

  PERFORM handle_main_ok_codes.

  CASE svcode.
    WHEN c_admi_code.
      MOVE-CORRESPONDING g_ifdata_tran-s1pr TO l_admin.
      CALL FUNCTION '/SIE/HR_IDP_SHOW_ADMIN_INFO'
           EXPORTING
                admin = l_admin.
    WHEN OTHERS.
*     Do nothing.
  ENDCASE.

ENDFORM.                    " PROCESS_OK_CODES_1003

*---------------------------------------------------------------------*
*       FORM PROCESS_OK_CODES_1006                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM process_ok_codes_1006.

  DATA: l_admin TYPE /sie/hr_idp_adm
      .

  PERFORM handle_main_ok_codes.

  CASE svcode.
    WHEN c_admi_code.
      PERFORM find_last_change_1006 CHANGING l_admin.
      CALL FUNCTION '/SIE/HR_IDP_SHOW_ADMIN_INFO'
           EXPORTING
                admin = l_admin.

    WHEN 'P--' OR 'P-' OR 'P+' OR 'P++' OR                  "#EC NOTEXT
         'SA_PMM' OR 'SA_PM' OR 'SA_PP' OR 'SA_PPP' OR      "#EC NOTEXT
         'SAF_PMM' OR 'SAF_PM' OR 'SAF_PP' OR 'SAF_PPP'.    "#EC NOTEXT
      PERFORM paging_2tc.

    WHEN 'R--' OR 'R-' OR 'R+' OR 'R++'.
      PERFORM page_recna.

    WHEN 'NEW_RECNAM'.                                      "#EC NOTEXT
      PERFORM create_recna.

    WHEN 'COPY_RECNAM'.                                     "SIE005
      PERFORM copy_recna.                                   "SIE005

    WHEN 'DEL_RECNAM'.                                      "#EC NOTEXT
      PERFORM del_recna.

    WHEN 'RECNA_CHANGED'.                                   "#EC NOTEXT
      PERFORM ren_recna.

    WHEN 'L_REFERENCE'.                                     "SIE002
      PERFORM modify_reference.                             "SIE002

    WHEN 'DOWNLOAD'.                                        "#EC NOTEXT
      CALL FUNCTION '/SIE/HR_IDP_IFC_SAVE'
           EXPORTING
                db_data  = g_ifdata_tran
           EXCEPTIONS
                no_iface = 1
                OTHERS   = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN 'UPLOAD'.                                          "#EC NOTEXT
      CALL FUNCTION '/SIE/HR_IDP_IFC_LOAD'
           CHANGING
                ifc_data = g_ifdata_tran.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " PROCESS_OK_CODES_1006

*---------------------------------------------------------------------*
*       FORM PROCESS_OK_CODES_1007                                    *
*---------------------------------------------------------------------*
*       Pricingmodell                                                 *
*---------------------------------------------------------------------*
FORM process_ok_codes_1007.

  DATA: l_admin TYPE /sie/hr_idp_adm
      .

  PERFORM handle_main_ok_codes.

  CASE svcode.
    WHEN c_admi_code.
      MOVE-CORRESPONDING /sie/hr_idp_s1pc TO l_admin.
      CALL FUNCTION '/SIE/HR_IDP_SHOW_ADMIN_INFO'
           EXPORTING
                admin = l_admin.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " PROCESS_OK_CODES_1006

*&---------------------------------------------------------------------*
*&      Form  CHECK_EXISTANCE
*&---------------------------------------------------------------------*
*       Prüft auf Existenz einer Schnittstelle
*----------------------------------------------------------------------*
FORM check_existance CHANGING p_rc LIKE sy-subrc.

  DATA: l_ifcid LIKE /sie/hr_idp_s1.

  l_ifcid = /sie/hr_idp_s1. CLEAR /sie/hr_idp_s1.
  SELECT SINGLE * FROM  /sie/hr_idp_s1
         WHERE  ifcid  = /sie/hr_idp_head-ifcid.
  IF sy-subrc = 0.
    p_rc = 0.
  ELSE.
    p_rc = 8.
  ENDIF.
  IF NOT ( l_ifcid IS INITIAL ).
    /sie/hr_idp_s1 = l_ifcid.
  ELSE.
*   do nothing.
  ENDIF.

ENDFORM.                    " CHECK_EXISTANCE

*&---------------------------------------------------------------------*
*&      Form  HANDLE_DOCUMENTATION
*&---------------------------------------------------------------------*
*       Diese Form Routine ruft den Langtexteditor auf
*----------------------------------------------------------------------*
FORM handle_documentation.

  DATA: answer(1)
      , rc LIKE sy-subrc
      .

  PERFORM check_existance CHANGING rc.
  IF ( rc >< 0 ) AND NOT ( sy-tcode = '/SIE/HR_IDP_IFC_NEW' ).
    MESSAGE s104.
  ELSE.
    rc = 0.
    CASE svcode.
      WHEN 'DOCU' OR 'DOCU2' OR 'DOCU3'.
        CASE sy-tcode.
*        when c_modi_tcod or c_new__tcod.    " Ändern oder Anlegen
* Ändern ist nur Eingabebereit, wenn das richtige Dynpro
* aufgerufen worden ist. m.E. ist es Dynpro 1000, im Moment halten
* wir es aber in Dynpros 1001-1004 offen.
*          case g_status_tran.
*            when c_1000_stat.
          WHEN '/SIE/HR_IDP_IFC_RELE' OR '/SIE/HR_IDP_IFC_RMOD' OR
               '/SIE/HR_IDP_IFC_CONF' OR '/SIE/HR_IDP_IFC_DISP'.
            CALL FUNCTION '/SIE/HR_IDP_S1LT_SHOW'
                 TABLES
                      i_s1lt = g_ifdata_tran-s1lt.

          WHEN OTHERS.
* Falls die aktuelle Schnittstelle freigegeben wurde, dann sollte
* die Dokumentation nur angezeigt werden können?
* if not ( g_ifdata_tran-s1vn-release_date is initial ).
         READ TABLE g_ifdata_tran-s1f INTO wa_s1f WITH KEY trole = '06'.
            IF NOT ( wa_s1f-ch_datum IS INITIAL ).
              PERFORM check_authority USING sy-tcode
                                         c_display
                                         g_ifdata_tran-s1-auth_class
                                         g_ifdata_tran-s1-ifcid
                                         'DOCU'
                        CHANGING rc.
              CALL FUNCTION '/SIE/HR_IDP_S1LT_SHOW'
                   TABLES
                        i_s1lt = g_ifdata_tran-s1lt.
            ELSE.
              PERFORM check_authority USING sy-tcode
                                         c_update
                                         g_ifdata_tran-s1-auth_class
                                         g_ifdata_tran-s1-ifcid
                                         'DOCU'
                        CHANGING rc.

              CALL FUNCTION '/SIE/HR_IDP_S1LT_EDIT'
                   EXPORTING
                        ifcid          = g_ifdata_tran-s1-ifcid
                   TABLES
                        i_s1lt         = g_ifdata_tran-s1lt
                   EXCEPTIONS
                        user_cancelled = 1
                        OTHERS         = 2.
              IF sy-subrc = 0.
                IF g_status_tran = '01'.
                  /sie/hr_idp_db_sel = g_proc_vec.
                  CALL FUNCTION '/SIE/HR_IDP_DB_CHECK'
                       EXPORTING
                            interface        = g_ifdata_tran-s1-ifcid
                            version          = g_ifdata_vers
                            transaction_data = g_ifdata_tran
                       CHANGING
                            dbsel            = /sie/hr_idp_db_sel.
                  IF NOT ( /sie/hr_idp_db_sel IS INITIAL ).
                    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
                         EXPORTING
                             defaultoption  = 'Y'
                  textline1      = 'Die Dokumentation wurde verändert.'
            textline2      = 'Möchten Sie die Dokumentation speichern?'
                   titel          = 'Die Dokumentation wurde verändert'
                             start_column   = 25
                             start_row      = 6
                        IMPORTING
                             answer         = answer
                              .
                    IF answer = 'J'.
                      PERFORM ifc_save.
                      CLEAR g_proc_vec.
                    ENDIF.
                    CLEAR g_proc_vec.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.

* Beim neu anlegen einer Schnittstelle simulieren wir, daß von der
* DB gelesen wurde.
            IF sy-tcode = c_new__tcod.
              DESCRIBE TABLE g_ifdata_tran-s1lt.
              IF sy-tfill >< 0.
                g_proc_vec-s1lt = yes.
              ENDIF.
            ENDIF.

        ENDCASE.
      WHEN OTHERS.                       " Default anzeigen
*        call function '/SIE/HR_IDP_S1LT_SHOW'
*             tables
*                  i_s1lt = g_ifdata_tran-s1lt.
    ENDCASE.
  ENDIF.
ENDFORM.                    " HANDLE_DOCUMENTATION

*&---------------------------------------------------------------------*
*&      Form  DELETE_LINE
*&---------------------------------------------------------------------*
FORM delete_line.
  CHECK sy-tcode NE '/SIE/HR_IDP_IFC_DISP'.
  IF NOT content IS INITIAL.
    DELETE g_ifdata_tran-s1vt WHERE mandt    = sy-mandt
                              AND   ifcid    = g_ifdata_tran-s1-ifcid
                              AND   vrsnr    = g_ifdata_vers
                              AND   feldname = content.
    IF sy-subrc EQ 0.
      MESSAGE s202 WITH content.
* Feld &1 wurde gelöscht.
    ENDIF.
  ELSE.
    MESSAGE s134.
  ENDIF.
*  if idx eq 0 or cursor_field eq 'G_VARDATA-IDENT'.
*    message s218.
* Bitte Cursor in ein Selektionsfeld setzen.
*  endif.
ENDFORM.                    " DELETE_LINE

*&---------------------------------------------------------------------*
*&      Form  ELIMINATE_INITIAL_LINES
*&---------------------------------------------------------------------*
*       Leerzeilen werden in der Datenbanktabelle nicht gespeichert
*----------------------------------------------------------------------*
FORM eliminate_initial_lines.
  LOOP AT g_ifdata_tran-s1vt INTO wa_tran_s1vt
                             WHERE ( feldname IS initial )
*<XFT>
* Änderung um nur nicht leere Selektionen zuzulassen
                             OR    ( ssign IS initial ).
*</XFT>
    DELETE g_ifdata_tran-s1vt INDEX sy-tabix.
  ENDLOOP.

  LOOP AT g_ifdata_tran-s1pg INTO wa_tran_s1pg
                             WHERE ( feldname IS initial ).
    DELETE g_ifdata_tran-s1pg INDEX sy-tabix.
  ENDLOOP.

ENDFORM.                    " ELIMINATE_INITIAL_LINES

*&---------------------------------------------------------------------*
*&      Form  HANDLE_TC_NAVIGATION
*&---------------------------------------------------------------------*
*       Prüft auf Navigation von Tablecontrols
*----------------------------------------------------------------------*
FORM handle_tc_navigation.
  CASE svcode.
* Table control navigation
    WHEN  c_pmm__code OR
          c_pm___code OR
          c_pp___code OR
          c_ppp__code.
      PERFORM paging USING svcode.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " HANDLE_TC_NAVIGATION

*---------------------------------------------------------------------*
*       FORM HANDLE_LEGE_CODE                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM handle_lege_code.

  CASE svcode.
    WHEN c_lege_code.

      CALL SCREEN 510 STARTING AT 30 5
                      ENDING   AT 90 10.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM HANDLE_PRINTING                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM handle_printing.

  DATA: it_rsparams TYPE STANDARD TABLE OF rsparams INITIAL SIZE 0
        WITH HEADER LINE.

  CASE svcode.
    WHEN '%PRI'.
      CLEAR it_rsparams[].
      it_rsparams-selname = 'S_IFCID'.
      it_rsparams-kind = 'S'.
      it_rsparams-sign = 'I'.
      it_rsparams-option = 'EQ'.
      it_rsparams-low = /sie/hr_idp_head-ifcid.
      it_rsparams-high = space.
      APPEND it_rsparams.
      it_rsparams-selname = 'S_VRSNR'.
      it_rsparams-kind = 'S'.
      it_rsparams-sign = 'I'.
      it_rsparams-option = 'EQ'.
      it_rsparams-low = /sie/hr_idp_head-vrsnr.
      it_rsparams-high = space.
      APPEND it_rsparams.

      SUBMIT /sie/hr_idp_print_interface
             VIA SELECTION-SCREEN
             WITH SELECTION-TABLE it_rsparams
             AND RETURN.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_VERSION_SELECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_version_selection.

  IF g_ifdata_vers IS INITIAL
     AND NOT ( g_ifdata_tran-s1-ifcid IS INITIAL ).
    CASE svcode.
      WHEN c_head_code OR c_prog_code OR c_vari_code OR c_defi_code
      OR   c_rele_code OR c_chan_code OR c_time_code OR c_pric_code.
        CLEAR okcode.
        MESSAGE s102.
        LEAVE SCREEN.
      WHEN OTHERS.
* do nothing.
    ENDCASE.
  ENDIF.

  IF g_ifdata_oldv >< g_ifdata_tran-s1-ifcid.
    CASE svcode.
      WHEN c_head_code OR c_prog_code OR c_vari_code OR c_defi_code
      OR   c_rele_code OR c_chan_code OR c_time_code OR c_pric_code.
        CLEAR okcode.

        g_ifdata_oldv = g_ifdata_tran-s1-ifcid.
        CALL FUNCTION '/SIE/HR_IDP_DB_INIT'.
        g_ifdata_tran-s1-ifcid = g_ifdata_oldv.

        MESSAGE s102.
        LEAVE SCREEN.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.

ENDFORM.                    " CHECK_VERSION_SELECTION

*&---------------------------------------------------------------------*
*&      Form  VDEL
*&---------------------------------------------------------------------*
*       Löscht die aktuelle, nicht freigegebene Version
*----------------------------------------------------------------------*
FORM vdel.

  DATA: l_version TYPE /sie/hr_idp_act_vers_nr
      , l_s1vn TYPE /sie/hr_idp_s1vn
      .

* Lese die aktuelle Version
  CALL FUNCTION '/SIE/HR_IDP_IFC_CURR_VERSION'
       EXPORTING
            interface = g_ifdata_tran-s1-ifcid
       IMPORTING
            version   = l_version.

* Prüfen, ob die aktuelle Version schon freigegeben wurde.
  CLEAR g_ifdata_1000.
  CALL FUNCTION '/SIE/HR_IDP_DB_READ_S1VN'
       EXPORTING
            interface      = g_ifdata_tran-s1-ifcid
       IMPORTING
            interface_data = g_ifdata_1000
       EXCEPTIONS
            no_data        = 1
            OTHERS         = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  READ TABLE g_ifdata_1000-s1vn INTO l_s1vn
                                WITH KEY vrsnr = l_version.

* if l_s1vn-release_date is initial.
  READ TABLE g_ifdata_1000-s1f INTO wa_s1f WITH KEY trole = '06'
                                                    vrsnr = l_version.
  IF wa_s1f-ch_datum IS INITIAL.

    DELETE FROM /sie/hr_idp_s1df WHERE ifcid = g_ifdata_tran-s1-ifcid
                                 AND   vrsnr = l_version.
    DELETE FROM /sie/hr_idp_s1pg WHERE ifcid = g_ifdata_tran-s1-ifcid
                                 AND      vrsnr = l_version.
*   SIE003_BEG
    DELETE FROM /sie/hr_idp_s1ps WHERE ifcid = g_ifdata_tran-s1-ifcid
                                 AND      vrsnr = l_version.
*   SIE003_END
    DELETE FROM /sie/hr_idp_s1r WHERE ifcid = g_ifdata_tran-s1-ifcid
                                AND         vrsnr = l_version.
    DELETE FROM /sie/hr_idp_s1vt WHERE ifcid = g_ifdata_tran-s1-ifcid
                                     AND    vrsnr = l_version.
    DELETE FROM /sie/hr_idp_s1dl WHERE ifcid = g_ifdata_tran-s1-ifcid
                                     AND    vrsnr = l_version.
    DELETE FROM /sie/hr_idp_s1vn WHERE ifcid = g_ifdata_tran-s1-ifcid
                                  AND       vrsnr = l_version.
    DELETE FROM /sie/hr_idp_s1pc WHERE ifcid = g_ifdata_tran-s1-ifcid
                                  AND       vrsnr = l_version.
    DELETE FROM /sie/hr_idp_s1sa WHERE ifcid = g_ifdata_tran-s1-ifcid
                                  AND       vrsnr = l_version.

* Es können zwei Möglichkeiten auftreten. Wenn die aktuelle Version
* 0001 ist, dann sollte die komplette Schnittstelle gelöscht werden,
* ansonsten dürfen nur die Versionsabhängige Tabellen gelöscht
* werden.
    IF l_version = '0001'.
      DELETE FROM /sie/hr_idp_s1 WHERE ifcid = g_ifdata_tran-s1-ifcid.
      DELETE FROM /sie/hr_idp_s1t WHERE ifcid = g_ifdata_tran-s1-ifcid.
      DELETE FROM /sie/hr_idp_s1lt WHERE ifcid = g_ifdata_tran-s1-ifcid.
* Lösche set/get Parameter!
      SET PARAMETER ID '/SIE/HR_IDP_IFCID' FIELD space.
    ELSE.
* Die aktuelle Version muß in der S1 noch gesetzt werden.

      l_version = l_version - 1.
      SELECT SINGLE FOR UPDATE *
                      FROM /sie/hr_idp_s1
                      WHERE ifcid = g_ifdata_tran-s1-ifcid.
      /sie/hr_idp_s1-act_vers_nr = l_version.
      MODIFY /sie/hr_idp_s1.
    ENDIF.

* Die Transaktion initialisieren.
    CLEAR g_ifdata_tran.
    CLEAR g_proc_vec.
    CLEAR g_ifdata_vers.

    CALL FUNCTION '/SIE/HR_IDP_DB_INIT'
              .

  ELSE.
    MESSAGE s113.
  ENDIF.

ENDFORM.                    " VDEL

*&---------------------------------------------------------------------*
*&      Form  HANDLE_IFCF
*&---------------------------------------------------------------------*
FORM handle_ifcf.
  CASE svcode.
    WHEN c_ifcf_code.
      SUBMIT /sie/hr_idp_find_ifc AND RETURN VIA SELECTION-SCREEN.
  ENDCASE.
ENDFORM.                    " HANDLE_IFCF

*&---------------------------------------------------------------------*
*&      Form  PAGING_2TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM paging_2tc.

  DATA: l_flag TYPE ty_yesno
      , l_tc TYPE ty_yesno
      .

  FIELD-SYMBOLS: <c> TYPE cxtab_control.

  l_flag = no.
  CASE svcode.
    WHEN 'SA_PMM'. l_tc = no. svcode = 'P--'. l_flag = yes.
    WHEN 'SA_PM'. l_tc = no. svcode = 'P-'. l_flag = yes.
    WHEN 'SA_PP'. l_tc = no. svcode = 'P+'. l_flag = yes.
    WHEN 'SA_PPP'. l_tc = no. svcode = 'P++'. l_flag = yes.
    WHEN 'SAF_PMM'. l_tc = yes. svcode = 'P--'. l_flag = yes.
    WHEN 'SAF_PM'. l_tc = yes. svcode = 'P-'. l_flag = yes.
    WHEN 'SAF_PP'. l_tc = yes. svcode = 'P+'. l_flag = yes.
    WHEN 'SAF_PPP'. l_tc = yes. svcode = 'P++'. l_flag = yes.
    WHEN OTHERS.
  ENDCASE.

  IF  l_flag = yes.
    CASE l_tc.
      WHEN yes.
        DESCRIBE TABLE g_itab_s1pg LINES step_lines.
        ASSIGN tc_saf TO <c>.
      WHEN no.
        DESCRIBE TABLE g_itab_sa LINES step_lines.
        ASSIGN tc_sa TO <c>.
      WHEN OTHERS.
    ENDCASE.

    CALL FUNCTION 'SCROLLING_IN_TABLE'
         EXPORTING
              ok_code     = svcode
              entry_act   = <c>-top_line
              entry_to    = <c>-lines
              loops       = step_lines
              overlapping = yes
         IMPORTING
              entry_new   = <c>-top_line
         EXCEPTIONS
              OTHERS      = 1.
    IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

ENDFORM.                    " PAGING_2TC
