extends Control

var unitRod = -1
var abacus = []
var displayInstructions = []
var wordIns = []
var insIdx = 0
var stepWord = false
@onready var displayManager = get_parent().find_child("abacusDisplay")

@export var feedTape:Control

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
	
	addBtn.pressed.connect(operation.bind(add))
	subBtn.pressed.connect(operation.bind(add,-1))
	multBtn.pressed.connect(operation.bind(multiply))
	setBtn.pressed.connect(set_val)
	stepBtn.pressed.connect(step)
	
	#steps.set_text("")
	#subSteps.set_text("")
	#equationDisplay.set_text("")

func operation(o, neg=1):
	wordIns.clear()
	var ins = o.call(int(entry.get_text())*neg)
	if not ins:
		equationDisplay.set_text("Not enough room in the abacus!")
		return
	entry.clear()
	for i in operatorBtns:
		i.set_disabled(true)
	stepBtn.set_disabled(false)
	displayInstructions = ins
	feedTape.setup(wordIns)

func step():
	print("step ",insIdx)
	if stepWord:
		feedTape.move(stepBtn)
	else:
		displayManager.display(displayInstructions[insIdx])
		insIdx+=1
	stepWord = !stepWord
	if insIdx >= len(displayInstructions):
		stepWord = false
		feedTape.kill()
		displayInstructions.clear()
		insIdx = 0
		equationDisplay.clear()
		for i in operatorBtns:
			i.set_disabled(false)
		stepBtn.set_disabled(true)
		return
	#networker.send_data(displayInstructions[insIdx])


#basic setter
func set_val(v=int(entry.get_text())):
	entry.clear()
	abacus = [0,0,0,0,0,0,0,0]
	var digits = str(v).split("")
	if len(digits) > len(abacus):
		equationDisplay.set_text("Not enough room in the abacus!")
		return 
	for i in range(len(digits)):
		abacus[unitRod-i] = int(digits[-1-i])
	displayManager.display(abacus)

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
		wordIns.append("S" + action + str(abs(n)) + verb + " rod " + char(73+col))
	else:
		array[col] -= 10-n if n > 0 else (10+n)*-1
		wordIns.append("S" + action + str(abs(n)) + verb + " rod " + char(73+col)+"," + action_inverse + "the compliment " +str(10-abs(n)) + " and...")
		ins.append(array)
		ins.append_array(add_digit(array,1 if n>0 else -1,col-1))
	return ins

#splits n into digits and calls add_digit with subtraction logic
func add(n,update=true,target = abacus):
	var instructions = []
	var negative = 1
	var negativeResult = false
	var val = int("".join(abacus))
	var action = "Adding " if n>0 else "Subtracing "
	var symbol = " + " if n>0 else " - "
	var verb = " to " if n>0 else " from "
	if len(str(val + n)) > 8:
		return []
	if update:
		equationDisplay.set_text(str(val) + symbol + str(n) + " = " + str(val+n*negative))
		wordIns.append("P" + action+ str(n*(-1 if n<0 else 1)) + verb + str(val)) 
	if n<0:
		n*=-1
		negative = -1
		if n > val:
			wordIns.append("S" + "Since this calulation will result in a negative number, add 1 to rod " + char(73-1*(len(str(n))+1)))
			target[-1*(len(str(n))+1)] += 1
			instructions.append(target.duplicate())
			negativeResult = true
	var digits = str(n).split("")
	for i in range(digits.size()):
		target = target if instructions.is_empty() else instructions[-1]
		instructions.append_array(add_digit(target,negative*int(digits[-1-i]),unitRod-i))
	if update:
		if negativeResult:
			wordIns.append("S" + "The result is negative, read the compliment for the negative answer")
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
			return []
		break 
	for i in range(len(digits)):
		array[i] = int(digits[i])
	wordIns.append("P" + "Multiplying " + str(val) + " by " + str(n))
	equationDisplay.set_text(str(val) + " " + char(215) + " " + str(n) + " = " + str(val*n))
	var inscribed = "S"+"Inscribe one less than " + str(n) +" (" + str(n-1) + ") in rod"+ ("s " if len(digits) > 1 else " ")
	for i in range(len(digits)):
		inscribed += char(65+i)
	wordIns.append(inscribed)
	instructions.append(array)
	for i in range(len(abacus)):
		if abacus[i] == 0:
				continue
		for j in range(len(digits)):
			var target = abacus if instructions.is_empty() else instructions[-1]
			var multWords = "P" + "Multiply " + str(abacus[i]) + " in rod " + char(65+i) + " by " + str(int(digits[j])*10**(len(digits)-j-1)) + " in rod " + char(65+j) + " and add the result " + str(abacus[i]*int(digits[j])*10**(len(digits)-j-1)) + " to rod" + ("s " if len(str(abacus[i]*int(digits[j])*10**(len(digits)-j-1))) > 1 else " ")
			for k in range(len(str(abacus[i]*int(digits[j])*10**(len(digits)-j-1)))-1,-1,-1):
				multWords += char(65+i-k)
			wordIns.append(multWords)
			var add_ins = add(int(digits[j])*abacus[i]*10**(len(digits)-j+len(abacus)-i-2),false,target)
			instructions.append_array(add_ins)

	var cleared = instructions[-1].duplicate()
	for i in range(len(digits)):
		cleared[i] = 0
	instructions.append(cleared)
	var clearWords = "P" + "Clear " + str(n-1) + " from rod"+ ("s " if len(digits) > 1 else " ")
	for i in range(len(digits)):
		clearWords += char(65+i)
	wordIns.append(clearWords)
	abacus = cleared
	return instructions
