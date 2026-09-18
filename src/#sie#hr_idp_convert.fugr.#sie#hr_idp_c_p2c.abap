FUNCTION /SIE/HR_IDP_C_P2C.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(OUTPUT_LENGTH) TYPE  I
*"             VALUE(SIGN) TYPE  C
*"             VALUE(DECIMAL_CHARACTER) TYPE  C
*"             VALUE(PACKED_VALUE) TYPE  P
*"       CHANGING
*"             VALUE(UNPACKED_VALUE)
*"       EXCEPTIONS
*"              NOT_A_NUMBER
*"              FIELD_LENGTH_MISMATCH
*"----------------------------------------------------------------------
*" 20141106 ML    Unicode-Umstellung (INC5560081)                  ML001
*"----------------------------------------------------------------------

  DATA: IG TYPE I    " Ganze Zahl
      , IF TYPE I    " Bruchteil
      , IDX TYPE I   " Länge des Feldes P
      .

* Diese Abfrage wurde auf bitten von IF-AF ausgeschaltet. Ein
* falsches Customizing/Erstellung von der Schnittstellenspezifikation
* stellt einen undefinierten Zustand dar, der durch einen Dump,
* einen NULL Wert oder abschneiden der Zahl repräsentiert wird. Hier
* hat man sich für letzteres Entschieden.

* Prüfen ob die länge in Ordnung ist.
*  describe field packed_value length idx.
*  if idx > output_length.
*    raise field_length_mismatch.
*  endif.

  PERFORM SPLIT_PACK USING PACKED_VALUE CHANGING IG IF.
  PERFORM CONCATENATE_NUMBER USING PACKED_VALUE
                                   IG
                                   IF
                                   OUTPUT_LENGTH
                                   SIGN
                                   DECIMAL_CHARACTER
                             CHANGING UNPACKED_VALUE.

ENDFUNCTION.

*---------------------------------------------------------------------*
*       FORM SPLIT_PACK                                               *
*---------------------------------------------------------------------*
*       Bricht die gepackte Zahl in zwei Teile: ein Integer, der      *
*       die Ganze Zahl repräsentiert und ein zweites Integer, der den *
*       Bruchteil repräsentiert.                                      *
*---------------------------------------------------------------------*
*  -->  VALUE(P) Gepackte Zahl                                        *
*  -->  G        Ganze Zahl                                           *
*  -->  F        Bruchteil                                            *
*---------------------------------------------------------------------*
FORM SPLIT_PACK  USING VALUE(P)   TYPE P
                 CHANGING    G    TYPE I
                             F    TYPE I.

  STATICS: EXP TYPE I, DEC TYPE P DECIMALS 14.

* Die Ganze Zahl ermitteln
  G = TRUNC( P ).

* Bruchteil ermitteln
  DEC = FRAC( P ).
  DESCRIBE FIELD P DECIMALS EXP.
  F = DEC * 10 ** EXP.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM F2                                                       *
*---------------------------------------------------------------------*
*       Fügt die Integerzahlen zusammen in ein Character Feld         *
*       mit einbindung sämtlicher Steuerungsmöglichkeiten wie         *
*       Dezimaltrennzeichen und Vorzeichen                            *
*---------------------------------------------------------------------*
*  -->  VALUE(P)                 Gepackte Zahl                         *
*  -->  VALUE(G)                 Ganze Zahl (Integer)                 *
*  -->  VALUE(F)                 Bruchteil (Integer)                  *
*  -->  VALUE(OUTPUT_LENGTH)                                          *
*  -->  VALUE(SIGN)              Steuerung des Vorzeichens            *
*  -->  VALUE(DECIMAL_CHARACTER) Dezimaltrennzeichen                  *
*  -->  C                        Ausgabewert                          *
*---------------------------------------------------------------------*
FORM CONCATENATE_NUMBER USING VALUE(P) TYPE P
                              VALUE(G) TYPE I
                              VALUE(F) TYPE I
                              VALUE(OUTPUT_LENGTH) TYPE I
                              VALUE(SIGN) TYPE C
                              VALUE(DECIMAL_CHARACTER) TYPE C
                         CHANGING C TYPE C.

  STATICS: EXP TYPE I, LEN TYPE I.

  DATA: H TYPE I,
        S TYPE XFELD.

*SIE002_BEG
*  FIELD-SYMBOLS: <FSG>,
*                 <FSF>,
*                 <DEC>,
*                 <SGN>.
  FIELD-SYMBOLS: <FSG> type any,
                 <FSF> type any,
                 <DEC> type any,
                 <SGN> type any.
*SIE002_END

  DESCRIBE FIELD P DECIMALS EXP.
  DESCRIBE FIELD C LENGTH LEN IN CHARACTER MODE. "ML001 Umstellung UNICODE ka20150821

  IF LEN < OUTPUT_LENGTH.
    RAISE FIELD_LENGTH_MISMATCH.
  ENDIF.

  H = OUTPUT_LENGTH - EXP.
  IF EXP = 0.
  ELSE.
    ASSIGN C+H(EXP) TO <FSF>.
  ENDIF.

  CASE DECIMAL_CHARACTER.
    WHEN '.'.
      H = H - 1.
      ASSIGN C+H(1) TO <DEC>.
      <DEC> = '.'.
    WHEN ','.
      H = H - 1.
      ASSIGN C+H(1) TO <DEC>.
      <DEC> = '.'.
    WHEN OTHERS.
  ENDCASE.
  ASSIGN C(H) TO <FSG>.

  IF P < 0.
    P = 0 - P.
    S = '-'.
  ELSE.
    S = '+'.
  ENDIF.

  CASE SIGN.
    WHEN SPACE.
      H = LEN - EXP.
      IF EXP = 0.
      ELSE.
        ASSIGN C+H(EXP) TO <FSF>.
      ENDIF.
      CASE DECIMAL_CHARACTER.
        WHEN '.' OR ','.
          H = H - 1.
          ASSIGN C+H(1) TO <DEC>.
          <DEC> = DECIMAL_CHARACTER.
        WHEN OTHERS.
      ENDCASE.
      ASSIGN C(H) TO <FSG>.

    WHEN 0.
      H = OUTPUT_LENGTH - 1.
      ASSIGN C+H(1) TO <SGN>.
      <SGN> = S.
      H = LEN - EXP - 1.
      IF EXP = 0.
      ELSE.
        ASSIGN C+H(EXP) TO <FSF>.
      ENDIF.
      CASE DECIMAL_CHARACTER.
        WHEN '.' OR ','.
          H = H - 1.
          ASSIGN C+H(1) TO <DEC>.
          <DEC> = DECIMAL_CHARACTER.
        WHEN OTHERS.
      ENDCASE.
      ASSIGN C(H) TO <FSG>.

    WHEN 1.
      H = OUTPUT_LENGTH - 1.
      ASSIGN C+H(1) TO <SGN>.
      IF S = '+'. S = SPACE. ENDIF.
      <SGN> = S.
      H = LEN - EXP - 1.
      IF EXP = 0.
      ELSE.
        ASSIGN C+H(EXP) TO <FSF>.
      ENDIF.
      CASE DECIMAL_CHARACTER.
        WHEN '.' OR ','.
          H = H - 1.
          ASSIGN C+H(1) TO <DEC>.
          <DEC> = DECIMAL_CHARACTER.
        WHEN OTHERS.
      ENDCASE.
      ASSIGN C(H) TO <FSG>.

    WHEN 2.
      ASSIGN C(1) TO <SGN>.
      <SGN> = S.
      H = LEN - EXP.
      IF EXP = 0.
      ELSE.
        ASSIGN C+H(EXP) TO <FSF>.
      ENDIF.
      CASE DECIMAL_CHARACTER.
        WHEN '.' OR ','.
          H = H - 1.
          ASSIGN C+H(1) TO <DEC>.
          <DEC> = DECIMAL_CHARACTER.
        WHEN OTHERS.
      ENDCASE.
      H = H - 1.
      ASSIGN C+1(H) TO <FSG>.

    WHEN 3.
      ASSIGN C(1) TO <SGN>.
      IF S = '+'. S = SPACE. ENDIF.
      <SGN> = S.
      H = LEN - EXP.
      IF EXP = 0.
      ELSE.
        ASSIGN C+H(EXP) TO <FSF>.
      ENDIF.
      CASE DECIMAL_CHARACTER.
        WHEN '.' OR ','.
          H = H - 1.
          ASSIGN C+H(1) TO <DEC>.
          <DEC> = DECIMAL_CHARACTER.
        WHEN OTHERS.
      ENDCASE.
      H = H - 1.
      ASSIGN C+1(H) TO <FSG>.
    WHEN OTHERS.
  ENDCASE.

  IF <FSG> IS ASSIGNED.
    UNPACK G TO <FSG>.
  ENDIF.

  IF <FSF> IS ASSIGNED.
    UNPACK F TO <FSF>.
  ENDIF.

ENDFORM.
