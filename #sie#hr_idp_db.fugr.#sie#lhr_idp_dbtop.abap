*Änderungen:
*   SIE001 Hierl 17.06.04 Neue Tabelle /SIE/HR_IDP_S1PS
*                         aufgenommen. CR 4258
*                         Thema "Filter auf Feldebene"

FUNCTION-POOL /SIE/HR_IDP_DB MESSAGE-ID /SIE/HR_IDP_MESSAGES.

TABLES: /SIE/HR_IDP_S1.

* Globale Typendefinitionen
INCLUDE /SIE/HR_IDP_TYPES.

* Informationen zum letzten änderer
INCLUDE /SIE/HR_IDP_ADMIN00.

* Feldsymbole zum setzen von Systeminformationen
FIELD-SYMBOLS: <MANDT> LIKE SY-MANDT
             , <NOTE_KEY>
             .

DATA: TABLE_NAME LIKE DD02L-TABNAME VALUE '/SIE/HR_IDP_Snxx'.

* Internal buffer with workareas
DATA: DB_DATA TYPE /SIE/HR_IDP_IFC_DB
    , OLD_IFCID TYPE /SIE/HR_IDP_INTERFACE_ID
    , OLD_VRSNR TYPE /SIE/HR_IDP_VERS_NR
    .

* Buffer directory
DATA: BUFFERED LIKE /SIE/HR_IDP_DB_SEL
    , FOUND LIKE /SIE/HR_IDP_DB_SEL
    .

* Hilfsfelder um datenbank insert/update/delete operationen zu
* ermöglichen
DATA: IFC_I TYPE STANDARD TABLE OF /SIE/HR_IDP_DB_GENERIC
            INITIAL SIZE 10 WITH HEADER LINE
     , IFC_U TYPE STANDARD TABLE OF /SIE/HR_IDP_DB_GENERIC
            INITIAL SIZE 10 WITH HEADER LINE
     , IFC_D TYPE STANDARD TABLE OF /SIE/HR_IDP_DB_GENERIC
            INITIAL SIZE 10 WITH HEADER LINE
     , ITAB_LINES TYPE I
     .

FIELD-SYMBOLS: <IFC_KEY>.

CONSTANTS: NORMAL_KEY_LENGTH TYPE I VALUE 18
         , TEXT_KEY_LENGTH TYPE I VALUE 19
         , VERS_KEY_LENGTH TYPE I VALUE 22
         , DEFI_KEY_LENGTH TYPE I VALUE 22
         , PROG_KEY_LENGTH TYPE I VALUE 33
         , FILT_KEY_LENGTH type i value 36                 "SIE001
         , SPEC_KEY_LENGTH TYPE I VALUE 45
         , ROLE_KEY_LENGTH TYPE I VALUE 24
         , NOTE_KEY_LENGTH TYPE I VALUE 23
         , MODI_KEY_LENGTH TYPE I VALUE 24
         , S1SA_KEY_LENGTH TYPE I VALUE 30
         , PARA_KEY_LENGTH TYPE I VALUE 22
         , DELIM_KEY_LENGTH TYPE I VALUE 22
         , PRICE_KEY_LENGTH TYPE I VALUE 22
         , LENGTH_OF_NOTE_KEY TYPE I VALUE 1
         .
