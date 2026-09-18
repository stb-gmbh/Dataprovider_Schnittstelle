*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 28.02.2002 at 10:48:20 by user MCH0664
*---------------------------------------------------------------------*
*...processing: /SIE/HR_IDP_V1..................................*
DATA:  BEGIN OF STATUS_/SIE/HR_IDP_V1                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/SIE/HR_IDP_V1                .
CONTROLS: TCTRL_/SIE/HR_IDP_V1
            TYPE TABLEVIEW USING SCREEN '0006'.
*...processing: /SIE/HR_IDP_VC1T................................*
TABLES: /SIE/HR_IDP_VC1T, */SIE/HR_IDP_VC1T. "view work areas
CONTROLS: TCTRL_/SIE/HR_IDP_VC1T
TYPE TABLEVIEW USING SCREEN '0007'.
DATA: BEGIN OF STATUS_/SIE/HR_IDP_VC1T. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/SIE/HR_IDP_VC1T.
* Table for entries selected to show on screen
DATA: BEGIN OF /SIE/HR_IDP_VC1T_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /SIE/HR_IDP_VC1T.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /SIE/HR_IDP_VC1T_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /SIE/HR_IDP_VC1T_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /SIE/HR_IDP_VC1T.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /SIE/HR_IDP_VC1T_TOTAL.

*...processing: /SIE/HR_IDP_VF0T................................*
TABLES: /SIE/HR_IDP_VF0T, */SIE/HR_IDP_VF0T. "view work areas
CONTROLS: TCTRL_/SIE/HR_IDP_VF0T
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/SIE/HR_IDP_VF0T. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/SIE/HR_IDP_VF0T.
* Table for entries selected to show on screen
DATA: BEGIN OF /SIE/HR_IDP_VF0T_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /SIE/HR_IDP_VF0T.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /SIE/HR_IDP_VF0T_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /SIE/HR_IDP_VF0T_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /SIE/HR_IDP_VF0T.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /SIE/HR_IDP_VF0T_TOTAL.

*...processing: /SIE/HR_IDP_VF1S................................*
TABLES: /SIE/HR_IDP_VF1S, */SIE/HR_IDP_VF1S. "view work areas
CONTROLS: TCTRL_/SIE/HR_IDP_VF1S
TYPE TABLEVIEW USING SCREEN '0005'.
DATA: BEGIN OF STATUS_/SIE/HR_IDP_VF1S. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/SIE/HR_IDP_VF1S.
* Table for entries selected to show on screen
DATA: BEGIN OF /SIE/HR_IDP_VF1S_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /SIE/HR_IDP_VF1S.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /SIE/HR_IDP_VF1S_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /SIE/HR_IDP_VF1S_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /SIE/HR_IDP_VF1S.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /SIE/HR_IDP_VF1S_TOTAL.

*...processing: /SIE/HR_IDP_VF1T................................*
TABLES: /SIE/HR_IDP_VF1T, */SIE/HR_IDP_VF1T. "view work areas
CONTROLS: TCTRL_/SIE/HR_IDP_VF1T
TYPE TABLEVIEW USING SCREEN '0003'.
DATA: BEGIN OF STATUS_/SIE/HR_IDP_VF1T. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/SIE/HR_IDP_VF1T.
* Table for entries selected to show on screen
DATA: BEGIN OF /SIE/HR_IDP_VF1T_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /SIE/HR_IDP_VF1T.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /SIE/HR_IDP_VF1T_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /SIE/HR_IDP_VF1T_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /SIE/HR_IDP_VF1T.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /SIE/HR_IDP_VF1T_TOTAL.

*...processing: /SIE/HR_IDP_VS0T................................*
TABLES: /SIE/HR_IDP_VS0T, */SIE/HR_IDP_VS0T. "view work areas
CONTROLS: TCTRL_/SIE/HR_IDP_VS0T
TYPE TABLEVIEW USING SCREEN '0009'.
DATA: BEGIN OF STATUS_/SIE/HR_IDP_VS0T. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/SIE/HR_IDP_VS0T.
* Table for entries selected to show on screen
DATA: BEGIN OF /SIE/HR_IDP_VS0T_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /SIE/HR_IDP_VS0T.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /SIE/HR_IDP_VS0T_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /SIE/HR_IDP_VS0T_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /SIE/HR_IDP_VS0T.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /SIE/HR_IDP_VS0T_TOTAL.

*.........table declarations:.................................*
TABLES: */SIE/HR_IDP_V1                .
TABLES: /SIE/HR_IDP_C1                 .
TABLES: /SIE/HR_IDP_C1T                .
TABLES: /SIE/HR_IDP_F0                 .
TABLES: /SIE/HR_IDP_F0T                .
TABLES: /SIE/HR_IDP_F1                 .
TABLES: /SIE/HR_IDP_F1S                .
TABLES: /SIE/HR_IDP_F1T                .
TABLES: /SIE/HR_IDP_S0                 .
TABLES: /SIE/HR_IDP_S0T                .
TABLES: /SIE/HR_IDP_V1                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
