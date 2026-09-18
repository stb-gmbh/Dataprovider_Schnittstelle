*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_F4I02 .
*----------------------------------------------------------------------*

*DATA: NODE_KEY LIKE TREEV_ITEM-NODE_KEY.
*DATA: L_FELDNAME TYPE /SIE/HR_IDP_FNAME.
************************************************************************
*            Änderungen: HAN001
*        Auskommentierte Anweisungen haben bei der Umstellung auf ERP einen
*        Fehler verursacht. Sie sind nähmlich nicht erreichbar.
*
*&---------------------------------------------------------------------*
*&      Module  PAI_1010  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_1010 INPUT.

* CONTROL_DISPATCH must be called because this function calls the
* event handler of an event.
  CALL FUNCTION 'CONTROL_DISPATCH'
    EXPORTING
      fcode        = ok_code
    EXCEPTIONS
      cb_not_found = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.
    MESSAGE a001 WITH 'CONTROL_DISPATCH'.
  ENDIF.

  CASE ok_code.

    WHEN 'BACK' OR 'PICK'. " Finish program

* Beim Exit command bitte die Auswahl löschen.
      IF ok_code = 'BACK'.
        CLEAR g_sel_fields[].
      ENDIF.

      PERFORM destroy.

      SET SCREEN 0. LEAVE SCREEN.

    WHEN 'ERTN'.
* Auswahl akzeptieren
      CALL FUNCTION 'TREEV_GET_SELECTED_NODE'
        EXPORTING
          handle                     = tree
        IMPORTING
          node_key                   = node_key
        EXCEPTIONS
          failed                     = 1
          instance_not_found         = 2
          single_node_selection_only = 3
          cntl_system_error          = 4
          OTHERS                     = 5.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      CLEAR g_sel_fields[].
      g_sel_fields-feldname = node_key.
      APPEND g_sel_fields.

      PERFORM destroy.
      SET SCREEN 0. LEAVE SCREEN.

    WHEN 'DOCU'.
      CALL FUNCTION 'TREEV_GET_SELECTED_NODE'
        EXPORTING
          handle                     = tree
        IMPORTING
          node_key                   = node_key
        EXCEPTIONS
          failed                     = 1
          instance_not_found         = 2
          single_node_selection_only = 3
          cntl_system_error          = 4
          OTHERS                     = 5.
      IF sy-subrc <> 0.
      ELSE.
        READ TABLE g_items INTO wa_items
                           WITH KEY node_key = node_key
                                    item_name = '2'.

        l_feldname =  wa_items-text.
        CALL FUNCTION '/SIE/HR_IDP_F1LT_SHOW'
          EXPORTING
            feldname = l_feldname.

      ENDIF.

    WHEN OTHERS.
  ENDCASE.
* CAUTION: clear ok code!
  CLEAR ok_code.

ENDMODULE.                 " PAI_1010  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1100  INPUT
*&---------------------------------------------------------------------*
*       Verzweigt in die Struktur oder einfache suche
*----------------------------------------------------------------------*
*MODULE USER_COMMAND_1100 INPUT.
*  SVCODE = OKCODE. CLEAR OKCODE.                                          "HAN001
*  CASE SVCODE.                                                            "HAN001
*    WHEN 'OK'.                                                            "HAN001
*  IF NOT ( /SIE/HR_IDP_F4_QFELDER-RADIO1 IS INITIAL ).   " Struktursuche  "HAN001
*        CALL FUNCTION '/SIE/HR_IDP_F4_TREE'                               "HAN001
*             TABLES                                                       "HAN001
*                  SELECTED_FIELDS = G_SEL_FIELDS.                         "HAN001
*        SET SCREEN 0. LEAVE SCREEN.                                       "HAN001
*      ENDIF.                                                              "HAN001
*                                                                          "HAN001
*   IF NOT ( /SIE/HR_IDP_F4_QFELDER-RADIO2 IS INITIAL ).   " Normal suche  "HAN001
*        SUBMIT /SIE/HR_IDP_FIND_FIELD AND RETURN VIA SELECTION-SCREEN.    "HAN001
*      ENDIF.                                                              "HAN001
*    WHEN OTHERS.                                                          "HAN001
*      SET SCREEN 0. LEAVE SCREEN.                                         "HAN001
*  ENDCASE.                                                                "HAN001

*ENDMODULE.                 " USER_COMMAND_1100  INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*MODULE EXIT_COMMAND INPUT.
*SET SCREEN 0. LEAVE SCREEN.                                 "HAN001
*ENDMODULE.                 " EXIT_COMMAND  INPUT
