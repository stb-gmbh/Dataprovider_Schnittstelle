*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_F07                                        *
*----------------------------------------------------------------------*

FORM CHECK_LOSS_OF_DATA USING VALUE(CODE)
                        CHANGING EXIT TYPE XFLAG.
* exit eq no  -->operation ausfuehren
* exit eq yes -->operation abbrechen
DATA: CHAR1.

  EXIT = NO.                         "default: operation ausfuehren
  CHECK SY-TCODE NE C_DISP_TCOD. "aendern oder hinzufügen
  IF SVCODE EQ C_BACK_CODE .
    CASE G_STATUS_TRAN.
      WHEN C_1000_STAT.  " or ...
        exit.
      when others.
    endcase.
  endif.
  /SIE/HR_IDP_DB_SEL = G_PROC_VEC.
  CALL FUNCTION '/SIE/HR_IDP_DB_CHECK'
       EXPORTING
            INTERFACE        = G_IFDATA_TRAN-S1-IFCID
            VERSION          = G_IFDATA_VERS
            TRANSACTION_DATA = G_IFDATA_TRAN
       CHANGING
            DBSEL            = /SIE/HR_IDP_DB_SEL
            .
  IF /SIE/HR_IDP_DB_SEL IS INITIAL. EXIT. ENDIF. "unveraendert

  call function 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
       EXPORTING  TEXTLINE1    = 'Möchten Sie das aktuelle Bild'(101)
                  TEXTLINE2    = 'trotzdem verlassen?'(102)
                  TITEL        = 'Aktuelles Bild verlassen'(103)
*                 START_COLUMN = 25
*                 START_ROW    = 6
       importing  answer       = char1
       exceptions others       = 1.
  if sy-subrc eq 0 and char1 eq 'J'.
    clear G_PROC_VEC. "operation ausfuehren, eingegebene daten vergessen
  else.
    exit = yes. "operation abbrechen
  endif.

ENDFORM. "check_loss_of_data
