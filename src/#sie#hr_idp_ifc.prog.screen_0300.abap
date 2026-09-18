*******************************************************************
*PBO
*******************************************************************
PROCESS BEFORE OUTPUT.
  MODULE fill_vardata.
  LOOP AT g_vardata INTO /sie/hr_idp_vardata
                    WITH CONTROL tc_var CURSOR tc_var-current_line.

    MODULE modify_tc.
    MODULE modify_screen.
    MODULE lines.
  ENDLOOP.
  MODULE read_1002.                                         "SIE004
  MODULE modify_screen.

*******************************************************************
*PAI
*******************************************************************
PROCESS AFTER INPUT.
  MODULE init.
* SIE004_BEG
  CHAIN.
*    FIELD /sie/hr_idp_s1df-gsel_mini6.        "ah003 COL-27098
    FIELD /sie/hr_idp_s1df-gsel_mini5.                      "ah002
    FIELD /sie/hr_idp_s1df-nogsel.
    FIELD /sie/hr_idp_s1df-gsel_mini1.                      "SIE007
    FIELD /sie/hr_idp_s1df-gsel_mini2.                      "SIE007
    FIELD /sie/hr_idp_s1df-gsel_mini4.                      "ah001

    FIELD /sie/hr_idp_s1df-psel_report.                     "SIE009
    FIELD /sie/hr_idp_s1df-psel_variant.                    "SIE009
    MODULE write_1002 ON CHAIN-REQUEST.

  ENDCHAIN.
* SIE004_END

*  module get_cursor.
  MODULE modify_selection.
  LOOP AT g_vardata.
    CHAIN.
      FIELD: /sie/hr_idp_vardata-feldname,
             /sie/hr_idp_vardata-ident,
             /sie/hr_idp_vardata-icon.
      MODULE modify_feldname ON CHAIN-REQUEST.
    ENDCHAIN.
    CHAIN.
      FIELD: /sie/hr_idp_vardata-mark,
             /sie/hr_idp_vardata-feldname.
      MODULE set_content ON CHAIN-REQUEST.
    ENDCHAIN.
  ENDLOOP.

*******************************************************************
*POVR
*******************************************************************
PROCESS ON VALUE-REQUEST.

  FIELD /sie/hr_idp_s1df-psel_report  MODULE f4_report.     "SIE009
  FIELD /sie/hr_idp_s1df-psel_variant MODULE f4_variant.    "SIE009
