class_name projectile
extends RigidBody2D

@onready var player_ref : CharacterBody2D = get_tree().current_scene.get_node("%player")
var custom_gravity : Vector2
var max_speed : float = 800.0

#------------------- propriétés du projectile à changer lorsque sa taille change -------------------
@onready var sprite_2d = $sprite_2d
@onready var collision_shape_2d = $collision_shape_2d
@onready var area_collision_shape_2d = $kill_zone/collision_shape_2d

@export var projectile_size_array : Array[projectile_size] # tableau contenant des ressources de type projectile_size
@export var size : SIZE:
	set(value):
		if value != size: # si la taille du projectile change le signal est envoyé
			size = value
			size_changed.emit()

#------------------- les différentes tailles de projectiles -------------------
enum SIZE {
	SMALL_1 = 0,
	SMALL_2 = 1,
	MEDIUM_1 = 2,
	MEDIUM_2 = 3,
	BIG_1 = 4
}

signal size_changed # signal envoyé lorsque la size du projectile est mise à jour

func _ready() -> void:
	size_changed.connect(projectile_update_size) # à la naissance du projectile, le signal de taille est connecté
	custom_integrator = true  # Activer le custom integrator pour cet objet
	
	custom_gravity = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity") * gravity_scale)

func _process(delta):
	#------------------- suppression du projectile si très loin du personnage -------------------
	var distance_from_player : int = global_position.distance_to(player_ref.global_position) # distance du projectile avec le joueur
	
	if distance_from_player > 6000: # si la distance est loin en dehors de l'écran du joueur
		queue_free() # le projectile est supprimmé
	
#------------------- mise à jour des propriétés du projectile lors de la réception du signal -------------------
func projectile_update_size() -> void:
	sprite_2d.scale = projectile_size_array[size].sprite_scale # taille du sprite 2D
	collision_shape_2d.shape = projectile_size_array[size].collision_shape # taille du collision shape 2D
	area_collision_shape_2d.shape = projectile_size_array[size].area_collision_shape # taille du collision shape de l'area 2D
		
#------------------- modifie la varialbe de gravité -------------------	
func set_gravity(dir: Vector2) -> void:
	custom_gravity = dir * gravity_scale
	
#------------------- met à jour la gravité quand moitié du niveau dépassée -------------------	
func _integrate_forces(state) -> void:
	state.linear_velocity += custom_gravity * state.step  # modification de la vélocité linéaire de l'objet
	var current_speed = state.linear_velocity.length()
	
	if current_speed > max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * (max_speed - size * 100) # plus l'objet est gros plus il est lent
	
