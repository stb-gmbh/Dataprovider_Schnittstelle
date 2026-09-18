*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_ADMIN00                                        *
*----------------------------------------------------------------------*

* Informationen zum letzten Änderer zur Bearbeitung aller *idp* Tabellen

TABLES: /SIE/HR_IDP_ADM.

FIELD-SYMBOLS: <ADM> STRUCTURE /SIE/HR_IDP_ADM DEFAULT /SIE/HR_IDP_ADM.

DATA: KEY_LENGTH TYPE I.

CONSTANTS: LENGTH_OF_ADM TYPE I VALUE 132 "  =2*(12+8+6+40)
         , INITIAL_NOTE_KEY(15) VALUE '          00000'.
         .
