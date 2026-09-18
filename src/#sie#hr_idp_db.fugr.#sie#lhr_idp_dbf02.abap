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

*---------------------------------------------------------------------*
*       FORM RESET_BUFFER_VERS                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM RESET_BUFFER_VERS.

  CLEAR:
        BUFFERED-S1VN
       , BUFFERED-S1DF
       , BUFFERED-S1PG
       , BUFFERED-S1PS                                     "SIE003
       , BUFFERED-S1VT
       , BUFFERED-S1R
       , BUFFERED-S1F
       , BUFFERED-S1PR
       , BUFFERED-S1SA
       , BUFFERED-S1DL
       , BUFFERED-S1PC
       .

  CLEAR:
        FOUND-S1VN
       , FOUND-S1DF
       , FOUND-S1PG
       , FOUND-S1PG                                        "SIE003
       , FOUND-S1VT
       , FOUND-S1R
       , FOUND-S1F
       , FOUND-S1PR
       , FOUND-S1SA
       , FOUND-S1DL
       , FOUND-S1PC
       .

  CLEAR:
        DB_DATA-S1VN
       , DB_DATA-S1DF
       , BUFFERED-S1PR
       , DB_DATA-S1PG[]
       , DB_DATA-S1PS[]                                    "SIE003
       , DB_DATA-S1VT[]
       , DB_DATA-S1R[]
       , DB_DATA-S1F[]
       , DB_DATA-S1SA[]
       , DB_DATA-S1PC
       .

ENDFORM.

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
    CASE TABLE_NAME.
      WHEN '/SIE/HR_IDP_S1' OR '/SIE/HR_IDP_S1T'.           "#EC NOTEXT
        SELECT SINGLE * FROM (TABLE_NAME) INTO DB_DATA
                                         WHERE IFCID = OLD_IFCID.
      WHEN OTHERS.
        SELECT SINGLE * FROM (TABLE_NAME) INTO DB_DATA
                                          WHERE IFCID = OLD_IFCID
                                          AND   VRSNR = OLD_VRSNR.
    ENDCASE.
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
  ASSIGN NEW+KEY_LENGTH(LENGTH_OF_ADM) TO <ADM>.
  PERFORM SET_SYS CHANGING <MANDT>
                           <ADM>.
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
  IF TABLE_NAME EQ '/SIE/HR_IDP_S1LT'.
*    and <note_key> ne initial_note_key.
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
    IF TABLE_NAME = '/SIE/HR_IDP_S1LT'.
      SELECT * INTO TABLE DB_DATA FROM (TABLE_NAME)
               WHERE IFCID EQ OLD_IFCID
               ORDER BY PRIMARY KEY. "wg. HANA
*               and   spras eq sy-langu.
    ELSE.
      SELECT * INTO TABLE DB_DATA FROM (TABLE_NAME)
               WHERE IFCID EQ OLD_IFCID
               AND   VRSNR EQ OLD_VRSNR
               ORDER BY PRIMARY KEY. "wg. hana
    ENDIF.
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
*  refresh: ifc_i, ifc_u, ifc_d.
  CLEAR: IFC_I[], IFC_U[], IFC_D[].
  ASSIGN OLD(KEY_LENGTH) TO <IFC_KEY>.
  loop at old.
    READ TABLE NEW BINARY SEARCH WITH KEY <IFC_KEY>.
    if sy-subrc ne 0.
      IFC_D = OLD. APPEND IFC_D.
    else.
      if old ne new.
        IFC_U = NEW. APPEND IFC_U.
      else.
*Bei Dokumentation immer die Zeile 00000 wegen ADM Include updaten
*        if table_name eq '/SIE/HR_IDP_S1LT'.
*          assign old(note_key_length)
*                 to <note_key>.
*          if <note_key> eq initial_note_key.
*            ifc_u = new. append ifc_u.
*          endif.
*        endif.
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
*    assign ifc_i+normal_key_length(length_of_note_key)
*           to <note_key>.
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
      ASSIGN IFC_U+KEY_LENGTH(LENGTH_OF_ADM) TO <ADM>.
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

  IF TABLE_NAME = '/SIE/HR_IDP_S1LT'.
    LOOP AT NEW.
      <MANDT> = SY-MANDT.
      MODIFY NEW.
    ENDLOOP.
    INSERT (TABLE_NAME) FROM TABLE NEW.
    IF SY-SUBRC NE 0. SUCCESS = NO. ENDIF.
  ELSE.
    assign new+normal_key_length(length_of_note_key)
           to <note_key>.
    ASSIGN NEW+KEY_LENGTH(LENGTH_OF_ADM) TO <ADM>.
    loop at new.
      PERFORM SET_SYS CHANGING <MANDT> <ADM>.
      modify new.
    endloop.
    insert (table_name) from table new.
    if sy-subrc ne 0. success = no. endif.
  ENDIF.
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
    CASE TABLE_NAME.
      WHEN '/SIE/HR_IDP_S1' OR '/SIE/HR_IDP_S1T'.         "#EC NOTEXT
        SELECT SINGLE * FROM (TABLE_NAME) INTO DB_DATA
                        WHERE IFCID EQ OLD_IFCID.

      WHEN OTHERS.
        SELECT SINGLE * FROM (TABLE_NAME) INTO DB_DATA
                        WHERE IFCID EQ OLD_IFCID
                        AND   VRSNR EQ OLD_VRSNR.
    ENDCASE.
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
    CASE TABLE_NAME.
      WHEN '/SIE/HR_IDP_S1LT'.
        SELECT * INTO TABLE DB_DATA FROM (TABLE_NAME)
                 WHERE SPRAS = SY-LANGU
                 AND   IFCID = OLD_IFCID
                 ORDER BY PRIMARY KEY. "wg. hana
      WHEN OTHERS.
        SELECT * INTO TABLE DB_DATA FROM (TABLE_NAME)
                 WHERE IFCID EQ OLD_IFCID
                 AND VRSNR EQ OLD_VRSNR
                 ORDER BY PRIMARY KEY.
    ENDCASE.
    if sy-subrc eq 0.
      FOUND_FLAG = YES. " Ja, gefunden
      TR_DATA[] = DB_DATA[].
    else.
      CLEAR DBSEL_FLAG. " Nein, nicht gefunden
      REFRESH TR_DATA.
    endif.
  endif.
ENDFORM.                    " GET_DATAX
