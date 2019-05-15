## Liste des bugs :
## Reste les instructions.

extends Node2D

var cur_pos = 0
var nxt_pos = 0
var max_pos = 0
var lst = []

var m = preload("res://Game.tscn").instance()
var ecrIns = preload("res://Instructions.tscn").instance()
var afficheInstruction = false
var launched : bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Intro.play()
	
	lst = $Boutons.get_children()
	for i in range(1, lst.size() ):
		lst[i].visible = false
	max_pos = lst.size() - 1
	
	if Input.is_action_just_pressed("ui_down"):
		nxt_pos += 1
	if Input.is_action_just_pressed("ui_up"):
		nxt_pos -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
        var cancel = preload("res://procedural/GUI/MenuPause.tscn").instance()
        add_child( cancel )
	if !launched:
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
	#if(!afficheInstruction):
		match cur_pos:
			0:
				lancer_jeu()
			1:
				add_child(ecrIns)
				afficheInstruction = true
			2:
				if !launched:
					get_tree().quit()
	
func lancer_jeu():
	$Intro.stop()
	add_child(m)
	virer_instructions()
	afficheInstruction = false
	launched = true

func virer_instructions():
	remove_child(ecrIns)
	ecrIns = preload("res://Instructions.tscn").instance()

func change_pos(pos):
	for i in range ( lst.size() ):
		if i == pos :
			lst[i].visible = true
		else :
			lst[i].visible = false
