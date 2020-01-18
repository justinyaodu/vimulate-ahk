;;;;;;;; help text generation ;;;;;;;;

VimulateHelpGenerate()
{
	global VIMULATE_COPYRIGHT, VIMULATE_NAME, VIMULATE_TITLE, vimulateLayers

	helpHeader =
	(
		%VIMULATE_TITLE%
		%VIMULATE_COPYRIGHT%
		Licensed under the <a href="https://github.com/justinyaodu/vimulate-ahk/blob/master/LICENSE.txt">MIT License</a>

		Visit the <a href="https://github.com/justinyaodu/vimulate-ahk">GitHub repository</a> to get more information,
		give feedback, and check for an updated version
		of the software.

		Thanks for using %VIMULATE_NAME% :)
	)
		
	Gui, VimulateHelp:Add, Link,, % helpHeader
	
	controlShortcuts =
	( LTrim
		control shortcuts:
		
		Win+Shift+Esc: turn %VIMULATE_NAME% on and off
		Esc: change to command mode
	)
	
	VimulateHelpAppend(controlShortcuts)
	
	loop % vimulateLayers.Length()
	{
		layer := vimulateLayers[A_Index]

		; print layer info
		layerHelp := layer.name " layer: " layer.description "`n"
		
		; print modes
		loop % layer.modeArray.Length()
		{
			mode := layer.modeArray[A_Index]
			layerHelp .= "`n" mode.name " mode: " mode.description
			
			; if this is the last mode, add another newline to separate the
			; modes section from the commands section
			if (A_Index == layer.modeArray.Length())
			{
				layerHelp .= "`n"
			}
		}
		
		; print commands
		loop % layer.commandArray.Length()
		{
			command := layer.commandArray[A_Index]
			layerHelp .= "`n" command.symbol ": " command.description
		}
		
		VimulateHelpAppend(layerHelp)
	}
}

VimulateHelpGenerate()

VimulateHelpAppend(text)
{
	Gui, VimulateHelp:Add, Text, x+m yp, % text
}


VimulateHelpShow()
{
	global VIMULATE_NAME
	Gui, VimulateHelp:Show,, % "About " VIMULATE_NAME
}

VimulateHelpGuiEscape()
{
	Gui, VimulateHelp:Hide
}