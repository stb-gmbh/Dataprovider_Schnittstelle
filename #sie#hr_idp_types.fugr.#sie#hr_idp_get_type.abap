FUNCTION /SIE/HR_IDP_GET_TYPE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(LOGICAL_FIELD) TYPE  /SIE/HR_IDP_FNAME
*"  EXPORTING
*"     VALUE(EXTERNAL_TYPE) TYPE  DYNPTYPE
*"     VALUE(LENGTH) TYPE  DDLENG
*"     VALUE(DB_LENGTH) TYPE  DDLENG
*"     VALUE(INTERNAL_TYPE) TYPE  INTTYPE
*"     VALUE(DECIMALS) TYPE  DECIMALS
*"     VALUE(SIGNFLAG) TYPE  SIGNFLAG
*"  EXCEPTIONS
*"      TYPE_UNDEFINED
*"      TYPE_NOT_FOUND
*"----------------------------------------------------------------------

* Ermittlung des Typs des logischen Feldnamens.
  PERFORM READ_FIELDNAME_TYPE USING LOGICAL_FIELD
                              CHANGING INTERNAL_TYPE
                                       LENGTH
                                       DB_LENGTH
                                       EXTERNAL_TYPE
                                       DECIMALS
                                       SIGNFLAG.

  IF EXTERNAL_TYPE IS INITIAL.
    MESSAGE E235 WITH LOGICAL_FIELD RAISING TYPE_NOT_FOUND.
  ENDIF.

ENDFUNCTION.
