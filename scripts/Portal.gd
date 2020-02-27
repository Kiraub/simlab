extends Actor

class_name Portal, "res://Assets/sprites/portal.png"

""" Godot signals """

signal entity_spawned

""" Variables """

var spawn_delay : int = 20 setget set_spawn_delay
var accumulate_spawns : bool = false setget set_accumulate_spawns
var spawn_batch_size : int = 1 setget set_spawn_batch_size
var spawned_vision_range : int = DEFAULT_VISION_RANGE setget set_spawned_vision_range, get_spawned_vision_range

var _rng : RandomNumberGenerator
var _config : ConfigWrapper
var _spawn_scene : PackedScene = GLOBALS.PACKED_SCENE_CUSTOMER
var _to_spawn : int = 0

""" Initialization """

#[override]
func _init(i_name : String = 'Entrance/Exit').(i_name) -> void:
  _config = ConfigWrapper.new(name)
  _config.add_config_entry("modulate", {
    ConfigWrapper.FIELDS.LABEL_TEXT     : "Color hue",
    ConfigWrapper.FIELDS.DEFAULT_VALUE  : modulate,
    ConfigWrapper.FIELDS.SIGNAL_NAME    : "modulate_changed"
  })
  _config.add_config_entry("accumulate_spawns", {
    ConfigWrapper.FIELDS.LABEL_TEXT     : "Accumulate spawns",
    ConfigWrapper.FIELDS.DEFAULT_VALUE  : accumulate_spawns,
    ConfigWrapper.FIELDS.SIGNAL_NAME    : "accumulate_spawns_changed"
  })
  _config.add_config_entry("spawn_delay", {
    ConfigWrapper.FIELDS.LABEL_TEXT     : "Spawn delay",
    ConfigWrapper.FIELDS.DEFAULT_VALUE  : spawn_delay,
    ConfigWrapper.FIELDS.SIGNAL_NAME    : "spawn_delay_changed"
  })
  _config.add_config_entry("spawn_batch_size", {
    ConfigWrapper.FIELDS.LABEL_TEXT     : "Spawn batch size",
    ConfigWrapper.FIELDS.DEFAULT_VALUE  : spawn_batch_size,
    ConfigWrapper.FIELDS.SIGNAL_NAME    : "spawn_batch_size_changed"
   })
  _config.add_config_entry("spawned_vision_range", {
    ConfigWrapper.FIELDS.LABEL_TEXT     : "Customer's vision range",
    ConfigWrapper.FIELDS.DEFAULT_VALUE  : spawned_vision_range,
    ConfigWrapper.FIELDS.SIGNAL_NAME    : "spawned_vision_range_changed"
  })
  _config.connect("modulate_changed", self, "_on_modulate_changed")
  _config.connect("accumulate_spawns_changed", self, "_on_accumulate_spawns_changed")
  _config.connect("spawn_delay_changed", self, "_on_spawn_delay_changed")
  _config.connect("spawn_batch_size_changed", self, "_on_spawn_batch_size_changed")
  _config.connect("spawned_vision_range_changed", self, "_on_spawned_vision_range_changed")

  _rng = RandomNumberGenerator.new()

#[override]
func _ready() -> void:
  _config.set_entry_value("modulate", modulate)
  _config.set_wrapped_class_name(name)

  _rng.set_seed(hash("%s-%s" % [name, OS.get_time()]))
  _rng.randomize()

""" Simulation step """

#[override]
func observe_neighbours() -> void:
  if _action_time_accu < spawn_delay:
    return
  _action_time_accu = 0
  _to_spawn += spawn_batch_size

#[override]
func perform_action() -> void:
  var mapcell : MapCell
  for rel_v in neighbours.keys():
    if _to_spawn == 0:
      return
    mapcell = neighbours[rel_v]
    if not (mapcell.has_entity() or mapcell.get_tile_id() in GLOBALS.BLOCKING_TILE_IDS):
      _action_time_accu = 0
      emit_signal("entity_spawned", self, _spawn_scene, MapCell.new(mapcell.get_tile_id(), mapcell.get_absolute_v(), mapcell.get_world_v()))
      _to_spawn -= 1
  if not accumulate_spawns:
    _to_spawn = 0

""" Setters / Getters """

func get_config_wrapper() -> ConfigWrapper:
  return _config

func set_accumulate_spawns(new_value : bool) -> void:
  accumulate_spawns = new_value
  _config.set_entry_value("accumulate_spawns", new_value)

func set_spawn_delay(new_value : int) -> void:
  spawn_delay = new_value
  _config.set_entry_value("spawn_delay", new_value)

func set_spawn_batch_size(new_value : int) -> void:
  spawn_batch_size = new_value
  _config.set_entry_value("spawn_batch_size", new_value)

func set_spawned_vision_range(new_value : int) -> void:
  spawned_vision_range = new_value
  _config.set_entry_value("spawned_vision_range", new_value)

func get_spawned_vision_range() -> int:
  return spawned_vision_range

""" Methods """

func normal_dist_spawned_decide_delay() -> int:
  var decide_delay : int = 5
  # base for this normal distribution is the center
  var decide_delay_base : float = float(GLOBALS.NORMAL_DIST_DECIDE_DELAY_MAX - GLOBALS.NORMAL_DIST_DECIDE_DELAY_MIN) / 2.0 + GLOBALS.NORMAL_DIST_DECIDE_DELAY_MIN
  # Box Muller method to generate values from normal distribution
  # see https://en.wikipedia.org/wiki/Normal_distribution#Generating_values_from_normal_distribution for reference
  # log() is same as mathematical "ln" by default
  var uniform_U : float = _rng.randf()
  var uniform_V : float = _rng.randf()
  var variation : float = sqrt(-2*log(uniform_U))*cos(2*PI*uniform_V) * GLOBALS.NORMAL_DIST_VARIATION_FACTOR
  decide_delay = int(round(min(GLOBALS.NORMAL_DIST_DECIDE_DELAY_MAX, max(GLOBALS.NORMAL_DIST_DECIDE_DELAY_MIN, decide_delay_base + variation))))
  #print_debug("%s's normal dist:\n\tbase: %.2f\n\tuniforms: %.2f, %.2f\n\tvariation: %.2f\n\tfinal: %d" % [name, decide_delay_base, uniform_U, uniform_V, variation, decide_delay])
  return decide_delay

func exponential_dist_spawned_angry_delay() -> int:
  var angry_delay : int = 20
  # base for this exponential distribution is the higher value
  var angry_delay_base : float = float(GLOBALS.EXPO_DIST_ANGRY_DELAY_MAX)
  # inverse transform sampling to generate values from exponential distribution
  # see https://en.wikipedia.org/wiki/Exponential_distribution#Generating_exponential_variates for reference
  var uniform_U : float = _rng.randf()
  var variation : float = -log(uniform_U) / (1.0 / float(GLOBALS.EXPO_DIST_EXPECTED_VARIATION))
  angry_delay = int(round(min(GLOBALS.EXPO_DIST_ANGRY_DELAY_MAX, max(GLOBALS.EXPO_DIST_ANGRY_DELAY_MIN, angry_delay_base - variation))))
  #print_debug("%s's exponential dist:\n\tbase: %.2f\n\tuniform: %.2f\n\tvariation: %.2f\n\tfinal: %d" % [name, angry_delay_base, uniform_U, variation, angry_delay])

  return angry_delay

""" Events """

func _on_modulate_changed(_old_value : Color, new_value : Color) -> void:
  set_modulate(new_value)

func _on_accumulate_spawns_changed(_old_value : bool, new_value : bool) -> void:
  set_accumulate_spawns(new_value)

func _on_spawn_delay_changed(_old_value : int, new_value : int) -> void:
  set_spawn_delay(new_value)

func _on_spawn_batch_size_changed(_old_value : int, new_value : int) -> void:
  set_spawn_batch_size(new_value)

func _on_spawned_vision_range_changed(_old_value : int, new_value : int) -> void:
  set_spawned_vision_range(new_value)
