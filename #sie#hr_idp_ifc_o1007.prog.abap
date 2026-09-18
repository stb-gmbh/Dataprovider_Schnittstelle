*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_O1007 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  FILL_1007  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FILL_1007 OUTPUT.

  CLEAR /SIE/HR_IDP_S1PC.
  G_IFDATA_TRAN-S1PC-IFCID = G_IFDATA_TRAN-S1-IFCID.
  G_IFDATA_TRAN-S1PC-VRSNR = G_IFDATA_VERS.

  MOVE-CORRESPONDING G_IFDATA_TRAN-S1PC TO /SIE/HR_IDP_S1PC.

ENDMODULE.                 " FILL_1007  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  MODIFY_1007  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_1007 OUTPUT.
*  loop at screen.
*    if screen-name = '/SIE/HR_IDP_S1PC-KOSTENDR' or
*       screen-name = '/SIE/HR_IDP_S1PC-CURRENCY'.
*      if not ( /sie/hr_idp_s1pc-kzkosdir is initial ).
*        screen-input = 1.
*      else.
*        screen-input = 0.
*      endif.
*      modify screen.
*    endif.
*  endloop.
ENDMODULE.                 " MODIFY_1007  OUTPUT
