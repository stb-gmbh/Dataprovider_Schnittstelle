*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_GENERATORF16 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PROCESS_AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TRANS_DATA_S1_AUTH_CLASS  text
*----------------------------------------------------------------------*
FORM PROCESS_AUTHORITY_CHECK USING P_IFCID
                                   P_AUTH_CLASS.

  DATA:
     TAG     TYPE /SIE/HR_IDP_TT_CODING,
     INPUT   TYPE /SIE/HR_IDP_TT_CODING,
     RESULT  TYPE /SIE/HR_IDP_TT_CODING.

  PERFORM GET_TAG USING 'auth_check' CHANGING TAG.
*  perform replace_param using 'ACTIVITY'
*                               '70'    " Create Execution
*                               tag
*                        changing result.
*  move result[] to input[].
  PERFORM REPLACE_PARAM USING 'CLASS'
                               P_AUTH_CLASS
                               TAG
                        CHANGING RESULT.
  MOVE RESULT[] TO INPUT[].
  PERFORM REPLACE_PARAM USING 'OBJECT'
                               P_IFCID
                               INPUT
                        CHANGING RESULT.
  MOVE RESULT[] TO INPUT[].
  PERFORM REPLACE_PARAM USING 'SUB'
                               'PROG'
                               INPUT
                        CHANGING RESULT.
  PERFORM INSERT_CODE USING RESULT.

*$<auth_check>
*$
*$ data: activity     type /sie/hr_idp_activity
*$     , class        type /sie/hr_idp_auth_class
*$     , object       type /sie/hr_idp_auth_class
*$     , sub          type /SIE/HR_IDP_SUBOBJECT
*$     .
*$
*$ if p_adhoc = 'X'.
*$ activity = '71'.
*$ else.
*$ activity = '70'.
*$ endif.
*$ class = '&CLASS'.
*$ object = '&OBJECT'.
*$ sub = '&SUB'.
*$
*$   call function '/SIE/HR_IDP_AUTH_CHECK'
*$        exporting
*$             activity     = ACTIVITY
*$             if_class     = CLASS
*$             object       = OBJECT
*$             subobject    = SUB
*$        exceptions
*$             no_authority = 1
*$             others       = 2.
*$   if sy-subrc <> 0.
*$    perform append_log using object
*$                              'E'
*$                              'Fehlende Berechtigung'.
*$     exit.
*$   endif.
*$</auth_check>

ENDFORM.                    " PROCESS_AUTHORITY_CHECK

*EXIT.
