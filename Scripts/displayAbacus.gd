extends Control
@onready var heaven_bead = find_child("Beads").get_child(4)
@onready var heaven_diff = find_child("Base2").get_global_position().y - heaven_bead.get_global_position().y-heaven_bead.size.y
@onready var earth_diff = find_child("Beads").get_child(0).get_global_position().y - find_child("Base2").get_global_position().y - find_child("Base2").get_child(0).size.y

var earth_id = 0
var heaven = 0
var earth = 0
var earths = []
signal updateDone

func _ready() -> void:
	for i in find_child("Beads").get_children().slice(0,4):
		earths.append(i)
func update_value(v,duration):
	if v == heaven*5 + earth:
		return
	var heaven_target = 1 if v >= 5 else 0
	var delta_heaven = heaven_target - heaven
	var earth_taget = v - 5 if v >= 5 else v
	var delta_earth = earth_taget - earth
	if delta_earth<0:
		earth_id-=1
		earth_diff *= -1
	if delta_heaven:
		var heaven_tween = create_tween()
		heaven_tween.tween_property(heaven_bead, "position", heaven_bead.position + Vector2(0,heaven_diff*delta_heaven), duration/(abs(delta_earth) if delta_earth else 1))\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
		if not delta_earth: await heaven_tween.finished
	for _i in range(abs(delta_earth)):
		var earth_tween = create_tween()
		earth_tween.tween_property(earths[earth_id], "position", earths[earth_id].position + Vector2(0,earth_diff*-1), duration/abs(delta_earth))\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
		earth_id+=1*sign(delta_earth)
		await earth_tween.finished
	if delta_earth<0:
		earth_id+=1
	earth_diff = abs(earth_diff)
	heaven = heaven_target
	earth = earth_taget
	emit_signal("updateDone")
