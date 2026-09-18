*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_O3000 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  INIT_3000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_3000 OUTPUT.

  PERFORM CHECK_AUTHORITY USING SY-TCODE
                             C_CONFIRM
                             G_IFDATA_TRAN-S1-AUTH_CLASS
                             G_IFDATA_TRAN-S1-IFCID
                             SPACE
                        CHANGING RC.

  CLEAR: OKCODE, SVCODE.

  IF ( /SIE/HR_IDP_S1-IFCID IS INITIAL ).
    GET PARAMETER ID '/SIE/HR_IDP_IFCID' FIELD /SIE/HR_IDP_S1-IFCID.
  ENDIF.

* if g_ifdata_oldv ne /sie/hr_idp_s1-ifcid.
*   clear /sie/hr_idp_s1t.
*   g_ifdata_tran-s1-ifcid = /sie/hr_idp_s1-ifcid.
* endif.

  IF ( G_IFDATA_OLDV NE /SIE/HR_IDP_S1-IFCID ) OR
     ( G_IFDATA_VERS NE OLD_VERSION ).

    PERFORM DEQUEUE.

    IF G_IFDATA_VERS IS INITIAL.
*     g_ifdata_vers = '0001'.
    ENDIF.

    OLD_VERSION = G_IFDATA_VERS.
    G_IFDATA_OLDV = /SIE/HR_IDP_S1-IFCID.

* alles nochmal einlesen.
    CLEAR G_PROC_VEC.
    CLEAR G_IFDATA_TRAN.
    CLEAR G_ITAB_S1PG[]. CLEAR G_1004_LOADED.
    CLEAR /SIE/HR_IDP_S1T.

    G_IFDATA_TRAN-S1-IFCID = G_IFDATA_OLDV.

  ENDIF.

  /SIE/HR_IDP_HEAD-IFCID = /SIE/HR_IDP_S1-IFCID.

ENDMODULE.                 " INIT_3000  OUTPUT
