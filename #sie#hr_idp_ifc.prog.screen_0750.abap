PROCESS BEFORE OUTPUT.
 MODULE set_pf_status_750.
 MODULE init.                               " Wird von allen aufgerufen
 MODULE init_0750.
 MODULE MODIFY_SCREEN.

PROCESS AFTER INPUT.
 MODULE user_command_0750.
 MODULE exit_command_0750 AT EXIT-COMMAND.

 FIELD /sie/hr_idp_s1dl-referenz MODULE CHECK_INPUT_750 ON INPUT.

 MODULE ok_code_750.
















