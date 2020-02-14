extends TileMap

class_name EntityMap

""" Constants """


""" Variables """

export var provide_random_targets	: bool = false
export var deep_has_over_traversal	: bool = false

var config					: ConfigWrapper			setget , get_config_wrapper
var rng 					: RandomNumberGenerator
var entities				: = []
var highlighted_entities	: = []

"""
	Runtime caches
	These variables represent key-value dictionaries of time intensive getter functions' input-ouptut pairs.
	Since many of the results don't change every query, the results are cached.
"""

# written inside: get_entities_with_flags
# cleared inside: clear_caches
var cache_entities_by_flags	: = {}
var cache_entities_by_map	: = {}
var cache_tiles_by_id		: = {}
var cache_blocking_by_map	: = {}

""" Initialization """

#[override]
func _init():
	self.name = "EntityMap"
	z_index = GLOBALS.Z_INDICIES.BACKGROUND
	
	config = ConfigWrapper.new("EntityMap")
	config.add_config_entry("deep_has_over_traversal", {
		ConfigWrapper.FIELDS.LABEL_TEXT: "Deep has over traversal",
		ConfigWrapper.FIELDS.DEFAULT_VALUE: deep_has_over_traversal,
		ConfigWrapper.FIELDS.SIGNAL_NAME: "deep_has_over_traversal_changed"
	})
	config.connect("deep_has_over_traversal_changed", self, "_on_deep_has_over_traversal_changed")
	
	rng = RandomNumberGenerator.new()
	rng.randomize()
	var h = hash(rng.get_seed())
	rng.set_seed(h)

#[override]
func _ready():
	add_entities(collect_child_entities(self))
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

func step_by(amount : float) -> void:
	var actors = []
	for entity in entities:
		if not entity is Actor:
			continue
		var actor : Actor = (entity as Actor)
		actors.append(actor)
		if provide_random_targets:
			if actor.position == actor.get_final_target():
				highlighted_entities = [actor]
				var random_target = get_random_tile_by_id(GLOBALS.TILES.FLOOR)
				handle_position_selection(random_target)
				for actor in highlighted_entities:
					actor.set_highlighted(false)
				highlighted_entities.clear()
	for actor in actors:
		actor.step_by(amount)

""" Setters / Getters """

func get_config_wrapper() -> ConfigWrapper:
	return config

""" Methods """

#[override]
func get_used_cells_by_id(id : int) -> Array:
	if not cache_tiles_by_id.has(id):
		cache_tiles_by_id[id] = .get_used_cells_by_id(id)
	return cache_tiles_by_id[id].duplicate()

func get_random_tile_by_id(id : int) -> Vector2:
	var random_tile = Vector2.ZERO
	var tiles = get_used_cells_by_id(id)
	if len(tiles) > 0:
		var random_index = rng.randi_range(0, len(tiles)-1)
		random_tile = tiles[random_index]
	return random_tile

func get_center_of_cell_by_map(map : Vector2) -> Vector2:
	var origin	: = map_to_world(map)
	var center	: = origin + (cell_size * 0.5)
	return center
func get_center_of_cell_by_world(world : Vector2) -> Vector2:
	var map		: = world_to_map(world)
	return get_center_of_cell_by_map(map)

func tile_is_blocked(map : Vector2) -> bool:
	var tile_id = get_cellv(map)
	var use_cache = true
	if use_cache:
		if _tib_1(map, tile_id):
			return true
	else:
		if _tib_2(tile_id):
			return true
	#if tile_id in [GLOBALS.TILES.WALL, GLOBALS.TILES.INVALID]:
	#	return true
	
	#for entity in get_entities_at_map(map):
	#	if entity.is_blocking():
	#		return true
	if _tib_3(map):
		return true
	return false

func _tib_1(map, tile_id):
	if not cache_blocking_by_map.has(map):
		cache_blocking_by_map[map] = tile_id == GLOBALS.TILES.WALL || tile_id == GLOBALS.TILES.INVALID
	return cache_blocking_by_map[map]

func _tib_2(tile_id):
	return tile_id == GLOBALS.TILES.WALL || tile_id == GLOBALS.TILES.INVALID

func _tib_3(map):
	for entity in get_entities_at_map(map):
		if entity.is_blocking():
			return true
	return false

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

func get_mapcell_at_map(map : Vector2) -> MapCell:
	var cell_entities	= get_entities_at_map(map)
	var cell_tile_id	= get_cellv(map)
	var cell_world_pos	= get_center_of_cell_by_map(map)
	return MapCell.new(cell_entities, cell_tile_id, cell_world_pos, map)

func filter_entities_in_map_range(original : Array, map_one : Vector2, map_two : Vector2) -> Array:
	var filtered = []
	var top_right = Vector2(min(map_one.x, map_two.x), min(map_one.y, map_two.y))
	var bottom_left = Vector2(max(map_one.x, map_two.x), max(map_one.y, map_two.y))
	for entity in original:
		var map_entity = world_to_map(entity.position)
		if (map_entity.x >= top_right.x and
			map_entity.y >= top_right.y and
			map_entity.x <= bottom_left.x and
			map_entity.y <= bottom_left.y):
			filtered.push_back(entity)
	return filtered
func filter_entities_in_tile_distance(original : Array, map : Vector2, distance : int) -> Array:
	var filtered = []
	for entity in original:
		var map_entity = world_to_map(entity.position)
		var distance_vector = map_entity - map
		var tile_distance = abs(distance_vector.x) + abs(distance_vector.y)
		if tile_distance <= distance:
			filtered.push_back(entity)
	return filtered

func get_neighbour_entities_of_map(map : Vector2, distance : int, distance_type : int, include_center : bool = false) -> Array:
	var neighbours = []
	assert(distance_type in GLOBALS.DISTANCES.values(), "Unknown neighbourhood type given: %s" % distance_type)
	match distance_type:
		GLOBALS.DISTANCES.MANHATTAN:
			neighbours = filter_entities_in_tile_distance(entities, map, distance)
		GLOBALS.DISTANCES.CHEBYSHEV:
			neighbours = filter_entities_in_map_range(entities, map + (Vector2.ONE * distance), map - (Vector2.ONE * distance))
	if not include_center:
		for center_neighbour in filter_entities_at_map(neighbours, map):
			neighbours.erase(center_neighbour)
	return neighbours

func center_entities() -> void:
	for entity in entities:
		if not entity is Entity:
			continue
		(entity as Entity).position = get_center_of_cell_by_world((entity as Entity).position)

func clear_entities_by_flag() -> void:
	# until map is editable at runtime this cache does not need clearing
	#cache_tiles_by_id.clear()
	cache_entities_by_flags.clear()
func push_entity_in_cache_at_map(entity : Entity, map : Vector2) -> void:
	if not cache_entities_by_map.has(map):
		cache_entities_by_map[map] = []
	if not (cache_entities_by_map[map] as Array).has(entity):
		(cache_entities_by_map[map] as Array).push_back(entity)
func erase_entity_in_cache_at_map(entity : Entity, map : Vector2) -> void:
	if not cache_entities_by_map.has(map):
		return
	if (cache_entities_by_map[map] as Array).has(entity):
		(cache_entities_by_map[map] as Array).erase(entity)

func add_entity(entity : Entity) -> void:
	if not entities.has(entity):
		entities.append(entity)
		entity.connect("flags_updated", self, "_on_entity_flags_updated")
		entity.connect("position_updated", self, "_on_entity_position_updated")
		entity.connect("tree_exiting", self, "_on_entity_exiting_tree", [entity])
		if entity.has_method(ConfigWrapper.GETTER_METHOD):
			config.add_config_entry(entity.name, {
				ConfigWrapper.FIELDS.LABEL_TEXT: entity.name,
				ConfigWrapper.FIELDS.DEFAULT_VALUE: entity,
				ConfigWrapper.FIELDS.SIGNAL_NAME: "unused_entity_changed"
			})
		if entity is Actor:
			(entity as Actor).connect("request_neighbours", self, "_on_request_neighbours")
func add_entities(new_entities : Array) -> void:
	for entity in new_entities:
		if entity is Entity:
			add_entity(entity)

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
					var point_world = get_center_of_cell_by_world(map_to_world(point_map))
					(entity as Actor).push_target_back(point_world)
				#print_debug("Highlighted actor gets target")
	else:
		for entity in highlighted_entities:
			(entity as Entity).set_highlighted(false)
		highlighted_entities.clear()
		#print_debug("Highlights cleared")
	for entity in clicked_entities:
		(entity as Entity).set_highlighted(true)
		#print_debug("Entity highlighted")
		highlighted_entities.append(entity)

""" Pathfinding methods """

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

func _on_deep_has_over_traversal_changed(_old_value : bool, new_value : bool) -> void:
	deep_has_over_traversal = new_value
	config.set_entry_value("deep_has_over_traversal", new_value)

func _on_entity_position_updated(entity : Entity, old_position : Vector2, new_position : Vector2) -> void:
	var old_map_pos = world_to_map(old_position)
	var new_map_pos = world_to_map(new_position)
	if old_map_pos != new_map_pos:
		erase_entity_in_cache_at_map(entity, old_map_pos)
		push_entity_in_cache_at_map(entity, new_map_pos)

func _on_entity_flags_updated(entity : Entity, old_flags : int, new_flags : int) -> void:
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

func _on_entity_exiting_tree(entity : Entity) -> void:
	assert(entity in entities, "Received 'tree_exiting' signal from unknown entity: %s" % entity)
	erase_entity_in_cache_at_map(entity, world_to_map(entity.position))
	entities.erase(entity)

func _on_request_neighbours(actor : Actor, distance_type : int) -> void:
	var map_actor = world_to_map(actor.position)
	var neighbours = get_neighbour_entities_of_map(map_actor, actor.vision_range, distance_type)
	actor.set_neighbours(neighbours)







