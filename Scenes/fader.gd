extends CanvasLayer

@onready var rect = $ColorRect

func fade_out(duration := 0.5):
	rect.visible = true
	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, duration)
	await tween.finished

func fade_in(duration := 0.5):
	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, duration)
	await tween.finished
	rect.visible = false
