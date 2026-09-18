FUNCTION /SIE/HR_IDP_COMPUTE_DATE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(IN_DATE) LIKE  SY-DATUM
*"             VALUE(DAY) TYPE  /SIE/HR_IDP_BEG_DAY_FIX OPTIONAL
*"             VALUE(OFFSET) TYPE  /SIE/HR_IDP_MONTH_OFFSET DEFAULT 0
*"       EXPORTING
*"             VALUE(OUT_DATE) LIKE  SY-DATUM
*"----------------------------------------------------------------------

DATA: MONTH(2) TYPE N,
      YEAR(4) TYPE N,
      MONTH_TOTAL(6) TYPE N,
      GOAL TYPE D.
    YEAR = IN_DATE(4).
    MONTH = IN_DATE+4(2).
    IF DAY IS INITIAL.
      DAY = IN_DATE+6(2).
    ENDIF.
    MONTH_TOTAL = YEAR * 12 +  MONTH + OFFSET. " - 1 + 1.
    YEAR = MONTH_TOTAL DIV 12.
    MONTH = ( MONTH_TOTAL MOD 12 ) + 1.
    CONCATENATE YEAR MONTH '01 ' INTO GOAL.
    SUBTRACT 1 FROM GOAL.
    IF DAY LT GOAL+6(2).
      MOVE DAY TO GOAL+6(2).
    ENDIF.
    OUT_DATE = GOAL.





ENDFUNCTION.
