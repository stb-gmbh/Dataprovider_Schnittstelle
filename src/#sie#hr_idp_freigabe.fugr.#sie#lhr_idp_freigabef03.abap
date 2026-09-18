*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_FREIGABEF03 .
*----------------------------------------------------------------------*

 DATA: G_WORK_EXCL_CMD TYPE TY_EXCMD
    , G_EXCL_COMMANDS TYPE TY_T_EXCMD.

 DEFINE EXCLUDE_COMMAND.
   G_WORK_EXCL_CMD-FUNC = &1.
   APPEND G_WORK_EXCL_CMD TO G_EXCL_COMMANDS.
   SET PF-STATUS 'RELEASE' EXCLUDING G_EXCL_COMMANDS IMMEDIATELY.
 END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Form  PLAUSI_CHECK_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM PLAUSI_CHECK_LIST.

   DATA: SW_WARNING TYPE TY_YESNO
       , SW_ERROR TYPE TY_YESNO
       .

   NEW-PAGE NO-TITLE LINE-SIZE 80.
   FORMAT COLOR COL_NORMAL INTENSIFIED ON.

   CLEAR G_EXCL_COMMANDS[].

*** WARNUNGEN ****
* Schnittstelle hat einen zu kurzen langtext oder gar keinen!
   PERFORM CHECK_LTEXT USING INT_INTERFACE
                             INT_VERSION
                       CHANGING SW_WARNING.

* Die Schnittstelle hat einen zu kurzen Kurztext.
   PERFORM CHECK_KTEXT USING INT_INTERFACE
                             INT_VERSION
                       CHANGING SW_WARNING.

* Das Endedatum ist nicht der 31.12. eines Jahres
   PERFORM CHECK_ENDDA USING INT_INTERFACE
                             INT_VERSION
                       CHANGING SW_WARNING.

* Der Lieferdatum der IFC ist zu kurz, unterschreitet eine Mindestanz.
* tage
   PERFORM CHECK_DURAT USING INT_INTERFACE
                             INT_VERSION
                       CHANGING SW_WARNING.

* Auch bei manuell geschriebenen Schnittstellen sollte der Feldkatalog
* spezifiert worden sein.
   PERFORM CHECK_FCATA USING INT_INTERFACE
                             INT_VERSION
                       CHANGING SW_WARNING.

* Die Schnittstelle hat nur eine Minimale Anzahl Felder
   PERFORM CHECK_FIELDS USING INT_INTERFACE
                             INT_VERSION
                       CHANGING SW_WARNING.

* Auch bei Manuell erstellten IFC sind die Selektionen anzugeben
   PERFORM CHECK_SELEC USING INT_INTERFACE
                             INT_VERSION
                       CHANGING SW_WARNING.

* Verrechnungsinformationen
   PERFORM CHECK_PRICING USING INT_INTERFACE
                             INT_VERSION
                       CHANGING SW_WARNING.

* Die UC4 Emails sollten auch gepflegt worden sein.
   PERFORM CHECK_UC4_EMAIL USING INT_INTERFACE
                           INT_VERSION
                     CHANGING SW_WARNING.

**** FEHLER ****
* Die Schnittstelle hat keine Berechtigungsklasse
   PERFORM CHECK_AUTHC USING INT_INTERFACE
                             INT_VERSION
                       CHANGING SW_ERROR.

* Der Logische Dateiname sollte angegeben worden sein.
   PERFORM CHECK_LOGFILENAME USING INT_INTERFACE
                                   INT_VERSION
                             CHANGING SW_ERROR.

* Der R/3 User unter dem die Schnittstelle laufen soll fehlt.
   PERFORM CHECK_R3USER USING INT_INTERFACE
                             INT_VERSION
                       CHANGING SW_ERROR.

* Bei manuell erstellten Programmen sollte das Programm existieren
* und Typ 1, bzw. LDB PNP sein.
   PERFORM CHECK_MANUAL USING INT_INTERFACE
                             INT_VERSION
                       CHANGING SW_ERROR.

* Bei manuell erstellten Schnittstellen sind die Programme nicht
* syntaktisch korrekt
   PERFORM CHECK_SYNTAX USING INT_INTERFACE
                              INT_VERSION
                        CHANGING SW_ERROR.

* Die UC4 Parameter sollten alle gepflegt worden sein.
   PERFORM CHECK_UC4 USING INT_INTERFACE
                           INT_VERSION
                     CHANGING SW_ERROR.


* Bei verschiedenen Satzarten sind nur bestimmte Felder erlaubt
   PERFORM CHECK_RECNA USING INT_INTERFACE
                                 INT_VERSION
                        CHANGING SW_ERROR.

* Bei Varianten: es wird eine Variante angegeben, die nicht existiert
* oder es wird eine Variante angegeben, aber es gibt keine Selektions-
* felder, etc.
   PERFORM CHECK_VARIANTS USING INT_INTERFACE
                                INT_VERSION
                         CHANGING SW_ERROR.

* Bei bestimmten Satzarten sind Singuläre Felder nicht erlaubt
   PERFORM CHECK_SINGULARITIES USING INT_INTERFACE
                                     INT_VERSION
                               CHANGING SW_ERROR.

* Bei Filter sind nur Satzarteigene Felder erlaubt
   PERFORM CHECK_FIELDS_RECTY USING INT_INTERFACE
                                     INT_VERSION
                               CHANGING SW_ERROR.


* Ende des findens aller Probleme und Warnungen.

   SKIP.
   IF SW_ERROR = YES.
     WRITE: / ICON_MESSAGE_CRITICAL AS ICON,
         'Es wurden Fehler in der Schnittstellendefinition gefunden.'.
     WRITE: / 'Die Schnittstelle kann nicht freigegeben werden.'.
     EXCLUDE_COMMAND 'SAVE'.
     EXCLUDE_COMMAND 'TEST'.
   ELSE.
     IF SW_WARNING = YES.
       WRITE: / ICON_MESSAGE_WARNING,
                'Es liegen Warnungen vor.'.
       IF  G_SW_RELEASE_DIALOG = NO.
         EXCLUDE_COMMAND 'SAVE'.
              EXCLUDE_COMMAND 'TEST'.
       ENDIF.
     ELSE.
       WRITE: / ICON_OKAY AS ICON,
                'Es liegen keine Warnungen oder Fehler vor'.
       IF  G_SW_RELEASE_DIALOG = NO.
         EXCLUDE_COMMAND 'SAVE'.
         EXCLUDE_COMMAND 'TEST'.
       ENDIF.
     ENDIF.
     IF  G_SW_RELEASE_DIALOG = YES.
       IF G_SW_TEST = YES.
         ULINE.
         WRITE: 'Durch drücken der Testen-Ikone'(AUS),
                 ICON_TEST AS ICON,
                'wird die Schnittstelle ausgeführt'(UUA).
       ELSE.
         ULINE.
         WRITE: 'Durch drücken der Sichern-Ikone'(UUS),
                 ICON_SYSTEM_SAVE AS ICON,
                'wird die Schnittstelle freigegeben'(UUF).
       ENDIF.
     ENDIF.
   ENDIF.
   FORMAT RESET.
   SW_RELEASE_BUTTON = NO.   " Nicht sichern.

 ENDFORM.                    " PLAUSI_CHECK_LIST

*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM USER_COMMAND.

   DATA: IT_RSPARAMS TYPE STANDARD TABLE OF RSPARAMS INITIAL SIZE 0
         WITH HEADER LINE.

   SVCODE = OKCODE.
   CLEAR OKCODE.

   CASE SVCODE.
     WHEN 'SAVE' OR 'TEST'.
       SW_RELEASE = YES.
       SET SCREEN 0. LEAVE SCREEN.
     WHEN 'CANC'.
       SW_RELEASE = NO.
       SET SCREEN 0. LEAVE SCREEN.
     WHEN 'CONT'.
       CLEAR IT_RSPARAMS[].
       IT_RSPARAMS-SELNAME = 'S_IFCID'.
       IT_RSPARAMS-KIND = 'S'.
       IT_RSPARAMS-SIGN = 'I'.
       IT_RSPARAMS-OPTION = 'EQ'.
       IT_RSPARAMS-LOW = INT_INTERFACE-S1-IFCID.
       IT_RSPARAMS-HIGH = SPACE.
       APPEND IT_RSPARAMS.
       IT_RSPARAMS-SELNAME = 'S_VRSNR'.
       IT_RSPARAMS-KIND = 'S'.
       IT_RSPARAMS-SIGN = 'I'.
       IT_RSPARAMS-OPTION = 'EQ'.
       IT_RSPARAMS-LOW = INT_INTERFACE-S1VN-VRSNR.
       IT_RSPARAMS-HIGH = SPACE.
       APPEND IT_RSPARAMS.
       IT_RSPARAMS-SELNAME = 'P_PARM7'.
       IT_RSPARAMS-KIND = 'P'.
       IT_RSPARAMS-SIGN = 'I'.
       IT_RSPARAMS-OPTION = 'EQ'.
*      it_rsparams-low = int_interface-s1vn-vrsnr.
       IT_RSPARAMS-LOW = YES.
       IT_RSPARAMS-HIGH = SPACE.
       APPEND IT_RSPARAMS.
       IT_RSPARAMS-SELNAME = 'P_PARM8'.
       IT_RSPARAMS-KIND = 'P'.
       IT_RSPARAMS-SIGN = 'I'.
       IT_RSPARAMS-OPTION = 'EQ'.
       IT_RSPARAMS-LOW = YES.
       IT_RSPARAMS-HIGH = SPACE.
       APPEND IT_RSPARAMS.

       SUBMIT /SIE/HR_IDP_PRINT_INTERFACE
              WITH SELECTION-TABLE IT_RSPARAMS
              AND RETURN.
     WHEN OTHERS.
   ENDCASE.

 ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ENQ_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE_S1DF_PROGR  text
*----------------------------------------------------------------------*
 FORM ENQ_REPORT USING P_INTERFACE_S1DF_PROGR TYPE PROGRAMM.

   CALL FUNCTION 'ENQUEUE_E_TRDIR'
        EXPORTING
             NAME           = P_INTERFACE_S1DF_PROGR
        EXCEPTIONS
             FOREIGN_LOCK   = 1
             SYSTEM_FAILURE = 2
             OTHERS         = 3.
   CASE SY-SUBRC.
     WHEN 0.
     WHEN 1.
* Überprüfen, ob der Benutzer sich selbst sperrt oder nicht.
       IF SY-MSGV1 = SY-UNAME.
         MESSAGE E122 WITH SY-MSGV1 SPACE SPACE SPACE
                         RAISING ENQUEUE.
       ELSE.
         MESSAGE E121 WITH TEXT-901
                           P_INTERFACE_S1DF_PROGR
                           SY-MSGV1 SPACE
                         RAISING ENQUEUE.
       ENDIF.
     WHEN OTHERS.
       MESSAGE E121 WITH TEXT-901
                         P_INTERFACE_S1DF_PROGR
                         SY-MSGV1 SPACE
                       RAISING ENQUEUE.
   ENDCASE.

 ENDFORM.                    " ENQ_REPORT

*&---------------------------------------------------------------------*
*&      Form  DEQ_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE_S1DF_PROGR  text
*----------------------------------------------------------------------*
 FORM DEQ_REPORT USING P_INTERFACE_S1DF_PROGR TYPE PROGRAMM.

   CALL FUNCTION 'DEQUEUE_E_TRDIR'
        EXPORTING
             NAME = P_INTERFACE_S1DF_PROGR.

 ENDFORM.                    " DEQ_REPORT
