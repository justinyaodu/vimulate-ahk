;;;;;;;; keymap (keystrokes to command text) ;;;;;;;;

#IF (vimulateCurrentMode.name != VIMULATE_MODE_DISABLED
		and vimulateCurrentMode.name != VIMULATE_MODE_INSERT)

; lowercase letters
a::VimulateInputAppend("a")
b::VimulateInputAppend("b")
c::VimulateInputAppend("c")
d::VimulateInputAppend("d")
e::VimulateInputAppend("e")
f::VimulateInputAppend("f")
g::VimulateInputAppend("g")
h::VimulateInputAppend("h")
i::VimulateInputAppend("i")
j::VimulateInputAppend("j")
k::VimulateInputAppend("k")
l::VimulateInputAppend("l")
m::VimulateInputAppend("m")
n::VimulateInputAppend("n")
o::VimulateInputAppend("o")
p::VimulateInputAppend("p")
q::VimulateInputAppend("q")
r::VimulateInputAppend("r")
s::VimulateInputAppend("s")
t::VimulateInputAppend("t")
u::VimulateInputAppend("u")
v::VimulateInputAppend("v")
w::VimulateInputAppend("w")
x::VimulateInputAppend("x")
y::VimulateInputAppend("y")
z::VimulateInputAppend("z")

; uppercase letters
+a::VimulateInputAppend("A")
+b::VimulateInputAppend("B")
+c::VimulateInputAppend("C")
+d::VimulateInputAppend("D")
+e::VimulateInputAppend("E")
+f::VimulateInputAppend("F")
+g::VimulateInputAppend("G")
+h::VimulateInputAppend("H")
+i::VimulateInputAppend("I")
+j::VimulateInputAppend("J")
+k::VimulateInputAppend("K")
+l::VimulateInputAppend("L")
+m::VimulateInputAppend("M")
+n::VimulateInputAppend("N")
+o::VimulateInputAppend("O")
+p::VimulateInputAppend("P")
+q::VimulateInputAppend("Q")
+r::VimulateInputAppend("R")
+s::VimulateInputAppend("S")
+t::VimulateInputAppend("T")
+u::VimulateInputAppend("U")
+v::VimulateInputAppend("V")
+w::VimulateInputAppend("W")
+x::VimulateInputAppend("X")
+y::VimulateInputAppend("Y")
+z::VimulateInputAppend("Z")

; numbers
1::VimulateInputAppend("1")
2::VimulateInputAppend("2")
3::VimulateInputAppend("3")
4::VimulateInputAppend("4")
5::VimulateInputAppend("5")
6::VimulateInputAppend("6")
7::VimulateInputAppend("7")
8::VimulateInputAppend("8")
9::VimulateInputAppend("9")
0::VimulateInputAppend("0")

; number row punctuation
+1::VimulateInputAppend("!")
+2::VimulateInputAppend("@")
+3::VimulateInputAppend("#")
+4::VimulateInputAppend("$")
+5::VimulateInputAppend("%")
+6::VimulateInputAppend("^")
+7::VimulateInputAppend("&")
+8::VimulateInputAppend("*")
+9::VimulateInputAppend("(")
+0::VimulateInputAppend(")")

; other punctuation
`::VimulateInputAppend("``")
+`::VimulateInputAppend("~")
-::VimulateInputAppend("-")
+-::VimulateInputAppend("_")
=::VimulateInputAppend("=")
+=::VimulateInputAppend("+")
[::VimulateInputAppend("[")
]::VimulateInputAppend("]")
+[::VimulateInputAppend("{")
+]::VimulateInputAppend("}")
\::VimulateInputAppend("\")
+\::VimulateInputAppend("|")
`;::VimulateInputAppend(";")
+;::VimulateInputAppend(":")
,::VimulateInputAppend(",")
+,::VimulateInputAppend("<")
.::VimulateInputAppend(".")
+.::VimulateInputAppend(">")
/::VimulateInputAppend("/")
+/::VimulateInputAppend("?")

#IF