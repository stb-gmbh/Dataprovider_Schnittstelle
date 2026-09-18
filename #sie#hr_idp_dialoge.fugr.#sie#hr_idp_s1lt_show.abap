FUNCTION /SIE/HR_IDP_S1LT_SHOW.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       TABLES
*"              I_S1LT TYPE  /SIE/HR_IDP_TT_S1LT
*"----------------------------------------------------------------------
  DATA: WA_S1LT   TYPE /SIE/HR_IDP_S1LT,
        ONELINE   TYPE /SIE/HR_IDP_TLINE,
        LINES     TYPE TABLE OF /SIE/HR_IDP_TLINE,
        LINECOUNT TYPE /SIE/HR_IDP_SEQNR,
        IFCID     TYPE /SIE/HR_IDP_INTERFACE_ID.

  SORT I_S1LT BY SPRAS  SEQNR.
  LOOP AT I_S1LT INTO WA_S1LT WHERE SPRAS = SY-LANGU.
    IFCID = WA_S1LT-IFCID.
    ONELINE = WA_S1LT-TLINE.
    APPEND ONELINE TO LINES.
  ENDLOOP.
  CALL FUNCTION '/SIE/HR_IDP_LANGTEXTEDITOR'
       EXPORTING
            TITEL          = 'Langtext'
            READONLY       = 'X'
       TABLES
            TEXTLINES      = LINES
       EXCEPTIONS
            USER_CANCELLED = 1
            OTHERS         = 2.

ENDFUNCTION.
