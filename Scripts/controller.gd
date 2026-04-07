extends Control
var unitRod = -1
var abacus = []
var displayInstructions = []
var wordIns = []
var insIdx = 0
var stepWord = false

signal calculationDone

var fastMode = false

@onready var displayManager = get_parent().find_child("abacusDisplay")
@export var feedTape:Control
@export var equationDisplay:RichTextLabel
@export var stepBtn:Button
@export var networker:Node

var abacusNegative = false
var totalBorrowed = 0
func _ready() -> void:
	set_val(0)
	stepBtn.pressed.connect(step.bind(true))
	#steps.set_text("")
	#subSteps.set_text("")
	#equationDisplay.set_text("")

func operation(o, n,final=false, neg=1):
	wordIns.clear()
	var ins = o.call(int(n*neg),final)
	displayInstructions = ins
	feedTape.setup(wordIns)
	if not fastMode:
		stepBtn.set_disabled(false)
	else:
		for i in range(len(displayInstructions)):
			step(false)
			await get_tree().create_timer(0.2).timeout
func step(btn):
	#networker.send_data(displayInstructions[insIdx])
	if btn: stepBtn.set_disabled(true)
	displayManager.display(displayInstructions[insIdx],0.2)
	insIdx+=1
	if insIdx >= len(displayInstructions):
		stepWord = false
		feedTape.kill()
		displayInstructions.clear()
		insIdx = 0
		equationDisplay.set_text("")
		if btn:stepBtn.set_disabled(true)
		await feedTape.killDone
		emit_signal("calculationDone")
		return
	feedTape.move()
	await feedTape.moveDone
	if btn: stepBtn.set_disabled(false)
#basic setter
func set_val(v):
	abacus = [0,0,0,0,0,0,0,0]
	var digits = str(v).split("")
	if len(digits) > len(abacus):
		equationDisplay.set_text("Not enough room in the abacus!")
		emit_signal("allDone")
		return 
	for i in range(len(digits)):
		abacus[unitRod-i] = int(digits[-1-i])
	#networker.send_data(abacus)
	displayManager.display(abacus,0.2)

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
func add(n,final_update=false,update=true,target=abacus):
	var instructions = []
	var nNegative = 1
	var negativeResult = false
	var val = int("".join(target))

	var action = "Adding " if n>0 else "Subtracing "
	var symbol = " + " if n>0 else " - "
	var verb = " to " if n>0 else " from "

	if update:
		if abacusNegative: val = (totalBorrowed - val)*-1
		abacusNegative = false
		equationDisplay.set_text(str(val) + symbol + str(abs(n)) + " = " + str(val+n))
		wordIns.append("P" + action+ str(n*(-1 if n<0 else 1)) + verb + str(val)) 
	if n+val <0:
		negativeResult = true
		abacusNegative = true
		var borrowneeded = 10**(len(str(abs(n))))
		totalBorrowed += borrowneeded
		wordIns.append("S" + "Since this calulation will result in a negative number, add " + str(borrowneeded))
		instructions.append(add(borrowneeded,false,false)[-1])
		for i in str(borrowneeded): if i != "0": wordIns.pop_back()
	if n <0:
		nNegative = -1
		n*=-1
	var digits = str(n).split("")
	for i in range(digits.size()):
		target = target if instructions.is_empty() else instructions[-1]
		instructions.append_array(add_digit(target,nNegative*int(digits[-1-i]),unitRod-i))
	if int(str(totalBorrowed).right(-1)) and update and not negativeResult:
		var temp = int(str(totalBorrowed).right(-1))
		wordIns.append("S" + "Since we borrowed " + str(totalBorrowed) + " earlier, subtract " +str(int(str(totalBorrowed).right(-1))))
		totalBorrowed-= temp
		instructions.append(add(temp*-1,false,false,instructions[-1])[-1])
		wordIns.pop_back()
	if final_update:
		if negativeResult:
			wordIns.append("S" + "The result is negative, read the compliment for the negative answer")
			var comp = str(totalBorrowed-int("".join(instructions[-1])))
			var compArray = [0,0,0,0,0,0,0,0]
			for i in range(len(comp)):
				compArray[-1-i] = int(comp[-1-i])
			instructions.append(compArray)
		elif totalBorrowed:
			wordIns.append("S" + "Since we borrowed " + str(totalBorrowed) + " earlier, subtract " +str(totalBorrowed))
			instructions.append(add(totalBorrowed*-1,false,false,instructions[-1])[-1])
			wordIns.pop_back()
	if update: abacus = instructions[-1]
	return instructions

#Determines spacing then calls add multiple times per digit of n
func multiply(n,_final):
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
			var add_ins = add(int(digits[j])*abacus[i]*10**(len(digits)-j+len(abacus)-i-2),false,false,target)
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

func parse(s,btns):
	totalBorrowed = 0
	abacusNegative = false
	var operations:Array[Callable] = []
	var split = s.split(" ")
	if not split[0].is_valid_int():
		equationDisplay.set_text("Invalid Syntax!")
		return
	var val = int(split[0])
	for i in range(1,len(split)-1,2):
		if not split[i+1].is_valid_int(): 
			equationDisplay.set_text("Invalid Syntax!")
			return
		if split[i] == "+": 
			operations.append(operation.bind(add,int(split[i+1]),i==len(split)-2))
			val += int(split[i+1])
		if split[i] == "-": 
			operations.append(operation.bind(add,int(split[i+1]),i==len(split)-2,-1))
			val -= int(split[i+1])
		if split[i] == "×": 
			operations.append(operation.bind(multiply,int(split[i+1]),i==len(split)-2))
			if 8 - len(str(val)) < 2*len(split[i+1]):
				equationDisplay.set_text("Not enough room in the abacus!")
				return
			val *= int(split[i+1])
	if len(str(val)) > 8:
		equationDisplay.set_text("Not enough room in the abacus!")
		return
	set_val(int(split[0]))
	var typing = get_parent().find_child("Typing")
	typing.find_child("displayMask").find_child("displayLabel").set_text("= " + str(val))
	typing.find_child("displayMask").find_child("displayLabel").set_position(typing.initPos)
	typing.find_child("displayMask").find_child("displayLabel").set_size(typing.initSize)
	typing.toClear = true
	for i in btns:
		i.set_disabled(true)
	for i in operations:
		i.call()
		await calculationDone
	for i in btns:
		i.set_disabled(false)
