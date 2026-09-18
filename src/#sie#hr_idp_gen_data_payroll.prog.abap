*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_GEN_DATA_PAYROLL                               *
*----------------------------------------------------------------------*

TABLES: DD40L.

DATA: PAYROLL_RESULT TYPE PAYDE_RESULT
    ,  C_CLUSTERID TYPE RELID_PCL2 VALUE 'RD'
    , MESSAGE_TEXT TYPE SYLISEL
    , VALUE(100)
    , DDIC_STRUCTURE TYPE TABNAME
    , OFFSET TYPE I
    , LENGTH TYPE I
    , BUFFER(3600)
    , LEN TYPE I
    , OLEN TYPE I
    , TYP TYPE C
    , DEC TYPE I
    , OTYPE TYPE C   " Objekttyp u, h
    .

FIELD-SYMBOLS: <RESULT>
             , <TABLE> TYPE TABLE
             , <STRUCTURE>
             , <FIELD>
             .

DATA: OBJECTS TYPE STANDARD TABLE OF HRPYSTRUC INITIAL SIZE 0
              WITH HEADER LINE.
