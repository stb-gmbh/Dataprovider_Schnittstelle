*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_F20 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  IFCID_CHECK
*&---------------------------------------------------------------------*
FORM IFCID_CHECK.

DATA: DUMMY_DBSEL LIKE /SIE/HR_IDP_DB_SEL.

  CALL FUNCTION '/SIE/HR_IDP_TEST_GENERATOR'
       EXPORTING
*            ifcid           = /sie/hr_idp_s1-ifcid
             IFCID           = G_IFDATA_TRAN-S1-IFCID
       IMPORTING
            DBSEL           = DUMMY_DBSEL
       EXCEPTIONS
            ENQUEUE         = 1
            WAS_RELEASED    = 2
            DB_INCONSISTENT = 3
            PROGRAM_EXISTS  = 4
            OTHERS          = 5.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " IFCID_CHECK

*&---------------------------------------------------------------------*
*&      Form  IFCID_RELEASE
*&---------------------------------------------------------------------*
FORM IFCID_RELEASE.

  DATA: L_DBSEL TYPE  /SIE/HR_IDP_DB_SEL
      .

  CHECK NOT ( /SIE/HR_IDP_S1-IFCID IS INITIAL ).

  CALL FUNCTION '/SIE/HR_IDP_IFC_RELEASE'
       EXPORTING
            IFCID             = /SIE/HR_IDP_S1-IFCID
       IMPORTING
            DBSEL             = L_DBSEL
       EXCEPTIONS
            WAS_RELEASED      = 1
            RELEASE_CANCELLED = 2
            PROGRAM_ERROR     = 3
            OTHERS            = 99.
  CASE SY-SUBRC.
    WHEN 0.
      MESSAGE S070 WITH /SIE/HR_IDP_S1-IFCID.
    WHEN 1.
      MESSAGE S302 WITH /SIE/HR_IDP_S1-IFCID.
*   Die Schnittstelle ist schon freigegeben.
    WHEN 2 OR 3.
      MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    WHEN OTHERS.
      MESSAGE S071 WITH /SIE/HR_IDP_S1-IFCID.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_3000  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_3000 INPUT.

*  perform check_version_selection.

  CASE SVCODE.
    WHEN  C_RELE_CODE.
      PERFORM ACCEPT_VERSION.
  ENDCASE.
  PERFORM HANDLE_IFCF.
  PERFORM HANDLE_LEGE_CODE.
  PERFORM HANDLE_DOCUMENTATION.
  PERFORM HANDLE_TC_NAVIGATION.

ENDMODULE.                 " USER_COMMAND_3000  INPUT

*&---------------------------------------------------------------------*
*&      Form  ACCEPT_VERSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ACCEPT_VERSION.

  DATA: L_VERSION TYPE /SIE/HR_IDP_VERS_NR.

  CALL FUNCTION '/SIE/HR_IDP_IFC_CURR_VERSION'
       EXPORTING
            INTERFACE         = /SIE/HR_IDP_S1-IFCID
            ACTIVE            = YES
       IMPORTING
            VERSION           = L_VERSION
       EXCEPTIONS
            NO_ACTIVE_VERSION = 1
            OTHERS            = 2.
  IF SY-SUBRC <> 0.
    L_VERSION = 0.
    MESSAGE S110 WITH /SIE/HR_IDP_S1-IFCID.
  ELSE.

    CALL FUNCTION '/SIE/HR_IDP_IFC_ACCEPT'
         EXPORTING
              IFCID        = /SIE/HR_IDP_S1-IFCID
              VRSNR        = L_VERSION
         EXCEPTIONS
              ENQUEUE      = 1
              NOT_RELEASED = 2
              OTHERS       = 3.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.
ENDFORM.                    " ACCEPT_VERSION

*&---------------------------------------------------------------------*
*&      Form  IFCID_TEST
*&---------------------------------------------------------------------*
FORM IFCID_TEST.

  CALL FUNCTION '/SIE/HR_IDP_TEST_GENERATOR'
       EXPORTING
            IFCID           = /SIE/HR_IDP_S1-IFCID
       EXCEPTIONS
            ENQUEUE         = 1
            WAS_RELEASED    = 2
            DB_INCONSISTENT = 3
            PROGRAM_EXISTS  = 4
            OTHERS          = 5.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " IFCID_TEST
