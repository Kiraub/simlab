extends TileMap

class_name EntityMap

""" Constants """

enum Tiles {
	FLOOR	= 0
	WALL	= 1
}

""" Variables """

""" Initialization """

func _init():
	pass

func _ready():
	center_child_entities()

""" Methods """

func center_to_cell(position : Vector2) -> Vector2:
	var map := world_to_map(position)
	var origin := map_to_world(map)
	var center := origin + (cell_size / 2)
	return center

func center_child_entities() -> void:
	for child in $Tables.get_children():
		if not child is Entity:
			continue
		(child as Entity).position = center_to_cell((child as Entity).position)
	for child in $Waiters.get_children():
		if not child is Entity:
			continue
		(child as Entity).position = center_to_cell((child as Entity).position)





