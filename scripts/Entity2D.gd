extends Entity

class_name Entity2D

const FULL_ROTATION : float = 360.0
export var _rotation_degrees : float setget setRotationDegrees, RotationDegrees

var _anchor : Node2D setget setAnchor, Anchor

func _init() -> void:
	pass

func _ready() -> void:
	pass

func setRotationRelative(rotationRelative : float) -> void:
	setRotationDegrees(rotationRelative * FULL_ROTATION)

func setRotationDegrees(rotationDegrees : float) -> void:
	_rotation_degrees = fmod(rotationDegrees, FULL_ROTATION)
	if Anchor() != null:
		_anchor.rotation_degrees = RotationDegrees()
func RotationDegrees() -> float:
	return _rotation_degrees

func setAnchor(anchor : Node2D) -> void:
	_anchor = anchor
	setRotationDegrees(RotationDegrees())
func Anchor() -> Node2D:
	return _anchor
