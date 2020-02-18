extends Actor

class_name Portal, "res://Assets/sprites/portal.png"

signal entity_spawned

""" Constants """

""" Variables """

export(PackedScene) var spawn_scene : PackedScene
export var spawn_delay : float setget set_spawn_delay

""" Initialization """

#[override]
func _init(i_name : String = 'Portal').(i_name) -> void:
  config.add_config_entry("spawn_delay", {
    ConfigWrapper.FIELDS.LABEL_TEXT     : "Spawn delay",
    ConfigWrapper.FIELDS.DEFAULT_VALUE  : spawn_delay,
    ConfigWrapper.FIELDS.SIGNAL_NAME    : "spawn_delay_changed"
  })
  config.connect("spawn_delay_changed", self, "_on_spawn_delay_changed")

""" Simulation step """

#[override]
func step_by(amount : float) -> void:
  _action_time_accu += amount
  if _action_time_accu >= spawn_delay:
    if spawn_on_free_neighbour():
      _action_time_accu = 0.0

""" Setters / Getters """

func get_config_wrapper() -> ConfigWrapper:
  return config

func set_spawn_delay(new_value : float) -> void:
  spawn_delay = new_value
  config.set_entry_value("spawn_delay", new_value)

""" Methods """

func spawn_on_free_neighbour() -> bool:
  var mapcell             : MapCell
  var volatile_neighbours : Dictionary = get_neighbours_volatile()
  
  if len(volatile_neighbours) == 0:
    request_neighbours(GLOBALS.DISTANCE_TYPES.MANHATTAN)
    return false
  for map_v in volatile_neighbours.keys():
    mapcell = volatile_neighbours[map_v]
    if not (mapcell.has_entity() or GLOBALS.BLOCKING_TILE_IDS.values().has(mapcell.get_tile_id())):
      emit_signal("entity_spawned", spawn_scene, mapcell)
      return true
  return false

""" Events """

func _on_spawn_delay_changed(_old_value : float, new_value : float) -> void:
  set_spawn_delay(new_value)






