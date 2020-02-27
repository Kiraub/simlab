extends TileMap

class_name EntityMap

signal statistics_set(key, value)
signal statistics_incremented(key)
signal statistics_decremented(key)
signal config_entries_changed

""" Constants """

const STATISTIC_KEYS = {
  TOTAL_STEP_COUNT          = "Total step count",
  TOTAL_CUSTOMERS_SPAWNED   = "Total customers entered",
  TOTAL_CUSTOMERS_SERVED    = "Total customers served",
  TOTAL_CUSTOMERS_DESPAWNED = "Total customers exited",
  TOTAL_CUSTOMERS_ANGRY     = "Total angry customers",
  CURRENT_CUSTOMER_COUNT    = "Current customer count",
  CURRENT_WAITER_COUNT      = "Current waiter count",
  CURRENT_PORTAL_COUNT      = "Current entrance/exit count",
  CURRENT_TABLE_COUNT       = "Current table count",
}
const SPAWN_BRIGHTNESS_START  : float = 0.5
const SPAWN_BRIGHTNESS_STEP   : float = 0.05
const SPAWN_BRIGHTNESS_MAX    : float = 1.0

""" Variables """

var _config          : ConfigWrapper setget , get_config_wrapper
var _entities        : = []
var _mapcells        : = {}
var _spawn_brightness : float = SPAWN_BRIGHTNESS_START

""" Initialization """

#[override]
func _init() -> void:
  self.name = "EntityMap"
  _config    = ConfigWrapper.new("Map")

#[override]
func _ready() -> void:
  for key in STATISTIC_KEYS:
    emit_signal("statistics_set", STATISTIC_KEYS[key], 0)

  for cell_v in get_used_cells():
    _mapcells[cell_v] = MapCell.new(get_cellv(cell_v), cell_v, _center_worldv_in_cell(map_to_world(cell_v)))

  for entity in collect_child_entities(self):
    _add_entity(entity)
  _center_entities_in_cells()

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
  var portals : = []
  var waiters : = []
  var map_v   : Vector2

  for entity in _entities:
    if entity is Portal:
      portals.push_front(entity)
    elif entity is Waiter:
      waiters.push_front(entity)

  for __ in range(0, amount):
    # step customers first to prevent them from moving right after getting served
    for customer in _entities:
      if customer is Customer:
        if customer.get_life_state() == GLOBALS.QUEUE_FREE_LIFE_STATE:
          customer.queue_free()
          continue
        map_v = world_to_map(customer.position)
        customer.set_neighbours(_neighbourhood_by_map(map_v, customer.get_vision_range(), customer.get_distance_type()))
        customer.step()
    # step waiters next
    for waiter in waiters:
        map_v = world_to_map(waiter.position)
        waiter.set_neighbours(_neighbourhood_by_map(map_v, waiter.get_vision_range(), waiter.get_distance_type()))
        waiter.step()
    # step portals last in case they spawn new customers
    for portal in portals:
      map_v = world_to_map(portal.position)
      portal.set_neighbours(_neighbourhood_by_map(map_v, portal.get_vision_range(), portal.get_distance_type()))
      portal.step()
    emit_signal("statistics_incremented", STATISTIC_KEYS.TOTAL_STEP_COUNT)

""" Setters / Getters """

func get_config_wrapper() -> ConfigWrapper:
  return _config

""" Methods """

func handle_click_at_world(world_v : Vector2, button_index : int) -> void:
  var map_v : Vector2 = world_to_map(world_v)
  if map_v.x < 0.0 or map_v.y < 0.0:
    return
  if button_index == BUTTON_LEFT:
    var old_tile_id : int = get_cellv(map_v)
    var new_tile_id : int = GLOBALS.TILE_UNCHANGED
    match old_tile_id:
      GLOBALS.TILE_INVALID:
        new_tile_id = GLOBALS.TILE_FLOOR
      GLOBALS.TILE_FLOOR:
        new_tile_id = GLOBALS.TILE_WALL
      GLOBALS.TILE_WALL:
        new_tile_id = GLOBALS.TILE_INVALID
    _edit_tile_at(map_v, new_tile_id)
  elif button_index == BUTTON_RIGHT:
    var old_entity : Entity = null
    var new_entity_scene : PackedScene
    if _mapcells.has(map_v):
      old_entity = _mapcells[map_v].get_entity()
    if old_entity is Portal:
      new_entity_scene = GLOBALS.PACKED_SCENE_TABLE
    elif old_entity is Table:
      new_entity_scene = GLOBALS.PACKED_SCENE_WAITER
    elif old_entity is Waiter:
      new_entity_scene = null
    elif old_entity == null:
      new_entity_scene = GLOBALS.PACKED_SCENE_PORTAL
    else:
      new_entity_scene = null
    _edit_entity_at(map_v, new_entity_scene)

func _neighbourhood_by_map(center_map : Vector2, distance : int, distance_type : int) -> Dictionary:
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
      if not _mapcells.has(map_absolute):
        continue
      mapcell = _mapcells[map_absolute]
      if mapcell.distance_to_v(center_map, distance_type) > distance:
        continue
      map_relative = map_absolute - center_map
      neighbourhood[map_relative] = MapCell.new(mapcell.get_tile_id(), mapcell.get_absolute_v(), mapcell.get_world_v(), mapcell.get_entity())
      (neighbourhood[map_relative] as MapCell).make_relative_to(center_map)

  return neighbourhood

func _center_worldv_in_cell(world_v : Vector2) -> Vector2:
  var map_v     : Vector2
  var origin_v  : Vector2
  var center_v  : Vector2

  map_v     = world_to_map(world_v)
  origin_v  = map_to_world(map_v)
  center_v  = origin_v + (cell_size * 0.5)
  return center_v

func _center_entities_in_cells() -> void:
  var center_v  : Vector2

  for entity in _entities:
    if not entity is Entity:
      continue
    center_v = _center_worldv_in_cell((entity as Entity).position)
    (entity as Entity).set_position(center_v)

func _edit_tile_at(map_v : Vector2, new_tile_id : int) -> void:
  var entity  : Entity
  var world_v : = _center_worldv_in_cell(map_to_world(map_v))

  if not new_tile_id == GLOBALS.TILE_UNCHANGED:
    set_cellv(map_v, new_tile_id)
    update_bitmask_area(map_v)
  if _mapcells.has(map_v) and _mapcells[map_v].has_entity():
    entity = _mapcells[map_v].get_entity()
  _mapcells[map_v] = MapCell.new(get_cellv(map_v), map_v, world_v, entity)

func _edit_entity_at(map_v : Vector2, new_entity_scene : PackedScene) -> void:
  var mapcell : MapCell
  var config_needs_reload : bool = false
  if not _mapcells.has(map_v):
    _mapcells[map_v] = MapCell.new(GLOBALS.TILE_INVALID, map_v, _center_worldv_in_cell(map_to_world(map_v)))
  mapcell = _mapcells[map_v]
  var old_entity : = mapcell.get_entity()
  if old_entity != null:
    if old_entity.has_method(ConfigWrapper.GETTER_METHOD):
      _config.remove_config_entry(old_entity.name)
      config_needs_reload = true
    old_entity.queue_free()
  _mapcells[map_v] = MapCell.new(mapcell.get_tile_id(), mapcell.get_absolute_v(), mapcell.get_world_v())
  var new_entity : Entity
  if new_entity_scene != null:
    new_entity = new_entity_scene.instance()
    add_child(new_entity, true)
    new_entity.owner = self
    new_entity.set_position(mapcell.get_world_v())
    _add_entity(new_entity)
    if new_entity.has_method(ConfigWrapper.GETTER_METHOD):
      config_needs_reload = true
  else:
    _mapcells[map_v] = MapCell.new(mapcell.get_tile_id(), mapcell.get_absolute_v(), mapcell.get_world_v(), null)
  if config_needs_reload:
    emit_signal("config_entries_changed")

func _add_entity(entity : Entity) -> void:
  var map_v   : Vector2
  var mapcell : MapCell

  assert(not _entities.has(entity), "Trying to add duplicate Entity reference: %s" % entity)
  map_v = world_to_map(entity.position)
  assert(_mapcells.has(map_v), "Trying to add Entity at unknown cell: %s" % entity)
  mapcell = _mapcells[map_v]
  assert(not mapcell.has_entity(), "Trying to add Entity at cell that already holds one: %s" % entity)
  _mapcells[map_v] = MapCell.new(mapcell.get_tile_id(), mapcell.get_absolute_v(), mapcell.get_world_v(), entity)
  _entities.append(entity)
  entity.connect("position_updated", self, "_on_entity_position_updated")
  entity.connect("tree_exiting", self, "_on_entity_exiting_tree", [entity])
  if entity is Portal:
    (entity as Portal).connect("entity_spawned", self, "_on_entity_spawned")
    emit_signal("statistics_incremented", STATISTIC_KEYS.CURRENT_PORTAL_COUNT)
  elif entity is Table:
    emit_signal("statistics_incremented", STATISTIC_KEYS.CURRENT_TABLE_COUNT)
  elif entity is Waiter:
    emit_signal("statistics_incremented", STATISTIC_KEYS.CURRENT_WAITER_COUNT)
  elif entity is Customer:
    emit_signal("statistics_incremented", STATISTIC_KEYS.CURRENT_CUSTOMER_COUNT)
    (entity as Customer).connect("became_angry_waiting_after", self, "_on_customer_became_angry_waiting_after")
    (entity as Customer).connect("got_served", self, "_on_customer_got_served")
  if entity.has_method(ConfigWrapper.GETTER_METHOD):
    _config.add_config_entry(entity.name, {
      ConfigWrapper.FIELDS.LABEL_TEXT: entity.name,
      ConfigWrapper.FIELDS.DEFAULT_VALUE: entity,
      ConfigWrapper.FIELDS.SIGNAL_NAME: "unused_entity_changed"
    })

""" Events """

func _on_entity_position_updated(entity : Entity, old_world_v : Vector2, new_world_v : Vector2) -> void:
  var old_mapcell : MapCell
  var new_mapcell : MapCell
  var old_map_v   : Vector2 = world_to_map(old_world_v)
  var new_map_v   : Vector2 = world_to_map(new_world_v)

  if old_map_v != new_map_v:
    assert(_mapcells.has(old_map_v), "Entity changed position from unknown old cell: %s" % old_map_v)
    assert(_mapcells.has(new_map_v), "Entity changed position from unknown new cell: %s" % new_map_v)
    old_mapcell = _mapcells[old_map_v]
    new_mapcell = _mapcells[new_map_v]
    assert(hash(old_mapcell.get_entity()) == hash(entity), "Entity changed position from cell that did not contain it: %s" % old_mapcell)
    assert(not new_mapcell.has_entity(), "Entity changed position to cell that already contains an Entity: %s" % new_mapcell)
    _mapcells[old_map_v] = MapCell.new(old_mapcell.get_tile_id(), old_mapcell.get_absolute_v(), old_mapcell.get_world_v())
    _mapcells[new_map_v] = MapCell.new(new_mapcell.get_tile_id(), new_mapcell.get_absolute_v(), new_mapcell.get_world_v(), entity)

func _on_entity_spawned(portal : Portal, spawn_scene : PackedScene, mapcell : MapCell) -> void:
  var entity  : Entity

  assert(spawn_scene != null, "Trying to spawn entity with null scene!")
  entity = spawn_scene.instance()
  assert(entity is Entity, "Spawned non-Entity scene in _on_entity_spawned!")
  (entity as Entity).set_position(mapcell.get_world_v())
  entity.set_name("Spawned %s" % entity.name)
  if entity is Actor:
    (entity as Actor).set_vision_range(portal.get_spawned_vision_range())
  if entity is Customer:
    (entity as Customer).set_decide_delay(portal.normal_dist_spawned_decide_delay())
    (entity as Customer).set_angry_delay(portal.exponential_dist_spawned_angry_delay())
    emit_signal("statistics_incremented", STATISTIC_KEYS.TOTAL_CUSTOMERS_SPAWNED)
  entity.set_modulate(Color.from_hsv(0.0, 0.0, _spawn_brightness, 1.0))
  _spawn_brightness += SPAWN_BRIGHTNESS_STEP
  if _spawn_brightness > SPAWN_BRIGHTNESS_MAX:
    _spawn_brightness = SPAWN_BRIGHTNESS_START
  add_child(entity, true)
  entity.owner = self
  _add_entity(entity)

func _on_entity_exiting_tree(entity : Entity) -> void:
  var map_v   : Vector2
  var mapcell : MapCell

  assert(entity in _entities, "Received 'tree_exiting' signal from unknown entity: %s" % entity)
  map_v = world_to_map(entity.position)
  assert(_mapcells.has(map_v), "Entity exiting tree from illegal cell: %s" % map_v)
  mapcell = _mapcells[map_v]
  if hash(mapcell.get_entity()) == hash(entity):
    _mapcells[map_v] = MapCell.new(mapcell.get_tile_id(), mapcell.get_absolute_v(), mapcell.get_world_v())
  if entity is Customer:
    emit_signal("statistics_incremented", STATISTIC_KEYS.TOTAL_CUSTOMERS_DESPAWNED)
    emit_signal("statistics_decremented", STATISTIC_KEYS.CURRENT_CUSTOMER_COUNT)
  elif entity is Waiter:
    emit_signal("statistics_decremented", STATISTIC_KEYS.CURRENT_WAITER_COUNT)
  elif entity is Portal:
    emit_signal("statistics_decremented", STATISTIC_KEYS.CURRENT_PORTAL_COUNT)
  elif entity is Table:
    emit_signal("statistics_decremented", STATISTIC_KEYS.CURRENT_TABLE_COUNT)
  _entities.erase(entity)

func _on_customer_became_angry_waiting_after(_life_time : int) -> void:
  emit_signal("statistics_incremented", STATISTIC_KEYS.TOTAL_CUSTOMERS_ANGRY)

func _on_customer_got_served() -> void:
  emit_signal("statistics_incremented", STATISTIC_KEYS.TOTAL_CUSTOMERS_SERVED)
