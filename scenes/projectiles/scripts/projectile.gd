class_name projectile
extends RigidBody2D

signal player_collision

@export var projectile_size_array : Array[projectile_size] # tableau contenant des ressources de type projectile_size

func _on_area_2d_body_entered(body):
	if body is player:
		player_collision.emit()
