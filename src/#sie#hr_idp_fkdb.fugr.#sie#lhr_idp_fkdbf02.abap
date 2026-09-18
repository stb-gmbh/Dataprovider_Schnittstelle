*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_DBF02 .
*----------------------------------------------------------------------*

INCLUDE /SIE/HR_IDP_UT_FCAT_MAC.   " Macros

*&---------------------------------------------------------------------*
*&      Form  RESET_BUFFER
*&---------------------------------------------------------------------*
FORM RESET_BUFFER.

  CLEAR: BUFFERED
       , FOUND
       , DB_DATA
       .

ENDFORM.                    " RESET_BUFFER

*&---------------------------------------------------------------------*
*&      Form  MOD_WA
*&---------------------------------------------------------------------*
*       Diese Form routine ändert die Schnittstellendaten auf der
*       Datenbank "auf höchster Ebene". Zuerst wird überprüft,
*       ob es sich um ein Insert oder ein Update handelt und dann
*       werden die entsprechenden "unteren" Routinen aufgerufen.
*----------------------------------------------------------------------*
FORM MOD_WA CHANGING DB_DATA                     " Alte Daten
                     TR_DATA                     " Neue Daten
                     DBSEL_FLAG TYPE TY_YESNO
                     BUFFERED_FLAG TYPE TY_YESNO
                     FOUND_FLAG TYPE TY_YESNO.

  IF BUFFERED_FLAG EQ YES.
    IF FOUND_FLAG EQ YES.
      PERFORM UPDATE_DATA USING DB_DATA
                          CHANGING TR_DATA
                          DBSEL_FLAG.             " Erfolreich?
    ELSE.
      PERFORM INSERT_DATA CHANGING TR_DATA
                                   DBSEL_FLAG.    " Erfolreich?
    ENDIF.
  ELSE.  "Bis jetzt nicht gepuffert
    BUFFERED_FLAG = YES.
    SELECT SINGLE * FROM (TABLE_NAME) INTO DB_DATA
                                      WHERE FELDNAME = OLD_FELDNAME.
    IF SY-SUBRC = 0.
      FOUND_FLAG = YES.
      PERFORM UPDATE_DATA USING DB_DATA
                          CHANGING TR_DATA
                                   DBSEL_FLAG.
    ELSE.
      PERFORM INSERT_DATA CHANGING TR_DATA
                                   DBSEL_FLAG.
    ENDIF.
  ENDIF.
  IF DBSEL_FLAG = YES.  " Erfolgreich?
    FOUND_FLAG = YES.  " Ja
    DB_DATA = TR_DATA.  " Puffer synchronisieren
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.                    " MOD_WA

*&---------------------------------------------------------------------*
*&      Form  UPDATE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DB_DATA  text
*      <--P_TR_DATA  text
*      <--P_DBSEL_FLAG  text
*----------------------------------------------------------------------*
FORM UPDATE_DATA USING VALUE(OLD)
                 CHANGING NEW
                          SUCCESS.
  CHECK OLD NE NEW.
  ASSIGN NEW(3) TO <MANDT>.
  CASE TABLE_NAME.
    WHEN '/SIE/HR_IDP_S1T'.
* Die Leiste hat keine ADM Informationen
      <MANDT> = SY-MANDT.
    WHEN OTHERS.
      ASSIGN NEW+KEY_LENGTH(LENGTH_OF_ADM) TO <ADM>.
      PERFORM SET_SYS CHANGING <MANDT>
                               <ADM>.
  ENDCASE.
  UPDATE (TABLE_NAME) FROM NEW.
  IF SY-SUBRC NE 0. SUCCESS = NO. ENDIF.

ENDFORM.                    " UPDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  INSERT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_TR_DATA  text
*      <--P_DBSEL_FLAG  text
*----------------------------------------------------------------------*
FORM INSERT_DATA CHANGING NEW
                          SUCCESS.

  ASSIGN NEW(3) TO <MANDT>.
  ASSIGN NEW+KEY_LENGTH(LENGTH_OF_ADM) TO <ADM>.
  PERFORM SET_SYS CHANGING <MANDT>
                           <ADM>.
  INSERT (TABLE_NAME) FROM NEW.
  IF SY-SUBRC NE 0. SUCCESS = NO. ENDIF.

ENDFORM.                    " INSERT_DATA

*---------------------------------------------------------------------*
*       FORM SET_SYS                                                  *
*---------------------------------------------------------------------*
*       Setzt den Mandanten und die Änderungsinformationen gleich     *
*       in die Datenbanktabelle ein.                                  *
*---------------------------------------------------------------------*
*  <->  MANDT Mandant                                                 *
*  <->  ADMIN Ersteller/Letzter Änderer                               *
*---------------------------------------------------------------------*
FORM SET_SYS CHANGING MANDT LIKE SY-MANDT
                      ADMIN LIKE /SIE/HR_IDP_ADM.

  MANDT = SY-MANDT.
  IF TABLE_NAME EQ '/SIE/HR_IDP_S1LT'
    AND <NOTE_KEY> NE INITIAL_NOTE_KEY.
  ELSE.
    FILL_ADM_INFO ADMIN.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MOD_TAB
*&---------------------------------------------------------------------*
*       Diese Form Routine aktualisiert die DB und ist auf Tabellen
*       spezialisiert im Gegensatz zu MOD_WA.
*----------------------------------------------------------------------*
FORM MOD_TAB TABLES   DB_DATA    " Alte Daten
                      TR_DATA    " Neue Daten
             CHANGING DBSEL_FLAG TYPE TY_YESNO
                      BUFFERED_FLAG TYPE TY_YESNO
                      FOUND_FLAG TYPE TY_YESNO.

  IF BUFFERED_FLAG EQ YES.
    IF FOUND_FLAG EQ YES.
      PERFORM UPDATE_DATAX TABLES  DB_DATA
                                   TR_DATA
                           CHANGING DBSEL_FLAG.
    else.
      PERFORM INSERT_DATAX TABLES   TR_DATA
                           CHANGING DBSEL_FLAG.
    endif.
  ELSE.
    BUFFERED_FLAG = YES.
    SELECT * INTO TABLE DB_DATA FROM (TABLE_NAME)
             WHERE FELDNAME EQ OLD_FELDNAME
            ORDER BY PRIMARY KEY. "wg hana
    if sy-subrc eq 0.
      FOUND_FLAG = YES. "indicate found
      PERFORM UPDATE_DATAX TABLES  DB_DATA
                                   TR_DATA
                           CHANGING DBSEL_FLAG.
    else.
      PERFORM INSERT_DATAX TABLES TR_DATA
                           CHANGING DBSEL_FLAG.
    endif.
  endif.
  IF DBSEL_FLAG EQ YES.
    FOUND_FLAG = YES.
    DB_DATA[] = TR_DATA[].
  else.
    rollback work.
  endif.
ENDFORM.                    " MOD_TAB


*---------------------------------------------------------------------*
*       FORM UPDATE_DATA                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  OLD                                                           *
*  -->  NEW                                                           *
*  -->  SUCCESS                                                       *
*---------------------------------------------------------------------*
FORM UPDATE_DATAX TABLES   OLD
                          NEW
                  CHANGING SUCCESS TYPE TY_YESNO.
  sort new.
  check old[] ne new[]. "something changed ?
  REFRESH: IFC_I, IFC_U, IFC_D.
  ASSIGN OLD(KEY_LENGTH) TO <IFC_KEY>.
  loop at old.
    READ TABLE NEW BINARY SEARCH WITH KEY <IFC_KEY>.
    if sy-subrc ne 0.
      IFC_D = OLD. APPEND IFC_D.
    else.
      if old ne new.
        IFC_U = NEW. APPEND IFC_U.
      else.
*Bei Dokumentatzion immer die Zeile 00000 wegen ADM Include updaten
        IF TABLE_NAME EQ '/SIE/HR_IDP_S1LT'.
          ASSIGN OLD+NORMAL_KEY_LENGTH(LENGTH_OF_NOTE_KEY)
                 to <note_key>.
          if <note_key> eq initial_note_key.
            IFC_U = NEW. APPEND IFC_U.
          endif.
        endif.
      endif.
    endif.
  endloop.
  ASSIGN NEW(KEY_LENGTH) TO <IFC_KEY>.
  loop at new.
    READ TABLE OLD BINARY SEARCH WITH KEY <IFC_KEY>.
    if sy-subrc ne 0.
      IFC_I = NEW. APPEND IFC_I.
    endif.
  endloop.
  DESCRIBE TABLE IFC_D LINES ITAB_LINES.
  if itab_lines gt 0.
    DELETE (TABLE_NAME) FROM TABLE IFC_D.
    if sy-subrc ne 0. success = no. exit. endif.
  endif.
  DESCRIBE TABLE IFC_I LINES ITAB_LINES.
  if itab_lines gt 0.
    ASSIGN IFC_I+NORMAL_KEY_LENGTH(LENGTH_OF_NOTE_KEY)
           to <note_key>.
    LOOP AT IFC_I.
      ASSIGN IFC_U+0(3) TO <MANDT>.
      ASSIGN IFC_I+KEY_LENGTH(LENGTH_OF_ADM) TO <ADM>.

      PERFORM SET_SYS CHANGING <MANDT>
                               <ADM>.
      MODIFY IFC_I.
    endloop.
    INSERT (TABLE_NAME) FROM TABLE IFC_I.
    if sy-subrc ne 0. success = no. exit. endif.
  endif.
  DESCRIBE TABLE IFC_U LINES ITAB_LINES.
  if itab_lines gt 0.
    ASSIGN IFC_U+NORMAL_KEY_LENGTH(LENGTH_OF_NOTE_KEY)
           to <note_key>.
    LOOP AT IFC_U.
      ASSIGN IFC_U+0(3) TO <MANDT>.
      ASSIGN IFC_I+KEY_LENGTH(LENGTH_OF_ADM) TO <ADM>.
      PERFORM SET_SYS CHANGING <MANDT>
                               <ADM>.
      MODIFY IFC_U.
    endloop.
    UPDATE (TABLE_NAME) FROM TABLE IFC_U.
    if sy-subrc ne 0. success = no. exit. endif.
  endif.
ENDFORM.                    " update_data

*---------------------------------------------------------------------*
*       FORM INSERT_DATA                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  NEW                                                           *
*  -->  SUCCESS                                                       *
*  -->  assign                                                        *
*  -->  new(3)                                                        *
*  -->  to                                                            *
*  -->  <mandt>                                                       *
*---------------------------------------------------------------------*
FORM INSERT_DATAX TABLES   NEW
                  CHANGING SUCCESS TYPE TY_YESNO.
  assign new(3) to <mandt>.
  assign new+normal_key_length(length_of_note_key)
         to <note_key>.
  ASSIGN NEW+KEY_LENGTH(LENGTH_OF_ADM) TO <ADM>.
  loop at new.
    PERFORM SET_SYS CHANGING <MANDT> <ADM>.
    modify new.
  endloop.
  insert (table_name) from table new.
  if sy-subrc ne 0. success = no. endif.
ENDFORM.                    " insert_data

*---------------------------------------------------------------------*
*       FORM GET_DATA                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  TR_DATA                                                       *
*  -->  DB_DATA                                                       *
*  -->  DBSEL_FLAG                                                    *
*  -->  BUFFERED_FLAG                                                 *
*  -->  FOUND_FLAG                                                    *
*---------------------------------------------------------------------*
FORM GET_DATA CHANGING TR_DATA
                       DB_DATA
                       DBSEL_FLAG    TYPE TY_YESNO
                       BUFFERED_FLAG TYPE TY_YESNO
                       FOUND_FLAG    TYPE TY_YESNO.
  IF BUFFERED_FLAG  EQ YES.
    IF FOUND_FLAG  EQ YES.
      TR_DATA  = DB_DATA.
    else.
      CLEAR DBSEL_FLAG .
      CLEAR TR_DATA .
    endif.
  ELSE.
    BUFFERED_FLAG  = YES.
    SELECT SINGLE * FROM (TABLE_NAME) INTO DB_DATA
                    WHERE FELDNAME EQ OLD_FELDNAME.
    if sy-subrc eq 0.
      FOUND_FLAG  = YES.
      TR_DATA  = DB_DATA.
    else.
      CLEAR DBSEL_FLAG .
      CLEAR TR_DATA .
    endif.
  endif.
endform.                    " GET_VVNN

*---------------------------------------------------------------------*
*       FORM GET_DATAX                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  TR_DATA                                                       *
*  -->  DB_DATA                                                       *
*  -->  DBSEL_FLAG                                                    *
*  -->  BUFFERED_FLAG                                                 *
*  -->  FOUND_FLAG                                                    *
*---------------------------------------------------------------------*
FORM GET_DATAX TABLES   TR_DATA
                        DB_DATA
               CHANGING DBSEL_FLAG TYPE TY_YESNO
                        BUFFERED_FLAG TYPE TY_YESNO
                        FOUND_FLAG TYPE TY_YESNO.
  IF BUFFERED_FLAG EQ YES.
    IF FOUND_FLAG EQ YES.
      TR_DATA[] = DB_DATA[].
    else.
      CLEAR DBSEL_FLAG.  " Nicht gefunden
      REFRESH TR_DATA.
    endif.
  ELSE. "Bis jetzt nicht gepuffert
    BUFFERED_FLAG = YES. " Pufferung merken
        SELECT * INTO TABLE DB_DATA FROM (TABLE_NAME)
                 WHERE FELDNAME EQ OLD_FELDNAME
                 ORDER BY PRIMARY KEY.
    if sy-subrc eq 0.
      FOUND_FLAG = YES. " Ja, gefunden
      TR_DATA[] = DB_DATA[].
    else.
      CLEAR DBSEL_FLAG. " Nein, nicht gefunden
      REFRESH TR_DATA.
    endif.
  endif.
ENDFORM.                    " GET_DATAX
