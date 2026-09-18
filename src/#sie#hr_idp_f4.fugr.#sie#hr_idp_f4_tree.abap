FUNCTION /SIE/HR_IDP_F4_TREE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(GRTYP) TYPE  /SIE/HR_IDP_GRKEY DEFAULT '2'
*"             VALUE(FL_DISPLAY) TYPE  XFELD DEFAULT SPACE
*"             VALUE(DPFTYPE) TYPE  /SIE/HR_IDP_FTYPE DEFAULT SPACE
*"             VALUE(FL_HEADER) TYPE  XFELD DEFAULT SPACE
*"       EXPORTING
*"             VALUE(RC) TYPE  SYSUBRC
*"       TABLES
*"              SELECTED_FIELDS STRUCTURE  /SIE/HR_IDP_F4_SEL_FIELDS
*"----------------------------------------------------------------------

  DATA: TABIX LIKE SY-TABIX.

  CLEAR G_SEL_FIELDS[].
  G_GRTYPE = GRTYP.
  G_DISPLAY = FL_DISPLAY.
  G_KZHDFT = FL_HEADER.
  IF DPFTYPE = 5.
    G_HDFT = YES.
  ENDIF.

  CALL FUNCTION 'CONTROL_INIT'. " Controls are used

  IF G_GRTYPE = 1.
    G_SEL_FIELDS[] = SELECTED_FIELDS[].
  ELSE.
    CLEAR G_SEL_FIELDS[].
  ENDIF.

* Baum anzeigen.

  CALL SCREEN 1000.
  IF G_RC = 0.
    SELECTED_FIELDS[] = G_SEL_FIELDS[].
    RC = 0.
  ELSE.
    RC = 8.
  ENDIF.


ENDFUNCTION.
