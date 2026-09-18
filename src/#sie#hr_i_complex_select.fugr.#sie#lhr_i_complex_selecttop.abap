FUNCTION-POOL /SIE/HR_I_COMPLEX_SELECT.     "MESSAGE-ID ..

*-----------------------------------------------------------------------
* GLOBAL MACRO DEFINITIONS
* the internal table repcode must exist!
*-----------------------------------------------------------------------

*  -->  STRING0 Text                                                   *
*       SHIFT0  Anfangsposition des Textes                             *
DEFINE RAPPEND-0.
  REPCODE-LINE = &1.
  CONDENSE REPCODE-LINE.
  SHIFT REPCODE-LINE RIGHT BY &2 PLACES.
  APPEND REPCODE.
END-OF-DEFINITION.

*  -->  STRING1 Text                                                   *
*       SHIFT1  Anfangsposition des Textes                             *
*       REP1_$$ Ersetzungstext fuer $$                                 *
DEFINE RAPPEND-1.
  REPCODE-LINE = &1.
  PERFORM REPLACE USING REPCODE-LINE '$$' &3.
  CONDENSE REPCODE-LINE.
  SHIFT REPCODE-LINE RIGHT BY &2 PLACES.
  APPEND REPCODE.
END-OF-DEFINITION.

*  -->  STRING2 Text                                                   *
*       SHIFT2  Anfangsposition des Textes                             *
*       REP2_$$ Ersetzungstext fuer $$                                 *
*       REP2_## Ersetzungstext fuer ##                                 *
DEFINE RAPPEND-2.
  REPCODE-LINE = &1.
  PERFORM REPLACE USING REPCODE-LINE '$$' &3.
  PERFORM REPLACE USING REPCODE-LINE '##' &4.
  CONDENSE REPCODE-LINE.
  SHIFT REPCODE-LINE RIGHT BY &2 PLACES.
  APPEND REPCODE.
END-OF-DEFINITION.

*  -->  STRING3 Text                                                   *
*       SHIFT3  Anfangsposition des Textes                             *
*       REP3_$$ Ersetzungstext fuer $$                                 *
*       REP3_## Ersetzungstext fuer ##                                 *
*       REP3_$# Ersetzungstext fuer ##                                 *
DEFINE RAPPEND-3.
  REPCODE-LINE = &1.
  PERFORM REPLACE USING REPCODE-LINE '$$' &3.
  PERFORM REPLACE USING REPCODE-LINE '##' &4.
  PERFORM REPLACE USING REPCODE-LINE '$#' &5.
  CONDENSE REPCODE-LINE.
  SHIFT REPCODE-LINE RIGHT BY &2 PLACES.
  APPEND REPCODE.
END-OF-DEFINITION.


*-----------------------------------------------------------------------
* GLOBAL TYPE DEFINITIONS
*-----------------------------------------------------------------------

TYPES: T_CODELINE(78) TYPE C,
       BEGIN OF T_CODING,
         LINE TYPE T_CODELINE,
       END OF T_CODING.

*-----------------------------------------------------------------------
* GLOBAL DATA DECLERATIONS
*-----------------------------------------------------------------------

* repcode is needed for the rappend-? macros!
DATA  REPCODE TYPE STANDARD TABLE OF T_CODING WITH HEADER LINE.

*--- table control on dynp500
DATA: BEGIN OF ICONDTAB OCCURS 0.
        INCLUDE STRUCTURE RHCONDTAB.
DATA:   ICON_TEXT(64),
      END OF ICONDTAB,
      CONDLINE LIKE ICONDTAB.

CONTROLS: TC1CONTROL    TYPE TABLEVIEW USING SCREEN 500.
DATA      TC1_LOOPLINES LIKE SY-LOOPC.

* structure for the option icons
DATA: BEGIN OF ICON_TAB OCCURS 0,
        SIGN   LIKE RHCONDTAB-SIGN,
        OPTION LIKE RHCONDTAB-OPTION,
        OPTEXT(4),
        OPDESC(60),
        ICON(64),
      END OF ICON_TAB.


*--- misc. stuff
DATA: OK_CODE      LIKE SY-UCOMM,
      SAVE_OK_CODE LIKE SY-UCOMM,
      HTABNAME     TYPE TABNAME,
      HFIELDNAME   TYPE FIELDNAME,
      HELPTABIX    LIKE SY-TABIX,
      DYNP_FIELD(50),
      DYNP_LINE    LIKE SY-TABIX,
      ACT_CANCELLED(1).
