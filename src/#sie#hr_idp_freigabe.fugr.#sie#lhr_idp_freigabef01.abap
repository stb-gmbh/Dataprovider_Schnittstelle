*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_FREIGABEF01 .
*----------------------------------------------------------------------*

" 2023-01-30 J.Zatopianski  R/T  20362 COL-20300 - C2C - Bearbeitung ATC-Check-Findings - V3

*&---------------------------------------------------------------------*
*&      Form  CHECK_LTEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE  text
*      -->P_VERSION  text
*      <--P_FL_ALL_OK  text
*----------------------------------------------------------------------*
FORM check_ltext USING VALUE(p_interface) TYPE /sie/hr_idp_ifc_db
                       VALUE(p_vrsnr) TYPE /sie/hr_idp_vers_nr
                 CHANGING p_warning TYPE ty_yesno.

  DESCRIBE TABLE p_interface-s1lt[].
  IF sy-tfill < 2.
    p_warning = yes.
    WRITE: / icon_yellow_light AS ICON,
    'Die Schnittstelle hat keinen oder einen zu kurzen Langtext'(001).
  ENDIF.

ENDFORM.                    " CHECK_LTEXT
*&---------------------------------------------------------------------*
*&      Form  CHECK_KTEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE  text
*      -->P_VERSION  text
*      <--P_FL_ALL_OK  text
*----------------------------------------------------------------------*
FORM check_ktext USING VALUE(p_interface) TYPE /sie/hr_idp_ifc_db
                       VALUE(p_vrsnr) TYPE /sie/hr_idp_vers_nr
                 CHANGING p_warning TYPE ty_yesno.

  DATA: len TYPE i
      .

  len = strlen( p_interface-s1t-ident ).
  IF len < 2.
    p_warning = yes.
    WRITE: / icon_yellow_light AS ICON,
             'Die Beschreibung der Schnittstelle ist zu kurz'(002).
  ENDIF.

ENDFORM.                    " CHECK_KTEXT
*&---------------------------------------------------------------------*
*&      Form  CHECK_ENDDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE  text
*      -->P_VERSION  text
*      <--P_FL_ALL_OK  text
*----------------------------------------------------------------------*
FORM check_endda USING VALUE(p_interface) TYPE /sie/hr_idp_ifc_db
                       VALUE(p_vrsnr) TYPE /sie/hr_idp_vers_nr
                 CHANGING p_warning TYPE ty_yesno.

  IF p_interface-s1-valid_to+4(4) >< '0930'.                "#EC NOTEXT
    p_warning = yes.
    WRITE:  / icon_yellow_light AS ICON,
    'Das Endedatum der Gültigkeit der Schnittstelle'(003),
    'ist nicht der 30.09.'(004).
  ENDIF.

ENDFORM.                    " CHECK_ENDDA
*&---------------------------------------------------------------------*
*&      Form  CHECK_DURAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE  text
*      -->P_VERSION  text
*      <--P_FL_ALL_OK  text
*----------------------------------------------------------------------*
FORM check_durat USING VALUE(p_interface) TYPE /sie/hr_idp_ifc_db
                       VALUE(p_vrsnr) TYPE /sie/hr_idp_vers_nr
                 CHANGING p_warning TYPE ty_yesno.

  DATA: len TYPE i.

  len = p_interface-s1-valid_to - p_interface-s1-valid_from.
  IF len < 5.
    p_warning = yes.
    WRITE:  / icon_yellow_light AS ICON,
           'Der Lieferzeitraum der Schnittstelle ist zu kurz'(006).
  ENDIF.

ENDFORM.                    " CHECK_DURAT
*&---------------------------------------------------------------------*
*&      Form  CHECK_AUTHC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE  text
*      -->P_VERSION  text
*      <--P_FL_ALL_OK  text
*----------------------------------------------------------------------*
FORM check_authc USING VALUE(p_interface) TYPE /sie/hr_idp_ifc_db
                       VALUE(p_vrsnr) TYPE /sie/hr_idp_vers_nr
                 CHANGING p_error TYPE ty_yesno.

  IF p_interface-s1-auth_class IS INITIAL.
    p_error = yes.
    WRITE:  / icon_red_light AS ICON,
            'Die Schnittstelle hat keine Berechtigungsklasse'(005).
  ENDIF.

ENDFORM.                    " CHECK_AUTHC

*&---------------------------------------------------------------------*
*&      Form  CHECK_FCATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE  text
*      -->P_VERSION  text
*      <--P_FL_ALL_OK  text
*----------------------------------------------------------------------*
FORM check_fcata USING VALUE(p_interface) TYPE /sie/hr_idp_ifc_db
                       VALUE(p_vrsnr) TYPE /sie/hr_idp_vers_nr
                 CHANGING p_warning TYPE ty_yesno.
  IF p_interface-s1df-gnrtd = no.
    DESCRIBE TABLE p_interface-s1pg[].
    IF sy-tfill = 0.
      p_warning = yes.
      WRITE:  / icon_yellow_light AS ICON,
         'Manuell geschriebene Programme sollten Felder aufweisen'(007).
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_FCATA

*&---------------------------------------------------------------------*
*&      Form  CHECK_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE  text
*      -->P_VERSION  text
*      <--P_FL_ALL_OK  text
*----------------------------------------------------------------------*
FORM check_fields USING VALUE(p_interface) TYPE /sie/hr_idp_ifc_db
                        VALUE(p_vrsnr) TYPE /sie/hr_idp_vers_nr
                  CHANGING p_warning TYPE ty_yesno.
  DESCRIBE TABLE p_interface-s1pg[].
  IF sy-tfill < 4.
    p_warning = yes.
    WRITE:  / icon_yellow_light AS ICON,
    'Die Schnittstellendefinition beinhaltet weniger als 3 Felder'(008).
  ENDIF.

ENDFORM.                    " CHECK_FIELDS

*&---------------------------------------------------------------------*
*&      Form  CHECK_SELEC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE  text
*      -->P_VERSION  text
*      <--P_FL_ALL_OK  text
*----------------------------------------------------------------------*
FORM check_selec USING VALUE(p_interface) TYPE /sie/hr_idp_ifc_db
                       VALUE(p_vrsnr) TYPE /sie/hr_idp_vers_nr
                 CHANGING p_warning TYPE ty_yesno.

  DESCRIBE TABLE p_interface-s1vt[].
  IF sy-tfill = 0.
    p_warning = yes.
    IF p_interface-s1df-gnrtd = no.
      WRITE:  / icon_yellow_light AS ICON,
  'Manuell geschriebene Programme sollten Selektionen aufweisen'(009).
    ELSE.
      WRITE:  / icon_yellow_light AS ICON,
                'Schnittstellen sollten Selektionen aufweisen'(022).
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_SELEC

*&---------------------------------------------------------------------*
*&      Form  CHECK_R3USER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE  text
*      -->P_VERSION  text
*      <--P_FL_ALL_OK  text
*----------------------------------------------------------------------*
FORM check_r3user USING VALUE(p_interface) TYPE /sie/hr_idp_ifc_db
                        VALUE(p_vrsnr) TYPE /sie/hr_idp_vers_nr
                  CHANGING p_error TYPE ty_yesno.


  IF p_interface-s1df-uc4nm IS INITIAL.
* Der R3 User existiert nicht.
    p_error = yes.
    WRITE: / icon_red_light AS ICON,
             'Der R/3 User unter dem das Program laufen soll',
             'wurde nicht angegeben.'.
  ENDIF.

ENDFORM.                    " CHECK_R3USER

*&---------------------------------------------------------------------*
*&      Form  CHECK_MANUAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE  text
*      -->P_VERSION  text
*      <--P_FL_ALL_OK  text
*----------------------------------------------------------------------*
FORM check_manual USING VALUE(p_interface) TYPE /sie/hr_idp_ifc_db
                        VALUE(p_vrsnr) TYPE /sie/hr_idp_vers_nr
                  CHANGING p_error TYPE ty_yesno.

  IF p_interface-s1df-gnrtd = no.
    IF p_interface-s1df-progr IS INITIAL.
      p_error = yes.
      WRITE: / icon_red_light AS ICON,
'Das Kennzeichen zur Programmgenerierung wurde nicht angekreuzt',
'und die Namen des Programms wurde nicht eingetragen.'.
    ELSE.
      " <<<< BEGIN of replacement  " 2023-01-30 J.Zatopianski  R/T  20362 COL-20300 - C2C - Bearbeitung ATC-Check-Findings - V3
      "  SELECT SINGLE * FROM  TRDIR
      "              WHERE  NAME  = P_INTERFACE-S1DF-PROGR.
      "
      SELECT  *  UP TO 1 ROWS
      FROM  trdir
                  WHERE  name  = p_interface-s1df-progr
      ORDER BY PRIMARY KEY.
      ENDSELECT.
      " >>>>> End of replacement  " 2023-01-30 J.Zatopianski  R/T  20362 COL-20300 - C2C - Bearbeitung ATC-Check-Findings - V3
      IF sy-subrc >< 0.
* Das Programm existiert nicht!
        p_error = yes.
        WRITE: / icon_red_light AS ICON,
                 'Das Programm '(010), p_interface-s1df-progr,
                 'existiert nicht'(013).
      ELSE.
        IF trdir-dbna = 'PN'.
* OK.
        ELSE.
          p_error = yes.
          WRITE:  / icon_red_light AS ICON,
                  'Das Programm '(010), p_interface-s1df-progr,
                  'wird nicht von der'(011),
                  'logischen Datenbank PN ausgewertet'(012).
        ENDIF.

        IF trdir-subc >< '1'.
          p_error = yes.
          WRITE:  / icon_red_light AS ICON,
'Das Programm sollte als ausführbares Programm gekennzeichnet sein'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_MANUAL

*---------------------------------------------------------------------*
*       FORM CHECK_VARIANTS                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VALUE(P_INTERFACE)                                            *
*  -->  VALUE(P_VRSNR)                                                *
*  -->  P_ERROR                                                       *
*---------------------------------------------------------------------*
FORM check_variants  USING VALUE(p_interface) TYPE /sie/hr_idp_ifc_db
                           VALUE(p_vrsnr) TYPE /sie/hr_idp_vers_nr
                CHANGING p_error TYPE ty_yesno.

  DATA: rc LIKE sy-subrc.

  IF p_interface-s1df-gnrtd = no.
    CALL FUNCTION 'RS_VARIANT_EXISTS'
      EXPORTING
        report              = p_interface-s1df-progr
        variant             = p_interface-s1df-varia
      IMPORTING
        r_c                 = rc
      EXCEPTIONS
        not_authorized      = 1
        no_report           = 2
        report_not_existent = 3
        report_not_supplied = 4
        OTHERS              = 5.
    CASE sy-subrc.
      WHEN 0.
* all ok.
      WHEN 1.
        p_error = yes.
        WRITE:  / icon_red_light AS ICON,
                'Sie haben keine Berechtigung, die Varianten ',
                'des Programmes ', p_interface-s1df-progr,
                'zu lesen'.
      WHEN OTHERS.
        p_error = yes.
        WRITE:  / icon_red_light AS ICON,
                'Das Programm hat keine Variante'.
    ENDCASE.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_SYNTAX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INT_INTERFACE  text
*      -->P_INT_VERSION  text
*      <--P_SW_ERROR  text
*----------------------------------------------------------------------*
FORM check_syntax  USING VALUE(p_interface) TYPE /sie/hr_idp_ifc_db
                    VALUE(p_vrsnr) TYPE /sie/hr_idp_vers_nr
                  CHANGING p_error TYPE ty_yesno.

  DATA: rsrc TYPE /sie/hr_idp_tt_coding
      , f(240)
      , g TYPE i
      , c(72)
      .
  IF p_interface-s1df-gnrtd = no.

    READ REPORT p_interface-s1df-progr INTO rsrc.
    SYNTAX-CHECK FOR rsrc MESSAGE f LINE g WORD c.
    IF sy-subrc >< 0.
      p_error = yes.
      WRITE:  / icon_red_light AS ICON,
              'Das Programm '(013), p_interface-s1df-progr,
              'ist syntaktisch nicht korrekt und daher nicht '(016),
              'ausführbar.'(017).
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_SYNTAX

*&---------------------------------------------------------------------*
*&      Form  CHECK_LOGFILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INT_INTERFACE  text
*      -->P_INT_VERSION  text
*      <--P_SW_ERROR  text
*----------------------------------------------------------------------*
FORM check_logfilename  USING VALUE(p_interface) TYPE /sie/hr_idp_ifc_db
                        VALUE(p_vrsnr) TYPE /sie/hr_idp_vers_nr
                       CHANGING p_error TYPE ty_yesno.

  IF ( p_interface-s1df-filen IS INITIAL ).
    p_error = yes.      "
    WRITE:  / icon_red_light AS ICON,
            'Der logische Dateiname fehlt.'(020).
*    write: / 'ACHTUNG DIESER TEST MUSS AKTIVIERT WERDEN!'.
  ENDIF.

ENDFORM.                    " CHECK_LOGFILENAME

*&---------------------------------------------------------------------*
*&      Form  CHECK_UC4
*&---------------------------------------------------------------------*
*       Prüft ob die UC4 Parameter komplett sind.
*----------------------------------------------------------------------*
FORM check_uc4  USING VALUE(p_interface) TYPE /sie/hr_idp_ifc_db
                       VALUE(p_vrsnr) TYPE /sie/hr_idp_vers_nr
                       CHANGING p_error TYPE ty_yesno.

  IF p_interface-s1df-sftp_transfer = abap_true.

    IF ( p_interface-s1df-uc4fr IS INITIAL ) OR
       ( p_interface-s1df-uc4to IS INITIAL ) OR
       ( p_interface-s1df-filen IS INITIAL ) OR
       ( p_interface-s1df-hostn IS INITIAL ) OR
       ( p_interface-s1df-tcpip IS INITIAL ) OR
       ( p_interface-s1df-portn IS INITIAL ) OR
       ( p_interface-s1df-sftp_publickey IS INITIAL ) OR
*       ( p_interface-s1df-sftp_zielverzeichnis IS INITIAL ) OR
       ( p_interface-s1df-sftp_user IS INITIAL ) .

      p_error = yes.
      WRITE:  / icon_red_light AS ICON,
             'Die UC4 Parametrisierung ist nicht komplett gepflegt.'(021).
    ENDIF.

  ELSE.

    IF ( p_interface-s1df-uc4fr IS INITIAL ) OR
       ( p_interface-s1df-uc4to IS INITIAL ) OR
       ( p_interface-s1df-filen IS INITIAL ) OR
       ( p_interface-s1df-hostn IS INITIAL ) OR
       ( p_interface-s1df-tcpip IS INITIAL ) OR
       ( p_interface-s1df-portn IS INITIAL ) OR
       ( p_interface-s1df-trfad IS INITIAL ) .

      p_error = yes.
      WRITE:  / icon_red_light AS ICON,
             'Die UC4 Parametrisierung ist nicht komplett gepflegt.'(021).
    ENDIF.
  ENDIF.

ENDFORM.                                                    " CHECK_UC4

*---------------------------------------------------------------------*
*       FORM CHECK_UC4_EMAIL                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VALUE(P_INTERFACE)                                            *
*  -->  VALUE(P_VRSNR)                                                *
*  -->  P_ERROR                                                       *
*---------------------------------------------------------------------*
FORM check_uc4_email  USING VALUE(p_interface) TYPE /sie/hr_idp_ifc_db
                       VALUE(p_vrsnr) TYPE /sie/hr_idp_vers_nr
                       CHANGING p_warning TYPE ty_yesno.

  IF ( p_interface-s1df-emerr IS INITIAL ).
    p_warning = yes.
    WRITE:  / icon_yellow_light AS ICON,
           'Die UC4 E-Mail angaben sind nicht komplett gepflegt'(027).
  ENDIF.

ENDFORM.                                                    " CHECK_UC4

*&---------------------------------------------------------------------*
*&      Form  CHECK_PRICING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INT_INTERFACE  text
*      -->P_INT_VERSION  text
*      <--P_SW_WARNING  text
*----------------------------------------------------------------------*
FORM check_pricing USING VALUE(p_interface) TYPE /sie/hr_idp_ifc_db
                         VALUE(p_vrsnr) TYPE /sie/hr_idp_vers_nr
                 CHANGING p_warning TYPE ty_yesno.

  IF ( p_interface-s1pc-kostendr IS INITIAL ) AND
    ( p_interface-s1pc-kostkatp IS INITIAL ).
    p_warning = yes.
    WRITE:  / icon_yellow_light AS ICON,
    'Die Kosten der Schnittstelle sind leer'(030).
  ENDIF.

ENDFORM.                    " CHECK_SELEC

*&---------------------------------------------------------------------*
*&      Form  CHECK_RECNA
*&---------------------------------------------------------------------*
*       Prüft, ob die Satzart nur bestimmte Felder entält
*----------------------------------------------------------------------*
FORM check_recna USING    p_int_interface TYPE /sie/hr_idp_ifc_db
                          p_int_version  TYPE /sie/hr_idp_vers_nr
                 CHANGING p_sw_error     TYPE ty_yesno.


  DATA: ls_s1pg TYPE /sie/hr_idp_s1pg
      , ls_s1sa TYPE /sie/hr_idp_s1sa
      .

  LOOP AT p_int_interface-s1sa INTO ls_s1sa.
    LOOP AT p_int_interface-s1pg INTO ls_s1pg
                                 WHERE recna = ls_s1sa-recna.
      CHECK ls_s1sa-recna >< ls_s1pg-feldname.
      SELECT SINGLE * FROM /sie/hr_idp_f1
               WHERE feldname = ls_s1pg-feldname.
      IF sy-subrc = 0.
        CASE ls_s1sa-recty.
          WHEN 1 OR 5.
            IF /sie/hr_idp_f1-kzhdft = no.
              WRITE:  / icon_red_light AS ICON,
              'Die Satzart '(060),
              ls_s1sa-recna,
             ' ist ein Vor-/Nachlaufsatz, enthält aber Nutzfelder'(061).
              p_sw_error = yes.
            ENDIF.
          WHEN 3 OR 4.
            IF /sie/hr_idp_f1-kzhdft = yes.
              WRITE:  / icon_red_light AS ICON,
              'Die Satzart '(060),
              ls_s1sa-recna,
      ' ist ein Einzel-/Wiederholsatz, enthält aber techn. Felder'(062).
              p_sw_error = yes.
            ENDIF.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " CHECK_RECNA
*&---------------------------------------------------------------------*
*&      Form  CHECK_SINGULARITIES
*&---------------------------------------------------------------------*
FORM check_singularities
                USING
                     VALUE(p_interface) TYPE /sie/hr_idp_ifc_db
                     VALUE(p_vrsnr) TYPE /sie/hr_idp_vers_nr
                 CHANGING
                     p_error TYPE ty_yesno.

  LOOP AT p_interface-s1sa INTO /sie/hr_idp_s1sa.
    LOOP AT p_interface-s1pg INTO /sie/hr_idp_s1pg
                             WHERE recna = /sie/hr_idp_s1sa-recna.
      CLEAR /sie/hr_idp_f1.
      CASE /sie/hr_idp_s1sa-recty.
        WHEN 3.
          IF ( /sie/hr_idp_s1pg-feldname(5) = 'PERNR' ) OR
             ( /sie/hr_idp_s1pg-feldname(8) = /sie/hr_idp_s1sa-recna ).
            /sie/hr_idp_f1-singular = 'X'.
          ELSE.
            SELECT SINGLE * FROM /sie/hr_idp_f1
                        WHERE feldname = /sie/hr_idp_s1pg-feldname.
          ENDIF.
          IF /sie/hr_idp_f1-singular = 'X'.
          ELSE.
            WRITE:  / icon_red_light AS ICON,
                    'Für die Satzart' NO-GAP,
                    /sie/hr_idp_s1sa-recna NO-GAP,
                    ' sind nur singuläre Felder erlaubt.'.
            WRITE: AT /6 /sie/hr_idp_s1pg-feldname NO-GAP,
                     ' ist nicht singulär.' NO-GAP.
            p_error = yes.
          ENDIF.
        WHEN 4.
          IF ( /sie/hr_idp_s1pg-feldname(5) EQ 'PERNR' ) OR
             ( /sie/hr_idp_s1pg-feldname(8) EQ /sie/hr_idp_s1sa-recna ).
            /sie/hr_idp_f1-singular = 'X'.
          ELSE.
            SELECT SINGLE * FROM /sie/hr_idp_f1
                        WHERE feldname = /sie/hr_idp_s1pg-feldname.
          ENDIF.
          IF /sie/hr_idp_f1-singular = 'X'.
          ELSE.
            IF /sie/hr_idp_f1-infty = /sie/hr_idp_s1sa-infty.
            ELSE.
              IF /sie/hr_idp_f1-infty = /sie/hr_idp_s1sa-infty.
                WRITE: / icon_red_light AS ICON,
                         'Die Satzart' NO-GAP,
                         /sie/hr_idp_s1sa-recna NO-GAP,
                         ' erlaubt nur singuläre Felder'.
                WRITE: AT /6 /sie/hr_idp_s1pg-feldname NO-GAP,
                        ' ist nicht singulär.'.
              ELSE.
                CHECK /sie/hr_idp_s1pg-feldname >< /sie/hr_idp_s1sa-recna.
                CHECK /sie/hr_idp_s1pg-feldname >< 'PERNR'. "#EC NOTEXT
                WRITE: / icon_red_light AS ICON,
                         'Die Satzart' NO-GAP,
                         /sie/hr_idp_s1sa-recna NO-GAP,
                         ' erlaubt nur Felder aus dem selben Infotyp.'.
                WRITE: AT /6 /sie/hr_idp_s1pg-feldname NO-GAP,
                        ' ist nicht vom selben Infotyp.'.

              ENDIF.
              p_error = yes.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " CHECK_SINGULARITIES

*&---------------------------------------------------------------------*
*&      Form  CHECK_FIELDS_RECTY
*&---------------------------------------------------------------------*
FORM check_fields_recty USING
                             VALUE(p_interface) TYPE /sie/hr_idp_ifc_db
                             VALUE(p_vrsnr) TYPE /sie/hr_idp_vers_nr
                         CHANGING
                             p_error TYPE ty_yesno.

  LOOP AT p_interface-s1sa INTO /sie/hr_idp_s1sa.
    LOOP AT p_interface-s1pg INTO /sie/hr_idp_s1pg
                             WHERE recna = /sie/hr_idp_s1sa-recna
                             AND   feldname = /sie/hr_idp_s1sa-operan.
    ENDLOOP.
    IF ( sy-subrc = 4 )
    AND ( NOT ( /sie/hr_idp_s1sa-operan IS INITIAL )  ) .
      WRITE: / icon_red_light AS ICON,
               'Der Filter der Satzart ' NO-GAP,
               /sie/hr_idp_s1sa-recna NO-GAP,
               ' enthält Satzartfremde Felder'.
      p_error = yes.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " CHECK_FIELDS_RECTY
