*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_MONITOR_GD_O0500                               *
*----------------------------------------------------------------------*

MODULE STATUS_0510 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.

  SET PF-STATUS 'YES'.
  SET TITLEBAR 'LEG'.
  PERFORM SHOW_LEGEND.

ENDMODULE.                 " STATUS_0510  OUTPUT
