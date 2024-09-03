class_name player
extends CharacterBody2D

# constantes
@onready var game_over_menu : CanvasLayer = %game_over_menu
const SPEED : float = 300.0
const JUMP_VELOCITY : float = -550.0

# autres variables
var gravity : int = 980
var jump_count : int = 0
var wall_jump_sensitivity : int = 10 # velocité minimale en y pour pouvoir effectuer le prochain wall jump
var double_tap_interval : float = 0.5 # délai en secondes entre deux pressions de touches pour détecter un dash
var tap_count_right : int = 0 # nombre de fois que arrow_right a été pressé dans un cours labste de temps
var tap_count_left : int = 0 # nombre de fois que arrow_left a été pressé dans un cours labste de temps
var can_dash : float = false

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

	move_and_slide()
	
	#------------------- dash du personnage -------------------
	if Input.is_action_just_pressed("move_left"):
		tap_count_left += 1
		
		if tap_count_left == 2: # si c'est la deuxième fois que le joueur appuie
			print(direction)
			tap_count_left = 0
		
	if Input.is_action_just_pressed("move_right"):
		tap_count_right += 1
		
		if tap_count_right == 2: # si c'est la deuxième fois que le joueur appuie
			print(direction)
			tap_count_right = 0
	
	if tap_count_left or tap_count_right == 1:
		double_tap_interval -= delta
		
		if double_tap_interval < 0.0:
			double_tap_interval = 0.5
			tap_count_right = 0
			tap_count_left = 0

func test(delta):
	double_tap_interval -= delta
	
	if double_tap_interval < 0:
		double_tap_interval = 0.3
		print("test")

func death():
	game_over_menu.show() # affiche le menu game over quand le joueur meurt

func _on_area_2d_body_entered(body):
	if body is TileMap:
		if velocity.y > wall_jump_sensitivity:
			jump_count = 1

func _on_area_2d_body_exited(body):
	if body is TileMap:
		pass

func _on_main_child_entered_tree(node):
	if node is projectile: # vérifie si un projectile est ajouté à la scène
		node.player_collision.connect(death)
