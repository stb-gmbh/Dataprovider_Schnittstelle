*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_KONFF01 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FILL_MATRIX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITAB_MATRIX  text
*----------------------------------------------------------------------*
FORM FILL_MATRIX CHANGING P_MATRIX TYPE  T_ITAB_MATRIX.

  STATICS: L_ITAB_MATRIX TYPE STANDARD TABLE OF T_MATRIX INITIAL SIZE 0
         .

  DATA: L_WORK_MATRIX TYPE T_MATRIX
      .

  DEFINE M_FILL.
    CLEAR L_WORK_MATRIX.
    L_WORK_MATRIX-ROLE   = &1.
    L_WORK_MATRIX-PERNR  = &2.
    L_WORK_MATRIX-UNAME  = &3.
    L_WORK_MATRIX-ORGEH  = &4.
    L_WORK_MATRIX-EMAIL  = &5.
    APPEND L_WORK_MATRIX TO L_ITAB_MATRIX.
  END-OF-DEFINITION.

  DESCRIBE TABLE L_ITAB_MATRIX.
  IF SY-TFILL = 0.
    M_FILL: '01' 'X' 'X' 'X' 'X'     "Anforderer            "#EC NOTEXT
          , '02' 'X' 'X' 'X' '+'     "Entwickler            "#EC NOTEXT
          , '03' 'X' '+' 'X' 'X'     "tech. Ansprechpartn.  "#EC NOTEXT
          , '04' 'X' 'X' 'X' '+'     "betr. Ansprechpartn.  "#EC NOTEXT
          , '05' 'X' 'X' 'X' '+'     "Abnehmer              "#EC NOTEXT
          , '06' 'X' '+' 'X' 'X'     "Freigabe              "#EC NOTEXT
          , '07' 'X' 'X' 'X' '+'     "
          .
  ENDIF.

  P_MATRIX[] = L_ITAB_MATRIX[].

ENDFORM.                    " FILL_MATRIX
