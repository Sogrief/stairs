extends CharacterBody2D

#constantes
const SPEED : float = 300.0
const JUMP_VELOCITY : float = -400.0

#autres variables
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is TileMap:
		print("entered")


func _on_area_2d_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if body is TileMap:
		print("exited")
