*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_I11                                        *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  WRITE_1001  INPUT
*&---------------------------------------------------------------------*
*       Füllen der globalen Datenstruktur
*----------------------------------------------------------------------*
MODULE WRITE_1001 INPUT.
  G_IFDATA_TRAN-S1-VALID_FROM = /SIE/HR_IDP_S1-VALID_FROM.
  G_IFDATA_TRAN-S1-VALID_TO = /SIE/HR_IDP_S1-VALID_TO.
  G_IFDATA_TRAN-S1-CUSTOMER = /SIE/HR_IDP_S1-CUSTOMER.
  G_IFDATA_TRAN-S1-AUTH_CLASS = /SIE/HR_IDP_S1-AUTH_CLASS.

  LOOP AT G_IFDATA_TRAN-S1R INTO /SIE/HR_IDP_S1R.
    /SIE/HR_IDP_S1R-IFCID = G_IFDATA_TRAN-S1-IFCID.
    MODIFY G_IFDATA_TRAN-S1R FROM /SIE/HR_IDP_S1R.
  ENDLOOP.

ENDMODULE.                 " WRITE_1001  INPUT

*&---------------------------------------------------------------------*
*&      Module  WRITE_MATRIX_1001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       MODULE WRITE_MATRIX INPUT                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE WRITE_MATRIX INPUT.
  READ TABLE G_IFDATA_TRAN-S1R INTO /SIE/HR_IDP_S1R
             WITH KEY TROLE = /SIE/HR_IDP_IFC_ROLES-TROLE.
  G_TABIX = SY-TABIX.
  /SIE/HR_IDP_S1R-IFCID = G_IFDATA_TRAN-S1-IFCID.
  /SIE/HR_IDP_S1R-PERNR = /SIE/HR_IDP_IFC_ROLES-PERNR.
  /SIE/HR_IDP_S1R-ORGEH = /SIE/HR_IDP_IFC_ROLES-ORGEH.
  /SIE/HR_IDP_S1R-USERN = /SIE/HR_IDP_IFC_ROLES-USERN.
  /SIE/HR_IDP_S1R-EMAIL = /SIE/HR_IDP_IFC_ROLES-EMAIL.

  MODIFY G_IFDATA_TRAN-S1R FROM /SIE/HR_IDP_S1R INDEX G_TABIX.
ENDMODULE.                 " WRITE_MATRIX_1001  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_DATES  INPUT
*&---------------------------------------------------------------------*
*       Prüft ob Die Daten auf dem Dynpro konsistent sind
*----------------------------------------------------------------------*
MODULE CHECK_DATES INPUT.

  IF /SIE/HR_IDP_S1-VALID_FROM > /SIE/HR_IDP_S1-VALID_TO.
    MESSAGE W120.
  ENDIF.

ENDMODULE.                 " CHECK_DATES  INPUT
