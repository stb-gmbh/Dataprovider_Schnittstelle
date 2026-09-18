*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_O2500 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  INIT_2500  OUTPUT
*&---------------------------------------------------------------------*
*       Initialisiere das Eingangsbildschirm und setze Defaults
*       falls nötig
*----------------------------------------------------------------------*
MODULE INIT_2500 OUTPUT.

* Berechtigungsprüfung
  PERFORM CHECK_AUTHORITY USING SY-TCODE
                             C_CREATE_EXE_T
                             G_IFDATA_TRAN-S1-AUTH_CLASS
                             G_IFDATA_TRAN-S1-IFCID
                             SPACE
                        CHANGING RC.

* Setze default Schnittstellen-Id
  IF ( /SIE/HR_IDP_S1-IFCID IS INITIAL ).
    GET PARAMETER ID '/SIE/HR_IDP_IFCID' FIELD /SIE/HR_IDP_S1-IFCID.
  ENDIF.

* Merken, ob dieselbe Schnittstelle vorhin ausgeführt wurde
  IF ( G_IFDATA_OLDV NE /SIE/HR_IDP_S1-IFCID ) OR
     ( G_IFDATA_VERS NE OLD_VERSION ).

    PERFORM DEQUEUE.

    OLD_VERSION = G_IFDATA_VERS.
    G_IFDATA_OLDV = /SIE/HR_IDP_S1-IFCID.

    CLEAR G_PROC_VEC.
    CLEAR G_IFDATA_TRAN.
    CLEAR /SIE/HR_IDP_S1T.

    CLEAR /SIE/HR_IDP_A1.

    G_IFDATA_TRAN-S1-IFCID = G_IFDATA_OLDV.

  ENDIF.

ENDMODULE.                 " INIT_2500  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_2500  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_2500 OUTPUT.

* Einlesen der letzten freigegebenen Version
  PERFORM READ_RELEASED_VERS USING /SIE/HR_IDP_S1-IFCID
                             CHANGING /SIE/HR_IDP_S1-ACT_VERS_NR.

* Einlesen Kurztexte
  PERFORM READ_SHORT_TEXT USING /SIE/HR_IDP_S1-IFCID
                          CHANGING /SIE/HR_IDP_S1T-IDENT.

* Setzen der globalen "Merkervariable"
  G_IFDATA_TRAN-S1-IFCID = /SIE/HR_IDP_S1-IFCID.
  G_IFDATA_VERS = /SIE/HR_IDP_S1-ACT_VERS_NR.

ENDMODULE.                 " READ_2500  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SYNC_2500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SYNC_2500 INPUT.
  /SIE/HR_IDP_HEAD-IFCID = /SIE/HR_IDP_S1-IFCID.
  G_IFDATA_TRAN-S1-IFCID = /SIE/HR_IDP_S1-IFCID.
ENDMODULE.                 " SYNC_2500  INPUT
