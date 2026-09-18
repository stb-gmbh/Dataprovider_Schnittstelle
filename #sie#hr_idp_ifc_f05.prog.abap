*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_F05                                        *
*----------------------------------------------------------------------*

FORM TRANSPORT USING P_MODE TYPE TY_TRANM
                     P_DATA TYPE /SIE/HR_IDP_IFC_DB.

  DATA: IE071K TYPE E071K OCCURS 0 WITH HEADER LINE.
  DATA: IKO200 TYPE KO200 OCCURS 0 WITH HEADER LINE.

  DATA: ORDER    LIKE E070-TRKORR,                   "Auftrag
        TASK     LIKE E070-TRKORR,                   "Aufgabe
        CATEGORY LIKE E070-KORRDEV,                  "Kategorie
        CLI_DEP  LIKE TRPARI-W_CLI_DEP,              "Mandantenabhängig
        ONAME(10),
        OTYPE(10).
  DATA:
    IFCID TYPE /SIE/HR_IDP_INTERFACE_ID,
    VRSNR TYPE /SIE/HR_IDP_VERS_NR,
    KEY TYPE TROBJ_NAME.
*  break mch0341.

  CALL FUNCTION 'TR_ORDER_CHOICE_CORRECTION'
       EXPORTING
            IV_CATEGORY            = 'SYST'
            IV_CLI_DEP             = YES
       IMPORTING
            EV_ORDER               = ORDER
            EV_TASK                = TASK
       EXCEPTIONS
            INVALID_CATEGORY       = 1
            NO_CORRECTION_SELECTED = 2
            OTHERS                 = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  DEFINE INSERT_TABLE.
    CLEAR KEY.
    TRANSLATE &2 USING ' @'.
    TRANSLATE &3 USING ' @'.
    CONCATENATE &2 &3 &4 INTO KEY.
    TRANSLATE KEY USING '@ '.
    IE071K-OBJNAME    = &1.
    IE071K-MASTERNAME = &1.
    IE071K-TABKEY     = KEY.
    APPEND IE071K.
    MOVE-CORRESPONDING IE071K TO IKO200.
    MOVE IE071K-OBJNAME TO IKO200-OBJ_NAME.
    IKO200-OBJFUNC   = 'K'.
    APPEND IKO200.
  END-OF-DEFINITION.
  IFCID = P_DATA-S1-IFCID.
  VRSNR = P_DATA-S1VN-VRSNR.
  CLEAR IE071K.
  IE071K-TRKORR       = TASK.
  IE071K-PGMID        = 'R3TR'.
  IE071K-OBJECT       = 'TABU'.
  IE071K-MASTERTYPE   = 'TABU'.

  INSERT_TABLE: '/SIE/HR_IDP_S1'     SY-MANDT IFCID SPACE,
                '/SIE/HR_IDP_S1T'    SY-MANDT SY-LANGU IFCID,
                '/SIE/HR_IDP_S1VN'   SY-MANDT IFCID VRSNR,
                '/SIE/HR_IDP_S1DF'   SY-MANDT IFCID VRSNR,
                '/SIE/HR_IDP_S1PG'   SY-MANDT IFCID VRSNR,
                '/SIE/HR_IDP_S1VT'   SY-MANDT IFCID VRSNR,
                '/SIE/HR_IDP_S1R'    SY-MANDT IFCID VRSNR,
                '/SIE/HR_IDP_S1LT'   SY-MANDT SY-LANGU IFCID.
*  CALL FUNCTION 'TR_OBJECTS_CHECK'
**    EXPORTING
**         IV_NO_STANDARD_EDITOR          = ' '
**         IV_NO_SHOW_OPTION              = ' '
**      IMPORTING
**           we_order                       = order
**           we_task                        =  task
**         WE_OBJECTS_APPENDABLE          =
*       TABLES
*            WT_KO200                       = IKO200
*            WT_E071K                       = IE071K
**         TT_TADIR                       =
*      EXCEPTIONS
*           CANCEL_EDIT_APPEND_ERROR_KEYS  = 1
*           CANCEL_EDIT_APPEND_ERROR_OBJCT = 2
*           CANCEL_EDIT_APPEND_ERROR_ORDER = 3
*           CANCEL_EDIT_BUT_SE01           = 4
*           CANCEL_EDIT_NO_HEADER_OBJECT   = 5
*           CANCEL_EDIT_NO_ORDER_SELECTED  = 6
*           CANCEL_EDIT_REPAIRED_OBJECT    = 7
*           CANCEL_EDIT_SYSTEM_ERROR       = 8
*           CANCEL_EDIT_TADIR_MISSING      = 9
*           CANCEL_EDIT_TADIR_UPDATE_ERROR = 10
*           CANCEL_EDIT_UNKNOWN_DEVCLASS   = 11
*           CANCEL_EDIT_UNKNOWN_OBJECTTYPE = 12
*           SHOW_ONLY_CLOSED_SYSTEM        = 13
*           SHOW_ONLY_CONSOLIDATION_LEVEL  = 14
*           SHOW_ONLY_DDIC_IN_CUSTOMER_SYS = 15
*           SHOW_ONLY_DELIVERY_SYSTEM      = 16
*           SHOW_ONLY_DIFFERENT_ORDERTYPES = 17
*           SHOW_ONLY_DIFFERENT_TASKTYPES  = 18
*           SHOW_ONLY_ENQUEUE_FAILED       = 19
*           SHOW_ONLY_GENERATED_OBJECT     = 20
*           SHOW_ONLY_ILL_LOCK             = 21
*           SHOW_ONLY_LOCK_ENQUEUE_FAILED  = 22
*           SHOW_ONLY_MIXED_ORDERS         = 23
*           SHOW_ONLY_MIX_LOCAL_TRANSP_OBJ = 24
*           SHOW_ONLY_NO_SHARED_REPAIR     = 25
*           SHOW_ONLY_OBJECT_LOCKED        = 26
*           SHOW_ONLY_REPAIRED_OBJECT      = 27
*           SHOW_ONLY_SHOW_CLIENT          = 28
*           SHOW_ONLY_TADIR_MISSING        = 29
*           SHOW_ONLY_UNKNOWN_DEVCLASS     = 30
*           CANCEL_EDIT_NO_CHECK_CALL      = 31
*           CANCEL_EDIT_CATEGORY_MIXTURE   = 32
*           SHOW_ONLY_CLOSED_CLIENT        = 33
*           SHOW_ONLY_CLOSED_ALE_OBJECT    = 34
*           CANCEL_EDIT_OTHER_ERROR        = 35
*           SHOW_ONLY_OTHER_ERROR          = 36
*           OTHERS                         = 37
*            .
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.

*  IKO200-TRKORR = ORDER.
*  MODIFY TABLE IKO200 TRANSPORTING TRKORR.
*  IE071K-TRKORR = ORDER.
*  MODIFY TABLE IE071K TRANSPORTING TRKORR.
*  CALL FUNCTION 'TR_OBJECTS_INSERT'
*    EXPORTING
*          WI_ORDER                       = ORDER
**         iv_no_standard_editor          = ' '
**         iv_no_show_option              = 'X'
**    IMPORTING
**         WE_ORDER                       =
**         WE_TASK                        =
*       TABLES
*            WT_KO200                       = IKO200
*            WT_E071K                       = IE071K
**         TT_TADIR                       =
*    EXCEPTIONS
*         CANCEL_EDIT_APPEND_ERROR_KEYS  = 1
*         CANCEL_EDIT_APPEND_ERROR_OBJCT = 2
*         CANCEL_EDIT_APPEND_ERROR_ORDER = 3
*         CANCEL_EDIT_BUT_SE01           = 4
*         CANCEL_EDIT_NO_HEADER_OBJECT   = 5
*         CANCEL_EDIT_NO_ORDER_SELECTED  = 6
*         CANCEL_EDIT_REPAIRED_OBJECT    = 7
*         CANCEL_EDIT_SYSTEM_ERROR       = 8
*         CANCEL_EDIT_TADIR_MISSING      = 9
*         CANCEL_EDIT_TADIR_UPDATE_ERROR = 10
*         CANCEL_EDIT_UNKNOWN_DEVCLASS   = 11
*         CANCEL_EDIT_UNKNOWN_OBJECTTYPE = 12
*         SHOW_ONLY_CLOSED_SYSTEM        = 13
*         SHOW_ONLY_CONSOLIDATION_LEVEL  = 14
*         SHOW_ONLY_DDIC_IN_CUSTOMER_SYS = 15
*         SHOW_ONLY_DELIVERY_SYSTEM      = 16
*         SHOW_ONLY_DIFFERENT_ORDERTYPES = 17
*         SHOW_ONLY_DIFFERENT_TASKTYPES  = 18
*         SHOW_ONLY_ENQUEUE_FAILED       = 19
*         SHOW_ONLY_GENERATED_OBJECT     = 20
*         SHOW_ONLY_ILL_LOCK             = 21
*         SHOW_ONLY_LOCK_ENQUEUE_FAILED  = 22
*         SHOW_ONLY_MIXED_ORDERS         = 23
*         SHOW_ONLY_MIX_LOCAL_TRANSP_OBJ = 24
*         SHOW_ONLY_NO_SHARED_REPAIR     = 25
*         SHOW_ONLY_OBJECT_LOCKED        = 26
*         SHOW_ONLY_REPAIRED_OBJECT      = 27
*         SHOW_ONLY_SHOW_CLIENT          = 28
*         SHOW_ONLY_TADIR_MISSING        = 29
*         SHOW_ONLY_UNKNOWN_DEVCLASS     = 30
*         CANCEL_EDIT_NO_CHECK_CALL      = 31
*         CANCEL_EDIT_CATEGORY_MIXTURE   = 32
*         SHOW_ONLY_CLOSED_CLIENT        = 33
*         SHOW_ONLY_CLOSED_ALE_OBJECT    = 34
*         CANCEL_EDIT_OTHER_ERROR        = 35
*         SHOW_ONLY_OTHER_ERROR          = 36
*         OTHERS                         = 37
*            .
*  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.

  CALL FUNCTION 'TR_APPEND_TO_COMM_OBJS_KEYS'
       EXPORTING
*         WI_SIMULATION                  = ' '
*         WI_SUPPRESS_KEY_CHECK          = ' '
            WI_TRKORR                      = TASK
       TABLES
            WT_E071                        = IKO200
            WT_E071K                       = IE071K
      EXCEPTIONS
           KEY_CHAR_IN_NON_CHAR_FIELD     = 1
           KEY_CHECK_KEYSYNTAX_ERROR      = 2
           KEY_INTTAB_TABLE               = 3
           KEY_LONGER_FIELD_BUT_NO_GENERC = 4
           KEY_MISSING_KEY_MASTER_FIELDS  = 5
           KEY_MISSING_KEY_TABLEKEY       = 6
           KEY_NON_CHAR_BUT_NO_GENERIC    = 7
           KEY_NO_KEY_FIELDS              = 8
           KEY_STRING_LONGER_CHAR_KEY     = 9
           KEY_TABLE_HAS_NO_FIELDS        = 10
           KEY_TABLE_NOT_ACTIV            = 11
           KEY_UNALLOWED_KEY_FUNCTION     = 12
           KEY_UNALLOWED_KEY_OBJECT       = 13
           KEY_UNALLOWED_KEY_OBJNAME      = 14
           KEY_UNALLOWED_KEY_PGMID        = 15
           KEY_WITHOUT_HEADER             = 16
           OB_CHECK_OBJ_ERROR             = 17
           OB_DEVCLASS_NO_EXIST           = 18
           OB_EMPTY_KEY                   = 19
           OB_GENERIC_OBJECTNAME          = 20
           OB_ILL_DELIVERY_TRANSPORT      = 21
           OB_ILL_LOCK                    = 22
           OB_ILL_PARTS_TRANSPORT         = 23
           OB_ILL_SOURCE_SYSTEM           = 24
           OB_ILL_SYSTEM_OBJECT           = 25
           OB_ILL_TARGET                  = 26
           OB_INTTAB_TABLE                = 27
           OB_LOCAL_OBJECT                = 28
           OB_LOCKED_BY_OTHER             = 29
           OB_MODIF_ONLY_IN_MODIF_ORDER   = 30
           OB_NAME_TOO_LONG               = 31
           OB_NO_APPEND_OF_CORR_ENTRY     = 32
           OB_NO_APPEND_OF_C_MEMBER       = 33
           OB_NO_CONSOLIDATION_TRANSPORT  = 34
           OB_NO_ORIGINAL                 = 35
           OB_NO_SHARED_REPAIRS           = 36
           OB_NO_SYSTEMNAME               = 37
           OB_NO_SYSTEMTYPE               = 38
           OB_NO_TADIR                    = 39
           OB_NO_TADIR_NOT_LOCKABLE       = 40
           OB_PRIVAT_OBJECT               = 41
           OB_REPAIR_ONLY_IN_REPAIR_ORDER = 42
           OB_RESERVED_NAME               = 43
           OB_SYNTAX_ERROR                = 44
           OB_TABLE_HAS_NO_FIELDS         = 45
           OB_TABLE_NOT_ACTIV             = 46
           TR_ENQUEUE_FAILED              = 47
           TR_ERRORS_IN_ERROR_TABLE       = 48
           TR_ILL_KORRNUM                 = 49
           TR_LOCKMOD_FAILED              = 50
           TR_LOCK_ENQUEUE_FAILED         = 51
           TR_NOT_OWNER                   = 52
           TR_NO_SYSTEMNAME               = 53
           TR_NO_SYSTEMTYPE               = 54
           TR_ORDER_NOT_EXIST             = 55
           TR_ORDER_RELEASED              = 56
           TR_ORDER_UPDATE_ERROR          = 57
           TR_WRONG_ORDER_TYPE            = 58
           OB_INVALID_TARGET_SYSTEM       = 59
           TR_NO_AUTHORIZATION            = 60
           OB_WRONG_TABLETYP              = 61
           OB_WRONG_CATEGORY              = 62
           OB_SYSTEM_ERROR                = 63
           OB_UNLOCAL_OBJEKT_IN_LOCAL_ORD = 64
           TR_WRONG_CLIENT                = 65
           OB_WRONG_CLIENT                = 66
           KEY_WRONG_CLIENT               = 67
           OTHERS                         = 68
            .
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.
