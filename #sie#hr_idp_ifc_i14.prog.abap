*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_I14 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  TC_PROG_LINE_1004  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_PROG_LINE_1004 INPUT.
  G_ITAB_S1PG-FLDPS = TC_PROG-CURRENT_LINE.
  MODIFY G_ITAB_S1PG INDEX TC_PROG-CURRENT_LINE.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  OK_CODES_1004  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE OK_CODES_1004 INPUT.
  PERFORM OK_CODES_1004.
ENDMODULE.                 " OK_CODES_1004  INPUT
*&---------------------------------------------------------------------*
*&      Module  SATZART_CHANGED_1004  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SATZART_CHANGED_1004 INPUT.
  IF G_ITAB_SATZART NE G_SATZART_OLD.
    G_1004_SATZART_CHANGED = 'X'.
    MOVE G_ITAB_SATZART TO G_SATZART_OLD.
  ENDIF.
ENDMODULE.                 " SATZART_CHANGED_1004  INPUT
*&---------------------------------------------------------------------*
*&      Module  I_1004_IDENT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE I_1004_IDENT INPUT.
  PERFORM READ_F1T USING G_ITAB_S1PG-FELDNAME
                   CHANGING G_ITAB_S1PG-IDENT.
  MODIFY G_ITAB_S1PG INDEX TC_PROG-CURRENT_LINE.

ENDMODULE.                 " I_1004_IDENT  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_FELD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_FELD INPUT.
  CHECK G_ITAB_S1PG-KONVNAM >< 'SATZART'.
  CHECK G_ITAB_S1PG-FELDNAME >< SPACE.
  SELECT SINGLE * FROM /SIE/HR_IDP_F1
           WHERE FELDNAME = G_ITAB_S1PG-FELDNAME.
  IF SY-SUBRC = 0.
  ELSE.
    MESSAGE E117 WITH G_ITAB_S1PG-FELDNAME.
  ENDIF.

ENDMODULE.                 " CHECK_FELD  INPUT

*&---------------------------------------------------------------------*
*&      Module  SWITCH_MONTHS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SWITCH_MONTHS OUTPUT.

  IF NOT ( G_ITAB_S1PG-FELDNAME IS INITIAL ).
    SELECT SINGLE * FROM  /SIE/HR_IDP_F1
           WHERE  FELDNAME  = G_ITAB_S1PG-FELDNAME.

    IF /SIE/HR_IDP_F1-DPFTYPE >< 4.
      LOOP AT SCREEN.
        CHECK SCREEN-NAME = 'g_itab_s1pg-MTHBK'.
        SCREEN-INPUT = '0'.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDMODULE.                 " SWITCH_MONTHS  INPUT

*&---------------------------------------------------------------------*
*&      Form  OK_CODES_1004
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
DATA: G_ITAB_S1PG_HELP LIKE G_ITAB_S1PG OCCURS 0 WITH HEADER LINE.
DATA: G_ITAB_S1PG_BUFFER LIKE G_ITAB_S1PG.

*---------------------------------------------------------------------*
*       FORM OK_CODES_1004                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM OK_CODES_1004.

  DATA: FL TYPE TY_YESNO
      , IDX TYPE I
      .

  FL = NO.

  CASE SVCODE.
    WHEN 'L_NEW'.
      REFRESH G_ITAB_S1PG_HELP.
      LOOP AT G_ITAB_S1PG.
        IF NOT G_ITAB_S1PG-MARK IS INITIAL.
          APPEND INITIAL LINE TO G_ITAB_S1PG_HELP.
          MESSAGE S124.
          FL = YES.
        ENDIF.
        APPEND G_ITAB_S1PG TO G_ITAB_S1PG_HELP.
      ENDLOOP.
      IF FL = NO.
        MESSAGE S134.
      ENDIF.
      G_ITAB_S1PG[] = G_ITAB_S1PG_HELP[].
    WHEN 'L_DEL'.
      LOOP AT G_ITAB_S1PG.
        IF NOT G_ITAB_S1PG-MARK IS INITIAL.
          DELETE G_ITAB_S1PG.
          MESSAGE S125.
          FL = YES.
        ENDIF.
      ENDLOOP.
      IF FL = NO.
        MESSAGE S134.
      ENDIF.
    WHEN 'L_CUT'.
      LOOP AT G_ITAB_S1PG.
        IF NOT G_ITAB_S1PG-MARK IS INITIAL.
          G_ITAB_S1PG_BUFFER = G_ITAB_S1PG.
          CLEAR G_ITAB_S1PG_BUFFER-MARK.
          DELETE G_ITAB_S1PG.
          MESSAGE S126.
          FL = YES.
        ENDIF.
      ENDLOOP.
      IF FL = NO.
        MESSAGE S134.
      ENDIF.
    WHEN 'L_COPY'.
      LOOP AT G_ITAB_S1PG.
        IF NOT G_ITAB_S1PG-MARK IS INITIAL.
          G_ITAB_S1PG_BUFFER = G_ITAB_S1PG.
          CLEAR G_ITAB_S1PG_BUFFER-MARK.
          MESSAGE S127.
          FL = YES.
        ENDIF.
      ENDLOOP.
      IF FL = NO.
        MESSAGE S134.
      ENDIF.
    WHEN 'L_PASTE'.
      IF NOT G_ITAB_S1PG_BUFFER IS INITIAL.
        REFRESH G_ITAB_S1PG_HELP.
        LOOP AT G_ITAB_S1PG.
          IF NOT G_ITAB_S1PG-MARK IS INITIAL.
            APPEND G_ITAB_S1PG_BUFFER TO G_ITAB_S1PG_HELP.
            MESSAGE S128.
            FL = YES.
          ENDIF.
          APPEND G_ITAB_S1PG TO G_ITAB_S1PG_HELP.
        ENDLOOP.
        IF FL = NO.
          MESSAGE S134.
        ENDIF.
        G_ITAB_S1PG[] = G_ITAB_S1PG_HELP[].
      ENDIF.
    WHEN 'L_LNEW'.
      DESCRIBE TABLE G_ITAB_S1PG.
      TC_PROG-TOP_LINE = TC_PROG-LINES - 1.
      REFRESH CONTROL 'TC_PROG' FROM SCREEN '1004'.
      IDX = STEP_LINES - 1.
      DO IDX TIMES.
        APPEND  INITIAL LINE TO G_ITAB_S1PG.
      ENDDO.
      MESSAGE S129.
    WHEN 'L_DELETE'.
      LOOP AT G_ITAB_S1PG.
        IF NOT G_ITAB_S1PG-MARK IS INITIAL.
          DELETE G_ITAB_S1PG.
          MESSAGE S130.
          FL = YES.
        ENDIF.
      ENDLOOP.
      IF FL = NO.
        MESSAGE S134.
      ENDIF.
    WHEN 'NEW_RECNAM'.
* wird später verarbeitet
    WHEN 'RECNA_CHANGED'.

  ENDCASE.

  DELETE G_IFDATA_TRAN-S1PG WHERE RECNA = G_SATZART_OLD
                              AND VRSNR = G_IFDATA_VERS.
  CLEAR I.
  LOOP AT G_ITAB_S1PG.
    CHECK NOT G_ITAB_S1PG-FELDNAME IS INITIAL.
    ADD 1 TO I.
*    /SIE/HR_IDP_S1PG = G_ITAB_S1PG+1.
    move-corresponding G_itab_s1pg to /SIE/HR_IDP_S1PG.   "SIE003
    /SIE/HR_IDP_S1PG-RECNA = G_SATZART_OLD.
    /SIE/HR_IDP_S1PG-IFCID = G_IFDATA_TRAN-S1-IFCID.
    /SIE/HR_IDP_S1PG-VRSNR = G_IFDATA_VERS.
    /SIE/HR_IDP_S1PG-FLDPS = I.
    APPEND /SIE/HR_IDP_S1PG TO G_IFDATA_TRAN-S1PG.
  ENDLOOP.
  SORT G_IFDATA_TRAN-S1PG BY IFCID VRSNR RECNA FLDPS.
  DELETE ADJACENT DUPLICATES FROM G_IFDATA_TRAN-S1PG
         COMPARING IFCID VRSNR RECNA FLDPS.

  CASE SVCODE.
    WHEN 'SAVE'. " OR 'RTRN' OR 'END' OR 'BREA'. kommt hier nicht an
      CLEAR G_ITAB_S1PG. REFRESH G_ITAB_S1PG.
      CLEAR G_1004_LOADED.
    WHEN 'DEL_RECNAM'.
      DELETE G_IFDATA_TRAN-S1PG WHERE VRSNR = G_IFDATA_VERS
                                  AND IFCID = G_IFDATA_TRAN-S1-IFCID
                                  AND RECNA = G_ITAB_SATZART.
      CLEAR G_ITAB_S1PG. REFRESH G_ITAB_S1PG.
      CLEAR G_1004_LOADED.
      MESSAGE S131.
    WHEN 'NEW_RECNAM'.
      CALL SCREEN 0700 STARTING AT 7 7.
      IF NOT G_700_SATZART IS INITIAL.
        G_ITAB_SATZART = G_700_SATZART.
        G_ITAB_SATZART_VALUES-KEY = G_ITAB_SATZART.
        G_ITAB_SATZART_VALUES-TEXT = G_ITAB_SATZART.
        APPEND G_ITAB_SATZART_VALUES.

        /SIE/HR_IDP_S1SA-IFCID = G_IFDATA_TRAN-S1-IFCID.
        /SIE/HR_IDP_S1SA-VRSNR = G_IFDATA_VERS.
        /SIE/HR_IDP_S1SA-RECNA = G_ITAB_SATZART.
        APPEND /SIE/HR_IDP_S1SA TO G_ITAB_SATZART.

        CALL FUNCTION 'VRM_SET_VALUES'
             EXPORTING
                  ID              = 'G_ITAB_SATZART'
                  VALUES          = G_ITAB_SATZART_VALUES[]
             EXCEPTIONS
                  ID_ILLEGAL_NAME = 1
                  OTHERS          = 2.
*      g_itab_satzart = '3'.

*Standardzeilen für Satzart eintragen
        REFRESH G_ITAB_S1PG.
* Aber nur für nicht single format Dateien
* Änderung wieder zurückgenommen da dies erst im generator stattzufinden
* hat..
*        if g_ifdata_tran-s1df-kzsfd is initial.
        G_ITAB_S1PG-RECNA = G_ITAB_SATZART.
        G_ITAB_S1PG-FLDPS = 1.
        G_ITAB_S1PG-FELDNAME = G_ITAB_SATZART.
        G_ITAB_S1PG-KONVNAM  = 'SATZART'.
        APPEND G_ITAB_S1PG.
*        endif.

        G_ITAB_S1PG-RECNA = G_ITAB_SATZART.
        G_ITAB_S1PG-FLDPS = 2.
        G_ITAB_S1PG-FELDNAME = 'P0001_PERNR'.
        G_ITAB_S1PG-KONVNAM  = ''.
        APPEND G_ITAB_S1PG.
        DO 5 TIMES.
          APPEND INITIAL LINE TO G_ITAB_S1PG.
        ENDDO.
        G_1004_DONT_LOAD = 'X'.
        MOVE G_ITAB_SATZART TO G_SATZART_OLD.
        MESSAGE S132 WITH G_700_SATZART.
      ENDIF.
    WHEN 'RECNA_CHANGED'.
      IF G_ITAB_SATZART IS INITIAL.
        MOVE G_SATZART_OLD TO  G_ITAB_SATZART.
      ELSE.
        IF G_ITAB_SATZART NE G_SATZART_OLD.
          G_1004_SATZART_CHANGED = 'X'.
          MOVE G_ITAB_SATZART TO G_SATZART_OLD.
*          message s133 with g_700_satzart.
          MESSAGE S133 WITH G_ITAB_SATZART.
        ENDIF.
      ENDIF.

  ENDCASE.

ENDFORM.                    " OK_CODES_1004
