;;;;;;;; built-in keymap ;;;;;;;;

; enable/disable hotkey
#+Escape::
	if (vimulateCurrentMode.name == VIMULATE_MODE_DISABLED)
	{
		VimulateModeSet(VIMULATE_MODE_COMMAND)
	}
	else
	{
		VimulateModeSet(VIMULATE_MODE_DISABLED)
	}
return

#IF (vimulateCurrentMode.name != VIMULATE_MODE_DISABLED)
	Escape::
		; clear command input, if any
		if (vimulateInput != "")
		{
			VimulateInputSet("")
		}
		; go back to command mode
		else if (vimulateCurrentMode.name != VIMULATE_MODE_COMMAND)
		{
			VimulateModeSet(VIMULATE_MODE_COMMAND)
		}
		else
		{
			Send, {Escape}
		}
	return
#IF
