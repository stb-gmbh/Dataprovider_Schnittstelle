PROCESS BEFORE OUTPUT.
* MODULE STATUS_1103.
MODULE set_radiob.
MODULE modify_screen.
MODULE modify_screen_1103.                                 "SIE002

*
PROCESS AFTER INPUT.
 CHAIN.
  FIELD /sie/hr_idp_s1df-uc4fr.
  FIELD /sie/hr_idp_s1df-uc4to.
  FIELD /sie/hr_idp_s1df-uc4dy.
  FIELD /sie/hr_idp_s1df-uc4nr.
  FIELD /sie/hr_idp_s1df-uc4pr.
  FIELD l_day.
  FIELD l_owndf.
 ENDCHAIN.

 CHAIN.
  FIELD /sie/hr_idp_s1df-uc4fr.
  FIELD /sie/hr_idp_s1df-uc4to.
  MODULE check_dates_1103 ON CHAIN-REQUEST.
 ENDCHAIN.

  CHAIN.
    FIELD: /sie/hr_idp_s1df-uc4dy, /sie/hr_idp_s1df-uc4pr,
           /sie/hr_idp_s1df-uc4nr, l_day, l_owndf.
    MODULE check_uc4_radio ON CHAIN-REQUEST.
  ENDCHAIN.

*  chain.
*    field: l_day, /sie/hr_idp_s1df-uc4dy.
*    field: l_owndf, /sie/hr_idp_s1df-uc4pr, /sie/hr_idp_s1df-uc4nr.
*    module validate_day on chain-request.
*  endchain.

CHAIN.
    FIELD: /sie/hr_idp_s1df-uc4nr,
           /sie/hr_idp_s1df-uc4pr.
    MODULE check_no_period ON CHAIN-REQUEST.
ENDCHAIN.












