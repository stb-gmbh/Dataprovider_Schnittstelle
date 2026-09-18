*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_STAT_SOS                                       *
*----------------------------------------------------------------------*

START-OF-SELECTION.
*  set pf-status 'LISTE'.
  PERFORM CLEAR_ALL.
  PERFORM READ_DB.
  PERFORM WRITE_LOGS.

*---------------------------------------------------------------------*
*       FORM CLEAR_ALL                                                *
*---------------------------------------------------------------------*
FORM CLEAR_ALL.
  CLEAR: GT_AUTH_IFCID[]
       , GT_S1S[]
       , GT_S1P[]
       , GT_S1L[]
       , GT_S1S[]
       , R_IFCID[]
       .
ENDFORM.
