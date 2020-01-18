;;;;;;;; base layer modes ;;;;;;;;

; hide GUI when disabled
_ModeDisableEnter()
{
	Gui -AlwaysOnTop
	Gui Minimize
}

_modeDisabled := new VimulateMode("DISABLED", VIMULATE_NAME " is disabled")
_modeDisabled.onEnter := Func("_ModeDisableEnter")
VIMULATE_MODE_DISABLED := _modeDisabled.name

_modeInsert := new VimulateMode("INSERT", "use the keyboard as usual")
VIMULATE_MODE_INSERT := _modeInsert.name

; restore GUI when entering command mode
_ModeCommandEnter()
{
	Gui +AlwaysOnTop
	Gui Restore
}

_modeCommand := new VimulateMode("COMMAND", "use Vim-style keyboard commands")
_modeCommand.onEnter := Func("_ModeCommandEnter")
VIMULATE_MODE_COMMAND := _modeCommand.name

_baseModes := [_modeDisabled, _modeInsert, _modeCommand]

;;;;;;;; visual layer modes ;;;;;;;;

_ModeVisualPreMove()
{
	Send, {Shift down}
}

_ModeVisualPostMove()
{
	Send, {Shift up}
}

_modeVisual := new VimulateMode("VISUAL", "select with keyboard commands")
_modeVisual.preMove := Func("_ModeVisualPreMove")
_modeVisual.postMove := Func("_ModeVisualPostMove")
VIMULATE_MODE_VISUAL := _modeVisual.name

_ModeVisualLineOnEnter()
{
	Send, {Home}{Shift down}{End}{Right}{Shift up}
}

_ModeVisualLinePreMove()
{
	_ModeVisualPreMove()
}

_ModeVisualLinePostMove()
{
	Send, {Left}{End}{Right}
	_ModeVisualPostMove()
}

_modeVisualLine := new VimulateMode("VISUAL LINE"
		, "select linewise with keyboard commands")
_modeVisualLine.onEnter := Func("_ModeVisualLineOnEnter")
_modeVisualLine.preMove := Func("_ModeVisualLinePreMove")
_modeVisualLine.postMove := Func("_ModeVisualLinePostMove")
VIMULATE_MODE_VISUAL_LINE := _modeVisualLine.name

_visualModes := [_modeVisual, _modeVisualLine]

;;;;;;;; base layer commands ;;;;;;;;

_baseGotoCol(count)
{
	VimulateParseCommand("0")
	
	if (count > 1)
	{
		; goto column N
		count--
		VimulateParseCommand(count . "l")
	}
}

_baseGotoLine(count, countIsExplicit)
{
	if (countIsExplicit)
	{
		; count specified, so go to line
		
		; top
		VimulateParseCommand("gg")
		
		if (count > 1)
		{
			; goto line N
			count--
			VimulateParseCommand(count . "j")
		}
	}
	else
	{
		; only pressed G, so go to bottom
		Send, ^{End}
	}
}

; helper function for creating double letter commands (e.g. dd)
_createDoubleLetterCommand(command, description)
{
	command := command.CreateDerived(command.symbol . command.symbol 
			,description)
	
	command.preMotion.Push("send:{Home}")
	command.primaryMotion.Push("send:{End}{Right}")
	
	return command
}

_baseCommands()
{
	global VIMULATE_MODE_COMMAND, VIMULATE_MODE_INSERT
			, VIMULATE_MODE_VISUAL, VIMULATE_MODE_VISUAL_LINE

	commands := []
	
	;;;; movement ;;;;

	moveLeft := new VimulateCommand("h", "left arrow")
	moveLeft.primaryMotion.Push("send:{Left}")
	
	moveDown := new VimulateCommand("j", "down arrow")
	moveDown.primaryMotion.Push("send:{Down}")
	
	moveUp := new VimulateCommand("k", "up arrow")
	moveUp.primaryMotion.Push("send:{Up}")
	
	moveRight := new VimulateCommand("l", "right arrow")
	moveRight.primaryMotion.Push("send:{Right}")
	
	commands.Push(moveLeft, moveDown, moveUp, moveRight)
	
	moveLeftWord := new VimulateCommand("b", "previous word")
	moveLeftWord.primaryMotion.Push("send:^{Left}")
	
	moveRightWord := new VimulateCommand("w", "next word")
	moveRightWord.primaryMotion.Push("send:^{Right}")
	
	commands.Push(moveLeftWord, moveRightWord)
	
	moveBol := new VimulateCommand("0", "beginning of line")
	moveBol.primaryMotion.Push("send:{Home}")
	
	moveBolAlternate := moveBol.CreateDerived("^")
	
	gotoCol := new VimulateCommand("|", "beginning of line, or go to column N")
	gotoCol.primaryMotion.Push("func:_baseGotoCol")
	
	moveEol := new VimulateCommand("$", "end of line")
	moveEol.primaryMotion.Push("send:{End}")
	
	prevLine := moveUp.CreateDerived("-", "previous line")
	prevLine.primaryMotion.Push("send:{Home}")
	
	nextLine := moveDown.CreateDerived("+", "next line")
	nextLine.primaryMotion.Push("send:{End}")
	
	commands.Push(moveBol, moveBolAlternate, gotoCol, moveEol
			, prevLine, nextLine)
	
	pageUp := new VimulateCommand("H", "page up")
	pageUp.primaryMotion.Push("send:{PgUp}")
	
	pageDown := new VimulateCommand("L", "page down")
	pageDown.primaryMotion.Push("send:{PgDn}")
	
	top := new VimulateCommand("gg", "jump to top")
	top.primaryMotion.Push("send:^{Home}")
	
	gotoLine := new VimulateCommand("G", "jump to bottom, or go to line N")
	gotoLine.primaryMotion.Push("func:_baseGotoLine")
	
	commands.Push(pageUp, pageDown, top, gotoLine)
	
	;;;; insertion ;;;;
	
	insert := new VimulateCommand("i", "insert at cursor position")
	insert.modeDuring := VIMULATE_MODE_INSERT
	
	insertAfter := moveRight.CreateDerived("a", "insert after cursor position")
	insertAfter.modeAfter := VIMULATE_MODE_INSERT
	
	insertBol := moveBol.CreateDerived("I", "insert at beginning of line")
	insertBol.modeAfter := VIMULATE_MODE_INSERT
	
	insertEol := moveEol.CreateDerived("A", "insert at end of line")
	insertEol.modeAfter := VIMULATE_MODE_INSERT
	
	insertBelow := new VimulateCommand("o", "insert on new line below")
	insertBelow.primaryMotion.Push("send:{End}{Enter}")
	insertBelow.modeAfter := VIMULATE_MODE_INSERT
	
	insertAbove := new VimulateCommand("O", "insert on new line above")
	insertAbove.primaryMotion.Push("send:{Home}{Enter}{Up}")
	insertAbove.modeAfter := VIMULATE_MODE_INSERT
	
	commands.Push(insert, insertAfter, insertBol, insertEol
			, insertBelow, insertAbove)
			
	;;;; visual ;;;;
	
	visual := new VimulateCommand("v", "visual mode")
	visual.modeDuring := VIMULATE_MODE_VISUAL
	
	visualLine := new VimulateCommand("V", "visual line mode")
	visualLine.modeDuring := VIMULATE_MODE_VISUAL_LINE
	
	commands.Push(visual, visualLine)
	
	;;;; cut/copy/paste ;;;;
	
	cut := new VimulateCommand("d", "cut MOTION to clipboard")
	cut.modeDuring := VIMULATE_MODE_VISUAL
	cut.primaryOperation.Push("send:^x")
	cut.modeAfter := VIMULATE_MODE_COMMAND
	
	cutLine := _createDoubleLetterCommand(cut, "cut line")
	
	cutEol := cut.CreateDerived("D", "cut to end of line")
	cutEol.primaryMotion.Push("send:{End}")
	
	cutForward := cut.CreateDerived("x", "cut next character")
	cutForward.primaryMotion.Push("send:{Right}")
	
	cutBackward := cut.CreateDerived("X", "cut previous character")
	cutBackward.primaryMotion.Push("send:{Left}")
	
	commands.Push(cut, cutLine, cutEol, cutForward, cutBackward)
	
	change := cut.CreateDerived("c", "change MOTION")
	change.modeAfter := VIMULATE_MODE_INSERT
	
	changeLine := _createDoubleLetterCommand(change, "change line")
	
	changeEol := cutEol.CreateDerived("C", "change to end of line")
	changeEol.modeAfter := VIMULATE_MODE_INSERT
	
	changeForward := cutForward.CreateDerived("s", "change next character")
	changeForward.modeAfter := VIMULATE_MODE_INSERT
	
	changeLineAlt := changeLine.CreateDerived("S", "change line")
	
	commands.Push(change, changeLine, changeEol, changeForward, changeLineAlt)
	
	copy := new VimulateCommand("y", "copy MOTION to clipboard")
	copy.modeDuring := VIMULATE_MODE_VISUAL
	copy.primaryOperation.Push("send:^c")
	copy.modeAfter := VIMULATE_MODE_COMMAND
	
	copyLine := copy.CreateDerived("Y", "copy line")
	copyLine.primaryMotion.Push("send:{End}")
	
	; copyLine.primaryMotion.Push("cmd:foo")
	; copyLine.modeAfter := "FOO"
	
	copyLineAlt := copyLine.CreateDerived("yy")
	
	commands.Push(copy, copyLineAlt, copyLine)
	
	paste := new VimulateCommand("p", "paste clipboard contents")
	paste.primaryMotion.Push("nop")
	paste.primaryOperation.Push("send:^v")
	paste.modeAfter := VIMULATE_MODE_COMMAND
	
	commands.Push(paste)
		
	;;;; external ;;;;
	
	find := new VimulateCommand("/", "find")
	find.primaryMotion.Push("nop")
	find.primaryOperation.Push("send:^f")
	find.modeAfter := VIMULATE_MODE_INSERT
	
	findNext := find.CreateDerived("n", "find next occurrence")
	findNext.primaryOperation.Push("send:{Enter}")
	findNext.modeAfter := VIMULATE_MODE_COMMAND
	
	undo := new VimulateCommand("u", "undo")
	undo.primaryMotion.Push("nop")
	undo.primaryOperation.Push("send:^z")
	undo.modeAfter := VIMULATE_MODE_COMMAND
	
	redo := undo.CreateDerived("U", "redo")
	redo.primaryOperation.Push("send:^y")
	
	commands.Push(find, findNext, undo, redo)
	
	;;;; miscellaneous ;;;;
	
	indentIncrease := new VimulateCommand(">", "increase indent of MOTION")
	indentIncrease.modeDuring := VIMULATE_MODE_VISUAL
	indentIncrease.primaryOperation.Push("send:{Tab}")
	indentIncrease.modeAfter := VIMULATE_MODE_COMMAND
	
	indentDecrease := new VimulateCommand("<", "decrease indent of MOTION")
	indentDecrease.modeDuring := VIMULATE_MODE_VISUAL
	indentDecrease.primaryOperation.Push("send:+{Tab}")
	indentDecrease.modeAfter := VIMULATE_MODE_COMMAND
		
	indentIncreaseLine := _createDoubleLetterCommand(indentIncrease
			, "increase indent of line")
	
	indentDecreaseLine := _createDoubleLetterCommand(indentDecrease
			, "decrease indent of line")

	join := new VimulateCommand("J", "join lines")
	join.primaryMotion.Push("send:{End}{Delete}{Space}{Left}")
	
	menu := new VimulateCommand("m", "menu key")
	menu.primaryMotion.Push("nop")
	menu.primaryOperation.Push("send:{AppsKey}")
	
	help := new VimulateCommand("K", "show help window")
	help.primaryMotion.Push("nop")
	help.primaryOperation.Push("func:VimulateHelpShow")
	
	commands.Push(indentIncrease, indentIncreaseLine
			, indentDecrease, indentDecreaseLine, join, menu, help)
		
	return commands
}

;;;;;;;; create base layer ;;;;;;;;

new VimulateLayer("base", "basic Vim-like functionality"
		, "", _baseCommands(), _baseModes, {})

;;;;;;;; visual layer commands ;;;;;;;;

_visualCommands()
{
	global vimulateLayers, VIMULATE_MODE_COMMAND, VIMULATE_MODE_INSERT
			, VIMULATE_MODE_VISUAL, VIMULATE_MODE_VISUAL_LINE

	visualModes := [VIMULATE_MODE_VISUAL, VIMULATE_MODE_VISUAL_LINE]
	commands := []
	
	;;;; visual toggle off ;;;;
	
	visualOff := new VimulateCommand("v", "if in visual, return to command")
	visualOff.modes := [VIMULATE_MODE_VISUAL]
	visualOff.modeDuring := VIMULATE_MODE_COMMAND
	
	visualLineOff := new VimulateCommand("V", "if in visual line, return to command")
	visualLineOff.modes := [VIMULATE_MODE_VISUAL_LINE]
	visualLineOff.modeDuring := VIMULATE_MODE_COMMAND
	
	commands.Push(visualOff, visualLineOff)
	
	;;;; selection operations ;;;;

	cut := new VimulateCommand("d", "cut selection to clipboard")
	cut.modes := visualModes
	cut.primaryMotion.Push("nop")
	cut.primaryOperation.Push("send:^x")
	cut.modeAfter := VIMULATE_MODE_COMMAND
	
	
	cutAlt1 := cut.CreateDerived("D")
	cutAlt2 := cut.CreateDerived("x")
	cutAlt3 := cut.CreateDerived("X")
		
	commands.Push(cut, cutAlt1, cutAlt2, cutAlt3)
	
	change := cut.CreateDerived("c", "change selection")
	change.modeAfter := VIMULATE_MODE_INSERT
	
	changeAlt1 := change.CreateDerived("C")
	changeAlt2 := change.CreateDerived("s")
	changeAlt3 := change.CreateDerived("S")
	
	commands.Push(change, changeAlt1, changeAlt2, changeAlt3)
	
	copy := vimulateLayers.FindCommand("base", "y").CreateDerived(""
			, "copy selection to clipboard")
	copy.modes := visualModes
	copy.primaryMotion.Push("nop")
	
	commands.Push(copy)
	
	indentIncrease := new VimulateCommand(">", "increase selection indent")
	indentIncrease.modes := visualModes
	indentIncrease.modeDuring := VIMULATE_MODE_COMMAND
	indentIncrease.primaryMotion.Push("send:{Tab}")
	
	indentDecrease := new VimulateCommand("<", "decrease selection indent")
	indentDecrease.modes := visualModes
	indentDecrease.modeDuring := VIMULATE_MODE_COMMAND
	indentDecrease.primaryMotion.Push("send:+{Tab}")
	
	commands.Push(indentIncrease, indentDecrease)
	
	return commands
}

;;;;;;;; create visual layer ;;;;;;;;

new VimulateLayer("visual", "selection modes"
		, "", _visualCommands(), _visualModes, {})
