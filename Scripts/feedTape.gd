extends Control
var labels = []
@onready var initPos = position
@onready var headings = find_child("headings")
@onready var tape = find_child("tape")
@onready var graveyard = find_child("graveyard")
signal moveDone
var index = 0
signal killDone
func kill():
	if index < len(labels)-1:
		var tween = create_tween()
		tween.tween_property(tape, "position", tape.position-Vector2(0,labels[index+1].size.y+2) , 0.2)\
			.set_trans(Tween.TRANS_QUAD)
		labels[index+1].queue_free()
		labels[index+1].reparent(graveyard)
		await tween.finished
	index += 1
	var moveTween = create_tween()
	moveTween.tween_property(self, "position",Vector2(0,-162), 0.5)\
		.set_trans(Tween.TRANS_QUAD)
	var fadeTween = create_tween()
	fadeTween.tween_property(self,"modulate:a",0.0,0.3)
	await moveTween.finished
	for i in get_children():
		for j in i.get_children():
			j.queue_free()
			j.reparent(graveyard)
	index = 0
	position = initPos
	labels.clear()
	headings.position = Vector2(0,0)
	tape.position = Vector2(0,0)
	modulate.a = 1.0
	emit_signal("killDone")
func setup(ins):
	for i in ins:
		var l = RichTextLabel.new()
		l.set_size(Vector2(256,32))
		l.fit_content = true
		l.set_position(Vector2(0,labels[-1].position.y+labels[-1].size.y+2 if labels else 2))
		l.add_theme_color_override("default_color","ffffff" if i[0] == "P" else "a1a1a1")
		l.set_text(i.right(-1))
		l.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
		l.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
		if i[0] == "P":
			var sep = ColorRect.new()
			sep.set_color("515151")
			sep.set_size(Vector2(256,2))
			sep.set_position(Vector2(0,labels[-1].position.y+labels[-1].size.y+2 if labels else 2)) 
			(tape if labels else headings).add_child(sep)
			l.position.y += 4
		(tape if labels else headings).add_child(l)
		labels.append(l)

func move():
	var tween = create_tween()
	tween.tween_property(tape, "position", tape.position-Vector2(0,labels[index+1].size.y+2) , 0.2)\
		.set_trans(Tween.TRANS_QUAD)
	var ftween = create_tween()
	ftween.tween_property(labels[index+1], "modulate:a",0.0, 0.18)
	await tween.finished
	labels[index+1].queue_free()
	labels[index+1].reparent(graveyard)
	index += 1
	if index == len(labels): return
	if  labels[index+1].get_theme_color("default_color") == Color("ffffff"):
		tape.get_child(0).reparent(headings)
		tape.get_child(0).reparent(headings)
		var tTween = create_tween()
		tTween.tween_property(tape, "position", tape.position-Vector2(0,headings.get_child(-3).size.y+6) , 0.2)\
			.set_trans(Tween.TRANS_QUAD)
		var hTween = create_tween()
		hTween.tween_property(headings, "position", headings.position-Vector2(0,headings.get_child(-3).size.y+6) , 0.2)\
			.set_trans(Tween.TRANS_QUAD)
		for i in headings.get_children().slice(-3,-5,-1):
			var fadeTween = create_tween()
			fadeTween.tween_property(i, "modulate:a", i.modulate.a - 0.7 , 0.2)
		for i in headings.get_children().slice(-5,-7,-1):
			var fadeTween = create_tween()
			fadeTween.tween_property(i, "modulate:a", i.modulate.a - 0.2, 0.2)
		index+=1
		await tTween.finished
	emit_signal("moveDone")
