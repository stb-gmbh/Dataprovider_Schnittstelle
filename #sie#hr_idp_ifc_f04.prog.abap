*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_F04                                        *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  GET_HELP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_HELP INPUT.
  CHECK OKCODE EQ 'ENGH'.
  CLEAR OKCODE.

* Struktur mit Daten versorgen
*  l_help_info-call       = 'M'.
*  l_help_info-object     = 'N'.
*  l_help_info-spras      = sy-langu.
*  l_help_info-docuid     = 'RE'.
*  l_help_info-report     = sy-repid.
*
*  l_dselc-fldname        = '/SIE/HR_IDP_S1-IFCID'.
*  l_dselc-fldinh         = g_ifdata_1000-s1-ifcid.
*  l_dselc-dyfldname      = 'G_IFDATA_1000-S1-IFCID'.
*
*call function 'HELP_START'
*     exporting
*          help_infos   = l_help_info
**    IMPORTING
**         SELECTION    =
**         SELECT_VALUE =
**         RSMDY_RET    =
*     tables
*          dynpselect   = l_dselc
*          dynpvaluetab = l_dval.

*call function 'DYNP_VALUES_READ'     "vgl. RUTSHEXP
*     exporting
*          dyname                   =
*          dynumb                   =
*         TRANSLATE_TO_UPPER       = ' '
*         REQUEST                  = ' '
*         PERFORM_CONVERSION_EXITS = ' '
*         PERFORM_INPUT_CONVERSION = ' '
*     tables
*          dynpfields               =
*    EXCEPTIONS
*         INVALID_ABAPWORKAREA     = 1
*         INVALID_DYNPROFIELD      = 2
*         INVALID_DYNPRONAME       = 3
*         INVALID_DYNPRONUMMER     = 4
*         INVALID_REQUEST          = 5
*         NO_FIELDDESCRIPTION      = 6
*         INVALID_PARAMETER        = 7
*         UNDEFIND_ERROR           = 8
*         DOUBLE_CONVERSION        = 9
*         OTHERS                   = 10
*  .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMODULE.                 " GET_HELP  INPUT
