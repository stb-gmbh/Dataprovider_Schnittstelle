*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_I100 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_100  INPUT
*&---------------------------------------------------------------------*
*       Füllt aus dem Dynpro die Variablen zurück.
*----------------------------------------------------------------------*
MODULE COPY_DATA_100 INPUT.

  G_IFDATA_TRAN-S1-IFCID = /SIE/HR_IDP_HEAD-IFCID.
  G_IFDATA_TRAN-S1T-IDENT = /SIE/HR_IDP_HEAD-IDENT.

* Beim Anlegen einer Schnittstelle kann sich der Schnittstellenname
* ändern!!
  IF SY-TCODE = '/SIE/HR_IDP_IFC_NEW'.

    G_IFDATA_TRAN-S1T-IFCID = /SIE/HR_IDP_HEAD-IFCID.

    IF G_PROC_VEC-S1VN = YES.
      G_IFDATA_TRAN-S1VN-IFCID = /SIE/HR_IDP_HEAD-IFCID.
    ENDIF.

    IF G_PROC_VEC-S1DF = YES.
      G_IFDATA_TRAN-S1DF-IFCID = /SIE/HR_IDP_HEAD-IFCID.
    ENDIF.

    IF G_PROC_VEC-S1PR = YES.
      G_IFDATA_TRAN-S1PR-IFCID = /SIE/HR_IDP_HEAD-IFCID.
    ENDIF.

    IF G_PROC_VEC-S1DL = YES.
      G_IFDATA_TRAN-S1DL-IFCID = /SIE/HR_IDP_HEAD-IFCID.
    ENDIF.

    IF G_PROC_VEC-S1VT = YES.
      LOOP AT G_IFDATA_TRAN-S1VT INTO /SIE/HR_IDP_S1VT.
        /SIE/HR_IDP_S1VT-IFCID = /SIE/HR_IDP_HEAD-IFCID.
        MODIFY G_IFDATA_TRAN-S1VT FROM /SIE/HR_IDP_S1VT.
      ENDLOOP.
    ENDIF.

    IF G_PROC_VEC-S1R = YES.
      LOOP AT G_IFDATA_TRAN-S1R INTO /SIE/HR_IDP_S1R.
        /SIE/HR_IDP_S1R-IFCID = /SIE/HR_IDP_HEAD-IFCID.
        MODIFY G_IFDATA_TRAN-S1R FROM /SIE/HR_IDP_S1R.
      ENDLOOP.
    ENDIF.

    IF G_PROC_VEC-S1LT = YES.
      LOOP AT G_IFDATA_TRAN-S1LT INTO /SIE/HR_IDP_S1LT.
        /SIE/HR_IDP_S1LT-IFCID = /SIE/HR_IDP_HEAD-IFCID.
        MODIFY G_IFDATA_TRAN-S1LT FROM /SIE/HR_IDP_S1LT.
      ENDLOOP.
    ENDIF.

    IF G_PROC_VEC-S1F = YES.
      LOOP AT G_IFDATA_TRAN-S1F INTO /SIE/HR_IDP_S1F.
        /SIE/HR_IDP_S1F-IFCID = /SIE/HR_IDP_HEAD-IFCID.
        MODIFY G_IFDATA_TRAN-S1F FROM /SIE/HR_IDP_S1F.
      ENDLOOP.
    ENDIF.

    IF G_PROC_VEC-S1SA = YES.
      LOOP AT G_IFDATA_TRAN-S1SA INTO /SIE/HR_IDP_S1SA.
        /SIE/HR_IDP_S1SA-IFCID = /SIE/HR_IDP_HEAD-IFCID.
        MODIFY G_IFDATA_TRAN-S1SA FROM /SIE/HR_IDP_S1SA.
      ENDLOOP.
    ENDIF.

    IF G_PROC_VEC-S1PG = YES.
      LOOP AT G_IFDATA_TRAN-S1PG INTO /SIE/HR_IDP_S1PG.
        /SIE/HR_IDP_S1PG-IFCID = /SIE/HR_IDP_HEAD-IFCID.
        MODIFY G_IFDATA_TRAN-S1PG FROM /SIE/HR_IDP_S1PG.
      ENDLOOP.
    ENDIF.

    IF G_PROC_VEC-S1PC = YES.
      G_IFDATA_TRAN-S1PC-IFCID = /SIE/HR_IDP_HEAD-IFCID.
    ENDIF.

  ENDIF.

ENDMODULE.                 " USER_COMMAND_100  INPUT
