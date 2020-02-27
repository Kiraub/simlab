"""
  An Actor is an Entity that can perform certain actions during a simulation step.
"""

extends Entity

class_name Actor

""" Constants """

const DEFAULT_VISION_RANGE    : int   = 1

""" Variables """

var vision_range        : int         setget set_vision_range, get_vision_range
var distance_type       : int         setget set_distance_type, get_distance_type
var life_state          : int         setget set_life_state, get_life_state
var neighbours          : Dictionary  setget set_neighbours, get_neighbours
var target              : Vector2     setget set_target, get_target

var _life_time_accu     : int = 0
var _action_time_accu   : int = 0
var _map_memory         :       = {}
var _visited            :       = []
var _path               :       = []

""" Initialization """

#[override]
func _init(i_name : String = 'Actor').(i_name) -> void:
  set_vision_range(DEFAULT_VISION_RANGE)
  set_distance_type(GLOBALS.DISTANCE_TYPES.DEFAULT)

""" Simulation step """

func step() -> void:
  _life_time_accu += 1
  _action_time_accu += 1
  for neighbour in neighbours.values():
    if not like_memory(neighbour):
      update_memory(neighbour)
  observe_neighbours()
  perform_action()

func observe_neighbours() -> void:
  # set target to first floor cell in sight without entities in between that is not in _visited
  for rel_v in neighbours:
    var mapcell := (neighbours[rel_v] as MapCell)
    if  ( not mapcell.get_absolute_v() in _visited
          and not mapcell.get_tile_id() in GLOBALS.BLOCKING_TILE_IDS
          and not mapcell.has_entity()
          and is_in_vision(mapcell)
        ):
      set_target(mapcell.get_absolute_v())
      return
  # Backtrack to earlier
  if len(_path) == 0:
    _visited.clear()
    return
  var previous = _path.pop_back()
  set_target(previous)

func perform_action() -> void:
  var current_v       : Vector2 = current_mapcell().get_absolute_v()
  var next_mapcell    : MapCell
  var path_to_target  : Array

  if not current_v in _visited:
    _visited.push_back(current_v)
  if not target in _visited:
    if len(_path) == 0 or _path.back() != current_v:
      _path.push_back(current_v)
  # default Actor action is to try to move towards target by one cell
  assert(_map_memory.has(target), "%s has target outside of map memory: %s" % [name, target])
  path_to_target = path_to(_map_memory[target])
  if len(path_to_target) > 0:
    next_mapcell = path_to_target.front()
    if next_mapcell.get_tile_id() in GLOBALS.BLOCKING_TILE_IDS:
      _path.clear()
      _visited.clear()
      return
    if not next_mapcell.has_entity():
      set_position(next_mapcell.get_world_v())

""" Setters / Getters """

func set_vision_range(new_value : int) -> void:
  vision_range = new_value

func get_vision_range() -> int:
  return vision_range

func set_distance_type(new_value : int) -> void:
  assert(new_value in GLOBALS.DISTANCE_TYPES.values(), "Trying to set an invalid distance type: %s" % new_value)
  distance_type = new_value

func get_distance_type() -> int:
  return distance_type

func set_target(new_value : Vector2) -> void:
  target = new_value

func get_target() -> Vector2:
  return target

func set_neighbours(new_value : Dictionary) -> void:
  for neighbour in new_value.values():
    assert(neighbour is MapCell, "Trying to set non MapCell neighbour: %s" % neighbour)
  neighbours = new_value

func get_neighbours() -> Dictionary:
  return neighbours

func set_life_state(new_value : int) -> void:
  life_state = new_value

func get_life_state() -> int:
  return life_state

""" Methods """

func current_mapcell() -> MapCell:
  var current : MapCell
  assert(neighbours.has(Vector2.ZERO))
  current = neighbours[Vector2.ZERO]
  return current

func next_life_state() -> void:
  set_life_state(life_state + 1)
  _visited.clear()
  _action_time_accu = 0

func is_in_range(other : MapCell, distance : int, entities_block : bool) -> bool:
  var current             : MapCell = current_mapcell()
  var delta_v             : Vector2
  var horizontal_v        : Vector2
  var vertical_v          : Vector2

  if current.distance_to_mapcell(other, distance_type) > distance:
    return false
  delta_v       = current.get_absolute_v() - other.get_absolute_v()
  horizontal_v  = Vector2.RIGHT * sign(delta_v.x) + other.get_absolute_v()
  vertical_v    = Vector2.DOWN * sign(delta_v.y) + other.get_absolute_v()
  if current.get_absolute_v() == horizontal_v or current.get_absolute_v() == vertical_v:
    return true
  if  ( horizontal_v != other.get_absolute_v()
        and _map_memory.has(horizontal_v)
        and not _map_memory[horizontal_v].get_tile_id() in GLOBALS.BLOCKING_TILE_IDS
        and not (entities_block and _map_memory[horizontal_v].has_entity())
        and is_in_range(_map_memory[horizontal_v], distance-1, entities_block)
      ):
    return true
  if  ( vertical_v != other.get_absolute_v()
        and _map_memory.has(vertical_v)
        and not _map_memory[vertical_v].get_tile_id() in GLOBALS.BLOCKING_TILE_IDS
        and not (entities_block and _map_memory[vertical_v].has_entity())
        and is_in_range(_map_memory[vertical_v], distance-1, entities_block)
      ):
    return true
  return false

func is_in_vision(other : MapCell) -> bool:
  return is_in_range(other, vision_range, true)

func path_to(other : MapCell, checked:Array=[]) -> Array:
  var path      : Array   = []
  var choices   : Array   = []
  var current_v : Vector2 = current_mapcell().get_absolute_v()
  var other_v   : Vector2 = other.get_absolute_v()
  var next_v    : Vector2
  var next_cell : MapCell

  if not _map_memory.has(other_v):
    return path
  if other_v == current_v:
    path.push_back(other)
    return path
  for direction in GLOBALS.DIRECTIONS_BY_DISTANCE_TYPE[distance_type]:
    next_v = other_v + direction
    if not _map_memory.has(next_v):
      continue
    if next_v == current_v:
      path.push_back(other)
      return path
    next_cell = _map_memory[next_v]
    if next_cell.has_entity() or next_cell.get_tile_id() in GLOBALS.BLOCKING_TILE_IDS:
      continue
    if next_cell in checked:
      continue
    choices.push_back(next_cell)
  for choice in choices:
    checked.push_back(choice)
    path = path_to(choice, checked)
    if len(path) > 0:
      path.push_back(choice)
      return path
  return path

func like_memory(mapcell : MapCell) -> bool:
  var memory_cell : MapCell

  if not _map_memory.has(mapcell.get_absolute_v()):
    return false
  memory_cell = _map_memory[mapcell.get_absolute_v()]
  if memory_cell.get_tile_id() != mapcell.get_tile_id():
    return false
  if hash(memory_cell.get_entity()) != hash(mapcell.get_entity()):
    return false
  return true

func update_memory(mapcell : MapCell) -> void:
  _map_memory[mapcell.get_absolute_v()] = mapcell
