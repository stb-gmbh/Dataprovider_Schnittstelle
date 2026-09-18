FUNCTION /SIE/HR_IDP_C_EINHEITEN.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(P_IN)
*"             VALUE(P_PARAMETERS) TYPE  /SIE/HR_IDP_KONVPARA
*"                             OPTIONAL
*"       EXPORTING
*"             VALUE(P_OUT)
*"----------------------------------------------------------------------

  DATA: UNIT TYPE PT_ZEINH
      , UNIT_TEXT TYPE EINHTXT
      .

  CLEAR P_OUT.

  UNIT = P_IN.
  PERFORM READ_T538T USING UNIT
                     CHANGING UNIT_TEXT.

  P_OUT = UNIT_TEXT.

ENDFUNCTION.
