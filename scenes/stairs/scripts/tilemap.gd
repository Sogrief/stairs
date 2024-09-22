extends TileMap

@export var spike_zone : PackedScene
var spike_zone_layer : int = 1

func _ready():
	add_spike_zones()
	
#------------------- fonction d'ajout d'une kill_zone aux tiles spikes -------------------
func add_spike_zones():
	var spikes_tiles = get_used_cells(spike_zone_layer) # récupération de la position des tiles spikes
	
	for i in range(spikes_tiles.size()):
		#------------------- instanciation d'une kill zone à la position de chaque spike -------------------
		var spike_instance = spike_zone.instantiate()
		add_child(spike_instance)
		spike_instance.position = map_to_local(spikes_tiles[i])
			
