FUNCTION /SIE/HR_IDP_AUTH_CHECK.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(TRANSACTION) TYPE  TCODE OPTIONAL
*"             VALUE(ACTIVITY) TYPE  /SIE/HR_IDP_ACTIVITY
*"             VALUE(IF_CLASS) TYPE  /SIE/HR_IDP_AUTH_CLASS
*"             VALUE(OBJECT) TYPE  /SIE/HR_IDP_AUTH_CLASS
*"             VALUE(SUBOBJECT) DEFAULT SPACE
*"       EXCEPTIONS
*"              NO_AUTHORITY
*"----------------------------------------------------------------------

* Erste Chance: Prüfen auf Individualstrategie
  AUTHORITY-CHECK OBJECT 'Z_IFCID'
   ID 'ZAUTHC'   FIELD SPACE
   ID 'ZOBJECT'  FIELD OBJECT
   ID 'ZSUBOBJ'   FIELD SUBOBJECT
   ID 'ZACTIVITY' FIELD ACTIVITY.
  CASE SY-SUBRC.
    WHEN 0.
* Benutzer hat die Berechtigung
    WHEN 4 OR 12 OR 16 OR 24.
* Zweite Chance: Prüfen auf Klassifikationsstrategie
      AUTHORITY-CHECK OBJECT 'Z_IFCID'
       ID 'ZAUTHC'   FIELD IF_CLASS
       ID 'ZOBJECT'  FIELD SPACE
       ID 'ZSUBOBJ'   FIELD SUBOBJECT
       ID 'ZACTIVITY' FIELD ACTIVITY.
      CASE SY-SUBRC.
        WHEN 0.
* Der Benutzer hat eine Berechtigung
        WHEN 4 OR 12 OR 16 OR 24.
* Der Benutzer hat keine Berechtigung
          MESSAGE E555 RAISING NO_AUTHORITY.
        WHEN 8.
* Interner Fehler = Programmfehler
          MESSAGE X556.
        WHEN OTHERS.
          MESSAGE E557 RAISING NO_AUTHORITY.
      ENDCASE.
    WHEN 8.
* Interner Fehler = Programmfehler
      MESSAGE X556.
    WHEN OTHERS.
      MESSAGE E557 RAISING NO_AUTHORITY.
  ENDCASE.

ENDFUNCTION.
