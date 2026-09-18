*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_ALERT_F01                                  *
*----------------------------------------------------------------------*

FORM notify_user TABLES
                   contents_txt STRUCTURE solisti1
                   receivers STRUCTURE somlreci1
                 USING VALUE(ext_mail_adr_bcc) TYPE c.

  DATA document_data TYPE sodocchgi1.
  DATA packing_list  TYPE STANDARD TABLE OF sopcklsti1 WITH HEADER LINE.
  DATA object_header TYPE STANDARD TABLE OF solisti1   WITH HEADER LINE.
  DATA contents_bin  TYPE STANDARD TABLE OF solisti1   WITH HEADER LINE.

  DATA object_para   TYPE STANDARD TABLE OF soparai1   WITH HEADER LINE.
  DATA object_parb   TYPE STANDARD TABLE OF soparbi1   WITH HEADER LINE.
* data receivers     type standard table of somlreci1  with header line.
  DATA receivers_h   TYPE STANDARD TABLE OF char256    WITH HEADER LINE.
  DATA std_text_data TYPE STANDARD TABLE OF tline      WITH HEADER LINE.

  DATA user_address TYPE addr3_val.
  DATA txt_name     TYPE thead-tdname.
  DATA line_no      TYPE i.
  DATA sender       LIKE soextreci1-receiver.

  DESCRIBE TABLE contents_txt LINES line_no.

* Kopfsatz füllen *
  document_data-obj_name  = 'USER-TOOL'.
  CONCATENATE 'SAP DP Schnittstelle'(012)
              gt_interfaces-ifcid
              'Gültigkeitsende'(013)
              INTO document_data-obj_descr
              SEPARATED BY space.
  document_data-doc_size  =  line_no * 255.

* Packing list aufbauen *
  packing_list-head_start =  1.
  packing_list-head_num   =  0.
  packing_list-body_start =  1.
  packing_list-body_num   =  line_no.
  packing_list-doc_type   = 'RAW'.
  APPEND packing_list.

* Senden des Dokuments mit Hilfe von SAPoffice *
  CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
    EXPORTING
      document_data              = document_data
      sender_address             = von
      sender_address_type        = 'INT'
    TABLES
      packing_list               = packing_list
      object_header              = object_header
      contents_bin               = contents_bin
      contents_txt               = contents_txt
      object_para                = object_para
      object_parb                = object_parb
      receivers                  = receivers
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.

* Erfolgreiche Auführung überprüfen *
  IF NOT sy-subrc = 0.
    READ TABLE receivers INDEX 1.
    MESSAGE e024 WITH receivers-receiver.
    EXIT.
  ELSE.
    MESSAGE s005 WITH 'Versand erfolgt.'(003).
  ENDIF.

  LOOP AT receivers WHERE NOT retrn_code = 0.               "#EC *
    READ TABLE receivers INDEX 1.
    MESSAGE e024 WITH receivers-receiver.
    EXIT.
  ENDLOOP.

* DB Aktualisieren *
  COMMIT WORK.

ENDFORM.                               " NOTIFY_USER

*&---------------------------------------------------------------------*
*&      Form  CREATE_CONTENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_INTERFACES_IFCID  text
*      -->P_GT_INTERFACES_ENDDA  text
*      <--P_CONTENTS  text
*----------------------------------------------------------------------*
FORM create_content TABLES contents STRUCTURE solisti1.

  DATA:
    formlang   LIKE thead-tdspras,
    orglang(1).

  CONSTANTS:
    true(1)  VALUE 'X',
    false(1) VALUE ' '.

  formlang  =  spras.
  orglang   =  'D'.
  DATA:
    header     LIKE thead,                        "...textheader
    formheader LIKE itcta,                        "...formheader
    options    LIKE itcpo,                        "...print-options
    result     LIKE itcpp.                        "...print-results

  DATA:
    lines      LIKE tline OCCURS 0 WITH HEADER LINE,
    lines1     LIKE tline OCCURS 6 WITH HEADER LINE,
    lines2     LIKE tline OCCURS 6 WITH HEADER LINE,
    selections LIKE thead OCCURS 0 WITH HEADER LINE,
    otf        LIKE itcoo OCCURS 0 WITH HEADER LINE.

  options-tdgetotf = true.
  options-tddest = 'LOCL'.                                  "#EC NOTEXT

  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      dialog             = space
      options            = options
      raw_data_interface = space
    EXCEPTIONS
      OTHERS             = 1.
  IF sy-subrc >< 0.
    WRITE: / 'Fehler beim öffnen des Formulares!'(010).
    CLEAR otf[].
  ELSE.

    PERFORM print_form USING formlang.

    CALL FUNCTION 'CLOSE_FORM'
      IMPORTING
        result  = result
      TABLES
        otfdata = otf
      EXCEPTIONS
        OTHERS  = 4.
    IF sy-subrc <> 0.
    ENDIF.

    CALL FUNCTION 'CONVERT_OTF'
      EXPORTING
        format                = 'ASCII'
        max_linewidth         = 132
      TABLES
        otf                   = otf
        lines                 = contents
      EXCEPTIONS
        err_max_linewidth     = 1
        err_format            = 2
        err_conv_not_possible = 3
        OTHERS                = 4.

    LOOP AT contents.
      SHIFT contents BY 2 PLACES.
      MODIFY contents.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " CREATE_CONTENT

*&---------------------------------------------------------------------*
*&      Form  PRINT_FORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FORMLANG  text
*----------------------------------------------------------------------*
FORM print_form USING p_formlang.

  PERFORM read_form_text_elements TABLES   text_element_tab
                                  USING    form
                                  CHANGING subrc.

  CALL FUNCTION 'START_FORM'
    EXPORTING
      form   = form
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc <> 0.
  ENDIF.

* HEADER
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'HEADER'
    EXCEPTIONS
      OTHERS  = 1.

* SELECTIONS
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'SELECTIONS'
    EXCEPTIONS
      OTHERS  = 1.

* SELECTION_LINE
  LOOP AT selections.
    CLEAR: /sie/hr_idp_ifc_validity_mail-ssign
        ,  /sie/hr_idp_ifc_validity_mail-sopti
        ,  /sie/hr_idp_ifc_validity_mail-sllow
        ,  /sie/hr_idp_ifc_validity_mail-shigh
        ,  /sie/hr_idp_ifc_validity_mail-feldname_ident
        .

    MOVE selections-feldname TO /sie/hr_idp_ifc_validity_mail-feldname.

    SELECT SINGLE * FROM /sie/hr_idp_f1t
                    WHERE feldname = selections-feldname
                    AND   spras    = sy-langu.
    IF sy-subrc = 0.
      /sie/hr_idp_ifc_validity_mail-feldname_ident = /sie/hr_idp_f1t-ident.
    ELSE.
      CLEAR /sie/hr_idp_ifc_validity_mail-feldname_ident.
    ENDIF.

    MOVE selections-ssign TO /sie/hr_idp_ifc_validity_mail-ssign.
    MOVE selections-sopti TO /sie/hr_idp_ifc_validity_mail-sopti.
    MOVE selections-sllow TO /sie/hr_idp_ifc_validity_mail-sllow.
    MOVE selections-shigh TO /sie/hr_idp_ifc_validity_mail-shigh.

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'SELECTION_LINE'
      EXCEPTIONS
        OTHERS  = 1.

  ENDLOOP.

* UC4PARAMETERS
  READ TABLE text_element_tab WITH KEY window = 'MAIN'
                                       element = 'UC4PARAMETERS'.
  IF sy-subrc >< 0 OR text_element_tab-linecount = 0.
  ELSE.
    SELECT SINGLE * FROM /sie/hr_idp_s1df
                   WHERE ifcid = gt_interfaces-ifcid
                   AND   vrsnr = gt_interfaces-vrsnr.
    IF sy-subrc = 0.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'UC4PARAMETERS'
        EXCEPTIONS
          OTHERS  = 1.
    ELSE.
      CLEAR /sie/hr_idp_s1df.
    ENDIF.
  ENDIF.

* PARAMETERS
  READ TABLE text_element_tab WITH KEY window = 'MAIN'
                                   element = 'PARAMETERS'.
  IF sy-subrc >< 0 OR text_element_tab-linecount = 0.
  ELSE.
    SELECT SINGLE * FROM /sie/hr_idp_s1pr
                    WHERE ifcid = gt_interfaces-ifcid
                    AND   vrsnr = gt_interfaces-vrsnr.
    IF sy-subrc = 0.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'UC4PARAMETERS'
        EXCEPTIONS
          OTHERS  = 1.
    ELSE.
      CLEAR /sie/hr_idp_s1pr.
    ENDIF.
  ENDIF.

* RECORD
  READ TABLE text_element_tab WITH KEY window = 'MAIN'
                                   element = 'RECORD'.
  IF sy-subrc >< 0 OR text_element_tab-linecount = 0.
  ELSE.
    SELECT * FROM /sie/hr_idp_s1sa WHERE ifcid = gt_interfaces-ifcid
                                   AND   vrsnr = gt_interfaces-vrsnr
      ORDER BY PRIMARY KEY.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'RECORD'
        EXCEPTIONS
          OTHERS  = 1.

* FIELD_LAYOUT
      READ TABLE text_element_tab WITH KEY window = 'MAIN'
                                       element = 'FIELD_LAYOUT'.
      IF sy-subrc >< 0 OR text_element_tab-linecount = 0.
      ELSE.
        SELECT * FROM /sie/hr_idp_s1pg WHERE ifcid = gt_interfaces-ifcid
                                       AND   vrsnr = gt_interfaces-vrsnr
                                    AND   recna = /sie/hr_idp_s1sa-recna
          ORDER BY PRIMARY KEY.

          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = 'FIELD_LAYOUT'
            EXCEPTIONS
              OTHERS  = 1.

        ENDSELECT.
      ENDIF.
    ENDSELECT.
  ENDIF.

* DELIMITER
  READ TABLE text_element_tab WITH KEY window = 'MAIN'
                                   element = 'RECORD'.
  IF sy-subrc >< 0 OR text_element_tab-linecount = 0.
  ELSE.
    SELECT SINGLE * FROM /sie/hr_idp_s1dl
      WHERE ifcid = gt_interfaces-ifcid
      AND vrsnr   = gt_interfaces-vrsnr.
    IF sy-subrc = 0.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'DELIMITER'
        EXCEPTIONS
          OTHERS  = 1.
    ELSE.
      CLEAR /sie/hr_idp_s1dl.
    ENDIF.
  ENDIF.

* FOOTER
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'FOOTER'
    EXCEPTIONS
      OTHERS  = 1.

  CALL FUNCTION 'END_FORM'
    EXCEPTIONS
      OTHERS = 1.

ENDFORM.                    " PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  WRITE_LOG
*&---------------------------------------------------------------------*
*       Drucken eines Protokolls über was an wen versandt werden
*       sollte.
*----------------------------------------------------------------------*
*      -->P_CONTENTS  Inhalt des Briefes
*      -->P_RECEIVERS Liste der Empfänger
*----------------------------------------------------------------------*
FORM write_log TABLES contents_txt STRUCTURE solisti1
                      receivers STRUCTURE somlreci1.

  NEW-PAGE.

  WRITE: / 'An folgende Empfänger'(001).
  LOOP AT receivers.
    WRITE: /10 receivers-receiver.
  ENDLOOP.
  ULINE.
  SKIP.
  WRITE: / 'wird die folgende E-Mail versandt:'(002).

  SKIP.

  LOOP AT contents_txt.
    WRITE: /10 contents_txt-line(122).
  ENDLOOP.

  SKIP.

ENDFORM.                    " WRITE_LOG

*&---------------------------------------------------------------------*
*&      Form  READ_FORM_TEXT_ELEMENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXT_ELEMENT_TAB  text
*      -->P_FORM  text
*      <--P_SUBRC  text
*----------------------------------------------------------------------*
FORM read_form_text_elements TABLES   p_text_element_tab STRUCTURE itcwe
                             USING    p_form
                             CHANGING p_subrc.

  CLEAR p_text_element_tab[].
  CALL FUNCTION 'READ_FORM_ELEMENTS'
    EXPORTING
      form     = form
      language = sy-langu
    TABLES
      elements = p_text_element_tab
    EXCEPTIONS
      form     = 1
      unopened = 2
      OTHERS   = 3.
  p_subrc = sy-subrc.

ENDFORM.                    " READ_FORM_TEXT_ELEMENTS
