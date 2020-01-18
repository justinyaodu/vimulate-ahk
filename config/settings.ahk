; hotkey rate
#HotkeyInterval 2000
#MaxHotkeysPerInterval 200

; initial window position
VIMULATE_WINDOW_POS_X := A_ScreenWidth - 225
VIMULATE_WINDOW_POS_Y := A_ScreenHeight - 100

; fonts
VIMULATE_FONT_DEFAULT      :=
VIMULATE_FONT_DEFAULT_SIZE :=
VIMULATE_FONT_MONO         := "Consolas"
VIMULATE_FONT_MONO_SIZE    := "s12"

; GUI configuration
VIMULATE_MODE_DROPDOWN_OPTIONS := "y1 w90 Left"
VIMULATE_COMMAND_DISPLAY_OPTIONS := "x+1 yp w60 r1 Right"

; play an alert sound when an invalid command is entered
VIMULATE_INVALID_COMMAND_BELL := true
VIMULATE_INVALID_COMMAND_BELL_SOUND := "*48"

; issue a warning when a command's count is greater than this value
VIMULATE_COUNT_WARN_THRESHOLD := 200