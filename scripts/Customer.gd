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
  
  config.add_config_entry("vision_range",  {
    ConfigWrapper.FIELDS.LABEL_TEXT: "Vision range (tile)",
    ConfigWrapper.FIELDS.DEFAULT_VALUE: vision_range,
    ConfigWrapper.FIELDS.SIGNAL_NAME: "vision_range_changed"
  })
  config.add_config_entry("decide_delay",  {
    ConfigWrapper.FIELDS.LABEL_TEXT: "Decide delay (step)",
    ConfigWrapper.FIELDS.DEFAULT_VALUE: decide_delay,
    ConfigWrapper.FIELDS.SIGNAL_NAME: "decide_delay_changed"
  })
  config.add_config_entry("process_delay",  {
    ConfigWrapper.FIELDS.LABEL_TEXT: "Eating delay (step)",
    ConfigWrapper.FIELDS.DEFAULT_VALUE: process_delay,
    ConfigWrapper.FIELDS.SIGNAL_NAME: "process_delay_changed"
  })
  config.connect("vision_range_changed", self, "_on_vision_range_changed")
  config.connect("decide_delay_changed", self, "_on_decide_delay_changed")
  config.connect("process_delay_changed", self, "_on_process_delay_changed")

""" Simulation step """

#[override]
func step() -> void:
  if len(targets) > 0:
    .step()
    return
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

func get_config_wrapper() -> ConfigWrapper:
  return config

func set_vision_range(new_value : int) -> void:
  vision_range = new_value
  config.set_entry_value("vision_range", new_value)

func set_decide_delay(new_value : float) -> void:
  decide_delay = new_value
  config.set_entry_value("decide_delay", new_value)

func set_process_delay(new_value : float) -> void:
  process_delay = new_value
  config.set_entry_value("process_delay", new_value)

""" Methods """

func enter_scene() -> void:
  var origin_mapcell      : MapCell
  var neighbour_mapcell   : MapCell
  
  request_neighbours(used_distance_type, vision_range)
  if len(neighbours.keys()) == 0:
    return
  assert(neighbours.has(Vector2.ZERO), "Non empty neighbours missing (0,0) key: %s" % neighbours)
  origin_mapcell = neighbours[Vector2.ZERO]
  for rel_v in neighbours:
    neighbour_mapcell = neighbours[rel_v]
    if is_in_vision(neighbour_mapcell, origin_mapcell, neighbours):
      if not like_memory(neighbour_mapcell):
        update_memory(neighbour_mapcell)
  next_life_state()

func search_table() -> void:
  next_life_state()

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
    if in_table_memory:
      _table_memory.push_back(map_v)
    else:
      _table_memory.erase(map_v)
  if in_portal_memory != mapcell.get_entity() is Portal:
    if in_portal_memory:
      _portal_memory.push_back(map_v)
    else:
      _portal_memory.erase(map_v)
  .update_memory(mapcell)

""" Events """

func _on_vision_range_changed(_old_value : int, new_value : int) -> void:
  set_vision_range(new_value)

func _on_decide_delay_changed(_old_value : float, new_value : float) -> void:
  set_decide_delay(new_value)

func _on_process_delay_changed(_old_value : float, new_value : float) -> void:
  set_process_delay(new_value)





