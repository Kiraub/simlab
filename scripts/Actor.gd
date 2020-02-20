"""
  An Actor is an Entity that can perform certain actions during a simulation step.
"""

extends Entity

class_name Actor

signal movement_started
signal movement_ended
signal request_neighbours

""" Constants """

const DEFAULT_SPEED   : float = 1.0

""" Variables """

var vision_range        : int   = 2
var speed               : float       setget set_speed, get_speed

var targets             : Array       setget set_targets, get_targets
var neighbours          : Dictionary  setget set_neighbours, get_neighbours
var life_state          : int         setget set_life_state, get_life_state
var used_distance_type  : int   = GLOBALS.DISTANCE_TYPES.MANHATTAN

var _action_time_accu   : float = 0.0
var _map_memory         :       = {}
var _traversed_mapv     :       = []

""" Initialization """

#[override]
func _init(i_name : String = 'Actor').(GLOBALS.Z_INDICIES.ACTIVE, i_name) -> void:
  speed   = DEFAULT_SPEED
  targets = []

""" Simulation step """

func step() -> void:
  if len(targets) > 0:
    var travel_distance : = get_speed()
    move_towards_target(travel_distance)

""" Static Methods """

static func get_expansions_by_distance_type(distance_type : int) -> Array:
  var expansions  : Array
  match distance_type:
    GLOBALS.DISTANCE_TYPES.MANHATTAN:
      expansions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
    GLOBALS.DISTANCE_TYPES.CHEBYSHEV:
      expansions = [
        Vector2.UP+Vector2.LEFT, Vector2.UP, Vector2.UP+Vector2.RIGHT, Vector2.RIGHT,
        Vector2.DOWN+Vector2.RIGHT, Vector2.DOWN, Vector2.DOWN+Vector2.LEFT, Vector2.LEFT
      ]
  return expansions

""" Setters / Getters """

func set_speed(new_speed : float) -> void:
  speed = new_speed
func get_speed() -> float:
  return speed

func set_targets(new_targets : Array) -> void:
  for target in new_targets:
    if not target is Vector2:
      print_debug("trying to set non Vector2 target")
  targets = new_targets.duplicate(true)
func get_targets() -> Array:
  return targets.duplicate(true)

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

func get_next_target() -> Vector2:
  if len(targets) > 0:
    return targets.front()
  return position

func get_final_target() -> Vector2:
  if len(targets) > 0:
    return targets.back()
  return position

func push_target_front(additional_target : Vector2) -> void:
  targets.push_front(additional_target)

func push_targets_front(additional_targets : Array) -> void:
  for target in additional_targets:
    if target is Vector2:
      push_target_front(target)
    else:
      print_debug("trying to add non Vector2 target")

func push_target_back(additional_target : Vector2) -> void:
  targets.push_back(additional_target)

func push_targets_back(additional_targets : Array) -> void:
  for target in additional_targets:
    if target is Vector2:
      push_target_back(target)
    else:
      print_debug("trying to add non Vector2 target")

func remove_target(index : int) -> void:
  if len(targets) > index:
    targets.remove(index)

func move_towards_target(travel_distance : float) -> void:
  if len(targets) == 0:
    return
  var next_target = targets.front()
  var direction_to_next : Vector2 = (next_target - position).normalized()
  var distance_to_next : float = (next_target - position).length()
  if travel_distance < distance_to_next:
    set_position(position + direction_to_next * travel_distance)
    travel_distance = 0
  else:
    travel_distance -= distance_to_next
    set_position(next_target)
    remove_target(0)
    move_towards_target(travel_distance)

func next_life_state() -> void:
  set_life_state(life_state + 1)
  _action_time_accu = 0

func is_in_vision(target : MapCell, from : MapCell, mapcells_by_rel : Dictionary) -> bool:
  var delta_v             : Vector2 = from.get_relative_v() - target.get_relative_v()
  var horizontal_v        : Vector2 = Vector2.RIGHT * sign(delta_v.x) + target.get_relative_v()
  var vertical_v          : Vector2 = Vector2.DOWN * sign(delta_v.y) + target.get_relative_v()
  
  if from.get_relative_v() == horizontal_v or from.get_relative_v() == vertical_v:
    return true
  if ( horizontal_v != target.get_relative_v()
    and mapcells_by_rel.has(horizontal_v)
    and not mapcells_by_rel[horizontal_v].get_tile_id() in GLOBALS.BLOCKING_TILE_IDS
    and is_in_vision(mapcells_by_rel[horizontal_v], from, mapcells_by_rel)
    ):
    return true
  if ( vertical_v != target.get_relative_v()
    and mapcells_by_rel.has(vertical_v)
    and not mapcells_by_rel[vertical_v].get_tile_id() in GLOBALS.BLOCKING_TILE_IDS
    and is_in_vision(mapcells_by_rel[vertical_v], from, mapcells_by_rel)
    ):
    return true
  return false

func get_path_from_memory(target : MapCell, from : MapCell) -> Array:
  return []

func like_memory(mapcell : MapCell) -> bool:
  var memory_cell : MapCell
  
  if not _map_memory.has(mapcell.get_absolute_v()):
    return false
  memory_cell = _map_memory[mapcell.get_absolute_v()]
  if memory_cell.get_tile_id() == mapcell.get_tile_id():
    return false
  if memory_cell.get_entity() != mapcell.get_entity():
    return false
  return true

func update_memory(mapcell : MapCell) -> void:
  _map_memory[mapcell.get_absolute_v()] = mapcell

func request_neighbours(distance_type : int, distance : int = 1) -> void:
  emit_signal("request_neighbours", self, distance_type, distance)

""" Events """






