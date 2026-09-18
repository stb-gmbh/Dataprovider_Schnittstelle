PROCESS BEFORE OUTPUT.
 MODULE SET_TRAN_STATUS_1007.
 MODULE INIT.                               " Wird von allen aufgerufen
 MODULE SET_STATUS.                         " Wird von allen aufgerufen
 MODULE READ_S1VN.
 CALL SUBSCREEN SUBSCR_TITLE INCLUDING '/SIE/HR_IDP_IFC' C_TITL_SDYN.
 MODULE READ_S1PC.
 MODULE READ_S1LT.
 MODULE FILL_1007.
 MODULE MODIFY_SCREEN.
 MODULE MODIFY_1007.
*
PROCESS AFTER INPUT.
 MODULE EXIT_COMMAND AT EXIT-COMMAND.       " Wird von allen aufgerufen
  CHAIN.
   FIELD: /SIE/HR_IDP_S1PC-KSTORGID
        , /SIE/HR_IDP_S1PC-KSTBSTLN
        , /SIE/HR_IDP_S1PC-VERWZWCK
        , /SIE/HR_IDP_S1PC-KOSTKATE
        , /SIE/HR_IDP_S1PC-KOSTKATP
*       , /sie/hr_idp_s1pc-kzkosdir
        , /SIE/HR_IDP_S1PC-KOSTENDR
        , /SIE/HR_IDP_S1PC-CURRENCY
       .
   MODULE READ_1007 ON CHAIN-REQUEST.
 ENDCHAIN.
 MODULE COPY_OK_CODE.                       " Wird von allen aufgerufen
 CALL SUBSCREEN SUBSCR_TITLE.               " Wird von allen aufgerufen
 MODULE USER_COMMAND.                       " Wird von allen aufgerufen


