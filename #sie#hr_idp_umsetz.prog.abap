REPORT /SIE/HR_IDP_UMSETZ .
*Änderungen SIE001 24.09.2002   Selektion auf Schnittstellenname
* SIE002 24.03.2023 COL-22048 - C2C - Bearb. ATC-Check-Findings

TABLES: /SIE/HR_IDP_S1,
        /SIE/HR_IDP_S1VN,
        /SIE/HR_IDP_S1PC,
        /SIE/HR_IDP_S1DL.

INCLUDE <ICON>.
INCLUDE /SIE/HR_IDP_TYPES.

SELECT-OPTIONS: SL_IFCID FOR /SIE/HR_IDP_S1-IFCID.        "SIE001

PARAMETERS: P_DELIM AS CHECKBOX DEFAULT 'X',                "#EC NOTEXT
            P_PRICG AS CHECKBOX DEFAULT 'X',                "#EC NOTEXT
            P_GENER AS CHECKBOX DEFAULT 'X',                "#EC NOTEXT
            P_VARIA AS CHECKBOX DEFAULT 'X',
            P_SCHARF AS CHECKBOX DEFAULT SPACE.

START-OF-SELECTION.
  PERFORM UMSETZ_DELIM.
  SKIP.
  PERFORM UMSETZ_PRICING.
  SKIP.
  PERFORM UMSETZ_GENERATOR.

*---------------------------------------------------------------------*
*       FORM UMSETZ_DELIM                                             *
*---------------------------------------------------------------------*
*       Umsetzung in der Tabelle /SIE/HR_IDP_S1VN                     *
*       Setzen eines Defaults bei nicht eingetragener Bennenung des   *
*       Delimiters.
*---------------------------------------------------------------------*
FORM UMSETZ_DELIM.
  IF NOT ( P_DELIM IS INITIAL ).
    WRITE: / 'Umsetzung der Delimiter'(001).
    ULINE.

*    SELECT * FROM /sie/hr_idp_s1vn.               "SIE001
    SELECT * FROM /SIE/HR_IDP_S1VN WHERE IFCID IN SL_IFCID "SIE001
      ORDER BY PRIMARY KEY. "SIE002

      CHECK NOT ( /SIE/HR_IDP_S1VN-IFCID IS INITIAL ).
      CLEAR /SIE/HR_IDP_S1DL.
      SELECT SINGLE * FROM /SIE/HR_IDP_S1DL
                      WHERE IFCID = /SIE/HR_IDP_S1VN-IFCID
                      AND   VRSNR = /SIE/HR_IDP_S1VN-VRSNR.
      IF SY-SUBRC EQ 0.
        WRITE: / 'Die Schnittstelle '(002),
                 /SIE/HR_IDP_S1VN-IFCID,
                 /SIE/HR_IDP_S1VN-VRSNR,
                 ' braucht nicht umgesetzt zu werden.'(008),
                 ICON_GREEN_LIGHT.
      ELSE.
        IF /SIE/HR_IDP_S1DL-FIXFM IS INITIAL.
          WRITE: / 'Die Schnittstelle '(002),
                   /SIE/HR_IDP_S1VN-IFCID,
                   /SIE/HR_IDP_S1VN-VRSNR.
          /SIE/HR_IDP_S1DL-MANDT = SY-MANDT.
          /SIE/HR_IDP_S1DL-IFCID = /SIE/HR_IDP_S1VN-IFCID.
          /SIE/HR_IDP_S1DL-VRSNR = /SIE/HR_IDP_S1VN-VRSNR.
          /SIE/HR_IDP_S1DL-FIXFM = 1.
          IF NOT ( P_SCHARF IS INITIAL ).
            MODIFY /SIE/HR_IDP_S1DL.
            IF SY-SUBRC = 0.
              WRITE: 'wurde umgesetzt.'(004),
                     ICON_GREEN_LIGHT.
            ELSE.
              WRITE: 'wurde nicht umgesetzt.'(006),
                     ICON_RED_LIGHT.
            ENDIF.
          ELSE.
            WRITE: 'wurde gefunden aber nicht umgesetzt.'(007),
                   ICON_YELLOW_LIGHT.
          ENDIF.
        ELSE.
          WRITE: / 'Die Schnittstelle '(002),
                   /SIE/HR_IDP_S1VN-IFCID,
                   /SIE/HR_IDP_S1VN-VRSNR,
                   'braucht nicht umgesetzt zu werden.'(008),
                   ICON_GREEN_LIGHT.
        ENDIF.
      ENDIF.
    ENDSELECT.
    IF SY-SUBRC >< 0.
      WRITE: /
         'Es wurden keine umzusetzende Schnittstellen gefunden.'(005),
         ICON_GREEN_LIGHT.
    ENDIF.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM UMSETZ_PRICING                                           *
*---------------------------------------------------------------------*
*       Pricing                                                       *
*---------------------------------------------------------------------*
FORM UMSETZ_PRICING.

  DATA: LT_S1VN TYPE STANDARD TABLE OF /SIE/HR_IDP_S1VN INITIAL SIZE 0
        WITH HEADER LINE.
  IF NOT ( P_PRICG IS INITIAL ).
    WRITE: / 'Umsetzung der Pricing Informationen'(009).
    ULINE.

*    SELECT * FROM /sie/hr_idp_s1vn INTO TABLE lt_s1vn.  "SIE001
    SELECT * FROM /SIE/HR_IDP_S1VN INTO TABLE LT_S1VN
                  WHERE IFCID IN SL_IFCID              "SIE001
                  ORDER BY PRIMARY KEY.                "SIE002
    IF SY-SUBRC = 0.
      LOOP AT LT_S1VN.
        CHECK NOT ( LT_S1VN-IFCID IS INITIAL ).
        SELECT SINGLE * FROM /SIE/HR_IDP_S1PC
                 WHERE IFCID = LT_S1VN-IFCID
                 AND   VRSNR = LT_S1VN-VRSNR.
        IF SY-SUBRC = 0.
          WRITE: / 'Die Schnittstelle '(002),
                   LT_S1VN-IFCID,
                   LT_S1VN-VRSNR,
                   'braucht nicht umgesetzt zu werden.'(008),
                   ICON_GREEN_LIGHT.
        ELSE.
          /SIE/HR_IDP_S1PC-MANDT = SY-MANDT.
          /SIE/HR_IDP_S1PC-IFCID = LT_S1VN-IFCID.
          /SIE/HR_IDP_S1PC-VRSNR = LT_S1VN-VRSNR.
          WRITE: / 'Die Schnittstelle '(002),
                   /SIE/HR_IDP_S1PC-IFCID,
                   /SIE/HR_IDP_S1PC-VRSNR.
          IF NOT ( P_SCHARF IS INITIAL ).
            INSERT /SIE/HR_IDP_S1PC.
            IF SY-SUBRC = 0.
              WRITE: 'wurde umgesetzt.'(004),
                     ICON_GREEN_LIGHT.
            ELSE.
              WRITE: 'wurde nicht umgesetzt.'(006),
                     ICON_RED_LIGHT.
            ENDIF.
          ELSE.
            WRITE: 'wurde gefunden aber nicht umgesetzt.'(007),
                   ICON_YELLOW_LIGHT.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UMSETZ_GENERATOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UMSETZ_GENERATOR.

  DATA: LS_DATA TYPE /SIE/HR_IDP_IFC_DB,
        L_VECTOR TYPE /SIE/HR_IDP_DB_SEL,
        LT_S1 TYPE STANDARD TABLE OF /SIE/HR_IDP_S1 INITIAL SIZE 0
              WITH HEADER LINE.

  L_VECTOR = C_ALL_TABL.

  IF NOT ( P_GENER IS INITIAL ).
    WRITE: / 'Umsetzung von Generatoränderungen'(010).
    ULINE.

    SELECT * FROM /SIE/HR_IDP_S1 INTO TABLE LT_S1.
*    LOOP AT lt_s1.                      "SIE001
    LOOP AT LT_S1  WHERE IFCID IN SL_IFCID. "SIE001.
      CALL FUNCTION '/SIE/HR_IDP_IFC_CURR_VERSION'
           EXPORTING
                INTERFACE         = LT_S1-IFCID
                ACTIVE            = YES
           IMPORTING
                VERSION           = LT_S1-ACT_VERS_NR
           EXCEPTIONS
                NO_ACTIVE_VERSION = 1
                OTHERS            = 2.
      IF SY-SUBRC = 0.
        CALL FUNCTION '/SIE/HR_IDP_DB_READ'
             EXPORTING
                  INTERFACE        = LT_S1-IFCID
                  VERSION          = LT_S1-ACT_VERS_NR
             CHANGING
                  TRANSACTION_DATA = LS_DATA
                  DBSEL            = L_VECTOR.
        CALL FUNCTION '/SIE/HR_IDP_GENERATE_REPORT'
             EXPORTING
                  P_TRANS_DATA  = LS_DATA
                  P_PROC_VECTOR = L_VECTOR.
        COMMIT WORK.
        WRITE: / 'Die Schnittstelle '(002),
                 LT_S1-IFCID,
                 LT_S1-ACT_VERS_NR,
                 'wurde umgesetzt.'(004),
                 ICON_GREEN_LIGHT.
IF NOT P_VARIA IS INITIAL.

CALL FUNCTION '/SIE/HR_IDP_GENERATE_VARIANT'
     EXPORTING
          IFCID     = LT_S1-IFCID
          VRSNR     = LT_S1-ACT_VERS_NR
*         TEST_EXEC = ' '
*    IMPORTING
*         dbsel     = l_vector
*    CHANGING
*         interface = ls_data
          .
        WRITE: / 'Die Variante der Schnittstelle ',
                 LT_S1-IFCID,
                 LT_S1-ACT_VERS_NR,
                 'wurde neu angelegt.',
                 ICON_GREEN_LIGHT.
ENDIF.
      ELSE.
        WRITE: / 'Die Schnittstelle '(002),
        LT_S1-IFCID,
        'braucht nicht umgesetzt zu werden.'(008),
        ICON_GREEN_LIGHT.
      ENDIF.
    ENDLOOP.
    IF SY-SUBRC >< 0.
      WRITE: /
         'Es wurden keine umzusetzende Schnittstellen gefunden.'(005),
         ICON_GREEN_LIGHT.
    ENDIF.
  ENDIF.
ENDFORM.                    " UMSETZ_GENERATOR
