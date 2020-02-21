extends Actor

class_name Customer, "res://Assets/sprites/customer.png"

""" Constants """

const E_LifeState = {
  ENTER_SCENE   = 0,
  SEARCH_TABLE  = 1,
  DECIDE_ORDER  = 2,
  MAKE_ORDER    = 3,
  WAIT_ORDER    = 4,
  PROCESS_ORDER = 5,
  PAY_ORDER     = 6,
  SEARCH_EXIT   = 7,
  LEAVE_SCENE   = 8
}

""" Variables """

export var decide_delay   : float = 5.0
export var process_delay  : float = 2.5

var _portal_memory        : Array
var _table_memory         : Array

""" Initialization """

#[override]
func _init(i_name : String = 'Customer').(i_name) -> void:
  life_state = E_LifeState.ENTER_SCENE
  _portal_memory = []
  _table_memory = []

""" Simulation step """

#[override]
func observe_neighbours() -> void:
  match life_state:
    E_LifeState.ENTER_SCENE:
      enter_scene()
    E_LifeState.SEARCH_TABLE:
      search_table()
    E_LifeState.DECIDE_ORDER:
      decide_order()
    E_LifeState.MAKE_ORDER:
      make_order()
    E_LifeState.WAIT_ORDER:
      wait_order()
    E_LifeState.PROCESS_ORDER:
      process_order()
    E_LifeState.PAY_ORDER:
      pay_order()
    E_LifeState.SEARCH_EXIT:
      search_exit()
    E_LifeState.LEAVE_SCENE:
      leave_scene()

""" Godot process """

""" Static Methods """

""" Setters / Getters """

func set_vision_range(new_value : int) -> void:
  vision_range = new_value

func set_decide_delay(new_value : float) -> void:
  decide_delay = new_value

func set_process_delay(new_value : float) -> void:
  process_delay = new_value

""" Methods """

func enter_scene() -> void:
  print("%s entered the restaurant." % name)
  set_target(current_mapcell().get_absolute_v())
  next_life_state()

func search_table() -> void:
  var next_to_table_v : Vector2
  
  print("%s is searching for a table..." % name)
  for map_v in _table_memory:
    if is_in_range(_map_memory[map_v], 1, false):
      print("%s arrived next to table at %s!" % [name, map_v])
      next_life_state()
      return
    for direction in GLOBALS.DIRECTIONS_BY_DISTANCE_TYPE[distance_type]:
      next_to_table_v = map_v + direction
      if not _map_memory.has(next_to_table_v):
        continue
      if is_in_vision(_map_memory[next_to_table_v]):
        set_target(next_to_table_v)
        return
  .observe_neighbours()

func decide_order() -> void:
  _action_time_accu += 1
  if _action_time_accu >= decide_delay:
    next_life_state()

func make_order() -> void:
  next_life_state()

func wait_order() -> void:
  next_life_state()

func process_order() -> void:
  _action_time_accu += 1
  if _action_time_accu >= process_delay:
    next_life_state()

func pay_order() -> void:
  next_life_state()

func search_exit() -> void:
  next_life_state()

func leave_scene() -> void:
  queue_free()

#[override]
func update_memory(mapcell : MapCell) -> void:
  var map_v             : Vector2 = mapcell.get_absolute_v()
  var in_table_memory   : bool    = _table_memory.has(map_v)
  var in_portal_memory  : bool    = _portal_memory.has(map_v)
  if in_table_memory != mapcell.get_entity() is Table:
    if not in_table_memory:
      _table_memory.push_back(map_v)
    else:
      _table_memory.erase(map_v)
  if in_portal_memory != mapcell.get_entity() is Portal:
    if not in_portal_memory:
      _portal_memory.push_back(map_v)
    else:
      _portal_memory.erase(map_v)
  .update_memory(mapcell)





