PROCESS BEFORE OUTPUT.
  MODULE set_crypt.
  MODULE modify_screen.

PROCESS AFTER INPUT.
  MODULE modify_screen.


  CHAIN.
    FIELD: /sie/hr_idp_s1df-filen,
           /sie/hr_idp_s1df-hostn,
           /sie/hr_idp_s1df-tcpip,
           /sie/hr_idp_s1df-portn,
           /sie/hr_idp_s1df-trfad,
           /sie/hr_idp_s1df-itype,
           /sie/hr_idp_s1df-encry,
           /sie/hr_idp_s1df-sftp_user,
           /sie/hr_idp_s1df-sftp_publickey,
           /sie/hr_idp_s1df-sftp_zielverzeichnis,
           /sie/hr_idp_s1df-sftp_transfer,
           /sie/hr_idp_s1df-openft_transfer,
           /sie/hr_idp_s1df-sftp_configfile.
  ENDCHAIN.

  FIELD /sie/hr_idp_s1df-itype MODULE check_itype.

  FIELD /sie/hr_idp_s1df-trfad MODULE validate_trfad ON INPUT.
  FIELD /sie/hr_idp_s1df-tcpip MODULE validate_ip ON INPUT.
