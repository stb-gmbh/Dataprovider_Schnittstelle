*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_I1006 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  WRITE_RECNA_ATRIX  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE write_recna_matrix INPUT.

  MOVE-CORRESPONDING /sie/hr_idp_satzarten_tc TO /sie/hr_idp_s1sa.
  READ TABLE g_ifdata_tran-s1sa TRANSPORTING NO FIELDS
                                WITH KEY recna = /sie/hr_idp_s1sa-recna.
  IF sy-subrc = 0.
    MODIFY g_ifdata_tran-s1sa FROM /sie/hr_idp_s1sa INDEX sy-tabix.
  ELSE.
* Keine Änderung
  ENDIF.
ENDMODULE.                 " WRITE_RECNA_MATRIX  INPUT

*&---------------------------------------------------------------------*
*&      Module  CURRENT_RECNA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE current_recna INPUT.

*  clear g_700_satzart.
  IF /sie/hr_idp_satzarten_tc-mark = yes.
    g_satzart_old = g_700_satzart.
    g_700_satzart = /sie/hr_idp_satzarten_tc-recna.
  ENDIF.

ENDMODULE.                 " CURRENT_RECNA  INPUT

*&---------------------------------------------------------------------*
*&      Module  WRITE_FIELDS_MATRIX  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE write_fields_matrix INPUT.

  IF /sie/hr_idp_felder_tc-mark = yes.
    g_feldname = /sie/hr_idp_felder_tc-feldname.
    g_feldname_idx = tc_saf-current_line.
  ENDIF.

ENDMODULE.                 " WRITE_FIELDS_MATRIX  INPUT

*&---------------------------------------------------------------------*
*&      Module  BREAK  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE break OUTPUT.

*  break-point.

* g_ifdata_s1pg[]
* g_ifdata_s1sa[]
* g_itab_s1pg[]

ENDMODULE.                 " BREAK  OUTPUT

*---------------------------------------------------------------------*
*       MODULE BREAK INPUT                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE break INPUT.

*  break-point.

ENDMODULE.                 " BREAK  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  WRITE_FLDPS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE write_fldps INPUT.

  IF /sie/hr_idp_felder_tc-ifcid IS INITIAL.
    /sie/hr_idp_felder_tc-ifcid = g_ifdata_tran-s1-ifcid.
    /sie/hr_idp_felder_tc-vrsnr = g_ifdata_vers.
    /sie/hr_idp_felder_tc-recna = g_satzart_old.
    /sie/hr_idp_felder_tc-fldps = tc_saf-current_line.

*    APPEND /SIE/HR_IDP_FELDER_TC TO G_ITAB_S1PG.
    MOVE-CORRESPONDING /sie/hr_idp_felder_tc
                             TO g_itab_s1pg.               "SIE003
    APPEND g_itab_s1pg.                                    "SIE003

  ELSE.
    IF /sie/hr_idp_felder_tc-kzkey = yes.
      /sie/hr_idp_felder_tc-keypos = '001'.
      IF g_ifdata_tran-s1df-delta = yes.                   "SIE001
         /sie/hr_idp_felder_tc-nosep = no.                 "SIE001
      ENDIF.                                               "SIE001
    ELSE.
      /sie/hr_idp_felder_tc-keypos = '000'.
    ENDIF.

*    MODIFY G_ITAB_S1PG FROM /SIE/HR_IDP_FELDER_TC
*                       INDEX TC_SAF-CURRENT_LINE.
    MOVE-CORRESPONDING /sie/hr_idp_felder_tc TO g_itab_s1pg."SIE003
    MODIFY g_itab_s1pg INDEX tc_saf-current_line.           "SIE003

  ENDIF.
ENDMODULE.                 " WRITE_FLDPS  INPUT

*&---------------------------------------------------------------------*
*&      Module  UPDATE_S1PG_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_s1pg_data INPUT.
  DELETE g_ifdata_tran-s1pg WHERE recna = g_satzart_old
                              AND vrsnr = g_ifdata_vers.

  DELETE g_ifdata_tran-s1ps WHERE recna = g_satzart_old    "SIE003
                              AND vrsnr = g_ifdata_vers.   "SIE003

*  LOOP AT G_ITAB_S1PG INTO /SIE/HR_IDP_FELDER_TC.
*    MOVE-CORRESPONDING /SIE/HR_IDP_FELDER_TC TO /SIE/HR_IDP_S1PG.
   LOOP AT g_itab_s1pg.                                    "SIE003
     MOVE-CORRESPONDING g_itab_s1pg TO /sie/hr_idp_s1pg.   "SIE003

    /sie/hr_idp_s1pg-recna = g_satzart_old.
    /sie/hr_idp_s1pg-ifcid = g_ifdata_tran-s1-ifcid.
    /sie/hr_idp_s1pg-vrsnr = g_ifdata_vers.
    /sie/hr_idp_s1pg-fldps = sy-tabix.

    IF /sie/hr_idp_s1pg-feldname IS INITIAL.
      CLEAR: /sie/hr_idp_s1pg-konvnam
           , /sie/hr_idp_s1pg-param
           .
    ENDIF.

*   Feldfilter aktualisieren
    IF /sie/hr_idp_s1pg-fldps = '001'                      "SIE003
    OR /sie/hr_idp_s1pg-fldps = '002'                      "SIE003
    OR /sie/hr_idp_s1pg-feldname = c_constant              "SIE003
    OR /sie/hr_idp_s1pg-feldname IS INITIAL.               "SIE003
    ELSE.                                                  "SIE003

      g_tabix = sy-tabix.                                  "SIE003
      LOOP AT g_itab_s1pg-s1ps INTO /sie/hr_idp_s1ps.      "SIE003

         /sie/hr_idp_s1ps-recna = g_satzart_old.           "SIE003
         /sie/hr_idp_s1ps-ifcid = g_ifdata_tran-s1-ifcid.  "SIE003
         /sie/hr_idp_s1ps-vrsnr = g_ifdata_vers.           "SIE003
         /sie/hr_idp_s1ps-fldps = g_tabix.                 "SIE003
         APPEND /sie/hr_idp_s1ps TO g_ifdata_tran-s1ps.    "SIE003

      ENDLOOP.                                             "SIE003
    ENDIF.                                                 "SIE003

    APPEND /sie/hr_idp_s1pg TO g_ifdata_tran-s1pg.
  ENDLOOP.

  SORT g_ifdata_tran-s1pg BY ifcid vrsnr recna fldps.

  DELETE ADJACENT DUPLICATES FROM g_ifdata_tran-s1pg
         COMPARING ifcid vrsnr recna fldps.

  DELETE ADJACENT DUPLICATES FROM g_ifdata_tran-s1ps       "SIE003
         COMPARING ifcid vrsnr recna fldps seqno.          "SIE003

* Da die Daten auch von der S1DF abhängig sind, hier auch nochmal ein
* update der Tabelle
  g_ifdata_tran-s1df-ifcid = g_ifdata_tran-s1-ifcid.
  g_ifdata_tran-s1df-vrsnr = g_ifdata_vers.

  g_ifdata_tran-s1dl-ifcid = g_ifdata_tran-s1-ifcid.
  g_ifdata_tran-s1dl-vrsnr = g_ifdata_vers.

ENDMODULE.                 " UPDATE_S1PG_DATA  INPUT

*&---------------------------------------------------------------------*
*&      Module  FIELD_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE field_user_command INPUT.
  PERFORM field_user_command.
ENDMODULE.                 " FIELD_USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  field_user_command_tc  INPUT               "SIE003
*&---------------------------------------------------------------------*
*&      zusätzliches user_command-Modul, da bei den anderen bereits die
*&      Zeileneingaben umgerechnet wurden. Daher könnte es dort zu
*&      Differenzen des ausgewählten und des tatsächlich selektierten
*&      Feldes kommen.
*&---------------------------------------------------------------------*


MODULE field_user_command_tc INPUT.

   CASE svcode.
      WHEN 'L_FILTER'.
         PERFORM set_field_filter.
   ENDCASE.

ENDMODULE.                 " field_user_command_tc  INPUT


*&---------------------------------------------------------------------*
*&      Module  CHECK_UNPACK  INPUT
*&---------------------------------------------------------------------*
*       Check ob die Ausgabefelder konvertiert werden müssen!
*----------------------------------------------------------------------*
MODULE check_conversion INPUT.
  IF NOT ( /sie/hr_idp_felder_tc-feldname IS INITIAL ).
    PERFORM field_check_convert.
  ENDIF.
ENDMODULE.                 " CHECK_UNPACK  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_FIELD_SINGULARITY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_field_singularity INPUT.
  IF NOT ( /sie/hr_idp_felder_tc-feldname IS INITIAL ).
    PERFORM check_field_singularity.
  ENDIF.
ENDMODULE.                 " CHECK_FIELD_SINGULARITY  INPUT

*&---------------------------------------------------------------------*
*&      Module  REIDX_S1SA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE reidx_s1sa INPUT.

*  loop at g_ifdata_tran-s1sa into /sie/hr_idp_s1sa.
*    /sie/hr_idp_s1sa-sortn = sy-tabix.
*    modify g_ifdata_tran-s1sa from /sie/hr_idp_s1sa.
*  endloop.
ENDMODULE.                 " REIDX_S1SA  INPUT

*&---------------------------------------------------------------------*
*&      Module  F4_CONVERSION  INPUT
*&---------------------------------------------------------------------*
*       Findet alle erlaubten Konvertierungen
*----------------------------------------------------------------------*
MODULE f4_conversion INPUT.
  PERFORM f4_konvnam CHANGING /sie/hr_idp_felder_tc-konvnam.
ENDMODULE.                 " F4_CONVERSION  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_APO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_apo INPUT.

  SEARCH /sie/hr_idp_felder_tc-param FOR text-apo.
  IF sy-subrc = 0.
    MESSAGE e148.
  ENDIF.

ENDMODULE.                 " CHECK_APO  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_RECNA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_recna INPUT.
  IF /sie/hr_idp_satzarten_tc-recty = 2.
    MESSAGE e242.
  ENDIF.
ENDMODULE.                 " CHECK_RECNA  INPUT

*&---------------------------------------------------------------------*
*&      Module  F4_FELDNAME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_feldname INPUT.
  PERFORM f4_feldname.
ENDMODULE.                 " F4_FELDNAME  INPUT

*&---------------------------------------------------------------------*
*&      Form  F4_FELDNAME
*&---------------------------------------------------------------------*
FORM f4_feldname.

  TYPES: BEGIN OF t_values
       ,  konvnam TYPE /sie/hr_idp_konvnam
       ,  ident LIKE /sie/hr_idp_c1t-ident
       , END OF t_values
       .

  DATA: l_dynnr LIKE sy-dynnr VALUE '1006'
      , l_repid LIKE sy-repid VALUE '/SIE/HR_IDP_IFC'
      , l_itab_dynpfields TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0
        WITH HEADER LINE
      , l_wa_dynpfields LIKE dynpread
      , l_itab_values TYPE STANDARD TABLE OF t_values INITIAL SIZE 0
         WITH HEADER LINE
      , l_conversion TYPE /sie/hr_idp_konvnam
      , l_fieldname LIKE /sie/hr_idp_felder_tc-feldname
      .

  DATA: l_fld_shlp TYPE shlp_descr_t,
        l_interface LIKE ddshiface,
        l_t_returnvalues LIKE ddshretval OCCURS 0,
* Rückgabe aus Aufruf
        l_fld_returnvalues LIKE LINE OF l_t_returnvalues,
        l_fld_prop LIKE ddshfprop
        .

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            povstepl        = l_wa_dynpfields-stepl
       EXCEPTIONS
            stepl_not_found = 1
            OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    l_wa_dynpfields-fieldname = '/SIE/HR_IDP_FELDER_TC-FELDNAME'.
    APPEND l_wa_dynpfields TO l_itab_dynpfields.
  ENDIF.

  CALL FUNCTION 'DYNP_VALUES_READ'
       EXPORTING
            dyname               = l_repid
            dynumb               = l_dynnr
       TABLES
            dynpfields           = l_itab_dynpfields
       EXCEPTIONS
            invalid_abapworkarea = 1
            invalid_dynprofield  = 2
            invalid_dynproname   = 3
            invalid_dynpronummer = 4
            invalid_request      = 5
            no_fielddescription  = 6
            invalid_parameter    = 7
            undefind_error       = 8
            double_conversion    = 9
            OTHERS               = 10.
  IF sy-subrc <> 0.
    l_fieldname = space.
  ELSE.
    READ TABLE  l_itab_dynpfields
         WITH KEY fieldname = '/SIE/HR_IDP_FELDER_TC-FELDNAME'.
    l_fieldname =  l_itab_dynpfields-fieldvalue.
  ENDIF.

  READ TABLE g_ifdata_tran-s1sa INTO /sie/hr_idp_s1sa
                                WITH KEY recna = g_700_satzart.
  IF ( /sie/hr_idp_s1sa-recty = 1 ) OR
     ( /sie/hr_idp_s1sa-recty = 5 ).
    l_fld_shlp-shlpname = '/SIE/HR_IDP_FELDNAME_T'.
  ELSE.
    l_fld_shlp-shlpname = '/SIE/HR_IDP_FELDNAME'.
  ENDIF.

  l_fld_shlp-shlptype = 'SH'.

  CALL FUNCTION 'DD_SHLP_GET_HELPMETHOD'
       EXPORTING
            tabname   = space
            fieldname = space
            langu     = sy-langu
       CHANGING
            shlp      = l_fld_shlp
       EXCEPTIONS
            OTHERS    = 0.

  CALL FUNCTION 'DD_SHLP_GET_DIALOG_INFO'
       CHANGING
            shlp = l_fld_shlp.

  READ TABLE l_fld_shlp-fieldprop INTO l_fld_prop
                                  WITH KEY fieldname = 'FELDNAME'.
  l_fld_prop-shlpoutput = 'X'.
  MODIFY l_fld_shlp-fieldprop FROM l_fld_prop INDEX sy-tabix.

  CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
       EXPORTING
            shlp          = l_fld_shlp
       TABLES
            return_values = l_t_returnvalues.
  IF l_itab_dynpfields-fieldinp = yes.
    LOOP AT l_t_returnvalues INTO l_fld_returnvalues WHERE
            recordpos = '0001'.
      CASE l_fld_returnvalues-fieldname.
        WHEN 'FELDNAME'.
          READ TABLE l_itab_dynpfields
           WITH KEY fieldname = '/SIE/HR_IDP_FELDER_TC-FELDNAME'.
          l_itab_dynpfields-fieldvalue = l_fld_returnvalues-fieldval.
          MODIFY l_itab_dynpfields INDEX sy-tabix.

          CALL FUNCTION 'DYNP_VALUES_UPDATE'
               EXPORTING
                    dyname               = l_repid
                    dynumb               = l_dynnr
               TABLES
                    dynpfields           = l_itab_dynpfields
               EXCEPTIONS
                    invalid_abapworkarea = 1
                    invalid_dynprofield  = 2
                    invalid_dynproname   = 3
                    invalid_dynpronummer = 4
                    invalid_request      = 5
                    no_fielddescription  = 6
                    undefind_error       = 7
                    OTHERS               = 8.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " F4_FELDNAME

*&---------------------------------------------------------------------*
*&      Module  CHECK_REC  INPUT
*&---------------------------------------------------------------------*
MODULE check_rec INPUT.
  IF okcode >< 'LDEL'.
    READ TABLE g_ifdata_tran-s1sa INTO /sie/hr_idp_s1sa
                                  WITH KEY recna = g_700_satzart.
    IF sy-subrc = 0.
      SELECT SINGLE * FROM /sie/hr_idp_f1
             WHERE feldname = /sie/hr_idp_felder_tc-feldname.
      CASE /sie/hr_idp_s1sa-recty.
        WHEN 1 OR 5.
          IF /sie/hr_idp_f1-kzhdft = yes.
* OK
          ELSE.
            MESSAGE w161.
          ENDIF.
        WHEN 3 OR 4.
          IF /sie/hr_idp_f1-kzhdft = yes.
            MESSAGE w162.
          ELSE.
* OK
          ENDIF.
      ENDCASE.
    ENDIF.
  ENDIF.
ENDMODULE.                 " CHECK_REC  INPUT

*&---------------------------------------------------------------------*
*&      Module  F4_OPERAN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_operan INPUT.

  TYPES: BEGIN OF t_values
       ,  feldname TYPE /sie/hr_idp_fname
       ,  ident TYPE /sie/hr_idp_nutzbez
       , END OF t_values
       .

  DATA: l_dynnr LIKE sy-dynnr VALUE '1006'                  "#EC NOTEXT
      , l_repid LIKE sy-repid VALUE '/SIE/HR_IDP_IFC'
      , l_itab_dynpfields TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0
        WITH HEADER LINE
      , l_wa_dynpfields LIKE dynpread
      , l_itab_values TYPE STANDARD TABLE OF t_values INITIAL SIZE 0
         WITH HEADER LINE
      , l_recordname LIKE /sie/hr_idp_felder_tc-feldname
      , l_wa_s1pg TYPE /sie/hr_idp_s1pg
      .

  DATA: l_fld_shlp TYPE shlp_descr_t,
        l_interface LIKE ddshiface,
        l_t_returnvalues LIKE ddshretval OCCURS 0,
* Rückgabe aus Aufruf
        l_fld_returnvalues LIKE LINE OF l_t_returnvalues,
        l_fld_prop LIKE ddshfprop
        .

  CLEAR: l_itab_dynpfields[]
       , l_itab_values[].

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            povstepl        = l_wa_dynpfields-stepl
       EXCEPTIONS
            stepl_not_found = 1
            OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    l_wa_dynpfields-fieldname = '/SIE/HR_IDP_SATZARTEN_TC-RECNA'.
    APPEND l_wa_dynpfields TO l_itab_dynpfields.
  ENDIF.

  CALL FUNCTION 'DYNP_VALUES_READ'
       EXPORTING
            dyname               = l_repid
            dynumb               = l_dynnr
       TABLES
            dynpfields           = l_itab_dynpfields
       EXCEPTIONS
            invalid_abapworkarea = 1
            invalid_dynprofield  = 2
            invalid_dynproname   = 3
            invalid_dynpronummer = 4
            invalid_request      = 5
            no_fielddescription  = 6
            invalid_parameter    = 7
            undefind_error       = 8
            double_conversion    = 9
            OTHERS               = 10.
  IF sy-subrc <> 0.
    l_recordname = space.
  ELSE.
    READ TABLE  l_itab_dynpfields
         WITH KEY fieldname = '/SIE/HR_IDP_SATZARTEN_TC-RECNA'.
    l_recordname =  l_itab_dynpfields-fieldvalue.
  ENDIF.

* loop at g_itab_s1pg where recna = l_recordname.
  LOOP AT g_ifdata_tran-s1pg INTO l_wa_s1pg
                             WHERE recna = l_recordname.
*   check l_recordname >< g_itab_s1pg-feldname.
*   check 'PERNR' >< g_itab_s1pg-feldname.                  "#EC NOTEXT
*   l_itab_values-feldname = g_itab_s1pg-feldname.
*   l_itab_values-ident = g_itab_s1pg-ident.
    CHECK l_recordname >< l_wa_s1pg-feldname.
    CHECK 'PERNR' >< l_wa_s1pg-feldname.                    "#EC NOTEXT
    l_itab_values-feldname = l_wa_s1pg-feldname.
    SELECT SINGLE * FROM  /sie/hr_idp_f1t
           WHERE  spras     = sy-langu
           AND    feldname  = l_itab_values-feldname.
    IF sy-subrc = 0.
      l_itab_values-ident = /sie/hr_idp_f1t-ident.
    ELSE.
      CLEAR l_itab_values-ident.
    ENDIF.
    APPEND l_itab_values.
  ENDLOOP.

  SORT l_itab_values.
  DELETE ADJACENT DUPLICATES FROM l_itab_values.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            retfield        = 'FELDNAME'                    "#EC NOTEXT
            dynpprog        = l_repid
            dynpnr          = l_dynnr
            dynprofield     = '/SIE/HR_IDP_SATZARTEN_TC-OPERAN'
            value_org       = 'S'                           "#EC NOTEXT
            multiple_choice = no
       TABLES
            value_tab       = l_itab_values
       EXCEPTIONS
            parameter_error = 1
            no_values_found = 2
            OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*  modify l_itab_dynpfields index sy-tabix.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
       EXPORTING
            dyname               = l_repid
            dynumb               = l_dynnr
       TABLES
            dynpfields           = l_itab_dynpfields
       EXCEPTIONS
            invalid_abapworkarea = 1
            invalid_dynprofield  = 2
            invalid_dynproname   = 3
            invalid_dynpronummer = 4
            invalid_request      = 5
            no_fielddescription  = 6
            undefind_error       = 7
            OTHERS               = 8.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDMODULE.                 " F4_OPERAN  INPUT
