extends Control
var unitRod = -1
var abacus = []
var displayInstructions = []
var insIdx = 0
@export var displayText:RichTextLabel

@export var addBtn:Button
@export var subBtn:Button
@export var multBtn:Button
@export var setBtn:Button
@export var stepBtn:Button

@onready var operatorBtns = [addBtn,subBtn,multBtn,setBtn]
@export var entry:LineEdit

func _ready() -> void:
	set_val(0)
	displayText.set_text("".join(abacus))
	addBtn.pressed.connect(operation.bind(add))
	subBtn.pressed.connect(operation.bind(add,-1))
	multBtn.pressed.connect(operation.bind(multiply))
	setBtn.pressed.connect(set_val)
	stepBtn.pressed.connect(step)

func operation(o, neg=1):
	var ins = o.call(int(entry.get_text())*neg)
	if typeof(ins) == 4:
		return
	entry.clear()
	for i in operatorBtns:
		i.set_disabled(true)
	stepBtn.set_disabled(false)
	displayInstructions = ins

func step():
	if insIdx >= len(displayInstructions):
		displayInstructions = []
		insIdx = 0
		for i in operatorBtns:
			i.set_disabled(false)
		stepBtn.set_disabled(true)
		return
	displayText.set_text("".join(displayInstructions[insIdx]))
	insIdx+=1

#basic setter
func set_val(v=int(entry.get_text())):
	entry.clear()
	abacus = [0,0,0,0,0,0,0,0,0,0]
	var digits = str(v).split("")
	if len(digits) > len(abacus):
		return 
	for i in range(len(digits)):
		abacus[unitRod-i] = int(digits[-1-i])
	displayText.set_text("".join(abacus))

#adding digits, called recursively for carrying
func add_digit(aba,n,col) -> Array:
	if n == 0:
		return []
	var ins = []
	var array = aba.duplicate()
	if n+array[col] < 10 and n+array[col] >= 0:
		array[col] += n
		ins.append(array)
	else:
		array[col] -= 10-n if n > 0 else (10+n)*-1
		ins.append(array)
		ins.append_array(add_digit(array,1 if n>0 else -1,col-1))
	return ins

#splits n into digits and calls add_digit with subtraction logic
func add(n,update=true,target = abacus) -> Array:
	var instructions = []
	var negative = 1
	if n<0:
		n*=-1
		negative = -1
		var val = int("".join(abacus))
		if n > val:
			target[str(val).split("").size()*-1-1] += 1
	var digits = str(n).split("")
	for i in range(digits.size()):
		target = target if instructions.is_empty() else instructions[-1]
		instructions.append_array(add_digit(target,negative*int(digits[-1-i]),unitRod-i))
	if update:
		abacus = instructions[-1]
	return instructions

#Determines spacing then calls add multiple times per digit of n
func multiply(n):
	var digits = str(n-1).split("")
	var instructions = []
	var array = abacus.duplicate()
	for i in range(len(abacus)):
		if abacus[i] == 0:
			continue
		if len(digits)*2-1>i:
			return "not enough space"
		break 
	for i in range(len(digits)):
		array[i] = int(digits[i])
	instructions.append(array)
	for i in range(len(abacus)):
		for j in range(len(digits)):
			if abacus[i] == 0:
				continue
			var target = abacus if instructions.is_empty() else instructions[-1]
			instructions.append_array(add(int(digits[j])*abacus[i]*10**(len(digits)-j+len(abacus)-i-2),false,target))
	var cleared = instructions[-1].duplicate()
	for i in range(len(digits)):
		cleared[i] = 0
	instructions.append(cleared)
	abacus = cleared
	return instructions
