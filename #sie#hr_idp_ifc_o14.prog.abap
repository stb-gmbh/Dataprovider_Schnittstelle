*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_P14 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  FILL_ITAB_S1PROG  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FILL_ITAB_S1PROG OUTPUT.
*  break mch0341.

  IF  ( G_1004_LOADED IS INITIAL OR
      NOT G_1004_SATZART_CHANGED IS INITIAL ) AND
      G_1004_DONT_LOAD IS INITIAL.
    SORT G_IFDATA_TRAN-S1PG BY RECNA FLDPS.
    IF G_1004_LOADED IS INITIAL.
      CLEAR G_ITAB_SATZART_VALUES. REFRESH G_ITAB_SATZART_VALUES.
      CLEAR G_ITAB_SATZART. REFRESH G_ITAB_SATZART.

    ENDIF.
    LOOP AT G_IFDATA_TRAN-S1PG INTO /SIE/HR_IDP_S1PG
                               WHERE VRSNR = G_IFDATA_VERS.
      APPEND /SIE/HR_IDP_S1PG-RECNA TO G_ITAB_SATZART.
      G_ITAB_SATZART_VALUES-KEY = /SIE/HR_IDP_S1PG-RECNA.
      G_ITAB_SATZART_VALUES-TEXT = /SIE/HR_IDP_S1PG-RECNA.
      APPEND G_ITAB_SATZART_VALUES.
    ENDLOOP.
    SORT G_ITAB_SATZART_VALUES.
    DELETE ADJACENT DUPLICATES FROM G_ITAB_SATZART_VALUES.
    SORT G_ITAB_SATZART.
    DELETE ADJACENT DUPLICATES FROM G_ITAB_SATZART.
    IF G_1004_SATZART_CHANGED IS INITIAL.
      READ TABLE G_ITAB_SATZART INDEX 1.
      G_SATZART_OLD = G_ITAB_SATZART.
    ENDIF.

    CLEAR G_1004_SATZART_CHANGED.
    CALL FUNCTION 'VRM_SET_VALUES'
         EXPORTING
              ID              = 'G_ITAB_SATZART'
              VALUES          = G_ITAB_SATZART_VALUES[]
         EXCEPTIONS
              ID_ILLEGAL_NAME = 1
              OTHERS          = 2.

    REFRESH G_ITAB_S1PG.
    LOOP AT G_IFDATA_TRAN-S1PG INTO /SIE/HR_IDP_S1PG
                               WHERE VRSNR = G_IFDATA_VERS.
      IF /SIE/HR_IDP_S1PG-RECNA = G_ITAB_SATZART.
*       G_ITAB_S1PG+1 = /SIE/HR_IDP_S1PG.
        move-corresponding /SIE/HR_IDP_S1PG to G_ITAB_S1PG.  "SIE003
        PERFORM READ_F1T USING G_ITAB_S1PG-FELDNAME
                         CHANGING G_ITAB_S1PG-IDENT.
        APPEND G_ITAB_S1PG.
      ENDIF.
    ENDLOOP.
    G_1004_LOADED = 'X'.
  ENDIF. "load satzart.
  CLEAR G_1004_DONT_LOAD.
  DESCRIBE TABLE G_ITAB_S1PG LINES TAB_LINES.
  IF TAB_LINES = 0.
    APPEND INITIAL LINE TO G_ITAB_S1PG.
    TAB_LINES = 1.
  ENDIF.
  TC_PROG-LINES = TAB_LINES.

ENDMODULE.                 " FILL_ITAB_S1PROG  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_TC_PROG  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_TC_PROG OUTPUT.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 EQ '001'.
      IF SY-TCODE EQ C_DISP_TCOD.
        SCREEN-INPUT = '0'.
      ELSE.
        SCREEN-INPUT = '1'.
      ENDIF.

    ENDIF.
    IF SCREEN-NAME CP 'G_ITAB_S1PG*'.
      IF G_ITAB_S1PG-FLDPS EQ '001' OR
         G_ITAB_S1PG-FLDPS EQ '002' OR
         TC_PROG-LINES < 3.
        SCREEN-INPUT = '0'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.


ENDMODULE.                 " MODIFY_TC_PROG  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  READ_F1T
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_ITAB_S1PG_FIELDS_IFCID  text
*      <--P_G_ITAB_S1PG_IDENT  text
*----------------------------------------------------------------------*
FORM READ_F1T USING    FNAME TYPE /SIE/HR_IDP_FNAME
              CHANGING IDENT TYPE /SIE/HR_IDP_NUTZBEZ.


  CLEAR IDENT.
  SELECT SINGLE IDENT FROM /SIE/HR_IDP_F1T
                      INTO IDENT
                      WHERE FELDNAME = FNAME
                        AND SPRAS = SY-LANGU.
  IF SY-SUBRC NE 0.
* Es könnte sich noch um eine Satzart handeln!
    READ TABLE G_ITAB_SATZART WITH KEY = FNAME.
    IF SY-SUBRC = 0.
      IDENT = 'Systemfeld Satzart'.
      ELSE.
      CLEAR IDENT.
    ENDIF.
  ELSE.
* do nothing.
  ENDIF.

ENDFORM.                                                    " READ_F1T
*&---------------------------------------------------------------------*
*&      Module  HIDE_TC_PROG  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HIDE_TC_PROG OUTPUT.
  DATA N TYPE I.
  DESCRIBE TABLE G_ITAB_S1PG LINES N.
  LOOP AT SCREEN.
    IF SCREEN-NAME = 'FRAME_TC_PROG'.
      IF N = 0.
        SCREEN-INVISIBLE = 1.
      ELSE.
        SCREEN-INVISIBLE = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " HIDE_TC_PROG  OUTPUT
