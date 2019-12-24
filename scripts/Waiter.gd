extends Actor2D

class_name Waiter

# percent of a tile in a tick
const WALKING_SPEED : float = 100.0
const GRID_SIZE : int = 32
# tick length in seconds
const TICK_LENGTH : float = .5

var movement : Vector2

func _init():
	setDisplayName("Waiter")
	setType(Types.WAITER)

func _ready():
	setAnchor($KinematicBody2D)

func observe_world(delta : float) -> void:
	reset_movement()
	var ori = getOrientation()
	if ori & Orientations.UP:
		movement += Vector2(0, -1)
	if ori & Orientations.DOWN:
		movement += Vector2(0, 1)
	if ori & Orientations.LEFT:
		movement += Vector2(-1, 0)
	if ori & Orientations.RIGHT:
		movement += Vector2(1, 0)

func action(delta : float) -> void:
	pass

func physics_observe_world(delta : float) -> void:
	pass

func physics_action(delta: float) -> void:
	$KinematicBody2D.move_and_slide(movement * WALKING_SPEED)

func reset_movement() -> void:
	movement = Vector2(0,0)