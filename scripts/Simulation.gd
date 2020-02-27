extends Control

class_name Simulation

signal simulation_stepped

""" Constants """

""" Variables """

var paused        : bool    = true          setget set_paused
var step_delay    : float   = 50.0          setget set_step_delay
var step_size     : int     = 1             setget set_step_size
var _delay_acc    : float   = 0.0

var statistics    : Dictionary              setget , get_statistics
var config        : ConfigWrapper           setget , get_config_wrapper
var entity_map    : EntityMap

onready var viewport      : Viewport  = $ViewportContainer/Viewport

""" Initialization """

func _init() -> void:
  statistics = {}

#[override]
func _ready() -> void:
  var bound : bool
  assert(viewport != null, "No Viewport bound in Simulation: %s" % self)

  bound = false
  for child in viewport.get_children():
    if child is EntityMap:
      entity_map = child
      bound = true
      break
  assert(bound, "No EntityMap found under Simulation->Viewport: %s->%s" % [self,viewport])

  config = ConfigWrapper.new("Simulation")
  config.add_config_entry("step_delay", {
    ConfigWrapper.FIELDS.LABEL_TEXT: "Step delay (ms)",
    ConfigWrapper.FIELDS.DEFAULT_VALUE: step_delay,
    ConfigWrapper.FIELDS.SIGNAL_NAME: "step_delay_changed"
  })
  config.add_config_entry("step_size", {
    ConfigWrapper.FIELDS.LABEL_TEXT: "Step size",
    ConfigWrapper.FIELDS.DEFAULT_VALUE: step_size,
    ConfigWrapper.FIELDS.SIGNAL_NAME: "step_size_changed"
  })
  config.add_config_entry("entity_map",  {
    ConfigWrapper.FIELDS.LABEL_TEXT: "Map",
    ConfigWrapper.FIELDS.DEFAULT_VALUE: entity_map,
    ConfigWrapper.FIELDS.SIGNAL_NAME: "entity_map_changed"
  })
  config.connect("step_delay_changed", self, "_on_step_delay_changed")
  config.connect("step_size_changed", self, "_on_step_size_changed")
  config.connect("entity_map_changed", self, "_on_entity_map_changed")

""" Simulation step """

func step_by(amount : int = 1) -> void:
  if amount > 0:
    entity_map.step_by(amount)
    emit_signal("simulation_stepped", amount)

""" Godot process """

#[override]
func _process(delta_in_seconds : float) -> void:
  if paused:
    return
  _delay_acc += delta_in_seconds * 1_000
  if _delay_acc > step_delay:
    _delay_acc = 0
    step_by(step_size)

""" Setters / Getters """

func set_paused(new_value : bool) -> void:
  paused = new_value

func set_step_delay(new_value : float) -> void:
  step_delay = new_value
  config.set_entry_value("step_delay", step_delay)

func set_step_size(new_value : int) -> void:
  step_size = new_value
  config.set_entry_value("step_size", step_size)

func get_statistics() -> Dictionary:
  return statistics

func get_config_wrapper() -> ConfigWrapper:
  return config

""" Methods """

""" Config signal handlers """

func _on_step_delay_changed(_old_value : float, new_value : float) -> void:
  set_step_delay(new_value)

func _on_step_size_changed(_old_value : int, new_value : int) -> void:
  set_step_size(new_value)

func _on_entity_map_changed() -> void:
  pass

""" GUI Events """

func _on_statistics_set(given_key : String, given_value : int) -> void:
  var key : String
  key = given_key.strip_escapes()
  statistics[key] = given_value

func _on_statistics_incremented(given_key : String) -> void:
  var key : String
  key = given_key.strip_escapes()
  if not statistics.has(key):
    statistics[key] = 0
  statistics[key] += 1

func _on_statistics_decremented(given_key : String) -> void:
  var key : String
  key = given_key.strip_escapes()
  if not statistics.has(key):
    statistics[key] = 0
  statistics[key] -= 1

func _on_PlayBtn_pressed():
  set_paused(false)

func _on_PauseBtn_pressed():
  set_paused(true)

func _on_StepBtn_pressed():
  if paused:
    step_by(step_size)

func _on_StepOneBtn_pressed():
  if paused:
    step_by(1)

func _on_ViewportController_received_mouse_click():
  set_paused(true)
