*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/SIE/HR_IEMPKENZ
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/SIE/HR_IEMPKENZ   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
