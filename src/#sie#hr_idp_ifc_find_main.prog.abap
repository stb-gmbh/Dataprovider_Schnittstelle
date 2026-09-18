*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_FIND_MAIN                                  *
*----------------------------------------------------------------------*

INITIALIZATION.
  G_REPID = SY-REPID.

START-OF-SELECTION.
  PERFORM SEARCH_DATA.
  SORT G_DATA BY IFCID VRSNR.
  PERFORM DISPLAY_DATA.
