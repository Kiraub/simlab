extends Actor2D

class_name Waiter, "res://Assets/sprites/waiter.png"

# percent of a tile in a tick
const WALKING_SPEED : float = 100.0
#const GRID_SIZE : int = 32
# tick length in seconds
#const TICK_LENGTH : float = .5

var _movement : Vector2

func _init():
	setDisplayName("Waiter")
	setType(B_Types.WAITER)

func _ready():
	setAnchor($KinematicBody2D)

func observe_world(_delta : float) -> void:
	reset_movement()
	var movement_direction = MovementDirection()
	if movement_direction & B_MovementDirections.UP:
		_movement += Vector2(0, -1)
	if movement_direction & B_MovementDirections.DOWN:
		_movement += Vector2(0, 1)
	if movement_direction & B_MovementDirections.LEFT:
		_movement += Vector2(-1, 0)
	if movement_direction & B_MovementDirections.RIGHT:
		_movement += Vector2(1, 0)

func action(_delta : float) -> void:
	setOrientation(MovementDirection())

func physics_observe_world(_delta : float) -> void:
	pass

func physics_action(_delta: float) -> void:
	$KinematicBody2D.move_and_slide(_movement * WALKING_SPEED)
	#$KinematicBody2D.move_and_collide(movement)

func reset_movement() -> void:
	_movement = Vector2(0,0)