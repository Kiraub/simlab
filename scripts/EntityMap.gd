extends TileMap

class_name EntityMap

""" Constants """

enum E_Tiles {
	FLOOR	= 0
	WALL	= 1
}

""" Variables """

var rng = RandomNumberGenerator.new()
export var provide_random_targets : bool = false
export var deep_has_over_traversal : bool = false

var entities : Array = [] setget , get_entities
var actors : Array = []
var statics : Array = []
var highlighted_entities : Array = []

var static_free_tiles : Array = []
var static_blocked_tiles : Array = []

var cached_by_flag : Dictionary = {}

""" Initialization """

#[override]
func _init():
	self.name = "EntityMap"
	z_index = GLOBALS.Z_INDICIES.BACKGROUND
	rng.randomize()
	var h = hash(rng.get_seed())
	rng.set_seed(h)

#[override]
func _ready():
	add_entities(collect_child_entities(self))
	add_entities(collect_static_entities(self))
	center_entities()

""" Simulation step """

func step_entities(step_count : float) -> void:
	for actor in actors:
		actor.step_by(step_count)
	if provide_random_targets:
		for actor in actors:
			if actor.position == actor.get_final_target():
				highlighted_entities = [actor]
				var random_target = get_random_free_tile()
				handle_position_selection(random_target)
				for actor in highlighted_entities:
					actor.set_highlighted(false)
				highlighted_entities.clear()

""" Setters / Getters """

func get_entities() -> Array:
	return entities

func get_random_free_tile() -> Vector2:
	var random_tile = Vector2.ZERO
	if len(static_free_tiles) > 0:
		var random_index = rng.randi_range(0, len(static_free_tiles)-1)
		random_tile = static_free_tiles[random_index]
	return random_tile

""" Static methods """

static func collect_child_entities(node : Node) -> Array:
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

static func collect_static_entities(entitymap : EntityMap) -> Array:
	var array = []
	for map in entitymap.get_used_cells():
		var tile_index = entitymap.get_cellv(map)
		var world = entitymap.map_to_world(map)
		if tile_index == E_Tiles.WALL:
			var wall_entity = Static.new('Wall', world)
			wall_entity.set_blocking(true)
			entitymap.add_child(wall_entity)
			array.push_back(wall_entity)
		elif tile_index == E_Tiles.FLOOR:
			var floor_entity = Static.new('Floor', world)
			floor_entity.set_blocking(false)
			entitymap.add_child(floor_entity)
			array.push_back(floor_entity)
	return array

static func collect_entities_flags(entitymap : EntityMap, flags : int) -> Array:
	if not entitymap.cached_by_flag.has(flags):
		var collection = []
		for entity in entitymap.get_entities():
			if (entity as Entity).EntityFlags & flags == flags:
				collection.append(entity)
		entitymap.cached_by_flag[flags] = collection
	return entitymap.cached_by_flag.get(flags).duplicate()

""" Methods """

func add_entity(entity : Entity) -> void:
	if not entities.has(entity):
		entities.append(entity)
		if entity is Static:
			statics.append(entity)
			if entity.is_blocking():
				var tile = world_to_map(entity.position)
				static_blocked_tiles.append(tile)
			else:
				var tile = world_to_map(entity.position)
				static_free_tiles.append(tile)
		elif entity is Actor:
			actors.append(entity)
func add_entities(new_entities : Array) -> void:
	for entity in new_entities:
		if entity is Entity:
			add_entity(entity)

func center_entities() -> void:
	for entity in entities:
		if not entity is Entity:
			continue
		(entity as Entity).position = center_to_cell((entity as Entity).position)

func handle_position_selection(map : Vector2) -> void:
	var selectable_entities = collect_entities_flags(self, Entity.E_EntityFlags.Selectable)
	var clicked_entities = get_entities_at(map, Entity.E_EntityFlags.Selectable)
	if len(clicked_entities) == 0:
		#print_debug("Empty space clicked")
		for entity in highlighted_entities:
			if entity is Actor:
				var actor_map = world_to_map((entity as Actor).get_final_target())
				var path_map = find_path(actor_map, map)
				if len(path_map) == 0:
					#print_debug("Empty or impossible path")
					continue
				for point_map in path_map:
					var point_world = center_to_cell(map_to_world(point_map))
					(entity as Actor).push_target_back(point_world)
				#(entity as Actor).push_target_back(map)
				#print_debug("Highlighted actor gets target")
	else:
		for entity in highlighted_entities:
			(entity as Entity).set_highlighted(false)
		highlighted_entities.clear()
		#print_debug("Highlights cleared")
	for entity in clicked_entities:
		if selectable_entities.has(entity):
			(entity as Entity).set_highlighted(true)
			highlighted_entities.append(entity)
			#print_debug("Entity highlighted")

func get_entities_at(map : Vector2, flags : int = 0) -> Array:
	var target_entities = []
	for entity in collect_entities_flags(self, flags):
		if world_to_map(entity.position) == map:
			target_entities.push_back(entity)
	return target_entities

func center_to_cell(world : Vector2) -> Vector2:
	var map		:= world_to_map(world)
	var origin	:= map_to_world(map)
	var center	:= origin + (cell_size / 2)
	return center

func tile_is_blocked(map : Vector2) -> bool:
	if map in static_blocked_tiles:
		return true
	for actor in actors:
		if actor is Actor and actor.is_blocking() and world_to_map(actor.position) == map:
			return true
	return false

func find_path(map_start : Vector2, map_end : Vector2) -> Array:
	if map_start == map_end:
		return []
	var bfs = breadth_first_search(map_start, map_end)
	if len(bfs) > 0:
		return bfs
	return []

func breadth_first_search(map_start : Vector2, map_end : Vector2) -> Array:
	#print_debug(self, "Doing bfs from", map_start, "to", map_end)
	var found_end = false
	var expansions = [Vector2.UP, Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT]
	var paths = [[map_start]]
	var blocked_tiles = []
	var traversed_tiles = [map_start]
	while(len(paths) > 0 and not found_end):
		var path : Array = paths.pop_front()
		var last = path.back()
		for expansion in expansions:
			var new_point = last + expansion
			if blocked_tiles.has(new_point):
				continue
			elif tile_is_blocked(new_point):
				blocked_tiles.append(new_point)
				continue
			if path.has(new_point):
				continue
			if deep_has_over_traversal:
				if deep_has(paths, new_point):
					continue
			elif traversed_tiles.has(new_point):
				continue
			else:
				traversed_tiles.append(new_point)
			var expanded_path = path.duplicate()
			expanded_path.push_back(new_point)
			paths.push_back(expanded_path)
			if new_point == map_end:
				found_end = true
				break
	if found_end:
		for path in paths:
			if (path as Array).front() == map_start and (path as Array).back() == map_end:
				return path
	return []

func deep_has(array_of_arrays : Array, elem) -> bool:
	if array_of_arrays.has(elem):
		return true
	for array in array_of_arrays:
		if array is Array and deep_has(array, elem):
			return true
	return false


