extends CanvasLayer

var cur_pos = 0
var nxt_pos = 0
var max_pos = 0
var lst = []
var lstR = []

#signal selected_item(value)

func _ready():
	get_tree().paused = true
	
	lst = $Ecran.get_children()
	lstR = $Regard.get_children()
	for i in range(1, lst.size() ):
		lst[i].visible = false
	for i in range(1, lstR.size() ):
		lstR[i].visible = false
	max_pos = lst.size() - 1


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
	
func change_pos(new_pos):
	print("New pos : ", new_pos)
	for i in range ( lst.size() ):
		if i == new_pos :
			lst[i].visible = true
			lstR[i].visible = true
		else :
			lst[i].visible = false
			lstR[i].visible = false
			
func on_valid_menu():
	match cur_pos:
		0:
			get_tree().paused = false
		1:
			get_tree().paused = false
			get_tree().reload_current_scene()
		2:
			get_tree().quit()
		
	queue_free()
