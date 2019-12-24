;;;;;;;; Vimulate AHK ;;;;;;;;

; Supported (maybe with minor differences)     : hjkl ←↓↑→ bw |^0$ -+ G
;                                                aAiIoO xX D sS C Y v
; Supported with noticeable differences        : g p V
; Implemented with external functionality      : / n u
; Partial support (only operate on selections) : d c y
; Partial support (don't operate on selections): J
; Partial support (can't be pressed repeatedly): HL <>
; Used for other functionality                 : m
; Supported but disabled by default            : (Bksp) (Space) (Enter)

; Counts are not supported on any commands (yet).

;;;;;;;; script configuration ;;;;;;;;

#NoEnv
#Warn
#SingleInstance Force
SendMode Input

; increase maximum hotkey rate
; TODO move to settings.ahk
#HotkeyInterval 2000
#MaxHotkeysPerInterval 200

;;;;;;;; define constants ;;;;;;;;

VIMULATE_AHK_VERSION := 0.1

MODE_INSERT      := "INSERT"
MODE_COMMAND     := "COMMAND"
MODE_VISUAL      := "VISUAL"
MODE_VISUAL_LINE := "VISUAL LINE"
MODE_DISABLED    := "DISABLED"

;;;;;;;; initialization ;;;;;;;;

; calculate window x and y
; TODO move to settings.ahk
_windowPosX := A_ScreenWidth - 225
_windowPosY := A_ScreenHeight - 100

Gui, Add, ComboBox, Left w90 VmodeCombo GSetModeFromCombo, % MODE_INSERT . "|" . MODE_COMMAND . "|" . MODE_VISUAL . "|" . MODE_VISUAL_LINE "|" . MODE_DISABLED
Gui, Add, Text, Right r1 w60 y0 VcmdBufferText,
Gui, -MinimizeBox -MaximizeBox
Gui, Show, x%_windowPosX% y%_windowPosY%, % "Vimulate AHK v" . VIMULATE_AHK_VERSION

SetMode(MODE_COMMAND)

;;;;;;;; define utility functions ;;;;;;;;

ModeIsInsert()
{
	global
	return (mode = MODE_INSERT)
}

ModeIsCommand()
{
	global
	return (mode = MODE_COMMAND)
}

ModeIsVisual()
{
	global
	return (mode = MODE_VISUAL or mode = MODE_VISUAL_LINE)
}

ModeIsDisabled()
{
	global
	return (mode = MODE_DISABLED)
}

SetModeFromCombo:
	GuiControlGet, _newMode,, modeCombo,
	SetMode(_newMode)
return

SetMode(newMode)
{
	global
	mode := newMode
	GuiControl, ChooseString, modeCombo, % mode
	
	if (ModeIsDisabled())
	{
		Gui, -AlwaysOnTop
		Gui, Minimize
	}
	else
	{
		Gui, Restore
		Gui, +AlwaysOnTop
	}
}

;;;;;;;; define action functions ;;;;;;;;

; hold down Shift before moving, and release after moving, if in visual mode
; but only do that if the user isn't actually holding down Shift already
MovePre:
	if (ModeIsVisual())
	{
		Send, {Shift down}
	}
return

MovePost:
	; keep whole lines selected if in line visual mode
	if (mode = MODE_VISUAL_LINE)
	{
		Send, {End}
	}
	
	if (ModeIsVisual())
	{
		Send, {Shift up}
	}
return

MoveLeft:
	gosub MovePre
	Send, {Left}
	gosub MovePost
return

MoveRight:
	gosub MovePre
	Send, {Right}
	gosub MovePost
return

MoveUp:
	gosub MovePre
	Send, {Up}
	gosub MovePost
return

MoveDown:
	gosub MovePre
	Send, {Down}
	gosub MovePost
return

MoveLeftWord:
	gosub MovePre
	Send, ^{Left}
	gosub MovePost
return

MoveRightWord:
	gosub MovePre
	Send, ^{Right}
	gosub MovePost
return

MoveBOL:
	gosub MovePre
	Send, {Home}
	gosub MovePost
return

MoveEOL:
	gosub MovePre
	Send, {End}
	gosub MovePost
return

MovePageUp:
	gosub MovePre
	Send, {PgUp}
	gosub MovePost
return

MovePageDown:
	gosub MovePre
	Send, {PgDn}
	gosub MovePost
return

MoveTop:
	gosub MovePre
	Send, ^{Home}
	gosub MovePost
return

MoveBottom:
	gosub MovePre
	Send, ^{End}
	gosub MovePost
return

IndentRight:
	Send, {Tab}
return

IndentLeft:
	Send, +{Tab}
return

RegisterCut:
	Send, ^x
	; delete newline if deleting line visual
	if (mode = MODE_VISUAL_LINE)
	{
		Send, {Delete}
	}
return

RegisterCopy:
	Send, ^c
return

RegisterPaste:
	Send, ^v
return

RegisterCutToEOL:
	SetMode(MODE_VISUAL)
	gosub MoveEOL
	gosub RegisterCut
return

BufferFind:
	Send, ^f
return

BufferFindNext:
	Send, ^f
	Send, {Enter}
return

;;;;;;;; movement ;;;;;;;;

#IF (ModeIsCommand() or ModeIsVisual())
	; hjkl for movement
	$h::gosub MoveLeft
	$j::gosub MoveDown
	$k::gosub MoveUp
	$l::gosub MoveRight
	
	; arrow keys for movement
	$Left::gosub MoveLeft
	$Down::gosub MoveDown
	$Up::gosub MoveUp
	$Right::gosub MoveRight
	
	; backspace and space for moving left/right
	; Enter for moving down a line
	; these are disabled by default to allow greater compatibility with other
	; applications (e.g. web browsers) without having to go to insert mode
	; $Backspace::gosub MoveLeft
	; $Space::gosub MoveRight
	; $Enter::gosub MoveDown

	; bw for previous and next word
	$b::gosub MoveLeftWord
	$w::gosub MoveRightWord
	
	; | and ^ and 0 for BOL, $ for EOL
	; DIFFERS from Vim behaviour, | and ^ and 0 are treated the same
	$+\::gosub MoveBOL
	$+6::gosub MoveBOL
	$0::gosub MoveBOL
	$+4::gosub MoveEOL
	
	; - for prev line
	$-::
		gosub MoveUp
		gosub MoveBOL
	return
	
	; + for next line
	$+=::
		gosub MoveDown
		gosub MoveBOL
	return
	
	; HL for page up/down
	; BUG these don't work if pressed repeatedly while Shift is held down
	$+h::gosub MovePageUp
	$+l::gosub MovePageDown
	
	; g and G for top and bottom
	; DIFFERS from Vim, only one g since multi-letter commands aren't supported
	$g::gosub MoveTop
	$+g::gosub MoveBottom
#IF

;;;;;;;; register operations ;;;;;;;;

#IF (ModeIsCommand() or ModeIsVisual())
	; delete next character to clipboard in command mode
	; cut selected text in visual mode
	$x::
		if (ModeIsCommand())
		{
			SetMode(MODE_VISUAL)
			gosub MoveRight
		}
		gosub RegisterCut
		SetMode(MODE_COMMAND)
	return
	
	; delete prev character to clipboard in command mode
	; cut selected text in visual mode
	; DIFFERS from Vim behaviour in visual mode
	$+x::
		if (ModeIsCommand())
		{
			SetMode(MODE_VISUAL)
			gosub MoveLeft
		}
		gosub RegisterCut
		SetMode(MODE_COMMAND)
	return

	; cut text to clipboard
	; LIMITATION only operates on selections
	$d::
		gosub RegisterCut
		SetMode(MODE_COMMAND)
	return
	
	; cut to EOL
	$+d::
		gosub RegisterCutToEOL
		SetMode(MODE_COMMAND)
	return
	
	; substitute character after cursor
	$s::
		SetMode(MODE_VISUAL)
		gosub MoveRight
		gosub RegisterCut
		SetMode(MODE_INSERT)
	return
	
	; substitute entire line
	$+s::
		gosub MoveBOL
		gosub RegisterCutToEOL
		SetMode(MODE_INSERT)
	return
	
	; change selected text (cut and enter insert mode)
	; LIMITATION only operates on selections
	$c::
		gosub RegisterCut
		SetMode(MODE_INSERT)
	return
	
	; change to EOL
	$+c::
		gosub RegisterCutToEOL
		SetMode(MODE_INSERT)
	return

	; copy text
	; LIMITATION only operates on selections
	; QUIRK if nothing is selected, the cursor moves to the right
	; (normally, that keystroke moves the cursor to the end of
	; the selection and deselects the selection)
	$y::
		gosub RegisterCopy
		SetMode(MODE_COMMAND)
		gosub MoveRight
	return

	; copy current line
	$+y::
		gosub MoveBOL
		SetMode(MODE_VISUAL)
		gosub MoveEOL
		gosub RegisterCopy
		SetMode(MODE_COMMAND)
		gosub MoveRight
	return
#IF

; paste clipboard contents with p
; DIFFERS from Vim behaviour regarding cursor position
; this implementation is equivalent to Ctrl+V without moving the cursor
#IF (ModeIsCommand())
	$p::gosub RegisterPaste
#IF

;;;;;;;; insertion ;;;;;;;;

#IF (ModeIsCommand())
	; insert at current position
	$i::
		SetMode(MODE_INSERT)
	return

	; insert at BOL
	$+i::
		gosub MoveBOL
		SetMode(MODE_INSERT)
	return

	; insert after current position
	$a::
		gosub MoveRight
		SetMode(MODE_INSERT)
	return

	; insert at EOL
	$+a::
		gosub MoveEOL
		SetMode(MODE_INSERT)
	return

	; insert on new line after
	$o::
		gosub MoveEOL
		Send, {Enter}
		SetMode(MODE_INSERT)
	return

	; insert on new line before
	$+o::
		gosub MoveBOL
		Send, {Enter}
		gosub MoveUp
		SetMode(MODE_INSERT)
	return
#IF

;;;;;;;; mode change ;;;;;;;;

; go back to command mode
#IF (ModeIsInsert() or ModeIsVisual())
	$Escape::SetMode(MODE_COMMAND)
#IF

; change to command if already in visual
; change to visual otherwise
#IF (!ModeIsInsert() and !ModeIsDisabled())
	$v::
		if (mode = MODE_VISUAL)
		{
			SetMode(MODE_COMMAND)
		}
		else
		{
			SetMode(MODE_VISUAL)
		}
	return
#IF

; change to command if already in visual line
; change to visual line otherwise
; QUIRK visual line only works mostly as expected when moving downward
#IF (!ModeIsInsert() and !ModeIsDisabled())
	$+v::
		if (mode = MODE_VISUAL_LINE)
		{
			SetMode(MODE_COMMAND)
		}
		else
		{
			gosub MoveBOL
			SetMode(MODE_VISUAL_LINE)
			gosub MoveEOL
		}
	return
#IF

; Win+Shift+Escape toggles whether Vimulate is enabled
#+Esc::
	if (ModeIsDisabled())
	{
		SetMode(MODE_COMMAND)
	}
	else
	{
		SetMode(MODE_DISABLED)
	}
return

; close button on titlebar disables and minimizes Vimulate
GuiClose:
	SetMode(MODE_DISABLED)
return

;;;;;;;; miscellaneous ;;;;;;;;

#IF (ModeIsCommand())
	; run find shortcut and go to insert mode (for typing search text)
	$/::
		gosub BufferFind
		SetMode(MODE_INSERT)
	return
	
	; run find shortcut and press Enter to repeat previous search
	$n::
		gosub BufferFindNext
	return
#IF

; undo
; LIMITATION it might not fully undo the last command because
; it relies on the undo buffer of the program, which might record
; a single command as multiple edit actions
#IF (ModeIsCommand())
	$u::^z
#IF

; indenting
; BUG these don't work if pressed repeatedly while Shift is held down
#IF (ModeIsCommand() or ModeIsVisual())
	; increase indent
	$+.::
		gosub MoveBOL
		gosub IndentRight
	return
	
	; decrease indent
	$+,::
		gosub MoveBOL
		gosub IndentLeft
	return
#IF

; join lines
; LIMITATION doesn't operate on selections
#IF (ModeIsCommand())
	$+j::
		gosub MoveEOL
		Send, {Delete}{Space}{Left}
	return
#IF

; emulate the menu key
; DIFFERS from Vim behaviour entirely
#IF (ModeIsCommand() or ModeIsVisual())
	$m::AppsKey
#IF

;;;;;;;; disable other keys in command and visual mode ;;;;;;;;

#IF (ModeIsCommand() or ModeIsVisual())
	; unused letters
	$+b::return
	$e::return
	$+e::return
	$f::return
	$+f::return
	$+k::return
	$m::return
	$+m::return
	$n::return
	$+n::return
	$+p::return
	$q::return
	$+q::return
	$r::return
	$+r::return
	$t::return
	$+t::return
	$+u::return
	$+w::return
	$z::return
	$+z::return
	
	; unused punctuation
	$`::return
	$+`::return
	$+1::return
	$+2::return
	$+3::return
	$+5::return
	$+7::return
	$+8::return
	$+9::return
	$+0::return
	$+-::return
	$=::return
	$[::return
	$+[::return
	$]::return
	$+]::return
	$;::return
	$+;::return
	$'::return
	$+'::return
	$\::return
	$,::return
	$.::return
	$+/::return
	
	; numbers (unused until counts are implemented)
	$1::return
	$2::return
	$3::return
	$4::return
	$5::return
	$6::return
	$7::return
	$8::return
	$9::return
#IF
