*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_GEN_DATA_LOG                                   *
*----------------------------------------------------------------------*

**** Datendeklarationen für Protokolle, Statistik und Fehler ****
TABLES: /SIE/HR_IDP_S1P
      , /SIE/HR_IDP_S1L
      , /SIE/HR_IDP_S1S
      .

DATA: SELPN TYPE /SIE/HR_IDP_SELPN   " Anzahl selektierte Personen
    , NUMBR TYPE /SIE/HR_IDP_NUMBR   " Anzahl Sätze
    , _BEGDA TYPE BEGDA               " Beginn Datum
    , _BEGUZ TYPE BEGUZ               " Beginn Uhrzeit
    , SEQNO TYPE /SIE/HR_IDP_SEQNO   " Aktuelle Laufnummer
    , FL_EMAIL TYPE XFLAG            " Falls email Versendet wurd
    , FL_ERROR TYPE XFLAG            " Falls Fehler entdesckt wurde
    , G_S1S TYPE STANDARD TABLE OF /SIE/HR_IDP_S1S
            INITIAL SIZE 0
            WITH HEADER LINE
    , G_S1L_IDX TYPE I
    .
