class_name player
extends CharacterBody2D

@onready var game_over_menu : CanvasLayer = %game_over_menu
@onready var delay_between_dash = $delay_between_dash
@onready var wall_jump_collision_shape = $area_2d/area_collision_shape_2d

#------------------- constantes -------------------
const SPEED : float = 300.0
const DASH_FORCE : float = 1000.0
const JUMP_VELOCITY : float = -620.0

#------------------- variables -------------------
var gravity : int = 980
var jump_count : int = 0
var wall_jump_sensitivity : int = 10 # velocité minimale en y pour pouvoir effectuer le prochain wall jump
var wall_jump_shape_height : int = 122

# fonctionnalité de dash
@export var double_tap_interval : float = 0.3 # délai en secondes entre deux pressions de touches pour détecter un dash
@export var dash_duration : float = 0.8 # durée des dashs
var dash_time : float # temps restant du dash en cours
var tap_count_right : int = 0 # nombre de fois que arrow_right a été pressé dans un cours labste de temps
var tap_count_left : int = 0 # nombre de fois que arrow_left a été pressé dans un cours labste de temps
var can_dash : bool = true
var can_break_projectile : bool = false # est ce que le joueur peut casser un projectile
var absolute_direction : float # dernière direction à droite ou à gauche, soit une varialbe égale à 1 ou -1
var prev_absolute_dir : float # précédente valeur de la variable absolute_direction
var dash_count_on_air : int = 0 # nombre de dash sans toucher le sol
	

func _physics_process(delta):
	#SceneTreeTimer
	#------------------- vol du personnage(debug) -------------------
	#if Input.is_action_pressed("jump"):
		#position.y -= 100
		#
	#if Input.is_action_pressed("move_down"):
		#position.y += 100
	
	#------------------- mouvements du personnage -------------------
	if !is_on_floor():
		velocity.y += gravity * delta
	else:
		dash_count_on_air = 0

	if Input.is_action_just_pressed("jump") and (is_on_floor() || jump_count > 0): # si le joueur saute et est au sol ou touche un mur
		jump_count = 0
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * SPEED
		absolute_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED / 4) # SPEED / 4 pour atténuer la décélération

	#------------------- dash du personnage -------------------
	double_tap()
	dash(direction, absolute_direction)
	
	if dash_time > 0 && abs(velocity.x) > 1000: # si en cours de dash et vitesse suffisante
		can_break_projectile = true
		wall_jump_collision_shape.shape.height = 188
	else:
		can_break_projectile = false
		wall_jump_collision_shape.shape.height = wall_jump_shape_height
	
	move_and_slide()

#------------------- fonction de double tap -------------------
func double_tap():
	if Input.is_action_just_pressed("move_left"):
		if can_dash == true:
			tap_count_left += 1
			
			if tap_count_left == 2: # deuxième fois que le joueur appuie & délai dash pas en cours	
				delay_between_dash.start()
				dash_time = dash_duration
				tap_count_left = 0
				can_dash = false
				
				if dash_count_on_air == 0:
					if !is_on_floor():
						dash_count_on_air += 1
						jump_count += 1
				
		else:
			tap_count_left = 0
		
	if Input.is_action_just_pressed("move_right"):
		if can_dash == true:
			tap_count_right += 1
			
			if tap_count_right == 2: # deuxième fois que le joueur appuie & délai dash pas en cours
				delay_between_dash.start()
				dash_time = dash_duration
				tap_count_right = 0
				can_dash = false
				
				if dash_count_on_air == 0:
					if !is_on_floor():
						dash_count_on_air += 1
						jump_count += 1
				
		else:
			tap_count_right = 0
	
	if 1 in [tap_count_left, tap_count_right]:
		double_tap_interval -= get_process_delta_time()
		
		if double_tap_interval < 0.0: # intervale entre deux touches insuffisant => double tap non détecté
			double_tap_interval = 0.5
			tap_count_right = 0
			tap_count_left = 0
			
#------------------- fonction de dash -------------------
func dash(dash_direction, absolute_dir):
	var direction_change : bool
	
	# détection du changement de direction du joueur
	if prev_absolute_dir != absolute_dir: 
		direction_change = true
	else:
		direction_change = false
	
	prev_absolute_dir = absolute_dir
	
	if dash_time > 0 && direction_change != true:
		var dash_progress : float = dash_time / dash_duration
		velocity.x += lerp(0.0, DASH_FORCE * dash_direction, dash_progress)
		dash_time -= get_process_delta_time()
	else: # si la direction du joueur a changé durant le dash
		dash_time = 0 # arrêt du dash en cours
		
#------------------- fonction de mort -------------------
func death():
	game_over_menu.show() # affiche le menu game over quand le joueur meurt
	
func _on_area_2d_body_entered(body):
	if body is TileMap:
		if velocity.y > wall_jump_sensitivity:
			jump_count = 1
			dash_count_on_air = 0
	
	if body is projectile:
		if can_break_projectile: # si le joueur peut briser un projectile
			body.queue_free()

func _on_delay_between_dash_timeout():
	can_dash = true
	
