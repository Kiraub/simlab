extends Actor

class_name Customer, "res://Assets/sprites/customer.png"

""" Godot signals """

signal got_served
signal became_angry_waiting_after(life_time)

""" Variables """

var angry_delay    : int setget set_angry_delay
var decide_delay   : int setget set_decide_delay
var process_delay  : int setget set_process_delay

var _portal_memory        : Array
var _table_memory         : Array

""" Initialization """

#[override]
func _init(i_name : String = 'Customer').(i_name) -> void:
  life_state = GLOBALS.CUSTOMER_LIFE_STATES.ENTER_SCENE
  _portal_memory = []
  _table_memory = []

""" Simulation step """

#[override]
func observe_neighbours() -> void:
  match life_state:
    GLOBALS.CUSTOMER_LIFE_STATES.ENTER_SCENE:
      _enter_scene()
    GLOBALS.CUSTOMER_LIFE_STATES.SEARCH_TABLE:
      _search_table()
    GLOBALS.CUSTOMER_LIFE_STATES.DECIDE_ORDER:
      _decide_order()
    GLOBALS.CUSTOMER_LIFE_STATES.MAKE_ORDER:
      _make_order()
    GLOBALS.CUSTOMER_LIFE_STATES.PROCESS_ORDER:
      _process_order()
    GLOBALS.CUSTOMER_LIFE_STATES.SEARCH_EXIT:
      _search_exit()
    GLOBALS.CUSTOMER_LIFE_STATES.EXIT_SCENE:
      _exit_scene()

#[overrid]
func perform_action() -> void:
  if life_state < GLOBALS.CUSTOMER_LIFE_STATES.PROCESS_ORDER and _action_time_accu > angry_delay:
    emit_signal("became_angry_waiting_after", _life_time_accu)
    set_modulate(GLOBALS.ANGRY_COLOR)
    life_state = GLOBALS.CUSTOMER_LIFE_STATES.SEARCH_EXIT
    return
  .perform_action()

""" Setters / Getters """

func set_angry_delay(new_value : int) -> void:
  angry_delay = new_value

func set_decide_delay(new_value : int) -> void:
  decide_delay = new_value

func set_process_delay(new_value : int) -> void:
  process_delay = new_value

""" Methods """

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

func _enter_scene() -> void:
  set_target(current_mapcell().get_absolute_v())
  next_life_state()

func _search_table() -> void:
  var next_to_table_v : Vector2

  for table_v in _table_memory:
    if is_in_range(_map_memory[table_v], 1, false):
      next_life_state()
      return
    for direction in GLOBALS.DIRECTIONS_BY_DISTANCE_TYPE[distance_type]:
      next_to_table_v = table_v + direction
      if not _map_memory.has(next_to_table_v):
        continue
      if is_in_vision(_map_memory[next_to_table_v]):
        set_target(next_to_table_v)
        return
  .observe_neighbours()

func _decide_order() -> void:
  _action_time_accu += 1
  if _action_time_accu >= decide_delay:
    next_life_state()

func _make_order() -> void:
  for rel_v in neighbours:
    if  ( neighbours[rel_v].has_entity()
          and neighbours[rel_v].get_entity() is Waiter
          and is_in_range(neighbours[rel_v], 1, false)
        ):
      emit_signal("got_served")
      set_modulate(GLOBALS.HAPPY_COLOR)
      next_life_state()

func _process_order() -> void:
  _action_time_accu += 1
  if _action_time_accu >= process_delay:
    next_life_state()

func _search_exit() -> void:
  var next_to_portal_v : Vector2

  for portal_v in _portal_memory:
    if is_in_range(_map_memory[portal_v], 1, false):
      next_life_state()
      return
    for direction in GLOBALS.DIRECTIONS_BY_DISTANCE_TYPE[distance_type]:
      next_to_portal_v = portal_v + direction
      if not _map_memory.has(next_to_portal_v):
        continue
      if is_in_vision(_map_memory[next_to_portal_v]):
        set_target(next_to_portal_v)
        return
  .observe_neighbours()

func _exit_scene() -> void:
  life_state = GLOBALS.QUEUE_FREE_LIFE_STATE
