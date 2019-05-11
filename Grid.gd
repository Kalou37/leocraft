extends TileMap

export var map_size = Vector2(22,10)

onready var player = $Player

onready var Inky = $Inky

onready var Blinky = $Blinky

onready var Pinky = $Pinky

onready var Clyde = $Clyde

onready var enemies = [Inky, Blinky, Pinky, Clyde]

var navigation = AStar.new()

var WALLS := [0,1]

var wall_list : Array

var walkable_cells : Array

var bonuses_position : Array

var mega_bonuses_position : Array

var grid

var scorePartie : int

var timerFlee = Timer.new()

var timerDead = Timer.new()

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
	$GameMusic.play()
	grid = get_parent()
	wall_list = get_used_cells_by_id(0) + get_used_cells_by_id(3)
	bonuses_position = get_used_cells_by_id(1)
	mega_bonuses_position = get_used_cells_by_id(2)
	get_walkable_cells() 
	astar_connect_walkable_cells()
	player.position = map_to_world(Vector2(9,11))
	timerFlee.set_wait_time(10)
	timerFlee.set_one_shot(true)
	timerFlee.connect("timeout", self, "_on_flee_timeout")
	add_child(timerFlee)
	timerDead.set_wait_time(3)
	timerDead.set_one_shot(true)
	timerDead.connect("timeout", self, "restartGame")
	add_child(timerDead)
	for enemy in enemies:
		enemy.position = map_to_world(enemy.start_position)

func _process(delta):
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
			elif enemy.is_fleeing():
				enemy.get_eaten()
	if player.grid_position in bonuses_position:
		retirerPiece(player.grid_position)
	if player.grid_position in mega_bonuses_position:
		superPiece(player.grid_position)

func stopGame():
	player.get_eaten()
	Inky.set_standing()
	Blinky.set_standing()
	Pinky.set_standing()
	Clyde.set_standing()
	Inky.startTimer.stop()
	Blinky.startTimer.stop()
	Pinky.startTimer.stop()
	Clyde.startTimer.stop()
	$GameMusic.stop()
	timerDead.start()

func retirerPiece(pos):
	self.set_cellv(pos, 4)
	bonuses_position.erase(pos)
	scorePartie += 1

func superPiece(pos):
	timerFlee.start()
	self.set_cellv(pos, 4)
	mega_bonuses_position.erase(pos)
	scorePartie += 5
	for enemy in enemies :
		enemy.set_fleeing()
	$FleeSound.play()
	$GameMusic.pitch_scale = 2
		
func _on_flee_timeout():
	$GameMusic.pitch_scale = 1
	for enemy in enemies :
		enemy.set_following()
		
func restartGame():
	for enemy in enemies :
		enemy.position = map_to_world(enemy.start_position)
		enemy._ready()
	player.position = map_to_world(Vector2(9,11))
	player.restart()
	$GameMusic.play()