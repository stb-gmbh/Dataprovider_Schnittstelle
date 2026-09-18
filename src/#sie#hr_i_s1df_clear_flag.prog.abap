*&---------------------------------------------------------------------*
*& Report  /SIE/HR_I_S1DF_CLEAR_FLAG
*&
*&---------------------------------------------------------------------*
*& S. Bogdanski 24.03.2023 COL-22048 - C2C - Bearb. ATC-Check-Findings
*&
*&---------------------------------------------------------------------*

REPORT  /sie/hr_i_s1df_clear_flag.

FIELD-SYMBOLS <field2modify> TYPE ANY.

DATA wa_s1df TYPE /sie/hr_idp_s1df.
DATA ta_s1df TYPE TABLE OF /sie/hr_idp_s1df.
DATA ta_changes TYPE TABLE OF /sie/hr_idp_s1df.

SELECT-OPTIONS s_ifcid FOR wa_s1df-ifcid.


PARAMETER flagname TYPE /sie/hr_idp_glob_sel.

PARAMETER newvalue AS CHECKBOX.
PARAMETER testmode AS CHECKBOX DEFAULT 'X'.

AT SELECTION-SCREEN.

  EXPORT '/SIE/HR_IDP_S1DF' TO MEMORY ID '/SIE/HR_IDP_PRESEL1'.



START-OF-SELECTION.

***********************************************************
* Berechtigungsprüfung
***********************************************************
  PERFORM check_authority IN PROGRAM /sie/hr_i_download_ici.


  IF flagname IS INITIAL.
    EXIT.
  ENDIF.


  TRANSLATE flagname TO UPPER CASE.

  SELECT * FROM /sie/hr_idp_s1df INTO TABLE ta_s1df
    WHERE ifcid IN s_ifcid
    ORDER BY PRIMARY KEY.

  LOOP AT ta_s1df INTO wa_s1df.

    ASSIGN COMPONENT flagname OF STRUCTURE wa_s1df TO <field2modify>.

    IF newvalue IS NOT INITIAL.
      <field2modify> = 'X'.
    ELSE.
      CLEAR <field2modify>.
    ENDIF.

    APPEND wa_s1df TO ta_changes.

    MODIFY /sie/hr_idp_s1df FROM wa_s1df.

  ENDLOOP.

  IF testmode IS NOT INITIAL.
    ROLLBACK WORK.
  ENDIF.


  PERFORM show_changes_as_alv.


*&---------------------------------------------------------------------*
*&      Form  SHOW_CHANGES_AS_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_changes_as_alv .

* Referenzen
  DATA: lr_cont           TYPE REF TO cl_gui_custom_container.
  DATA: lr_table          TYPE REF TO cl_salv_table.
  DATA: lv_exc_not_found  TYPE REF TO cx_salv_not_found.    "#EC NEEDED
  DATA: lv_exc            TYPE REF TO cx_salv_msg.
  DATA: lr_functions      TYPE REF TO cl_salv_functions_list.
  DATA: lr_salv_columns   TYPE REF TO cl_salv_columns_table.
*  DATA: lt_columns        TYPE salv_t_column_ref,
*        ls_columns        TYPE salv_s_column_ref,
*        ls_column         TYPE REF TO cl_salv_column.
*  DATA: ls_datatype       TYPE datatype_d.
*  DATA: v_colname         TYPE c LENGTH 40.

*** instructions:
*** -------------

  IF lr_cont IS NOT BOUND.
    CREATE OBJECT lr_cont
      EXPORTING
        container_name = 'CONT_NAME'.
  ENDIF.
  TRY.
      CALL METHOD cl_salv_table=>factory
        IMPORTING
          r_salv_table = lr_table
        CHANGING
          t_table      = ta_changes.

    CATCH cx_salv_msg INTO lv_exc.
      MESSAGE lv_exc TYPE 'I'
      DISPLAY LIKE 'E'.
  ENDTRY.
  lr_salv_columns = lr_table->get_columns( ).
  lr_salv_columns->set_optimize( abap_true ).

  lr_table->display( ).

ENDFORM.                    " SHOW_CHANGES_AS_ALV
