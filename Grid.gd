extends TileMap

#The map size in number of cells
export var map_size = Vector2(22,10)

#pointer to the player
onready var player = $Player

#pointer to the Inky ghost
onready var Inky = $Inky

#pointer to the Blinky ghost
onready var Blinky = $Blinky

#pointer to the Pinky ghost
onready var Pinky = $Pinky

#pointer to the Clyde ghost
onready var Clyde = $Clyde

#Array of the enemies (useful for group actions)
onready var enemies = [Inky, Blinky, Pinky, Clyde]

#setting up a pathfinding algorithm to manage the ghosts
var navigation = AStar.new()

#ID of walls on the gridmap
var WALLS := [0,1]

#list of Vector2 of walls cells (in grid coordidates)
var wall_list : Array

#list of Vector2 of the walkable cells for the pathfinding algorithm (in grid coordidates)
var walkable_cells : Array

#list of Vector2 of the bonuses position (in grid coordidates)
var bonuses_position : Array

#return a Vector2 of the player's position in grid coordinates
func get_player_pos() -> Vector2:
	#when you work with a grid you often need to go from real coordinates (the pixels in the window)
	#to grid coordinates (the cell's coordinates inside the grid
	#for this we have two functions : 
	#	world_to_map -> converts coordinates in the window into grid coordinates
	#	map_to_world -> converts grid cell coordinates into window's pixel coordinates
	#to ease working with maps, unless stated otherwise every coordinates pair are in grid coordinates
	return(world_to_map(player.position))
	
#builds the class variable walkable_cells (I.E. get dynamicly all the cells that are not walls)
#and add them to the pathfinding class
func get_walkable_cells() -> void:
	walkable_cells = []
	for y in range(map_size.y):
		for x in range(map_size.x):
			var cell = Vector2(x,y)
			if cell in wall_list : continue
			var cell_id = cell.x + map_size.x * cell.y
			navigation.add_point(cell_id, Vector3(cell.x,cell.y,0.0))
			walkable_cells.append(cell)

#return true if the cell is out of the grid's bounds
func out_of_bounds(cell : Vector2) -> bool:
	return cell.x < 0 or cell.y < 0 or cell.x >= map_size.x or cell.y >= map_size.y

#builds automaticaly the graph of the walkable cells for the pathfinding algorithm
#by connecting walkable cells that are next to each other
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

#return true if the cell from+direction is walkable
func can_move(from : Vector2, direction : Vector2) -> bool:
	var npos = from + direction
	if npos in wall_list :
		return false
	return true

#return the grid coordinates of the enemy
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

#Returns the next cell to go for a path that goes from cell_from to cell_to

func astar_get_next_cell(cell_from : Vector2, cell_to : Vector2) -> Vector2:
	var cell_from_id = cell_from.x + map_size.x * cell_from.y
	var cell_to_id = cell_to.x + map_size.x * cell_to.y
	var path = navigation.get_point_path(cell_from_id, cell_to_id)
	if path.size() > 1 :
		return Vector2(path[1].x,path[1].y)
	return Vector2()


#Called once when the Game scene is loaded (like a constructor in OOP)

func _ready():
	wall_list = get_used_cells_by_id(0) + get_used_cells_by_id(1)
	get_walkable_cells() 
	astar_connect_walkable_cells()
	player.position = map_to_world(Vector2(9,11))
	for enemy in enemies:
		enemy.position = map_to_world(enemy.start_position)


#called every frame, thats where the logic of the game is implemented
#I.E. check if the player is eaten by ghosts and so on 
func _process(delta):
	if player.grid_position == Vector2():
		return
	print('player : ',player.grid_position)
	if (player.grid_position.x == -1):
		player.position = map_to_world(Vector2(18,player.grid_position.y))
	if (player.grid_position.x == 19):
		player.position = map_to_world(Vector2(0,player.grid_position.y))
	for enemy in enemies :
		if player.grid_position == enemy.grid_position :
			print('enemy : ',enemy.grid_position)
			if enemy.is_following():
				player.get_eaten()
				Inky.set_victorious()
				Blinky.set_victorious()
				Pinky.set_victorious()
				Clyde.set_victorious()
				print("toto")
			elif enemy.is_fleeing():
				enemy.get_eaten()
				player.eat_enemy()
	#TODO : Create a Bonus scene and manage the bonus logic 
	#	in the grid and in the player
	#if player.grid_position in bonuses_position:
	#	var bonus = get_bonus_at(player.grid_position)
	#	player.eat_bonus(bonus.get_type())
		
			
			
			
