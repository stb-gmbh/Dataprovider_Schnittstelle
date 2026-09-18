*&---------------------------------------------------------------------*
*& Modulpool         /SIE/HR_IDP_IFC                                   *
*&---------------------------------------------------------------------*
*& Modulpool zur Schnittstellen-Anzeige und -Pflege                    *
*&---------------------------------------------------------------------*
*SIE001 29.03.2004 Hierl    Neue Option "kein Trennzeichen" CR 4199
*SIE002 12.05.2004 Hierl    Neue Funktion "Schnittstelle referenzieren"
*                           CR 4258
*SIE003 17.06.2004 Hierl    Neue Tabelle S1PS für Filter auf
*                           Feldebene eingebaut CR 4258
*SIE004 12.10.2004 Hierl    Kennzeichen zum Deaktivieren der globalen
*                           Selektion eingebaut CR 4708
*SIE005 14.03.2005 Hierl    Neue Funktion "Satzarten kopieren" CR4258
*                           Korrektur, dass die Eingabe einer fehlerhaften
*                           Referenzschnittstelle auf entsprechendem Popup
*                           trotz Abbrechen übernommen wird
*SIE006 18.03.2005 Hierl    neues Selektionskriterium P0203-ZZSEL CR4697
*                           (für SCD-Schnittstelle benötigt)
*SIE007 04.05.2005 Hierl    Kennzeichen zum Deaktivieren der Selektion auf
*                           verschiedene Ministammsätze eingebaut CR 4185
*SIE008 27.03.2007 Hierl    neues Selektionskriterium P9008-ZZENTG_KTO
*                           CR 1301
*SIE009 07.03.2008 Hierl    Neue Funktionalität der Vorselektion über ein
*                           externes Programm bei den Selektionsvorgaben.
*                           CR 3076
*ah001 10.08.2009 Hannemann Ausschluss Ministammsatz #DC#  (CRQ 23109)
*                           IT9020 Art 4
*ah003: 08.02.2011 Hannemann globale Selektion auf ZAK Zeitarbeitskraefte
*                            CRQ 25795
*COL-27098 15.02.2024 Muzyka ZAK Rückbau
*
*COL-30157 10.01.2025 Erweiterung des SAP DP um SFTP-Transfermöglichkeit
*
*COL-40685 18.08.2025 Erweiterung der SAP DP Maske für den SFTP Versand (SFTP_CONFIGFILE)




INCLUDE /sie/hr_idp_ifc_top.  " Datendeklarationen
INCLUDE /sie/hr_idp_ifc_o01.  " SAP DP PBO Set Status und Modify Screen
INCLUDE /sie/hr_idp_ifc_i01.  " SAP DP PAI Exit- und User-Commands
INCLUDE /sie/hr_idp_ifc_f01 . " SAP DP Forms für alle Dynpros
INCLUDE /sie/hr_idp_ifc_f03 . " SAP DP Forms OK Codes
INCLUDE /sie/hr_idp_ifc_f04.  " SAP DP Help
INCLUDE /sie/hr_idp_ifc_f05.  " Transport
INCLUDE /sie/hr_idp_ifc_f06.  " Rollen
INCLUDE /sie/hr_idp_ifc_f07.  " Datenbankschnittstelle

* Includes für Dynpro 1000
INCLUDE /sie/hr_idp_ifc_o02.  " SAP DP PBO Module für Dynpros 0100,1000
INCLUDE /sie/hr_idp_ifc_i02.  " SAP DP PAI Dynpros 0100 und 1000
INCLUDE /sie/hr_idp_ifc_f02 . " SAP DP Forms Dynpro 1000

* Includes für Dynpro 1001
INCLUDE /sie/hr_idp_ifc_o11.  " SAP DP PBO Module Dynpro 1001
INCLUDE /sie/hr_idp_ifc_i11.  " SAP DP PAI Module Dynpro 1001
INCLUDE /sie/hr_idp_ifc_f11.  " SAP DP Forms Dynpro 1001

* Includes für Dynpro 1002
INCLUDE /sie/hr_idp_ifc_o12.  " SAP DP PBO Module Dynpro 1002
INCLUDE /sie/hr_idp_ifc_i12.  " SAP DP PAI Module Dynpro 1002
INCLUDE /sie/hr_idp_ifc_f12.  " SAP DP Forms Dynpro 1002

* Includes für Dynpro 1003
INCLUDE /sie/hr_idp_ifc_o13.  " SAP DP PBO Module Dynpro 1003
INCLUDE /sie/hr_idp_ifc_i13.  " SAP DP PAI Module Dynpro 1003
INCLUDE /sie/hr_idp_ifc_f13.  " SAP DP Forms Dynpro 1003

* Dynpro 0400
INCLUDE /sie/hr_idp_ifc_o04.
INCLUDE /sie/hr_idp_ifc_i04.
INCLUDE /sie/hr_idp_ifc_f08.

INCLUDE /sie/hr_idp_ifc_o14.
INCLUDE /sie/hr_idp_ifc_i14.
INCLUDE /sie/hr_idp_ifc_f14.

INCLUDE /sie/hr_idp_ifc15.

* Dynpro 0600
INCLUDE /sie/hr_idp_ifc_016.


INCLUDE /sie/hr_idp_ifc_o100.
INCLUDE /sie/hr_idp_ifc_i100.

INCLUDE /sie/hr_idp_ifc_read.
INCLUDE /sie/hr_idp_ifc_read_pbo.

INCLUDE /sie/hr_idp_ifc_o20.
INCLUDE /sie/hr_idp_ifc_i20.
INCLUDE /sie/hr_idp_ifc_f20.

INCLUDE /sie/hr_idp_ifc_d700.
INCLUDE /sie/hr_idp_ifc_d750.                              "SIE002

INCLUDE /sie/hr_idp_ifc_o06.

INCLUDE /sie/hr_idp_ifc_o700.
INCLUDE /sie/hr_idp_ifc_i700.
INCLUDE /sie/hr_idp_ifc_f700.

INCLUDE /sie/hr_idp_ifc_0500.
INCLUDE /sie/hr_idp_ifc_i500.
INCLUDE /sie/hr_idp_ifc_f500.

INCLUDE /sie/hr_idp_ifc_o3000.

INCLUDE /sie/hr_idp_ifc_i2000.

INCLUDE /sie/hr_idp_ifc_0800.
INCLUDE /sie/hr_idp_ifc_i800.

INCLUDE /sie/hr_idp_ifc_o4000.
INCLUDE /sie/hr_idp_ifc_i4000.
INCLUDE /sie/hr_idp_ifc_f4000.

INCLUDE /sie/hr_idp_ifc_i1005.
INCLUDE /sie/hr_idp_ifc_o1005.

INCLUDE /sie/hr_idp_ifc_i1203.
INCLUDE /sie/hr_idp_ifc_f1203.

INCLUDE /sie/hr_idp_ifc_i1003.
INCLUDE /sie/hr_idp_ifc_o1003.

INCLUDE /sie/hr_idp_ifc_i400.
INCLUDE /sie/hr_idp_f400.

INCLUDE /sie/hr_idp_o1004.
INCLUDE /sie/hr_idp_f1004.

INCLUDE /sie/hr_idp_authority.

INCLUDE /sie/hr_idp_f1005.

INCLUDE /sie/hr_idp_tran_status.

INCLUDE /sie/hr_idp_ifc_o1006.

INCLUDE /sie/hr_idp_ifc_i1006.

INCLUDE /sie/hr_idp_ifc_f1006.

INCLUDE /sie/hr_idp_ifc_i1103.

INCLUDE /sie/hr_idp_ifc_o200.

INCLUDE /sie/hr_idp_ifc_f1001.

INCLUDE /sie/hr_idp_ifc_o1007.

INCLUDE /sie/hr_idp_ifc_i1007.

INCLUDE /sie/hr_idp_ifc_i1000.

INCLUDE /sie/hr_idp_ifc_i2500.

INCLUDE /sie/hr_idp_ifc_o2500.

INCLUDE /sie/hr_idp_ifc_f2500.

INCLUDE /sie/hr_idp_ifc_i2510.

INCLUDE /sie/hr_idp_ifc_o2510.

INCLUDE /sie/hr_idp_ifc_f2510.

INCLUDE /sie/hr_idp_ifc_f750.
