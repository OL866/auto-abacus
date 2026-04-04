extends Control

var unitRod = -1
var abacus = []
var displayInstructions = []
var wordIns = []
var subWordIns = []
var insIdx = 0

@export var displayText:RichTextLabel
@export var steps:RichTextLabel
@export var subSteps:RichTextLabel
@export var equationDisplay:RichTextLabel

@export var addBtn:Button
@export var subBtn:Button
@export var multBtn:Button
@export var setBtn:Button
@export var stepBtn:Button
@onready var operatorBtns = [addBtn,subBtn,multBtn,setBtn]

@export var networker:Node
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
	subWordIns.clear()
	wordIns.clear()
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
	for i in wordIns:
		if i[1] == 0:
			continue
		steps.set_text(i[0])
		i[1] -= 1
		break
	subSteps.set_text(subWordIns[insIdx])
	#networker.send_data(displayInstructions[insIdx])
	insIdx+=1

#basic setter
func set_val(v=int(entry.get_text())):
	entry.clear()
	abacus = [0,0,0,0,0,0,0,0]
	var digits = str(v).split("")
	if len(digits) > len(abacus):
		return 
	for i in range(len(digits)):
		abacus[unitRod-i] = int(digits[-1-i])
	displayText.set_text("".join(abacus))

#adding digits, called recursively for carrying
func add_digit(aba,n,col) -> Array:
	var action = "Add " if n>0 else "Subtract "
	var action_inverse = " add " if n<0 else " subtract "
	var verb = " to" if n>0 else " from"
	
	if n == 0:
		return []
	var ins = []
	var array = aba.duplicate()
	if n+array[col] < 10 and n+array[col] >= 0:
		array[col] += n
		ins.append(array)
		subWordIns.append(action + str(abs(n)) + verb + " rod " + char(73+col))
	else:
		array[col] -= 10-n if n > 0 else (10+n)*-1
		subWordIns.append(action + str(abs(n)) + verb + " rod " + char(73+col)+"," + action_inverse + "the compliment " +str(10-abs(n)) + " and...")
		ins.append(array)
		ins.append_array(add_digit(array,1 if n>0 else -1,col-1))
	return ins

#splits n into digits and calls add_digit with subtraction logic
func add(n,update=true,target = abacus) -> Array:
	var instructions = []
	var negative = 1
	var negativeResult = false
	var val = int("".join(abacus))
	var action = "Adding " if n>0 else "Subtracing "
	var symbol = " + " if n>0 else " - "
	var verb = " to " if n>0 else " from "
	if n<0:
		n*=-1
		negative = -1
		if n > val:
			subWordIns.append("Since this calulation will result in a negative number, add 1 to rod " + char(73+str(val).split("").size()*-1-1))
			target[str(val).split("").size()*-1-1] += 1
			instructions.append(target.duplicate())
			negativeResult = true
	var digits = str(n).split("")
	if update:
		equationDisplay.set_text(str(val) + symbol + str(n) + " = " + str(val+n*negative))
		wordIns.append([action+ str(n) + verb + str(val),-1]) 
	for i in range(digits.size()):
		target = target if instructions.is_empty() else instructions[-1]
		instructions.append_array(add_digit(target,negative*int(digits[-1-i]),unitRod-i))
	if update:
		if negativeResult:
			subWordIns.append("The result is negative, read the compliment for the negative answer")
			var comp = str(10**(len(str(int("".join(instructions[-1])))))-int("".join(instructions[-1])))
			var compArray = [0,0,0,0,0,0,0,0]
			for i in range(len(comp)):
				compArray[-1-i] = int(comp[-1-i])
			instructions.append(compArray)
		abacus = instructions[-1]
	return instructions
#Determines spacing then calls add multiple times per digit of n
func multiply(n):
	var val = int("".join(abacus))
	var digits = str(n-1).split("")
	var instructions = []
	var array = abacus.duplicate()
	for i in range(len(abacus)):
		if abacus[i] == 0:
			continue
		if len(digits)*2-1>=i:
			return "not enough space"
		break 
	for i in range(len(digits)):
		array[i] = int(digits[i])
	wordIns.append(["Multiplying " + str(val) + " by " + str(n),1])
	equationDisplay.set_text(str(val) + " " + char(215) + " " + str(n) + " = " + str(val*n))
	var inscribed = "Inscribe one less than " + str(n) +" (" + str(n-1) + ") in rod"+ ("s " if len(digits) > 1 else " ")
	for i in range(len(digits)):
		inscribed += char(65+i)
	subWordIns.append(inscribed)
	instructions.append(array)
	for i in range(len(abacus)):
		if abacus[i] == 0:
				continue
		for j in range(len(digits)):
			var target = abacus if instructions.is_empty() else instructions[-1]
			var multWords = "Multiply " + str(abacus[i]) + " in rod " + char(65+i) + " by " + str(int(digits[j])*10**(len(digits)-j-1)) + " in rod " + char(65+j) + " and add the result " + str(abacus[i]*int(digits[j])*10**(len(digits)-j-1)) + " to rod" + ("s " if len(str(abacus[i]*int(digits[j])*10**(len(digits)-j-1))) > 1 else " ")
			for k in range(len(str(abacus[i]*int(digits[j])*10**(len(digits)-j-1)))-1,-1,-1):
				multWords += char(65+i-k)
			var add_ins = add(int(digits[j])*abacus[i]*10**(len(digits)-j+len(abacus)-i-2),false,target)
			instructions.append_array(add_ins)
			wordIns.append([multWords,len(add_ins)])
	var cleared = instructions[-1].duplicate()
	for i in range(len(digits)):
		cleared[i] = 0
	instructions.append(cleared)
	var clearWords = "Clear " + str(n) + " from rod"+ ("s " if len(digits) > 1 else " ")
	for i in range(len(digits)):
		clearWords += char(65+i)
	wordIns.append([clearWords,1])
	subWordIns.append("")
	abacus = cleared
	return instructions
