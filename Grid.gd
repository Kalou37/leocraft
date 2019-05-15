extends TileMap

export var map_size = Vector2(22,10)

onready var player = $Player

onready var Inky = $Inky

onready var Blinky = $Blinky

onready var Pinky = $Pinky

onready var Clyde = $Clyde

onready var enemies = [Inky, Blinky, Pinky, Clyde]

var navigation = AStar.new()

var wall_list : Array

var walkable_cells : Array

var bonuses_position : Array

var mega_bonuses_position : Array

var caseVide : Array = []

var pieceTabEnours : int = 5

var ncase = Vector2(-1,-1)

#warning-ignore:unused_class_variable
var grid = get_parent()

var scorePartie : int

var timerFlee = Timer.new()

var timerFleeEnd = Timer.new()

var timerDead = Timer.new()

var timerTableau = Timer.new()

var player_victory : bool = false

var player_defeat : bool = false

var elements_restant : int = 0

export var player_life : int = 3

var premPiece : bool = true

# --Gestion tableaux
var imgT1 = Image.new()
var imgT2 = Image.new()
var imgT3 = Image.new()
var imgT4 = Image.new()
var imgT5 = Image.new()
var imgV = Image.new()
var modeTableau : int = 0

var imageTexture1 = ImageTexture.new()
var imageTexture4 = ImageTexture.new()
var imageTexture5 = ImageTexture.new()

var coord = []


##----

func get_player_pos() -> Vector2:
	return(world_to_map(player.position))
	
func get_player_dir() -> Vector2:
	return(player.direction)
	
func get_walkable_cells() -> void:
	walkable_cells = []
	for y in range(map_size.y):
		for x in range(map_size.x):
			var cell = Vector2(x,y)
			if cell in wall_list : continue
			var cell_id = cell.x + map_size.x * cell.y
			navigation.add_point(cell_id, Vector3(cell.x,cell.y,0.0))
			walkable_cells.append(cell)

func out_of_bounds(cell : Vector2) -> bool:
	return cell.x < 0 or cell.y < 0 or cell.x >= map_size.x or cell.y >= map_size.y

func astar_connect_walkable_cells() -> void :
	for cell in walkable_cells:
		var cell_id = cell.x + map_size.x * cell.y
		var ortho_neighbors = PoolVector2Array([
			cell + Vector2(1,0),
			cell + Vector2(-1,0),
			cell + Vector2(0,1),
			cell + Vector2(0,-1),
		])
		for neighbor in ortho_neighbors:
			var neighbor_id = neighbor.x + map_size.x * neighbor.y
			if out_of_bounds(neighbor) : continue
			if not navigation.has_point(neighbor_id) : continue
			navigation.connect_points(cell_id, neighbor_id, false)

func can_move(from : Vector2, direction : Vector2) -> bool:
	var npos = from + direction
	if npos in wall_list :
		return false
	return true

func get_enemy_pos(id : String) -> Vector2:
	match id:
		"Inky":
			return world_to_map(Inky.position)
		"Blinky":
			return world_to_map(Blinky.position)
		"Pinky":
			return world_to_map(Pinky.position)
		"Clyde":
			return world_to_map(Clyde.position)
	return Vector2()

func astar_get_next_cell(cell_from : Vector2, cell_to : Vector2) -> Vector2:
	var cell_from_id = cell_from.x + map_size.x * cell_from.y
	var cell_to_id = cell_to.x + map_size.x * cell_to.y
	var path = navigation.get_point_path(cell_from_id, cell_to_id)
	if path.size() > 1 :
		return Vector2(path[1].x,path[1].y)
	return Vector2()

func _ready():
	$GameOver.visible = false
	for x in range(0, 10):
		for y in range(0,14):
			coord.push_back(int((x*100)+y))
	imgT1 = preload("res://assets/world/canvas_185x240.png")
	imgT2 = preload("res://assets/world/canvas_color.png")
	imgT3 = preload("res://assets/world/black.png")
	imgT4 = preload("res://assets/world/canvas_185x240.png")
	imgT5 = preload("res://assets/world/canvas_185x240.png")
	imgV = preload("res://assets/UI/screen_victory_char.png")
	imageTexture1.create_from_image(imgT1, 7)
	imageTexture4.create_from_image(imgT4, 7)
	imageTexture5.create_from_image(imgT5, 7)

	$Victoire.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	scorePartie = 0
	$GameMusic.play()
	wall_list = get_used_cells_by_id(0) + get_used_cells_by_id(3)
	bonuses_position = get_used_cells_by_id(1)
	mega_bonuses_position = get_used_cells_by_id(2)
	elements_restant = bonuses_position.size()+mega_bonuses_position.size() + 3
	$HUD/TxtElRes/DynElRes.text = str(elements_restant)
	get_walkable_cells() 
	astar_connect_walkable_cells()
	player.position = map_to_world(player.POS_INIT)
	timerFlee.set_wait_time(8)
	timerFlee.set_one_shot(true)
	timerFlee.connect("timeout", self, "_on_flee_timeout")
	add_child(timerFlee)
	timerFleeEnd.set_wait_time(2)
	timerFleeEnd.set_one_shot(true)
	timerFleeEnd.connect("timeout", self, "_on_flee_end_timeout")
	add_child(timerFleeEnd)
	timerDead.set_wait_time(3)
	timerDead.set_one_shot(true)
	timerDead.connect("timeout", self, "restartGame")
	add_child(timerDead)
	timerTableau.set_wait_time(2)
	timerTableau.set_one_shot(true)
	timerTableau.connect("timeout", self, "tableau_up")
	add_child(timerTableau)
	for enemy in enemies:
		enemy.position = map_to_world(enemy.start_position)

#warning-ignore:unused_argument
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if player_defeat:
#warning-ignore:return_value_discarded
			get_tree().reload_current_scene()
		if player_victory:
			$Victoire.texture = imgV
			player_defeat = true
	if player.grid_position == Vector2():
		return
	if (player.grid_position.x == -2):
		player.position = map_to_world(Vector2(19,player.grid_position.y))
	if (player.grid_position.x == 20):
		player.position = map_to_world(Vector2(-1,player.grid_position.y))
		
	for enemy in enemies :
		if player.grid_position == enemy.grid_position :
			if enemy.is_following():
				stopGame()
			elif enemy.is_fleeing() or enemy.is_end_fleeing():
				scorePartie += 10
				$HUD/TxtScore/DynScore.text = str(scorePartie)
				enemy.get_eaten()
	if player.grid_position in bonuses_position:
		retirerPiece(player.grid_position)
	if player.grid_position in mega_bonuses_position:
		superPiece(player.grid_position)
	if player.grid_position == ncase:
		if pieceTabEnours < 9:
			tableau_up()

func stopGame():
	$GameMusic.stop()
	for enemy in enemies:
		enemy.stopAll()
	if(player_victory):
		$VictorySound.play()
		for enemy in enemies:
			enemy.tween.stop_all()
			enemy.set_process(false)
		player.tween.stop_all()
		player.set_process(false)
		$Victoire/DynScore.text = str(scorePartie)
		$Victoire.visible = true
	elif(player_life <= 1):
		$HUD/TxtVies/DynVies.text = str(0)
		player.get_eaten()
		$PlayerGO.play()
		player_defeat = true
		$GameOver.visible = true
	else:
		player_life = player_life-1
		$HUD/TxtVies/DynVies.text = str(player_life)
		player.get_eaten()
		$PlayerDead.play()
		timerDead.start()

func retirerPiece(pos):
	if(premPiece):
		timerTableau.start()
		premPiece = false
	bonuses_position.erase(pos)
	scorePartie += 1
	itemMoins(pos)


func superPiece(pos):
	timerFleeEnd.stop()
	timerFlee.start()
	mega_bonuses_position.erase(pos)
	scorePartie += 5
	itemMoins(pos)
	if(!bonuses_position.empty() or !mega_bonuses_position.empty()):
		for enemy in enemies :
			enemy.set_fleeing()
		$FleeSound.play()
		$GameMusic.pitch_scale = 2
		player.set_transformation(true)

func itemMoins(pos):
	caseVide.push_back(pos)
	if(coord.size() > 0):
		add_piece()
	self.set_cellv(pos, 8)
	elements_restant = elements_restant-1
	$HUD/TxtElRes/DynElRes.text = str(elements_restant)
	$HUD/TxtScore/DynScore.text = str(scorePartie)
	if(bonuses_position.empty() && mega_bonuses_position.empty()):
		player_victory = true
		stopGame()

func _on_flee_timeout():
	timerFleeEnd.start()
	for enemy in enemies :
		if(enemy.is_fleeing()):
			enemy.set_fleeingEnd()
	
func _on_flee_end_timeout():
	$GameMusic.pitch_scale = 1
	for enemy in enemies :
		enemy.set_following()
	player.set_transformation(false)
		
func restartGame():
	for enemy in enemies :
		enemy.position = map_to_world(enemy.start_position)
		enemy.set_standing()
		enemy.startTimer.start()
	player.position = map_to_world(player.POS_INIT)
	player.current_state = player.state.PREY
	player.anim.play("down")
	player.set_process(true)
	$GameMusic.pitch_scale = 1
	$GameMusic.play()
	
func add_piece():
	var n = coord[randi() % coord.size()]
	coord.erase(n)
	var x = floor(n/100)
	var y = n-(x*100)
	imgT1.blend_rect(imgT3, Rect2(x*18,y*17,18,17), Vector2(x*18,y*17))
	imgT4.blend_rect(imgT2, Rect2(x*18,y*17,18,17), Vector2(x*18,y*17))
	imageTexture1.create_from_image(imgT1, 7)
	imageTexture4.create_from_image(imgT4, 7)
	change_mode_tableau()
	
func tableau_up():
	print("tableau")
	self.set_cellv(ncase, 8)
	ncase = caseVide[randi() % caseVide.size()]
	caseVide.erase(ncase)
	self.set_cellv(ncase, pieceTabEnours)
	pieceTabEnours += 1
	elements_restant -= 1
	$HUD/TxtElRes/DynElRes.text = str(elements_restant)
	modeTableau += 1
	if(modeTableau > 1):
		add_piece()
	change_mode_tableau()

		
func change_mode_tableau():
	if(modeTableau == 2):
		$Tableau.set_texture(imageTexture5)
	if(modeTableau == 3):
		$Tableau.set_texture(imageTexture1)
	elif(modeTableau == 4):
		$Tableau.set_texture(imageTexture4)
		for caseRestante in bonuses_position :
			self.set_cellv(caseRestante, 4)
	