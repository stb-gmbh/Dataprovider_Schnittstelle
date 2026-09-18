FUNCTION /SIE/HR_IDP_READ_VALIDITY_DATE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(INTERVAL) TYPE  /SIE/HR_IDP_MONTH_OFFSET
*"                             DEFAULT 2
*"       EXPORTING
*"             VALUE(DATE_TO) TYPE  /SIE/HR_IDP_VALID_TO
*"       TABLES
*"              TAB_INTERFACES STRUCTURE  /SIE/HR_IDP_MONITOR_GD
*"       CHANGING
*"             VALUE(DATE_FROM) TYPE  /SIE/HR_IDP_VALID_FROM
*"                             DEFAULT SY-DATUM
*"----------------------------------------------------------------------

  DATA: DATE_H TYPE D
        , L_WA_INTERFACES LIKE /SIE/HR_IDP_MONITOR_GD
        .

  PERFORM DAY_PLUS_MONTHS(SAPFP500)
          USING DATE_FROM INTERVAL DATE_TO.

* If the end date is less than the begin date then switch the dates
  IF DATE_TO < DATE_FROM.
    CLEAR DATE_H.
    DATE_H = DATE_FROM.
    DATE_FROM = DATE_TO.
    DATE_TO = DATE_H.
  ENDIF.

  CLEAR TAB_INTERFACES[].

  SELECT * FROM /SIE/HR_IDP_S1 WHERE VALID_TO   LE DATE_TO
                               AND   VALID_TO   GE DATE_FROM.

    CLEAR L_WA_INTERFACES.
    L_WA_INTERFACES-IFCID = /SIE/HR_IDP_S1-IFCID.
    L_WA_INTERFACES-VRSNR = /SIE/HR_IDP_S1-ACT_VERS_NR.
    L_WA_INTERFACES-ENDDA = /SIE/HR_IDP_S1-VALID_TO.
* Assert that we have not read an interface which is being edited
* and never has been released.
    CHECK L_WA_INTERFACES-VRSNR >< 0.

    CALL FUNCTION '/SIE/HR_IDP_VERSION_INFO'
         EXPORTING
              INTERFACE_ID = /SIE/HR_IDP_S1-IFCID
              VERSION      = /SIE/HR_IDP_S1-ACT_VERS_NR
         IMPORTING
              RC_ICON      = L_WA_INTERFACES-STATUS.

    APPEND L_WA_INTERFACES TO TAB_INTERFACES.

  ENDSELECT.

ENDFUNCTION.
