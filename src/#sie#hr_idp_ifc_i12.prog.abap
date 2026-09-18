*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_I12                                        *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  INIT  INPUT
*&---------------------------------------------------------------------*
*       Initialisieren
*----------------------------------------------------------------------*
MODULE init INPUT.
  CLEAR: wa_tran_s1vt
       , cursor_field
       , cursor_line
       , idx
       , content
       .
ENDMODULE.                 " INIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  WRITE_1002  INPUT                          "SIE004
*&---------------------------------------------------------------------*
*       Zusätzliche Felder schreiben
*----------------------------------------------------------------------*
MODULE write_1002 INPUT.

 DATA: h_variant TYPE variant.

 g_ifdata_tran-s1df-nogsel = /sie/hr_idp_s1df-nogsel.

 g_ifdata_tran-s1df-gsel_mini1 = /sie/hr_idp_s1df-gsel_mini1. "SIE007
 g_ifdata_tran-s1df-gsel_mini2 = /sie/hr_idp_s1df-gsel_mini2. "SIE007
 g_ifdata_tran-s1df-gsel_mini4 = /sie/hr_idp_s1df-gsel_mini4. "ah001
 g_ifdata_tran-s1df-gsel_mini5 = /sie/hr_idp_s1df-gsel_mini5. "ah002
* g_ifdata_tran-s1df-gsel_mini6 = /sie/hr_idp_s1df-gsel_mini6. "ah003 "COL-27098"

"SIE009_BEG
 IF NOT /sie/hr_idp_s1df-psel_report  IS INITIAL OR
    NOT /sie/hr_idp_s1df-psel_variant IS INITIAL.
    SELECT SINGLE variant FROM varid
                        INTO h_variant
                       WHERE report  = /sie/hr_idp_s1df-psel_report
                         AND variant = /sie/hr_idp_s1df-psel_variant.

    IF sy-subrc <> 0.
       MESSAGE e016(rp) WITH 'Report/Variante nicht vorhanden!'.
    ENDIF.

 ENDIF.

 g_ifdata_tran-s1df-psel_report  = /sie/hr_idp_s1df-psel_report.
 g_ifdata_tran-s1df-psel_variant = /sie/hr_idp_s1df-psel_variant.

"SIE009_END


ENDMODULE.                 " INIT  INPUT


*&---------------------------------------------------------------------*
*&      Module  F4_REPORT  INPUT                          "SIE009
*&---------------------------------------------------------------------*
*       F4-Hilfe für Report für Vorselektion
*----------------------------------------------------------------------*
MODULE f4_report INPUT.                                   "SIE009

   DATA: h_report LIKE /sie/hr_idp_s1df-psel_report.
   DATA: repid LIKE sy-repid.
   DATA: dynpfields TYPE TABLE OF dynpread WITH HEADER LINE.

   dynpfields-fieldname  = '/SIE/HR_IDP_S1DF-PSEL_REPORT'.
   APPEND dynpfields.

   repid = sy-repid.
   CALL FUNCTION 'DYNP_VALUES_READ'
        EXPORTING
             dyname     = repid
             dynumb     = sy-dynnr
        TABLES
             dynpfields = dynpfields
        EXCEPTIONS
            OTHERS.
   READ TABLE dynpfields INDEX 1.

   /sie/hr_idp_s1df-psel_report = dynpfields-fieldvalue.

   CALL FUNCTION 'F4_REPORT'
     EXPORTING
       object                   = /sie/hr_idp_s1df-psel_report
       suppress_selection       = 'X'
*      DISPLAY_ONLY             =
     IMPORTING
       RESULT                   = /sie/hr_idp_s1df-psel_report
             .


*   CALL FUNCTION 'REPOSITORY_INFO_SYSTEM_F4'
*        EXPORTING
*          object_type          = 'PROG'
*          object_name          = /sie/hr_idp_s1df-psel_report
*          suppress_selection   = 'X'
*        IMPORTING
*          object_name_selected = h_report
*        EXCEPTIONS
*          cancel               = 01.
*
*   IF sy-subrc = 0.
*      /sie/hr_idp_s1df-psel_report = h_report.
*   ENDIF.

ENDMODULE.                 " INIT  INPUT


*&---------------------------------------------------------------------*
*&      Module  F4_VARIANT  INPUT                          "SIE009
*&---------------------------------------------------------------------*
*       F4-Hilfe für Variante Vorselektion
*----------------------------------------------------------------------*
MODULE f4_variant INPUT.                                   "SIE009

   CALL FUNCTION 'F4_REPORT_VARIANT'
     EXPORTING
       object                   = /sie/hr_idp_s1df-psel_variant
       program                  = /sie/hr_idp_s1df-psel_report
*      suppress_selection       = ' '
*      DISPLAY_ONLY             =
     IMPORTING
       RESULT                   = /sie/hr_idp_s1df-psel_variant
*      PROGRAM                  =
             .

ENDMODULE.                 " INIT  INPUT



*&---------------------------------------------------------------------*
*&      Module  MODIFY_FELDNAME  INPUT
*&---------------------------------------------------------------------*
*       Aktualisieren der internen Tabelle g_ifdata_tran-s1vt          *
*----------------------------------------------------------------------*
MODULE modify_feldname INPUT.
  CHECK NOT /sie/hr_idp_vardata-feldname IS INITIAL.
  PERFORM check_selektionsfeld_valid USING /sie/hr_idp_vardata-feldname.
  PERFORM check_duplikate USING /sie/hr_idp_vardata-feldname.
  wa_tran_s1vt-feldname = /sie/hr_idp_vardata-feldname.
  wa_tran_s1vt-mandt = sy-mandt.
  wa_tran_s1vt-ifcid = g_ifdata_tran-s1-ifcid.
  wa_tran_s1vt-vrsnr = g_ifdata_vers.
  APPEND wa_tran_s1vt TO g_ifdata_tran-s1vt.
  MESSAGE s220.
* Table Control wurde aktualisiert.
ENDMODULE.                 " MODIFY_FELDNAME  INPUT

*&---------------------------------------------------------------------*
*&      Module  MODIFY_SELECTION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_selection INPUT.
  CHECK svcode EQ c_selm_code.
  PERFORM get_dialog.
ENDMODULE.                 " MODIFY_SELECTION  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_CURSOR  INPUT
*&---------------------------------------------------------------------*
MODULE get_cursor INPUT.
  GET CURSOR FIELD cursor_field LINE cursor_line VALUE content.
ENDMODULE.                 " GET_CURSOR  INPUT

*---------------------------------------------------------------------*
*       MODULE SET_CONTENT INPUT                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE set_content INPUT.

  IF /sie/hr_idp_vardata-mark = yes.
    content = /sie/hr_idp_vardata-feldname.
  ENDIF.

ENDMODULE.
