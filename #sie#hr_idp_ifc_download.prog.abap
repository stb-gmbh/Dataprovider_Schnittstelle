*&---------------------------------------------------------------------*
*& Report  /SIE/HR_IDP_IFC_DOWNLOAD                                    *
*&                                                                     *
*&---------------------------------------------------------------------*
*& Download von Schnittstellen in einem XML Format ins Präsentations-  *
*& Server/Frontend PC.                                                 *
*&---------------------------------------------------------------------*

REPORT  /sie/hr_idp_ifc_download MESSAGE-ID /sie/hr_idp_messages.      .

TABLES: /sie/hr_idp_s1
      , /sie/hr_idp_s1vn
      .

INCLUDE /sie/hr_idp_types.

TYPES: BEGIN OF s_data
     , text(1000)
     , END OF s_data
     , t_data TYPE STANDARD TABLE OF s_data INITIAL SIZE 0
     .

DATA: gt_s1vn TYPE STANDARD TABLE OF /sie/hr_idp_s1vn INITIAL SIZE 0
    , wa_s1vn TYPE /sie/hr_idp_s1vn
    , db_data TYPE /sie/hr_idp_ifc_db
    , gt_buffer TYPE t_data
    , gs_buffer TYPE s_data
    , gt_file TYPE t_data
    , gs_file TYPE s_data
    , g_proc_vec TYPE ty_tablix
    , sapdpversion(20) TYPE c
    , vrsnr_ok TYPE ty_yesno
    , s TYPE i
    .

FIELD-SYMBOLS: <fs>.

DATA:    current_version TYPE /sie/hr_idp_vers_nr
       , current_released_version TYPE /sie/hr_idp_vers_nr
       , current_accepted_version TYPE /sie/hr_idp_vers_nr
       .

DATA: fl_data TYPE ty_yesno.

SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE text-s00.
SELECT-OPTIONS: so_ifcid FOR /sie/hr_idp_s1-ifcid
*             , so_vrsnr for /sie/hr_idp_s1vn-vrsnr
              .

PARAMETERS:  p_inarb AS CHECKBOX
          , p_relea AS CHECKBOX DEFAULT yes
          , p_accep AS CHECKBOX DEFAULT yes
          , p_all AS CHECKBOX DEFAULT no
          .


SELECTION-SCREEN END OF BLOCK sel.

SELECTION-SCREEN BEGIN OF BLOCK sel2 WITH FRAME TITLE text-s01.
PARAMETER: filename LIKE rlgrap-filename.
SELECTION-SCREEN END OF BLOCK sel2.

INITIALIZATION.
  IF filename IS INITIAL.

    CALL FUNCTION 'WS_ULDL_PATH'
      IMPORTING
        download_path = filename.

    CONCATENATE filename
               'Interfaces'
                sy-sysid
                sy-mandt
                '.xml'
    INTO filename.
  ENDIF.

START-OF-SELECTION.
  fl_data = no.
  SELECT * FROM /sie/hr_idp_s1vn INTO TABLE gt_s1vn
                                 WHERE ifcid IN so_ifcid
                                 ORDER BY PRIMARY KEY.
*                                and   vrsnr in so_vrsnr.

  CLEAR gt_file[].

  LOOP AT gt_s1vn INTO wa_s1vn.
    AT NEW ifcid.
      CALL FUNCTION '/SIE/HR_IDP_DB_INIT'.
    ENDAT.

* Versionen die nicht interessieren herausfiltern
    vrsnr_ok = no.
    CALL FUNCTION '/SIE/HR_IDP_RELEASE_INFO'
      EXPORTING
        interface_id             = wa_s1vn-ifcid
        version                  = wa_s1vn-vrsnr
      IMPORTING
        current_version          = current_version
        current_released_version = current_released_version
        current_accepted_version = current_accepted_version.

    IF wa_s1vn-vrsnr > current_version.
      IF p_inarb = yes.
        vrsnr_ok = yes.
      ENDIF.
    ENDIF.

    IF wa_s1vn-vrsnr = current_released_version.
      IF p_relea = yes.
        vrsnr_ok = yes.
      ENDIF.
    ENDIF.

    IF wa_s1vn-vrsnr = current_accepted_version.
      IF p_accep = yes.
        vrsnr_ok = yes.
      ENDIF.
    ENDIF.

    IF p_all = yes.
      vrsnr_ok = yes.
    ENDIF.

    CHECK vrsnr_ok = yes.

    fl_data = yes.

    g_proc_vec = c_all_tabl.

    CALL FUNCTION '/SIE/HR_IDP_DB_READ'
      EXPORTING
        interface        = wa_s1vn-ifcid
        version          = wa_s1vn-vrsnr
      CHANGING
        transaction_data = db_data
        dbsel            = g_proc_vec.

    CLEAR gt_buffer[].

    CHECK g_proc_vec-s1 = yes.

    IF db_data-s1-ifcid IS INITIAL.
    ENDIF.

    CALL FUNCTION '/SIE/HR_IDP_WRITE_TO_XML'
      EXPORTING
        db_data     = db_data
        fl_envelope = space
      TABLES
        xml_data    = gt_buffer.

    APPEND LINES OF gt_buffer TO gt_file.

  ENDLOOP.

  IF ( fl_data IS INITIAL ).
    MESSAGE w002.
  ELSE.

    CALL FUNCTION '/SIE/HR_IDP_IFC_VERSION'
      IMPORTING
        version = sapdpversion.

    gs_buffer = text-001.
    INSERT gs_buffer INTO gt_file INDEX 1.

    CONCATENATE '<sap_dp'
                '>'
    INTO gs_buffer.
    INSERT gs_buffer INTO gt_file INDEX 2.

    gs_buffer-text = '</sap_dp>'.
    APPEND gs_buffer TO gt_file.

    DATA: l_filename TYPE string.

    l_filename = filename.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = l_filename
        append                  = space " Überschreiben
        codepage                = '4110'                    "#EC NOTEXT
      CHANGING
        data_tab                = gt_file[]
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.
