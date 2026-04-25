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
func update_value(v,duration:float,comp):
	if v == heaven*5 + earth and not comp:
		emit_signal("updateDone")
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
		heaven_tween.tween_property(heaven_bead, "position", heaven_bead.position + Vector2(0,heaven_diff*delta_heaven), duration/5.0)\
		.set_trans(Tween.TRANS_QUAD)
		var style = heaven_bead.get_theme_stylebox("disabled").duplicate()
		if comp and delta_heaven>0:
			style.border_color = Color("666666")
			heaven_bead.add_theme_stylebox_override("disabled", style)
		if style.border_color == Color("666666") and delta_heaven<0:
			style.border_color = Color("ffffff")
			heaven_bead.add_theme_stylebox_override("disabled", style)
		if not delta_earth: await heaven_tween.finished
	for _i in range(abs(delta_earth)):
		var earth_tween = create_tween()
		earth_tween.tween_property(earths[earth_id], "position", earths[earth_id].position + Vector2(0,earth_diff*-1), duration/5.0)\
		.set_trans(Tween.TRANS_QUAD)
		var style = earths[earth_id].get_theme_stylebox("disabled").duplicate()
		if comp and earth_diff > 0:
			style.border_color = Color("666666")
			earths[earth_id].add_theme_stylebox_override("disabled", style)
		if style.border_color == Color("666666") and earth_diff<0:
			style.border_color = Color("ffffff")
			earths[earth_id].add_theme_stylebox_override("disabled", style)
		await earth_tween.finished
		earth_id+=1*sign(delta_earth)
	if delta_earth<0:
		earth_id+=1
	earth_diff = abs(earth_diff)
	heaven = heaven_target
	earth = earth_taget
	await get_tree().create_timer(0.01).timeout
	emit_signal("updateDone")
