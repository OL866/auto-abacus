extends Button

@onready var destination = Vector2(position.x,get_parent().find_child("Base").position.y-size.y)
@onready var initPos = position


var moved = false

func _on_pressed() -> void:
	set_disabled(true)
	set_text("ON" if moved else "OFF")
	var tween = create_tween()
	tween.tween_property(self, "position", initPos if moved else destination , 0.4)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	await tween.finished
	moved = !moved
	set_disabled(false)
