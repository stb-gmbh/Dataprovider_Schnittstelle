*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /SIE/HR_IEMPKENZ................................*
DATA:  BEGIN OF STATUS_/SIE/HR_IEMPKENZ              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/SIE/HR_IEMPKENZ              .
CONTROLS: TCTRL_/SIE/HR_IEMPKENZ
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */SIE/HR_IEMPKENZ              .
TABLES: /SIE/HR_IEMPKENZ               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
