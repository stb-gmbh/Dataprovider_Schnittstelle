*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_F4I01 .
*----------------------------------------------------------------------*

DATA: NODE_KEY LIKE TREEV_ITEM-NODE_KEY.
DATA: NODE_KEYS TYPE STANDARD TABLE OF TREEV_NKEY INITIAL SIZE 0
      WITH HEADER LINE.
DATA: L_FELDNAME TYPE /SIE/HR_IDP_FNAME.


*&---------------------------------------------------------------------*
*&      Module  PAI_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_1000 INPUT.

* CONTROL_DISPATCH must be called because this function calls the
* event handler of an event.
  CALL FUNCTION 'CONTROL_DISPATCH'
       EXPORTING
            FCODE        = OK_CODE
       EXCEPTIONS
            CB_NOT_FOUND = 1
            OTHERS       = 2.
  IF SY-SUBRC <> 0.
    MESSAGE A001 WITH 'CONTROL_DISPATCH'.
  ENDIF.

  CASE OK_CODE.

    WHEN 'BACK' OR 'PICK'. " Finish program
      G_RC = 8.
      PERFORM DESTROY.

      SET SCREEN 0. LEAVE SCREEN.

    WHEN 'ERTN'.
    G_RC = 0.
* Auswahl akzeptieren
      CASE G_GRTYPE.
        WHEN 1.
* Über die Checkboxes sind die Felder ausgewählt worden und in die
*  g_sel_fields bereitgestellt worden.
          PERFORM DESTROY.
          SET SCREEN 0. LEAVE SCREEN.

        WHEN 2.
          CALL FUNCTION 'TREEV_GET_SELECTED_NODE'
               EXPORTING
                    HANDLE                     = TREE
               IMPORTING
                    NODE_KEY                   = NODE_KEY
               EXCEPTIONS
                    FAILED                     = 1
                    INSTANCE_NOT_FOUND         = 2
                    SINGLE_NODE_SELECTION_ONLY = 3
                    CNTL_SYSTEM_ERROR          = 4
                    OTHERS                     = 5.
          IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.
          CLEAR G_SEL_FIELDS[].

* Check node
          CLEAR WA_ITEMS.
          READ TABLE G_ITEMS INTO WA_ITEMS WITH KEY NODE_KEY = NODE_KEY
                                                    ITEM_NAME = '3'.
          IF SY-SUBRC >< 0.
            MESSAGE S225.
          ELSE.
            G_SEL_FIELDS-FELDNAME = NODE_KEY.
            APPEND G_SEL_FIELDS.

            PERFORM DESTROY.
            SET SCREEN 0. LEAVE SCREEN.
          ENDIF.
      ENDCASE.

    WHEN 'DOCU'.
      CALL FUNCTION 'TREEV_GET_SELECTED_NODE'
           EXPORTING
                HANDLE                     = TREE
           IMPORTING
                NODE_KEY                   = NODE_KEY
           EXCEPTIONS
                FAILED                     = 1
                INSTANCE_NOT_FOUND         = 2
                SINGLE_NODE_SELECTION_ONLY = 3
                CNTL_SYSTEM_ERROR          = 4
                OTHERS                     = 5.
      IF SY-SUBRC <> 0.
      ELSE.
        IF NODE_KEY IS INITIAL.








        ELSE.
          READ TABLE G_ITEMS INTO WA_ITEMS
                             WITH KEY NODE_KEY = NODE_KEY
                                      ITEM_NAME = 1.

          L_FELDNAME =  WA_ITEMS-TEXT.
          CALL FUNCTION '/SIE/HR_IDP_F1LT_SHOW'
               EXPORTING
                    FELDNAME = L_FELDNAME.

        ENDIF.
      ENDIF.

    WHEN OTHERS.
      CHECK G_GRTYPE = 2.
      IF OK_CODE(4) = '%_GC'.
* Auswahl akzeptieren (Doppelclick!)
        CALL FUNCTION 'TREEV_GET_SELECTED_NODE'
             EXPORTING
                  HANDLE                     = TREE
             IMPORTING
                  NODE_KEY                   = NODE_KEY
             EXCEPTIONS
                  FAILED                     = 1
                  INSTANCE_NOT_FOUND         = 2
                  SINGLE_NODE_SELECTION_ONLY = 3
                  CNTL_SYSTEM_ERROR          = 4
                  OTHERS                     = 5.
        IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
        CLEAR G_SEL_FIELDS[].
*
* Check node
        CLEAR WA_ITEMS.
        READ TABLE G_ITEMS INTO WA_ITEMS WITH KEY NODE_KEY = NODE_KEY
                                                  ITEM_NAME = 1.
        IF SY-SUBRC >< 0.
          MESSAGE S225.
        ELSE.
          G_SEL_FIELDS-FELDNAME = WA_ITEMS-TEXT.
          APPEND G_SEL_FIELDS.

          PERFORM DESTROY.
          SET SCREEN 0. LEAVE SCREEN.
        ENDIF.
      ENDIF.
  ENDCASE.
* CAUTION: clear ok code!
  CLEAR OK_CODE.

ENDMODULE.                 " PAI_1000  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1100  INPUT
*&---------------------------------------------------------------------*
*       Verzweigt in die Struktur oder einfache suche
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1100 INPUT.
  SVCODE = OKCODE. CLEAR OKCODE.
  CASE SVCODE.
    WHEN 'OK'.
  IF NOT ( /SIE/HR_IDP_F4_QFELDER-RADIO1 IS INITIAL ).   " Struktursuche
        CALL FUNCTION '/SIE/HR_IDP_F4_TREE'
             TABLES
                  SELECTED_FIELDS = G_SEL_FIELDS.
        SET SCREEN 0. LEAVE SCREEN.
      ENDIF.

   IF NOT ( /SIE/HR_IDP_F4_QFELDER-RADIO2 IS INITIAL ).   " Normal suche
        SUBMIT /SIE/HR_IDP_FIND_FIELD AND RETURN VIA SELECTION-SCREEN.
      ENDIF.
    WHEN OTHERS.
      SET SCREEN 0. LEAVE SCREEN.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1100  INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.
  SET SCREEN 0. LEAVE SCREEN.
ENDMODULE.                 " EXIT_COMMAND  INPUT
