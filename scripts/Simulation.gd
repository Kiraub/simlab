extends Control

class_name Simulation

signal configuration_opened
signal simulation_stepped

""" Constants """

""" Variables """

var title         : String  = "Simulation"  setget set_title
var paused        : bool    = true          setget set_paused
var partial_steps : bool    = false         setget set_partial_steps
var highlighted   : bool    = false         #setget set_highlighted
var step_delay    : float   = 1_000.0       setget set_step_delay
var step_size     : float   = 1.0           setget set_step_size
var _delay_acc    : float   = 0.0
var _step_acc     : float   = 0.0

var config        : ConfigWrapper           setget , get_config_wrapper
var entity_map    : EntityMap
var viewport      : Viewport
var titleLabel    : Label

""" Initialization """

#[override]
func _ready() -> void:
  var bound : bool

  viewport    = get_node_or_null("VSplitContainer/ViewportContainer/Viewport")
  assert(viewport != null, "No Viewport bound in Simulation: %s" % self)
  titleLabel  = get_node_or_null("VSplitContainer/HSplitContainer/Title")
  assert(titleLabel != null, "No TitleLabel bound in Simulation: %s" % self)
  titleLabel.text = title
  
  bound = false
  for child in viewport.get_children():
    if child is EntityMap:
      entity_map = child
      bound = true
      break
  assert(bound, "No EntityMap found under Simulation->Viewport: %s->%s" % [self,viewport])
  
  config = ConfigWrapper.new("Simulation")
  config.add_config_entry("title", {
    ConfigWrapper.FIELDS.LABEL_TEXT: "Title",
    ConfigWrapper.FIELDS.DEFAULT_VALUE: title,
    ConfigWrapper.FIELDS.SIGNAL_NAME: "title_changed"
  })
  config.add_config_entry("partial_steps", {
    ConfigWrapper.FIELDS.LABEL_TEXT: "Partial steps",
    ConfigWrapper.FIELDS.DEFAULT_VALUE: partial_steps,
    ConfigWrapper.FIELDS.SIGNAL_NAME: "partial_steps_changed"
  })
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
    ConfigWrapper.FIELDS.LABEL_TEXT: "Entity Map",
    ConfigWrapper.FIELDS.DEFAULT_VALUE: entity_map,
    ConfigWrapper.FIELDS.SIGNAL_NAME: "entity_map_changed"
  })
  config.connect("title_changed", self, "_on_title_changed")
  config.connect("partial_steps_changed", self, "_on_partial_steps_changed")
  config.connect("step_delay_changed", self, "_on_step_delay_changed")
  config.connect("step_size_changed", self, "_on_step_size_changed")
  config.connect("entity_map_changed", self, "_on_entity_map_changed")

""" Simulation step """

func step_by(amount : float = 1.0) -> void:
  var steps_taken = 0.0
  _step_acc += amount
  if partial_steps:
    steps_taken = _step_acc
    _step_acc = 0.0
  elif _step_acc >= 1.0:
    steps_taken = floor(_step_acc)
    _step_acc -= steps_taken
  if steps_taken > 0.0:
    entity_map.step_by(steps_taken)
    emit_signal("simulation_stepped", steps_taken)

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

func set_title(new_title : String) -> void:
  title = new_title
  titleLabel.text = title

func set_paused(new_value : bool) -> void:
  paused = new_value

func set_partial_steps(new_value : bool) -> void:
  partial_steps = new_value
  config.set_entry_value("partial_steps", partial_steps)

func set_step_delay(new_value : float) -> void:
  step_delay = new_value
  config.set_entry_value("step_delay", step_delay)

func set_step_size(new_value : float) -> void:
  step_size = new_value
  config.set_entry_value("step_size", step_size)

func get_config_wrapper() -> ConfigWrapper:
  return config

""" Methods """

""" Events """

func _on_title_changed(_old_value : String, new_value : String) -> void:
  set_title(new_value)

func _on_partial_steps_changed(_old_value : bool, new_value : bool) -> void:
  set_partial_steps(new_value)

func _on_step_delay_changed(_old_value : float, new_value : float) -> void:
  set_step_delay(new_value)

func _on_step_size_changed(_old_value : float, new_value : float) -> void:
  set_step_size(new_value)

func _on_entity_map_changed() -> void:
  pass

func _on_ConfigBtn_pressed() -> void:
  emit_signal("configuration_opened", config)

func _on_PlayPauseBtn_pressed(play : bool) -> void:
  set_paused(!play)

func _on_StepBtn_pressed(amount : float = step_size):
  if paused:
    step_by(amount)

func _on_DeleteBtn_pressed():
  self.queue_free()
