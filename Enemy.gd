extends Node2D

#an ID for the enemy
export var ID : String

#its start_position on the grid
export var start_position : Vector2

#var UP = Vector2(0,-1)
#var DOWN = Vector2(0,1)
#var LEFT = Vector2(-1,0)
#var RIGHT = Vector2(1,0)
#var IDLE = Vector2(0,0)

#pointer to the AnimatedSprite cild
onready var anim = $AnimatedSprite

#pointer to the grid
onready var grid = get_parent()

#pointer to the Tween child
#in game development tweening is the process of
#calcultating interpolations between two positions
#to move an object
onready var tween = $AnimatedSprite/Tween

#the diferent behaviors of the enemy
#allows us to implement a state machine for the enemy
#	"if I am in this state, I know I must do precisely this thing
#-> FOLLOW : Follow pacman and try to eat him
#-> FLEE : Pacman can eat ghots we must flee him
#-> DEAD : I'm dead, I go back to my starting point
#-> VICTORIOUS : one of us has eaten Pacman but we still need to go somewhere
enum behavior {FOLLOW, FLEE, DEAD, VICTORIOUS}

#the starting behavior
var current_behavior = behavior.FOLLOW

#we always know where the player is (updated each frame)
var player_position : Vector2

#The position of the enemy in grid coordinates
var grid_position : Vector2

#Set the enemy position to its init posisition
func _ready():
	pass
	#position = grid.map_to_world(start_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var objective = Vector2()
	var move_time : float
	var next_position = Vector2()
	grid_position = grid.get_enemy_pos(ID)
	#The Enemy must act according to its behavior
	if current_behavior == behavior.FOLLOW:
		#I'm following, my objective is Pacman
		objective = grid.get_player_pos()
		anim.play("follow")
		move_time = 0.4
		next_position = grid.astar_get_next_cell(grid_position,objective)
	elif current_behavior == behavior.FLEE:
		#I'm fleeing, mmy objective is far away from pacman
		objective = grid.map_size
		anim.play("flee")
		move_time = 0.3
		next_position = grid.astar_get_next_cell(grid_position,objective)
	elif current_behavior == behavior.DEAD:
		#I'm dead I blink and go back home
		next_position = start_position
		anim.play("blink")
		move_time = 1.5
		if grid_position == start_position :
			current_behavior = behavior.FOLLOW
	elif current_behavior == behavior.VICTORIOUS:
		print("#I go back home to bring my trophy")
		next_position = start_position
		anim.play("follow")
		move_time = 1.5
		if grid_position == start_position :
			current_behavior = behavior.FOLLOW
	
	print(current_behavior)
	#I get my next position from the grid

	if next_position == Vector2():
		return
	#when process is set to false the _process function is not called until
	#until it is set back to true, this allows us to perform e full animation
	#and motion of the enemy before trying to get it's next position
	#without this, the enemy would almost teleport itself on its target
	set_process(false)
	#this allows us to move smoothly from on cell to the next
	tween.interpolate_property(self,"position", grid.map_to_world(grid_position), grid.map_to_world(next_position), 
			move_time, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	tween.start()
	#wait for the tween to be over before continuing
	yield(tween,"tween_completed")
	
	#we now allow _process to be called on the next frame since we are finished moving
	#this will allow us to get our next position and move to it
	set_process(true)
	
#Set the Enemy behavior when he is eaten by Pacman
func get_eaten() :
	current_behavior = behavior.DEAD

#Set the Enemy bheavior when one of the has eaten Pacman
func set_victorious() :
	current_behavior = behavior.VICTORIOUS

#retrun true if our current behavior is FOLLOW
func is_following() : 
	return current_behavior == behavior.FOLLOW

#retrun true if our current behavior is FLEE
func is_fleeing() : 
	return current_behavior == behavior.FLEE