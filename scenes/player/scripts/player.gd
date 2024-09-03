class_name player
extends CharacterBody2D

@onready var game_over_menu : CanvasLayer = %game_over_menu

# constantes
const SPEED : float = 300.0
const JUMP_VELOCITY : float = -550.0

# autres variables
var gravity : int = 980
var jump_count : int = 0
var wall_jump_sensitivity : int = 10 # velocité minimal en y pour pouvoir effectuer le prochain wall jump
var double_tap_interval : float = 0.3 # délai en secondes entre deux pressions de touches pour détecter un dash
var tap_count : int = 0 # nombre de pressions de touches successives

func _physics_process(delta):
	
	#------------------- dash du personnage -------------------
	double_tap_interval -= delta
	
	if double_tap_interval < 0.0:
		double_tap_interval = 0.3
		print(delta)
		
	
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
