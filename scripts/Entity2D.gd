extends Entity

class_name Entity2D

const FULL_ROTATION : float = 360.0

var _rotation : float setget setRotation, Rotation
export var _rotation_degrees : float setget setRotationDegrees, RotationDegrees
var _anchor : Node2D setget setAnchor, Anchor

func _init() -> void:
	pass

func _ready() -> void:
	pass

func setRotation(newRotation : float) -> void:
	if  newRotation > 1.0:
		_rotation = 0.0
	elif newRotation < 0.0:
		_rotation = 0.0
	else:
		_rotation = newRotation
	if Anchor() != null:
		_anchor.rotation = Rotation()
func Rotation() -> float:
	return _rotation

func setRotationDegrees(newRotationDegrees : float) -> void:
	if newRotationDegrees > 360.0:
		_rotation_degrees = 360.0
	elif newRotationDegrees < 0.0:
		_rotation_degrees = 0.0
	else:
		_rotation_degrees = newRotationDegrees
	if Anchor() != null:
		_anchor.rotation_degrees = RotationDegrees()
func RotationDegrees() -> float:
	return _rotation_degrees

func setAnchor(newAnchor : Node2D) -> void:
	_anchor = newAnchor
	setRotationDegrees(RotationDegrees())
func Anchor() -> Node2D:
	return _anchor
