extends PanelContainer

class_name Simulation

""" Constants """

""" Variables """

export var simulation_speed : float = 1.0
export var highlighted : bool = false setget set_highlighted, is_highlighted
var step_count : float = 0.0
var entity_map : EntityMap

""" Initialization """

func _ready() -> void:
	if bind_entity_map(self):
		print_debug("EntityMap bound to simulation.")
	else:
		print_debug("EntityMap not found underneath simulation.")

""" Godot process """

func _physics_process(delta):
	step_count += simulation_speed
	while step_count >= 1.0:
		step_count -= 1.0
		entity_map.step_entities(delta)

""" Setters / Getters """

func set_highlighted(new_highlighted : bool) -> void:
	if new_highlighted:
		

""" Methods """

func bind_entity_map(from : Node) -> bool:
	for child in from.get_children():
		if child is EntityMap:
			entity_map = child
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

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			print_debug(self, " has received a gui lmb click")
			handle_lmb_click(event)

func handle_lmb_click(event : InputEventMouseButton) -> void:
	var map_position = entity_map.center_to_cell(event.position)
	entity_map.handle_position_selection(map_position)