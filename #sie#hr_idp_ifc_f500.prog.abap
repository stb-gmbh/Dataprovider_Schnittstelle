*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_F500 .
*----------------------------------------------------------------------*

DEFINE ICON_LINE.
  IF &4 = 0.
    FORMAT INTENSIFIED OFF.
  ELSE.
    FORMAT INTENSIFIED ON.
  ENDIF.
  WRITE: / '|', &1 AS ICON,   7(59) &2 COLOR &3 , 60 '|'.
END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Form  SHOW_LEGEND
*&---------------------------------------------------------------------*
FORM SHOW_LEGEND.

  NEW-PAGE NO-TITLE LINE-SIZE 60.

  WRITE: /
'Folgende Farben kennzeichnen den Status einer Schnittstelle'(C00).

  SKIP.

  ULINE.
  ICON_LINE ICON_RED_LIGHT
       'Die Version muß noch freigegeben werden'(C01) 6 1.

  ICON_LINE ICON_YELLOW_LIGHT
       'Die Version ist (noch) nicht abgenommen worden'(C02) 3 1.

  ICON_LINE ICON_GREEN_LIGHT
       'Die Version ist freigegeben und abgenommen'(C03) 5 1.

  ICON_LINE SPACE
       ' Historische Version'(C04) COL_NORMAL 1.
  ULINE.

ENDFORM.                    " SHOW_LEGEND

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM TOP_OF_PAGE.


ENDFORM.                    " TOP_OF_PAGE
