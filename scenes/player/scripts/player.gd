extends CharacterBody2D

#constantes
const SPEED : float = 300.0
const JUMP_VELOCITY : float = -550.0

#autres variables
var gravity : int = 980
var jump_count : int = 0

func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and (is_on_floor() || jump_count > 0):
		jump_count = 0
		velocity.y = JUMP_VELOCITY

	var direction : int = Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _on_area_2d_body_entered(body):
	if body is TileMap:
		jump_count = 1


func _on_area_2d_body_exited(body):
	if body is TileMap:
		pass
