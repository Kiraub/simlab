extends Control

class_name Simulation

signal configuration_opened
signal simulation_stepped

""" Constants """

""" Variables """

var title			: String	= "Simulation"	setget set_title
var paused			: bool		= true			setget set_paused
var partial_steps	: bool		= false			setget set_partial_steps
var random_targets	: bool		= false			setget set_random_targets
var highlighted		: bool		= false			#setget set_highlighted
var step_delay		: float		= 1_000.0		setget set_step_delay
var step_size		: float		= 1.0			setget set_step_size
var _delay_acc		: float		= 0.0
var _step_acc		: float		= 0.0

var config			: ConfigWrapper				setget , get_config_wrapper
var entity_map		: EntityMap

# When child-nodes are ready
onready var viewport	: Viewport	= $VSplitContainer/ViewportContainer/Viewport
onready var titleLabel	: Label		= $VSplitContainer/HSplitContainer/Title

""" Initialization """

func _ready() -> void:
	titleLabel.text = title
	
	var bound = false
	for child in viewport.get_children():
		if child is EntityMap:
			entity_map = child
			bound = true
			break
	assert(bound, "No EntityMap found under Viewport::%s" % viewport)
	
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
	config.add_config_entry("random_targets" , {
		ConfigWrapper.FIELDS.LABEL_TEXT: "Random targets",
		ConfigWrapper.FIELDS.DEFAULT_VALUE: random_targets,
		ConfigWrapper.FIELDS.SIGNAL_NAME: "random_targets_changed"
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
	config.connect("random_targets_changed", self, "_on_random_targets_changed")
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
	config.set_entry_value("paused", paused)

func set_partial_steps(new_value : bool) -> void:
	partial_steps = new_value
	config.set_entry_value("partial_steps", partial_steps)

func set_random_targets(new_value : bool) -> void:
	random_targets = new_value
	config.set_entry_value("random_targets", random_targets)
	entity_map.provide_random_targets = random_targets

func set_step_delay(new_value : float) -> void:
	step_delay = new_value
	config.set_entry_value("step_delay", step_delay)

func set_step_size(new_value : float) -> void:
	step_size = new_value
	config.set_entry_value("step_size", step_size)

func get_config_wrapper() -> ConfigWrapper:
	return config

""" Methods """

func handle_lmb_click(event : InputEventMouseButton) -> void:
	if not entity_map is EntityMap:
		return
	var map_position = entity_map.world_to_map(event.position)
	entity_map.handle_position_selection(map_position)
	get_tree().set_input_as_handled()

""" Events """

func _unhandled_input(event : InputEvent) -> void:
	# Events for EntityMap
	if not entity_map is EntityMap:
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			handle_lmb_click(event)

func _gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			handle_lmb_click(event)

func _on_title_changed(_old_value : String, new_value : String) -> void:
	set_title(new_value)

func _on_partial_steps_changed(_old_value : bool, new_value : bool) -> void:
	set_partial_steps(new_value)

func _on_random_targets_changed(_old_value : bool, new_value : bool) -> void:
	set_random_targets(new_value)

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
