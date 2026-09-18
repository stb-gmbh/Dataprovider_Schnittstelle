*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_ALERT_DAT                                  *
*----------------------------------------------------------------------*

TABLES: /sie/hr_idp_ifc_validity_mail
      , /sie/hr_idp_roles
      , /sie/hr_idp_s1
      , /sie/hr_idp_s1t
      , /sie/hr_idp_s1r
      , /sie/hr_idp_s1pc
      , /sie/hr_idp_s1pg
      , /sie/hr_idp_s1vt
      , /sie/hr_idp_s1vn
      , /sie/hr_idp_s1sa
      , /sie/hr_idp_s1pr   " Parameter
      , /sie/hr_idp_s1df   " UC4 Parameter
      , /sie/hr_idp_s1dl   " Delimiter
      , /sie/hr_idp_f1t
      , /sie/hr_idp_vs1t
      , rstxd
      .

INCLUDE rssocons.

TYPES: cont_type   TYPE STANDARD TABLE OF solisti1.

DATA: contents     TYPE cont_type WITH HEADER LINE
    , receivers    TYPE STANDARD TABLE OF somlreci1 WITH HEADER LINE
    , receivers_h  TYPE STANDARD TABLE OF somlreci1 WITH HEADER LINE
    .

DATA:  gt_interfaces TYPE STANDARD TABLE OF /sie/hr_idp_monitor_gd
                          INITIAL SIZE 0 WITH HEADER LINE
     , g_wa_interfaces TYPE /sie/hr_idp_monitor_gd
     , selections TYPE STANDARD TABLE OF /sie/hr_idp_s1vt INITIAL SIZE 0
       WITH HEADER LINE
     .

DATA: wa_s1vt LIKE /sie/hr_idp_vs1t.

DATA: g_vs1t TYPE STANDARD TABLE OF /sie/hr_idp_vs1t
    , g_data TYPE STANDARD TABLE OF /sie/hr_idp_ifcsearch
    , g_wa TYPE /sie/hr_idp_ifcsearch
    , idx TYPE i
    .

DATA: text_element_tab TYPE STANDARD TABLE OF itcwe
                            INITIAL SIZE 0 WITH HEADER LINE
    .
DATA  subrc LIKE sy-subrc.
