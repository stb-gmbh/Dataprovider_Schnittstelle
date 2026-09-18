FUNCTION /sie/hr_idp_no_leading_zero.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(P_IN)
*"     VALUE(P_PARAMETERS) TYPE  /SIE/HR_IDP_KONVPARA OPTIONAL
*"  EXPORTING
*"     VALUE(P_OUT)
*"----------------------------------------------------------------------
p_out = p_in.
CONDENSE p_out NO-GAPS.
    CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
      CHANGING
        value = p_out.
ENDFUNCTION.
