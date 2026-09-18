*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_I1007 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  READ_1007  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_1007 INPUT.
  MOVE-CORRESPONDING /SIE/HR_IDP_S1PC TO G_IFDATA_TRAN-S1PC.
  IF G_IFDATA_TRAN-S1PC-IFCID IS INITIAL.
    G_IFDATA_TRAN-S1PC-IFCID = G_IFDATA_TRAN-S1-IFCID.
    G_IFDATA_TRAN-S1PC-VRSNR = G_IFDATA_VERS.
  ENDIF.

  IF NOT ( G_IFDATA_TRAN-S1PC-KOSTKATE IS INITIAL ) AND
     NOT ( G_IFDATA_TRAN-S1PC-KOSTENDR IS INITIAL ).
    MESSAGE E158.
  ENDIF.

  IF G_IFDATA_TRAN-S1PC-CURRENCY IS INITIAL.
    G_IFDATA_TRAN-S1PC-CURRENCY = 'EUR'.                    "#EC NOTEXT
  ENDIF.

ENDMODULE.                 " READ_1007  INPUT
