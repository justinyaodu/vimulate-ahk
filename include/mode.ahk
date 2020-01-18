;;;;;;;; mode class ;;;;;;;;

class VimulateMode
{
	; string with pipe-separated mode names
	static modeList := ""

	; name:        name of this mode
	; description: description of this mode for generating help text
	; preMove:     optional function called before any move command
	; postMove:    optional function called after any move command
	; onEnter:     optional function called when mode entered
	; onExit:      optional function called when mode exited
	
	preMove  := ""
	postMove := ""
	onEnter  := ""
	onExit   := ""
	
	__New(name, description)
	{
		this.name        := name
		this.description := description
		
		; append mode name to combo box list
		; initial pipe is intentional; specifies overwrite of contents
		VimulateMode.modeList .= "|" name
		VimulateGuiModeListChanged(VimulateMode.modeList)
	}
}

;;;;;;;; mode management ;;;;;;;;

; initialized by VimulateModeSet
vimulateCurrentMode :=

VimulateModeSet(modeName)
{
	global vimulateLayers, vimulateCurrentMode
		
	; get mode from active layers
	newMode := vimulateLayers.GetMode(modeName)
	
	; if mode not enabled or doesn't exist, indicate error and exit
	if (!newMode)
	{
		VimulateErrorMsg("Cannot change to mode (is defined in inactive layer"
				. " or does not exist): """ . modeName . """")
		return
	}
		
	; change mode
	vimulateCurrentMode.onExit()
	vimulateCurrentMode := newMode
	vimulateCurrentMode.onEnter()
	
	; report mode change to GUI
	VimulateGuiModeChanged(vimulateCurrentMode.name)
}
