FUNCTION /SIE/HR_IDP_CONVERT_P_TO_C.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(IMP_PFELD)
*"             VALUE(IMP_CSIGN) TYPE  CHAR1 DEFAULT SPACE
*"             VALUE(IMP_NOPLS) TYPE  XFELD DEFAULT SPACE
*"             VALUE(IMP_UMSDC) TYPE  XFELD DEFAULT SPACE
*"             VALUE(IMP_ANZDC) TYPE  DECIMALS OPTIONAL
*"             VALUE(IMP_VZLOR) TYPE  XFELD DEFAULT SPACE
*"             VALUE(IMP_TRENN) TYPE  CHAR1 DEFAULT ','
*"       CHANGING
*"             VALUE(CHG_CFELD)
*"             VALUE(CHG_CSIGN) TYPE  CHAR1 OPTIONAL
*"----------------------------------------------------------------------
*" 20141106 ML    Unicode-Umstellung (INC5560081)                  ML001
*"----------------------------------------------------------------------
  Data: Conv_CFeld(100)   type c.
  DATA: CONV_CFELD_INT(100)   TYPE C.
  DATA: CONV_CFELD_DEC(100)   TYPE C.
  DATA: KOMMA_POSITION TYPE I.
  data: conv_csign(001)   type c.
  data: conv_length       type i.
  data: conv_type         type c.
  data: tmp_pfeld(15)     type p.
  data: conv_decimals     type i.
  data: used_decimals     type i.
  data: used_length       type i.
  data: shift_places      type i.
  constants:
        kein_Punkt(2)     type c value '. ',
        Kein_Komma(2)     type c value ', ',
        vornullen(2)      type c value ' 0',
        no_plus(2)        type c value '+ '.
  Constants:
        Plus(1)           type c value '+',
        Minus(1)          type c value '-',
        type_character(1) type c value 'C',
        marked            type c value 'X'.
  data: sign_separat      type c.

  sign_separat = imp_csign.

  describe  field chg_cfeld length conv_length in byte mode "ML001
                            type   conv_type.
  describe  field IMP_pfeld decimals conv_decimals.

* Wenn Typ nicht Charakter, muss Vorzeichen immer separat dargestellt
* werden
  IF CONV_TYPE NE TYPE_CHARACTER.
    sign_separat = marked.
  ENDIF.

  conv_csign   = Plus.
  if imp_pfeld lt 0.
    conv_csign = Minus.
  endif.
  if sign_separat ne space.
    CHG_CSIGN  = CONV_CSIGN.
    IF IMP_NOPLS NE SPACE.
      TRANSLATE CHG_CSIGN USING NO_PLUS.
    ENDIF.
    conv_csign = space.
  endif.
  tmp_pfeld = imp_pfeld * ( 10 ** conv_decimals ).
  if tmp_pfeld lt 0.
    tmp_pfeld = tmp_pfeld * ( -1 ).
  endif.
* Umsetzen Nachkommastellen
  if imp_umsdc ne space.
    if conv_decimals ne imp_anzdc.
      if conv_decimals gt imp_anzdc.
        used_decimals = conv_decimals - imp_anzdc.
        tmp_pfeld = tmp_pfeld / ( 10 ** used_decimals ).
      endif.
      if conv_decimals lt imp_anzdc.
        used_decimals = imp_anzdc - conv_decimals.
        tmp_pfeld = tmp_pfeld * ( 10 ** used_decimals ).
      endif.
    endif.
  endif.

  write   tmp_pfeld to conv_cfeld.
  condense  conv_cfeld no-gaps.
  translate conv_cfeld using Kein_Punkt.
  translate conv_cfeld using Kein_Komma.
  condense  conv_cfeld no-gaps.

  used_length   = strlen( conv_cfeld ).
  if imp_csign eq space.
    used_length = used_length + 1.
  endif.

  IF ( IMP_TRENN NE SPACE ).
    KOMMA_POSITION = USED_LENGTH - IMP_ANZDC - 1.
    IF KOMMA_POSITION > 0.
      CONV_CFELD_DEC = CONV_CFELD+KOMMA_POSITION.
      IF NOT ( CONV_CFELD_DEC IS INITIAL ).
        CONV_CFELD_INT = CONV_CFELD(KOMMA_POSITION).
        CONCATENATE CONV_CFELD_INT IMP_TRENN CONV_CFELD_DEC
              INTO CONV_CFELD.
        SHIFT_PLACES  = CONV_LENGTH - USED_LENGTH - 1.
      ELSE.
        SHIFT_PLACES  = CONV_LENGTH - USED_LENGTH.
      ENDIF.
    ELSE.
      SHIFT_PLACES  = CONV_LENGTH - USED_LENGTH.
    ENDIF.
  ELSE.
    shift_places  = conv_length - used_length.
  ENDIF.

  shift conv_cfeld right by shift_places places.
  IF IMP_VZLOR EQ SPACE.
    concatenate conv_cfeld
                conv_csign
           into conv_cfeld.
  ELSE.
    CONCATENATE CONV_CSIGN
                CONV_CFELD
           INTO CONV_CFELD.
  ENDIF.
  chg_cfeld     = conv_cfeld.

* Vornullen nur bei Charakterfeld notwendig
  if conv_type eq type_character.
    translate     chg_cfeld using vornullen.
    if imp_nopls ne space.
      translate   chg_cfeld using no_plus.
    endif.
  endif.

ENDFUNCTION.
