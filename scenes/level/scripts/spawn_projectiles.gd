extends Node2D

@export var projectile : PackedScene
@onready var projectile_launcher := %sprite_2d # lanceur de projectile
@onready var path : Path2D = %path_2d # parcours 2D de la map
@onready var player : CharacterBody2D = %player # joueur

var path_points : Array # l'ensemble des points du path2D
var player_position : Vector2 # la position en temps réel du joueur
var closest_point : Vector2
var timer : float = 1.0 # le délai entre chaque projectile


func _ready():
	path_points = get_all_points_from_path(path) # récupération de tous les points du path2D

func _process(delta):
	closest_point = path_points[get_closest_path_point(path_points, player_position)]
	print(closest_point)
	
	
	player_position = player.global_position
	
	timer -= delta
	
	if timer < 0.0:
		timer = 1.0
		
		# ajout d'un nouveau projectile
		var projectile_instance = projectile.instantiate()
		add_child(projectile_instance)
		

func get_closest_path_point(points : Array, player_pos : Vector2):
	var distances_from_player : Array = []
	
	for i in range(points.size()):
		var distance = points[i].distance_to(player_pos) #distance entre le joueur et chaque point du path
		distances_from_player.append(distance)
		
	return distances_from_player.find(distances_from_player.min()) #retourne l'indice du point le plus proche du joueur
	
		

func get_all_points_from_path(path : Path2D) -> Array: # méthode qui récupère tous les points du Path 2D
	var points = []
	
	# vérifie si le Path2D a une courbe
	if path.curve:
		var curve = path.curve
		var point_count = curve.get_point_count() # nombre de points de la courbe
		
		# récupération de chaque point
		for i in range(point_count):
			var point_position = curve.get_point_position(i)
			points.append(point_position)
			
	return points
	
	
