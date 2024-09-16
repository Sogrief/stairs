extends Node2D

@onready var player_reference = %player

func _on_button_pressed():
	get_tree().reload_current_scene() #rejoue la scène actuelle


