;;;;;;;; layer class ;;;;;;;;

class VimulateLayer
{
	; name:            name of this layer
	; description:     description for generating help text
	; enableCondition: function (or function-like object) whose return value
	;                          specifies whether this layer should be enabled,
	;                          or none to always enable this layer
	; commands:        array of commands defined by this layer
	; modes:           array of modes defined by this layer
	; settings:        associative array of layer settings
	__New(name, description, enableCondition, commands, modes, settings)
	{
		; initialize variables
		this.name            := name
		this.description     := description
		this.enableCondition := enableCondition
		this.settings        := settings
		
		; convert commands and modes to associative arrays
		this.commandArray := commands
		this.commands     := VimulateConvertAssociative(commands, "symbol")
		this.modeArray    := modes
		this.modes        := VimulateConvertAssociative(modes, "name")
		
		; generate command prefixes
		this.commandPrefixes := {}
		loop % this.commandArray.Length()
		{
			symbol := this.commandArray[A_Index].symbol
			prefix := symbol
			
			; enumerate all prefixes of symbol
			while (StrLen(prefix := SubStr(prefix, 1, -1)) > 0)
			{
				; map prefixes to an array of symbols
				if (this.commandPrefixes[prefix] == "")
				{
					this.commandPrefixes[prefix] := [symbol]
				}
				else
				{
					this.commandPrefixes[prefix].Push(symbol)
				}
			}
		}
		
		; append to global array of layers
		global vimulateLayers
		vimulateLayers.Push(this)
	}
}

;;;;;;;; single object with all layers ;;;;;;;;
class vimulateLayers
{
	; update the local array of indices corresponding to active layers
	UpdateActiveLayers()
	{
		this.activeIndices := []
		
		index := this.Length() + 1
		while (--index)
		{
			; if function object is null or evaluates to true
			if (this[index].enableCondition == "" or this[index].enableCondition())
			{
				this.activeIndices.Push(index)
			}
		}
	}
	
	; find the command with this symbol in this layer
	FindCommand(layerName, symbol)
	{
		loop % this.Length()
		{
			layer := this[A_Index]
			
			if (layer.name := layerName)
			{			
				command := layer.commands[symbol]
				
				if (command != "")
				{
					return command
				}
			}
		}
		
		return ""
	}

	; get command in topmost active layer matching symbol
	GetCommand(symbol)
	{		
		return this.GetHighest("commands", symbol, "OperatesInMode")
	}
	
	; get value of layer setting in highest active layer
	GetSetting(setting)
	{
		return this.GetHighest("settings", setting)
	}
	
	; get mode object corresponding to this name in highest active layer
	GetMode(mode)
	{
		return this.GetHighest("modes", mode)
	}
	
	; return whether any commands start with this prefix
	ContainsPrefix(prefix)
	{
		; handle empty string properly
		if (prefix == "")
		{
			return true
		}
	
		return this.GetHighest("commandPrefixes", prefix) != ""
	}
	
	; get the value corresponding to this key in the highest active layer
	; for which that key has a value defined
	GetHighest(associativeArray, key, modeCondition := "")
	{
		this.UpdateActiveLayers()

		global vimulateCurrentMode
		
		key := VimulateUppercaseConvert(key)
	
		; loop over active layers
		loop % this.activeIndices.Length()
		{
			layer := this[this.activeIndices[A_Index]]
			value := layer[associativeArray][key]
			
			; check if value exists
			if (value)
			{
				; check mode condition, if specified
				if (modeCondition == "")
				{
					return value
				}
				else if (value[modeCondition](vimulateCurrentMode.name))
				{
					return value
				}
			}
		}
		
		; not found
		return ""
	}
}
