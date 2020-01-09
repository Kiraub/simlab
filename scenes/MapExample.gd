extends TileMap

class_name NavMap

func _ready():
	pass

func center_to_cell(position : Vector2) -> Vector2:
	var map := world_to_map(position)
	var origin := map_to_world(map)
	var center := origin + (cell_size / 2)
	return center







