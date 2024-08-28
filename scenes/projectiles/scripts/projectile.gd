class_name projectile
extends RigidBody2D

signal player_collision

func _on_area_2d_body_entered(body):
	if body is player:
		player_collision.emit()
