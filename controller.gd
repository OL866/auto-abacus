extends Control
var unit_rod = -1
var abacus = [0,0,0,0,0,0,0,0,0,0]
func set_val(v):
	var digits = str(v).split("")
	for i in range(len(digits)):
		abacus[unit_rod-i] = int(digits[-1-i])
func _ready() -> void:
	set_val(111)
	for i in add(999):
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
		for i in add_digit(array,1 if n>0 else -1,col-1):
			ins.append(i)
	return ins
func add(n) -> Array:
	var instructions = [abacus]
	var negative = 1
	if n<0:
		n*=-1
		negative = -1
		var val = int("".join(abacus))
		print(val)
		if n > val:
			abacus[str(val).split("").size()*-1-1] += 1
	var digits = str(n).split("")
	for i in range(digits.size()):
		for j in add_digit(instructions[-1],negative*int(digits[-1-i]),unit_rod-i):
			instructions.append(j)
	return instructions
