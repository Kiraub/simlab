extends Position2D

class_name Entity

""" Constants """

const FULL_ROTATION : float = 360.0

""" Initialization """

func _init() -> void:
	name = 'Entity'

func _ready() -> void:
	pass

""" Setters / Getters """

func setRotationRelative(rotationRelative : float) -> void:
	set_rotation_degrees(rotationRelative * FULL_ROTATION)
func getRotationRelative() -> float:
	return get_rotation_degrees() / FULL_ROTATION

func nset_rotation_degrees(new_rotation_degrees : float) -> void:
	rotation_degrees = fmod(new_rotation_degrees, FULL_ROTATION)
func nget_rotation_degrees() -> float:
	return .get_rotation_degrees()
