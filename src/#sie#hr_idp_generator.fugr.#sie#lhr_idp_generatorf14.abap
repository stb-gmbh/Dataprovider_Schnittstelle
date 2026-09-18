*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_GENERATORF14 .
*----------------------------------------------------------------------*

FORM PROCESS_LOG_DECLARATIONS.

  DATA:
    TAG       TYPE /SIE/HR_IDP_TT_CODING.

  PERFORM GET_TAG USING 'log_decla' CHANGING TAG.
  PERFORM INSERT_CODE USING TAG.

*$<log_decla>
*$
*$ tables: /sie/hr_idp_s1l
*$       , /sie/hr_idp_s1p
*$       , /sie/hr_idp_s1s
*$       .
*$
*$   types: ty_yesno type xfeld.
*$     constants: yes type ty_yesno value 'X'
*$              , no  type ty_yesno value space
*$              .
*$
*$ data: selpn type /sie/hr_idp_selpn   " Anzahl selektierte Personen
*$     , numbr type /sie/hr_idp_numbr   " Anzahl Sätze
*$     , _begda type begda               " Beginn Datum
*$     , _beguz type beguz               " Beginn Uhrzeit
*$     , seqno type /sie/hr_idp_seqno   " Aktuelle Laufnummer
*$     , fl_email type xflag            " Falls email Versendet wurd
*$     , fl_error type xflag            " Falls Fehler entdesckt wurde
*$     , fl_log type xflag              " Falls Protokollmeldungen
*$     , fl_testlf type xfeld           " Falls Testlauf
*$     , g_s1s type standard table of /sie/hr_idp_s1s
*$             initial size 0
*$             with header line
*$     , g_s1l_idx type i
*$     .
*$</log_decla>
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_SOS_STAT                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_IFCID                                                       *
*---------------------------------------------------------------------*
FORM PROCESS_SOS_STAT USING P_IFCID TYPE /SIE/HR_IDP_INTERFACE_ID.

  DATA:
     TAG     TYPE /SIE/HR_IDP_TT_CODING,
     RESULT  TYPE /SIE/HR_IDP_TT_CODING.

  PERFORM GET_TAG USING 'sos_stat' CHANGING TAG.
  PERFORM REPLACE_PARAM USING 'IFCID'
                               P_IFCID
                               TAG
                        CHANGING RESULT.

  PERFORM INSERT_CODE USING RESULT.

*$<sos_stat>
*$   get time.
*$   perform init_statistics using '&IFCID'.
*$</sos_stat>
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_PERNR_STAT                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM PROCESS_PERNR_STAT USING P_IFCID TYPE /SIE/HR_IDP_INTERFACE_ID.

  DATA:
    RESULT    TYPE /SIE/HR_IDP_TT_CODING,
    TAG       TYPE /SIE/HR_IDP_TT_CODING.

  PERFORM GET_TAG USING 'pernr_stat' CHANGING TAG.
  PERFORM REPLACE_PARAM USING 'IFCID'
                               P_IFCID
                               TAG
                      CHANGING RESULT.

  PERFORM INSERT_CODE USING RESULT.

*$<pernr_stat>
*$ add 1 to g_pernrcount.
*$ perform update_statistics using '&IFCID'
*$                                 p0001-juper
*$                                 p0001-werks
*$                                 p0001-zzbreinh.
*$</pernr_stat>
ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_EOS_STAT                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_IFCID                                                       *
*  -->  P_VRSNR                                                       *
*---------------------------------------------------------------------*
FORM PROCESS_EOS_STAT USING P_IFCID TYPE /SIE/HR_IDP_INTERFACE_ID
                            P_VRSNR TYPE /SIE/HR_IDP_VERS_NR.

  DATA:
     TAG     TYPE /SIE/HR_IDP_TT_CODING,
     INPUT   TYPE /SIE/HR_IDP_TT_CODING,
     RESULT  TYPE /SIE/HR_IDP_TT_CODING.

  PERFORM GET_TAG USING 'eos_stat' CHANGING TAG.
  PERFORM REPLACE_PARAM USING 'IFCID'
                               P_IFCID
                               TAG
                        CHANGING RESULT.
  MOVE RESULT[] TO INPUT[].
  PERFORM REPLACE_PARAM USING 'VRSNR'
                               P_VRSNR
                               INPUT
                        CHANGING RESULT.

  PERFORM INSERT_CODE USING RESULT.

*$<eos_stat>
*$  get time.
*$  perform write_statistics using '&IFCID'
*$                                 '&VRSNR'
*$                                 sy-slset
*$                                 sy-uname.
*$</eos_stat>
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PROCESS_LOG_INCLUDE
*&---------------------------------------------------------------------*
*       Generiert Forms zur Protokollierung und Statistik
*----------------------------------------------------------------------*
FORM PROCESS_LOG_INCLUDE.

  DATA:
    TAG       TYPE /SIE/HR_IDP_TT_CODING.

  PERFORM GET_TAG USING 'logforms' CHANGING TAG.
  PERFORM INSERT_CODE USING TAG.

*$<logforms>
*$ form init_statistics
*$                 using value(p_ifcid) type /sie/hr_idp_interface_id.
*$
*$   data: l_s1p like /sie/hr_idp_s1p.
*$
*$   _begda = sy-datum.
*$   _beguz = sy-uzeit.
*$
*$   clear: selpn, numbr, seqno, fl_email, fl_error, g_s1s[].
*$
* call function 'ENQUEUE_/SIE/HR_IDP_PROT'
*    exporting
*         mode_/sie/hr_idp_s1p = 'E'
*         mandt                = sy-mandt
*         ifcid                = p_ifcid
*         _WAIT                = 'X'
*    EXCEPTIONS
*         FOREIGN_LOCK         = 1
*         SYSTEM_FAILURE       = 2
*         OTHERS               = 3
*          .
*if sy-subrc <> 0.
* perform compose_message using p_ifcid.
* exit.
*endif.
*$
*$   select max( seqno ) from /sie/hr_idp_s1p
*$          into /sie/hr_idp_s1p-seqno
*$          where ifcid = p_ifcid.
*$
*$   seqno = /sie/hr_idp_s1p-seqno + 1.
*$
*   clear /sie/hr_idp_s1p.
*   /SIE/HR_IDP_s1p-mandt = sy-mandt.
*   /SIE/HR_IDP_s1p-ifcid = p_ifcid.
*   /SIE/HR_IDP_s1p-seqno = seqno.
*   insert /sie/hr_idp_s1p.
*   commit work.
*
* call function 'DEQUEUE_/SIE/HR_IDP_PROT'
*    EXPORTING
*         MODE_/SIE/HR_IDP_S1P = 'E'
*         MANDT                = SY-MANDT
*         IFCID                = p_ifcid.
*
*$   g_s1l_idx = 0.
*$
*$ if P_adhoc = 'X'.
*$ perform set_testlf.
*$ endif.
*$
*$ endform.                    " INIT_STATS
*$
*$ form update_statistics    " AUFRUF GET PERNR
*$    using value(p_ifcid) type /sie/hr_idp_interface_id
*$          value(p_juper) type juper
*$          value(p_werks) type persa
*$          value(p_brein) type /sie/hr_pm_breinh.
*$
*$   numbr = numbr + 1.
*$
*$   perform fill_s1s using p_ifcid
*$                          p_juper
*$                          p_werks
*$                          p_brein.
*$
*$ endform.                    " UPDATE_STATISTICS
*$
*$ form write_statistics   " END OF SELECTION
*$                  using value(p_ifcid) type /sie/hr_idp_interface_id
*$                        value(p_vrsnr) type /sie/hr_idp_vers_nr
*$                        value(p_varia) type variant
*$                        value(p_uc4nam) type /sie/hr_idp_uc4_uname.
*$
*$   perform write_s1s.
*$   perform write_s1p using p_ifcid p_vrsnr p_varia p_uc4nam.
*$
*$ endform.                    " WRITE_STATS
*$
*$form append_log using value(p_ifcid) type /sie/hr_idp_interface_id
*$                     value(p_logtp) type /sie/hr_idp_logtp
*$                     value(p_text) type text60.
*$
*$  clear /sie/hr_idp_s1l.
*$
*$  g_s1l_idx = g_s1l_idx + 1.
*$
*$  /sie/hr_idp_s1l-ifcid = p_ifcid.
*$  /sie/hr_idp_s1l-seqno = seqno.
*$  /sie/hr_idp_s1l-subsq = g_s1l_idx.
*$  /sie/hr_idp_s1l-logtp = p_logtp.
*$  /sie/hr_idp_s1l-text = p_text.
*$
*$  perform set_log.
*$
*$  insert /sie/hr_idp_s1l.
*$
*$  commit work.
*$
*$endform.
*$
*$form set_testlf.
*$ fl_testlf = 'X'.
*$endform.
*$
*$form set_error.
*$  fl_error = 'X'.
*$endform.
*$
*$form set_email.
*$  fl_email = 'X'.
*$endform.
*$
*$ form set_log.
*$  fl_log = 'X'.
*$ endform.
*$
*$ form write_s1p using value(p_ifcid) type /sie/hr_idp_interface_id
*$                      value(p_vrsnr) type /sie/hr_idp_vers_nr
*$                      value(p_varia) type variant
*$                      value(p_uc4nam) type /sie/hr_idp_uc4_uname.
*$
*$   /sie/hr_idp_s1p-mandt = sy-mandt.
*$   /sie/hr_idp_s1p-ifcid = p_ifcid.
*$   /sie/hr_idp_s1p-beguz = _beguz.
*$   /sie/hr_idp_s1p-enduz = sy-uzeit.
*$   /sie/hr_idp_s1p-begda = _begda.
*$   /sie/hr_idp_s1p-endda = sy-datum.
*$   /sie/hr_idp_s1p-numbr = numbr.
*$   /sie/hr_idp_s1p-seqno = seqno.
*$   /sie/hr_idp_s1p-ifcid = p_ifcid.
*$   /sie/hr_idp_s1p-varia = p_varia.
*$   /sie/hr_idp_s1p-progr = sy-repid.
*$   /sie/hr_idp_s1p-vrsnr = p_vrsnr.
*$   /sie/hr_idp_s1p-error = fl_error.
*$   /sie/hr_idp_s1p-email = fl_email.
*$   /sie/hr_idp_s1p-pfnam = dsn.
*$   /SIE/HR_IDP_s1p-swlog = fl_log.
*$   /sie/hr_idp_s1p-uc4nam = p_uc4nam.
*$   /SIE/HR_IDP_s1p-filesz = g_filesize.
*$   /SIE/HR_IDP_s1p-testlf = fl_testlf.
*$
*   delete from /sie/hr_idp_s1p where ifcid = p_ifcid
*                          and   seqno = seqno
*                          and   begda is NULL.
*
*$   insert into /sie/hr_idp_s1p values /sie/hr_idp_s1p.
*$   commit work.
*$ endform.
*$
*$ form fill_s1s using value(p_ifcid) type /sie/hr_idp_interface_id
*$                     value(p_juper) type juper
*$                     value(p_werks) type persa
*$                     value(p_brein) type /sie/hr_pm_breinh.
*$
*$   /sie/hr_idp_s1s-mandt = sy-mandt.
*$   /sie/hr_idp_s1s-ifcid = p_ifcid.
*$   /sie/hr_idp_s1s-selpn = 1.
*$   /sie/hr_idp_s1s-juper = p_juper.
*$   /sie/hr_idp_s1s-werks = p_werks.
*$   /sie/hr_idp_s1s-brein = p_brein.
*$   /sie/hr_idp_s1s-seqno = seqno.
*$
*$   collect /sie/hr_idp_s1s into g_s1s.
*$
*$ endform.                                                    " FILL_S1
*$
*$  form write_s1s.
*$
*$    data: l_s1s type /sie/hr_idp_s1s.
*$
*$    describe table g_s1s.
*$    check sy-tfill > 0.
*$
*$    loop at g_s1s into l_s1s.
*$      l_s1s-subsq = sy-tabix.
*$      modify g_s1s from l_s1s index sy-tabix.
*$    endloop.
*$
*$    insert /sie/hr_idp_s1s from table g_s1s.
*$    commit work.
*$
*$  endform.
*$ form compose_message using p_ifcid type /sie/hr_idp_interface_id.
*$
*$   data: message_text like sy-lisel.
*$
*$   call function 'RPY_MESSAGE_COMPOSE'
*$        exporting
*$             message_id        = sy-msgid
*$             message_number    = sy-msgno
*$             message_var1      = sy-msgv1
*$             message_var2      = sy-msgv2
*$             message_var3      = sy-msgv3
*$             message_var4      = sy-msgv4
*$        importing
*$             message_text      = message_text
*$        exceptions
*$             message_not_found = 1
*$             others            = 2.
*$   if sy-subrc <> 0.
*$     perform append_log using p_ifcid
*$                               sy-msgty
*$                               'Unbekannte Systemnachricht!'.
*$   else.
*$     perform append_log using p_ifcid
*$                               sy-msgty
*$                               message_text(60).
*$   endif.
*$
*$ endform.
*$
*$</logforms>
ENDFORM.                    " PROCESS_LOG_INCLUDE

*---------------------------------------------------------------------*
*       FORM PROCESS_TESTLAUF                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM PROCESS_TESTLAUF.
  DATA:
    TAG       TYPE /SIE/HR_IDP_TT_CODING.

  PERFORM GET_TAG USING 'testlauf' CHANGING TAG.
  PERFORM INSERT_CODE USING TAG.
*$<testlauf>
*$perform set_testlf.
*$</testlauf>
ENDFORM.
