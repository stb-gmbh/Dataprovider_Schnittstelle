*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_GENERATORF02 .
*  D A T E N B E S C H A F F U N G
*----------------------------------------------------------------------*
*  M. Przygocki 20230111 ATC findings C2C correction

FORM get_satzarten USING    p_trans_data  TYPE /sie/hr_idp_ifc_db
                   CHANGING p_it_satzart LIKE it_satzart.
  DATA: ws LIKE LINE OF p_trans_data-s1sa,
        wd LIKE LINE OF p_it_satzart.
  DATA: help(20) TYPE c.


  CLEAR p_it_satzart.
  LOOP AT p_trans_data-s1sa INTO ws.
    MOVE-CORRESPONDING ws TO wd.
    WRITE sy-tabix TO help LEFT-JUSTIFIED.
    CONCATENATE 'SA_' help INTO wd-sname.
    COLLECT wd INTO it_satzart.
  ENDLOOP.

ENDFORM.                    " GET_SATZARTEN

*---------------------------------------------------------------------*
*       FORM GET_FIELDS                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_TRANS_DATA                                                  *
*  -->  P_IT_FELDER                                                   *
*  -->  P_IT_SA_INFTY                                                 *
*  -->  P_IT_INFOTYPE                                                 *
*---------------------------------------------------------------------*
FORM get_fields USING    p_trans_data TYPE /sie/hr_idp_ifc_db
                CHANGING p_it_felder LIKE it_felder
                         p_it_sa_infty LIKE it_sa_infty
                         p_it_infotype LIKE it_infotypes.
  DATA: ws LIKE LINE OF p_trans_data-s1pg,   "Work_area_source
        wsa LIKE LINE OF p_trans_data-s1sa,  "Work_area_source-Satzarten
        wd LIKE LINE OF p_it_felder,         "Work_area_destination
        si LIKE LINE OF p_it_sa_infty,       "Infotypen pro Satzart
        it LIKE LINE OF p_it_infotype,       "zu deklarierende Infotypen
        len TYPE i,
        tabname TYPE /sie/hr_idp_tabname.

  CLEAR p_it_felder.
  REFRESH p_it_infotype.                                   "SIE003
  it = '0001'. COLLECT it INTO p_it_infotype.
  it = '0003'. COLLECT it INTO p_it_infotype.              "SIE003
  it = '0263'. COLLECT it INTO p_it_infotype.
  it = '9008'. COLLECT it INTO p_it_infotype.
  it = '0203'. COLLECT it INTO p_it_infotype.              "SIE004
  it = '9020'. Collect it into p_it_infotype.              "SIE005
  LOOP AT p_trans_data-s1sa INTO wsa.

* Feldinformationen auf Satzartebene
  IF NOT ( wsa-infty IS INITIAL ).
    CLEAR it.
    it = wsa-infty.
    COLLECT it INTO p_it_infotype.
  ENDIF.

    LOOP AT p_trans_data-s1pg INTO ws WHERE recna = wsa-recna.
      MOVE-CORRESPONDING ws TO wd.
      IF ws-feldname = ws-recna.  "Satzart
        IF wsa-kzsrn IS INITIAL.
          wd-structure = '/SIE/HR_IDP_RECORD_NAME'.
          wd-type = 'X'.
          CONCATENATE 'FSA_' ' ' INTO wd-selname.
          APPEND wd TO p_it_felder.
        ENDIF.
      ELSEIF ws-feldname = 'PERNR'.
        IF wsa-kzspn IS INITIAL.
          wd-structure = 'PERSNO'.
          wd-type = 'X'.
          wd-selname = 'F_PERNR'.
          APPEND wd TO p_it_felder.
        ENDIF.
      ELSE.
       SELECT SINGLE * FROM /sie/hr_idp_f1 WHERE feldname = ws-feldname.
        MOVE-CORRESPONDING /sie/hr_idp_f1 TO wd.
        CASE /sie/hr_idp_f1-dpftype.
          WHEN '1'. "infotypfeld
            CONCATENATE 'P' /sie/hr_idp_f1-infty
                        '-' /sie/hr_idp_f1-inftyfeld
                        INTO wd-structure.
*           APPEND wd TO p_it_felder.
            "Infotypen Pro Satzart
            MOVE-CORRESPONDING ws TO si.
            MOVE-CORRESPONDING /sie/hr_idp_f1 TO si.
            COLLECT si INTO p_it_sa_infty.
            "Infotypen
            MOVE /sie/hr_idp_f1-infty TO it.
            COLLECT it INTO p_it_infotype.
          WHEN '2'. "Gebildeter Begriff
            SELECT SINGLE * FROM /sie/hr_fuba_kat
                            WHERE begriff = /sie/hr_idp_f1-begriff.
            SELECT SINGLE * FROM fupararef
                            WHERE funcname = /sie/hr_fuba_kat-fuba
                              AND r3state = 'A'
                              AND parameter = /sie/hr_fuba_kat-exparam
                              AND paramtype = 'E'.
            MOVE-CORRESPONDING /sie/hr_fuba_kat TO wd.
            MOVE-CORRESPONDING fupararef TO wd.
            IF wd-semcls = 3. "Summierer aus der Abrechnung
              SPLIT ws-paramgb AT ';' INTO wd-paramgb wd-mthbk.
              IF wd-mthbk EQ space.
                 wd-mthbk = 0.
              ENDIF.
              COLLECT wd-mthbk INTO it_monthback.
              CASE wd-funcname.
              WHEN '/SIE/HR_FGB_AWARTSUM'.
                tabname = 'AB'.
                COLLECT tabname INTO it_rd_tabs.
              WHEN '/SIE/HR_FGB_LGARTSUM'.
                tabname = 'RT'.
                COLLECT tabname INTO it_rd_tabs.
              ENDCASE.
            ENDIF.
*          APPEND wd TO p_it_felder.
            "infotypes
            SELECT * FROM fupararef
                            WHERE funcname = /sie/hr_fuba_kat-fuba
                              AND r3state = 'A'
                              AND paramtype = 'I'.
              len = strlen( fupararef-parameter ).
              IF fupararef-parameter+0(2) = 'PP' AND
                 fupararef-parameter+2(4) GE '0000' AND
                 fupararef-parameter+2(4) LE '9999' AND
                 len = 6.
                it = fupararef-parameter+2(4).
                COLLECT it INTO p_it_infotype.
              ENDIF.
            ENDSELECT.
          WHEN '3'.
            tabname = 'RT'.
            COLLECT tabname INTO it_rd_tabs.
            COLLECT wd-mthbk INTO it_monthback.
            wd-type = space.   " LIKE
            PERFORM get_payroll_struc USING wd-acltab
                                            wd-aclfeld
                                      CHANGING
                                            wd-acl_offset
                                            wd-acl_length
                                            wd-acl_fldtyp
                                            wd-acl_tabtyp
                                            wd-structure.
          WHEN '4'.
            COLLECT wd-acltab INTO it_rd_tabs.
            COLLECT wd-mthbk INTO it_monthback.
* Lohnartennamen können "fuzzy" characters beinhalten. Diese zunächst
* durch normale Zeichen ersetzten
            CALL FUNCTION '/SIE/HR_IDP_CONVERT_ACCENTS'
                 EXPORTING
                      in_text         = wd-feldname
                      sw_convert      = 'X'
                      sw_fixed_length = no
                      sw_strip_slash  = yes
                 IMPORTING
                      out_text        = wd-feldname
                 EXCEPTIONS
                      OTHERS          = 1.
            IF sy-subrc <> 0.
            ENDIF.

            wd-acltab = 'RT'.
            wd-type = space.   " LIKE
            CASE wd-rtkz.
              WHEN 'A'.
                wd-aclfeld = 'BETRG'.
              WHEN 'N'.
                wd-aclfeld = 'ANZHL'.
              WHEN 'R'.
                wd-aclfeld = 'BETPE'.
              WHEN OTHERS.
*            FEHLER !
            ENDCASE.
            PERFORM get_payroll_struc USING wd-acltab
                                            wd-aclfeld
                                      CHANGING
                                            wd-acl_offset
                                            wd-acl_length
                                            wd-acl_fldtyp
                                            wd-acl_tabtyp
                                            wd-structure.
            wd-lgart = /sie/hr_idp_f1-rtlgart.
          WHEN OTHERS.
*            FEHLER !
        ENDCASE.
*Konvertierungen
        IF NOT ws-konvnam IS INITIAL.
          SELECT SINGLE * FROM /sie/hr_idp_c1
                          WHERE konvnam = ws-konvnam.
          IF sy-subrc = 0.
            wd-conf_funcname = /sie/hr_idp_c1-fubanam.
            wd-conf_out_param = 'P_OUT'.
            wd-conf_ctrl_param = 'P_PARAM'.
            wd-conf_ctrl_value = /sie/hr_idp_c1-konvpara.
            wd-conf_out_length = /sie/hr_idp_c1-konvleng.
            IF wd-conf_out_length = 0.
              wd-conf_out_length = 255.
            ENDIF.
          ENDIF.
        ENDIF.
*        CONCATENATE 'F_' wd-fldps wd-feldname INTO wd-selname.
        CONCATENATE 'F_' wd-fldps INTO wd-selname.
        CALL FUNCTION '/SIE/HR_IDP_GET_TYPE'
             EXPORTING
                  logical_field = ws-feldname
             IMPORTING
                  external_type = wd-external_type
                  length     = wd-db_length  "aha003
                  internal_type = wd-internal_type
             EXCEPTIONS
                  OTHERS        = 1.
        IF wd-db_length = 0. wd-db_length = 255. ENDIF.
        APPEND wd TO p_it_felder.
        IF wd-infty = '0008' AND wd-inftyfeld(3) = 'BET'.
        g_indbw8 = 'X'. ENDIF.
        IF wd-infty = '0014' AND wd-inftyfeld(3) = 'BET'.
        g_indbw14 = 'X'. ENDIF.
        IF wd-infty = '0015' AND wd-inftyfeld(3) = 'BET'.
        g_indbw15 = 'X'. ENDIF.
        IF wd-infty = '0052' AND wd-inftyfeld(3) = 'BET'.
        g_indbw52 = 'X'. ENDIF.

      ENDIF.
*   APPEND wd TO p_it_felder.
      CLEAR ws. CLEAR wd.
    ENDLOOP.
  ENDLOOP.
  SORT p_it_felder BY recna fldps.
  IF  g_indbw8 = 'X'
      OR  g_indbw14 = 'X'
      OR  g_indbw15 = 'X'
      OR  g_indbw52 = 'X'.
    it = '0007'. COLLECT it INTO p_it_infotype.
    it = '0008'. COLLECT it INTO p_it_infotype.
    it = '0001'. COLLECT it INTO p_it_infotype.
  ENDIF.
ENDFORM.                    " GET_FIELDS

*---------------------------------------------------------------------*
*       FORM GET_FILTER                                    SIE002     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM get_filter USING    p_trans_data TYPE /sie/hr_idp_ifc_db
                         p_it_satzart LIKE it_satzart
                         p_it_felder  LIKE it_felder
                CHANGING p_it_filter  LIKE it_filter.

   DATA: wa_satzart LIKE LINE OF p_it_satzart,
         wa_felder  LIKE LINE OF p_it_felder,
         ws         LIKE LINE OF p_trans_data-s1ps,
         wd_filter  LIKE LINE OF p_it_filter.

   REFRESH p_it_filter.
   LOOP AT p_trans_data-s1ps INTO ws.

     CLEAR wd_filter.
     MOVE-CORRESPONDING ws TO wd_filter.
     READ TABLE p_it_satzart INTO wa_satzart
                             WITH KEY recna = wd_filter-recna.
     CHECK sy-subrc = 0.
     READ TABLE p_it_felder  INTO wa_felder
                             WITH KEY recna = wd_filter-recna
                                      fldps = wd_filter-fldps.
     CHECK sy-subrc = 0.

     wd_filter-sname    = wa_satzart-sname.
     wd_filter-selname  = wa_felder-selname.
     wd_filter-feldname = wa_felder-feldname.
     CONCATENATE 'SL' wd_filter-sname wd_filter-selname
            INTO wd_filter-rangename SEPARATED BY '_'.

     APPEND wd_filter TO p_it_filter.

   ENDLOOP.
   SORT p_it_filter.

ENDFORM.                    " GET_FILTER


*---------------------------------------------------------------------*
*       FORM GET_FIELDS_ALT                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_TRANS_DATA                                                  *
*  -->  P_IT_FELDER                                                   *
*  -->  P_IT_SA_INFTY                                                 *
*  -->  P_IT_INFOTYPE                                                 *
*---------------------------------------------------------------------*
FORM get_fields_alt USING    p_trans_data TYPE /sie/hr_idp_ifc_db
                CHANGING p_it_felder LIKE it_felder
                         p_it_sa_infty LIKE it_sa_infty
                         p_it_infotype LIKE it_infotypes.
  DATA: ws LIKE LINE OF p_trans_data-s1pg,   "Work_area_source
        wd LIKE LINE OF p_it_felder,         "Work_area_destination
        si LIKE LINE OF p_it_sa_infty,       "Infotypen pro Satzart
        it LIKE LINE OF p_it_infotype,       "zu deklarierende Infotypen
        len TYPE i.
  CLEAR p_it_felder.

  LOOP AT p_trans_data-s1pg INTO ws.
    MOVE-CORRESPONDING ws TO wd.
    IF ws-feldname = ws-recna.  "Satzart
*** Bernhard, kzfsd ist nicht mehr in s1df vorhanden.
*   Muß hier korrigiert werden !!!
*      break mch0664. break mch0341.
      IF space = space. " Temporäre Lösung
*      IF p_trans_data-s1df-kzsfd IS INITIAL.

        wd-structure = '/SIE/HR_IDP_RECORD_NAME'.
        wd-type = 'X'.
        CONCATENATE 'F_' ws-recna INTO wd-selname.
        APPEND wd TO p_it_felder.
      ENDIF.
    ELSE.
      SELECT SINGLE * FROM /sie/hr_idp_f1 WHERE feldname = ws-feldname.
      MOVE-CORRESPONDING /sie/hr_idp_f1 TO wd.
      CASE /sie/hr_idp_f1-dpftype.
        WHEN '1'. "infotypfeld
          CONCATENATE 'P' /sie/hr_idp_f1-infty
                      '-' /sie/hr_idp_f1-inftyfeld
                      INTO wd-structure.
*           APPEND wd TO p_it_felder.
          "Infotypen Pro Satzart
          MOVE-CORRESPONDING ws TO si.
          MOVE-CORRESPONDING /sie/hr_idp_f1 TO si.
          COLLECT si INTO p_it_sa_infty.
          "Infotypen
          MOVE /sie/hr_idp_f1-infty TO it.
          COLLECT it INTO p_it_infotype.
        WHEN '2'. "Gebildeter Begriff
          SELECT SINGLE * FROM /sie/hr_fuba_kat
                          WHERE begriff = /sie/hr_idp_f1-begriff.
          SELECT SINGLE * FROM fupararef
                          WHERE funcname = /sie/hr_fuba_kat-fuba
                            AND r3state = 'A'
                            AND parameter = /sie/hr_fuba_kat-exparam
                            AND paramtype = 'E'.
          MOVE-CORRESPONDING /sie/hr_fuba_kat TO wd.
          MOVE-CORRESPONDING fupararef TO wd.
*          APPEND wd TO p_it_felder.
          "infotypes
          SELECT * FROM fupararef
                          WHERE funcname = /sie/hr_fuba_kat-fuba
                            AND r3state = 'A'
                            AND paramtype = 'I'.
            len = strlen( fupararef-parameter ).
            IF fupararef-parameter+0(2) = 'PP' AND
               fupararef-parameter+2(4) GE '0000' AND
               fupararef-parameter+2(4) LE '9999' AND
               len = 6.
              it = fupararef-parameter+2(4).
              COLLECT it INTO p_it_infotype.
            ENDIF.
          ENDSELECT.
        WHEN '3'.
          wd-type = space.   " LIKE
          PERFORM get_payroll_struc USING wd-acltab
                                          wd-aclfeld
                                    CHANGING
                                          wd-acl_offset
                                          wd-acl_length
                                          wd-acl_fldtyp
                                          wd-acl_tabtyp
                                          wd-structure.
        WHEN '4'.
          wd-type = space.   " LIKE
          wd-acltab = 'RT'.
          wd-acl_tabtyp = 'h'.   " Interne Tabelle
          CASE wd-rtkz.
            WHEN 'A'.
              wd-aclfeld = 'BETRG'.
              CONCATENATE 'PC207' '-' wd-aclfeld INTO wd-structure.
              PERFORM get_length_offset USING 'PC207'
                                              wd-aclfeld
                                        CHANGING wd-acl_length
                                                 wd-acl_offset
                                                 wd-acl_fldtyp.
            WHEN 'N'.
              wd-aclfeld = 'ANZHL'.
              CONCATENATE 'PC207' '-' wd-aclfeld INTO wd-structure.
              PERFORM get_length_offset USING 'PC207'
                                              wd-aclfeld
                                        CHANGING wd-acl_length
                                                 wd-acl_offset
                                                 wd-acl_fldtyp.
            WHEN 'R'.
              wd-aclfeld = 'BETPE'.
              CONCATENATE 'PC207' '-' wd-aclfeld INTO wd-structure.
              PERFORM get_length_offset USING 'PC207'
                                              wd-aclfeld
                                        CHANGING wd-acl_length
                                                 wd-acl_offset
                                                 wd-acl_fldtyp.
            WHEN OTHERS.
*            FEHLER !
          ENDCASE.
        WHEN OTHERS.
*            FEHLER !
      ENDCASE.
*Konvertierungen
      IF NOT ws-konvnam IS INITIAL.
        SELECT SINGLE * FROM /sie/hr_idp_c1
                        WHERE konvnam = ws-konvnam.
        IF sy-subrc = 0.
          wd-conf_funcname = /sie/hr_idp_c1-fubanam.
          wd-conf_out_param = 'P_OUT'.
          wd-conf_ctrl_param = 'P_PARAM'.
          wd-conf_ctrl_value = /sie/hr_idp_c1-konvpara.
          wd-conf_out_length = /sie/hr_idp_c1-konvleng.
        ENDIF.
      ENDIF.
      CONCATENATE 'F_' wd-fldps wd-feldname INTO wd-selname.
      APPEND wd TO p_it_felder.
    ENDIF.
*   APPEND wd TO p_it_felder.
    CLEAR ws. CLEAR wd.
  ENDLOOP.
  SORT p_it_felder BY recna fldps.
ENDFORM.                    " GET_FIELDS

*---------------------------------------------------------------------*
*       FORM CHANGE_FIELDS                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_IT_FELDER                                                   *
*  -->  P_IT_SA_INFTY                                                 *
*  -->  P_IT_SATZART                                                  *
*---------------------------------------------------------------------*
FORM change_fields CHANGING p_it_felder LIKE it_felder
                            p_it_sa_infty LIKE it_sa_infty
                            p_it_satzart LIKE it_satzart.
*bei Satzarten aus zwei infotypen wird die Pernr aus dem existierenden
*Infotypen gelesen und somit die Anzahl der Infotypen pro Satzart
*hoffentlich auf 1 reduziert.

  DATA: wf  LIKE LINE OF p_it_felder,
        wsi LIKE LINE OF p_it_sa_infty,
        ws  LIKE LINE OF p_it_satzart,
        goal TYPE infty,
        count TYPE i.

  LOOP AT p_it_satzart INTO ws.
    CLEAR count.
    LOOP AT p_it_sa_infty TRANSPORTING NO FIELDS
                          WHERE recna = ws-recna.
      ADD 1 TO count.
    ENDLOOP.
    IF count EQ 2. "möglicherweise auf 1 reduzierbar
      CLEAR count.
      LOOP AT p_it_felder TRANSPORTING NO FIELDS
                          WHERE recna = ws-recna
                            AND infty = '0001'.
        ADD 1 TO count.
      ENDLOOP.
      IF count = 1.
        LOOP AT p_it_felder INTO wf
                            WHERE recna = ws-recna
                              AND infty NE space
                              AND infty NE '0001'.
          goal = wf-infty.
          EXIT.
        ENDLOOP.
        LOOP AT p_it_felder INTO wf
                            WHERE recna = ws-recna
                              AND infty EQ '0001'.
          wf-infty = goal.
          MODIFY p_it_felder FROM wf.
        ENDLOOP.
        wsi-recna = ws-recna.
        wsi-infty = '0001'.
        DELETE TABLE p_it_sa_infty FROM wsi.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_LENGTH_OFFSET
*&---------------------------------------------------------------------*
*       Diese Formroutine liset aus dem DDIC die Länge und danach
*       den Offset des feldes in der Struktur
*----------------------------------------------------------------------*
*      -->P_WD_STRUCTURE  DDIC Strukturname
*      -->P_WD_ACLFELD    DDIC Feldname
*      <--P_WD_ACL_LENGTH Länge
*      <--P_WD_ACL_OFFSET Offset in der DDIC Struktur
*----------------------------------------------------------------------*
FORM get_length_offset USING value(p_structure)
                             value(p_aclfeld) TYPE fieldname
                       CHANGING p_acl_length TYPE n
                                p_acl_offset TYPE n
                                p_type TYPE c.

  DATA: name LIKE dcobjdef-name
      , local_dd03p_tab TYPE STANDARD TABLE OF dd03p INITIAL SIZE 0
        WITH HEADER LINE.

  name = p_structure.
  PERFORM get_structure TABLES local_dd03p_tab
                        USING  name.

  LOOP AT local_dd03p_tab.
    IF local_dd03p_tab-fieldname = p_aclfeld.
      p_acl_length = local_dd03p_tab-leng.
      p_type = local_dd03p_tab-inttype.
      EXIT.
    ELSE.
      p_acl_offset = p_acl_offset + local_dd03p_tab-leng.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " GET_LENGTH_OFFSET

*---------------------------------------------------------------------*
*       FORM GET_STRUCTURE                                            *
*---------------------------------------------------------------------*
*       Diese Formroutine liest aus dem DDIC die Strukturinformation  *
*---------------------------------------------------------------------*
*  <--  LOCAL_DD03P_TAB           Strukturinformationen               *
*  -->  RECORD_CONTROL-STRUCTURE  Strukturname                        *
*---------------------------------------------------------------------*
FORM get_structure TABLES local_dd03p_tab
                   USING structure TYPE ddobjname.

  DATA: name LIKE dcobjdef-name,
        local_dd02v_wa LIKE dd02v.

  name = structure.

  CALL FUNCTION 'DDIF_TABL_GET'
       EXPORTING
            name          = name
            state         = 'A'
            langu         = sy-langu
       TABLES
            dd03p_tab     = local_dd03p_tab
       EXCEPTIONS
            illegal_input = 1
            OTHERS        = 2.
  IF sy-subrc <> 0.
    CLEAR local_dd03p_tab[].
  ENDIF.

ENDFORM.                               " GET_STRUCTURE

*&---------------------------------------------------------------------*
*&      Form  GET_PAYROLL_STRUC
*&---------------------------------------------------------------------*
*       Diese Routine findet Informationen bzgl. den Abrechnungs-
*       Ergebnis Strukturen und Tabellen.
*----------------------------------------------------------------------*
*      -->P_0013   text
*      -->P_0014   text
*      <--P_WD_ACL_OFFSET  text
*      <--P_WD_ACL_LENGTH  text
*      <--P_WD_ACL_FLDTYP  text
*      <--P_WD_ACL_TABTYP  text
*      <--P_WD_STRUCTURE  text
*----------------------------------------------------------------------*
FORM get_payroll_struc USING  value(p_acltab)
                                value(p_aclfeld)
                       CHANGING p_acl_offset
                                p_acl_length
                                p_acl_fldtyp
                                p_acl_tabtyp
                                p_structure.

  CONSTANTS: clusterid LIKE  pcl2-relid VALUE 'RD'.

  STATICS: requested_objects_list TYPE STANDARD TABLE OF hrpystruc
        INITIAL SIZE 0 WITH HEADER LINE
      .

  STATICS: itab_dfies LIKE dfies OCCURS 0 WITH HEADER LINE.
  DATA: typename LIKE dcobjdef-name VALUE 'PAYXX_RESULT'.
  DATA: iso_code LIKE t500l-intca.
  DATA: help_lname TYPE dfies-lfieldname.
  DATA: hyphen_offset TYPE sy-fdpos.

  CONSTANTS: int_name(5) VALUE 'INTER',
             nat_name(3) VALUE 'NAT',
             evp_name(3) VALUE 'EVP',
             result_name(6) VALUE 'RESULT',
             version_name(7) VALUE 'VERSION'.

  DESCRIBE TABLE itab_dfies.
  IF sy-tfill = 0.

    CLEAR requested_objects_list[].
    SELECT intca INTO iso_code FROM t500l UP TO 1 ROWS
           WHERE relid = clusterid
      ORDER BY PRIMARY KEY.               "M. Przygocki 20230111
    ENDSELECT.
    REPLACE 'XX' WITH iso_code INTO typename.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
         EXPORTING
              tabname        = typename
              all_types      = 'X'
         TABLES
              dfies_tab      = itab_dfies
         EXCEPTIONS
              not_found      = 1
              internal_error = 2
              OTHERS         = 3.
    IF sy-subrc <> 0.
      RAISE ddictype_does_not_exist.
    ENDIF.

  ENDIF.

  READ TABLE itab_dfies WITH KEY fieldname = p_acltab
*                                 DATATYPE = 'TTAB'.
                                 datatype = 'TTYP'. "SIE001

  p_acl_tabtyp = itab_dfies-inttype.

  IF itab_dfies-rollname(2) = 'PC'.
    p_structure = itab_dfies-rollname.
  ELSE.
    IF itab_dfies-lfieldname(5) EQ int_name.
      SELECT * FROM dd40l WHERE typename LIKE 'HRPAY99%'
        ORDER BY PRIMARY KEY.        "M. Przygocki 20230111
        IF dd40l+8(22) = p_acltab.
          MOVE dd40l-rowtype TO p_structure.
          EXIT.
        ENDIF.
      ENDSELECT.
    ELSEIF itab_dfies-lfieldname(3) EQ nat_name.
      SELECT * FROM dd40l WHERE typename LIKE 'HRPAYDE%'
        ORDER BY PRIMARY KEY.        "M. Przygocki 20230111
        IF dd40l+8(22) = p_acltab.
          MOVE dd40l-rowtype TO p_structure.
          EXIT.
        ENDIF.
      ENDSELECT.
    ENDIF.
  ENDIF.

  PERFORM get_length_offset USING p_structure
                                  p_aclfeld
                            CHANGING p_acl_length
                                     p_acl_offset
                                     p_acl_fldtyp.

  CONCATENATE p_structure '-' p_aclfeld INTO p_structure.

ENDFORM.                    " GET_PAYROLL_STRUC
