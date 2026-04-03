extends Control
var unit_rod = -1
var abacus = [0,0,0,0,0,0,0,0,0,0]
func set_val(v):
	abacus = [0,0,0,0,0,0,0,0,0,0]
	var digits = str(v).split("")
	for i in range(len(digits)):
		abacus[unit_rod-i] = int(digits[-1-i])
func _ready() -> void:
	set_val(99)
	for i in multiply(99):
		print(i)
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
		instructions.append_array(add_digit(target,negative*int(digits[-1-i]),unit_rod-i))
	if update:
		abacus = instructions[-1]
	return instructions
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
