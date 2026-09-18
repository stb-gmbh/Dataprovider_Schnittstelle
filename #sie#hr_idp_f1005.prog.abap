*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_F1005 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  CHECK_DATES_1005
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_DATES_1005_DATA.

  DATA: DATA_BEGIN TYPE D
      , DATA_END TYPE D
      .

  CALL FUNCTION '/SIE/HR_IDP_COMPUTE_DATE'
       EXPORTING
            IN_DATE  = SY-DATUM
            DAY      = /SIE/HR_IDP_S1PR-BEGDT
            OFFSET   = /SIE/HR_IDP_S1PR-BEGDO
       IMPORTING
            OUT_DATE = DATA_BEGIN.

  CALL FUNCTION '/SIE/HR_IDP_COMPUTE_DATE'
       EXPORTING
            IN_DATE  = SY-DATUM
            DAY      = /SIE/HR_IDP_S1PR-ENDDT
            OFFSET   = /SIE/HR_IDP_S1PR-ENDDO
       IMPORTING
            OUT_DATE = DATA_END.

  IF DATA_BEGIN > DATA_END.
    MESSAGE E138 WITH 'Datenauswahlzeitraum'.
  ENDIF.

ENDFORM.                    " CHECK_DATES_1005

*---------------------------------------------------------------------*
*       FORM CHECK_DATES_1005_PERSON                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM CHECK_DATES_1005_PERSON.

  DATA: PERSON_BEGIN TYPE D
      , PERSON_END TYPE D
      .

  CALL FUNCTION '/SIE/HR_IDP_COMPUTE_DATE'
       EXPORTING
            IN_DATE  = SY-DATUM
            DAY      = /SIE/HR_IDP_S1PR-BEGPT
            OFFSET   = /SIE/HR_IDP_S1PR-BEGPO
       IMPORTING
            OUT_DATE = PERSON_BEGIN.

  CALL FUNCTION '/SIE/HR_IDP_COMPUTE_DATE'
       EXPORTING
            IN_DATE  = SY-DATUM
            DAY      = /SIE/HR_IDP_S1PR-ENDPT
            OFFSET   = /SIE/HR_IDP_S1PR-ENDPO
       IMPORTING
            OUT_DATE = PERSON_END.

  IF PERSON_BEGIN > PERSON_END.
    MESSAGE E138 WITH 'Personenauswahlzeitraum'.
  ENDIF.

ENDFORM.                    " CHECK_DATES_1005
