extends PanelContainer

class_name Simulation

""" Constants """

""" Variables """

# In-Editor visible
export var simulation_speed : float = 1.0
export var paused : bool = false
export var highlighted : bool = false

var config : ConfigWrapper = ConfigWrapper.new("Simulation") setget, get_config_wrapper
var step_acc : float = 0.0

var entity_map : EntityMap

# When child-nodes are ready
onready var viewport_container	: ViewportContainer	= $ViewportContainer
onready var viewport			: Viewport			= $ViewportContainer/Viewport

""" Initialization """

func _ready() -> void:
	config.add_config_entry("simulation_speed", {
		ConfigWrapper.CONFIG_FIELDS[0]: "Speed",
		ConfigWrapper.CONFIG_FIELDS[1]: simulation_speed,
		ConfigWrapper.CONFIG_FIELDS[2]: "signal_name"
	})
	config.add_config_entry("paused", {
		ConfigWrapper.CONFIG_FIELDS[0]: "Paused",
		ConfigWrapper.CONFIG_FIELDS[1]: paused,
		ConfigWrapper.CONFIG_FIELDS[2]: "signal_name"
	})
	
	var bound = false
	for child in viewport.get_children():
		if child is EntityMap:
			entity_map = child
			bound = true
			break
	if not bound:
		print_debug("No EntityMap found under Viewport::", viewport)

""" Godot process """

func _process(_delta : float) -> void:
	var _r = step_simulation()

""" Setters / Getters """

func get_config_wrapper() -> ConfigWrapper:
	return config

""" Methods """

func step_simulation() -> float:
	var steps_taken = 0.0
	if paused:
		return steps_taken
	step_acc += simulation_speed
	if step_acc >= 1.0:
		steps_taken = floor(step_acc)
		step_acc -= steps_taken
		entity_map.step_entities(steps_taken)
	return steps_taken

func handle_lmb_click(event : InputEventMouseButton) -> void:
	if not entity_map is EntityMap:
		return
	var map_position = entity_map.world_to_map(event.position)
	entity_map.handle_position_selection(map_position)


""" Events """

func _unhandled_input(event : InputEvent) -> void:
	if not entity_map is EntityMap:
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			handle_lmb_click(event)
	if Input.is_action_just_pressed("ui_up"):
		simulation_speed *= 2
	if Input.is_action_just_pressed("ui_down"):
		simulation_speed /= 2
	if Input.is_action_just_pressed("ui_select"):
		entity_map.provide_random_targets = not entity_map.provide_random_targets
	if Input.is_action_just_pressed("ui_focus_next"):
		entity_map.deep_has_over_traversal = not entity_map.deep_has_over_traversal

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			handle_lmb_click(event)
