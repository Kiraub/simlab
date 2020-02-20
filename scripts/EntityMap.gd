extends TileMap

class_name EntityMap

""" Constants """


""" Variables """

var config          : ConfigWrapper setget , get_config_wrapper
var entities        : = []
var mapcells        : = {}

var _spawned_parent : Node

""" Initialization """

#[override]
func _init():
  self.name = "EntityMap"
  z_index   = GLOBALS.Z_INDICIES.BACKGROUND
  config    = ConfigWrapper.new("EntityMap")
  _spawned_parent = Node.new()
  _spawned_parent.name = "Spawned entities"

#[override]
func _ready():
  add_child(_spawned_parent)
  _spawned_parent.owner = self
  
  for cell_v in get_used_cells():
    mapcells[cell_v] = MapCell.new(get_cellv(cell_v), cell_v, center_worldv_in_cell(map_to_world(cell_v)))
  
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

func step_by(amount : int) -> void:
  var actors  : = []
  var actor   : Actor
  
  for entity in entities:
    if not entity is Actor:
      continue
    actor = (entity as Actor)
    actors.append(actor)
  
  for __ in range(0, amount):
    for actor in actors:
      actor.step()

""" Setters / Getters """

func get_config_wrapper() -> ConfigWrapper:
  return config

""" Methods """

func get_neighbourhood_by_map(center_map : Vector2, distance : int, distance_type : int) -> Dictionary:
  var neighbourhood : = {}
  var map_absolute  : Vector2
  var map_relative  : Vector2
  var mapcell       : MapCell
  var x_range       : Array   = range(center_map.x - distance, center_map.x + distance + 1)
  var y_range       : Array   = range(center_map.y - distance, center_map.y + distance + 1)
  
  assert(distance_type in GLOBALS.DISTANCE_TYPES.values(), "Unknown distance type given: %s" % distance_type)
  for y_coord in y_range:
    for x_coord in x_range:
      map_absolute = Vector2(x_coord, y_coord)
      if not mapcells.has(map_absolute):
        continue
      mapcell = mapcells[map_absolute]
      if mapcell.distance_to_map(center_map, distance_type) > distance:
        continue
      map_relative = map_absolute - center_map
      neighbourhood[map_relative] = MapCell.new(mapcell.get_tile_id(), mapcell.get_absolute_v(), mapcell.get_center_v(), mapcell.get_entity())
      (neighbourhood[map_relative] as MapCell).make_relative_to(center_map)
  
  return neighbourhood

func center_worldv_in_cell(world_v : Vector2) -> Vector2:
  var map_v     : Vector2
  var origin_v  : Vector2
  var center_v  : Vector2
  
  map_v     = world_to_map(world_v)
  origin_v  = map_to_world(map_v)
  center_v  = origin_v + (cell_size * 0.5)
  return center_v

func center_entities_in_cells() -> void:
  var center_v  : Vector2
  
  for entity in entities:
    if not entity is Entity:
      continue
    center_v = center_worldv_in_cell((entity as Entity).position)
    (entity as Entity).set_position(center_v)

func add_entity(entity : Entity) -> void:
  var map_v   : Vector2
  var mapcell : MapCell
  
  assert(not entities.has(entity), "Trying to add duplicate Entity reference: %s" % entity)
  map_v = world_to_map(entity.position)
  assert(mapcells.has(map_v), "Trying to add Entity at unknown cell: %s" % entity)
  mapcell = mapcells[map_v]
  assert(not mapcell.has_entity(), "Trying to add Entity at cell that already holds one: %s" % entity)
  mapcells[map_v] = MapCell.new(mapcell.get_tile_id(), mapcell.get_absolute_v(), mapcell.get_center_v(), entity)
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
  var old_map_v   : Vector2 = world_to_map(old_world_v)
  var new_map_v   : Vector2 = world_to_map(new_world_v)
  
  if old_map_v != new_map_v:
    assert(mapcells.has(old_map_v), "Entity changed position from unknown old cell: %s" % old_map_v)
    assert(mapcells.has(new_map_v), "Entity changed position from unknown new cell: %s" % new_map_v)
    old_mapcell = mapcells[old_map_v]
    new_mapcell = mapcells[new_map_v]
    assert(old_mapcell.get_entity() == entity, "Entity changed position from cell that did not contain it: %s" % old_mapcell)
    assert(not new_mapcell.has_entity(), "Entity changed position to cell that already contains an Entity: %s" % new_mapcell)
    mapcells[old_map_v] = MapCell.new(old_mapcell.get_tile_id(), old_mapcell.get_absolute_v(), old_mapcell.get_center_v())
    mapcells[new_map_v] = MapCell.new(new_mapcell.get_tile_id(), new_mapcell.get_absolute_v(), new_mapcell.get_center_v(), entity)

func _on_entity_spawned(spawn_scene : PackedScene, mapcell : MapCell) -> void:
  var entity  : Entity
  var world_v : Vector2
  
  assert(spawn_scene != null, "Trying to spawn entity with null scene!")
  entity = spawn_scene.instance()
  assert(entity is Entity, "Spawned non-Entity scene in _on_entity_spawned!")
  world_v = center_worldv_in_cell(map_to_world(mapcell.get_absolute_v()))
  (entity as Entity).set_position(world_v)
  entity.set_name("Spawned %s" % entity.name)
  _spawned_parent.add_child(entity, true)
  entity.owner = _spawned_parent
  add_entity(entity)

func _on_entity_exiting_tree(entity : Entity) -> void:
  var map_v   : Vector2
  var mapcell : MapCell
  
  assert(entity in entities, "Received 'tree_exiting' signal from unknown entity: %s" % entity)
  map_v = world_to_map(entity.position)
  assert(mapcells.has(map_v), "Entity exiting tree from illegal cell: %s" % map_v)
  mapcell = mapcells[map_v]
  mapcells[map_v] = MapCell.new(mapcell.get_tile_id(), mapcell.get_absolute_v(), mapcell.get_center_v())
  entities.erase(entity)

func _on_request_neighbours(actor : Actor, distance_type : int, distance : int) -> void:
  var map_actor   : Vector2
  var neighbours  : Dictionary
  
  assert(actor in entities, "Received 'request_neighbours' signal from unknown actor: %s" % actor)
  map_actor = world_to_map(actor.position)
  neighbours = get_neighbourhood_by_map(map_actor, distance, distance_type)
  actor.set_neighbours(neighbours)






