*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_UTFIELDCATALOG_F01                             *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM FIND_NAME                                                *
*---------------------------------------------------------------------*
*       Deses Form baut den Namen einer DDIC Struktur eines Inftypen  *
*---------------------------------------------------------------------*
*  -->  REFERENCE(INFTY) Name des Infotypen (Nummer)                  *
*  -->  INFTY_DDIC       Name der Struktur                            *
*---------------------------------------------------------------------*
FORM FIND_NAME USING VALUE(INFTY) TYPE INFOTYP
               CHANGING INFTY_DDIC TYPE DDOBJNAME.

  CONCATENATE 'PS' INFTY INTO INFTY_DDIC.                  "# EC NOTEXT

ENDFORM.
