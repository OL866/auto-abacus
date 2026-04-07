extends Control

@onready var btns = find_child("Buttons").get_children()
@onready var displayLabel = find_child("displayMask").get_child(0)
@onready var initSize = displayLabel.size
@onready var initPos = displayLabel.position
@export var controller:Control
var toClear = false
var sizeChanges = [0]
var lastDiff = 0

func _ready() -> void:
	for i in btns:
		i.pressed.connect(typing.bind(i.get_text()))
func typing(s):
	var xSize = displayLabel.size.x
	if s == "C" or toClear:
		displayLabel.set_text("")
		displayLabel.set_position(initPos)
		displayLabel.set_size(initSize)
		sizeChanges.clear()
		find_child("Buttons").find_child("plus").set_disabled(false)
		find_child("Buttons").find_child("minus").set_disabled(false)
		find_child("Buttons").find_child("mult").set_disabled(false)
		controller.set_val(0)
		controller.equationDisplay.set_text("")
		if not toClear: return
		toClear = false
	if s == "⌫":
		if not displayLabel.get_text(): return
		if len(displayLabel.get_text()) >= 3:
			if displayLabel.get_text()[-1] == " ":
				displayLabel.set_text(displayLabel.get_text().left(-3))
				displayLabel.position.x += sizeChanges[-1]
				displayLabel.size.x -= sizeChanges[-1]
				sizeChanges.pop_back()
				if not ("+" in displayLabel.get_text()or "-" in displayLabel.get_text() or "×" in displayLabel.get_text()):
					find_child("Buttons").find_child("mult").set_disabled(false)
					find_child("Buttons").find_child("plus").set_disabled(false)
					find_child("Buttons").find_child("minus").set_disabled(false)
				return
		displayLabel.set_text(displayLabel.get_text().left(-1))
		displayLabel.position.x += sizeChanges[-1]
		displayLabel.size.x -= sizeChanges[-1]
		sizeChanges.pop_back()
		return
	if s == "=":
		controller.parse(displayLabel.get_text(),btns)
		return
	if s == "+" or s == "-":
		displayLabel.set_text(displayLabel.get_text()+" "+s+" ")
		find_child("Buttons").find_child("mult").set_disabled(true)
	elif s == "×":
		displayLabel.set_text(displayLabel.get_text()+" "+s+" ")
		find_child("Buttons").find_child("plus").set_disabled(true)
		find_child("Buttons").find_child("minus").set_disabled(true)
	elif s != "C":
		displayLabel.set_text(displayLabel.get_text()+s)
	await get_tree().create_timer(0.001).timeout
	sizeChanges.append(displayLabel.size.x-xSize)
	if sizeChanges[-1]:
		displayLabel.position.x -= sizeChanges[-1]
