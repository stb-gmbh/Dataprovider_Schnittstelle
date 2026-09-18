*----------------------------------------------------------------------*
*   INCLUDE /SIE/LHR_IDP_F4F03_1010                                    *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_TREE_1010
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_AND_INIT_TREE_1010.
  DATA: NODE_TABLE TYPE NODE_TABLE_TYPE,
        ITEM_TABLE TYPE ITEM_TABLE_TYPE,
        THIS_REPID LIKE SY-REPID,
        THIS_DYNNR LIKE SY-DYNNR.

*  PERFORM BUILD_COLUMN_HEADER.
  PERFORM BUILD_NODE_TABLE_1010 USING NODE_TABLE
                                      ITEM_TABLE.

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
            REGISTER_EVENT_CHECKBOX_CHANGE = NO
            REGISTER_EVENT_LINK_CLICK      = NO
            REGISTER_EVENT_SEL_CHANGE      = NO
            REGISTER_EVENT_HEADER_CLICK    = NO
            NODE_SELECTION_MODE            = TREEV_NODE_SEL_MODE_SINGLE
            ITEM_TABLE_STRUCTURE_NAME      = '/SIE/HR_IDP_F4'
            ITEM_SELECTION                 = NO
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

  PERFORM EXPAND_ROOT_NODES_1010.
  PERFORM ENSURE_VISIBILITY_1010 USING ITEM_TABLE.

ENDFORM.                    " CREATE_AND_INIT_TREE_1010
*&---------------------------------------------------------------------*
*&      Form  build_node_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM BUILD_NODE_TABLE_1010 USING NODE_TABLE TYPE NODE_TABLE_TYPE
                                 ITEM_TABLE TYPE ITEM_TABLE_TYPE.

* Build the node table.
  PERFORM PREPARE_NODE_TABLE_1010.
  PERFORM FILL_ROOT_NODE_1010 USING NODE_TABLE
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
FORM PREPARE_NODE_TABLE_1010.

* Einlesen der Daten aus der DB
  SELECT * FROM /SIE/HR_IDP_F0 INTO TABLE G_ITAB_F0
           WHERE GRTYP = G_GRTYPE.

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
FORM FILL_ROOT_NODE_1010 USING NODE_TABLE TYPE NODE_TABLE_TYPE
                               ITEM_TABLE TYPE ITEM_TABLE_TYPE.

  LOOP AT G_ITAB_F0.
    CHECK G_ITAB_F0-GRKEY = G_ITAB_F0-PARENT.       "roots only...
    PERFORM ADD_NODE_1010 TABLES NODE_TABLE
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
FORM ADD_NODE_1010 TABLES NODE_TABLE TYPE NODE_TABLE_TYPE
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
  ITEM-TEXT = /SIE/HR_IDP_F0T-IDENT.
  APPEND ITEM TO ITEM_TABLE.

* Füge alle Felder hinzu
*  PERFORM FILL_FIELDS_1010 TABLES NODE_TABLE
*                                  ITEM_TABLE
*                            USING P_GRKEY.

* Füge alle Kinder auch gleich hinzu
  LOOP AT G_ITAB_F0 WHERE PARENT = P_GRKEY
             AND   GRKEY <> P_GRKEY.

    PERFORM ADD_NODE_1010 TABLES NODE_TABLE
                                 ITEM_TABLE
                           USING G_ITAB_F0-GRKEY
                                 G_ITAB_F0-PARENT.
  ENDLOOP.
* Auf der letzten Ebene müssen die Gruppierungskeys Feldeigenschaft
* besitzen

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  EXPAND_ROOT_NODES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM EXPAND_ROOT_NODES_1010.
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

*DATA: IDX_KEY TYPE I.


*---------------------------------------------------------------------*
*       FORM FILL_FIELDS                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  NODE_TABLE                                                    *
*  -->  ITEM_TABLE                                                    *
*  -->  P_GRKEY                                                       *
*---------------------------------------------------------------------*
FORM FILL_FIELDS_1010 TABLES NODE_TABLE TYPE NODE_TABLE_TYPE
                             ITEM_TABLE TYPE ITEM_TABLE_TYPE
                             USING P_GRKEY.

  DATA: NODE_KEY LIKE TREEV_ITEM-NODE_KEY,
        NODE TYPE TREEV_NODE,
        ITEM TYPE /SIE/HR_IDP_F4,
        FL_DOCU_EXISTS TYPE TY_YESNO.

  DATA: L_ITAB_F1 TYPE STANDARD TABLE OF /SIE/HR_IDP_F1 INITIAL SIZE 0
      , L_WORK_F1 TYPE /SIE/HR_IDP_F1
      .
  CASE G_GRTYPE.
    WHEN '1'.
      SELECT * FROM /SIE/HR_IDP_F1S INTO CORRESPONDING FIELDS OF
                                    TABLE L_ITAB_F1
                                    WHERE GRKEY = P_GRKEY.

    WHEN '2'.
      SELECT * FROM /SIE/HR_IDP_F1 INTO TABLE L_ITAB_F1
                                    WHERE GRKEY = P_GRKEY.
  ENDCASE.

  SORT L_ITAB_F1 BY SORTN FELDNAME.

  LOOP AT L_ITAB_F1 INTO L_WORK_F1.

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
    IF FL_DOCU_EXISTS = YES.
      NODE-N_IMAGE = ICON_DISPLAY_TEXT.
    ELSE.
      NODE-N_IMAGE = ICON_SPACE.
    ENDIF.
    CLEAR NODE-EXP_IMAGE.
    NODE-EXPANDER = ' '.
    APPEND NODE TO NODE_TABLE.

* Dann die ITEM Informationen

    CLEAR ITEM.
*    item-node_key = l_work_f1-feldname.
    ITEM-NODE_KEY = NODE-NODE_KEY.
    ITEM-CLASS = TREEV_ITEM_CLASS_TEXT.
    ITEM-LENGTH = 20.
    ITEM-LENGTH_PIX = SPACE.
    ITEM-TEXT = L_WORK_F1-FELDNAME.
    ITEM-ITEM_NAME = '2'.
    APPEND ITEM TO ITEM_TABLE.

    CLEAR ITEM.
    ITEM-NODE_KEY = NODE-NODE_KEY.
    ITEM-LENGTH = 60.
    ITEM-LENGTH_PIX = SPACE.
    SELECT SINGLE * FROM /SIE/HR_IDP_F1T WHERE SPRAS = SY-LANGU
                                  AND   FELDNAME = L_WORK_F1-FELDNAME.
    ITEM-TEXT = /SIE/HR_IDP_F1T-IDENT.
    ITEM-ITEM_NAME = '3'.
*     if fl_docu_exists = yes.
*       item-class = treev_item_class_link.
*     else.
    ITEM-CLASS = TREEV_ITEM_CLASS_TEXT.
*     endif.

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
FORM ENSURE_VISIBILITY_1010 USING ITEM_TABLE TYPE ITEM_TABLE_TYPE.

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

*&---------------------------------------------------------------------*
*&      Module  SET_STATUS_1010  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_STATUS_1010 OUTPUT.
  IF G_DISPLAY = YES.
    WA_COMMAND = 'ERTN'.                                    "#EC NOTEXT
    APPEND WA_COMMAND TO G_COMMAND.
  ELSE.
* Do nothing.
  ENDIF.
  WA_COMMAND = 'DOCU'.
  APPEND WA_COMMAND TO G_COMMAND.
  SET PF-STATUS 'MAIN' EXCLUDING G_COMMAND.
  SET TITLEBAR 'MAIN'.
ENDMODULE.                 " SET_STATUS_1010  OUTPUT
