*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_READ                                       *
*----------------------------------------------------------------------*
*Änderungen: SIE001 Hierl 17.06.2004 Neue Tabelle S1PS für Filter auf
*                                    Feldebene eingebaut


*---------------------------------------------------------------------*
*       FORM READ_S1                                                  *
*---------------------------------------------------------------------*
*       Liest die Tabelle S1 aus der DB                               *
*---------------------------------------------------------------------*
FORM READ_S1.

  DATA: L_DATA TYPE /SIE/HR_IDP_IFC_DB
      , L_DBSEL TYPE /SIE/HR_IDP_DB_SEL
      .

  IF G_PROC_VEC-S1 = NO.
    G_PROC_VEC-S1 = YES.
    L_DBSEL = G_PROC_VEC.
    CALL FUNCTION '/SIE/HR_IDP_DB_READ'
         EXPORTING
              INTERFACE        = /SIE/HR_IDP_HEAD-IFCID
              VERSION          = G_IFDATA_VERS
         CHANGING
              TRANSACTION_DATA = L_DATA
              DBSEL            = L_DBSEL.

    IF L_DBSEL-S1 = G_PROC_VEC-S1.
      G_IFDATA_TRAN-S1 = L_DATA-S1.
    ELSE.
      CLEAR G_IFDATA_TRAN-S1.
      CLEAR G_PROC_VEC-S1.
    ENDIF.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM READ_S1T                                                 *
*---------------------------------------------------------------------*
*       Liest die Texttabelle S1 ein                                  *
*---------------------------------------------------------------------*
FORM READ_S1T.
  DATA: L_DATA TYPE /SIE/HR_IDP_IFC_DB
      , L_DBSEL TYPE /SIE/HR_IDP_DB_SEL
      .

  IF G_PROC_VEC-S1T = NO.
    G_PROC_VEC-S1T = YES.
    L_DBSEL = G_PROC_VEC.
    CALL FUNCTION '/SIE/HR_IDP_DB_READ'
         EXPORTING
              INTERFACE        = G_IFDATA_TRAN-S1-IFCID
              VERSION          = G_IFDATA_VERS
         CHANGING
              TRANSACTION_DATA = L_DATA
              DBSEL            = L_DBSEL.

    IF L_DBSEL-S1T = G_PROC_VEC-S1T.
      G_IFDATA_TRAN-S1T = L_DATA-S1T.
    ELSE.
      CLEAR G_IFDATA_TRAN-S1T.
    ENDIF.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM READ_S1VN                                                *
*---------------------------------------------------------------------*
*       Liest die Versionierungsdaten                                 *
*---------------------------------------------------------------------*
FORM READ_S1VN.

  DATA: L_DATA TYPE /SIE/HR_IDP_IFC_DB
      , L_DBSEL TYPE /SIE/HR_IDP_DB_SEL
      .

  IF G_PROC_VEC-S1VN = NO.
    G_PROC_VEC-S1VN = YES.
    L_DBSEL = G_PROC_VEC.
    CALL FUNCTION '/SIE/HR_IDP_DB_READ'
         EXPORTING
              INTERFACE        = G_IFDATA_TRAN-S1-IFCID
              VERSION          = G_IFDATA_VERS
         CHANGING
              TRANSACTION_DATA = L_DATA
              DBSEL            = L_DBSEL.

    IF L_DBSEL-S1VN = G_PROC_VEC-S1VN.
      G_IFDATA_TRAN-S1VN = L_DATA-S1VN.
    ELSE.
      CLEAR G_IFDATA_TRAN-S1VN.
    ENDIF.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM READ_S1VT                                                *
*---------------------------------------------------------------------*
*       Liest die Varianten                                           *
*---------------------------------------------------------------------*
FORM READ_S1VT.
  DATA: L_DATA TYPE /SIE/HR_IDP_IFC_DB
      , L_DBSEL TYPE /SIE/HR_IDP_DB_SEL
      .

  IF G_PROC_VEC-S1VT = NO.
    G_PROC_VEC-S1VT = YES.
    L_DBSEL = G_PROC_VEC.
    CALL FUNCTION '/SIE/HR_IDP_DB_READ'
         EXPORTING
              INTERFACE        = G_IFDATA_TRAN-S1-IFCID
              VERSION          = G_IFDATA_VERS
         CHANGING
              TRANSACTION_DATA = L_DATA
              DBSEL            = L_DBSEL.

    IF L_DBSEL-S1VT = G_PROC_VEC-S1VT.
      G_IFDATA_TRAN-S1VT[] = L_DATA-S1VT[].
    ELSE.
      CLEAR G_IFDATA_TRAN-S1VT[].
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  READ_S1R
*&---------------------------------------------------------------------*
FORM READ_S1R.
  DATA: L_DATA TYPE /SIE/HR_IDP_IFC_DB
      , L_DBSEL TYPE /SIE/HR_IDP_DB_SEL
      .

  IF G_PROC_VEC-S1R = NO.
    G_PROC_VEC-S1R = YES.
    L_DBSEL = G_PROC_VEC.
    CALL FUNCTION '/SIE/HR_IDP_DB_READ'
         EXPORTING
              INTERFACE        = G_IFDATA_TRAN-S1-IFCID
              VERSION          = G_IFDATA_VERS
         CHANGING
              TRANSACTION_DATA = L_DATA
              DBSEL            = L_DBSEL.

    IF L_DBSEL-S1R = G_PROC_VEC-S1R.
      G_IFDATA_TRAN-S1R[] = L_DATA-S1R[].
    ELSE.
      CLEAR G_IFDATA_TRAN-S1R[].
    ENDIF.
  ENDIF.

ENDFORM.                                                    " READ_S1R

*---------------------------------------------------------------------*
*       FORM READ_S1DF                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM READ_S1DF.
  DATA: L_DATA TYPE /SIE/HR_IDP_IFC_DB
      , L_DBSEL TYPE /SIE/HR_IDP_DB_SEL
      .

  IF G_PROC_VEC-S1DF = NO.
    G_PROC_VEC-S1DF = YES.
    L_DBSEL = G_PROC_VEC.
    CALL FUNCTION '/SIE/HR_IDP_DB_READ'
         EXPORTING
              INTERFACE        = G_IFDATA_TRAN-S1-IFCID
              VERSION          = G_IFDATA_VERS
         CHANGING
              TRANSACTION_DATA = L_DATA
              DBSEL            = L_DBSEL.

    IF L_DBSEL-S1DF = G_PROC_VEC-S1DF.
      G_IFDATA_TRAN-S1DF = L_DATA-S1DF.
    ELSE.
      CLEAR G_IFDATA_TRAN-S1DF.
    ENDIF.
  ENDIF.

ENDFORM.                                                    " READ_S1df

*---------------------------------------------------------------------*
*       FORM READ_S1PG                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM READ_S1PG.
  DATA: L_DATA TYPE /SIE/HR_IDP_IFC_DB
      , L_DBSEL TYPE /SIE/HR_IDP_DB_SEL
      .

  IF G_PROC_VEC-S1PG = NO.
    G_PROC_VEC-S1PG = YES.
    L_DBSEL = G_PROC_VEC.
    CALL FUNCTION '/SIE/HR_IDP_DB_READ'
         EXPORTING
              INTERFACE        = G_IFDATA_TRAN-S1-IFCID
              VERSION          = G_IFDATA_VERS
         CHANGING
              TRANSACTION_DATA = L_DATA
              DBSEL            = L_DBSEL.

    IF L_DBSEL-S1PG = G_PROC_VEC-S1PG.
      G_IFDATA_TRAN-S1PG[] = L_DATA-S1PG[].
    ELSE.
      CLEAR G_IFDATA_TRAN-S1PG[].
    ENDIF.
  ENDIF.

ENDFORM.                                                    " READ_S1pg

*---------------------------------------------------------------------*
*       FORM READ_S1PS      SIE001                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM READ_S1PS.
  DATA: L_DATA TYPE /SIE/HR_IDP_IFC_DB
      , L_DBSEL TYPE /SIE/HR_IDP_DB_SEL
      .

  IF G_PROC_VEC-S1PS = NO.
    G_PROC_VEC-S1PS = YES.
    L_DBSEL = G_PROC_VEC.
    CALL FUNCTION '/SIE/HR_IDP_DB_READ'
         EXPORTING
              INTERFACE        = G_IFDATA_TRAN-S1-IFCID
              VERSION          = G_IFDATA_VERS
         CHANGING
              TRANSACTION_DATA = L_DATA
              DBSEL            = L_DBSEL.

    IF L_DBSEL-S1PS = G_PROC_VEC-S1PS.
      G_IFDATA_TRAN-S1PS[] = L_DATA-S1PS[].
    ELSE.
      CLEAR G_IFDATA_TRAN-S1PS[].
    ENDIF.
  ENDIF.

ENDFORM.                                                    " READ_S1PS



FORM READ_S1DL.
  DATA: L_DATA TYPE /SIE/HR_IDP_IFC_DB
      , L_DBSEL TYPE /SIE/HR_IDP_DB_SEL
      .

  IF G_PROC_VEC-S1DL = NO.
    G_PROC_VEC-S1DL = YES.
    L_DBSEL = G_PROC_VEC.
    CALL FUNCTION '/SIE/HR_IDP_DB_READ'
         EXPORTING
              INTERFACE        = G_IFDATA_TRAN-S1-IFCID
              VERSION          = G_IFDATA_VERS
         CHANGING
              TRANSACTION_DATA = L_DATA
              DBSEL            = L_DBSEL.

    IF L_DBSEL-S1DL = G_PROC_VEC-S1DL.
      G_IFDATA_TRAN-S1DL = L_DATA-S1DL.
    ELSE.
      CLEAR G_IFDATA_TRAN-S1DL.
    ENDIF.
  ENDIF.

ENDFORM.                                                    " READ_S1dl

*---------------------------------------------------------------------*
*       FORM READ_S1LT                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM READ_S1LT.
  DATA: L_DATA TYPE /SIE/HR_IDP_IFC_DB
      , L_DBSEL TYPE /SIE/HR_IDP_DB_SEL
      .

  CHECK NOT ( G_IFDATA_TRAN-S1-IFCID IS INITIAL ).

  IF G_PROC_VEC-S1LT = NO.
    G_PROC_VEC-S1LT = YES.
    L_DBSEL = G_PROC_VEC.
    CALL FUNCTION '/SIE/HR_IDP_DB_READ'
         EXPORTING
              INTERFACE        = G_IFDATA_TRAN-S1-IFCID
              VERSION          = G_IFDATA_VERS
         CHANGING
              TRANSACTION_DATA = L_DATA
              DBSEL            = L_DBSEL.

    IF L_DBSEL-S1LT = G_PROC_VEC-S1LT.
      G_IFDATA_TRAN-S1LT[] = L_DATA-S1LT[].
    ELSE.
      CLEAR G_IFDATA_TRAN-S1LT.
    ENDIF.
  ENDIF.

ENDFORM.                                                    " READ_S1pg


*---------------------------------------------------------------------*
*       FORM READ_S1F                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM READ_S1F.

  DATA: L_DATA TYPE /SIE/HR_IDP_IFC_DB
      , L_DBSEL TYPE /SIE/HR_IDP_DB_SEL
      .
  CHECK NOT ( G_IFDATA_VERS IS INITIAL ).

  IF G_PROC_VEC-S1F = NO.
    G_PROC_VEC-S1F = YES.
    L_DBSEL = G_PROC_VEC.
    CALL FUNCTION '/SIE/HR_IDP_DB_READ'
         EXPORTING
              INTERFACE        = G_IFDATA_TRAN-S1-IFCID
              VERSION          = G_IFDATA_VERS
         CHANGING
              TRANSACTION_DATA = L_DATA
              DBSEL            = L_DBSEL.

    IF L_DBSEL-S1F = G_PROC_VEC-S1F.
      G_IFDATA_TRAN-S1F[] = L_DATA-S1F[].
    ELSE.
      CLEAR G_IFDATA_TRAN-S1F[].
    ENDIF.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM READ_S1PR                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM READ_S1PR.
  DATA: L_DATA TYPE /SIE/HR_IDP_IFC_DB
      , L_DBSEL TYPE /SIE/HR_IDP_DB_SEL
      .

  IF G_PROC_VEC-S1PR = NO.
    G_PROC_VEC-S1PR = YES.
    L_DBSEL = G_PROC_VEC.
    CALL FUNCTION '/SIE/HR_IDP_DB_READ'
         EXPORTING
              INTERFACE        = G_IFDATA_TRAN-S1-IFCID
              VERSION          = G_IFDATA_VERS
         CHANGING
              TRANSACTION_DATA = L_DATA
              DBSEL            = L_DBSEL.

    IF L_DBSEL-S1PR = G_PROC_VEC-S1PR.
      G_IFDATA_TRAN-S1PR = L_DATA-S1PR.
    ELSE.
      CLEAR G_IFDATA_TRAN-S1PR.
    ENDIF.
  ENDIF.

ENDFORM.                                                    " READ_S1R

*---------------------------------------------------------------------*
*       FORM READ_S1SA                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM READ_S1SA.
  DATA: L_DATA TYPE /SIE/HR_IDP_IFC_DB
      , L_DBSEL TYPE /SIE/HR_IDP_DB_SEL
      .

  IF G_PROC_VEC-S1SA = NO.
    G_PROC_VEC-S1SA = YES.
    L_DBSEL = G_PROC_VEC.
    CALL FUNCTION '/SIE/HR_IDP_DB_READ'
         EXPORTING
              INTERFACE        = G_IFDATA_TRAN-S1-IFCID
              VERSION          = G_IFDATA_VERS
         CHANGING
              TRANSACTION_DATA = L_DATA
              DBSEL            = L_DBSEL.

    IF L_DBSEL-S1SA = G_PROC_VEC-S1SA.
      G_IFDATA_TRAN-S1SA = L_DATA-S1SA.
*      sort g_ifdata_tran-s1sa by sortn.
    ELSE.
      CLEAR G_IFDATA_TRAN-S1SA.
    ENDIF.
  ENDIF.
ENDFORM.                                                    " READ_S1SA

FORM READ_S1PC.
  DATA: L_DATA TYPE /SIE/HR_IDP_IFC_DB
      , L_DBSEL TYPE /SIE/HR_IDP_DB_SEL
      .

  IF G_PROC_VEC-S1PC = NO.
    G_PROC_VEC-S1PC = YES.
    L_DBSEL = G_PROC_VEC.
    CALL FUNCTION '/SIE/HR_IDP_DB_READ'
         EXPORTING
              INTERFACE        = G_IFDATA_TRAN-S1-IFCID
              VERSION          = G_IFDATA_VERS
         CHANGING
              TRANSACTION_DATA = L_DATA
              DBSEL            = L_DBSEL.

    IF L_DBSEL-S1PC = G_PROC_VEC-S1PC.
      G_IFDATA_TRAN-S1PC = L_DATA-S1PC.
    ELSE.
      CLEAR G_IFDATA_TRAN-S1PC.
    ENDIF.
  ENDIF.
ENDFORM.                                                    " READ_S1PC
