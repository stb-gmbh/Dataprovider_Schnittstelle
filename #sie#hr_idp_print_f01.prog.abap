*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_PRINT_F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SEARCH_DATA
*&---------------------------------------------------------------------*
*       Die Ergebnisse der DB-Selektion werden in g_data gesammelt
*----------------------------------------------------------------------*
FORM SEARCH_DATA.
  CLEAR: G_DATA[], G_INFTY[], G_LGART, G_GEBIL[], G_KTO[].
* Nach den Infotyp-Felder suchen
  IF NOT ( P_INFTY IS INITIAL ).
    PERFORM SEARCH_INFTY.
  ENDIF.
* Nach den Lohnarten-Felder suchen
  IF NOT ( P_LGART IS INITIAL ).
    PERFORM SEARCH_LGART.
  ENDIF.
* Nach den Gebildeten Begriffen suchen
  IF NOT ( P_GEBIL IS INITIAL ).
    PERFORM SEARCH_BEGRIFFE.
  ENDIF.
* Nach den Gebildeten Begriffen suchen
  IF NOT ( P_KTO IS INITIAL ).
    PERFORM SEARCH_KTO.
  ENDIF.
  PERFORM CONSOLIDATE_DATA.
  PERFORM ADDITIONAL_SEARCH.
  PERFORM INSERT_PARENT.
  PERFORM FILL_ROOT_NODE USING NODE_TABLE
*                               ITEM_TABLE
                                          .

  SELECT * INTO TABLE G_F0T FROM /SIE/HR_IDP_F0T.
  IF SY-SUBRC NE 0.
    MESSAGE E001.
  ENDIF.
  LOOP AT NODE_TABLE INTO WA_NODE.
    AT NEW NODE_KEY.
      READ TABLE G_F0T WITH KEY MANDT = SY-MANDT
                                SPRAS = SY-LANGU
                                GRTYP = '2'
                                GRKEY = WA_NODE-NODE_KEY.
      IF SY-SUBRC EQ 0.
*        write: / g_f0t-ident.
      ELSE.
        READ TABLE G_DATA INTO WA_DATA
          WITH KEY FELDNAME = WA_NODE-NODE_KEY.
        IF SY-SUBRC EQ 0.
*          write: /10 wa_data-feldname.
        ENDIF.
      ENDIF.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " SEARCH_DATA

*&---------------------------------------------------------------------*
*&      Form  SEARCH_INFTY
*&---------------------------------------------------------------------*
*       Zusammenstellung der Infotyp-Felder
*----------------------------------------------------------------------*
FORM SEARCH_INFTY.

  DATA: H_DATA TYPE STANDARD TABLE OF /SIE/HR_IDP_FIELDSEARCH
        INITIAL SIZE 0
      .

* Zunächst werden alle angegebenen Felder eingelesen.

  SELECT DISTINCT A~FELDNAME DPFTYPE INFTY INFTYFELD IDENT GRKEY
*           UP TO LOOPC ROWS
           INTO (/SIE/HR_IDP_F1-FELDNAME,
                 /SIE/HR_IDP_F1-DPFTYPE,
                 /SIE/HR_IDP_F1-INFTY,
                 /SIE/HR_IDP_F1-INFTYFELD,
                 /SIE/HR_IDP_F1T-IDENT,
                 /SIE/HR_IDP_F1-GRKEY)
           FROM /SIE/HR_IDP_F1 AS A
           LEFT JOIN /SIE/HR_IDP_F1T AS B
           ON A~FELDNAME = B~FELDNAME
*           WHERE A~FELDNAME IN P_KEY1
           AND  DPFTYPE = '1'
*           AND   CR_UNAME IN P_CRNAM
*           AND   DATUM IN    P_DATUM
*           AND   UNAME IN    P_UNAME
           AND   INFTY IN    P_INFOT.
*           AND   SUBTY IN   P_SUBTY
*           AND INFTYFELD IN P_IFELD
*           AND KONVNAME IN P_KVNAME.
            .
    CHECK: NOT ( /SIE/HR_IDP_F1-INFTY IS INITIAL ) .

    MOVE-CORRESPONDING /SIE/HR_IDP_F1 TO WA_DATA.
    MOVE /SIE/HR_IDP_F1T-IDENT TO WA_DATA-IDENT.
    CLEAR /SIE/HR_IDP_F1T.
    APPEND WA_DATA TO G_INFTY.
  ENDSELECT.

* Nun wird geschaut, ob die Texte auch stimmen.
  CLEAR H_DATA[].
  LOOP AT G_INFTY INTO WA_DATA.
*                  WHERE IDENT IN P_XTEXT.
    APPEND WA_DATA TO H_DATA.
  ENDLOOP.

  CLEAR G_INFTY. G_INFTY[] = H_DATA[].
ENDFORM.                    " SEARCH_INFTY

*&---------------------------------------------------------------------*
*&      Form  SEARCH_LGART
*&---------------------------------------------------------------------*
*       Zusammenstellung der Lohnarten-Texte
*----------------------------------------------------------------------*
FORM SEARCH_LGART.
  DATA: H_DATA TYPE STANDARD TABLE OF /SIE/HR_IDP_FIELDSEARCH
        INITIAL SIZE 0
      .

* Zunächst werden alle angegeben Felder eingelesen.
  SELECT DISTINCT A~FELDNAME DPFTYPE ACLTAB ACLFELD RTLGART RTKZ IDENT
    GRKEY
*           UP TO LOOPC ROWS
           INTO (/SIE/HR_IDP_F1-FELDNAME,
                 /SIE/HR_IDP_F1-DPFTYPE,
                 /SIE/HR_IDP_F1-ACLTAB,
                 /SIE/HR_IDP_F1-ACLFELD,
                 /SIE/HR_IDP_F1-RTLGART,
                 /SIE/HR_IDP_F1-RTKZ,
                 /SIE/HR_IDP_F1T-IDENT,
                 /SIE/HR_IDP_F1-GRKEY)
           FROM /SIE/HR_IDP_F1 AS A
           LEFT JOIN /SIE/HR_IDP_F1T AS B
           ON A~FELDNAME = B~FELDNAME
           WHERE A~FELDNAME IN P_KEY1
          AND  DPFTYPE = '4'
*          AND   CR_UNAME IN P_CRNAM
*          AND   DATUM IN    P_DATUM
*          AND   UNAME IN    P_UNAME
          AND   ACLTAB IN    P_ACLTAB
*          AND   ACLFELD IN   P_ACLFLD
          AND RTLGART IN P_RTLGRT
*          AND RTKZ IN P_RTKZ.
*          AND KONVNAME IN P_KVNAME.
           .

    CHECK: NOT ( /SIE/HR_IDP_F1-RTLGART IS INITIAL ) .

    MOVE-CORRESPONDING /SIE/HR_IDP_F1 TO WA_DATA.
    MOVE /SIE/HR_IDP_F1T-IDENT TO WA_DATA-IDENT.
    CLEAR /SIE/HR_IDP_F1T.
    APPEND WA_DATA TO G_LGART.
  ENDSELECT.

* Nun wird geschaut, ob die Texte auch stimmen.
  CLEAR H_DATA[].
  LOOP AT G_LGART INTO WA_DATA.
*                  WHERE IDENT IN P_XTEXT.
    APPEND WA_DATA TO H_DATA.
  ENDLOOP.

  CLEAR G_LGART. G_LGART[] = H_DATA[].

ENDFORM.                    " SEARCH_LGART

*&---------------------------------------------------------------------*
*&      Form  SEARCH_BEGRIFFE
*&---------------------------------------------------------------------*
*       Zusammenstellung der gebildeten Begriffen
*----------------------------------------------------------------------*
FORM SEARCH_BEGRIFFE.
  DATA: H_DATA TYPE STANDARD TABLE OF /SIE/HR_IDP_FIELDSEARCH
        INITIAL SIZE 0
        .

  SELECT DISTINCT A~FELDNAME DPFTYPE IDENT GRKEY
*           UP TO LOOPC ROWS
           INTO (/SIE/HR_IDP_F1-FELDNAME,
                 /SIE/HR_IDP_F1-DPFTYPE,
                 /SIE/HR_IDP_F1T-IDENT,
                 /SIE/HR_IDP_F1-GRKEY)
           FROM /SIE/HR_IDP_F1 AS A
           LEFT JOIN /SIE/HR_IDP_F1T AS B
           ON A~FELDNAME = B~FELDNAME
           WHERE A~FELDNAME IN P_KEY1
           AND  DPFTYPE = '2'.
*           AND   CR_UNAME IN P_CRNAM
*           AND   DATUM IN    P_DATUM
*           AND   UNAME IN    P_UNAME.

    MOVE-CORRESPONDING /SIE/HR_IDP_F1 TO WA_DATA.
    MOVE /SIE/HR_IDP_F1T-IDENT TO WA_DATA-IDENT.
    CLEAR /SIE/HR_IDP_F1T.
    APPEND WA_DATA TO G_GEBIL.
  ENDSELECT.

* nun wird geschaut, ob die texte auch stimmen.
  CLEAR H_DATA[].
  LOOP AT G_GEBIL INTO WA_DATA.
*                  WHERE IDENT IN P_XTEXT.
    APPEND WA_DATA TO H_DATA.
  ENDLOOP.

  CLEAR G_GEBIL. G_GEBIL[] = H_DATA[].

ENDFORM.                    " SEARCH_BEGRIFFE

*&---------------------------------------------------------------------*
*&      Form  SEARCH_KTO
*&---------------------------------------------------------------------*
*       Zusammenstellung der Lohnkontofelder
*----------------------------------------------------------------------*
FORM SEARCH_KTO.
  DATA: H_DATA TYPE STANDARD TABLE OF /SIE/HR_IDP_FIELDSEARCH
        INITIAL SIZE 0
        .

* Zunächst werden alle angegebenen Felder eingelesen.

  SELECT DISTINCT A~FELDNAME DPFTYPE INFTY INFTYFELD IDENT GRKEY
*           UP TO LOOPC ROWS
           INTO (/SIE/HR_IDP_F1-FELDNAME,
                 /SIE/HR_IDP_F1-DPFTYPE,
                 /SIE/HR_IDP_F1-INFTY,
                 /SIE/HR_IDP_F1-INFTYFELD,
                 /SIE/HR_IDP_F1T-IDENT,
                 /SIE/HR_IDP_F1-GRKEY)
           FROM /SIE/HR_IDP_F1 AS A
           LEFT JOIN /SIE/HR_IDP_F1T AS B
           ON A~FELDNAME = B~FELDNAME
           WHERE A~FELDNAME IN P_KEY1
           AND  DPFTYPE = '3'
*           AND   CR_UNAME IN P_CRNAM
*           AND   DATUM IN    P_DATUM
*           AND   UNAME IN    P_UNAME
           AND   ACLTAB IN   P_ACLTAB
*           AND   ACLFELD IN   P_ACLFLD.
*           AND KONVNAME IN P_KVNAME.
           .

    CHECK: NOT ( /SIE/HR_IDP_F1-INFTY IS INITIAL ) .

    MOVE-CORRESPONDING /SIE/HR_IDP_F1 TO WA_DATA.
    MOVE /SIE/HR_IDP_F1T-IDENT TO WA_DATA-IDENT.
    CLEAR /SIE/HR_IDP_F1T.
    APPEND WA_DATA TO G_INFTY.
  ENDSELECT.

* Nun wird geschaut, ob die Texte auch stimmen.
  CLEAR H_DATA[].
  LOOP AT G_KTO INTO WA_DATA.
*                  WHERE IDENT IN P_XTEXT.
    APPEND WA_DATA TO H_DATA.
  ENDLOOP.

  CLEAR G_KTO. G_KTO[] = H_DATA[].

ENDFORM.                    " SEARCH_KTO

*&---------------------------------------------------------------------*
*&      Form  CONSOLIDATE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CONSOLIDATE_DATA.
  APPEND LINES OF G_INFTY TO G_DATA.
  APPEND LINES OF G_LGART TO G_DATA.
  APPEND LINES OF G_GEBIL TO G_DATA.
  APPEND LINES OF G_KTO TO G_DATA.
ENDFORM.                    " CONSOLIDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  ADDITIONAL_SEARCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ADDITIONAL_SEARCH.
  DATA: L_INFTY_NAME(6) TYPE C VALUE 'PSxxxx'
      , L_DATA TYPE STANDARD TABLE OF  /SIE/HR_IDP_FIELDSEARCH
               INITIAL SIZE 0
      .

  RANGES: LR_FELDER FOR /SIE/HR_IDP_F1-FELDNAME.

  CLEAR L_DATA[].
  LOOP AT G_DATA INTO WA_DATA.

* Haben wir es mit Infotyp Felder zu tun, dann die Namen aufbauen
    IF ( WA_DATA-DPFTYPE = '1' ).
      WRITE WA_DATA-INFTY TO L_INFTY_NAME+2(4).
      PERFORM GET_DDIC USING    L_INFTY_NAME
                                WA_DATA-INFTYFELD
                       CHANGING WA_DATA-DATATYPE
                                WA_DATA-LENG.
    ENDIF.

* Lohnartenbehandlung
    IF ( WA_DATA-DPFTYPE = '4' ).
      WA_DATA-LENG = 15.   " Ist bei allen drei 15.
      CASE WA_DATA-RTKZ.
        WHEN 'A'.
          WA_DATA-DATATYPE = 'CURR'.
        WHEN 'N'.
          WA_DATA-DATATYPE = 'DEC'.
        WHEN 'R'.
          WA_DATA-DATATYPE = 'CURR'.
        WHEN OTHERS.
* Sollte es nicht geben.
      ENDCASE.
    ENDIF.

* Prüfen ob die Typenangabe und Länge stimmen.
    IF ( WA_DATA-DATATYPE IN P_TYPE ).
      IF ( WA_DATA-LENG IN P_LEN ).
        APPEND WA_DATA TO L_DATA.
      ENDIF.
    ENDIF.

  ENDLOOP.
  CLEAR G_DATA[]. G_DATA[] = L_DATA[]. CLEAR L_DATA[].

* Langtextsuche.
  CLEAR LR_FELDER[].
  LOOP AT G_DATA INTO WA_DATA.
    LR_FELDER-SIGN = 'I'.
    LR_FELDER-OPTION = 'EQ'.
    LR_FELDER-LOW = WA_DATA-FELDNAME.
    APPEND LR_FELDER.
  ENDLOOP.

  CLEAR WA_DATA.
  SELECT * FROM /SIE/HR_IDP_F1LT.
    WA_DATA-FELDNAME = /SIE/HR_IDP_F1LT-FELDNAME.
    APPEND WA_DATA TO L_DATA.
  ENDSELECT.

  LOOP AT G_DATA INTO WA_DATA.
    READ TABLE L_DATA WITH KEY FELDNAME = WA_DATA-FELDNAME
                      TRANSPORTING NO FIELDS.
    IF SY-SUBRC >< 0.
* Vor dem Löschen sollte aber noch geprüft werden, ob das Feld
* überhaupt Dokumentation besitzt. Ansonsten wird es gelöscht.
SELECT SINGLE * FROM /SIE/HR_IDP_F1LT WHERE FELDNAME = WA_DATA-FELDNAME.
      IF SY-SUBRC >< 0.
* Feld existiert nicht in der Datenbank. Das Feld behalten.
      ELSE.
        DELETE G_DATA.
      ENDIF.
    ELSE.
* Alles in Ordnung. Das Feld behalten.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " ADDITIONAL_SEARCH

*&---------------------------------------------------------------------*
*&      Form  GET_DDIC
*&---------------------------------------------------------------------*
FORM GET_DDIC USING    P_NAME
                       P_FELD
              CHANGING P_TYPE
                       P_LENG.
  DATA: L_DFIES TYPE DFIES
      , L_FIELDNAME TYPE  DFIES-LFIELDNAME
      , L_TABNAME TYPE DCOBJDEF-NAME
      .

  L_TABNAME = P_NAME.
  L_FIELDNAME = P_FELD.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
       EXPORTING
            TABNAME        = L_TABNAME
            LANGU          = SY-LANGU
            LFIELDNAME     = L_FIELDNAME
       IMPORTING
            DFIES_WA       = L_DFIES
       EXCEPTIONS
            NOT_FOUND      = 1
            INTERNAL_ERROR = 2
            OTHERS         = 3.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    P_TYPE = L_DFIES-DATATYPE.
    P_LENG = L_DFIES-LENG.
  ENDIF.

ENDFORM.                    " GET_DDIC

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       Übergabe Feldkatalog an ABAP List-Viewer
*----------------------------------------------------------------------*
FORM DISPLAY_DATA.
  PERFORM VARIANT_INIT.
  PERFORM FILL_LAYOUT CHANGING GS_LAYOUT.
  PERFORM FILL_FIELDCAT CHANGING GT_FIELDCAT.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
       EXPORTING
            I_CALLBACK_PROGRAM       = G_REPID
            I_CALLBACK_PF_STATUS_SET = 'CALLBACK_PF_STATUS_SET'
            I_CALLBACK_USER_COMMAND  = 'CALLBACK_USER_COMMAND'
*            i_structure_name         = '/SIE/HR_IDP_FIELDSEARCH'
            IS_LAYOUT                = GS_LAYOUT
            IT_FIELDCAT              = GT_FIELDCAT
       TABLES
            T_OUTTAB                 = G_DATA
       EXCEPTIONS
            PROGRAM_ERROR            = 1
            OTHERS                   = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " DISPLAY_DATA

*&---------------------------------------------------------------------*
*&      Form  VARIANT_INIT
*&---------------------------------------------------------------------*
FORM VARIANT_INIT.
  CLEAR G_VARIANT.
  G_VARIANT-REPORT = G_REPID.
ENDFORM.                    " VARIANT_INIT

*&---------------------------------------------------------------------*
*&      Form  FILL_LAYOUT
*&---------------------------------------------------------------------*
*       Füllt die Layout Feldleiste
*----------------------------------------------------------------------*
FORM FILL_LAYOUT CHANGING P_GS_LAYOUT TYPE SLIS_LAYOUT_ALV.
  P_GS_LAYOUT-ZEBRA = YES.
  P_GS_LAYOUT-COLWIDTH_OPTIMIZE = YES.
* p_gs_layout-box_fieldname = 'MARK'.
ENDFORM.                    " FILL_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  FILL_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_FIELDCAT CHANGING P_GT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

  DATA: LS_FIELDCAT TYPE SLIS_FIELDCAT_ALV.

  CLEAR P_GT_FIELDCAT[].

  LS_FIELDCAT-TABNAME       = G_TABNAME.
  LS_FIELDCAT-FIELDNAME     = 'FELDNAME'.
  LS_FIELDCAT-KEY           = 'X'.        "sets key field
  APPEND LS_FIELDCAT TO P_GT_FIELDCAT.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
       EXPORTING
            I_PROGRAM_NAME         = G_REPID
            I_INTERNAL_TABNAME     = G_TABNAME
            I_STRUCTURE_NAME       = '/SIE/HR_IDP_FIELDSEARCH'
            I_CLIENT_NEVER_DISPLAY = 'X'
       CHANGING
            CT_FIELDCAT            = P_GT_FIELDCAT
       EXCEPTIONS
            INCONSISTENT_INTERFACE = 1
            PROGRAM_ERROR          = 2
            OTHERS                 = 3.

  DELETE P_GT_FIELDCAT WHERE FIELDNAME = 'DPFTYPE'.
  DELETE P_GT_FIELDCAT WHERE FIELDNAME = 'INFTY'.
  DELETE P_GT_FIELDCAT WHERE FIELDNAME = 'INFTYFELD'.
  DELETE P_GT_FIELDCAT WHERE FIELDNAME = 'ACLTAB'.
  DELETE P_GT_FIELDCAT WHERE FIELDNAME = 'ACLFELD'.
  DELETE P_GT_FIELDCAT WHERE FIELDNAME = 'RTLGART'.
  DELETE P_GT_FIELDCAT WHERE FIELDNAME = 'RTKZ'.

ENDFORM.                    " FILL_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  INSERT_PARENT
*&---------------------------------------------------------------------*
*       Einpflegen des Feldes PARENT in g_data
*----------------------------------------------------------------------*
FORM INSERT_PARENT.
  DATA SAVE_PARENT LIKE /SIE/HR_IDP_F0-PARENT.
  SELECT * INTO TABLE G_F0 FROM /SIE/HR_IDP_F0.
  IF SY-SUBRC NE 0.
    MESSAGE E001.
  ENDIF.
  SORT G_DATA BY GRKEY.
  SORT G_F0 BY GRKEY.
  LOOP AT G_F0.
    SAVE_PARENT = G_F0-PARENT.
    AT NEW GRKEY.
      LOOP AT G_DATA INTO WA_DATA WHERE GRKEY EQ G_F0-GRKEY.
        WA_DATA-PARENT = SAVE_PARENT.
        MODIFY G_DATA FROM WA_DATA.
      ENDLOOP.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " INSERT_PARENT

*&---------------------------------------------------------------------*
*&      Form  FILL_ROOT_NODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_ROOT_NODE USING NODE_TABLE TYPE NODE_TABLE_TYPE
*                          ITEM_TABLE TYPE ITEM_TABLE_TYPE
                                                          .
  LOOP AT G_F0.
    CHECK G_F0-GRKEY = G_F0-PARENT.                "roots only...
    PERFORM ADD_NODE TABLES NODE_TABLE
*                            ITEM_TABLE
                     USING  G_F0-GRKEY
                            G_F0-PARENT.
  ENDLOOP.
ENDFORM.                    " FILL_ROOT_NODE

*&---------------------------------------------------------------------*
*&      Form  ADD_NODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ADD_NODE TABLES NODE_TABLE TYPE NODE_TABLE_TYPE
*                     ITEM_TABLE TYPE ITEM_TABLE_TYPE
              USING  VALUE(P_GRKEY) TYPE /SIE/HR_IDP_F0-GRKEY
                     VALUE(P_PARENT) TYPE /SIE/HR_IDP_F0-PARENT.

* Füge die Informationen zum Knoten hinzu

  DATA: NODE LIKE TREEV_NODE
*      , ITEM LIKE /SIE/HR_IDP_F4
       .

WRITE: / 'Gruppe: ', P_GRKEY.


  CLEAR NODE.
  NODE-NODE_KEY = G_F0-GRKEY.
* Für Wurzelknoten ein Spezialfall
  IF G_F0-GRKEY = G_F0-PARENT.
    CLEAR NODE-RELATKEY.
    CLEAR NODE-RELATSHIP.
  ELSE.
    NODE-RELATKEY = G_F0-PARENT.
    NODE-RELATSHIP = TREEV_RELAT_LAST_CHILD.
  ENDIF.
  NODE-EXPANDER  = SPACE.
  NODE-HIDDEN    = SPACE.
  NODE-DISABLED  = SPACE.
  NODE-ISFOLDER  = 'X'.
  NODE-NO_BRANCH = 'X'.
  CLEAR NODE-N_IMAGE.
  CLEAR NODE-EXP_IMAGE.
  APPEND NODE TO NODE_TABLE.

* Nun die Anzeigedaten zu dem Knoten
*  CLEAR ITEM.
*  ITEM-NODE_KEY = G_F0-GRKEY.
*  ITEM-ITEM_NAME = '1'.
*  ITEM-CLASS = TREEV_ITEM_CLASS_TEXT.
*  ITEM-ALIGNMENT = TREEV_ALIGN_LEFT.
*  ITEM-LENGTH = 60.
*  ITEM-LENGTH_PIX = SPACE.
*  SELECT SINGLE * FROM /SIE/HR_IDP_F0T WHERE SPRAS = SY-LANGU
*                                         AND GRKEY = G_F0-GRKEY.
*  ITEM-TEXT = /SIE/HR_IDP_F0T-IDENT.
*  APPEND ITEM TO ITEM_TABLE.

* Füge alle Felder hinzu
  PERFORM FILL_FIELDS TABLES NODE_TABLE
*                             ITEM_TABLE
                      USING  P_GRKEY.

* Füge alle Kinder hinzu
  LOOP AT G_F0 WHERE PARENT = P_GRKEY
               AND   GRKEY <> P_GRKEY.

    PERFORM ADD_NODE TABLES NODE_TABLE
*                            ITEM_TABLE
                      USING G_F0-GRKEY
                            G_F0-PARENT.
  ENDLOOP.
ENDFORM.                    " ADD_NODE

*&---------------------------------------------------------------------*
*&      Form  FILL_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_FIELDS TABLES NODE_TABLE TYPE NODE_TABLE_TYPE
*                        ITEM_TABLE TYPE ITEM_TABLE_TYPE
                 USING  P_GRKEY.

  DATA: NODE_KEY LIKE TREEV_ITEM-NODE_KEY
      ,  NODE TYPE TREEV_NODE
*     ,   ITEM TYPE /SIE/HR_IDP_F4
      ,  FL_DOCU_EXISTS TYPE TY_YESNO
      .

  DATA: L_ITAB_F1 TYPE STANDARD TABLE OF /SIE/HR_IDP_F1 INITIAL SIZE 0
      , L_WORK_F1 TYPE /SIE/HR_IDP_F1
      .

  SELECT * FROM /SIE/HR_IDP_F1 INTO TABLE L_ITAB_F1
    WHERE GRKEY = P_GRKEY.
    LOOP AT L_ITAB_F1 INTO L_WORK_F1.

* Wenn Dokumentation existiert, dann soll ein Link darauf verweisen
      FL_DOCU_EXISTS = NO.
      SELECT * FROM /SIE/HR_IDP_F1LT WHERE  SPRAS = SY-LANGU
        AND FELDNAME = L_WORK_F1-FELDNAME.
      FL_DOCU_EXISTS = YES.
      EXIT.
      ENDSELECT.

* Die NODE Informationen zuerst
    NODE-NODE_KEY = L_WORK_F1-FELDNAME.
    NODE-RELATKEY = L_WORK_F1-GRKEY.
    NODE-RELATSHIP = TREEV_RELAT_LAST_CHILD.
    NODE-HIDDEN = ' '.
    NODE-DISABLED = ' '.
    NODE-ISFOLDER = ' '.
*    IF FL_DOCU_EXISTS = YES.
*    NODE-N_IMAGE = ICON_DISPLAY_TEXT.
*    ELSE.
*    NODE-N_IMAGE = ICON_SPACE.
*    ENDIF.
    CLEAR NODE-EXP_IMAGE.
    NODE-EXPANDER = ' '.
    APPEND NODE TO NODE_TABLE.

WRITE: / '            ' , NODE-NODE_KEY .

* Dann die ITEM Informationen

*    CLEAR ITEM.
*    ITEM-NODE_KEY = L_WORK_F1-FELDNAME.
*    ITEM-CLASS = TREEV_ITEM_CLASS_TEXT.
*    ITEM-LENGTH = 20.
*    ITEM-LENGTH_PIX = SPACE.
*    ITEM-TEXT = L_WORK_F1-FELDNAME.
*    ITEM-ITEM_NAME = '2'.
*    APPEND ITEM TO ITEM_TABLE.
*
*    CLEAR ITEM.
*    ITEM-NODE_KEY = L_WORK_F1-FELDNAME.
*    ITEM-LENGTH = 60.
*    ITEM-LENGTH_PIX = SPACE.
*    SELECT SINGLE * FROM /SIE/HR_IDP_F1T WHERE SPRAS = SY-LANGU
*                                  AND   FELDNAME = L_WORK_F1-FELDNAME.
*    ITEM-TEXT = /SIE/HR_IDP_F1T-IDENT.
*    ITEM-ITEM_NAME = '3'.
*    IF FL_DOCU_EXISTS = YES.
*      ITEM-CLASS = TREEV_ITEM_CLASS_LINK.
*    ELSE.
*      ITEM-CLASS = TREEV_ITEM_CLASS_TEXT.
*    ENDIF.
*
*    APPEND ITEM TO ITEM_TABLE.
  ENDLOOP.

ENDFORM.                    " FILL_FIELDS
