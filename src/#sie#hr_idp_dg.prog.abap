*&---------------------------------------------------------------------*
*& Report  /SIE/HR_IDP_DG                                              *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*Änderungen: 18.10.2002 Hierl SIE001: unterschiedliche Schlüssel je
*                                     Satzart; Trennzeichen bei Header
*                                     von Pos1 nach Ende verschoben;
*                                     Keine Testdateien berücksichtigen
*            15.11.2002 Hierl SIE002: fehlende/doppelte Sätze korrigiert
*            06.12.2002 Hierl SIE003: Delete&Insert gleicher Sätze
*                                     PrimärKey-Behandlung eingebaut
*            10.12.2002 Hierl SIE004: Delete&Insert gleicher Sätze
*                                     Keytrenner eingebaut
*            10.01.2003 Hierl SIE005: löschen der letzten 6 Zeichen
*                                     im Referenzdateinamen, wenn
*                                     manuelle Schnittstelle
*                                     (werden über Par-Datei gestartet)
*            24.02.2003 Hierl SIE006: Initiallieferung bei fehlender
*                                     Referenzdatei aus SAP-DP
*            13.11.2003 Hierl SIE007: Korrekturen bei FIX-Format:
*                                      -Seperator beim Deltakennzeichen
*                                      -Satzartenlängeimmer 8 Stellen
*                                     SLF #900020318
*            26.03.2004 Hierl SIE008: Fehler bei neuen/gelöschten
*                                     Satzarten korrigiert
*                                     SLF #900021287
*            19.04.2004 Hierl SIE009: weiterer Fehler bei mehr als
*                                     einer neuen/gelöschten Satzart
*                                     korrigiert   SLF #900021287
*          20070522 Hannemann HAN001: FUBAs ws_upload und ws_download
*                                     sind als veraltet gekenzeichnet
*                                     und deswegen ausgetauscht
*          20141023 Lauer     ML001:  Unicode-Umstellung (INC5560081)

REPORT  /sie/hr_idp_dg.

*
* Globale Daten
*

TABLES:
   /sie/hr_iss_stat.

DATA:
   lfile LIKE            filename-fileintern,
   pfile(100)            TYPE c,
   s_tmp(120)            TYPE c,
   pcount                TYPE i,
   csv_separator(1)      TYPE c VALUE ';',
   csv_separatorc(1)     TYPE c VALUE ';',
   csv_separatorl(1)     TYPE c VALUE ';',
   keysep(1)             TYPE c VALUE '!',                  "SIE004
   kennung_insert(1)     TYPE c VALUE 'I',
   kennung_delete(1)     TYPE c VALUE 'D',
   kennung_update(1)     TYPE c VALUE 'U',
   global_debug(1)       TYPE c,
   len_satzart           TYPE i VALUE '8'.                  "SIE007

DATA:
   num_skippers(8)       TYPE n,
   num_personsl(8)       TYPE n,
   num_personsc(8)       TYPE n,
   num_personsw(8)       TYPE n,
   num_linesl(8)         TYPE n,
   num_linesc(8)         TYPE n,
   num_unskipped(8)      TYPE n,
   num_changed(8)        TYPE n,
   num_errors(8)         TYPE n.


*
* Definition des Selektionsschirms.
*

SELECTION-SCREEN SKIP.
SELECTION-SCREEN COMMENT 1(60) text-001.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN COMMENT 1(40) text-002.
SELECTION-SCREEN SKIP.

* Parameter über Schnittstelle
SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE text-006.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
   pdoint             RADIOBUTTON GROUP rb1 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 3(25) tdoint.
SELECTION-SCREEN COMMENT 28(11) tnameint.
SELECTION-SCREEN POSITION 39.
PARAMETERS:
   pnameint           TYPE /sie/hr_idp_interface_id.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.                             "SIE001
PARAMETERS:                                                 "SIE001
   ptstfile              AS CHECKBOX.                       "SIE001
SELECTION-SCREEN COMMENT 3(25) ttstfile.                    "SIE001
SELECTION-SCREEN END OF LINE.                               "SIE001
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
   pdoext             RADIOBUTTON GROUP rb1.
SELECTION-SCREEN COMMENT 3(25) tdoext.
SELECTION-SCREEN COMMENT 28(11) tnameext.
SELECTION-SCREEN POSITION 39.
PARAMETERS:
   pnameext           TYPE /sie/hr_iiftyp.
SELECTION-SCREEN COMMENT 57(11) tparapf.
SELECTION-SCREEN POSITION 68.
PARAMETERS:
   pparain(200)       TYPE c LOWER CASE VISIBLE LENGTH 10.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
   pparalog         AS CHECKBOX       DEFAULT 'X'.
SELECTION-SCREEN COMMENT 3(25) tparalog.
SELECTION-SCREEN COMMENT 28(11) tparain.
SELECTION-SCREEN POSITION 39.
PARAMETERS:
   fparain(256)     TYPE c LOWER CASE  VISIBLE LENGTH 39
                                      DEFAULT '/SIE/HR_IDP_DG_PARAM'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
   pdofile            RADIOBUTTON GROUP rb1.
SELECTION-SCREEN COMMENT 3(30) tdofile.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b0.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-003.

* Aktuelle Eingabedatei
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) tfilec.
*SELECTION-SCREEN COMMENT 28(10) tfilecp.
*SELECTION-SCREEN POSITION 39.
*PARAMETERS:
*   pcurrpr1(200)         TYPE c LOWER CASE VISIBLE LENGTH 18,
*   pcurrpr2(200)         TYPE c LOWER CASE VISIBLE LENGTH 18.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
   pcurrlog         AS CHECKBOX       DEFAULT 'X'.
SELECTION-SCREEN COMMENT 3(25) tcurrlog.
SELECTION-SCREEN COMMENT 28(11) tcurrin.
SELECTION-SCREEN POSITION 39.
PARAMETERS:
   fcurrin(256)     OBLIGATORY TYPE c LOWER CASE  VISIBLE LENGTH 39
                                      DEFAULT '/SIE/HR_IDP_DG_CURRENT'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 1.
PARAMETERS:
   pcopyloc         AS CHECKBOX       DEFAULT ' '.
SELECTION-SCREEN COMMENT 3(25) tcopyloc.
SELECTION-SCREEN COMMENT 28(11) tfileloc.
SELECTION-SCREEN POSITION 39.
PARAMETERS:
   pfileloc(80)     TYPE c            LOWER CASE VISIBLE LENGTH 39
                                      DEFAULT 'c:\curr.txt'.
SELECTION-SCREEN END OF LINE.

* Letzte Eingabedatei
SELECTION-SCREEN SKIP 2.
SELECTION-SCREEN COMMENT 1(30) tfilel.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
   plastlog         AS CHECKBOX       DEFAULT 'X'.
SELECTION-SCREEN COMMENT 3(25) tlastlog.
SELECTION-SCREEN COMMENT 28(11) tlastin.
SELECTION-SCREEN POSITION 39.
PARAMETERS:
   flastin(256)     TYPE c LOWER CASE VISIBLE LENGTH 39
                                      DEFAULT '/SIE/HR_IDP_DG_LAST'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 1.
PARAMETERS:
   pcopylol         AS CHECKBOX       DEFAULT ' '.
SELECTION-SCREEN COMMENT 3(25) tcopylol.
SELECTION-SCREEN COMMENT 28(11) tfilelol.
SELECTION-SCREEN POSITION 39.
PARAMETERS:
   pfilelol(80)     TYPE c            LOWER CASE VISIBLE LENGTH 39
                                      DEFAULT 'c:\last.txt'.
SELECTION-SCREEN END OF LINE.

* Deltadatei
SELECTION-SCREEN SKIP 2.
SELECTION-SCREEN COMMENT 1(30) tfiled.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
   pdeltlog         AS CHECKBOX       DEFAULT 'X'.
SELECTION-SCREEN COMMENT 3(25) tdeltlog.
SELECTION-SCREEN COMMENT 28(11) tfiledel.
SELECTION-SCREEN POSITION 39.
PARAMETERS:
   fdeltout(256)    OBLIGATORY TYPE c LOWER CASE VISIBLE LENGTH 39
                                      DEFAULT '/SIE/HR_IDP_DG_DELTA'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 1.
PARAMETERS:
   pcopylod         AS CHECKBOX       DEFAULT ' '.
SELECTION-SCREEN COMMENT 3(25) tcopylod.
SELECTION-SCREEN COMMENT 28(11) tfilelod.
SELECTION-SCREEN POSITION 39.
PARAMETERS:
   pfilelod(80)     TYPE c            LOWER CASE VISIBLE LENGTH 39
                                      DEFAULT 'c:\delta.txt'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b1.

* Optionen
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-004.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 1.
PARAMETERS:
   showmsg          AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT 3(22) tshowmsg.
SELECTION-SCREEN POSITION 33.
PARAMETERS:
   showsame         AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN COMMENT 35(23) tshowsam.
SELECTION-SCREEN POSITION 58.
PARAMETERS:
   chksort          AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN COMMENT 60(18) tchksort.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b2.

* Testunterstützung
SELECTION-SCREEN BEGIN OF BLOCK b6 WITH FRAME TITLE text-005.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 1.
PARAMETERS:
   showlist         AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN COMMENT 3(22) tshowlis.
SELECTION-SCREEN POSITION 33.
PARAMETERS:
   detailcu         AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN COMMENT 35(20) tdetailc.
SELECTION-SCREEN POSITION 58.
PARAMETERS:
   detailla         AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN COMMENT 60(20) tdetaill.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 1.
PARAMETERS:
   showsart         AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN COMMENT 3(22) tshowart.
SELECTION-SCREEN POSITION 33.
PARAMETERS:
   showhetr         AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN COMMENT 35(25) tshowhet.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(32) tdebug1.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS:
   firstkey(40)      TYPE c DEFAULT ''  VISIBLE LENGTH 10.
SELECTION-SCREEN COMMENT 44(13) tdebug2.
SELECTION-SCREEN POSITION POS_HIGH.
PARAMETERS:
   lastkey(40)      TYPE c DEFAULT ''  VISIBLE LENGTH 10.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b6.


* Initialisierung
INITIALIZATION.
  tdoint    = 'Parameter aus SAP DP'.
  ttstfile  = 'Testläufe berücksichtigen'.                  "SIE001
  tdoext    = 'Parameter aus Par.-Datei'.
  tdofile   = 'Dateien separat spezifiziert'.
  tnameint  = 'Schnittst.:'.
  tnameext  = 'Schnittst.:'.
  tparalog  = 'Logischer Name'.
  tparapf   = 'Pfad (opt.)'.
  tparain   = 'Dateiname :'.
  tfilec    = 'Aktuelle Eingabedatei'.
  tcurrlog  = 'Logischer Name'.
  tcurrin   = 'Dateiname :'.
  tfilel    = 'Referenzierte Eingabedatei'.
  tlastlog  = 'Logischer Name'.
  tlastin   = 'Dateiname :'.
  tcopyloc  = 'Kopiere von lokaler Datei'.
  tfileloc  = 'Dateiname :'.
  tcopylol  = 'Kopiere von lokaler Datei'.
  tfilelol  = 'Dateiname :'.
  tfiled    = 'Delta-Datei'.
  tdeltlog  = 'Logischer Name'.
  tfiledel  = 'Dateiname :'.
  tcopylod  = 'Kopiere zu lokaler Datei'.
  tfilelod  = 'Dateiname :'.

  tshowmsg  = 'Meldungen anzeigen'.
  tshowsam  = 'Unveränd. Zeilen anzei.'.
  tchksort  = 'Sortierung prüfen'.

  tdebug1   = 'Satzselektion:  Von Schlüssel'.
  tdebug2   = 'bis Schlüssel'.
  tshowlis  = 'Ausgabe anzeigen'.
  tdetailc  = 'Aktuelle anzeigen'.
  tdetaill  = 'Referenzierte anzei.'.
  tshowart  = 'Satzarten auflisten'.
  tshowhet  = 'Header/Trailer auflisten'.




*
* Hauptprogramm
*
START-OF-SELECTION.

* Initalisierung
  PERFORM init_all.

* Paramter aus Schnittstelle per FuBa ermitteln.
  IF pdoint = 'X'.
* Zur Anpassung an Konvention des FuBa
    DATA:
       lnameint        TYPE /sie/hr_idp_interface_id,
       lfcurrin(256)   TYPE c,
       lflastin(256)   TYPE c,
       lfdeltout(256)  TYPE c,
       maxlines        TYPE i.

    CLEAR fparain.
    lnameint = pnameint.
    IF 1 = 2.
      WRITE: '*** FuBa zum SAPDP noch nicht unterstützt! ***'.
      ADD 1 TO num_errors.
    ELSE.
      IF lnameint IS INITIAL.
        SKIP.
        WRITE: / 'Schnittstelle muss angegeben werden!'.
        ADD 1 TO num_errors.
        EXIT.
      ELSE.
        CALL FUNCTION '/SIE/HR_IDP_GETFILES'
          EXPORTING
            interface           = lnameint
            incl_testfiles      = ptstfile
            allow_initial       = 'X'
          IMPORTING
            current             = lfcurrin
            previous            = lflastin
          EXCEPTIONS
            interface_not_found = 1
            not_delta           = 2
            cannot_compute      = 3
            OTHERS              = 9.
        IF sy-subrc <> 0.
          WRITE: / 'Fehler bei Parameterermittlung:', sy-subrc.
          ADD 1 TO num_errors.
        ELSE.
          fcurrin     = lfcurrin.
          flastin     = lflastin.
          CONCATENATE fcurrin '.delta'  INTO fdeltout.
          CLEAR:      pcurrlog, plastlog, pdeltlog.
        ENDIF.
      ENDIF.
    ENDIF.

* Parameter aus externer Parameterdatei
  ELSEIF pdoext = 'X'.

* Dateien separat spezifiziert
  ELSE.
    CLEAR fparain.
  ENDIF.

* Dateinamen überprüfen.
  IF fcurrin IS INITIAL.
    WRITE: / 'Keine aktuelle Datei angegeben'.
    ADD 1 TO num_errors.
  ENDIF.

* Umsetzung durchführen
  IF num_errors = 0.
    IF firstkey(1) = '#'.
      CLEAR firstkey.
      global_debug = 'X'.
    ENDIF.
    IF firstkey(1) = '*'.
      maxlines = firstkey+1.
      WRITE: / 'Debug: Abbruchkriterien bei', maxlines, 'Zeilen.'.
      CLEAR firstkey.
    ENDIF.
    IF pparalog IS INITIAL AND NOT fparain IS INITIAL.
      CONCATENATE pparain fparain INTO fparain.
    ENDIF.
    PERFORM compare_files
       USING
          fcurrin            " Name der aktuellen Datei
          flastin            " Name der vor-aktuellen Datei
          fdeltout           " Name der zu erzeugenden Delta-Datei
          fparain
          pcurrlog           " Kennzeichen für logische Dateinamen
          plastlog
          pdeltlog
          pparalog
          pnameext
          firstkey           " Schlüssel des ersten Satzes
          lastkey            " Schlüssel des letzten Satzes
          showlist           " Ergebnis(Datei) anzeigen
          showmsg            " Nachrichten anzeigen
          showsame           " Unveränderte Zeilen anzeigen
          maxlines.          " Maximale Anzahl Zeilen
  ENDIF.


*
* Unterprogramme
*


*
FORM write_delta_out TABLES buffer USING pfileout.
  LOOP AT buffer.
* Zeile schreiben.
    TRANSFER buffer TO pfileout.

* Anzahl verarbeiteter Sätze erhöhen.
    ADD 1 TO num_personsw.
  ENDLOOP.
ENDFORM. "write_delta_out


* Logische in physische Dateinamen umsetzen
FORM log_to_phys USING lfile CHANGING pfile.
  DATA:
     ilfile LIKE  filename-fileintern.

  ilfile = lfile.
  CALL FUNCTION 'FILE_GET_NAME'
    EXPORTING
      logical_filename = ilfile
    IMPORTING
      file_name        = pfile
    EXCEPTIONS
      file_not_found   = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
    WRITE: / 'Zuordnung von', lfile, 'nicht möglich'.
    ADD 1 TO num_errors.
  ENDIF.
ENDFORM. "log_to_phys


* Lokale Datei in zentrale Datei kopieren
FORM copy_from_local_file
   USING
      plocal_file
      central_file.

  DATA:
     buffer(20000) TYPE c OCCURS 0 WITH HEADER LINE,
     len           TYPE i,
     local_file    TYPE rlgrap-filename,
     file_type     TYPE rlgrap-filetype,
     tmps(150)     TYPE c.

  local_file = plocal_file.
  file_type  = 'ASC'.
  CONCATENATE 'Kopiere' local_file 'zu' central_file
     INTO tmps SEPARATED BY space.
  FORMAT COLOR COL_HEADING.
  WRITE: / tmps.
  FORMAT COLOR OFF.

  DATA lv_filename_for_gui_upload TYPE  string.             "HAN001
  DATA lv_filetype_for_gui_upload TYPE  char10.             "HAN001
  lv_filename_for_gui_upload = local_file.                  "HAN001
  lv_filetype_for_gui_upload = file_type.                   "HAN001
  CALL FUNCTION 'GUI_UPLOAD'                                "HAN001
    EXPORTING                                               "HAN001
      filename             = lv_filename_for_gui_upload     "HAN001
     filetype              = lv_filetype_for_gui_upload     "HAN001
   IMPORTING                                                "HAN001
     filelength                    = len                    "HAN001
    TABLES                                                  "HAN001
      data_tab                      = buffer                "HAN001
   EXCEPTIONS                                               "HAN001
     file_open_error               = 1                      "HAN001
     file_read_error               = 2                      "HAN001
     no_batch                      = 3                      "HAN001
     gui_refuse_filetransfer       = 4                      "HAN001
     invalid_type                  = 5                      "HAN001
     no_authority                  = 6                      "HAN001
     unknown_error                 = 7                      "HAN001
     bad_data_format               = 8                      "HAN001
     header_not_allowed            = 9                      "HAN001
     separator_not_allowed         = 10                     "HAN001
     header_too_long               = 11                     "HAN001
     unknown_dp_error              = 12                     "HAN001
     access_denied                 = 13                     "HAN001
     dp_out_of_memory              = 14                     "HAN001
     disk_full                     = 15                     "HAN001
     dp_timeout                    = 16                     "HAN001
     OTHERS                        = 17.                    "HAN001
*   CALL FUNCTION 'WS_UPLOAD'                               "HAN001
*      EXPORTING                                            "HAN001
*         filename                = local_file              "HAN001
*         filetype                = file_type               "HAN001
*      IMPORTING                                            "HAN001
*         filelength              = len                     "HAN001
*      TABLES                                               "HAN001
*         data_tab                = buffer                  "HAN001
*      EXCEPTIONS                                           "HAN001
*         conversion_error        = 1                       "HAN001
*         file_open_error         = 2                       "HAN001
*         file_read_error         = 3                       "HAN001
*         invalid_table_width     = 4                       "HAN001
*         invalid_type            = 5                       "HAN001
*         no_batch                = 6                       "HAN001
*         unknown_error           = 7                       "HAN001
*         gui_refuse_filetransfer = 8                       "HAN001
*         customer_error          = 9                       "HAN001
*         OTHERS                  = 10.                     "HAN001
  IF sy-subrc <> 0.
    WRITE: / 'Fehler beim Kopieren : ', sy-subrc.
    ADD 1 TO num_errors.
  ELSE.
    OPEN DATASET central_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. "ML001.
    IF sy-subrc <> 0.
      WRITE: / 'Fehler beim Erzeugen von', central_file.
      ADD 1 TO num_errors.
      EXIT.
    ELSE.
      LOOP AT buffer.
        TRANSFER buffer TO central_file.
      ENDLOOP.
      CLOSE DATASET central_file.
    ENDIF.
  ENDIF.
ENDFORM. "copy_from_local_file


* Zentrale Datei in lokale Datei kopieren
FORM copy_to_local_file
   USING
      plocal_file
      central_file.

  DATA:
     buffer(20000) TYPE c OCCURS 0 WITH HEADER LINE,
     len           TYPE i,
     local_file    TYPE rlgrap-filename,
     file_type     TYPE rlgrap-filetype,
     tmps(150)     TYPE c.

  local_file = plocal_file.
  file_type  = 'ASC'.
  CONCATENATE 'Kopiere' central_file 'zu' local_file
     INTO tmps SEPARATED BY space.
  FORMAT COLOR COL_HEADING.
  WRITE: / tmps.
  FORMAT COLOR OFF.

  OPEN DATASET central_file FOR INPUT IN TEXT MODE ENCODING DEFAULT. "ML001.
  IF sy-subrc <> 0.
    WRITE: / 'Fehler beim Öffnen von', central_file.
    ADD 1 TO num_errors.
  ELSE.
    DO.
      READ DATASET central_file INTO buffer.
      IF sy-subrc <> 0. EXIT. ENDIF.
      APPEND buffer.
    ENDDO.
    CLOSE DATASET central_file.
  ENDIF.
  DATA lv_filename_for_gui_upload TYPE  string.             "HAN001
  DATA lv_filetype_for_gui_upload TYPE  char10.             "HAN001
  lv_filename_for_gui_upload = local_file.                  "HAN001
  lv_filetype_for_gui_upload = file_type.                   "HAN001
  CALL FUNCTION 'GUI_DOWNLOAD'                              "HAN001
    EXPORTING                                               "HAN001
      filename                = lv_filename_for_gui_upload  "HAN001
      filetype                = lv_filetype_for_gui_upload  "HAN001
    IMPORTING                                               "HAN001
      filelength              = len                         "HAN001
    TABLES                                                  "HAN001
      data_tab                = buffer                      "HAN001
    EXCEPTIONS                                              "HAN001
      file_write_error        = 1                           "HAN001
      no_batch                = 2                           "HAN001
      gui_refuse_filetransfer = 3                           "HAN001
      invalid_type            = 4                           "HAN001
      no_authority            = 5                           "HAN001
      unknown_error           = 6                           "HAN001
      header_not_allowed      = 7                           "HAN001
      separator_not_allowed   = 8                           "HAN001
      filesize_not_allowed    = 9                           "HAN001
      header_too_long         = 10                          "HAN001
      dp_error_create         = 11                          "HAN001
      dp_error_send           = 12                          "HAN001
      dp_error_write          = 13                          "HAN001
      unknown_dp_error        = 14                          "HAN001
      access_denied           = 15                          "HAN001
      dp_out_of_memory        = 16                          "HAN001
      disk_full               = 17                          "HAN001
      dp_timeout              = 18                          "HAN001
      file_not_found          = 19                          "HAN001
      dataprovider_exception  = 20                          "HAN001
      control_flush_error     = 21                          "HAN001
      OTHERS                  = 22.                         "HAN001
*  CALL FUNCTION 'WS_DOWNLOAD'                               "HAN001
*    EXPORTING                                               "HAN001
*      filename                = local_file                  "HAN001
*      filetype                = file_type                   "HAN001
*    IMPORTING                                               "HAN001
*      filelength              = len                         "HAN001
*    TABLES                                                  "HAN001
*      data_tab                = buffer                      "HAN001
*    EXCEPTIONS                                              "HAN001
*      file_open_error         = 1                           "HAN001
*      file_write_error        = 2                           "HAN001
*      invalid_filesize        = 3                           "HAN001
*      invalid_table_width     = 4                           "HAN001
*      invalid_type            = 5                           "HAN001
*      no_batch                = 6                           "HAN001
*      unknown_error           = 7                           "HAN001
*      gui_refuse_filetransfer = 8                           "HAN001
*      OTHERS                  = 9.                          "HAN001
  IF sy-subrc <> 0.
    WRITE: 'Fehler beim Schreiben der lokalen Datei : ', sy-subrc.
    ADD 1 TO num_errors.
  ENDIF.
ENDFORM. "copy_to_local_file


* LOG Eintrag
FORM log USING text.
  WRITE: / text.
ENDFORM.                    "log


TYPES:
   BEGIN OF column_type,
      name(40)      TYPE c,
      width(4)      TYPE n,
      key(3)        TYPE n,
   END OF column_type,
   BEGIN OF satzart_type,
      name(40)        TYPE c,
      is_curr(1)      TYPE c,
      index           TYPE i,
      actual(20000)   TYPE c,
      last_key(20000) TYPE c,
      columns         TYPE column_type OCCURS 0,
   END OF satzart_type,
   BEGIN OF header_type,
      name(40)        TYPE c,
   END OF header_type,
   BEGIN OF trailer_type,
      name(40)        TYPE c,
   END OF trailer_type.

DATA:
   satzarten          TYPE satzart_type OCCURS 0 WITH HEADER LINE,
   headers_curr       TYPE header_type  OCCURS 0 WITH HEADER LINE,
   headers_last       TYPE header_type  OCCURS 0 WITH HEADER LINE,
   trailers_curr      TYPE trailer_type OCCURS 0 WITH HEADER LINE,
   trailers_last      TYPE trailer_type OCCURS 0 WITH HEADER LINE,
   delta_trailer_lines(20000)  TYPE c OCCURS 0 WITH HEADER LINE.

*
* Unterprogramme
*

* Initalisierung globaler Datenbereiche
FORM init_all.
  REFRESH: satzarten.
  REFRESH: headers_curr, headers_last, trailers_curr, trailers_last.
ENDFORM. " init_all


DATA:
*SIE008   isatzartc   TYPE i  VALUE  1,    "Index der Satzart
*SIE008   isatzartl   TYPE i  VALUE  1,
   ftypec(1)   TYPE c  VALUE  'C',  "Art der Satzstruktur; 'C' = CSV
   ftypel(1)   TYPE c  VALUE  'C'.

* Header-Satz in Bestandteile zerlegen
FORM analyse_header_line
   USING
      is_curr     " Satz aus aktueller Datei
      line.
  DATA:
     iline(20000),
     relements(100)      TYPE c OCCURS 100 WITH HEADER LINE,
     nrelements(8)       TYPE n,
     satzart(8)          TYPE c,
     praefix_pfile(200)  TYPE c,
     mtype(1)            TYPE c,
     column              TYPE column_type,
     new_satzart(1)      TYPE c,

     h_satzarten         TYPE satzart_type.                 "SIE008

  STATICS:
     rec_index           TYPE i VALUE 1.                    "SIE008

  iline = line.
  SPLIT iline AT ';' INTO TABLE relements.
  DESCRIBE TABLE relements LINES nrelements.
*   WRITE: / nrelements, 'Elemente in ', iline(70).
  CLEAR new_satzart.
  REFRESH satzarten-columns. CLEAR satzarten-columns.
  LOOP AT relements.
* muss immer '//' sein
    IF sy-tabix = 1.
      IF relements <> '//'. WRITE: / '???'. ENDIF.
* die Satzart, kann leer sein
    ELSEIF sy-tabix = 2.
      satzart = relements.
* der header-Typ
    ELSEIF sy-tabix = 3.
      mtype   = relements.
* weitere Elemente, abhängig vom Header-Typ
    ELSE.
      CASE mtype.
* Kommentar
        WHEN 'C'.
          WRITE: / 'Kommentar', is_curr, ':', relements.
* Separator (bei CSV)
        WHEN 'D'.
          IF is_curr = 'X'.
            csv_separatorc = relements.
            WRITE: / 'Verwendeter Separator (aktuelle) :',
                     csv_separatorc.
          ELSE.
            csv_separatorl = relements.
            WRITE: / 'Verwendeter Separator (referenz.):',
                     csv_separatorl.
          ENDIF.
* der Dateiname
        WHEN 'F'.
          CASE sy-tabix.
            WHEN 4.
              IF showmsg = 'X'.
                WRITE: / 'Originärer Dateiname:', relements.
              ENDIF.
            WHEN 5.
              IF showmsg = 'X'.
                WRITE: / 'Verwendeter Dateityp:', relements.
              ENDIF.
              IF is_curr = 'X'.
                ftypec = relements(1).
              ELSE.
                ftypel = relements(1).
              ENDIF.
          ENDCASE.
* gültige Header-Kennungen
        WHEN 'H'.
          IF is_curr = 'X'.
            headers_curr-name = relements.
            APPEND headers_curr.
          ELSE.
            headers_last-name = relements.
            APPEND headers_last.
          ENDIF.
* gültige Trailer-Kennungen
        WHEN 'T'.
          IF is_curr = 'X'.
            trailers_curr-name = relements.
            APPEND trailers_curr.
          ELSE.
            trailers_last-name = relements.
            APPEND trailers_last.
          ENDIF.
* Pfadpräfix zur Eingabedatei
        WHEN 'P'.
          IF sy-tabix = 4.
            praefix_pfile = relements.
          ENDIF.
* Version des Exportprogramms
        WHEN 'V'.
* Spaltenbeschreibung einer Satzart
        WHEN 'S'.
          new_satzart = 'X'.
          SPLIT relements AT ':' INTO
             column-name column-key column-width.
          APPEND column TO satzarten-columns.
* Unbekannter Typ
        WHEN OTHERS.
          IF sy-tabix = 4.
            WRITE: / 'Unbekannter Meta-Typ:', mtype.
          ENDIF.
      ENDCASE.
    ENDIF.
  ENDLOOP.
  IF new_satzart = 'X'.
    len_satzart = STRLEN( satzart ).                        "SIE007
    satzarten-name    = satzart.
    satzarten-is_curr = is_curr.
*    SIE008_BEG
*      IF is_curr = 'X'.
*         satzarten-index   = isatzartc.
*         ADD 1 TO isatzartc.
*      ELSE.
*         satzarten-index   = isatzartl.
*         ADD 1 TO isatzartl.
*      ENDIF.

    READ TABLE satzarten INTO h_satzarten
                         WITH KEY name = satzart.

    IF sy-subrc = 0.
      satzarten-index = h_satzarten-index.
    ELSE.
      satzarten-index = rec_index.
      ADD 1 TO rec_index.
    ENDIF.

*    SIE008_END
    APPEND satzarten.
  ENDIF.
ENDFORM.                    "analyse_header_line


DATA:
   keywosac(20000)    TYPE c,
   keyprimc(20000)    TYPE c,                               "SIE003
   keywosal(20000)    TYPE c,
   keypriml(20000)    TYPE c,                               "SIE003

   eofc(1)            TYPE c  VALUE ' ',
   eofl(1)            TYPE c  VALUE ' ',
   trailerc(1)        TYPE c  VALUE ' ',
   trailerl(1)        TYPE c  VALUE ' ',
   headerc(1)         TYPE c  VALUE 'X',                    "SIE008
   headerl(1)         TYPE c  VALUE 'X',                    "SIE008
   skip_rest(1)       TYPE c  VALUE ' ',
   lastlinec(20000)   TYPE c,
   lastlinel(20000)   TYPE c,
   lasttrailer(20000) TYPE c,
   saindexc           TYPE i.


* Datenzeile in Bestandteile zerlegen und verarbeiten.
* Da immer zuerst aus der aktuellen Datei gelesen wird, erfolgt die
* Deltabildung beim Lesen von Zeilen aus der Referenzdatei (is_curr='').

FORM analyse_data_line
   USING
      plastfile
      poutfile
      is_curr     " Satz aus aktueller Datei
      line
      loadinitial " Initialladung
      first_key   " Sätze vor diesem ignorieren
      last_key    " Sätze nach diesem ignorieren
   CHANGING
      read_curr
      read_last.

  DATA:
     iline(20000),
     relements(100) TYPE c OCCURS 100 WITH HEADER LINE,
     nrelements(8)  TYPE n,
     satzart(8)     TYPE c,
     mtype(1)       TYPE c,
     idx            TYPE i,
     column         TYPE column_type,
     key(20000)     TYPE c,
     keywosa(20000) TYPE c,
     keyprim(20000) TYPE c,                                 "SIE003
     new_satzart(1) TYPE c,
     skip_line(1)   TYPE c VALUE ' ',
     tmps(150)      TYPE c.

* Parameter umkopieren
  iline = line.

* Rückgabewerte initialisieren.
  read_curr = 'X'.
  read_last = 'X'.

* Inital-Ladung
  IF loadinitial = 'X'.
    read_last = ' '.
    IF is_curr = ' '.
      EXIT.
    ENDIF.
  ENDIF.

* Sondersituationen:
* b) EOF Bearbeitung (die entsprechende Zeile ist leer)
  IF iline IS INITIAL AND skip_rest = ' '
     AND loadinitial = ' '.
    IF is_curr = 'X'.
      eofc = 'X'.
      read_curr = ' '.
      PERFORM gen_delta_line
         USING
            poutfile kennung_delete lastlinel.
      IF showmsg = 'X'.
        CONCATENATE 'Änderung bei Schlüssel:' key
                    '>>> Satz wird entfernt (type F)'
                    INTO tmps SEPARATED BY space.
        WRITE: / tmps.
      ENDIF.
    ENDIF.
*
*      IF  is_curr = ' '.                                 "SIE002
    IF  is_curr = ' ' AND trailerc <> 'X'.                  "SIE002
      eofl = 'X'.
      read_last = ' '.
      PERFORM gen_delta_line
         USING
            poutfile kennung_insert lastlinec.
      IF showmsg = 'X'.
        CONCATENATE 'Änderung bei Schlüssel:' key
                    '>>> Satz wird zugefügt (type G)'
                    INTO tmps SEPARATED BY space.
        WRITE: / tmps.
      ENDIF.
    ENDIF.
    EXIT.
  ENDIF.


* Zeilenzerlegung abhängig vom Dateityp ('FIX' oder 'CSV') durchführen.
  IF   is_curr = 'X' AND ftypec = 'C'
    OR is_curr = ' ' AND ftypel = 'C'.
    IF is_curr = 'X'.
      csv_separator = csv_separatorc.
    ELSE.
      csv_separator = csv_separatorl.
    ENDIF.
    SPLIT iline AT csv_separator INTO TABLE relements.
  ELSE.
*      SATZART = ILINE(8).                                "SIE007
    satzart = iline(len_satzart).                           "SIE007
    READ TABLE satzarten WITH KEY name = satzart is_curr = is_curr.
    IF sy-subrc <> 0.
      relements = satzart.
      APPEND relements.
    ELSE.
      LOOP AT satzarten-columns INTO column.
        relements = iline(column-width).
        SHIFT iline LEFT BY column-width PLACES.
        APPEND relements.
      ENDLOOP.
    ENDIF.
  ENDIF.
  DESCRIBE TABLE relements LINES nrelements.

* Lese Satzart
  READ TABLE relements INDEX 1.
  IF sy-subrc <> 0.
    IF skip_rest = ' '.
      WRITE: / 'Fehler 1 in Datensatzstruktur. Curr =', is_curr.
      ADD 1 TO num_errors.
    ENDIF.
  ELSE.
    satzart = relements.

* prüfe auf Header
    READ TABLE headers_curr WITH KEY name = satzart.
    IF sy-subrc = 0.
      IF is_curr = 'X'.
        SEARCH iline FOR '%Referenzdatei%'.
        IF sy-subrc = 0.
          CONCATENATE iline plastfile INTO iline.
*              SIE005_BEG
          IF pdoext = 'X'. "manuell programmierte Schnittstelle
            PERFORM cut_last_chars USING 6
                                   CHANGING iline.
          ENDIF.
*              SIE005_END
        ENDIF.
        PERFORM gen_delta_line
           USING
*                  poutfile '' iline.                       "SIE001
              poutfile iline ''.                            "SIE001
      ENDIF. " is current
      skip_line = 'X'.
      IF global_debug = 'X'.
        WRITE: / 'Header:', satzart, 'current:', is_curr.
      ENDIF.
**     SIE008_BEG
*      else. " no header line
**        Warten, bis Header von beiden Eingabedateien gelesen wurden.
*         if is_curr = 'X'.
*            clear headerc.
*            if headerl = 'X'.
*               skip_line = 'X'.
*               clear read_curr.
*            endif.
*         else.
*            clear headerl.
*            if headerc = 'X'.
*               skip_line = 'X'.
*               clear read_last.
*            endif.
*         endif.
**     SIE008_END
    ENDIF. " is header line

* prüfe auf Trailer
    READ TABLE trailers_curr WITH KEY name = satzart.
*     IF sy-subrc = 0.                                      "SIE008
    IF sy-subrc = 0 AND skip_line = ' '.                    "SIE008
      IF is_curr = 'X'.
        IF line <> lasttrailer.
          lasttrailer = line.
          delta_trailer_lines = line.
          APPEND delta_trailer_lines.
        ENDIF.
        trailerc = 'X'.
      ELSE.
        trailerl = 'X'.
        IF skip_line <> 'X' AND trailerc <> 'X'.            "SIE002
          PERFORM gen_delta_line                            "SIE002
             USING poutfile kennung_insert lastlinec.       "SIE002
        ENDIF.                                              "SIE002
      ENDIF. " is current
      skip_line = 'X'.
      IF global_debug = 'X'.
        WRITE: / 'Trailer:', satzart, 'current:', is_curr.
      ENDIF.
    ENDIF. " is trailer line

* Falls ausserhalb des Begrenzungsbandes, Rest ignorieren
    IF skip_rest = 'X'.
      ADD 1 TO num_skippers.
      EXIT.
    ENDIF.

* prüfe auf Satzarten
    IF skip_line = ' '.
      READ TABLE satzarten WITH KEY name = satzart is_curr = is_curr.
      idx = sy-tabix.
* Satzart gefunden
      IF sy-subrc = 0.

* Initial-Ladung
        IF loadinitial = 'X'.
          PERFORM gen_delta_line
             USING
                poutfile kennung_insert line.
        ELSE.

* Key berechnen
*         CLEAR: key, keywosa.   "SIE003
          CLEAR: key, keywosa, keyprim.                     "SIE003
          LOOP AT satzarten-columns INTO column.
            READ TABLE relements INDEX sy-tabix.
            IF column-key > '000'.
*               CONCATENATE key relements INTO key.      "SIE004
              CONCATENATE key relements keysep INTO key.    "SIE004
              IF sy-tabix > 1.
*                  CONCATENATE keywosa relements INTO keywosa. "SIE004
                CONCATENATE keywosa relements keysep INTO keywosa."SIE004
                IF sy-tabix = 2.                            "SIE003
*            CONCATENATE keyprim relements INTO keyprim. "SIE003 "SIE004
                  CONCATENATE keyprim relements keysep INTO keyprim."SIE004
                ENDIF.                                      "SIE003
              ENDIF.
            ENDIF.
          ENDLOOP.

* Falls Teilausschnitt dann Sätze vor dem Startschlüssel oder nach
* dem Endeschlüssel überspringen
          IF NOT ( first_key IS INITIAL )
             AND ( NOT keywosa IS INITIAL )
             AND keywosa < first_key.
            IF is_curr = 'X'.
              ADD 1 TO num_skippers.
            ENDIF.
            EXIT.
          ENDIF.
          IF NOT ( last_key IS INITIAL )
             AND ( NOT keywosa IS INITIAL )
             AND keywosa > last_key
             AND trailerc = ' '
             AND trailerl = ' '.
            IF is_curr = 'X'.
              ADD 1 TO num_skippers.
            ENDIF.
            skip_rest = 'X'.
            EXIT.
          ENDIF.

* Key-Änderung ?
          IF keywosa <> satzarten-last_key.
            satzarten-last_key = keywosa.
            IF is_curr = 'X'.
              ADD 1 TO num_personsc.
            ELSE.
              ADD 1 TO num_personsl.
            ENDIF.
          ENDIF. " Key-Änderung

* aktuelle Zeile speichern.
          satzarten-actual = line.
          MODIFY satzarten INDEX idx.

* Vergleich durchführen. Dies passiert bei der Verarbeitung des 'last'-
* Satzes, da dieser nach dem 'curr' Satz gelesen wird.
          IF is_curr = 'X'.
            IF chksort = 'X' AND keywosac > keywosa.
              WRITE: / 'Sortierung nicht aufsteigend!'.
              ADD 1 TO num_errors.
            ENDIF.
            keywosac  = keywosa.
            keyprimc  = keyprim.
            lastlinec = line.
            saindexc  = satzarten-index.
          ELSE.
            IF chksort = 'X' AND keywosal > keywosa.
              WRITE: / 'Sortierung nicht aufsteigend!'.
              ADD 1 TO num_errors.
            ENDIF.
            keywosal  = keywosa.
            keypriml  = keyprim.
            lastlinel = line.

**           SIE008_BEG
**           Deltazeilen nur generieren falls Satzarten vorhanden.
**           EOF wird ja bereits oben abgefangen
*            IF saindexc = '0'.
*               CLEAR read_last.
*               EXIT.
*            ENDIF.
**           SIE008_END


* Key (ohne Satzart) ist gleich.
*            IF keywosac = keywosal.                           "SIE001
* Satzart ist identisch
*               IF saindexc = satzarten-index.                 "SIE001

*           Satzart ist identisch                             "SIE001
            IF saindexc = satzarten-index.                  "SIE001
*              Key (ohne Satzart) ist gleich.                 "SIE001
              IF keywosac = keywosal.                       "SIE001

                IF lastlinec <> line. "Sätze nicht identisch
                  PERFORM gen_delta_line
                     USING
                        poutfile kennung_update lastlinec.
                  IF showmsg = 'X'.
                    CONCATENATE 'Änderung bei Schlüssel:' key
                       '>>> Satz wird aktualisiert (type A)'
                       INTO tmps SEPARATED BY space.
                    WRITE: / tmps.
                  ENDIF.
                ELSE.
                  IF showmsg = 'X'.
                    CONCATENATE 'Gleichh. bei Schlüssel:' key
                       INTO tmps SEPARATED BY space.
                    WRITE: / tmps.
                  ENDIF.
                ENDIF. "Sätze nicht identisch

* SIE001_BEG
** Satzart nicht identisch
*                  IF SAINDEXC < SATZARTEN-INDEX.
** Zeile fehlt in last.
*                     CLEAR READ_LAST.
*                     PERFORM GEN_DELTA_LINE
*                        USING
*                           POUTFILE KENNUNG_INSERT LASTLINEC.
*                     IF SHOWMSG = 'X'.
*                        CONCATENATE 'Änderung bei Schlüssel:' KEY
*                           '>>> Satz wird zugefügt (type B)'
*                           INTO TMPS SEPARATED BY SPACE.
*                        WRITE: / TMPS.
*                     ENDIF.
*                  ELSE.
** Zeile fehlt in current.
*                     CLEAR READ_CURR.
*                     PERFORM GEN_DELTA_LINE
*                        USING
*                           POUTFILE KENNUNG_DELETE LINE.
*                     IF SHOWMSG = 'X'.
*                        CONCATENATE 'Änderung bei Schlüssel:' KEY
*                           '>>> Satz wird entfernt (type C)'
*                           INTO TMPS SEPARATED BY SPACE.
*                        WRITE: / TMPS.
*                     ENDIF.
*                  ENDIF.
*               ENDIF.
* SIE001_END

* Key (ohne Satzart) ist unterschiedlich
              ELSE.
                IF keywosac < keywosal
                   AND trailerc = ' '.
* Zeile fehlt in last
                  CLEAR read_last.
                  PERFORM gen_delta_line
                     USING
                        poutfile kennung_insert lastlinec.
                  IF showmsg = 'X'.
                    CONCATENATE 'Änderung bei Schlüssel:'
                       keywosac '/' keywosal
                       '>>> Satz wird zugefügt (type D)'
                       INTO tmps SEPARATED BY space.
                    WRITE: / tmps.
                  ENDIF.
                ELSE.
* Zeile fehlt in current
                  CLEAR read_curr.
                  PERFORM gen_delta_line
                     USING
                        poutfile kennung_delete line.
                  IF showmsg = 'X'.
                    CONCATENATE 'Änderung bei Schlüssel:'
                       keywosac '/' keywosal
                       '>>> Satz wird entfernt (type E)'
                       INTO tmps SEPARATED BY space.
                    WRITE: / tmps.
                  ENDIF.
                ENDIF. " keywosac < keywosal
              ENDIF. " keywosac <> keywosal
* SIE001_BEG
            ELSE.
* Satzart nicht identisch

              IF keypriml = keyprimc.                       "SIE003
                IF saindexc < satzarten-index.

* Zeile fehlt in last.
                  CLEAR read_last.
                  PERFORM gen_delta_line
                     USING
                        poutfile kennung_insert lastlinec.
                  IF showmsg = 'X'.
                    CONCATENATE 'Änderung bei Schlüssel:' key
                       '>>> Satz wird zugefügt (type B)'
                       INTO tmps SEPARATED BY space.
                    WRITE: / tmps.
                  ENDIF.
                ELSE.
* Zeile fehlt in current.
                  CLEAR read_curr.
                  PERFORM gen_delta_line
                     USING
                        poutfile kennung_delete line.
                  IF showmsg = 'X'.
                    CONCATENATE 'Änderung bei Schlüssel:' key
                       '>>> Satz wird entfernt (type C)'
                       INTO tmps SEPARATED BY space.
                    WRITE: / tmps.
                  ENDIF.
                ENDIF.


              ELSE. "Primary Key unterschiedlich   "SIE003_BEG
                IF keyprimc < keypriml
                   AND trailerc = ' '.
* Zeile fehlt in last
                  CLEAR read_last.
                  PERFORM gen_delta_line
                     USING
                        poutfile kennung_insert lastlinec.
                  IF showmsg = 'X'.
                    CONCATENATE 'Änderung bei PrimärSchlüssel:'
                       keyprimc '/' keypriml
                       '>>> Satz wird zugefügt (type D)'
                       INTO tmps SEPARATED BY space.
                    WRITE: / tmps.
                  ENDIF.
                ELSE.
* Zeile fehlt in current
                  CLEAR read_curr.
                  PERFORM gen_delta_line
                     USING
                        poutfile kennung_delete line.
                  IF showmsg = 'X'.
                    CONCATENATE 'Änderung bei PrimärSchlüssel:'
                       keyprimc '/' keypriml
                       '>>> Satz wird entfernt (type E)'
                       INTO tmps SEPARATED BY space.
                    WRITE: / tmps.
                  ENDIF.
                ENDIF. " keywosac < keywosal
              ENDIF. " keyprimc <> keypriml     "SIE003_END

            ENDIF.



* SIE001_END
          ENDIF. " is last
        ENDIF. "Delta-Ladung
      ELSE.
        WRITE: / 'Satzart', satzart, 'nicht bekannt'.
        ADD 1 TO num_errors.
      ENDIF. "Satzart bekannt
    ENDIF. " skip_line

  ENDIF. " Satzart ermittelbar
ENDFORM.                    "analyse_data_line


* satzarten auflisten
FORM list_satzarten.
  DATA:
     column   TYPE column_type,
     position LIKE column-width VALUE '0001'.

  FORMAT COLOR COL_HEADING.
  WRITE: / 'Liste der definierten Satzarten:'.
  FORMAT COLOR OFF.
  LOOP AT satzarten.
    SKIP.
    position = '0001'.
    WRITE: / 'Satzart:', satzarten-name(20),
              'Aktuell =', satzarten-is_curr,
              'Index = ', satzarten-index,
              'Letzter Schlüssel = ', satzarten-last_key(30).
    FORMAT COLOR COL_KEY.
    WRITE: / '   Feldname                       Position Breite',
             'Schlüssel'.
    FORMAT COLOR OFF.
    LOOP AT satzarten-columns INTO column.
      WRITE: / '  ', column-name(30), position, '   ', column-width,
               ' ', column-key.
      ADD column-width TO position.
    ENDLOOP.
  ENDLOOP.
  SKIP.
ENDFORM. "list_satzarten.


* header auflisten
FORM list_headers.
  DATA:
     column   TYPE column_type.

  SKIP.
  FORMAT COLOR COL_HEADING.
  WRITE: / 'Liste der definierten Header:'.
  FORMAT COLOR OFF.
  LOOP AT headers_curr.
    WRITE: / 'Header :', headers_curr-name.
    READ TABLE headers_last WITH KEY name = headers_curr-name.
    IF sy-subrc > 2.
      WRITE: / headers_curr-name, 'nicht in letzter Datei'.
    ENDIF.
  ENDLOOP.
  LOOP AT headers_last.
    READ TABLE headers_curr WITH KEY name = headers_last-name.
    IF sy-subrc > 2.
      WRITE: / headers_last-name, 'nicht in aktueller Datei'.
    ENDIF.
  ENDLOOP.
  SKIP.
ENDFORM. "list_header.


* Trailer auflisten
FORM list_trailers.
  DATA:
     column   TYPE column_type.

  SKIP.
  FORMAT COLOR COL_HEADING.
  WRITE: / 'Liste der definierten Trailer:'.
  FORMAT COLOR OFF.
  LOOP AT trailers_curr.
    WRITE: / 'Trailer:', trailers_curr-name.
    READ TABLE trailers_last WITH KEY name = trailers_curr-name.
    IF sy-subrc > 2.
      WRITE: / trailers_curr-name, 'nicht in letzter Datei'.
    ENDIF.
  ENDLOOP.
  LOOP AT trailers_last.
    READ TABLE trailers_curr WITH KEY name = trailers_last-name.
    IF sy-subrc > 2.
      WRITE: / trailers_last-name, 'nicht in aktueller Datei'.
    ENDIF.
  ENDLOOP.
  SKIP.
ENDFORM. "list_trailer.



* Header im Delta Format erstellen.
FORM gen_delta_header USING pfileout.
  DATA:
     recsout(20000)        TYPE c OCCURS 0 WITH HEADER LINE.

  REFRESH recsout.      CLEAR recsout.
*   PERFORM write_delta_out TABLES recsout USING pfileout.
ENDFORM. "gen_delta_header


* Trailer im Delta Format erstellen.
FORM gen_delta_trailer USING pfileout.
  PERFORM write_delta_out TABLES delta_trailer_lines USING pfileout.
ENDFORM. "gen_delta_trailer


*&---------------------------------------------------------------------*
*&      Form  out_line
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RECIN      text
*----------------------------------------------------------------------*
FORM out_line USING recin.
  DATA:
     bt(120) TYPE c,
     offset  TYPE i.

  offset = 0.
  DO.
    bt = recin+offset(120).
    IF bt IS INITIAL. EXIT. ENDIF.
    WRITE: / bt.
    ADD 120 TO offset.
  ENDDO.
ENDFORM.                    "out_line

* Satz im Delta Datei schreiben.
FORM gen_delta_line
   USING
      pfileout
      kennung
      line.
  DATA:
     recsout(20000)        TYPE c OCCURS 0 WITH HEADER LINE,
     separator(1)          TYPE c VALUE ''.

*  IF NOT CSV_SEPARATORC IS INITIAL.
  IF NOT csv_separatorc IS INITIAL AND ftypec = 'C'.        "SIE007
    separator = csv_separatorc.
  ENDIF.
  REFRESH recsout.      CLEAR recsout.
  CONCATENATE kennung separator line INTO recsout.
  APPEND recsout.
  PERFORM write_delta_out TABLES recsout USING pfileout.

ENDFORM. "gen_delta_line


* Dateien vergleichen und Ausgabedatei erzeugen
FORM compare_files
   USING
      linfile
      llastfile
      loutfile
      lparafile
      logicalc
      logicall
      logicald
      logicalp
      nameext
      first_key
      last_key
      showlist
      showmsg
      showsame
      maxlines   TYPE i.

  DATA:  ppraefix(300)         TYPE c,
         reclast(20000)        TYPE c,
         recin(20000)          TYPE c,
         recout(20000)         TYPE c,
         plastfile(300)        TYPE c,
         pinfile(300)          TYPE c,
         poutfile(300)         TYPE c,
         pparafile(300)        TYPE c,
         ptempfile(300)        TYPE c,
         readfromparac(1)      TYPE c,
         iparac                TYPE i,
         readfromparal(1)      TYPE c,
         iparal                TYPE i,
         formatcsv(1)          TYPE c VALUE 'X',
         loadinitial(1)        TYPE c VALUE ' ',
         pernrc(8)             TYPE c,
         pernrl(8)             TYPE c,
         do_change(1)          TYPE c,
         read_la(1)            TYPE c,
         read_in(1)            TYPE c,
         eof_last(1)           TYPE c,
         eof_in(1)             TYPE c,
         compare_lines(1)      TYPE c,
         status(2)             TYPE n,
         max_emptyloop(2)      TYPE n,
         tmps(200)             TYPE c,
         pfnlen                TYPE i,
         pfnlenm1              TYPE i,
         pfnlenm2              TYPE i,
         adjust_recs           TYPE c VALUE 'X',            "SIE008
         paraext(10000)        TYPE c OCCURS 0 WITH HEADER LINE,
         partsfilename(100)    TYPE c OCCURS 0 WITH HEADER LINE,
         recsout(20000)        TYPE c OCCURS 0 WITH HEADER LINE.

* Initialisierungen
  CLEAR:   num_personsc, num_personsl, num_personsw, num_changed,
           num_linesc,   num_linesl,   num_skippers, num_unskipped.
  REFRESH: satzarten.

* Initialmeldungen ausgeben
  SKIP.
  FORMAT INTENSIFIED ON.
  WRITE: 'SAP-DP Deltagenerator           ', text-002.
  FORMAT INTENSIFIED OFF.
  SKIP.
  WRITE: / 'Beginn der Verarbeitung:', sy-uzeit.

* falls angegeben, logische in physische Dateinamen umsetzen
  IF NOT lparafile IS INITIAL AND logicalp = 'X'.
    PERFORM log_to_phys USING lparafile  CHANGING pparafile.
  ELSE.
    MOVE lparafile  TO pparafile.
  ENDIF.

* Pfadpräfix vorab aus Parameterdatei ermitteln.
  IF NOT pparafile IS INITIAL.
    OPEN DATASET pparafile FOR INPUT IN TEXT MODE ENCODING DEFAULT. "ML001
    IF sy-subrc <> 0.
      WRITE: / 'Fehler beim Öffnen von:', pparafile.
    ELSE.
      DO.
        READ DATASET pparafile INTO recin.
        IF sy-subrc <> 0. EXIT. ENDIF.
        IF recin(6) = '//;;P;'.
          ppraefix = recin+6.
          WRITE: / 'Dateinamenspräfix:', ppraefix(60).
        ENDIF.
      ENDDO.
      CLOSE DATASET pparafile.
    ENDIF.
  ENDIF.
  IF logicalc = 'X'.
    PERFORM log_to_phys USING linfile   CHANGING pinfile.
  ELSE.
    CONCATENATE ppraefix linfile INTO pinfile.
  ENDIF.
  IF logicall = 'X'.
    PERFORM log_to_phys USING llastfile CHANGING plastfile.
  ELSE.
    CONCATENATE ppraefix llastfile INTO plastfile.
  ENDIF.
  IF logicald = 'X'.
    PERFORM log_to_phys USING loutfile  CHANGING poutfile.
  ELSE.
    CONCATENATE ppraefix loutfile INTO poutfile.
  ENDIF.

* Evt. Referenzdatei ermitteln; den ZWEITEN Eintrag
  IF NOT lparafile IS INITIAL.
    DATA: first_row(1) TYPE c.
    first_row = 'X'.
    SELECT * FROM /sie/hr_iss_stat
    WHERE iftyp  = nameext
      AND status = 'F'
    ORDER BY start_datum DESCENDING start_zeit DESCENDING.
      IF first_row = 'X'.
        CLEAR first_row.
      ELSE.
        llastfile = '* aus /sie/hr_iss_stat *'.
        SPLIT pinfile+1 AT '/' INTO TABLE partsfilename.
        DESCRIBE TABLE partsfilename LINES pfnlen.
        pfnlenm1 = pfnlen - 1.
        pfnlenm2 = pfnlen - 2.
        CLEAR ptempfile.
        LOOP AT partsfilename.
          IF sy-tabix <= pfnlenm2.
            CONCATENATE ptempfile '/' partsfilename
               INTO ptempfile.
          ELSEIF sy-tabix = pfnlenm1.
            CONCATENATE ptempfile '/' /sie/hr_iss_stat-moverz
              INTO ptempfile.
          ELSE.
            CONCATENATE ptempfile '/' /sie/hr_iss_stat-name
               INTO ptempfile.
          ENDIF.
        ENDLOOP.
        plastfile = ptempfile.
        EXIT.
      ENDIF.
    ENDSELECT.
    IF sy-subrc <> 0.
      CONCATENATE 'Kann Schnittstelle "' nameext
         '" nicht ermitteln !' INTO s_tmp.
      WRITE: / s_tmp.
      ADD 1 TO num_errors.
      EXIT.
    ENDIF.
    loutfile = '* generiert aus akt. Datei *'.
    CONCATENATE pinfile '.delta' INTO poutfile.
  ENDIF.

* Dateinamen ausgeben
  SKIP.
  FORMAT COLOR COL_GROUP.
  CONCATENATE 'Transformiere   (akt.) :' linfile
          '  (' pinfile ')' INTO tmps.
  WRITE: / tmps.
  WRITE: / pinfile.
  IF plastfile IS INITIAL.
    tmps = 'Initalladung (keine Referenzdatei angegeben)'.
  ELSE.
    CONCATENATE 'Deltas in Bezug auf    :' llastfile
            '  (' plastfile ')' INTO tmps.
  ENDIF.
  WRITE: / tmps.
  WRITE: / plastfile.
  CONCATENATE 'in DELTA-Datei   (neu) :' loutfile
          '  (' poutfile ')' INTO tmps.
  WRITE: / tmps.
  FORMAT COLOR OFF.

* Ausgabe eventueller Bereichseinschränkungen
  IF NOT first_key IS INITIAL.
    SKIP.
    WRITE: / 'Bereich eingeschränkt ab ', first_key.
  ENDIF.
  IF NOT last_key IS INITIAL.
    IF first_key IS INITIAL.
      SKIP.
    ENDIF.
    WRITE: / 'Bereich eingeschränkt bis', last_key.
  ENDIF.


  IF pinfile = plastfile.
    SKIP.
    WRITE: / 'Eingabedatei und Referenzdatei sind identisch !'.
    EXIT.
  ENDIF.


* Berechtigung prüfen.
  DATA: ipfile LIKE  authb-filename.
  ipfile = plastfile.
  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
    EXPORTING
      activity         = 'READ'
      filename         = ipfile
    EXCEPTIONS
      no_authority     = 1
      activity_unknown = 2
      OTHERS           = 3.
  IF sy-subrc <> 0.
    WRITE: / 'Keine Berechtigung (rc=', sy-subrc, ') für', plastfile.
    ADD 1 TO num_errors.
  ENDIF.

* Aktuelle Datei verarbeiten.
* Evt. Parameterdatei öffnen.
  IF NOT lparafile IS INITIAL.
    OPEN DATASET pparafile FOR INPUT IN TEXT MODE ENCODING DEFAULT. "ML001
    IF sy-subrc <> 0.
      CONCATENATE '!!! Datei "' pparafile(60)
               '" kann nicht geöffnet werden !' INTO s_tmp.
      WRITE: / s_tmp.
      ADD 1 TO num_errors.
      EXIT.
    ELSE.
      DO.
        READ DATASET pparafile INTO paraext.
        IF sy-subrc <> 0. EXIT. ENDIF.
        APPEND paraext.
      ENDDO.
      SKIP.
      WRITE: / 'Externe Parameterdatei:'.
      LOOP AT paraext.
        WRITE: / paraext(100).
      ENDLOOP.
      SKIP.
      readfromparac = 'X'.
      iparac        = 1.
      readfromparal = 'X'.
      iparal        = 1.
    ENDIF.
  ENDIF.
* Evt. lokale Datei kopieren.
  IF pcopyloc = 'X'.
    PERFORM copy_from_local_file USING pfileloc pinfile.
  ENDIF.
* Eingabedatei öffnen
  OPEN DATASET pinfile FOR INPUT IN TEXT MODE ENCODING DEFAULT. "ML001
  IF sy-subrc <> 0.
    CONCATENATE '!!! Datei "' pinfile(60)
             '" kann nicht geöffnet werden !' INTO s_tmp.
    WRITE: / s_tmp.
    ADD 1 TO num_errors.
  ELSE.
* Referenz-Datei verarbeiten. Falls der Name leer ist handelt es sich
* um eine Initial-Ladung.
* Evt. lokale Datei in Delta-Referenzdatei kopieren.
    IF pcopylol = 'X'.
      PERFORM copy_from_local_file USING pfilelol plastfile.
    ENDIF.
* Delta-Referenzdatei öffnen
    IF plastfile IS INITIAL.
      loadinitial = 'X'.
      sy-subrc = 0.
    ELSE.
      OPEN DATASET plastfile FOR INPUT IN TEXT MODE ENCODING DEFAULT. "ML001
    ENDIF.
    IF sy-subrc <> 0.
      CONCATENATE '!!! Datei "' plastfile(60)
               '" kann nicht geöffnet werden !' INTO s_tmp.
      WRITE: / s_tmp.
      ADD 1 TO num_errors.
    ELSE.
* Ausgabedatei öffnen
      OPEN DATASET poutfile FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. "ML001
.
      IF sy-subrc <> 0.
        WRITE: / '!!! Ausgabedatei "', poutfile(60),
                '" kann nicht erzeugt werden !'.
        ADD 1 TO num_errors.
        EXIT.
      ELSE.
        SKIP. SKIP.
        FORMAT COLOR COL_HEADING.
        WRITE: / 'Meldungen :'.
        FORMAT COLOR OFF.
        SKIP.

* Status (im Feld 'status') :
*   0 : Header suchen
*  10 : Beginn einer Person
        status    = 0.
        read_in   = 'X'.
        eof_in    = ' '.
        read_la = 'X'.
        eof_last  = ' '.
        IF plastfile IS INITIAL.
          eof_last = 'X'.
        ENDIF.
* Header der Ausgabedatei schreiben
        PERFORM gen_delta_header USING    poutfile.

        REFRESH recsout. CLEAR recsout.

* Schleife über die Eingabedateien
        DO.
* Abbrechen bei Ausnahmebedingungen.
          IF num_errors > 10.
            WRITE: / 'Abbruch nach mehr als zehn Fehlern !'.
            EXIT.
          ENDIF.

* Abbrechen bei vorgegebener Anzahl
          IF maxlines > 0.
            IF num_linesc > maxlines
            OR num_linesl > maxlines.
              WRITE: / 'Abbruch nach mehr als', maxlines,
                       'Zeilen !'.
              EXIT.
            ENDIF.
          ENDIF.

* Gesteuert über die Flags 'read_last' und 'read_curr' werden
* die beiden Eingabedateien gelesen. Sobald beide beendet sind,
* wird die Verarbeitung beendet.
          IF read_in = 'X'.
            IF readfromparac = 'X'.
              READ TABLE paraext INDEX iparac.
              IF sy-subrc <> 0.
                readfromparac = ' '.
              ELSE.
                recin = paraext.
                WRITE: / 'C', recin(80).
              ENDIF.
              ADD 1 TO iparac.
            ENDIF.
            IF readfromparac = ' '.
              READ DATASET pinfile INTO recin.
              IF sy-subrc NE 0.
                IF global_debug = 'X'.
                  WRITE: / 'EOF bei current'.
                ENDIF.
                eof_in  = 'X'.
                read_in = ' '.
              ELSE.
                ADD 1 TO num_linesc.
                IF detailcu = 'X'.
                  PERFORM out_line USING recin.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
          IF read_la = 'X' AND NOT plastfile IS INITIAL.
            IF readfromparal = 'X'.
              READ TABLE paraext INDEX iparal.
              IF sy-subrc <> 0.
                readfromparal = ' '.
              ELSE.
                reclast = paraext.
                WRITE: / 'L', reclast(80).
              ENDIF.
              ADD 1 TO iparal.
            ENDIF.
            IF readfromparal = ' '.
              READ DATASET plastfile INTO reclast.
              IF sy-subrc NE 0.
                IF global_debug = 'X'.
                  WRITE: / 'EOF bei Referenz'.
                ENDIF.
                eof_last  = 'X'.
                read_la = ' '.
              ELSE.
                ADD 1 TO num_linesl.
                IF detailla = 'X'.
                  PERFORM out_line USING reclast.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
          IF eof_last = 'X' AND eof_in = 'X'.
            EXIT.
          ENDIF.
* Sicherheitsüberwachung gegen Endlosschleife.
          IF read_la = ' ' AND read_in = ' '.
            ADD 1 TO max_emptyloop.
            IF max_emptyloop > 10.
              SKIP.
              WRITE: / 'Ende nach Leerschleife in Status',
                 status.
*                     ADD 1 TO num_errors.
              EXIT.
            ENDIF.
          ELSE.
            CLEAR max_emptyloop.
          ENDIF.

          compare_lines = 'X'.

* Eingabesätze aufgliedern
          CLEAR: read_in, read_la.                          "SIE008
          IF recin(2) = '//'.
            PERFORM analyse_header_line USING 'X' recin.
            CLEAR: compare_lines.
            read_in   = 'X'.
          ENDIF.
          IF reclast(2) = '//'.
            PERFORM analyse_header_line USING ' ' reclast.
            CLEAR: compare_lines.
            read_la = 'X'.
          ENDIF.

*              SIE008_BEG
*              Satzarten abgleichen

          IF compare_lines = 'X' AND adjust_recs = 'X'.
            PERFORM init_recs.
            CLEAR adjust_recs.
          ENDIF.
*              SIE008_END

          IF compare_lines = 'X'.
* Datensätze analysieren
            DATA:
               t_read_in(1)   TYPE c,
               t_read_la(1)   TYPE c.

            PERFORM analyse_data_line
               USING
                  plastfile poutfile 'X' recin loadinitial
                  first_key last_key
               CHANGING
                  read_in read_la.
            t_read_in   = read_in.
            t_read_la   = read_la.
            PERFORM analyse_data_line
               USING
                  plastfile poutfile ' ' reclast loadinitial
                  first_key last_key
               CHANGING
                  read_in read_la.
            IF t_read_in = ' '.
              read_in = ' '.
            ENDIF.
            IF t_read_la = ' '.
              read_la = ' '.
            ENDIF.
          ENDIF.

        ENDDO.

* Trailer der Ausgabedatei schreiben
        PERFORM gen_delta_trailer CHANGING poutfile.

        CLOSE DATASET poutfile.
      ENDIF.
      CLOSE DATASET plastfile.
    ENDIF.
    CLOSE DATASET pinfile.

* Evt. Ergebnisdatei auf lokale Datei kopieren.
    IF pcopylod = 'X'.
      PERFORM copy_to_local_file USING pfilelod poutfile.
    ENDIF.

* Statistik zur Umsetzung ausgeben.

    SKIP. SKIP.
    FORMAT COLOR COL_HEADING.
    WRITE: / 'Statistik :'.
    FORMAT COLOR OFF.
    SKIP.
    WRITE: / 'Anzahl übersprungener Zeilen     :', num_skippers.
    num_unskipped = num_personsc - num_skippers.
    WRITE: / 'Anzahl gelesener Schlüssel (neu) :', num_unskipped.
    WRITE: / 'Anzahl gelesener Zeilen    (neu) :', num_linesc.
    num_unskipped = num_personsl - num_skippers.
    WRITE: / 'Anzahl gelesener Schlüssel (Ref.):', num_unskipped.
    WRITE: / 'Anzahl gelesener Zeilen    (Ref.):', num_linesl.
    WRITE: / 'Anzahl geschriebener Zeilen      :', num_personsw.
    WRITE: / 'Anzahl Fehler                    :', num_errors.
    SKIP.
  ENDIF.

* Ausgabedatei auflisten
  IF showlist = 'X'.
    SKIP.
    FORMAT COLOR COL_HEADING.
    WRITE: / 'Inhalt der Ausgabedatei :'.
    FORMAT COLOR OFF.
    SKIP.
    OPEN DATASET poutfile FOR INPUT IN TEXT MODE ENCODING DEFAULT. "ML001
    IF sy-subrc <> 0.
      WRITE: / 'Kann Datei', poutfile, 'nicht öffnen'.
      ADD 1 TO num_errors.
    ELSE.
      DO.
        READ DATASET poutfile INTO recout.
        IF sy-subrc NE 0.  EXIT.  ENDIF.
        WRITE: / recout(150).
      ENDDO.
      CLOSE DATASET poutfile.
    ENDIF.
    SKIP.
  ENDIF.

* Falls Fehler aufgetreten sind wird die Ausgabedatei gelöscht.
  IF num_errors > 0.
    WRITE: / 'Ausgabedatei wird aufgrund von Fehlern während der',
             'Verarbeitung gelöscht.'.
    DELETE DATASET poutfile.
    IF sy-subrc <> 0.
      WRITE: / 'Fehler beim Löschen der Ausgabedatei.'.
    ENDIF.
  ENDIF.

* Zur Aktualisierung der Uhrzeit ein 'commit work'...
  COMMIT WORK.
  SKIP.
  IF showsart = 'X'.
    PERFORM: list_satzarten.
  ENDIF.
  IF showhetr = 'X'.
    PERFORM: list_headers,
             list_trailers.
  ENDIF.
  WRITE: / 'Ende der Verarbeitung:', sy-uzeit.
  SKIP.
*   WRITE: / 'Vielen Dank für die Benutzung der SAP-DP',
*            'Delta Komponente !'.
ENDFORM. "compare_files
*&---------------------------------------------------------------------*
*&      Form  CUT_LAST_CHARS "SIE005
*&---------------------------------------------------------------------*
*       Schneidet übergebene Anzahl Zeichen von einem String ab
*----------------------------------------------------------------------*
FORM cut_last_chars USING anzahl
                    CHANGING text.
  DATA: h_pos LIKE sy-fdpos.
  h_pos = STRLEN( text ) - anzahl.
  text = text(h_pos).

ENDFORM.                    " CUT_LAST_CHARS
*&---------------------------------------------------------------------*
*&      Form  INIT_RECS                       SIE008
*&---------------------------------------------------------------------*
*       Gleicht die Satzarten zwischen Current- und Lastdatei ab
*----------------------------------------------------------------------*
FORM init_recs.

  DATA: h_rest  TYPE i,
        h_tabix LIKE sy-tabix,
        h_satz  TYPE satzart_type.

  SORT satzarten BY index ASCENDING.

  LOOP AT satzarten.

*     Nur ungeraden Tabellenindex berücksichtigen
    h_rest = sy-tabix MOD 2.
    CHECK h_rest = 1.

*     Wenn kein korrespondierender Satz vorhanden,
    h_tabix = sy-tabix + 1.
    LOOP AT satzarten FROM h_tabix
                      INTO h_satz
                      WHERE name = satzarten-name.
    ENDLOOP.
    IF sy-subrc <> 0.
*        ... dann diesen neu erstellen.
      CLEAR h_satz.
      h_satz = satzarten.
      IF h_satz-is_curr = 'X'.
        CLEAR h_satz-is_curr.
      ELSE.
        h_satz-is_curr = 'X'.
      ENDIF.
      INSERT h_satz INTO satzarten INDEX h_tabix.
    ENDIF.

  ENDLOOP.

*SIE009_BEG

* Index neu vergeben:
  SORT satzarten BY name ASCENDING is_curr DESCENDING.
  LOOP AT satzarten.
    satzarten-index = sy-tabix / 2.
    MODIFY satzarten.
  ENDLOOP.

*SIE009_END

ENDFORM.                    " INIT_RECS
