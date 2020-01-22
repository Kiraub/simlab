extends PanelContainer

class_name Simulation

""" Constants """

""" Variables """

export var simulation_speed : float = 1.0
export var highlighted : bool = false setget set_highlighted, is_highlighted

export var use_physics_process : bool = true

var step_count : float = 0.0
var viewport_container : ViewportContainer
var entity_map : EntityMap

""" Initialization """

func _ready() -> void:
	if bind_viewport_container(self):
		viewport_container.connect("gui_input", self, "_gui_input", [])
		print_debug("ViewportContainer bound to simulation.")
	else:
		print_debug("ViewportContainer not found underneath simulation.")
		get_tree().quit()
	if bind_entity_map(self):
		print_debug("EntityMap bound to simulation.")
	else:
		print_debug("EntityMap not found underneath simulation.")
		get_tree().quit()
	toggle_processing()

""" Godot process """

func _process(delta):
	step_count += simulation_speed
	while step_count >= 1.0:
		step_count -= 1.0
		entity_map.step_entities(delta)

func _physics_process(delta):
	step_count += simulation_speed
	while step_count >= 1.0:
		step_count -= 1.0
		entity_map.step_entities(delta)

""" Setters / Getters """

func set_highlighted(new_highlighted : bool) -> void:
	if new_highlighted:
		pass
func is_highlighted()-> bool:
	return highlighted

""" Methods """

func toggle_processing() -> void:
	if use_physics_process:
		set_process(false)
		set_physics_process(true)
	else:
		set_process(true)
		set_physics_process(false)

func bind_entity_map(from : Node) -> bool:
	for child in from.get_children():
		if child is EntityMap:
			entity_map = child
			return true
		elif bind_entity_map(child):
			return true
	return false

func bind_viewport_container(from : Node) -> bool:
	for child in from.get_children():
		if child is ViewportContainer:
			viewport_container = child
			return true
		elif bind_entity_map(child):
			return true
	return false

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			handle_lmb_click(event)
	if Input.is_action_just_pressed("ui_up"):
		simulation_speed *= 2
	if Input.is_action_just_pressed("ui_down"):
		simulation_speed /= 2
	if Input.is_action_just_pressed("ui_accept"):
		use_physics_process = not use_physics_process
		toggle_processing()
	if Input.is_action_just_pressed("ui_select"):
		entity_map.provide_random_targets = not entity_map.provide_random_targets
	if Input.is_action_just_pressed("ui_focus_next"):
		entity_map.deep_has_over_traversal = not entity_map.deep_has_over_traversal

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			handle_lmb_click(event)

func handle_lmb_click(event : InputEventMouseButton) -> void:
	var map_position = entity_map.world_to_map(event.position)
	entity_map.handle_position_selection(map_position)