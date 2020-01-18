;;;;;;;; command input ;;;;;;;;

vimulateInput :=

VimulateInputSet(text)
{
	global vimulateInput
	vimulateInput := text
	
	; update GUI
	VimulateGuiInputChanged(vimulateInput)
	
	; attempt parsing and clear if command was run (or is invalid)
	if (inputResult := VimulateParseCommand(vimulateInput))
	{
		VimulateInputSet("")
	}
	
	; play bell sound for invalid command
	global VIMULATE_INVALID_COMMAND_BELL, VIMULATE_INVALID_COMMAND_BELL_SOUND
	if (inputResult == -1 and VIMULATE_INVALID_COMMAND_BELL)
	{
		SoundPlay, % VIMULATE_INVALID_COMMAND_BELL_SOUND
	}
}

VimulateInputAppend(text)
{
	global vimulateInput
	VimulateInputSet(vimulateInput . text)
}
