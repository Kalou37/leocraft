extends Node2D

#These directional vectors alllows us to write code more simply
var UP = Vector2(0,-1)
var DOWN = Vector2(0,1)
var LEFT = Vector2(-1,0)
var RIGHT = Vector2(1,0)
var IDLE = Vector2(0,0)

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
	if grid.can_move(grid_position, direction):
		moving = true
		#to move smoothlly from one cell to the next
		tween.interpolate_property(self,"position", grid.map_to_world(grid_position), grid.map_to_world(grid_position+direction), 
			0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
		tween.start()
		#move until the tween animation is over
		yield(tween,"tween_completed")
		moving = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	grid_position = grid.get_player_pos()
	#get input from the player in a Vector2 that will be
	#one of the directional vectors. IDLE happens when there are no input 
	var input_direction = Vector2(int(Input.is_action_pressed("ui_right"))-int(Input.is_action_pressed("ui_left")),
					int(Input.is_action_pressed("ui_down"))-int(Input.is_action_pressed("ui_up")))
	#if the input is valid (not IDLE) it will be our next direction
	if input_direction != IDLE :
		next_direction = input_direction
	
	#if we can move from our position in the next direction, 
	#we need to change some values
	if grid.can_move(grid_position, next_direction):
		direction = next_direction
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
	current_state = state.DEAD