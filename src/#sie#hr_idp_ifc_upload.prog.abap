*&---------------------------------------------------------------------*
*& Report  /SIE/HR_IDP_IFC_UPLOAD                                      *
*&                                                                     *
*&---------------------------------------------------------------------*
*& Upload von Schnittstellen in einem XML Format vom Präsentations-    *
*& Server/Frontend PC.                                                 *
*&---------------------------------------------------------------------*

REPORT  /sie/hr_idp_ifc_upload MESSAGE-ID /sie/hr_idp_messages.

TABLES: /sie/hr_idp_s1
      , /sie/hr_idp_s1vn
      .

INCLUDE /sie/hr_idp_types.
INCLUDE /sie/hr_idp_xml_types.
INCLUDE <icon>.

TYPES: BEGIN OF s_data
     , text(1000)
     , END OF s_data
     , t_data TYPE STANDARD TABLE OF s_data INITIAL SIZE 0
     .

DATA:  db_data TYPE /sie/hr_idp_ifc_db
    , t_db_data TYPE /sie/hr_idp_tt_ifc
    , gt_buffer TYPE t_data
    , gs_buffer TYPE s_data
    , gt_file TYPE t_data
    , gs_file TYPE s_data
    , g_proc_vec TYPE ty_tablix
    , sapdpversion(20) TYPE c
    , vrsnr_ok TYPE ty_yesno
    , found TYPE ty_yesno
    , mark TYPE ty_yesno
    , silent TYPE c
    , g_ifcid TYPE /sie/hr_idp_interface_id
    , g_vrsnr TYPE /sie/hr_idp_vers_nr
    .

DATA: gt_xml TYPE t_data
    , gs_xml TYPE s_data
    , ifc_xml TYPE t_data
    , lt_buffer TYPE t_xml_file
    , ls_buffer TYPE s_xml_file
    .

DATA: t_attributes TYPE /sie/hr_idp_tt_attributes
    , s_attributes TYPE /sie/hr_idp_pairs
    , s_attribute TYPE /sie/hr_idp_pair
    .

TYPES: BEGIN OF s_ifcid
     , ifcid TYPE /sie/hr_idp_interface_id
     , vrsnr TYPE /sie/hr_idp_vers_nr
     , END OF s_ifcid
     , t_ifcid TYPE STANDARD TABLE OF s_ifcid INITIAL SIZE 0
     .

DATA: gs_ifcid TYPE s_ifcid
    , gt_ifcid TYPE t_ifcid
    .

SELECTION-SCREEN BEGIN OF BLOCK sel2 WITH FRAME TITLE text-s01.
PARAMETER: filename LIKE rlgrap-filename.
SELECTION-SCREEN END OF BLOCK sel2.

INITIALIZATION.

  IF filename IS INITIAL.
    CALL FUNCTION 'WS_ULDL_PATH'
      IMPORTING
        upload_path = filename.

  ENDIF.

START-OF-SELECTION.
  DATA: l_filename TYPE string,
        lit_file   TYPE filetable,
        l_subrc    TYPE sysubrc.

  SET PF-STATUS 'LIST'.

  IF NOT ( filename IS INITIAL ).
*    SILENT = 'S'.
    l_filename = filename. "aha001
  ELSE.
*    SILENT = SPACE.
    CALL METHOD cl_gui_frontend_services=>file_open_dialog
      CHANGING
        file_table              = lit_file
        rc                      = l_subrc
      EXCEPTIONS
        file_open_dialog_failed = 1
        cntl_error              = 2
        error_no_gui            = 3
        not_supported_by_gui    = 4
        OTHERS                  = 5.
    IF sy-subrc <> 0
    OR lit_file IS INITIAL.
      STOP.
    ENDIF.

    READ TABLE lit_file INDEX 1 INTO l_filename.

  ENDIF.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = l_filename
      codepage                = '4110'                      "#EC NOTEXT
    CHANGING
      data_tab                = gt_file[]
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Translate escape characters
*  perform translate_escape.

* Tags die nicht interessieren herausfiltern
  PERFORM get_tag_org  TABLES gt_file
                          gt_xml
                  USING 'sap_dp'.                           "#EC NOTEXT

  LOOP AT gt_xml INTO gs_xml.

    IF gs_xml CS '<interface>'.                            "#EC NOTEXT.
      CLEAR: db_data, ifc_xml[].
      found = yes.
      CONTINUE.
    ENDIF.

    IF gs_xml CS '</interface>'.                            "#EC NOTEXT
      found = no.

      CALL FUNCTION '/SIE/HR_IDP_READ_FROM_XML'
        IMPORTING
          ifc_data = db_data
        TABLES
          xml_data = ifc_xml.

      mark = yes.
      g_ifcid = db_data-s1-ifcid.
      g_vrsnr = db_data-s1vn-vrsnr.

      READ TABLE gt_ifcid INTO gs_ifcid
                          WITH KEY ifcid = g_ifcid.
      IF sy-subrc = 0.
        IF gs_ifcid-vrsnr < db_data-s1vn-vrsnr.
          gs_ifcid-vrsnr =  db_data-s1vn-vrsnr.
          MODIFY gt_ifcid FROM gs_ifcid INDEX sy-tabix.

          gs_ifcid-ifcid = g_ifcid.
          gs_ifcid-vrsnr = g_vrsnr.
          APPEND gs_ifcid TO gt_ifcid.

          DELETE t_db_data WHERE s1-ifcid = g_ifcid.
          APPEND db_data TO t_db_data.
          CONTINUE.
        ELSE.
* ignore this version
        ENDIF.
      ELSE.

        gs_ifcid-ifcid = g_ifcid.
        gs_ifcid-vrsnr = g_vrsnr.
        APPEND gs_ifcid TO gt_ifcid.

        APPEND db_data TO t_db_data.
        CONTINUE.

      ENDIF.
    ENDIF.

    IF found = yes.
      APPEND gs_xml TO ifc_xml.
    ENDIF.

  ENDLOOP.

  LOOP AT t_db_data INTO db_data.
    g_ifcid = db_data-s1-ifcid.
    g_vrsnr = db_data-s1vn-vrsnr.

    WRITE: / mark AS CHECKBOX,
             db_data-s1-ifcid,
             db_data-s1t-ident,
             db_data-s1vn-vrsnr.

    HIDE: g_ifcid,
          g_vrsnr.

  ENDLOOP.

AT USER-COMMAND.
  PERFORM user_command.

  INCLUDE /sie/hr_idp_tags.

**---------------------------------------------------------------------*
**       FORM TRANSLATE_ESCAPE                                         *
**---------------------------------------------------------------------*
*FORM TRANSLATE_ESCAPE.
*  LOOP AT GT_FILE INTO GS_FILE.
*
*    DO.
*     IF GS_FILE CS '&amp;'.                                 "#EC NOTEXT
*       REPLACE '&amp;' WITH '&' INTO GS_FILE.               "#EC NOTEXT
*        MODIFY GT_FILE FROM GS_FILE.
*      ELSE.
*        EXIT.
*      ENDIF.
*    ENDDO.
*
*    DO.
*      IF GS_FILE CS '&#xA0;'.
*        REPLACE '&#xA0;' WITH SPACE INTO GS_FILE.
*        MODIFY GT_FILE FROM GS_FILE.
*      ELSE.
*        EXIT.
*      ENDIF.
*    ENDDO.
*
*  ENDLOOP.
*
*ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_S1F
*&---------------------------------------------------------------------*
FORM fill_s1f.
  DATA: wa_s1f TYPE /sie/hr_idp_s1f.
  wa_s1f-ifcid = db_data-s1-ifcid.
  wa_s1f-vrsnr = db_data-s1df-vrsnr.
  wa_s1f-trole = '06'.                                      "#EC NOTEXT
  APPEND wa_s1f TO db_data-s1f.
  wa_s1f-trole = '07'.                                      "#EC NOTEXT
  APPEND wa_s1f TO db_data-s1f.
ENDFORM.                                                    " FILL_S1F

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
FORM user_command.
  CASE sy-ucomm.
    WHEN 'MARK'.                                            "#EC NOTEXT
      PERFORM set_multi_selection USING yes.
    WHEN 'DMAR'.                                            "#EC NOTEXT
      PERFORM set_multi_selection USING no.
    WHEN 'UPLO'.                                            "#EC NOTEXT
      PERFORM commit_db.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " USER_COMMAND

*---------------------------------------------------------------------*
*       FORM SET_MULTI_SELECTION                                      *
*---------------------------------------------------------------------*
FORM set_multi_selection USING p_bool.

  DO.
    READ LINE sy-index FIELD VALUE mark.
    IF sy-subrc NE 0. EXIT. ENDIF.
    MODIFY CURRENT LINE FIELD VALUE mark FROM p_bool.
  ENDDO.

ENDFORM.                    "SET_MULTI_SELECTION

*---------------------------------------------------------------------*
*       FORM COMMIT_DB                                                *
*---------------------------------------------------------------------*
FORM commit_db.

  DATA: proc_vec TYPE ty_tablix VALUE c_all_tabl.

  CLEAR: mark, g_ifcid, g_vrsnr.

  DO.
    READ LINE sy-index FIELD VALUE g_ifcid g_vrsnr mark.
    IF sy-subrc NE 0. EXIT. ENDIF.
    IF mark = yes.
      READ TABLE t_db_data INTO db_data WITH KEY s1-ifcid = g_ifcid.
      IF sy-subrc = 0.
* Schnelle Prüfung ob die Schnittstelle schon existiert.
        SELECT SINGLE * FROM /sie/hr_idp_s1 WHERE ifcid = db_data-s1-ifcid.
        IF sy-subrc = 0.
          WRITE: / icon_red_light,
                   ' Die Schnittstelle ',
                   db_data-s1-ifcid,
                   ' ist in diesem System schon vorhanden'.
        ELSE.
          CALL FUNCTION '/SIE/HR_IDP_DB_INIT'.

          PERFORM fill_s1f.
          PERFORM transform_data.

          CALL FUNCTION '/SIE/HR_IDP_DB_UPDATE'
            EXPORTING
              interface        = db_data-s1-ifcid
              version          = db_data-s1df-vrsnr
              sw_commit_work   = yes
            CHANGING
              transaction_data = db_data
              dbsel            = proc_vec.
          IF proc_vec >< c_all_tabl.
            WRITE: / icon_red_light,
                     'Fehler beim schreiben der Schnittstelle ',
                     db_data-s1-ifcid.
          ELSE.
            WRITE: / icon_green_light,
                     'Die Schnittstelle ',
                     db_data-s1-ifcid,
                     ' wurde erfolgreich importiert'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDDO.
ENDFORM.                    "COMMIT_DB

*&---------------------------------------------------------------------*
*&      Form  TRANSFORM_DATA
*&---------------------------------------------------------------------*
FORM transform_data.

  db_data-s1-act_vers_nr = '0000'.
  db_data-s1vn-vrsnr = '0001'.

ENDFORM.                    " TRANSFORM_DATA
