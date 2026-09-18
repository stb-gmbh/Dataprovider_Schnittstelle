*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_I1000 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  CHECK_CHANGE  INPUT
*&---------------------------------------------------------------------*
*       Prüft, ob der Name der Schnittstelle sich geändert hat
*----------------------------------------------------------------------*
MODULE CHECK_CHANGE INPUT.

  IF G_IFDATA_OLDV >< /SIE/HR_IDP_HEAD-IFCID.
    G_IFDATA_VERS = '0000'.
    GV_FLAG_NEWVERSION = YES.
  ENDIF.

ENDMODULE.                 " CHECK_CHANGE  INPUT
