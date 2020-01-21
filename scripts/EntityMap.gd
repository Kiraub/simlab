extends TileMap

class_name EntityMap

""" Constants """

enum E_Tiles {
	FLOOR	= 0
	WALL	= 1
}

""" Variables """

var entities : Array = [] setget , get_entities
var actors : Array = []
var statics : Array = []
var highlighted_entites : Array = []
var static_blocked_tiles : Array = []

""" Initialization """

#[override]
func _init():
	z_index = GLOBALS.Z_INDICIES.BACKGROUND

#[override]
func _ready():
	add_entities(collect_child_entities(self))
	add_entities(collect_wall_entities(self))
	center_entities()

""" Simulation step """

func step_entities(delta : float) -> void:
	for actor in actors:
		actor.step_time(delta)
	#get_tree().call_group(GLOBALS.GROUP_NAMES.get(GLOBALS.GROUP_FLAGS.Acting), "step_time", delta)

""" Setters / Getters """
"""
func set_entities(new_entities : Array) -> void:
	for entity in new_entities:
		if not entity is Entity:
			return
	entities = new_entities
"""
func get_entities() -> Array:
	return entities

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

static func collect_wall_entities(entitymap : EntityMap) -> Array:
	var array = []
	for map in entitymap.get_used_cells():
		var tile_index = entitymap.get_cellv(map)
		if tile_index == E_Tiles.WALL:
			var world = entitymap.map_to_world(map)
			var wall_entity = Static.new('Wall', world)
			wall_entity.set_blocking(true)
			entitymap.add_child(wall_entity)
			array.push_back(wall_entity)
	return array

static func collect_entities_flags(entitymap : EntityMap, flags : int) -> Array:
	var collection = []
	for entity in entitymap.entities:
		if (entity as Entity).EntityFlags & flags == flags:
			collection.append(entity)
	return collection

""" Methods """

func add_entity(entity : Entity) -> void:
	if not entities.has(entity):
		entities.append(entity)
		if entity is Static:
			statics.append(entity)
			if entity.is_blocking():
				var tile = world_to_map(entity.position)
				static_blocked_tiles.append(tile)
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
	print_debug(selectable_entities)
	var clicked_entities = get_entities_at(map)
	if len(clicked_entities) == 0:
		print_debug("Empty space clicked")
		for entity in highlighted_entites:
			if entity is Actor:
				var path = find_path((entity as Actor).get_final_target(), map)
				if len(path) == 0:
					print_debug("Empty or impossible path")
					continue
				(entity as Actor).push_targets_back(path)
				#(entity as Actor).push_target_back(map)
				print_debug("Highlighted actor gets target")
	else:
		for entity in highlighted_entites:
			(entity as Entity).set_highlighted(false)
		highlighted_entites.clear()
		print_debug("Highlights cleared")
	for entity in clicked_entities:
		if selectable_entities.has(entity):
			(entity as Entity).set_highlighted(true)
			highlighted_entites.append(entity)
			print_debug("Entity highlighted")

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
	var map = world_to_map(world)
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
	var found_end = false
	var expansions = [Vector2.UP * cell_size, Vector2.LEFT * cell_size, Vector2.DOWN * cell_size, Vector2.RIGHT * cell_size]
	var paths = [[map_start]]
	var blocked_tiles = []
	var traversed_tiles = [map_start]
	var DEEP_HAS_OVER_TRAVERSAL = true
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
			if DEEP_HAS_OVER_TRAVERSAL:
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


