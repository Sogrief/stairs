class_name kill_zone
extends Area2D

signal player_collision #signal envoyé lors de la collision de ce projectile avec le joueur

@onready var player_ref : CharacterBody2D = get_tree().current_scene.get_node("%player")

func _on_body_entered(body):
	if body is player:
		player_ref.death()
