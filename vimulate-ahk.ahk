;;;;;;;; begin auto-execute section ;;;;;;;;

#NoEnv
#Warn
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

; settings
#include config/settings.ahk

; constants and helper functions
#include include/constants.ahk
#include include/util.ahk

; core
#include include/command.ahk
#include include/mode.ahk
#include include/layer.ahk
#include include/parse.ahk

; user interface
#include include/input.ahk
#include include/gui.ahk

; base and visual layers
#include config/layers_builtin.ahk

; user-defined layers
#include config/layers_custom.ahk

; generate help text
#include include/help.ahk

; initialization
VimulateModeSet(VIMULATE_MODE_COMMAND)

;;;;;;;; end auto-execute section ;;;;;;;;

; built-in keyboard and GUI bindings
#include include/bindings.ahk

; key mapping
#include config/keymap.ahk
