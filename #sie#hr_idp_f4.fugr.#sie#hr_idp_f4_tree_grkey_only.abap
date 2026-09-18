FUNCTION /SIE/HR_IDP_F4_TREE_GRKEY_ONLY.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(GRTYP) TYPE  /SIE/HR_IDP_GRKEY DEFAULT '2'
*"             VALUE(FL_DISPLAY) TYPE  XFELD DEFAULT SPACE
*"       TABLES
*"              SELECTED_FIELDS STRUCTURE  /SIE/HR_IDP_F4_SEL_FIELDS
*"----------------------------------------------------------------------

  CLEAR G_SEL_FIELDS[].
  G_GRTYPE = GRTYP.
  G_DISPLAY = FL_DISPLAY.

  CALL FUNCTION 'CONTROL_INIT'. " Controls are used

* Baum anzeigen.
  CALL SCREEN 1010.

  CLEAR SELECTED_FIELDS[].
  DESCRIBE TABLE G_SEL_FIELDS.
  IF SY-TFILL NE 0.
    READ TABLE G_SEL_FIELDS INDEX 1.
   SELECTED_FIELDS-FELDNAME = G_SEL_FIELDS-FELDNAME.
   APPEND SELECTED_FIELDS.
  ENDIF.
ENDFUNCTION.
