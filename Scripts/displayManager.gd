extends Control
var abacusPart = preload("res://Scenes/abacus_section.tscn")
var sections = []
var digits = []
signal displayDone

func _ready() -> void:
	for i in range(8):
		var section = abacusPart.instantiate()
		section.set_position(Vector2(64*(i-4),-200))
		add_child(section)
		sections.append(section)
	for i in range(8):
		var digit = RichTextLabel.new()
		digit.add_theme_font_size_override("normal_font_size", 32)
		digit.set_size(Vector2(64,64))
		digit.set_position(Vector2(64*(i-4),0))
		digit.set_text("0")
		digit.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
		digit.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
		add_child(digit)
		digits.append(digit)
		var lex = RichTextLabel.new()
		lex.add_theme_font_size_override("normal_font_size", 32)
		lex.set_size(Vector2(64,64))
		lex.set_position(Vector2(64*(i-4),64))
		lex.set_text(char(65+i))
		lex.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
		lex.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
		add_child(lex)

func display(abacus,duration):
	for i in range(-1,-9,-1):
		if digits[i].get_text() != str(abacus[i]):
			var numTween = create_tween()
			sections[i].update_value(abacus[i],duration)
			numTween.tween_method(func(v):digits[i].text = str(int(v)), 0, abacus[i], duration)
			await sections[i].updateDone
	emit_signal("displayDone")
