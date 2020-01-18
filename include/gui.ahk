;;;;;;;; initialize and display GUI ;;;;;;;;

VimulateGuiFontDefault()
{
	global
	Gui, Font, %VIMULATE_FONT_DEFAULT_SIZE%, %VIMULATE_FONT_DEFAULT%
}

VimulateGuiFontMono()
{
	global
	Gui, Font, %VIMULATE_FONT_MONO_SIZE%, %VIMULATE_FONT_MONO%
}

VimulateGuiInit()
{
	global
	
	; use configured default font for following GUI elements
	VimulateGuiFontDefault()

	; tighten everything up
	Gui, Margin, 0, 0

	; no minimize or maximize buttons
	Gui, -MinimizeBox -MaximizeBox

	; add help button
	Gui, Add, Button, GVimulateHelpShow, ?

	; add mode selection drop-down list
	VIMULATE_MODE_DROPDOWN_OPTIONS := ""
			. "VvimulateModeDDL GVimulateGuiChangeMode "
			. VIMULATE_MODE_DROPDOWN_OPTIONS
	Gui, Add, DropDownList, %VIMULATE_MODE_DROPDOWN_OPTIONS%,

	; add text display for command input
	VimulateGuiFontMono()
	VIMULATE_COMMAND_DISPLAY_OPTIONS := "+0x80 "
			. VIMULATE_COMMAND_DISPLAY_OPTIONS
	Gui, Add, Text, VvimulateInputText %VIMULATE_COMMAND_DISPLAY_OPTIONS%
	VimulateGuiFontDefault()

	; show
	Gui, Show, x%VIMULATE_WINDOW_POS_X% y%VIMULATE_WINDOW_POS_Y% NoActivate
			, % VIMULATE_TITLE
}

VimulateGuiInit()

VimulateGuiModeListChanged(modeList)
{
	GuiControl,, vimulateModeDDL, % modeList
}

VimulateGuiChangeMode()
{
	GuiControlGet, mode,, vimulateModeDDL
	VimulateModeSet(mode)
}

VimulateGuiModeChanged(mode)
{
	GuiControl, ChooseString, vimulateModeDDL, % mode
	; TODO set color
}

VimulateGuiInputChanged(text)
{
	GuiControl,, vimulateInputText, % text
}