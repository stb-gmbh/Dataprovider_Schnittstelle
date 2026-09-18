FUNCTION /SIE/HR_IDP_F1LT_EDIT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(FIELDNAME)
*"             VALUE(SPRAS) LIKE  SY-LANGU
*"       EXPORTING
*"             VALUE(DIRTY) TYPE  XFELD
*"       TABLES
*"              TXTABLE STRUCTURE  /SIE/HR_IDP_F1LT_EXTENDED
*"----------------------------------------------------------------------
  DATA: ONELINE   TYPE /SIE/HR_IDP_TLINE,
        LINES     TYPE TABLE OF /SIE/HR_IDP_TLINE,
        LINES_OLD TYPE TABLE OF /SIE/HR_IDP_TLINE,
        LINECOUNT TYPE /SIE/HR_IDP_SEQNR.
  CLEAR DIRTY.
  LOOP AT TXTABLE WHERE FELDNAME = FIELDNAME
                  AND SPRAS = SPRAS
                  AND ACTION NE 'D'.
    ONELINE = TXTABLE-TLINE.
    APPEND ONELINE TO LINES.
  ENDLOOP.
  LINES_OLD = LINES.
  CALL FUNCTION '/SIE/HR_IDP_LANGTEXTEDITOR'
       EXPORTING
            TITEL          = 'Langtext'
            READONLY       = ' '
       TABLES
            TEXTLINES      = LINES
       EXCEPTIONS
            USER_CANCELLED = 1
            OTHERS         = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    IF LINES NE LINES_OLD.
      DIRTY = 'X'.
      DESCRIBE TABLE LINES LINES LINECOUNT.
      DELETE TXTABLE WHERE FELDNAME = FIELDNAME
                           AND SPRAS = SPRAS
                           AND SEQNR GT LINECOUNT
                           AND ACTION = 'N'.
      TXTABLE-ACTION = 'D'.
      MODIFY TXTABLE TRANSPORTING ACTION
                     WHERE FELDNAME = FIELDNAME
                     AND SPRAS = SPRAS
                     AND SEQNR GT LINECOUNT.
      LINECOUNT = 0.
      LOOP AT LINES INTO ONELINE.
        ADD 1 TO LINECOUNT.
        READ TABLE TXTABLE WITH KEY SPRAS = SPRAS
                                    FELDNAME = FIELDNAME
                                    SEQNR = LINECOUNT.
        IF SY-SUBRC LT 4.
          IF TXTABLE-TLINE NE ONELINE.
            IF TXTABLE-ACTION NE 'N'.
              TXTABLE-ACTION = 'C'.
            ENDIF.
            TXTABLE-TLINE = ONELINE.
            MODIFY TXTABLE INDEX SY-TABIX TRANSPORTING ACTION TLINE.
          ENDIF.
        ELSE.
          TXTABLE-SPRAS = SPRAS.
          TXTABLE-FELDNAME = FIELDNAME.
          TXTABLE-SEQNR = LINECOUNT.
          TXTABLE-TLINE = ONELINE.
          TXTABLE-ACTION = 'N'.
          APPEND TXTABLE.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFUNCTION.
