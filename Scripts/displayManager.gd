extends Control
var abacusPart = preload("res://Scenes/abacus_section.tscn")
var abacusLeft = preload("res://Scenes/abacus_section_L.tscn")
var abacusRight =  preload("res://Scenes/abacus_section_R.tscn")
var sections = []
var digits = []
signal displayDone
@export var initVal = "0"
@export var count = 8
@export var placeVals = false
@export var lexes = true
func _ready() -> void:
	for i in range(count):
		var section = abacusPart.instantiate() if i else abacusLeft.instantiate()
		if i == count-1: section = abacusRight.instantiate()
		section.set_position(Vector2(64*i,0))
		add_child(section)
		sections.append(section)
		var digit = RichTextLabel.new()
		digit.add_theme_font_size_override("normal_font_size", 32)
		digit.set_size(Vector2(64,64))
		digit.set_position(Vector2(64*i,192))
		digit.set_text("0")
		digit.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
		digit.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
		add_child(digit)
		digits.append(digit)
		if not lexes: continue
		var lex = RichTextLabel.new()
		lex.add_theme_font_size_override("normal_font_size", 32)
		lex.set_size(Vector2(64,64))
		lex.set_position(Vector2(64*i,256))
		lex.set_text(char(65+i))
		lex.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
		lex.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
		add_child(lex)
		if not placeVals: continue
		var place = RichTextLabel.new()
		place.add_theme_font_size_override("normal_font_size", 32)
		place.set_size(Vector2(64,64))
		place.set_position(Vector2(64*i,320))
		place.set_text("10")
		place.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
		place.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
		add_child(place)
		var superscript = RichTextLabel.new()
		superscript.add_theme_font_size_override("normal_font_size", 18)
		superscript.set_size(Vector2(64,64))
		superscript.set_position(Vector2(64*i+24,308))
		superscript.set_text(str(i*-1+7))
		superscript.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
		superscript.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
		add_child(superscript)
	if initVal != "0":display(Array(initVal.split("")).map(func(n):return int(n)),0.2,false)
func display(abacus,duration,comp):
	for i in range(-1,-1*count-1,-1):
		if digits[i].get_text() != str(abacus[i]) or comp:
			var numTween = create_tween()
			sections[i].update_value(abacus[i],duration,false if i==-1 and not abacus[i] else comp)
			numTween.tween_method(func(v):digits[i].text = str(int(v)), int(digits[i].text), abacus[i] if not comp or (i==-1 and not abacus[i])  else 9-abacus[i], duration)
	await get_tree().create_timer(duration).timeout
	emit_signal("displayDone")
