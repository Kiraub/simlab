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
	z_index = GLOBALS.Z_INDICIES.BACKGROUND

func _ready():
	add_entities(collect_child_entities(self))
	add_entities(collect_wall_entities(self))
	center_entities()

""" Simulation step """

func step_entities(delta : float) -> void:
	for entity in get_entities():
		if entity is Actor:
			process_actor(entity as Actor, delta)

""" Setters / Getters """

func set_entities(new_entities : Array) -> void:
	for entity in new_entities:
		if not entity is Entity:
			return
	entities = new_entities
func get_entities() -> Array:
	return entities

""" Methods """

func add_entity(entity : Entity) -> void:
	if not entities.has(entity):
		entities.append(entity)
func add_entities(new_entities : Array) -> void:
	for entity in new_entities:
		if entity is Entity:
			add_entity(entity)

func center_entities() -> void:
	for entity in entities:
		if not entity is Entity:
			continue
		(entity as Entity).position = center_to_cell((entity as Entity).position)

func process_actor(actor : Actor, delta : float) -> void:
	var targets := actor.get_targets()
	var travel_distance := actor.get_speed() * delta;
	if len(targets) > 0:
		var next_target : Vector2 = targets.pop_front()
		var new_actor_position := actor.position
		var distance_to_next : float = (next_target - new_actor_position).length()
		while travel_distance > 0:
			if travel_distance < distance_to_next:
				new_actor_position += (next_target - new_actor_position).normalized() * travel_distance
				travel_distance = 0
			else:
				travel_distance -= distance_to_next
				new_actor_position = next_target
				actor.remove_target(0)
				if len(targets) > 0:
					next_target = targets.pop_front()
					distance_to_next = (next_target - new_actor_position).length()
		actor.position = new_actor_position

func handle_position_selection(map : Vector2) -> void:
	var target_entities = get_entities_at(map)
	## highlight selected
	for entity in get_entities():
		# check if new actor_target should be added
		if len(target_entities) == 0 && (entity as Entity).get_highlighted():
			pass
		if target_entities.has(entity):
			(entity as Entity).set_highlighted(true)
		else:
			(entity as Entity).set_highlighted(false)
		
	"""TODO"""

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

func collect_wall_entities(entitymap : EntityMap) -> Array:
	var array = []
	for map in get_used_cells():
		var tile_index = get_cellv(map)
		if tile_index == E_Tiles.WALL:
			var world = map_to_world(map)
			var wall_entity = Static.new('Wall', world)
			wall_entity.set_blocking(true)
			array.push_back(wall_entity)
	return array

func get_entities_at(map : Vector2) -> Array:
	var target_entities = []
	for entity in get_entities():
		if center_to_cell(entity.position) == map:
			target_entities.push_back(entity)
	return target_entities

func center_to_cell(world : Vector2) -> Vector2:
	var map		:= world_to_map(world)
	var origin	:= map_to_world(map)
	var center	:= origin + (cell_size / 2)
	return center

func tile_is_blocked(world : Vector2) -> bool:
	var map :=	world_to_map(world)
	if get_cell(map.x as int, map.y as int) == E_Tiles.WALL:
		return false
	"""TODO"""
	return true


