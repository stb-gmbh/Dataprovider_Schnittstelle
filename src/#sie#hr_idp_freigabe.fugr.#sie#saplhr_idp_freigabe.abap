*******************************************************************
*   System-defined Include-files.                                 *
*******************************************************************
  INCLUDE /SIE/LHR_IDP_FREIGABETOP.          " Global Data
  INCLUDE /SIE/LHR_IDP_FREIGABEUXX.          " Function Modules

*******************************************************************
*   User-defined Include-files (if necessary).                    *
*******************************************************************
* INCLUDE /SIE/LHR_IDP_FREIGABEF...          " Subprograms
* INCLUDE /SIE/LHR_IDP_FREIGABEO...          " PBO-Modules
* INCLUDE /SIE/LHR_IDP_FREIGABEI...          " PAI-Modules

  INCLUDE /SIE/LHR_IDP_FREIGABEF01.
  INCLUDE /SIE/LHR_IDP_FREIGABEF02.
  INCLUDE /SIE/LHR_IDP_FREIGABEF03.

  INCLUDE /SIE/HR_IDP_ERR.

  INCLUDE /SIE/LHR_IDP_FREIGABEO01.
  INCLUDE /SIE/LHR_IDP_FREIGABEI01.

  AT USER-COMMAND.
    OKCODE = SY-UCOMM.
    PERFORM USER_COMMAND.
