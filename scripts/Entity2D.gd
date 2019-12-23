extends Entity

class_name Entity2D

const GRID_SIZE : int = 32

var __position : Vector2 setget setPosition, getPosition
var __rotation : float setget setRotation, getRotation
var anchor : Node2D

func _init() -> void:
	anchor = Node2D.new()
	anchor.name = "anchor"
	.add_child(anchor, true)

func _ready() -> void:
	pass

func setPosition(newPosition : Vector2) -> void:
	__position = newPosition * GRID_SIZE + Vector2(GRID_SIZE, GRID_SIZE) * 0.5
	anchor.position = getPosition()
func getPosition() -> Vector2:
	return __position

func setRotation(newRotation : float) -> void:
	if  newRotation > 1.0:
		__rotation = 0.0
	elif newRotation < 0.0:
		__rotation = 0.0
	else:
		__rotation = newRotation
	anchor.rotation_degrees = getRotation() * 360
func getRotation() -> float:
	return __rotation

func make_relative(node : Node) -> void:
	anchor.add_child(node, true)