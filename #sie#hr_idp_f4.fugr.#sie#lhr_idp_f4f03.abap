*----------------------------------------------------------------------*
*   INCLUDE /SIE/LHR_IDP_F4F03                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_TREE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_AND_INIT_TREE.
  STATICS: NODE_TABLE TYPE NODE_TABLE_TYPE,
           ITEM_TABLE TYPE ITEM_TABLE_TYPE,
           OLD_GRTYPE TYPE /SIE/HR_IDP_GRKEY.
  DATA: THIS_REPID LIKE SY-REPID,
        THIS_DYNNR LIKE SY-DYNNR.

  DATA: MODE TYPE I
      , FL_ITEM_SEL TYPE TY_YESNO
      , FL_ITEM_DBL TYPE TY_YESNO
      .


  IF G_GRTYPE = 1.
    MODE =  TREEV_NODE_SEL_MODE_MULTIPLE.
    FL_ITEM_SEL = YES.
    FL_ITEM_DBL = YES.
  ELSE.
    MODE =  TREEV_NODE_SEL_MODE_SINGLE.
    FL_ITEM_SEL = NO.
    FL_ITEM_DBL = NO.
  ENDIF.

*  PERFORM BUILD_COLUMN_HEADER.
  IF G_GRTYPE >< OLD_GRTYPE OR OLD_KZHDFT >< G_KZHDFT.
    .
    OLD_GRTYPE = G_GRTYPE.
    OLD_KZHDFT = G_KZHDFT.
    CLEAR: NODE_TABLE[], ITEM_TABLE[], G_ITAB_F0[].
    PERFORM BUILD_NODE_TABLE USING NODE_TABLE
                                   ITEM_TABLE.
  ELSE.
* Bei Selektionsfelder immer neu selektieren
    IF G_GRTYPE = 1.

      OLD_GRTYPE = G_GRTYPE.
      OLD_KZHDFT = G_KZHDFT.
      CLEAR: NODE_TABLE[], ITEM_TABLE[], G_ITAB_F0[].
      PERFORM BUILD_NODE_TABLE USING NODE_TABLE
                                     ITEM_TABLE.

    ENDIF.
  ENDIF.

  THIS_REPID = SY-REPID.
  THIS_DYNNR = SY-DYNNR.
  G_ITEMS[] = ITEM_TABLE[].

  CALL FUNCTION 'TREEV_CREATE_LIST_TREE'
       EXPORTING
            OWNER_REPID                    = THIS_REPID
            DYNNR                          = THIS_DYNNR
            CONTAINER                      = 'TREE_CONTAINER'
            LEFT                           = 0
            TOP                            = 0
            WIDTH                          = 0
            HEIGHT                         = 0
            REGISTER_EVENT_NODE_DBL_CLICK  = YES
            REGISTER_EVENT_ITEM_DBL_CLICK  = FL_ITEM_DBL
            REGISTER_EVENT_CHECKBOX_CHANGE = YES
            REGISTER_EVENT_LINK_CLICK      = NO
            REGISTER_EVENT_SEL_CHANGE      = NO
            REGISTER_EVENT_HEADER_CLICK    = NO
            NODE_SELECTION_MODE            = MODE
            ITEM_TABLE_STRUCTURE_NAME      = '/SIE/HR_IDP_F4'
            ITEM_SELECTION                 = FL_ITEM_SEL
            WITH_HEADERS                   = NO
       TABLES
            NODE_TABLE                     = NODE_TABLE
            ITEM_TABLE                     = ITEM_TABLE
       CHANGING
            HANDLE                         = TREE
       EXCEPTIONS
            CREATE_ERROR                   = 1
            TREE_CONTROL_NOT_EXISTING      = 2
            CNTL_SYSTEM_ERROR              = 3
            FAILED                         = 4
            ILLEGAL_NODE_SELECTION_MODE    = 5
            MISSING_ITEM_STRUCTURE_NAME    = 6
            ERROR_IN_TABLES                = 7
            DP_ERROR                       = 8
            ILLEGAL_OWNER_REPID            = 9
            TABLE_STRUCTURE_NAME_NOT_FOUND = 10
            OTHERS                         = 11.

  IF SY-SUBRC <> 0.
    MESSAGE A001 WITH 'TREEV_CREATE_SIMPLE_TREE'.
  ENDIF.

  PERFORM EXPAND_ROOT_NODES.
  PERFORM ENSURE_VISIBILITY USING ITEM_TABLE.

ENDFORM.                    " CREATE_AND_INIT_TREE
*&---------------------------------------------------------------------*
*&      Form  build_node_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM BUILD_NODE_TABLE USING NODE_TABLE TYPE NODE_TABLE_TYPE
                            ITEM_TABLE TYPE ITEM_TABLE_TYPE.

  DATA: NODE_TAB2 TYPE NODE_TABLE_TYPE.
  DATA: NODE LIKE TREEV_NODE.

* Build the node table.
  PERFORM PREPARE_NODE_TABLE.
  PERFORM FILL_ROOT_NODE USING NODE_TABLE
                               ITEM_TABLE.

  DELETE ADJACENT DUPLICATES FROM NODE_TABLE.

ENDFORM.                    " build_node_table

*&---------------------------------------------------------------------*
*&      Form  PREPARE_NODE_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PREPARE_NODE_TABLE.

  STATICS: OLD_GRTYPE TYPE /SIE/HR_IDP_GRKEY.

* Einlesen der Daten aus der DB
  DESCRIBE TABLE  G_ITAB_F0.
  IF SY-TFILL EQ 0 OR OLD_GRTYPE <> G_GRTYPE.
    CLEAR G_ITAB_F0.
    SELECT * FROM /SIE/HR_IDP_F0 INTO TABLE G_ITAB_F0
             WHERE GRTYP = G_GRTYPE.
    OLD_GRTYPE = G_GRTYPE.
  ENDIF.

* Sortieren der Daten, gemäß angaben in der Tabelle
  SORT G_ITAB_F0 BY PARENT SORTN GRKEY.

ENDFORM.                    " PREPARE_NODE_TABLE

*&---------------------------------------------------------------------*
*&      Form  FILL_NODE_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILL_ROOT_NODE USING NODE_TABLE TYPE NODE_TABLE_TYPE
                          ITEM_TABLE TYPE ITEM_TABLE_TYPE.

  LOOP AT G_ITAB_F0.
    CHECK G_ITAB_F0-GRKEY = G_ITAB_F0-PARENT.       "roots only...
    PERFORM ADD_NODE TABLES NODE_TABLE
                                 ITEM_TABLE
                          USING  G_ITAB_F0-GRKEY
                                 G_ITAB_F0-PARENT.
  ENDLOOP.

ENDFORM.                    " FILL_NODE_TABLE

*---------------------------------------------------------------------*
*       FORM ADD_NODE                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  NODE_TABLE                                                    *
*  -->  P_ITAB_F0                                                     *
*  -->  P_GRKEY                                                       *
*  -->  P_PARENT                                                      *
*---------------------------------------------------------------------*
FORM ADD_NODE TABLES NODE_TABLE TYPE NODE_TABLE_TYPE
                     ITEM_TABLE TYPE ITEM_TABLE_TYPE
              USING  VALUE(P_GRKEY) TYPE /SIE/HR_IDP_F0-GRKEY
                     VALUE(P_PARENT) TYPE /SIE/HR_IDP_F0-PARENT.

* Füge die Informationen zum Knoten hinzu

  DATA: NODE LIKE TREEV_NODE
      , ITEM LIKE /SIE/HR_IDP_F4
      .

  CLEAR NODE.
  NODE-NODE_KEY = G_ITAB_F0-GRKEY.
*  node-node_key = g_itab_f0-idx_key.

* Für Wurzelknoten ein Spezialfall
  IF G_ITAB_F0-GRKEY = G_ITAB_F0-PARENT.
    CLEAR NODE-RELATKEY.
    CLEAR NODE-RELATSHIP.
  ELSE.
    NODE-RELATKEY = G_ITAB_F0-PARENT.
*    node-relatkey = g_itab_f0-idx_parent.
    NODE-RELATSHIP = TREEV_RELAT_LAST_CHILD.
  ENDIF.
  NODE-EXPANDER = SPACE.
  NODE-HIDDEN = SPACE.
  NODE-DISABLED = SPACE.
  NODE-ISFOLDER = 'X'.
  NODE-NO_BRANCH = 'X'.
  CLEAR NODE-N_IMAGE.
  CLEAR NODE-EXP_IMAGE.
  APPEND NODE TO NODE_TABLE.

* Nun die Anzeigedaten zu dem Knoten
  CLEAR ITEM.
  ITEM-NODE_KEY = G_ITAB_F0-GRKEY.
*  item-node_key = node-node_key.
  ITEM-ITEM_NAME = '1'.
  ITEM-CLASS = TREEV_ITEM_CLASS_TEXT.
  ITEM-ALIGNMENT = TREEV_ALIGN_LEFT.
  ITEM-LENGTH = 60.
  ITEM-LENGTH_PIX = SPACE.
  SELECT SINGLE * FROM /SIE/HR_IDP_F0T WHERE SPRAS = SY-LANGU
                                AND GRTYP = G_ITAB_F0-GRTYP
                                AND GRKEY = G_ITAB_F0-GRKEY.
  IF SY-SUBRC = 0.
    ITEM-TEXT = /SIE/HR_IDP_F0T-IDENT.
  ELSE.
    CLEAR ITEM-TEXT.
  ENDIF.
  APPEND ITEM TO ITEM_TABLE.

* Füge alle Felder hinzu
  PERFORM FILL_FIELDS TABLES NODE_TABLE
                             ITEM_TABLE
                      USING P_GRKEY.

* Füge alle Kinder auch gleich hinzu
  LOOP AT G_ITAB_F0 WHERE PARENT = P_GRKEY
             AND   GRKEY <> P_GRKEY.

    PERFORM ADD_NODE TABLES NODE_TABLE
                            ITEM_TABLE
                         USING G_ITAB_F0-GRKEY
                               G_ITAB_F0-PARENT.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  EXPAND_ROOT_NODES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM EXPAND_ROOT_NODES.
  CALL FUNCTION 'TREEV_EXPAND_ROOT_NODES'
       EXPORTING
            HANDLE              = TREE
            LEVEL_COUNT         = 0
            EXPAND_ALL_CHILDREN = SPACE
       EXCEPTIONS
            FAILED              = 1
            ILLEGAL_LEVEL_COUNT = 2
            CNTL_SYSTEM_ERROR   = 3
            OTHERS              = 4.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " EXPAND_ROOT_NODES

*&---------------------------------------------------------------------*
*&      Form  FILL_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_GRKEY  text
*      -->P_ELSE  text
*----------------------------------------------------------------------*

DATA: IDX_KEY TYPE I.


*---------------------------------------------------------------------*
*       FORM FILL_FIELDS                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  NODE_TABLE                                                    *
*  -->  ITEM_TABLE                                                    *
*  -->  P_GRKEY                                                       *
*---------------------------------------------------------------------*
FORM FILL_FIELDS TABLES NODE_TABLE TYPE NODE_TABLE_TYPE
                        ITEM_TABLE TYPE ITEM_TABLE_TYPE
                 USING P_GRKEY.

  DATA: NODE_KEY LIKE TREEV_ITEM-NODE_KEY,
        NODE TYPE TREEV_NODE,
        ITEM TYPE /SIE/HR_IDP_F4,
        FL_DOCU_EXISTS TYPE TY_YESNO,
        IDX_NUM TYPE I.

  DATA: L_ITAB_F1 TYPE STANDARD TABLE OF /SIE/HR_IDP_F1 INITIAL SIZE 0
      , L_WORK_F1 TYPE /SIE/HR_IDP_F1
      .
  CASE G_GRTYPE.
    WHEN '1'.
      SELECT * FROM /SIE/HR_IDP_F1S INTO CORRESPONDING FIELDS OF
                                    TABLE L_ITAB_F1
                                    WHERE GRKEY = P_GRKEY
                                    ORDER BY PRIMARY KEY.

    WHEN '2'.
      SELECT * FROM /SIE/HR_IDP_F1 INTO TABLE L_ITAB_F1
                                    WHERE GRKEY = P_GRKEY
                                    AND   KZHDFT = G_KZHDFT
                                    ORDER BY PRIMARY KEY.
  ENDCASE.


  SORT L_ITAB_F1 BY SORTN FELDNAME.

  LOOP AT L_ITAB_F1 INTO L_WORK_F1.
    CLEAR IDX_NUM. IDX_NUM = 1.
* Wenn Dokumentation existiert, dann soll ein Link darauf verweisen
    FL_DOCU_EXISTS = NO.
    SELECT * FROM /SIE/HR_IDP_F1LT WHERE  SPRAS = SY-LANGU
                                 AND    FELDNAME = L_WORK_F1-FELDNAME.
      FL_DOCU_EXISTS = YES.
      EXIT.
    ENDSELECT.

* Die NODE Informationen zuerst
*    node-node_key = l_work_f1-feldname.
    IDX_KEY = IDX_KEY + 1.
    NODE-NODE_KEY = IDX_KEY.
    NODE-RELATKEY = L_WORK_F1-GRKEY.
    NODE-RELATSHIP = TREEV_RELAT_LAST_CHILD.
    NODE-HIDDEN = ' '.
    NODE-DISABLED = ' '.
    NODE-ISFOLDER = ' '.
    CLEAR NODE-EXP_IMAGE.
    NODE-N_IMAGE = 'BNONE'. "#EC NOTEXT
    NODE-EXPANDER = ' '.
    APPEND NODE TO NODE_TABLE.

* Dann die ITEM Informationen
    IF G_GRTYPE = 1.
      CLEAR ITEM.
      ITEM-NODE_KEY = NODE-NODE_KEY.
      ITEM-CLASS = TREEV_ITEM_CLASS_CHECKBOX. " Item is a checkbox
      READ TABLE G_SEL_FIELDS WITH KEY FELDNAME = L_WORK_F1-FELDNAME.
      IF SY-SUBRC >< 0.
        ITEM-CHOSEN = NO.
      ELSE.
        ITEM-CHOSEN = YES.
      ENDIF.
      ITEM-EDITABLE = YES.
      ITEM-LENGTH = 20.
      ITEM-TEXT = L_WORK_F1-FELDNAME.
      ITEM-ITEM_NAME = IDX_NUM. IDX_NUM = IDX_NUM + 1.
      APPEND ITEM TO ITEM_TABLE.
    ELSE.
      CLEAR ITEM.
      ITEM-NODE_KEY = NODE-NODE_KEY.
      ITEM-CLASS =  TREEV_ITEM_CLASS_TEXT.
      ITEM-LENGTH = 20.
      ITEM-TEXT = L_WORK_F1-FELDNAME.
      ITEM-ITEM_NAME = IDX_NUM. IDX_NUM = IDX_NUM + 1.
      APPEND ITEM TO ITEM_TABLE.
    ENDIF.

    CLEAR ITEM.
    ITEM-NODE_KEY = NODE-NODE_KEY.
    ITEM-LENGTH = 60.
    ITEM-LENGTH_PIX = SPACE.
    SELECT SINGLE * FROM /SIE/HR_IDP_F1T WHERE SPRAS = SY-LANGU
                                  AND   FELDNAME = L_WORK_F1-FELDNAME.
    IF SY-SUBRC = 0.
      ITEM-TEXT = /SIE/HR_IDP_F1T-IDENT.
    ELSE.
      CLEAR ITEM-TEXT.
    ENDIF.
    ITEM-ITEM_NAME = IDX_NUM. IDX_NUM = IDX_NUM + 1.
    ITEM-CLASS = TREEV_ITEM_CLASS_TEXT.

    IF FL_DOCU_EXISTS = YES.
      ITEM-T_IMAGE = ICON_DISPLAY_TEXT.
    ELSE.
      ITEM-T_IMAGE = ICON_SPACE.
    ENDIF.

    APPEND ITEM TO ITEM_TABLE.

  ENDLOOP.

ENDFORM.                    " FILL_FIELDS

*&---------------------------------------------------------------------*
*&      Form  ENSURE_VISIBILITY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ENSURE_VISIBILITY USING ITEM_TABLE TYPE ITEM_TABLE_TYPE.

  DATA: ITEM LIKE TREEV_ITEM
      , SHOW_FIELD TYPE TEXT60
      .

  IMPORT SHOW_FIELD FROM MEMORY ID '/SIE/HR_IDP_IFC'.
  CHECK NOT ( SHOW_FIELD IS INITIAL ).
  LOOP AT ITEM_TABLE INTO ITEM WHERE TEXT = SHOW_FIELD.
    CALL FUNCTION 'TREEV_ENSURE_VISIBLE'
         EXPORTING
              HANDLE            = TREE
              NODE_KEY          = ITEM-NODE_KEY
         EXCEPTIONS
              FAILED            = 1
              NODE_NOT_FOUND    = 2
              CNTL_SYSTEM_ERROR = 3
              OTHERS            = 4.
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    EXIT.
  ENDLOOP.

ENDFORM.                    " ENSURE_VISIBILITY
