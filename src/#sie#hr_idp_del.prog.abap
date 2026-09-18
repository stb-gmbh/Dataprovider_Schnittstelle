*&---------------------------------------------------------------------*
*& Report  /SIE/HR_IDP_DEL                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
*&  Dieses Report löscht eine Schnittstellenversion                    *
*&                                                                     *
*&---------------------------------------------------------------------*
*Änderungen: SIE001 Hierl 25.06.2004 Neue Tabelle S1PS für Filter auf
*                                    Feldebene ebenfalls löschen

REPORT  /sie/hr_idp_del NO STANDARD PAGE HEADING
                        MESSAGE-ID /sie/hr_idp_messages
                        LINE-SIZE 80.

INCLUDE /sie/hr_idp_types.

TABLES: /sie/hr_idp_s1
      , /sie/hr_idp_s1t
      , /sie/hr_idp_s1df
      , /sie/hr_idp_s1lt
      , /sie/hr_idp_s1pg
      , /sie/hr_idp_s1ps                                   "SIE001
      , /sie/hr_idp_s1r
      , /sie/hr_idp_s1vn
      , /sie/hr_idp_s1vt
      , /sie/hr_idp_s1f
      , /sie/hr_idp_s1pr
      , /sie/hr_idp_s1dl
      , /sie/hr_idp_s1sa
      , /sie/hr_idp_s1pc
      .

DATA: proc_vec TYPE /sie/hr_idp_db_sel VALUE c_all_tabl
    , db_data TYPE /sie/hr_idp_ifc_db
    , last_version TYPE /sie/hr_idp_vers_nr
    , old_version TYPE /sie/hr_idp_vers_nr
    , g_rc TYPE sysubrc
    .
DATA: BEGIN OF tab OCCURS 10,
        fcode LIKE rsmpe-func,
      END OF tab.

DATA: rc LIKE sy-subrc.
DATA: ifc_count TYPE i.

PARAMETERS: ifcid TYPE /sie/hr_idp_interface_id
          , fl_all AS CHECKBOX DEFAULT space
*         , fl_all default space no-display
          .

INITIALIZATION.
  GET PARAMETER ID '/SIE/HR_IDP_IFCID' FIELD ifcid.

START-OF-SELECTION.

  CALL FUNCTION '/SIE/HR_IDP_CHECK_REFERENCE'
    EXPORTING
      ifcid                   = ifcid
    IMPORTING
      ifc_count               = ifc_count
*     OUTTAB                  =
            .
  IF ifc_count > 0.
     MESSAGE e453 WITH ifc_count.
     EXIT.
  ENDIF.


  IF ( fl_all IS INITIAL ).
    SET PF-STATUS 'DELT'.

    PERFORM read_ifcid.

    IF db_data-s1-ifcid IS INITIAL.
      MESSAGE e199.
      EXIT.
    ENDIF.

    PERFORM check_authority USING sy-tcode
                               c_utility
                               db_data-s1-auth_class
                               db_data-s1-ifcid
                               'IDEL'   " Interface Delete
                       CHANGING rc.
    PERFORM enqueue.
    PERFORM list_display.
  ELSE.
    IF NOT ( ifcid IS INITIAL ).
      SELECT SINGLE * FROM /sie/hr_idp_s1 WHERE ifcid = ifcid.
      IF sy-subrc EQ 0.
        PERFORM check_authority USING sy-tcode
                                   c_utility
                                   /sie/hr_idp_s1-auth_class
                                   ifcid
                                   'IDEL'
                       CHANGING rc.

        DELETE FROM /sie/hr_idp_s1 WHERE ifcid = ifcid.
        DELETE FROM /sie/hr_idp_s1t WHERE ifcid = ifcid.
        DELETE FROM /sie/hr_idp_s1r WHERE ifcid = ifcid.
        DELETE FROM /sie/hr_idp_s1df WHERE ifcid = ifcid.
        DELETE FROM /sie/hr_idp_s1pg WHERE ifcid = ifcid.
        DELETE FROM /sie/hr_idp_s1ps WHERE ifcid = ifcid.  "SIE001
        DELETE FROM /sie/hr_idp_s1f WHERE ifcid = ifcid.
        DELETE FROM /sie/hr_idp_s1vt WHERE ifcid = ifcid.
        DELETE FROM /sie/hr_idp_s1vn WHERE ifcid = ifcid.
        DELETE FROM /sie/hr_idp_s1lt WHERE ifcid = ifcid.
        DELETE FROM /sie/hr_idp_s1pr WHERE ifcid = ifcid.
        DELETE FROM /sie/hr_idp_s1sa WHERE ifcid = ifcid.
        DELETE FROM /sie/hr_idp_s1dl WHERE ifcid = ifcid.
        DELETE FROM /sie/hr_idp_s1pc WHERE ifcid = ifcid.
        COMMIT WORK.
      ENDIF.
    ENDIF.
  ENDIF.

AT USER-COMMAND.
  CASE sy-ucomm.
    WHEN 'END'.
      PERFORM dequeue.
      LEAVE PROGRAM.
    WHEN 'DELT'.
      PERFORM del_execute.
      PERFORM dequeue.
      CLEAR tab[].
      MOVE 'DELT' TO tab-fcode.
      APPEND tab.
      SET PF-STATUS 'DELT' EXCLUDING tab IMMEDIATELY.
    WHEN 'ERR '.
      PERFORM print_error_list.
    WHEN OTHERS.
  ENDCASE.

*---------------------------------------------------------------------*
*       FORM READ_IFCID                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM read_ifcid.

  CALL FUNCTION '/SIE/HR_IDP_IFC_CURR_VERSION'
       EXPORTING
            interface = ifcid
       IMPORTING
            version   = last_version.
  old_version = last_version.
  IF last_version IS INITIAL.
    EXIT.
  ELSE.
    CALL FUNCTION '/SIE/HR_IDP_DB_READ'
         EXPORTING
              interface        = ifcid
              version          = last_version
         CHANGING
              transaction_data = db_data
              dbsel            = proc_vec.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM LIST_DISPLAY                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM list_display.

  WRITE: / 'Die Schnittstelle ' NO-GAP
         , db_data-s1-ifcid NO-GAP
         , ' in der Version ' NO-GAP
         , last_version NO-GAP
         , ' wird gelöscht' NO-GAP
         .

ENDFORM.

*---------------------------------------------------------------------*
*       FORM DEL_EXECUTE                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM del_execute.

  CHECK g_rc = 0.

  CHECK NOT ( db_data-s1-ifcid IS INITIAL ).

  DELETE FROM /sie/hr_idp_s1df WHERE ifcid = db_data-s1-ifcid
                               AND   vrsnr = last_version.
  PERFORM append_error USING 'S'
                            '115'
                            sy-dbcnt
                            '/sie/hr_idp_s1df'
                            space
                            space.


  SELECT SINGLE * FROM /sie/hr_idp_s1df WHERE ifcid = db_data-s1-ifcid
                                 AND      vrsnr = last_version.
  IF sy-subrc = 0.
    IF NOT ( /sie/hr_idp_s1df-progr IS INITIAL ).
      CALL FUNCTION 'RS_DELETE_PROGRAM'
           EXPORTING
                program            = /sie/hr_idp_s1df-progr
               suppress_checks    = 'X'
               suppress_popup     = 'X'
*         TADIR_DEVCLASS     =
*    IMPORTING
*         CORRNUMBER         =
*         PROGRAM            =
    EXCEPTIONS
         enqueue_lock       = 1
         object_not_found   = 2
         permission_failure = 3
         reject_deletion    = 4
         OTHERS             = 5
                .
      IF sy-subrc <> 0.
* Do nothing
      ENDIF.
    ENDIF.
  ENDIF.

  DELETE FROM /sie/hr_idp_s1pg WHERE ifcid = db_data-s1-ifcid
                               AND      vrsnr = last_version.
  PERFORM append_error USING 'S'
                            '115'
                            sy-dbcnt
                            '/sie/hr_idp_s1pg'
                            space
                            space.

*SIE001_BEG
  DELETE FROM /sie/hr_idp_s1ps WHERE ifcid  = db_data-s1-ifcid
                               AND    vrsnr = last_version.
  PERFORM append_error USING 'S'
                            '115'
                            sy-dbcnt
                            '/sie/hr_idp_s1ps'
                            space
                            space.
*SIE001_END

  DELETE FROM /sie/hr_idp_s1r WHERE ifcid = db_data-s1-ifcid
                              AND         vrsnr = last_version.
  PERFORM append_error USING 'S'
                            '115'
                            sy-dbcnt
                            '/sie/hr_idp_s1r'
                            space
                            space.
  DELETE FROM /sie/hr_idp_s1vn WHERE ifcid = db_data-s1-ifcid
                                AND       vrsnr = last_version.
  PERFORM append_error USING 'S'
                            '115'
                            sy-dbcnt
                            '/sie/hr_idp_s1vn'
                            space
                            space.
  DELETE FROM /sie/hr_idp_s1vt WHERE ifcid = db_data-s1-ifcid
                                   AND    vrsnr = last_version.
  PERFORM append_error USING 'S'
                            '115'
                            sy-dbcnt
                            '/sie/hr_idp_s1vt'
                            space
                            space.

  DELETE FROM /sie/hr_idp_s1pr WHERE ifcid = db_data-s1-ifcid
                                   AND    vrsnr = last_version.
  PERFORM append_error USING 'S'
                            '115'
                            sy-dbcnt
                            '/sie/hr_idp_s1pr'
                            space
                            space.


  DELETE FROM /sie/hr_idp_s1f WHERE ifcid = db_data-s1-ifcid
                                   AND    vrsnr = last_version.
  PERFORM append_error USING 'S'
                            '115'
                            sy-dbcnt
                            '/sie/hr_idp_s1f'
                            space
                            space.

  IF last_version = '0001'.
    DELETE FROM /sie/hr_idp_s1 WHERE ifcid = db_data-s1-ifcid.
    PERFORM append_error USING 'S'
                              '115'
                              sy-dbcnt
                              '/sie/hr_idp_s1'
                              space
                              space.
    DELETE FROM /sie/hr_idp_s1t WHERE ifcid = db_data-s1-ifcid.
    PERFORM append_error USING 'S'
                              '115'
                              sy-dbcnt
                              '/sie/hr_idp_s1t'
                              space
                              space.

    DELETE FROM /sie/hr_idp_s1lt WHERE ifcid = db_data-s1-ifcid.
    PERFORM append_error USING 'S'
                              '115'
                              sy-dbcnt
                              '/sie/hr_idp_s1lt'
                              space
                              space.

    DELETE FROM /sie/hr_idp_s1dl WHERE ifcid = db_data-s1-ifcid
                                 AND   vrsnr = last_version.
    PERFORM append_error USING 'S'
                              '115'
                              sy-dbcnt
                              '/sie/hr_idp_s1dl'
                              space
                              space.


    DELETE FROM /sie/hr_idp_s1sa WHERE ifcid = db_data-s1-ifcid.
    PERFORM append_error USING 'S'
                              '115'
                              sy-dbcnt
                              '/sie/hr_idp_s1sa'
                              space
                              space.

    DELETE FROM /sie/hr_idp_s1pc WHERE ifcid = db_data-s1-ifcid
                                     AND   vrsnr = last_version.
    PERFORM append_error USING 'S'
                              '115'
                              sy-dbcnt
                              '/sie/hr_idp_s1pc'
                              space
                              space.

  ELSE.
    last_version = last_version - 1.
    SELECT SINGLE FOR UPDATE *
                    FROM /sie/hr_idp_s1
                    WHERE ifcid = db_data-s1-ifcid.
    /sie/hr_idp_s1-act_vers_nr = last_version.

* Egal ob eine neue oder freigegebene Schnttstelle gerade gelöscht
* wird, eine neue Version wird es nicht geben, da die einzige neue
* Version die existieren könnte, gerade gelöscht wird und alle
* anderen Möglichkeiten keine neue Version zulassen.
    /sie/hr_idp_s1-new_version = no.
    MODIFY /sie/hr_idp_s1.
    PERFORM append_error USING 'S'
                              '116'
                               last_version
                              space
                              space
                              space.

  ENDIF.
  COMMIT WORK.

  g_rc = 8.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ENQUEUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM enqueue.

  CALL FUNCTION 'ENQUEUE_/SIE/HR_IDPIFCID'
       EXPORTING
            mode_/sie/hr_idp_s1 = 'E'
            mandt               = sy-mandt
            ifcid               = db_data-s1-ifcid
       EXCEPTIONS
            foreign_lock        = 1
            system_failure      = 2
            OTHERS              = 3.
  IF sy-subrc >< 0.
    g_rc = 8.
    PERFORM append_error USING 'E'
                               '114'
                               space
                               space
                               space
                               space.
  ENDIF.
ENDFORM.                    " ENQUEUE

*&---------------------------------------------------------------------*
*&      Form  DEQUEUE
*&---------------------------------------------------------------------*
FORM dequeue.

  CALL FUNCTION 'DEQUEUE_/SIE/HR_IDPIFCID'
       EXPORTING
            mode_/sie/hr_idp_s1 = 'E'
            mandt               = sy-mandt
            ifcid               = db_data-s1-ifcid
            _synchron           = 'X'.

ENDFORM.                    " DEQUEUE

INCLUDE /sie/hr_idp_err.
INCLUDE /sie/hr_idp_authority.
