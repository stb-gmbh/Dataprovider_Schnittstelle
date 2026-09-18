*&---------------------------------------------------------------------*
*& Include /SIE/HR_IDP_MONITOR_GD_TOP                                  *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  /SIE/HR_IDP_MONITOR_GD MESSAGE-ID /SIE/HR_IDP_MESSAGES.

TABLES: /SIE/HR_IDP_S1
      , /SIE/HR_IDP_S1DF
      , /SIE/HR_IDP_S1T
      , /SIE/HR_IDP_MONITOR_GD
      , /SIE/HR_IDP_MONITOR_HEAD
      , /SIE/HR_IDP_ROLES
      .

INCLUDE <ICON>.
INCLUDE /SIE/HR_IDP_UT_FCAT_MAC.   " Macros

TYPES: /SIE/HR_IDP_TYPES.

DATA: OKCODE TYPE SYUCOMM
    , SVCODE TYPE SYUCOMM
    .

DATA: GT_INTERFACES TYPE STANDARD TABLE OF /SIE/HR_IDP_MONITOR_GD
      INITIAL SIZE 0 WITH HEADER LINE
    , G_WA_INTERFACES TYPE /SIE/HR_IDP_MONITOR_GD
    , GD_DATE TYPE D
    , GD_INTERVAL TYPE I VALUE 2
    .

CONTROLS: CTRL_VALIDITY TYPE TABLEVIEW USING SCREEN 5000.

DATA: TXT_INTERVAL(55) TYPE C
    , STEP_LINES LIKE SY-TABIX
    .





















DATA  G_CC TYPE SO_REC_EXT.
