FUNCTION /SIE/HR_IDP_F1LT_SHOW.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(FELDNAME) TYPE  /SIE/HR_IDP_FNAME
*"----------------------------------------------------------------------
DATA: I_F1LT TYPE SORTED TABLE
             OF /SIE/HR_IDP_F1LT
             WITH UNIQUE KEY SPRAS FELDNAME SEQNR,
      WA_F1LT TYPE /SIE/HR_IDP_F1LT,
      ONELINE TYPE /SIE/HR_IDP_TLINE,
      LINES   TYPE TABLE OF /SIE/HR_IDP_TLINE.

SELECT * FROM /SIE/HR_IDP_F1LT INTO TABLE I_F1LT
         WHERE SPRAS = SY-LANGU
           AND FELDNAME = FELDNAME
           ORDER BY PRIMARY KEY.
LOOP AT I_F1LT INTO WA_F1LT.
  ONELINE = WA_F1LT-TLINE.
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
          OTHERS         = 2
          .
IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.

ENDFUNCTION.
