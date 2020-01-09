extends Position2D

class_name Entity

""" Constants """

#const FULL_ROTATION : float = 360.0

""" Initialization """

func _init() -> void:
	set_name('Entity')

func _ready() -> void:
	pass

""" Setters / Getters """

func set_name(new_name : String) -> void:
	name = new_name
func get_name() -> String:
	return name

"""
func set_rotation_relative(new_rotation_relative : float) -> void:
	set_rotation_degrees(new_rotation_relative * FULL_ROTATION)
func get_rotation_relative() -> float:
	return get_rotation_degrees() / FULL_ROTATION

func set_rotation_degrees(new_rotation_degrees : float) -> void:
	.set_rotation_degrees(fmod(new_rotation_degrees, FULL_ROTATION))
func get_rotation_degrees() -> float:
	return .get_rotation_degrees()
"""