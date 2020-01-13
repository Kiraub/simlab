extends TileMap

class_name EntityMap

""" Constants """

enum E_Tiles {
	FLOOR	= 0
	WALL	= 1
}

""" Variables """

var entities : Array = [] setget set_entities, get_entities

""" Initialization """

func _init():
	pass

func _ready():
	add_entities(collect_child_entities(self))
	center_child_entities()

""" Setters / Getters """
func set_entities(new_entities : Array) -> void:
	for entity in new_entities:
		if not entity is Entity:
			return
	entities = new_entities
func get_entities() -> Array:
	return entities

""" Methods """

func collect_child_entities(node : Node) -> Array:
	var array = []
	var subtrees = []
	for child in node.get_children():
		if child is Entity:
			array.append(child as Entity)
		if (child as Node).get_child_count() != 0:
			subtrees.append(child as Node)
	for subtree in subtrees:
		for subchild in collect_child_entities(subtree):
			array.append(subchild)
	return array

func add_entitiy(entity : Entity) -> void:
	if not entities.has(entity):
		entities.append(entity)
func add_entities(new_entities : Array) -> void:
	for entity in new_entities:
		if entity is Entity:
			add_entitiy(entity)

func center_to_cell(world : Vector2) -> Vector2:
	var map		:= world_to_map(world)
	var origin	:= map_to_world(map)
	var center	:= origin + (cell_size / 2)
	return center

func center_child_entities() -> void:
	for child in entities:
		if not child is Entity:
			continue
		(child as Entity).position = center_to_cell((child as Entity).position)

func tile_is_blocked(world : Vector2) -> bool:
	var map :=	world_to_map(world)
	if get_cell(map.x as int, map.y as int) == E_Tiles.WALL:
		return false
	return true


