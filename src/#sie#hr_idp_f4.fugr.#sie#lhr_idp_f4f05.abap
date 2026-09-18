*----------------------------------------------------------------------*
*   INCLUDE /SIE/LHR_IDP_F4F05                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  assign_callbacks
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ASSIGN_CALLBACKS.

* callback HANDLE_TREE_NODE_DBL_CLK for the event node_dbl_clk.
* Event occurs if the user double clicks a node
  CALL FUNCTION 'TREEV_EVENT_CB_NODE_DBL_CLK'
       EXPORTING
            CALLBACK_FORM           = 'HANDLE_TREE_NODE_DBL_CLK'
       CHANGING
            HANDLE                  = TREE
       EXCEPTIONS
            CB_NOT_FOUND            = 1
            FAILED                  = 2
            INV_CALLBACK_DEFINITION = 3
            OTHERS                  = 4.
  IF SY-SUBRC <> 0.
    MESSAGE A001 WITH 'TREEV_EVENT_CB_NODE_DBL_CLK'.
  ENDIF.

IF G_GRTYPE = 1.
  CALL FUNCTION 'TREEV_EVENT_CB_ITEM_DBL_CLK'
       EXPORTING
            CALLBACK_FORM           = 'HANDLE_TREE_ITEM_DBL_CLK'
       CHANGING
            HANDLE                  = TREE
       EXCEPTIONS
            CB_NOT_FOUND            = 1
            FAILED                  = 2
            INV_CALLBACK_DEFINITION = 3
            OTHERS                  = 4.
  IF SY-SUBRC <> 0.
    MESSAGE A001 WITH 'TREEV_EVENT_CB_ITEM_DBL_CLK'.
  ENDIF.
ENDIF.

  IF G_GRTYPE = 1.
    CALL FUNCTION 'TREEV_EVENT_CB_CHECKBOX_CHANGE'
         EXPORTING
              CALLBACK_FORM           = 'HANDLE_TREE_CHECKBOX_CHANGE'
         CHANGING
              HANDLE                  = TREE
         EXCEPTIONS
              CB_NOT_FOUND            = 1
              FAILED                  = 2
              INV_CALLBACK_DEFINITION = 3
              OTHERS                  = 4.
    IF SY-SUBRC <> 0.
      MESSAGE A001 WITH 'TREEV_EVENT_CB_CHECKBOX_CHANGE'.
    ENDIF.
  ENDIF.
ENDFORM.                    " assign_callbacks

*&---------------------------------------------------------------------*
*&      Form  DESTROY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DESTROY.

  IF TREE_CONTROL_CREATED = 'X'.
    CLEAR TREE_CONTROL_CREATED.
    CALL FUNCTION 'CONTROL_DESTROY' " Destroy control
*            EXPORTING
*                 NO_FLUSH          =
         CHANGING
              H_CONTROL         = TREE
         EXCEPTIONS
              CNTL_SYSTEM_ERROR = 1
              CNTL_ERROR        = 2
              OTHERS            = 3.
    IF SY-SUBRC <> 0.
      MESSAGE A001 WITH 'CONTROL_DESTROY'.
    ENDIF.
    CALL FUNCTION 'CONTROL_FLUSH'      " we must flush here
         EXCEPTIONS                    " (CONTROL_DESTROY does not)
              CNTL_SYSTEM_ERROR = 1
              CNTL_ERROR        = 2
              OTHERS            = 3.
    IF SY-SUBRC <> 0.
      MESSAGE A001 WITH 'CONTROL_DESTROY (FLUSH)'.
    ENDIF.
  ENDIF.

ENDFORM.                    " DESTROY
