*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_GENERATORF15 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  PROCESS_SD_INCLUDE
*&---------------------------------------------------------------------*
*       Generierung von Code zum Erstellen eines Sendeauftrages
*----------------------------------------------------------------------*
FORM PROCESS_SD USING VALUE(P_IFCID) TYPE /SIE/HR_IDP_INTERFACE_ID
                      VALUE(P_VRSNR) TYPE /SIE/HR_IDP_VERS_NR.

  DATA:
    TAG       TYPE /SIE/HR_IDP_TT_CODING,
    INPUT     TYPE /SIE/HR_IDP_TT_CODING,
    RESULT     TYPE /SIE/HR_IDP_TT_CODING.

  PERFORM GET_TAG USING 'sd_forms' CHANGING TAG.
  PERFORM REPLACE_PARAM USING 'IFCID'
                               P_IFCID
                               TAG
                        CHANGING RESULT.
  MOVE RESULT[] TO INPUT[].
  PERFORM REPLACE_PARAM USING 'VRSNR'
                               P_VRSNR
                               INPUT
                        CHANGING RESULT.

  PERFORM INSERT_CODE USING RESULT.

*$<sd_forms>
*$
*$   call function '/SIE/HR_IDP_GENERATE_SD'
*$        exporting
*$             interface_id = '&IFCID'
*$             version      = '&VRSNR'
*$             file_name    = dsn
*$             sd_file_name = sd
*$             adhoc_exec   = p_adhoc
*$*       EXCEPTIONS
*$*            FAILED       = 1
*$*            OTHERS       = 2
*$             .
*$   if sy-subrc <> 0.
*$     perform set_error.
*$     perform compose_message using '&IFCID'.
*$  endif.
*$
*$* Sendedatei bei Ad-HOC Läufen an Aufrufendes Programm mitteilen!
*$ if p_adhoc = 'X'. "#EC NOTEXT
*$   export sd to memory id 'SAP_DP'.
*$ endif.
*$</sd_forms>
ENDFORM.                    " PROCESS_SD_INCLUDE
