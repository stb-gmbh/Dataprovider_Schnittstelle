FUNCTION /sie/hr_idp_ifc_transport.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(P_IFCID) TYPE  /SIE/HR_IDP_INTERFACE_ID
*"             VALUE(P_VRSNR) TYPE  /SIE/HR_IDP_VERS_NR
*"----------------------------------------------------------------------
* Korrekturen:       bei den FUBAs ist die  EXCEPTIONS Sst. angepasst worden
*
*
*FORM transport USING p_mode TYPE ty_tranm
*                     p_data TYPE /sie/hr_idp_ifc_db.

  DATA: ie071k TYPE e071k OCCURS 0 WITH HEADER LINE.
  DATA: iko200 TYPE ko200 OCCURS 0 WITH HEADER LINE.

  DATA: order    LIKE e070-trkorr,                   "Auftrag
        task     LIKE e070-trkorr,                   "Aufgabe
        category LIKE e070-korrdev,                  "Kategorie
        cli_dep  LIKE trpari-w_cli_dep,              "Mandantenabhängig
        oname(10),
        otype(10).
  DATA:
    p_trans_data TYPE /sie/hr_idp_ifc_db,
    p_proc_vector TYPE /sie/hr_idp_db_sel,
    key TYPE trobj_name.
*  break mch0341.


*    P_PROC_VECTOR = 'XXXXXXXXXXXXXXXXXXXXXXXX'.
*    CALL FUNCTION '/SIE/HR_IDP_DB_READ'
*         EXPORTING
*              INTERFACE        = P_IFCID
*              VERSION          = P_VRSNR
*         CHANGING
*              TRANSACTION_DATA = P_TRANS_DATA
*              DBSEL            = P_PROC_VECTOR.


*  CALL FUNCTION 'TR_ORDER_CHOICE_CORRECTION'
*       EXPORTING
*            IV_CATEGORY            = 'CUST'
*            IV_CLI_DEP             = YES
*       IMPORTING
*            EV_ORDER               = ORDER
*            EV_TASK                = TASK
*       EXCEPTIONS
*            INVALID_CATEGORY       = 1
*            NO_CORRECTION_SELECTED = 2
*            OTHERS                 = 3.
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*break mch0341.
  DEFINE insert_table.
    clear key.
    translate &2 using ' @'.
    translate &3 using ' @'.
    concatenate &2 &3 &4 &5 into key.
    translate key using '@ '.
    ie071k-objname    = &1.
    ie071k-mastername = &1.
    ie071k-tabkey     = key.
*    ie071k-objfunc   = 'K'.
    append ie071k.
    move-corresponding ie071k to iko200.
    move ie071k-objname to iko200-obj_name.
*    iko200-objfunc   = 'K'.
    iko200-operation = 'I'.
    append iko200.
  END-OF-DEFINITION.


  CLEAR ie071k.
*  ie071k-trkorr       = order.
  ie071k-pgmid        = 'R3TR'.
  ie071k-object       = 'TABU'.
  ie071k-mastertype   = 'TABU'.

*  INSERT_TABLE:
*                '/SIE/HR_IDP_S1'     SY-MANDT P_IFCID SPACE,
*                '/SIE/HR_IDP_S1T'    SY-MANDT SY-LANGU P_IFCID,
*                '/SIE/HR_IDP_S1VN'   SY-MANDT P_IFCID P_VRSNR,
*                '/SIE/HR_IDP_S1DF'   SY-MANDT P_IFCID P_VRSNR,
*                '/SIE/HR_IDP_S1PG'   SY-MANDT P_IFCID P_VRSNR '*',
*                '/SIE/HR_IDP_S1VT'   SY-MANDT P_IFCID P_VRSNR,
*                '/SIE/HR_IDP_S1R'    SY-MANDT P_IFCID P_VRSNR,
*                '/SIE/HR_IDP_S1LT'   SY-MANDT SY-LANGU P_IFCID.
*                '/SIE/HR_IDP_S1DL'   SY-MANDT SY-LANGU P_IFCID.



  CALL FUNCTION 'TR_OBJECTS_CHECK'
*    EXPORTING
*         IV_NO_STANDARD_EDITOR          = ' '
*         IV_NO_SHOW_OPTION              = ' '
*      IMPORTING
*          we_order                       = order
*         we_task                        =  task
*         WE_OBJECTS_APPENDABLE          =
        TABLES
             wt_ko200                       = iko200
             wt_e071k                       = ie071k
*         TT_TADIR                       =
 EXCEPTIONS
   cancel_edit_other_error       = 1
   show_only_other_error         = 2
   OTHERS                        = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*  iko200-trkorr = order.
*  MODIFY TABLE iko200 TRANSPORTING trkorr.
*  ie071k-trkorr = order.
*  MODIFY TABLE ie071k TRANSPORTING trkorr.
*break mch0341.
  CALL FUNCTION 'TR_OBJECTS_INSERT'
*    EXPORTING
*         wi_order                       = order
*         iv_no_standard_editor          = ' '
*         iv_no_show_option              = 'X'
*    IMPORTING
*         WE_ORDER                       =
*         WE_TASK                        =
       TABLES
            wt_ko200                       = iko200
            wt_e071k                       = ie071k
*         TT_TADIR                       =
     EXCEPTIONS
    cancel_edit_other_error       = 1
    show_only_other_error         = 2
    OTHERS                        = 3
           .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*  CALL FUNCTION 'TR_APPEND_TO_COMM_OBJS_KEYS'
*       EXPORTING
**         WI_SIMULATION                  = ' '
**         WI_SUPPRESS_KEY_CHECK          = ' '
*            WI_TRKORR                      = TASK
*       TABLES
*            WT_E071                        = IKO200
*            WT_E071K                       = IE071K
*      EXCEPTIONS
*           KEY_CHAR_IN_NON_CHAR_FIELD     = 1
*           KEY_CHECK_KEYSYNTAX_ERROR      = 2
*           KEY_INTTAB_TABLE               = 3
*           KEY_LONGER_FIELD_BUT_NO_GENERC = 4
*           KEY_MISSING_KEY_MASTER_FIELDS  = 5
*           KEY_MISSING_KEY_TABLEKEY       = 6
*           KEY_NON_CHAR_BUT_NO_GENERIC    = 7
*           KEY_NO_KEY_FIELDS              = 8
*           KEY_STRING_LONGER_CHAR_KEY     = 9
*           KEY_TABLE_HAS_NO_FIELDS        = 10
*           KEY_TABLE_NOT_ACTIV            = 11
*           KEY_UNALLOWED_KEY_FUNCTION     = 12
*           KEY_UNALLOWED_KEY_OBJECT       = 13
*           KEY_UNALLOWED_KEY_OBJNAME      = 14
*           KEY_UNALLOWED_KEY_PGMID        = 15
*           KEY_WITHOUT_HEADER             = 16
*           OB_CHECK_OBJ_ERROR             = 17
*           OB_DEVCLASS_NO_EXIST           = 18
*           OB_EMPTY_KEY                   = 19
*           OB_GENERIC_OBJECTNAME          = 20
*           OB_ILL_DELIVERY_TRANSPORT      = 21
*           OB_ILL_LOCK                    = 22
*           OB_ILL_PARTS_TRANSPORT         = 23
*           OB_ILL_SOURCE_SYSTEM           = 24
*           OB_ILL_SYSTEM_OBJECT           = 25
*           OB_ILL_TARGET                  = 26
*           OB_INTTAB_TABLE                = 27
*           OB_LOCAL_OBJECT                = 28
*           OB_LOCKED_BY_OTHER             = 29
*           OB_MODIF_ONLY_IN_MODIF_ORDER   = 30
*           OB_NAME_TOO_LONG               = 31
*           OB_NO_APPEND_OF_CORR_ENTRY     = 32
*           OB_NO_APPEND_OF_C_MEMBER       = 33
*           OB_NO_CONSOLIDATION_TRANSPORT  = 34
*           OB_NO_ORIGINAL                 = 35
*           OB_NO_SHARED_REPAIRS           = 36
*           OB_NO_SYSTEMNAME               = 37
*           OB_NO_SYSTEMTYPE               = 38
*           OB_NO_TADIR                    = 39
*           OB_NO_TADIR_NOT_LOCKABLE       = 40
*           OB_PRIVAT_OBJECT               = 41
*           OB_REPAIR_ONLY_IN_REPAIR_ORDER = 42
*           OB_RESERVED_NAME               = 43
*           OB_SYNTAX_ERROR                = 44
*           OB_TABLE_HAS_NO_FIELDS         = 45
*           OB_TABLE_NOT_ACTIV             = 46
*           TR_ENQUEUE_FAILED              = 47
*           TR_ERRORS_IN_ERROR_TABLE       = 48
*           TR_ILL_KORRNUM                 = 49
*           TR_LOCKMOD_FAILED              = 50
*           TR_LOCK_ENQUEUE_FAILED         = 51
*           TR_NOT_OWNER                   = 52
*           TR_NO_SYSTEMNAME               = 53
*           TR_NO_SYSTEMTYPE               = 54
*           TR_ORDER_NOT_EXIST             = 55
*           TR_ORDER_RELEASED              = 56
*           TR_ORDER_UPDATE_ERROR          = 57
*           TR_WRONG_ORDER_TYPE            = 58
*           OB_INVALID_TARGET_SYSTEM       = 59
*           TR_NO_AUTHORIZATION            = 60
*           OB_WRONG_TABLETYP              = 61
*           OB_WRONG_CATEGORY              = 62
*           OB_SYSTEM_ERROR                = 63
*           OB_UNLOCAL_OBJEKT_IN_LOCAL_ORD = 64
*           TR_WRONG_CLIENT                = 65
*           OB_WRONG_CLIENT                = 66
*           KEY_WRONG_CLIENT               = 67
*           OTHERS                         = 68
*            .
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.


*ENDFORM.





ENDFUNCTION.
