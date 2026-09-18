FUNCTION /SIE/HR_IDP_KONF_MATRIX.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(ROLE) DEFAULT '01'
*"             VALUE(FIELD) DEFAULT 'P'
*"       EXPORTING
*"             VALUE(OPTION)
*"       EXCEPTIONS
*"              NO_SUCH_ROLE
*"              NO_SUCH_FIELD
*"----------------------------------------------------------------------

  DATA: ITAB_MATRIX TYPE T_ITAB_MATRIX
      , WORK_MATRIX TYPE T_MATRIX
      .

  PERFORM FILL_MATRIX CHANGING ITAB_MATRIX[].

  READ TABLE ITAB_MATRIX INTO WORK_MATRIX WITH KEY ROLE = ROLE.
  IF SY-SUBRC NE 0.
    IF ROLE IS INITIAL.
      OPTION = 'X'.    " Default for a new or unknown role is "can"
    ELSE.
      MESSAGE E107 WITH ROLE RAISING NO_SUCH_ROLE.
    ENDIF.
  ELSE.
    CASE FIELD.
      WHEN 'P'.                                             "#EC NOTEXT
        OPTION = WORK_MATRIX-PERNR.
      WHEN 'U'.                                             "#EC NOTEXT
        OPTION = WORK_MATRIX-UNAME.
      WHEN 'O'.                                             "#EC NOTEXT
        OPTION = WORK_MATRIX-ORGEH.
      WHEN 'E'.                                             "#EC NOTEXT
        OPTION = WORK_MATRIX-EMAIL.
      WHEN OTHERS.
        MESSAGE E108 WITH FIELD RAISING NO_SUCH_FIELD.
    ENDCASE.
  ENDIF.

ENDFUNCTION.
