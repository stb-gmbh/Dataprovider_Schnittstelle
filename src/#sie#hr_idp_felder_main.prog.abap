*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_FELDER_MAIN                                    *
*----------------------------------------------------------------------*
INITIALIZATION.
  G_REPID = SY-REPID.

START-OF-SELECTION.
  PERFORM SEARCH_DATA.
  PERFORM DISPLAY_DATA.
