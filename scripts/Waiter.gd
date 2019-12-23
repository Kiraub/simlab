extends Actor2D

# percent of a tile in a tick
const WALKING_SPEED : float = 100.0

var movement : Vector2

func _ready():
	setDisplayName("waiter")
	setType(Types.WAITER)
	setAnchor($KinematicBody2D)
	reset_movement()

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
	var k = getAnchor() as KinematicBody2D
	k.move_and_slide_with_snap(movement * WALKING_SPEED, Vector2(GRID_SIZE, GRID_SIZE))

func reset_movement() -> void:
	movement = Vector2(0,0)