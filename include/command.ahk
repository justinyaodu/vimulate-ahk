;;;;;;;; command class ;;;;;;;;

class VimulateCommand
{
	; symbol:           symbol(s) used to activate this command
	; description:      command description for generating help menu
	; modes:            array of modes in which this command operates,
	;                           or empty to enable for all modes
	;                           (except for disabled and insert)
	; preMotion:        array of motion(s) taken before the command
	; modeDuring:       change to this mode before primary motion is run,
	;                           or blank for no change
	; primaryMotion:    array of motion(s) to be repeated
	; primaryOperation: array of operation(s) to be performed on selection
	; modeAfter:        change to this mode afterward, or blank for no change
	; postMotion:       array of motion(s) taken after
	
	; initialize
	modes            := []
	preMotion        := []
	modeDuring       := ""
	primaryMotion    := []
	primaryOperation := []
	modeAfter        := ""
	postMotion       := []
	
	__New(symbol, description)
	{
		this.symbol           := symbol
		this.description      := description
	}
	
	; make a copy of this command
	CreateDerived(symbol := "", description := "")
	{
		; copy symbol and description if not specified
		if (symbol == "")
		{
			symbol := this.symbol
		}
		if (description == "")
		{
			description := this.description
		}
	
		command := new VimulateCommand(symbol, description)
		
		; deep copy arrays
		command.modes            := this.modes.Clone()
		command.preMotion        := this.preMotion.Clone()
		command.modeDuring       := this.modeDuring
		command.primaryMotion    := this.primaryMotion.Clone()
		command.primaryOperation := this.primaryOperation.Clone()
		command.modeAfter        := this.modeAfter
		command.postMotion       := this.postMotion.Clone()
		
		return command
	}
	
	; return whether this command operates in a certain mode
	OperatesInMode(mode)
	{
		; if list is empty, command is enabled for all modes
		if (this.modes.Length() == 0)
		{
			return true
		}
		else
		{
			return VimulateArrayContains(this.modes, mode)
		}
	}
	
	; return whether this command only has a primaryMotion
	IsMotionCommand()
	{
		return this.primaryMotion.Length()          > 0
				and this.preMotion.Length()        == 0
				and this.modeDuring                == ""
				and this.primaryOperation.Length() == 0
				and this.modeAfter                 == ""
				and this.postMotion.Length()       == 0
	}
	
	; return whether this command only has a modeDuring
	IsModeCommand()
	{
		return this.modeDuring                     != ""
				and this.preMotion.Length()        == 0
				and this.primaryMotion.Length()    == 0
				and this.primaryOperation.Length() == 0
				and this.modeAfter                 == ""
				and this.postMotion.Length()       == 0
	}
	
	; return whether this command takes a character parameter
	TakesCharacterParameter()
	{
		loop % this.primaryMotion.Length()
		{
			action := VimulateCommandResolveAction(this.primaryMotion[A_Index]
					, "primaryMotion")
			
			; if action is a function
			; and the function takes three parameters instead of the usual two
			if (action[1] == "func" and Func(action[2]).MinParams() == 3)
			{
				return true
			}
		}
		
		return false
	}
	
	; run this command object
	Run(count, countIsExplicit, charParameter)
	{
		VimulateCommandRunActions(this.preMotion, "primaryMotion"
				, true, 1, false, "")
		VimulateCommandSetMode(this.modeDuring)
		VimulateCommandRunActions(this.primaryMotion, "primaryMotion"
				, true, count, countIsExplicit, charParameter)
		VimulateCommandRunActions(this.primaryOperation, "primaryOperation"
				, false, 1, false, "")
		VimulateCommandSetMode(this.modeAfter)
		VimulateCommandRunActions(this.postMotion, "primaryMotion"
				, true, 1, false, "")
	}
}

; execute an array of actions
; if a reference to another command is specified, lookupField specifies the
; name of the field to use as the referenced action
VimulateCommandRunActions(actions, lookupField, isMotion
		, count, countIsExplicit, charParameter)
{
	global vimulateCurrentMode

	; return if no actions, so preMove and postMove aren't called unnecessarily
	if (actions.Length() == 0)
	{
		return
	}
	
	if (isMotion)
	{
		vimulateCurrentMode.preMove()
	}

	loop % actions.Length()
	{
		; resolve action string and split into array
		actionString := actions[A_Index]
		action := VimulateCommandResolveAction(actionString, lookupField)
		
		if (action[1] == "send")
		{
			loop % count
			{
				Send, % action[2]
			}
		}
		else if (action[1] == "func")
		{
			functionName := action[2]
			
			if (!IsFunc(functionName))
			{
				VimulateErrorMsg("Function does not exist: """
						. functionName . """")
			}
			
			%functionName%(count, countIsExplicit, charParameter)
		}
		else if (action[1] == "nop")
		{
			continue
		}
		else if (action[1] == "sub")
		{
			loop % count
			{
				subroutineName := action[2]
				gosub %subroutineName%
			}
		}
		else
		{
			VimulateErrorMsg("Unrecognized action string format: """
					. actionString . """")
		}
	}
	
	if (isMotion)
	{
		vimulateCurrentMode.postMove()
	}
}

; set the mode, specified directly or by referencing another command
VimulateCommandSetMode(mode)
{
	; if a reference, always use the referenced command's modeDuring
	mode := VimulateCommandResolve(mode, "modeDuring")
	
	; ignore empty mode strings, because they are used to specify no change
	if (mode == "")
	{
		return
	}
	
	VimulateModeSet(mode)
}

VimulateCommandResolveAction(action, lookupField)
{
	action := VimulateCommandResolve(action, lookupField)
	action := StrSplit(action, ":", "", 2)
	return action
}
	
; if an action or mode references another command, evaluate that reference
; and return the corresponding value
; lookupField specifies which field from the referenced command to return
VimulateCommandResolve(value, lookupField)
{
	global vimulateLayers

	while (SubStr(value, 1, 4) == "cmd:")
	{
		command := vimulateLayers.GetCommand(SubStr(value, 5))
		
		; if no command found
		if (command == "")
		{
			VimulateErrorMsg("Referenced command is in a disabled layer"
					. " or does not exist: """ . value . """")
			
			; prevent cascade of errors
			return "nop"
		}
		
		value := command[lookupField]
		
		; if it's an array, use just the first element
		if (value.Length() > 0)
		{
			value := value[1]
		}
	}
	
	return value
}
