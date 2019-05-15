extends Node2D

#These directional vectors alllows us to write code more simply
var UP = Vector2(0,-1)
var DOWN = Vector2(0,1)
var LEFT = Vector2(-1,0)
var RIGHT = Vector2(1,0)
var IDLE = Vector2(0,0)
var POS_INIT = Vector2(9,11)

#TODO : add variable for score and life counter
# and their logic

#pointer to the AnimatedSprite child
onready var anim = $AnimatedSprite

#pointer to the grid parent
onready var grid = get_parent()

#pointer to the Tween child
onready var tween = $AnimatedSprite/Tween

#Init the player direction
var direction = RIGHT

#will hold the next_direction according to the player's input
var next_direction :Vector2

#the player's position on the grid
var grid_position : Vector2

var mode_char : bool = false

#true if the player is currently moving
var moving = false

#the player's states : 
#-> PREY : the player is hunted by ghosts and can be eaten
#-> HUNTER : the player has eaten a bonus that allows him to eat ghosts
#-> DEAD : the player has been eaten 
enum state {PREY, HUNTER, DEAD}

#init the player's state
var current_state = state.PREY

func _ready():
	pass

#move the player
func move() :
	#iw we can move to the cell in grid_position + direction, we do
	if current_state != state.DEAD :
		if grid.can_move(grid_position, direction):
			moving = true
			#to move smoothlly from one cell to the next
			tween.interpolate_property(self,"position", grid.map_to_world(grid_position), grid.map_to_world(grid_position+direction), 
				0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
			tween.start()
			#move until the tween animation is over
			yield(tween,"tween_completed")
			moving = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var dir_x : int = 0
	var dir_y : int = 0
	grid_position = grid.get_player_pos()
	#get input from the player in a Vector2 that will be
	#one of the directional vectors. IDLE happens when there are no input 
	if Input.is_action_just_pressed("ui_down"):
		dir_y = 1
	if Input.is_action_just_pressed("ui_up"):
		dir_y = -1
	if Input.is_action_just_pressed("ui_right"):
		dir_x = 1
	if Input.is_action_just_pressed("ui_left"):
		dir_x = -1
		
		
	#if(Input.get_joy_axis(0, JOY_AXIS_0) != 0):
	#	dir_x = Input.get_joy_axis(0, JOY_AXIS_0)
	#if(Input.get_joy_axis(0, JOY_AXIS_1) != 0):
	#	dir_y = Input.get_joy_axis(0, JOY_AXIS_2)
	#if(int(Input.is_action_pressed("ui_right"))-int(Input.is_action_pressed("ui_left")) != 0):
	#	dir_x = int(Input.is_action_pressed("ui_right"))-int(Input.is_action_pressed("ui_left"))
	#if(int(Input.is_action_pressed("ui_down"))-int(Input.is_action_pressed("ui_up")) != 0):
	#	dir_y = int(Input.is_action_pressed("ui_down"))-int(Input.is_action_pressed("ui_up"))
	var input_direction = Vector2(dir_x, dir_y)
	#if the input is valid (not IDLE) it will be our next direction
	if input_direction != IDLE :
		next_direction = input_direction
	
	#if we can move from our position in the next direction, 
	#we need to change some values
	if current_state != state.DEAD:
		if grid.can_move(grid_position, next_direction):
			direction = next_direction
			if(!mode_char):
				if direction == UP :
					anim.play("up")
				elif direction == DOWN:
					anim.play("down")
				elif direction == LEFT:
					anim.play("left")
				elif direction == RIGHT:
					anim.play("right")
	#if we are not already moving we move.
	#this allows us to alwas move in the same direction
	#until :
	#	1) we hit a wall
	#	2) we go back
	#	3) we changed direction previously and we now can go there
	if not moving:
		move()

#The player has been eaten by a ghost, we set its stat to DEAD
#TODO : decrease lives
#	check for game over
func get_eaten():
	print("MORT")
	current_state = state.DEAD
	set_process(false)
	
func set_transformation(val):
	if(val):
		mode_char = true
		anim.play("char")
	else:
		mode_char = false
		anim.play("down")