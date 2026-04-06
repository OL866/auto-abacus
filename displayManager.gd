extends Control

var digits = []
func _ready() -> void:
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
			var diff = abacus[i] - int(digits[i].get_text()) 
			for j in range(1,abs(diff)+1):
				digits[i].set_text(str(int(digits[i].get_text())+sign(diff)*1))
				await get_tree().create_timer(duration/abs(diff)).timeout
