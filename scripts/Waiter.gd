extends Actor

class_name Waiter#, "res://Assets/sprites/waiter.png"

# percent of a tile in a tick
const WALKING_SPEED : float = 100.0
#const GRID_SIZE : int = 32
# tick length in seconds
#const TICK_LENGTH : float = .5

# added from tutorial
var path : = PoolVector2Array() setget set_path
var travel : bool

var _movement : Vector2

func _init():
	#setDisplayName("Waiter")
	set_type(B_Types.WAITER)

func _ready():
	#setAnchor($KinematicBody2D)
	travel = false

# added from tutorial
func _process(delta : float) -> void:
	if not travel:
		return
	var move_distance : = WALKING_SPEED * delta
	move_along_path(move_distance)

func observe_world(_delta : float) -> void:
	pass

func action(_delta : float) -> void:
	pass

func physics_observe_world(_delta : float) -> void:
	pass
	var movement_direction = get_movement_direction()
	if movement_direction & B_DistinctDirections.UP:
		_movement += Vector2(0, -1)
	if movement_direction & B_DistinctDirections.DOWN:
		_movement += Vector2(0, 1)
	if movement_direction & B_DistinctDirections.LEFT:
		_movement += Vector2(-1, 0)
	if movement_direction & B_DistinctDirections.RIGHT:
		_movement += Vector2(1, 0)

func physics_action(_delta : float) -> void:
	pass
	if _movement.length() != 0:
		#setOrientation(MovementDirection())
		$KinematicBody2D.move_and_slide(_movement * WALKING_SPEED)
		reset_movement()
	else:
		pass
		#setOrientation(B_DistinctDirections.NONE)

func reset_movement() -> void:
	_movement = Vector2(0,0)

# added from tutorial
func set_path(value : PoolVector2Array) -> void:
	path = value
	if value.size() == 0:
		return
	travel = true

func move_along_path(distance : float) -> void:
	var start_point : = global_position
	for _i in range(path.size()):
		var distance_to_next : = start_point.distance_to(path[0])
		if distance <= distance_to_next and distance >= 0.0:
			global_position = start_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif distance < 0.0:
			global_position = path[0]
			travel = false
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)
















