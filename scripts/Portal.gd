extends Actor

class_name Portal, "res://Assets/sprites/portal.png"

signal entity_spawned

""" Constants """

""" Variables """

export(PackedScene) var spawn_scene : PackedScene
export var spawn_delay : int setget set_spawn_delay

var config : ConfigWrapper

""" Initialization """

#[override]
func _init(i_name : String = 'Portal').(i_name) -> void:
  config = ConfigWrapper.new(name)
  config.add_config_entry("spawn_delay", {
    ConfigWrapper.FIELDS.LABEL_TEXT     : "Spawn delay",
    ConfigWrapper.FIELDS.DEFAULT_VALUE  : spawn_delay,
    ConfigWrapper.FIELDS.SIGNAL_NAME    : "spawn_delay_changed"
  })
  config.connect("spawn_delay_changed", self, "_on_spawn_delay_changed")

""" Simulation step """

#[override]
func step() -> void:
  _action_time_accu += 1
  if _action_time_accu >= spawn_delay:
    if spawn_on_free_neighbour():
      _action_time_accu = 0.0

""" Setters / Getters """

func get_config_wrapper() -> ConfigWrapper:
  return config

func set_spawn_delay(new_value : int) -> void:
  spawn_delay = new_value
  config.set_entry_value("spawn_delay", new_value)

""" Methods """

func spawn_on_free_neighbour() -> bool:
  var mapcell             : MapCell
  
  if len(neighbours.keys()) == 0:
    return false
  for map_v in neighbours.keys():
    mapcell = neighbours[map_v]
    if not (mapcell.has_entity() or mapcell.get_tile_id() in GLOBALS.BLOCKING_TILE_IDS):
      emit_signal("entity_spawned", spawn_scene, mapcell)
      return true
  return false

""" Events """

func _on_spawn_delay_changed(_old_value : int, new_value : int) -> void:
  set_spawn_delay(new_value)






