*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_UC4F02 .
*----------------------------------------------------------------------*
*" 20141106 ML    Unicode-Umstellung (INC5560081)                  ML001
*"----------------------------------------------------------------------

*&---------------------------------------------------------------------*
*&      Form  OUTPUT_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM OUTPUT_FILE USING VALUE(IFCID)
                       VALUE(VERSION)
                       VALUE(ITYPE)
                       VALUE(P_SD_FILE) TYPE TEXT256.

  DATA: DSN(256) TYPE C
      , L LIKE LINE OF CODE
      , LEN TYPE I
      , PARAM2(60) TYPE C
      , AUTH LIKE AUTHB-FILENAME
      .

  DSN = P_SD_FILE.

  OPEN DATASET dsn FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. "ML001
  IF sy-subrc NE 0.
    MESSAGE E804 WITH DSN RAISING FAILED.
  ENDIF.

  LOOP AT CODE INTO L.
    LEN = STRLEN( L ).
    TRANSFER L TO DSN LENGTH LEN.
  ENDLOOP.

  CLOSE DATASET DSN.
ENDFORM.                    " OUTPUT_FILE

*&---------------------------------------------------------------------*
*&      Form  CREATE_PARAMETERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITYPE  text
*      -->P_PROGRAM_NAME  text
*      <--P_PARAM_1  text
*      <--P_PARAM_2  text
*      <--P_PARAM_3  text
*----------------------------------------------------------------------*
*form create_parameters using value(p_itype) type /sie/hr_idp_itype
FORM CREATE_PARAMETERS USING VALUE(P_IFCID)
                                  TYPE /SIE/HR_IDP_INTERFACE_ID
                             VALUE(P_VRSNR) TYPE /SIE/HR_IDP_VERS_NR
                             VALUE(P_ITYPE)
                             VALUE(P_PROGRAM_NAME) TYPE REPID
                       CHANGING P_PARAM_1
                                P_PARAM_2
                                P_PARAM_3.
  IF P_IFCID IS INITIAL.
    P_PARAM_1 = P_ITYPE.
  ELSE.
    CONCATENATE P_IFCID '-' P_VRSNR '-' INTO P_PARAM_1.
  ENDIF.

  CONCATENATE SY-DATUM(4)
              '-'
              SY-DATUM+4(2)
              '-'
              SY-DATUM+6(2)
              '-'
              SY-UZEIT(2)
              '-'
              SY-UZEIT+2(2)
              '-'
              SY-UZEIT+4(2)
              INTO P_PARAM_2.

  P_PARAM_3 = P_PROGRAM_NAME.
  TRANSLATE P_PARAM_3 USING '/_'.

ENDFORM.                    " CREATE_PARAMETERS

*&---------------------------------------------------------------------*
*&      Form  CREATE_FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PARAM_1  text
*      -->P_PARAM_2  text
*      -->P_PARAM_3  text
*      <--P_FILEN_DATA  text
*----------------------------------------------------------------------*
FORM CREATE_FILENAME USING VALUE(P_LOGICAL_NAME) TYPE FILEINTERN
                           VALUE(P_PARAM_1)
                           VALUE(P_PARAM_2)
                           VALUE(P_PARAM_3)
                     CHANGING P_FILEN_DATA.

  CALL FUNCTION 'FILE_GET_NAME'
       EXPORTING
            CLIENT           = SY-MANDT
            LOGICAL_FILENAME = P_LOGICAL_NAME
            PARAMETER_1      = P_PARAM_1
            PARAMETER_2      = P_PARAM_2
            PARAMETER_3      = P_PARAM_3
       IMPORTING
            FILE_NAME        = P_FILEN_DATA
       EXCEPTIONS
            FILE_NOT_FOUND   = 1
            OTHERS           = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
    RAISING FILE_NOT_FOUND.
  ENDIF.

ENDFORM.                    " CREATE_FILENAME
