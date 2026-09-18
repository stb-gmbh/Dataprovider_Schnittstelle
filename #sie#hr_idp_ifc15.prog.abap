*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC15 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  SET_PF_STATUS_103  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_PF_STATUS_103 OUTPUT.
  SET TITLEBAR  C_COPY_PFST WITH G_IFDATA_TRAN-S1-IFCID.
  SET PF-STATUS C_COPY_MUST.
ENDMODULE.                 " SET_PF_STATUS_103  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  IFCID_READ  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE IFCID_READ OUTPUT.

* Per default werden die aktuellen Daten übernommen.
  MOVE G_IFDATA_TRAN-S1-IFCID TO /SIE/HR_IDP_COPY_FIELDS-IFCID.
  MOVE G_IFDATA_VERS TO /SIE/HR_IDP_COPY_FIELDS-VRSNR.

* Die aktuelle Schnittstelle wird auch als Name vorgeschlagen, sollte
* aber noch abgeändert werden.
  MOVE G_IFDATA_TRAN-S1-IFCID TO /SIE/HR_IDP_COPY_FIELDS-NEW_IFCID.

ENDMODULE.                 " IFCID_READ  OUTPUT
