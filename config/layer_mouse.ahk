;;;;;;;; mouse layer mode ;;;;;;;;

; releases any virtually held-down mouse buttons
_mouseStateReset()
{
	if (GetKeyState("LButton") and !GetKeyState("LButton", "P"))
	{
		Click, Left, Up
	}
	if (GetKeyState("RButton") and !GetKeyState("RButton", "P"))
	{
		Click, Right, Up
	}
}

_modeMouse := new VimulateMode("MOUSE", "mouse control mode")
_modeMouse.onExit := Func("_mouseStateReset")
VIMULATE_MODE_MOUSE := _modeMouse.name

_mouseModes := [_modeMouse]

;;;;;;;; mouse layer commands ;;;;;;;;

_mouseMoveLeft(count)
{
	MouseMove, -count, 0, 0, R
}

_mouseMoveRight(count)
{
	MouseMove, count, 0, 0, R
}

_mouseMoveDown(count)
{
	MouseMove, 0, count, 0, R
}

_mouseMoveUp(count)
{
	MouseMove, 0, -count, 0, R
}

_mouseSetX(count)
{
	MouseGetPos,, yPos
	MouseMove, count - 1, yPos
}

_mouseSetY(count)
{
	MouseGetPos, xPos
	MouseMove, xPos, count - 1
}

_mouseWindowLeft()
{
	_mouseSetX(0)
}

_mouseWindowRight()
{
	WinGetActiveStats, title, width, height, x, y
	_mouseSetX(width)
}

_mouseWindowTop()
{
	_mouseSetY(0)
}

_mouseWindowBottom()
{
	WinGetActiveStats, title, width, height, x, y
	_mouseSetY(height)
}

_mouseRow(count, countIsExplicit)
{
	if (countIsExplicit)
	{
		_mouseSetY(count)
	}
	else
	{
		_mouseWindowBottom()
	}
}

_mouseCommands()
{
	global VIMULATE_MODE_MOUSE
	
	mouseModes := [VIMULATE_MODE_MOUSE]
	commands := []
	
	mouseMode := new VimulateCommand("M", "mouse control mode")
	mouseMode.modeDuring := VIMULATE_MODE_MOUSE
	
	commands.Push(mouseMode)
	
	mouseLeft := new VimulateCommand("h", "move mouse left N pixels")
	mouseLeft.modes := mouseModes
	mouseLeft.primaryMotion.Push("func:_mouseMoveLeft")
	
	mouseDown := new VimulateCommand("j", "move mouse down N pixels")
	mouseDown.modes := mouseModes
	mouseDown.primaryMotion.Push("func:_mouseMoveDown")
	
	mouseUp := new VimulateCommand("k", "move mouse up N pixels")
	mouseUp.modes := mouseModes
	mouseUp.primaryMotion.Push("func:_mouseMoveUp")
	
	mouseRight := new VimulateCommand("l", "move mouse right N pixels")
	mouseRight.modes := mouseModes
	mouseRight.primaryMotion.Push("func:_mouseMoveRight")
	
	commands.Push(mouseLeft, mouseDown, mouseUp, mouseRight)
	
	mouseLeftEdge := new VimulateCommand("0", "move mouse to left edge")
	mouseLeftEdge.modes := mouseModes
	mouseLeftEdge.primaryMotion.Push("func:_mouseWindowLeft")
	
	mouseLeftEdgeAlt := mouseLeftEdge.CreateDerived("^")
	
	mouseCol := new VimulateCommand("|"
			, "move mouse to left edge, or go to x=N")
	mouseCol.modes := mouseModes
	mouseCol.primaryMotion.Push("func:_mouseSetX")
	
	mouseRightEdge := new VimulateCommand("$", "move mouse to right edge")
	mouseRightEdge.modes := mouseModes
	mouseRightEdge.primaryMotion.Push("func:_mouseWindowRight")
	
	commands.Push(mouseLeftEdge, mouseLeftEdgeAlt, mouseCol, mouseRightEdge)
	
	mouseTopEdge := new VimulateCommand("gg", "move mouse to top edge")
	mouseTopEdge.modes := mouseModes
	mouseTopEdge.primaryMotion.Push("func:_mouseWindowTop")
		
	mouseRow := new VimulateCommand("G"
			, "move mouse to bottom edge, or go to y=N")
	mouseRow.modes := mouseModes
	mouseRow.primaryMotion.Push("func:_mouseRow")
	
	commands.Push(mouseTopEdge, mouseRow)
	
	; TODO implement mouse buttons
	; TODO make this acceleration based
		
	return commands
}

;;;;;;;; create mouse layer ;;;;;;;;

new VimulateLayer("mouse", "control the mouse with the keyboard"
		, "", _mouseCommands(), _mouseModes, {})
