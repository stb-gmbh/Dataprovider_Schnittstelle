FUNCTION /SIE/HR_IDP_S1LT_EDIT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(IFCID) TYPE  /SIE/HR_IDP_INTERFACE_ID
*"       TABLES
*"              I_S1LT TYPE  /SIE/HR_IDP_TT_S1LT
*"       EXCEPTIONS
*"              USER_CANCELLED
*"----------------------------------------------------------------------
  DATA: WA_S1LT   TYPE /SIE/HR_IDP_S1LT,
        ONELINE   TYPE /SIE/HR_IDP_TLINE,
        LINES     TYPE TABLE OF /SIE/HR_IDP_TLINE,
        LINECOUNT TYPE /SIE/HR_IDP_SEQNR.


  SORT I_S1LT BY SPRAS  SEQNR.
  LOOP AT I_S1LT INTO WA_S1LT WHERE SPRAS = SY-LANGU.

    ONELINE = WA_S1LT-TLINE.
    APPEND ONELINE TO LINES.
  ENDLOOP.
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
  RAISE USER_CANCELLED.
  ELSE.
    CLEAR: I_S1LT[], WA_S1LT.
    WA_S1LT-SPRAS = SY-LANGU.
    WA_S1LT-MANDT = SY-MANDT.
    WA_S1LT-IFCID = IFCID.
    LOOP AT LINES INTO ONELINE.
      WA_S1LT-SEQNR = SY-TABIX.
      WA_S1LT-TLINE = ONELINE.
      APPEND WA_S1LT TO I_S1LT.
      LINECOUNT = WA_S1LT-SEQNR.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.
