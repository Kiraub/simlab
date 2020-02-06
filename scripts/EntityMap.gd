extends TileMap

class_name EntityMap

""" Constants """

enum E_Tiles {
	INVALID = -1
	FLOOR	= 0
	WALL	= 1
}

""" Variables """

var rng = RandomNumberGenerator.new()
export var provide_random_targets	: bool = false
export var deep_has_over_traversal	: bool = false

var entities				: Array
var highlighted_entities	: Array

var cache_cells_by_id		: Dictionary = {}
var cache_entities_by_flags	: Dictionary = {}
var cache_entities_by_map	: Dictionary = {}

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
	#add_entities(collect_static_entities(self))
	center_entities()

""" Static methods """

static func collect_child_entities(node : Node) -> Array:
	var array = []
	var subtrees = []
	for child in node.get_children():
		if child is Entity:
			array.append(child as Entity)
		elif (child as Node).get_child_count() != 0:
			subtrees.append(child as Node)
	for subtree in subtrees:
		for subchild in collect_child_entities(subtree):
			array.append(subchild)
	return array

""" Simulation step """

func step_entities(step_count : float) -> void:
	clear_caches()
	for entity in entities:
		if not entity is Actor:
			continue
		var actor : Actor = (entity as Actor)
		actor.step_by(step_count)
		if provide_random_targets:
			if actor.position == actor.get_final_target():
				highlighted_entities = [actor]
				var random_target = get_random_floor_tile()
				handle_position_selection(random_target)
				for actor in highlighted_entities:
					actor.set_highlighted(false)
				highlighted_entities.clear()

""" Setters / Getters """

""" Methods """

#[override]
func get_used_cells_by_id(id : int) -> Array:
	if not cache_cells_by_id.has(id):
		cache_cells_by_id[id] = .get_used_cells_by_id(id)
	return cache_cells_by_id[id].duplicate()

func clear_caches() -> void:
	cache_cells_by_id.clear()
	cache_entities_by_flags.clear()
	cache_entities_by_map.clear()

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

func handle_position_selection(map : Vector2) -> void:
	var selectable_entities = get_entities_with_flags(Entity.E_EntityFlags.Selectable)
	var clicked_entities = filter_entities_at_map(selectable_entities, map)
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
				#print_debug("Highlighted actor gets target")
	else:
		for entity in highlighted_entities:
			(entity as Entity).set_highlighted(false)
		highlighted_entities.clear()
		#print_debug("Highlights cleared")
	for entity in clicked_entities:
		(entity as Entity).set_highlighted(true)
		highlighted_entities.append(entity)
		#print_debug("Entity highlighted")

func get_entities_with_flags(flags : int) -> Array:
	if not cache_entities_by_flags.has(flags):
		cache_entities_by_flags[flags] = filter_entities_with_flags(entities, flags)
	return cache_entities_by_flags[flags].duplicate()

func filter_entities_with_flags(original : Array, flags : int) -> Array:
	var filtered = []
	for entity in original:
		if (entity as Entity).EntityFlags & flags == flags:
			filtered.push_back(entity)
	return filtered

func get_entities_at_map(map : Vector2) -> Array:
	if not cache_entities_by_map.has(map):
		cache_entities_by_map[map] = filter_entities_at_map(entities, map)
	return cache_entities_by_map[map].duplicate()

func filter_entities_at_map(original : Array, map : Vector2) -> Array:
	var filtered = []
	for entity in original:
		if world_to_map(entity.position) == map:
			filtered.push_back(entity)
	return filtered

func get_random_floor_tile() -> Vector2:
	var random_tile = Vector2.ZERO
	var floor_tiles = get_used_cells_by_id(E_Tiles.FLOOR)
	if len(floor_tiles) > 0:
		var random_index = rng.randi_range(0, len(floor_tiles)-1)
		random_tile = floor_tiles[random_index]
	return random_tile

func center_to_cell(world : Vector2) -> Vector2:
	var map		:= world_to_map(world)
	var origin	:= map_to_world(map)
	var center	:= origin + (cell_size / 2)
	return center

func tile_is_blocked(map : Vector2) -> bool:
	var tile_index = get_cellv(map)
	if tile_index == E_Tiles.WALL || tile_index == E_Tiles.INVALID:
		return true
	for entity in get_entities_at_map(map):
		if entity.is_blocking():
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
	for entity in get_entities_with_flags(Entity.E_EntityFlags.Blocking):
		blocked_tiles.append(world_to_map(entity.position))
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

""" Events """

func _on_path_exhausted(path : Array, search_strategy : int = 0) -> void:
	pass

func _on_entity_spawned(spawn_scene : PackedScene, initial_position : Vector2) -> void:
	if not spawn_scene is PackedScene:
		return
	var entity = spawn_scene.instance()
	if not entity is Entity:
		entity.queue_free()
	(entity as Entity).position = initial_position
	add_child(entity)
	entity.owner = self
	add_entity(entity)
