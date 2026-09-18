*----------------------------------------------------------------------*
*   INCLUDE /SIE/LHR_IDP_F4F04                                         *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       CALLBACK  HANDLE_TREE_EXPAND_NC
*---------------------------------------------------------------------*
*allback handle_tree_expand_nc.
*
*ata: node_key like treev_item-node_key,
*     node_table type node_table_type,
*     node type treev_node,
*     item_table type item_table_type,
*     item type /sie/hr_idp_f4.
*
*all function 'TREEV_GET_EP_EXPAND_NC'
*    exporting
*         handle            = tree
*    importing
*         node_key          = node_key
*    exceptions
*         failed            = 1
*         cntl_system_error = 2
*         others            = 3.
*f sy-subrc <> 0.
* message a001 with 'TREEV_GET_EP_EXPAND_NC'.
*ndif.
*
*ndcallback.

CALLBACK HANDLE_TREE_NODE_DBL_CLK.

DATA NODE_KEY LIKE TREEV_ITEM-NODE_KEY.

CALL FUNCTION 'TREEV_GET_EP_NODE_DBL_CLK'
     EXPORTING
          HANDLE            = TREE
     IMPORTING
          NODE_KEY          = NODE_KEY
     EXCEPTIONS
          FAILED            = 1
          CNTL_SYSTEM_ERROR = 2
          OTHERS            = 3.
IF SY-SUBRC <> 0.
  MESSAGE A001 WITH 'TREEV_GET_EP_NODE_DBL_CLK'.
ENDIF.
G_NODE_KEY = NODE_KEY.

G_SEL_FIELDS-FELDNAME = G_NODE_KEY.
APPEND G_SEL_FIELDS.

ENDCALLBACK.

CALLBACK HANDLE_TREE_ITEM_DBL_CLK.
DATA NODE_KEY LIKE TREEV_ITEM-NODE_KEY.
DATA ITEM_NAME LIKE TREEV_ITEM-ITEM_NAME.
DATA L_FELDNAME TYPE /SIE/HR_IDP_FNAME.
CALL FUNCTION 'TREEV_GET_EP_ITEM_DBL_CLK'
     EXPORTING
          HANDLE            = TREE
     IMPORTING
          NODE_KEY          = NODE_KEY
          ITEM_NAME         = ITEM_NAME
     EXCEPTIONS
          FAILED            = 1
          CNTL_SYSTEM_ERROR = 2
          OTHERS            = 3.
IF SY-SUBRC <> 0.
  MESSAGE A001 WITH 'TREEV_GET_EP_ITEM_DBL_CLK'.
ENDIF.

 READ TABLE G_ITEMS INTO WA_ITEMS
                    WITH KEY NODE_KEY = NODE_KEY
                             ITEM_NAME = 1.

 L_FELDNAME =  WA_ITEMS-TEXT.
 CALL FUNCTION '/SIE/HR_IDP_F1LT_SHOW'
      EXPORTING
           FELDNAME = L_FELDNAME.

ENDCALLBACK.

CALLBACK HANDLE_TREE_NODE_CONTEXT_MENU.

DATA NODE_KEY LIKE TREEV_ITEM-NODE_KEY.

* get the parameters of the event.
*break-point.
CALL FUNCTION 'TREEV_GET_EP_NODE_CONTEXT_MEN'
     EXPORTING
          HANDLE            = TREE
     IMPORTING
          NODE_KEY          = NODE_KEY
     EXCEPTIONS
          FAILED            = 1
          CNTL_SYSTEM_ERROR = 2
          OTHERS            = 3.
IF SY-SUBRC <> 0.
  MESSAGE A001 WITH 'TREEV_GET_EP_NODE_CONTEXT_MEN'.
ENDIF.
G_EVENT = 'node_context_men'.
G_NODE_KEY = NODE_KEY.
ENDCALLBACK.

CALLBACK HANDLE_TREE_HEADER_CLICK.
DATA: CHECKED(1) TYPE C
    , WA_FIELDS TYPE /SIE/HR_IDP_F4_SEL_FIELDS
    .
*break-point.
CALL FUNCTION 'TREEV_GET_EP_HEADER_CLICK'
     EXPORTING
          HANDLE      = TREE
     IMPORTING
          HEADER_NAME = G_NODE_KEY
     EXCEPTIONS
          FAILED      = 1
          OTHERS      = 2.

WA_FIELDS-FELDNAME = G_NODE_KEY.

CASE CHECKED.
  WHEN SPACE.
    DELETE TABLE G_SEL_FIELDS FROM WA_FIELDS.
  WHEN OTHERS.
    APPEND WA_FIELDS TO G_SEL_FIELDS.
ENDCASE.

ENDCALLBACK.

CALLBACK HANDLE_TREE_LINK_CLICK.
DATA NODE_KEY LIKE TREEV_ITEM-NODE_KEY.
DATA ITEM_NAME LIKE TREEV_ITEM-ITEM_NAME.
DATA: L_FELDNAME TYPE /SIE/HR_IDP_FNAME.
*break-point.
CALL FUNCTION 'TREEV_GET_EP_LINK_CLICK'
     EXPORTING
          HANDLE            = TREE
     IMPORTING
          NODE_KEY          = NODE_KEY
          ITEM_NAME         = ITEM_NAME
     EXCEPTIONS
          FAILED            = 1
          CNTL_SYSTEM_ERROR = 2
          OTHERS            = 3.
IF SY-SUBRC <> 0.
  MESSAGE A001 WITH 'TREEV_GET_EP_LINK_CLICK'.
ENDIF.
G_NODE_KEY = NODE_KEY.

L_FELDNAME = NODE_KEY.
CALL FUNCTION '/SIE/HR_IDP_F1LT_SHOW'
     EXPORTING
          FELDNAME = L_FELDNAME.

ENDCALLBACK.

CALLBACK HANDLE_TREE_CHECKBOX_CHANGE.

DATA: NODE_KEY LIKE TREEV_ITEM-NODE_KEY,
      ITEM_NAME LIKE TREEV_ITEM-ITEM_NAME,
      CHECKED TYPE C.

CALL FUNCTION 'TREEV_GET_EP_CHECKBOX_CHANGE'
     EXPORTING
          HANDLE            = TREE
     IMPORTING
          NODE_KEY          = NODE_KEY
          ITEM_NAME         = ITEM_NAME
          CHECKED           = CHECKED
     EXCEPTIONS
          FAILED            = 1
          CNTL_SYSTEM_ERROR = 2
          OTHERS            = 3.
IF SY-SUBRC <> 0.
  MESSAGE A001 WITH 'TREEV_GET_EP_CHECKBOX_CHANGE'.
ENDIF.
G_NODE_KEY = NODE_KEY.
IF CHECKED = YES.
  READ TABLE G_ITEMS INTO WA_ITEMS WITH KEY NODE_KEY = NODE_KEY
                                            ITEM_NAME = 1.
  IF SY-SUBRC >< 0.
    MESSAGE S225.
  ELSE.
    G_SEL_FIELDS-FELDNAME = WA_ITEMS-TEXT.
    APPEND G_SEL_FIELDS.
  ENDIF.

ELSE.
  READ TABLE G_ITEMS INTO WA_ITEMS WITH KEY NODE_KEY = NODE_KEY
                                            ITEM_NAME = 1.
  IF SY-SUBRC = 0.
    READ TABLE G_SEL_FIELDS WITH KEY FELDNAME = WA_ITEMS-TEXT.
    IF SY-SUBRC >< 0.
    ELSE.
      DELETE G_SEL_FIELDS WHERE FELDNAME = WA_ITEMS-TEXT.
    ENDIF.
  ENDIF.

ENDIF.
ENDCALLBACK.
