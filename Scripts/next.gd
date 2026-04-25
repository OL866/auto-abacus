extends Button

@export var displays:Array[Control]

@export var texts:Array[RichTextLabel]

@export var nIns1:Array[String]
@export_multiline() var tIns1:Array[String]
@export var nIns2:Array[String]
@export_multiline() var tIns2:Array[String]
@export var nIns3:Array[String]
@export_multiline() var tIns3:Array[String]
@onready var nIns = [nIns1,nIns2,nIns3]
@onready var tIns = [tIns1,tIns2,tIns3]
@export var comp:Array[bool] = [false,false,false]
var rDone = 0
var aDone = 0
var currentIns = 0
var incriments = 0.000001

signal removeDone
signal addDone

func _ready() -> void:
	set_disabled(true)
	await animate_all()
	set_disabled(false)
func remove_text(t):
	for i in range(len(t.get_text())):
		t.set_text(t.get_text().left(-1))
		await get_tree().create_timer(incriments).timeout
	rDone += 1
	if rDone == len(texts): emit_signal("removeDone")
func add_text(t,id):
	for i in range(len(tIns[id][currentIns])):
		t.set_text(t.get_text()+tIns[id][currentIns][i])
		await get_tree().create_timer(incriments).timeout
	aDone += 1
	if aDone == len(texts): emit_signal("addDone")
func animate_text(t,id):
	await remove_text(t)
	if rDone !=  len(texts): await removeDone
	await add_text(t,id)
func animate_all():
	rDone = 0
	aDone = 0
	for i in range(len(texts)):
		texts[i].set_visible(tIns[i][currentIns] != "kill")
		displays[i].set_visible(tIns[i][currentIns] != "kill")
		animate_text(texts[i],i)
		displays[i].display(Array(nIns[i][currentIns].split("")).map(func(n):return int(n)),0.5,comp[i])
	await addDone
func _on_pressed(path:NodePath) -> void:
	var prevBtn = get_node(path)
	set_disabled(true)
	currentIns += 1
	await animate_all()
	set_disabled(currentIns == len(nIns1)-1)
	prevBtn.set_disabled(currentIns == 0)
func _on_prev_pressed(path: NodePath) -> void:
	var prevBtn = get_node(path)
	prevBtn.set_disabled(true)
	currentIns -= 1
	await animate_all()
	set_disabled(currentIns == len(nIns1)-1)
	prevBtn.set_disabled(currentIns == 0)
