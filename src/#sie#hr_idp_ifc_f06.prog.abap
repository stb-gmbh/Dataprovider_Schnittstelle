*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_F06 .
*----------------------------------------------------------------------*

DEFINE SHOW_HIDE_MX.

  CALL FUNCTION '/SIE/HR_IDP_KONF_MATRIX'
       EXPORTING
            ROLE          = &1
            FIELD         = &2
       IMPORTING
            OPTION        = OPTION
       EXCEPTIONS
            NO_SUCH_ROLE  = 1
            NO_SUCH_FIELD = 2
            OTHERS        = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  CASE OPTION.
    WHEN '+'.
      SCREEN-REQUIRED = '1'.
      SCREEN-OUTPUT = '1'.
      SCREEN-INPUT = '1'.
      MODIFY SCREEN.
    WHEN '-'.
      SCREEN-REQUIRED = SPACE.
      SCREEN-INPUT = SPACE.
      SCREEN-OUTPUT = '1'.
      MODIFY SCREEN.
    WHEN 'X'.
      SCREEN-REQUIRED = SPACE.
      SCREEN-INPUT = '1'.
      SCREEN-OUTPUT = '1'.
      MODIFY SCREEN.
  ENDCASE.


END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Form  SHOW_HIDE_MATRIX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SHOW_HIDE_MATRIX.

  DATA: OPTION(1) TYPE C.

  LOOP AT SCREEN.
    CHECK NOT ( SCREEN-GROUP4 IS INITIAL ).
    CASE SCREEN-GROUP4.
      WHEN '001'.  "Sclüsselfeld
        SCREEN-INPUT = SPACE.
        SCREEN-OUTPUT = '1'.
        MODIFY SCREEN.
      WHEN '002'.  "Feld P
        SHOW_HIDE_MX /SIE/HR_IDP_IFC_ROLES-TROLE 'P'.
      WHEN '003'.  "Feld U
        SHOW_HIDE_MX /SIE/HR_IDP_IFC_ROLES-TROLE 'U'.
      WHEN '004'.  "Feld O
        SHOW_HIDE_MX /SIE/HR_IDP_IFC_ROLES-TROLE 'O'.
      WHEN '005'.  "Feld E
        SHOW_HIDE_MX /SIE/HR_IDP_IFC_ROLES-TROLE 'E'.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " SHOW_HIDE_MATRIX

*&---------------------------------------------------------------------*
*&      Form  GET_DOMA_TEXT
*&---------------------------------------------------------------------*
*       Liest die Domänentexte aus derm DDIC für rollen
*----------------------------------------------------------------------*
*  -->  ROLE      Rolle
*  <--  TEXT      Beschreibung zur Rolle
*----------------------------------------------------------------------*
FORM GET_DOMA_TEXT USING ROLE LIKE /SIE/HR_IDP_IFC_ROLES-TROLE
                   CHANGING TEXT LIKE /SIE/HR_IDP_IFC_ROLES-TEXT.

  DATA: L_ROLE TYPE DD07V-DOMVALUE_L
      , L_TEXT TYPE DD07V-DDTEXT
      .

  L_ROLE = ROLE.

  CALL FUNCTION 'DOMAIN_VALUE_GET'
       EXPORTING
            I_DOMNAME  = '/SIE/HR_IDP_TRANS_ROLE'
            I_DOMVALUE = L_ROLE
       IMPORTING
            E_DDTEXT   = L_TEXT
       EXCEPTIONS
            NOT_EXIST  = 1
            OTHERS     = 2.
  IF SY-SUBRC <> 0.
    CLEAR TEXT.
  ELSE.
    TEXT = L_TEXT.
  ENDIF.

ENDFORM.                    " GET_DOMA_TEXT

*&---------------------------------------------------------------------*
*&      Form  GET_ENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_/SIE/HR_IDP_IFC_ROLES_PERNR  text
*      <--P_/SIE/HR_IDP_IFC_ROLES_ENAME  text
*----------------------------------------------------------------------*
FORM GET_ENAME USING    P_PERNR
               CHANGING P_ENAME.

  DATA: PERSONNEL_NUMBER TYPE  PRELP-PERNR
      , RC TYPE SYSUBRC
      , EDIT_NAME(80)
      .
  DATA: BEGIN OF ITAB_0001 OCCURS 0.
          INCLUDE STRUCTURE P0001.
  DATA: END OF ITAB_0001 VALID BETWEEN BEGDA AND ENDDA.
  DATA: BEGIN OF ITAB_0002 OCCURS 0.
          INCLUDE STRUCTURE P0002.
  DATA: END OF ITAB_0002 VALID BETWEEN BEGDA AND ENDDA.

  RP-LOW-HIGH.

  RP-SET-NAME-FORMAT.
  PERSONNEL_NUMBER = P_PERNR.

  CALL FUNCTION 'HR_READ_INFOTYPE'
       EXPORTING
            PERNR           = PERSONNEL_NUMBER
            INFTY           = '0001'
       IMPORTING
            SUBRC           = RC
       TABLES
            INFTY_TAB       = ITAB_0001
       EXCEPTIONS
            INFTY_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
    CLEAR EDIT_NAME.
  ELSE.
    RP_PROVIDE_FROM_LAST ITAB_0001 SPACE LOW_DATE HIGH_DATE.

    SELECT SINGLE * FROM T001P
       WHERE WERKS EQ ITAB_0001-WERKS AND
             BTRTL EQ ITAB_0001-BTRTL.

    CALL FUNCTION 'HR_READ_INFOTYPE'
         EXPORTING
              PERNR           = PERSONNEL_NUMBER
              INFTY           = '0002'
         IMPORTING
              SUBRC           = RC
         TABLES
              INFTY_TAB       = ITAB_0002
         EXCEPTIONS
              INFTY_NOT_FOUND = 1
              OTHERS          = 2.
    IF RC = 0.
      CALL FUNCTION 'RP_EDIT_NAME'
           EXPORTING
                PP0002    = ITAB_0002
                FORMAT    = $$FORMAT
                LANGU     = SY-LANGU
                MOLGA     = T001P-MOLGA
           IMPORTING
                EDIT_NAME = EDIT_NAME.
    ELSE.
      CLEAR EDIT_NAME.
    ENDIF.
  ENDIF.
  P_ENAME = EDIT_NAME.
ENDFORM.                    " GET_ENAME

*&---------------------------------------------------------------------*
*&      Form  GET_XUNAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_/SIE/HR_IDP_IFC_ROLES_UNAME  text
*      <--P_/SIE/HR_IDP_IFC_ROLES_XUNAME  text
*----------------------------------------------------------------------*
FORM GET_XUNAME USING    P_UNAME
                CHANGING P_XUNAME.

  DATA: USER_NAME LIKE  USR01-BNAME
      , USR03 LIKE USR03.

  USER_NAME = P_UNAME.

  CALL FUNCTION 'SUSR_USER_ADDRESS_READ'
       EXPORTING
            USER_NAME              = P_UNAME
       IMPORTING
            USER_USR03             = USR03
       EXCEPTIONS
            USER_ADDRESS_NOT_FOUND = 1
            OTHERS                 = 2.
  IF SY-SUBRC <> 0.
    CLEAR P_XUNAME.
  ELSE.
    CONCATENATE USR03-NAME1 USR03-NAME2 INTO P_XUNAME
                SEPARATED BY SPACE.
  ENDIF.

ENDFORM.                    " GET_XUNAME
*&---------------------------------------------------------------------*
*&      Form  GET_ORGTX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_/SIE/HR_IDP_IFC_ROLES_ORGEH  text
*      <--P_/SIE/HR_IDP_IFC_ROLES_ORGTX  text
*----------------------------------------------------------------------*
FORM GET_ORGTX USING    P_ORGEH
               CHANGING P_ORGTX.

  DATA: STEXT LIKE P1000-STEXT
      , HR_SUBRC LIKE STRUC-SUBRC
      , REPID LIKE SY-REPID
      , OBJID LIKE PLOG-OBJID
      .

  REPID = SY-REPID.
  OBJID = P_ORGEH.

  CALL FUNCTION 'RH_READ_OBJECT'
       EXPORTING
            PLVAR     = '01'
            OTYPE     = 'O'
            OBJID     = OBJID
       IMPORTING
            STEXT     = STEXT
       EXCEPTIONS
            NOT_FOUND = 1
            OTHERS    = 2.
  IF SY-SUBRC <> 0.
    CLEAR P_ORGTX.
  ELSE.
    P_ORGTX = STEXT.
  ENDIF.

ENDFORM.                    " GET_ORGTX
