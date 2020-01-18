;;;;;;;; command parser ;;;;;;;;

; returns 0 if command is incomplete
; returns 1 if command was parsed and run successfully
; returns -1 if command is invalid
; returns -2 if command was canceled by user
VimulateParseCommand(input)
{
	count           := 1
	countIsExplicit := false
	charParameter   := ""
	command         := ""
		
	loop
	{
		; parse count from the beginning of the command
		VimulateParseCount(input, count, countIsExplicit)
		
		; get longest sequence of command symbols from the beginning
		RegExMatch(input, "^[^1-9]+", commandSymbol)
		
		newCommand := VimulateParseCommandSymbol(commandSymbol, input)
		
		; if no matching command found
		if (newCommand == "")
		{
			; check whether it's the start of a valid command
			; maybe the command hasn't been fully entered yet
			if (vimulateLayers.ContainsPrefix(commandSymbol))
			{
				return 0
			}
			else
			{
				; VimulateErrorMsg("No matching command " . commandSymbol)
				; TODO error message
				return -1
			}
		}
		
		; consume character parameter if command requires one
		if (newCommand.TakesCharacterParameter())
		{
			; check if there is another character
			if (StrLen(input) == 0)
			{
				charParameter := SubStr(input, 1, 1)
				input = SubStr(input, 2)
			}
			else
			{
				return 0
			}
		}
		
		combined := VimulateCommandCombine(command, newCommand)
		
		; if combining commands fails
		if (combined == "")
		{
			; TODO error message
			return -1
		}
		else
		{
			command := combined
		}
	}
	until % VimulateCommandReady(command)
	
	global VIMULATE_COUNT_WARN_THRESHOLD
	if (count > VIMULATE_COUNT_WARN_THRESHOLD)
	{
		warningText := "Count for this command (" . count . ") exceeds the"
				. " warning threshold (" . VIMULATE_COUNT_WARN_THRESHOLD
				. "). Very high counts can cause extreme lag and other"
				. " unforeseen problems. Continue anyway?"
		
		; if user clicks no
		if (!VimulateConfirmMsg(warningText))
		{
			return -2
		}
	}
	
	command.Run(count, countIsExplicit, charParameter)
	
	return 1
}

VimulateParseCount(byref input, byref count, byref countIsExplicit)
{
	; extract count
	RegExMatch(input, "^[1-9][0-9]*", countMore)
		
	; if there is a count
	if (countMore != "")
	{
		count *= countMore
		countIsExplicit := true
		
		; remove count from input
		input := SubStr(input, 1 + StrLen(countMore))
	}
}

VimulateParseCommandSymbol(commandSymbol, byref input)
{
	; find longest command matching input
	while (StrLen(commandSymbol) > 0)
	{
		; get command corresponding to prefix, if any
		command := vimulateLayers.GetCommand(commandSymbol)
		
		if (command != "")
		{
			; remove matched prefix from input
			input := SubStr(input, 1 + StrLen(commandSymbol))
			
			return command
		}
		
		; remove last character
		commandSymbol := SubStr(commandSymbol, 1, -1)
	}
	
	return ""
}

VimulateCommandCombine(initial, additional)
{
	; return additional command if initial is null
	if (initial == "")
	{
		return additional
	}
	
	; if it's a motion command, overwrite primary motion
	if (additional.IsMotionCommand())
	{
		combined := initial.Clone()
		combined.primaryMotion := additional.primaryMotion
		return combined
	}
	
	; if it's a visual command, overwrite mode during
	if (additional.IsModeCommand())
	{
		combined := initial.Clone()
		combined.modeDuring := additional.modeDuring
		return combined
	}
	
	; indicate error by returning null
	return ""
}

VimulateCommandReady(command)
{
	return command.IsModeCommand() or command.primaryMotion.Length() > 0
}
