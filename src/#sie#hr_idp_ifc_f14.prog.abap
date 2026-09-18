*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_F14 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  IFC_SAVE
*&---------------------------------------------------------------------*
*       Speichern der Schnittstelle
*----------------------------------------------------------------------*
FORM IFC_SAVE.
  /SIE/HR_IDP_DB_SEL = G_PROC_VEC.

  CALL FUNCTION '/SIE/HR_IDP_DB_UPDATE'
       EXPORTING
            INTERFACE        = G_IFDATA_TRAN-S1-IFCID
            VERSION          = G_IFDATA_VERS
            SW_COMMIT_WORK   = YES
       CHANGING
            DBSEL            = /SIE/HR_IDP_DB_SEL
            TRANSACTION_DATA = G_IFDATA_TRAN.

  IF /SIE/HR_IDP_DB_SEL EQ G_PROC_VEC. "alles erledigt?
* Wurde eine neue Schnittstelle angelegt, so wird diese als
* neu angelegt als Nachricht ausgegeben, ansonsten als verändert.
* Der Flag wird gleichzeitig gelöscht. (?)
    IF SY-TCODE = C_NEW__TCOD.
      MESSAGE S051 WITH G_IFDATA_TRAN-S1-IFCID.
    ELSE.
      MESSAGE S053 WITH G_IFDATA_TRAN-S1-IFCID.
    ENDIF.
*    call function '/SIE/HR_IDP_DB_CHECK'
*         exporting
*              interface        = g_ifdata_tran-s1-ifcid
*              version          = g_ifdata_vers
*              transaction_data = g_ifdata_tran
*         changing
*              dbsel            = g_proc_vec
*              .
  ELSE.  " Nein
    MESSAGE S052 WITH G_IFDATA_TRAN-S1-IFCID.
  ENDIF.

ENDFORM.                    " IFC_SAVE
