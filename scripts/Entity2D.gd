extends Entity

class_name Entity2D

export var __rotation : float setget setRotation, getRotation
export var __rotation_degrees : float setget , getRotationDegrees
var anchor : Node2D setget setAnchor, getAnchor

func _init() -> void:
	pass

func _ready() -> void:
	pass

func setRotation(newRotation : float) -> void:
	if  newRotation > 1.0:
		__rotation = 0.0
	elif newRotation < 0.0:
		__rotation = 0.0
	else:
		__rotation = newRotation
	if getAnchor() != null:
		anchor.rotation_degrees = getRotationDegrees()
func getRotation() -> float:
	return __rotation
func getRotationDegrees() -> float:
	return getRotation() * 360

func setAnchor(newAnchor : Node2D) -> void:
	anchor = newAnchor
	setRotation(getRotation())
func getAnchor() -> Node2D:
	return anchor
