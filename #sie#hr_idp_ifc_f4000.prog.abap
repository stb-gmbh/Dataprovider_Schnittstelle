*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_F4000 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  HANDLE_OKCODES_4000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM HANDLE_OKCODES_4000.

  DATA: L_CALL_METHOD TYPE TY_CALLM
      , L_CALL_SCREEN TYPE SYDYNNR
      .

  CASE G_STATUS_TRAN.
    WHEN C_4000_STAT.
      L_CALL_METHOD = C_CALS_CALLM.
    WHEN OTHERS.
      L_CALL_METHOD = C_SETS_CALLM.
  ENDCASE.

  PERFORM HANDLE_MAIN_OK_CODES.

  CASE SVCODE.
    WHEN 'RMOD'.
      CHECK  NOT ( /SIE/HR_IDP_S1-ACT_VERS_NR IS INITIAL ).
      L_CALL_SCREEN = C_MODR_SDYN.
      PERFORM CALL_SCREEN USING L_CALL_SCREEN L_CALL_METHOD.
    WHEN OTHERS.
  ENDCASE.

* PERFORM HANDLE_DOCUMENTATION.

ENDFORM.                    " HANDLE_OKCODES_4000

*&---------------------------------------------------------------------*
*&      Form  ADD_NOTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ADD_NOTE.

* Abnahmeinformationen ändern
  READ TABLE G_IFDATA_TRAN-S1F INTO WA_S1F WITH KEY TROLE = '06'.
  IF SY-SUBRC = 0.
    WA_S1F-CH_DATUM = SY-DATUM.
    WA_S1F-CH_UNAME = SY-UNAME.
    WA_S1F-CH_UZEIT = SY-UZEIT.
* Kommentarzeile einfügen
    IF ( WA_S1F-LTEXT IS INITIAL ).
      CONCATENATE 'Nachträgliche Änderung durch '
                  SY-TCODE
                  INTO WA_S1F-LTEXT.
    ENDIF.
    MODIFY G_IFDATA_TRAN-S1F FROM WA_S1F INDEX SY-TABIX.
  ENDIF.

ENDFORM.                    " ADD_NOTE
