*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/SIE/HR_IDP_SE54
*   generation date: 08.02.2002 at 16:03:18 by user MCH0664
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/SIE/HR_IDP_SE54   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
