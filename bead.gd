extends Button
@export var targetY = 80
@export var down = true
@export var delay:float
@export_file_path("*.tscn") var scenePath
@onready var targetScene = load(scenePath)
@onready var destination = Vector2(position.x,get_parent().find_child("Base").position.y - (size.y if down else get_parent().find_child("Base").find_child("Base").size.y*-1))
@onready var initPos = position
var going = false
func _ready() -> void:
	await get_tree().create_timer(delay).timeout
	var tween = create_tween()
	tween.tween_property(self, "position", destination, 1)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
func _on_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", initPos , 1)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	var new_stylebox_hover = get_theme_stylebox("normal").duplicate()
	add_theme_stylebox_override("hover", new_stylebox_hover)
	going = true
func _process(_delta: float) -> void:
	if position.y <= targetY and going and down:
		fader_load(scenePath)
	elif position.y >= targetY and going and not down:
		fader_load(scenePath)
func fader_load(s):
	await Fade.fade_out()
	get_tree().change_scene_to_file(s)
	await Fade.fade_in()
