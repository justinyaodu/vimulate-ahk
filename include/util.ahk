; convert a regular array to an associative one
VimulateConvertAssociative(array, keyField)
{
	associativeArray := {}
	loop % array.Length()
	{
		element := array[A_Index]
		associativeArray[VimulateUppercaseConvert(element[keyField])] := element
	}
	
	return associativeArray
}

; replace uppercase letters with other characters so that associative arrays
; can be used with case-sensitive strings
VimulateUppercaseConvert(text)
{
	newText := ""

	loop % StrLen(text)
	{	
		ord := Ord(SubStr(text, A_Index, 1))
		if (Ord("A") <= ord and ord <= Ord("Z"))
		{
			; convert to Unicode bold capital letter
			newText .= Chr(ord + 0x1D3BF)
		}
		else
		{
			newText .= Chr(ord)
		}
	}
	
	return newText
}

VimulateArrayContains(array, value)
{
	loop % array.Length()
	{
		if (array[A_Index] == value)
		{
			return true
		}
	}
			
	return false
}

VimulateErrorMsg(text)
{
	global VIMULATE_TITLE
	MsgBox, 0x10, %VIMULATE_TITLE%, %text%
}

VimulateConfirmMsg(text)
{
	global VIMULATE_TITLE
	MsgBox, 0x134, %VIMULATE_TITLE%, %text%
	
	IfMsgBox, Yes
	{
		return true
	}
	return false
}
