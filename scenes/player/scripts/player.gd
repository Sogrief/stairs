class_name player
extends CharacterBody2D

@onready var game_over_menu : CanvasLayer = %game_over_menu
@onready var delay_between_dash = $delay_between_dash

# constantes
const SPEED : float = 300.0
const DASH_FORCE : float = 500.0
const JUMP_VELOCITY : float = -550.0

# autres variables
var gravity : int = 980
var jump_count : int = 0
var wall_jump_sensitivity : int = 10 # velocité minimale en y pour pouvoir effectuer le prochain wall jump
@export var double_tap_interval : float = 0.5 # délai en secondes entre deux pressions de touches pour détecter un dash
@export var dash_duration : float = 0.8 # durée des dashs
var dash_time : float # temps restant du dash en cours
var tap_count_right : int = 0 # nombre de fois que arrow_right a été pressé dans un cours labste de temps
var tap_count_left : int = 0 # nombre de fois que arrow_left a été pressé dans un cours labste de temps
var can_dash : bool = true
var dash_direction : float

func _physics_process(delta):
	#------------------- mouvements du personnage -------------------
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_pressed("jump") and (is_on_floor() || jump_count > 0):
		jump_count = 0
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	#------------------- dash du personnage -------------------
	if Input.is_action_just_pressed("move_left"):
		if can_dash == true:
			tap_count_left += 1
			
			if tap_count_left == 2: # deuxième fois que le joueur appuie & délai dash pas en cours
				delay_between_dash.start()
				dash_time = dash_duration
				dash_direction = direction
				tap_count_left = 0
				can_dash = false
				
		else:
			tap_count_left = 0
		
	if Input.is_action_just_pressed("move_right"):
		if can_dash == true:
			tap_count_right += 1
			
			if tap_count_right == 2: # deuxième fois que le joueur appuie & délai dash pas en cours
				delay_between_dash.start()
				dash_time = dash_duration
				dash_direction = direction
				tap_count_right = 0
				can_dash = false
				
		else:
			tap_count_right = 0
	
	if 1 in [tap_count_left, tap_count_right]:
		double_tap_interval -= delta
		
		if double_tap_interval < 0.0: # intervale entre deux touches insuffisant => double tap non détecté
			double_tap_interval = 0.5
			tap_count_right = 0
			tap_count_left = 0
			
	dash(dash_direction)
	
	move_and_slide()
	

#------------------- fonction de dash -------------------
func dash(dash_direction):

	if dash_time > 0:
		var dash_progress : float = dash_time / dash_duration
		dash_time -= get_process_delta_time()
		#velocity.x += DASH_FORCE * dash_direction
		velocity.x += lerp(0.0, DASH_FORCE * dash_direction, dash_progress)
		
#------------------- fonction de mort -------------------
func death():
	game_over_menu.show() # affiche le menu game over quand le joueur meurt
	
func _on_area_2d_body_entered(body):
	if body is TileMap:
		if velocity.y > wall_jump_sensitivity:
			jump_count = 1

func _on_area_2d_body_exited(body):
	if body is TileMap:
		pass

#fonction à mettre dans game manager plutôt ?
func _on_main_child_entered_tree(node):
	if node is projectile: # vérifie si un projectile est ajouté à la scène
		node.player_collision.connect(death)

func _on_delay_between_dash_timeout():
	can_dash = true
