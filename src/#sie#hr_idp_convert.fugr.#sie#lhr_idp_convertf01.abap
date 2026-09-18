*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_CONVERTF01 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  PARSE_PARAMETERS
*&---------------------------------------------------------------------*
*       Diese Formroutine 'parses' die Parameterliste der
*       Konvertierung und baut Paare von Variablen und Werte
*----------------------------------------------------------------------*
*      -->PT_PARAM        Tabelle der Paare
*      -->P_P_PARAMETERS  Übergabeparameter
*----------------------------------------------------------------------*
FORM PARSE_PARAMETERS USING VALUE(P_PARAM) TYPE /SIE/HR_IDP_KONVPARA
                      CHANGING PT_PARAM TYPE TY_TPAIR.

  DATA: T_PARAM TYPE STANDARD TABLE OF TY_PARAM INITIAL SIZE 0
      , WA_PARAM TYPE TY_PARAM
      , WA_PAIR TYPE TY_PAIR
      .

  SPLIT P_PARAM AT C_SEMICOLON INTO TABLE T_PARAM.

  LOOP AT T_PARAM INTO WA_PARAM.
    SPLIT WA_PARAM AT '=' INTO WA_PAIR-VARIABLE WA_PAIR-VALUE.
    TRANSLATE WA_PAIR-VARIABLE TO UPPER CASE.
    TRANSLATE WA_PAIR-VALUE TO UPPER CASE.
    APPEND WA_PAIR TO PT_PARAM.
  ENDLOOP.

ENDFORM.                    " PARSE_PARAMETERS

*&---------------------------------------------------------------------*
*&      Form  PARSE_VALUES
*&---------------------------------------------------------------------*
*       Diese Routine liest die Werte der Parameter aus der Tabelle
*----------------------------------------------------------------------*
*      -->PT_PARAM  Parametertabelle
*      -->P_KEY     Parametername
*      <--VAL       Wert des Parameters
*----------------------------------------------------------------------*
FORM PARSE_VALUES USING VALUE(PT_PARAM) TYPE TY_TPAIR
                        VALUE(P_KEY) TYPE TY_PARAM
                  CHANGING WA_VAL TYPE TY_PARAM.

  DATA: WA_PAIR TYPE TY_PAIR.

  CLEAR WA_VAL.

  TRANSLATE P_KEY TO UPPER CASE.
  READ TABLE PT_PARAM WITH KEY VARIABLE = P_KEY
                     INTO WA_PAIR.
  IF SY-SUBRC = 0.
    WA_VAL = WA_PAIR-VALUE.
    TRANSLATE WA_VAL TO UPPER CASE.
  ELSE.
    CLEAR WA_VAL.
  ENDIF.

ENDFORM.                    " PARSE_VALUES

*&---------------------------------------------------------------------*
*&      Form  READ_T538A
*&---------------------------------------------------------------------*
*      -->P_P_IN(3)  Einheitencode
*      <--P_UNIT     Einheitentext
*----------------------------------------------------------------------*
FORM READ_T538T USING P_IN TYPE C
                CHANGING P_UNIT TYPE EINHTXT.

  DATA: WA_538T TYPE T538T.

  DESCRIBE TABLE G_538T.
  IF SY-TFILL = 0.
    SELECT * FROM T538T INTO TABLE G_538T
                        WHERE SPRSL = SY-LANGU.
  ENDIF.

  READ TABLE G_538T INTO WA_538T
                    WITH KEY ZEINH = P_IN.
  IF SY-SUBRC = 0.
    P_UNIT = WA_538T-ETEXT.
  ELSE.
    CLEAR P_UNIT.
  ENDIF.

ENDFORM.                    " READ_T538A
