extends Node2D

export var ID : String

export var start_position : Vector2

var start_all_position = Vector2(9,9)

onready var anim = $AnimatedSprite

onready var grid = get_parent()

onready var tween = $AnimatedSprite/Tween

#onready var player = $Player

enum behavior {FOLLOW, FLEE, FLEE_END, STAND, DEAD, VICTORIOUS}

var current_behavior = behavior.STAND

#var player_position : Vector2

var grid_position : Vector2

var startTimer = Timer.new()
var timerDelay = 0

func _ready():
	if(ID == "Blinky"):
		timerDelay = 1
	elif(ID == "Pinky"):
		timerDelay = 1.8
	elif(ID == "Inky"):
		timerDelay = 2.6
	elif(ID == "Clyde"):
		timerDelay = 3.4

	startTimer.set_wait_time(timerDelay)
	startTimer.set_one_shot(true)
	startTimer.connect("timeout", self, "_on_Timer_timeout")
	current_behavior = behavior.STAND
	add_child(startTimer)
	startTimer.start()
	#	
	position = grid.map_to_world(start_position)

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
		anim.play(ID)
		move_time = 0.2
		next_position = grid.astar_get_next_cell(grid_position,objective)
	elif current_behavior == behavior.FLEE:
		objective = get_next_flee_cell()
		anim.play("Flee")
		move_time = 0.3
		next_position = grid.astar_get_next_cell(grid_position,objective)
	elif current_behavior == behavior.FLEE_END:
		objective = get_next_flee_cell()
		if(ID == "Blinky"):
			anim.play("FleeEndBlinky")
		elif(ID == "Pinky"):
			anim.play("FleeEndPinky")
		elif(ID == "Inky"):
			anim.play("FleeEndInky")
		elif(ID == "Clyde"):
			anim.play("FleeEndClyde")
		move_time = 0.5
		next_position = grid.astar_get_next_cell(grid_position,objective)
	elif current_behavior == behavior.STAND:
		anim.play(ID)
		move_time = 0
	elif current_behavior == behavior.DEAD:
		#I'm dead I blink and go back home
		objective = start_all_position
		anim.play("Eyes")
		move_time = 0.1
		next_position = grid.astar_get_next_cell(grid_position,objective)
		if grid_position == start_all_position :
			current_behavior = behavior.FOLLOW
	elif current_behavior == behavior.VICTORIOUS:
		print("#Je vous emmerde et je rentre à ma maison")
		anim.play("follow")
		current_behavior = behavior.FOLLOW
	

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

func get_next_flee_cell():
	var pos_fuite = Vector2()
	if(grid.get_player_pos().x < grid.get_enemy_pos(ID).x):
		pos_fuite.x = 17
	else:
		pos_fuite.x = 1
	if(grid.get_player_pos().y < grid.get_enemy_pos(ID).y):
		pos_fuite.y = 19
	else:
		pos_fuite.y = 1
	if((grid.get_enemy_pos(ID) == Vector2(1,1)) or (grid.get_enemy_pos(ID) == Vector2(1,19)) or (grid.get_enemy_pos(ID) == Vector2(17,1)) or (grid.get_enemy_pos(ID) == Vector2(17,19))):
		if(abs(grid.get_enemy_pos(ID).x-grid.get_player_pos().x) < abs(grid.get_enemy_pos(ID).y-grid.get_player_pos().y)):
    		pos_fuite.x = abs(pos_fuite.x-18)
		else:
			pos_fuite.y = abs(pos_fuite.y-20)
	return(pos_fuite)
	
func _on_Timer_timeout():
	current_behavior = behavior.FOLLOW

#Set the Enemy behavior when he is eaten by Pacman
func get_eaten() :
	current_behavior = behavior.DEAD
	$EatGhost.play()

#Set the Enemy bheavior when one of the has eaten Pacman
func set_victorious() :
	current_behavior = behavior.VICTORIOUS

func set_standing() : 
	current_behavior = behavior.STAND
	
func set_fleeing() : 
	current_behavior = behavior.FLEE
	
func set_fleeingEnd() : 
	current_behavior = behavior.FLEE_END
	
func set_following() : 
	current_behavior = behavior.FOLLOW

#retrun true if our current behavior is FOLLOW
func is_following() : 
	return current_behavior == behavior.FOLLOW
	

#retrun true if our current behavior is FLEE
func is_fleeing() : 
	return current_behavior == behavior.FLEE

func is_end_fleeing() : 
	return current_behavior == behavior.FLEE_END

func is_standing() : 
	return current_behavior == behavior.STAND
	
func stopAll():
	tween.stop_all()
	set_standing()
	startTimer.stop()
	set_process(true)