*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_O02 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  READ_S1VN_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       Dieses Modul liest die Schnittstellenkopfdaten und Versionen
*----------------------------------------------------------------------*
MODULE READ_S1VN_DATA OUTPUT.

  DATA: RET_CODE LIKE SY-SUBRC.

  G_IFDATA_OLDV =  G_IFDATA_TRAN-S1-IFCID.

  CLEAR G_IFDATA_1000.
  CALL FUNCTION '/SIE/HR_IDP_DB_READ_S1VN'
       EXPORTING
            INTERFACE      = /SIE/HR_IDP_HEAD-IFCID
*           interface      = g_ifdata_oldv
       IMPORTING
            INTERFACE_DATA = G_IFDATA_1000
       EXCEPTIONS
            NO_DATA        = 1
            OTHERS         = 2.
  RET_CODE = SY-SUBRC.

* Erster Eintritt in die Transaktion, nichts im Hauptspeicher
  IF G_IFDATA_TRAN-S1-IFCID IS INITIAL.
    MESSAGE I104(/SIE/HR_IDP_MESSAGES).
  ELSE.

    IF RET_CODE <> 0.
      PERFORM DEQUEUE.
      MESSAGE ID SY-MSGID TYPE 'W' NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
    ENDIF.
  ENDIF.

ENDMODULE.                 " READ_S1VN_DATA  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  FILL_VERSION_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       In diesem Modul werden die Versionen der Schnittstelle
*       eingelesen.
*----------------------------------------------------------------------*
MODULE FILL_VERSION_DATA OUTPUT.
  PERFORM FILL_VERSION_DATA.
  DESCRIBE TABLE G_T_VERS_0100 LINES TAB_LINES.
  TC_VERS-LINES = TAB_LINES.
ENDMODULE.                 " FILL_VERSION_DATA  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_VERSION  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
DATA: RC LIKE SY-SUBRC.

*---------------------------------------------------------------------*
*       MODULE FILL_VERSION OUTPUT                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE FILL_VERSION OUTPUT.

  IF G_IFDATA_VERS IS INITIAL.
    IF SY-STEPL = 1.
* Selektieren des ersten Eintrages, aber nur wenn schon eine
* Schnittstelle angegeben wurde oder diese angelegt wurde!
      IF NOT ( G_IFDATA_TRAN-S1-IFCID IS INITIAL ).
        PERFORM CHECK_EXISTANCE CHANGING RC.
        IF RC = 0.
          G_IFDATA_VERS = /SIE/HR_IDP_IFC_VERSIONS-VRSNR.
          /SIE/HR_IDP_IFC_VERSIONS-SELECTION = 'X'.
          FL_NEW_VERSION = NO.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    IF FL_NEW_VERSION = YES.
      FL_NEW_VERSION = NO.
      /SIE/HR_IDP_IFC_VERSIONS-SELECTION = 'X'.
      G_IFDATA_VERS = /SIE/HR_IDP_IFC_VERSIONS-VRSNR.
    ELSE.
      IF G_IFDATA_VERS = /SIE/HR_IDP_IFC_VERSIONS-VRSNR.
        /SIE/HR_IDP_IFC_VERSIONS-SELECTION = 'X'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " FILL_VERSION  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_NEW  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_NEW OUTPUT.
  IF G_IFDATA_OLDV NE G_IFDATA_TRAN-S1-IFCID.
    CLEAR G_PROC_VEC.
    SHOW_FIELD = SPACE.
    EXPORT SHOW_FIELD TO MEMORY ID '/SIE/HR_IDP_IFC'.
  ENDIF.
ENDMODULE.                 " CHECK_NEW  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_TRANSACTION  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_TRANSACTION OUTPUT.

  IF ( G_IFDATA_OLDV NE G_IFDATA_TRAN-S1-IFCID ).
    PERFORM DEQUEUE.
*<xft 25.10.2001>
    CLEAR G_IFDATA_VERS.
*</xft 25.10.2001>
  ENDIF.

  IF ( G_IFDATA_OLDV NE G_IFDATA_TRAN-S1-IFCID ) OR
     ( G_IFDATA_VERS NE OLD_VERSION ).

    OLD_VERSION = G_IFDATA_VERS.
    G_IFDATA_OLDV = G_IFDATA_TRAN-S1-IFCID.

* Alles nochmal einlesen.
    CLEAR G_PROC_VEC.

    CLEAR G_IFDATA_TRAN.
    G_IFDATA_TRAN-S1-IFCID = G_IFDATA_OLDV.

  ENDIF.

ENDMODULE.                 " INIT_TRANSACTION  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LINES OUTPUT.
  STEP_LINES = SY-LOOPC.
ENDMODULE.                 " LINES  OUTPUT
