*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_MONITOR_GD_O5000 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  READ_IFCID  OUTPUT
*&---------------------------------------------------------------------*
*       Einlesen der Schnittstellenstati
*----------------------------------------------------------------------*
MODULE read_ifcid OUTPUT.

  CALL FUNCTION '/SIE/HR_IDP_READ_VALIDITY_DATE'
       EXPORTING
            interval       = /sie/hr_idp_monitor_head-val_interval
       IMPORTING
            date_to        = /sie/hr_idp_monitor_head-date_to
       TABLES
            tab_interfaces = gt_interfaces
       CHANGING
            date_from      = /sie/hr_idp_monitor_head-val_date.

  LOOP AT gt_interfaces INTO g_wa_interfaces.

    SELECT SINGLE * FROM /sie/hr_idp_s1t
                    WHERE ifcid = g_wa_interfaces-ifcid
                    AND   spras = sy-langu.
    g_wa_interfaces-ident = /sie/hr_idp_s1t-ident.

    g_wa_interfaces-cmdbt = icon_allow.

    MODIFY gt_interfaces FROM g_wa_interfaces.
  ENDLOOP.

  SORT gt_interfaces BY ifcid ASCENDING.

  DESCRIBE TABLE gt_interfaces.
  ctrl_validity-lines = sy-tfill.



ENDMODULE.                 " READ_IFCID  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_5000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_5000 OUTPUT.

  DATA: g_c(5) TYPE c
      , g_d(10) TYPE c
      , g_d2(10) TYPE c
      .

  WRITE: /sie/hr_idp_monitor_head-val_interval TO g_c LEFT-JUSTIFIED.
  WRITE: /sie/hr_idp_monitor_head-val_date TO g_d LEFT-JUSTIFIED.
  WRITE: /sie/hr_idp_monitor_head-date_to TO g_d2 LEFT-JUSTIFIED.

  CLEAR txt_interval.
  CONCATENATE g_d '-' g_d2 '(' g_c 'Monate' ')'             "#EC NOTEXT
                           INTO txt_interval SEPARATED BY space.

  SET PF-STATUS 'MON_MAIN'.
*  set pf-status 'IFC_GENERAL' of program '/SIE/HR_IDP_IFC'.
  SET TITLEBAR 'MON_MAIN' WITH txt_interval.

ENDMODULE.                 " STATUS_5000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_5000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_5000 OUTPUT.

  IF /sie/hr_idp_monitor_head-val_date IS INITIAL.
    /sie/hr_idp_monitor_head-val_date = sy-datum.
    /sie/hr_idp_monitor_head-ext_uc4 = 'X'.                 "#EC NOTEXT
  ENDIF.

  IF /sie/hr_idp_monitor_head-val_interval IS INITIAL.
    /sie/hr_idp_monitor_head-val_interval = 2.
  ENDIF.

  IF /sie/hr_idp_monitor_head-ext_interval IS INITIAL.
    CALL FUNCTION '/SIE/HR_IDP_DEFAULT_VALIDITY'
         IMPORTING
              months = /sie/hr_idp_monitor_head-ext_interval.
  ENDIF.

ENDMODULE.                 " INIT_5000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_EMPTY  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_empty OUTPUT.
  DESCRIBE TABLE gt_interfaces.
  IF sy-tfill >< 0.
  ELSE.
    MESSAGE s252.
  ENDIF.
ENDMODULE.                 " CHECK_EMPTY  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_screen OUTPUT.
  IF /sie/hr_idp_monitor_gd-ifcid = space.
    LOOP AT SCREEN.
      CHECK screen-name = '/SIE/HR_IDP_MONITOR_GD-CMDBT'.
      screen-active = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " SET_SCREEN  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE lines OUTPUT.
  step_lines = sy-loopc.
ENDMODULE.                 " LINES  OUTPUT
