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
var process_speed	: float		= 1.0			setget set_process_speed
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
		ConfigWrapper.CONFIG_FIELDS[0]: "Title",
		ConfigWrapper.CONFIG_FIELDS[1]: title,
		ConfigWrapper.CONFIG_FIELDS[2]: "title_changed"
	})
	config.add_config_entry("partial_steps", {
		ConfigWrapper.CONFIG_FIELDS[0]: "Partial steps",
		ConfigWrapper.CONFIG_FIELDS[1]: partial_steps,
		ConfigWrapper.CONFIG_FIELDS[2]: "partial_steps_changed"
	})
	config.add_config_entry("random_targets" , {
		ConfigWrapper.CONFIG_FIELDS[0]: "Random targets",
		ConfigWrapper.CONFIG_FIELDS[1]: random_targets,
		ConfigWrapper.CONFIG_FIELDS[2]: "random_targets_changed"
	})
	config.add_config_entry("process_speed", {
		ConfigWrapper.CONFIG_FIELDS[0]: "Process Speed",
		ConfigWrapper.CONFIG_FIELDS[1]: process_speed,
		ConfigWrapper.CONFIG_FIELDS[2]: "process_speed_changed"
	})
	config.add_config_entry("entity_map",  {
		ConfigWrapper.CONFIG_FIELDS[0]: "Entity Map",
		ConfigWrapper.CONFIG_FIELDS[1]: entity_map,
		ConfigWrapper.CONFIG_FIELDS[2]: "entity_map_changed"
	})
	config.connect("title_changed", self, "_on_title_changed")
	config.connect("partial_steps_changed", self, "_on_partial_steps_changed")
	config.connect("random_targets_changed", self, "_on_random_targets_changed")
	config.connect("process_speed_changed", self, "_on_process_speed_changed")
	config.connect("entity_map_changed", self, "_on_entity_map_changed")
	

""" Godot process """

func _process(_delta : float) -> void:
	if paused:
		return
	step_by(process_speed)

""" Setters / Getters """

func set_title(new_title : String) -> void:
	title = new_title
	titleLabel.text = title

func set_paused(new_value : bool) -> void:
	paused = new_value
	config.set_entry_value("paused", paused)
	entity_map.clear_caches()

func set_partial_steps(new_value : bool) -> void:
	partial_steps = new_value
	config.set_entry_value("partial_steps", partial_steps)

func set_random_targets(new_value : bool) -> void:
	random_targets = new_value
	config.set_entry_value("random_targets", random_targets)
	entity_map.provide_random_targets = random_targets

func set_process_speed(new_value : float) -> void:
	process_speed = new_value
	config.set_entry_value("process_speed", process_speed)

func get_config_wrapper() -> ConfigWrapper:
	return config

""" Methods """

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

func handle_lmb_click(event : InputEventMouseButton) -> void:
	if not entity_map is EntityMap:
		return
	var map_position = entity_map.world_to_map(event.position)
	entity_map.handle_position_selection(map_position)

func double_process_speed() -> void:
	set_process_speed(process_speed * 2)

func half_process_speed() -> void:
	set_process_speed(process_speed / 2)

""" Events """

func _unhandled_input(event : InputEvent) -> void:
	# Events for Simulation
	if Input.is_action_just_pressed("ui_up"):
		double_process_speed()
	if Input.is_action_just_pressed("ui_down"):
		half_process_speed()
	# Events for EntityMap
	if not entity_map is EntityMap:
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			handle_lmb_click(event)
	if Input.is_action_just_pressed("ui_focus_next"):
		entity_map.deep_has_over_traversal = not entity_map.deep_has_over_traversal

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

func _on_process_speed_changed(_old_value : float, new_value : float) -> void:
	set_process_speed(new_value)

func _on_entity_map_changed() -> void:
	pass

func _on_ConfigBtn_pressed() -> void:
	emit_signal("configuration_opened", config)

func _on_PlayPauseBtn_pressed(play : bool) -> void:
	set_paused(!play)

func _on_StepBtn_pressed():
	if paused:
		step_by()

func _on_DeleteBtn_pressed():
	self.queue_free()
