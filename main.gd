extends Node2D

var cur_pos = 0
var nxt_pos = 0
var max_pos = 0
var lst = []

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Intro.play()
	
	lst = $Boutons.get_children()
	for i in range(1, lst.size() ):
		lst[i].modulate.a = 0
	max_pos = lst.size() - 1
	
	if Input.is_action_just_pressed("ui_down"):
		nxt_pos += 1
	if Input.is_action_just_pressed("ui_up"):
		nxt_pos -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		on_valid_menu()
		
	if Input.is_action_just_pressed("ui_down"):
		nxt_pos += 1
	if Input.is_action_just_pressed("ui_up"):
		nxt_pos -= 1
		
	nxt_pos = clamp(nxt_pos, 0, max_pos)
	
	if cur_pos != nxt_pos :
		cur_pos = nxt_pos
		change_pos(nxt_pos)
		
func on_valid_menu():
	match cur_pos:
		0:
			$Intro.stop()
			var m = preload("res://Game.tscn").instance()
			add_child( m )
		1:
			get_tree().quit()
	
func change_pos(pos):
	for i in range ( lst.size() ):
		if i == pos :
			lst[i].modulate.a = 1
		else :
			lst[i].modulate.a = 0
