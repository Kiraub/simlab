extends Node

class_name Simulation

""" Constants """

""" Variables """

export var simulation_speed : float = 1.0
var step_count : float = 0.0

""" Initialization """

onready var entity_map : EntityMap = $EntityMap

func _physics_process(delta):
	step_count += simulation_speed
	while step_count >= 1.0:
		step_count -= 1.0
		entity_map.step_entities(delta)

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			handle_lmb_click(event)
	if Input.is_action_just_pressed("ui_up"):
		simulation_speed *= 2
	if Input.is_action_just_pressed("ui_down"):
		simulation_speed /= 2

func handle_lmb_click(event : InputEventMouseButton) -> void:
	var map_position = entity_map.center_to_cell(event.global_position)
	entity_map.handle_position_selection(map_position)