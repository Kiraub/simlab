extends TileMap

class_name EntityMap

""" Constants """


""" Variables """

var config    : ConfigWrapper setget , get_config_wrapper
var entities  : = []
var mapcells  : = {}

""" Initialization """

#[override]
func _init():
  self.name = "EntityMap"
  z_index   = GLOBALS.Z_INDICIES.BACKGROUND
  config    = ConfigWrapper.new("EntityMap")

#[override]
func _ready():
  for cell_v in get_used_cells():
    mapcells[cell_v] = MapCell.new(get_cellv(cell_v), cell_v)
  
  add_entities(collect_child_entities(self))
  center_entities_in_cells()

""" Static methods """

static func collect_child_entities(node : Node) -> Array:
  var array     : = []
  var subtrees  : = []
  
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
  var actors  : = []
  var actor   : Actor
  
  for entity in entities:
    if not entity is Actor:
      continue
    actor = (entity as Actor)
    actors.append(actor)
  
  for actor in actors:
    actor.step_by(amount)

""" Setters / Getters """

func get_config_wrapper() -> ConfigWrapper:
  return config

""" Methods """

func get_neighbourhood_by_map(center_map : Vector2, distance : int, distance_type : int, include_center : bool = false) -> Dictionary:
  var neighbourhood : = {}
  var tile_distance : int
  var map_relative  : Vector2
  
  assert(distance_type in GLOBALS.DISTANCE_TYPES.values(), "Unknown distance type given: %s" % distance_type)
  
  match distance_type:
    GLOBALS.DISTANCE_TYPES.MANHATTAN:
      tile_distance = int(floor(abs(map_relative.x) + abs(map_relative.y)))
    GLOBALS.DISTANCE_TYPES.CHEBYSHEV:
      tile_distance = int(floor(min(abs(map_relative.x), abs(map_relative.y))))
  return neighbourhood

func center_entities_in_cells() -> void:
  var map_v     : Vector2
  var origin_v  : Vector2
  var center_v  : Vector2
  
  for entity in entities:
    if not entity is Entity:
      continue
    map_v     = world_to_map((entity as Entity).position)
    origin_v  = map_to_world(map_v)
    center_v  = origin_v + (cell_size * 0.5)
    (entity as Entity).set_position(center_v)

func add_entity(entity : Entity) -> void:
  var map_v   : Vector2
  var mapcell : MapCell
  
  assert(not entities.has(entity), "Trying to add duplicate Entity reference: %s" % entity)
  map_v = world_to_map(entity.position)
  assert(mapcells.has(map_v), "Trying to add Entity at unknown cell: %s" % entity)
  mapcell = mapcells[map_v]
  assert(not mapcell.has_entity(), "Trying to add Entity at cell that already holds one: %s" % entity)
  mapcells[map_v] = MapCell.new(mapcell.get_tile_id(), mapcell.get_absolute_v(), entity)
  
  entities.append(entity)
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
    assert(entity is Entity, "Trying to add non-Entity object to EntityMap: %s" % entity)
    add_entity(entity)

""" Events """

func _on_entity_position_updated(entity : Entity, old_world_v : Vector2, new_world_v : Vector2) -> void:
  var old_mapcell : MapCell
  var new_mapcell : MapCell
  var old_map_v   : Vector2= world_to_map(old_world_v)
  var new_map_v   : Vector2= world_to_map(new_world_v)
  
  if old_map_v != new_map_v:
    assert(mapcells.has(old_map_v), "Entity changed position from illegal old cell: %s" % old_map_v)
    assert(mapcells.has(new_map_v), "Entity changed position from illegal new cell: %s" % new_map_v)
    old_mapcell = mapcells[old_map_v]
    new_mapcell = mapcells[new_map_v]
    assert(old_mapcell.get_entity() == entity, "Entity changed position from cell that did not contain it: %s" % old_mapcell)
    assert(not new_mapcell.has_entity(), "Entity changed position to cell that already contains an Entity: %s" % new_mapcell)
    mapcells[old_map_v] = MapCell.new(old_mapcell.get_tile_id(), old_mapcell.get_absolute_v())
    mapcells[new_map_v] = MapCell.new(new_mapcell.get_tile_id(), new_mapcell.get_absolute_v(), entity)

func _on_entity_spawned(spawn_scene : PackedScene, initial_world_v : Vector2) -> void:
  var entity : Entity
  
  assert(spawn_scene != null, "Trying to spawn entity with null scene!")
  entity = spawn_scene.instance()
  assert(entity is Entity, "Spawned non-Entity scene in _on_entity_spawned!")
  (entity as Entity).set_position(initial_world_v)
  add_child(entity, true)
  entity.owner = self
  add_entity(entity)

func _on_entity_exiting_tree(entity : Entity) -> void:
  var map_v : Vector2
  
  assert(entity in entities, "Received 'tree_exiting' signal from unknown entity: %s" % entity)
  map_v = world_to_map(entity.position)
  assert(mapcells.has(map_v), "Entity exiting tree from illegal cell: %s" % map_v)
  mapcells[map_v] = MapCell.new(get_cellv(map_v), map_v)
  entities.erase(entity)

func _on_request_neighbours(actor : Actor, distance_type : int, distance : int) -> void:
  var map_actor   : Vector2
  var neighbours  : Dictionary
  
  assert(actor in entities, "Received 'request_neighbours' signal from unknown actor: %s" % actor)
  map_actor = world_to_map(actor.position)
  neighbours = get_neighbourhood_by_map(map_actor, distance, distance_type)
  actor.set_neighbours(neighbours)






