*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_TAGS                                           *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  GET_TAG
*&---------------------------------------------------------------------*
FORM GET_TAG TABLES   P_FILE TYPE T_XML_FILE
                      P_XML TYPE T_XML_FILE
              USING    P_TAGNAME.

  DATA:
    L TYPE S_XML_FILE,
    START_MARK TYPE S_XML_FILE,
    END_MARK TYPE S_XML_FILE,
    FOUND.

* concatenate '<' p_tagname '>' into start_mark.
  CONCATENATE '<' P_TAGNAME INTO START_MARK.
  CONCATENATE '</' P_TAGNAME '>' INTO END_MARK.
  LOOP AT P_FILE INTO L.
    IF L CS START_MARK.
      FOUND = 'X'.
    ELSEIF L CS END_MARK.
      EXIT.
    ELSEIF NOT FOUND IS INITIAL.
      TRANSLATE L TO UPPER CASE.
      APPEND L TO P_XML.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " GET_TAG


*---------------------------------------------------------------------*
*       FORM GET_TAG_ATTRIBUTES                                       *
*---------------------------------------------------------------------*
FORM GET_TAG_ATTRIBUTES USING    P_TAGNAME
                                 P_FILE TYPE S_XML_FILE
  CHANGING P_ATTRIBUTES TYPE /SIE/HR_IDP_TT_ATTRIBUTES.

  DATA:
    L TYPE S_XML_FILE,
    START_MARK TYPE S_XML_FILE,
    END_MARK TYPE S_XML_FILE,
    FOUND(1) TYPE C VALUE NO,
    LS_ATTRIBUTES TYPE /SIE/HR_IDP_PAIRS,
    LS_ATTRIBUTE TYPE /SIE/HR_IDP_PAIR,
    L_VALUE TYPE S_XML_FILE,
    R_VALUE TYPE S_XML_FILE,
    RVALUE_H TYPE S_XML_FILE,
    LENGTH TYPE I,
    FL TYPE C,
    IDX TYPE I
    .

  DATA: BEGIN OF T_HELP OCCURS 0
      ,  LINE(1000)
      , END OF T_HELP.

  CONCATENATE '<' P_TAGNAME INTO START_MARK.
  END_MARK = '>'.
  L = P_FILE.
  IF L CS START_MARK.
    FOUND = YES.
    LS_ATTRIBUTES-NODE_NAME = P_TAGNAME.
  ENDIF.

  IF FOUND = YES.

    FIELD-SYMBOLS: <C>.
    FL = SPACE.
    CLEAR IDX.
    IDX = STRLEN( L ).
    DO.
      IDX = IDX - 1.
      IF IDX = 0. EXIT. ENDIF.
      ASSIGN L+IDX(1) TO <C>.
      IF <C> = TEXT-SK0.
        IF FL = SPACE.
          FL = 'X'.
        ELSE.
          CLEAR FL.
        ENDIF.
      ELSE.
        IF <C> = SPACE.
          IF FL = 'X'. <C> = '~'. ELSE. ENDIF.
        ENDIF.
      ENDIF.
    ENDDO.

    SPLIT L AT SPACE INTO TABLE T_HELP.

    LOOP AT T_HELP.
      PERFORM TRANSLATE_ESCAPE CHANGING T_HELP.
      REPLACE TEXT-HSK WITH TEXT-003 INTO T_HELP.

      SPLIT T_HELP AT '=' INTO L_VALUE R_VALUE.
      IF R_VALUE(2) = TEXT-004.
        CLEAR R_VALUE.
      ENDIF.

      LENGTH = 0.
      RVALUE_H = R_VALUE+1.
      IF RVALUE_H CS TEXT-003.
        DO.
          IF RVALUE_H(1) = TEXT-003.
            EXIT.
          ENDIF.
          SHIFT RVALUE_H.
          LENGTH = LENGTH + 1.
        ENDDO.
      ELSE.
        LENGTH = 0.
      ENDIF.
      IF LENGTH > 0.
        R_VALUE = R_VALUE+1(LENGTH).
      ENDIF.
      LS_ATTRIBUTE-ATTRIBUTENAME = L_VALUE.
      LS_ATTRIBUTE-VALUE = R_VALUE.
      APPEND LS_ATTRIBUTE TO LS_ATTRIBUTES-ATTRIBUTES.
    ENDLOOP.
* Ersten und letzten Eintrag löschen
    DELETE LS_ATTRIBUTES-ATTRIBUTES INDEX 1.
    DESCRIBE TABLE LS_ATTRIBUTES-ATTRIBUTES.
    DELETE LS_ATTRIBUTES-ATTRIBUTES INDEX SY-TFILL.

    APPEND LS_ATTRIBUTES TO P_ATTRIBUTES.
  ENDIF.

ENDFORM.






*---------------------------------------------------------------------*
*       FORM GET_TAG_ORG                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_FILE                                                        *
*  -->  P_XML                                                         *
*  -->  P_TAGNAME                                                     *
*---------------------------------------------------------------------*
FORM GET_TAG_ORG TABLES   P_FILE TYPE T_XML_FILE
                      P_XML TYPE T_XML_FILE
              USING    P_TAGNAME.

  DATA:
    L TYPE S_XML_FILE,
    START_MARK TYPE S_XML_FILE,
    END_MARK TYPE S_XML_FILE,
    FOUND.

* concatenate '<' p_tagname '>' into start_mark.
  CONCATENATE '<' P_TAGNAME INTO START_MARK.
  CONCATENATE '</' P_TAGNAME '>' INTO END_MARK.
  LOOP AT P_FILE INTO L.
    IF L CS START_MARK.
      FOUND = 'X'.
    ELSEIF L CS END_MARK.
      EXIT.
    ELSEIF NOT FOUND IS INITIAL.
      APPEND L TO P_XML.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " GET_TAG

*---------------------------------------------------------------------*
*       FORM TRANSLATE_ESCAPE                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  L                                                             *
*---------------------------------------------------------------------*
FORM TRANSLATE_ESCAPE CHANGING L.

  TRANSLATE L USING '~ '.

  do.
    IF L CS '&amp;'.
      REPLACE '&amp;' WITH '&' INTO L.
    else.
      exit.
    endif.
  enddo.

  do.
    IF L CS '&#xA0;'.
      REPLACE '&#xA0;' WITH SPACE INTO L.
    else.
      exit.
    endif.
  enddo.

ENDFORM.                    " TRANSLATE_ESCAPE
