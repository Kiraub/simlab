extends Entity2D

class_name Actor2D

enum B_Types {
	IDLE
	WAITER
	CUSTOMER
	CHEF
}
enum B_MovementDirections {
	NONE	= 0
	UP		= 1
	DOWN	= 2
	LEFT	= 4
	RIGHT	= 8
}
enum B_Orientations {
	NONE		= 0
	UP			= 1
	DOWN		= 2
	LEFT		= 4
	UPLEFT		= 5
	DOWNLEFT	= 6
	RIGHT		= 8
	UPRIGHT		= 9
	DOWNRIGHT	= 10
	DEFAULT		= 15
}
enum B_Behaviours {
	MANUAL_CONTROL	= 1
	RESET_ROTATION	= 2
}
export(B_Behaviours, FLAGS) var Behaviour

var _type : int setget setType, Type
var _orientation : int setget setOrientation, Orientation
var _movement_direction : int setget setMovementDirection, MovementDirection

func _init() -> void:
	setOrientation(B_Orientations.DEFAULT)
	Behaviour |= B_Behaviours.MANUAL_CONTROL

func _ready() -> void:
	pass

func _process(delta : float) -> void:
	update_flags()
	observe_world(delta)
	action(delta)

func _physics_process(delta : float) -> void:
	update_movement()
	physics_observe_world(delta)
	physics_action(delta)

func setType(type : int) -> void:
	match type:
		B_Types.IDLE, B_Types.WAITER, B_Types.CHEF, B_Types.CUSTOMER:
			_type = type
		_:
			_type = B_Types.IDLE
func Type() -> int:
	return _type

func setOrientation(orientation : int) -> void:
	_orientation = orientation
	if Orientation() == B_Orientations.NONE:
		if Behaviour & B_Behaviours.RESET_ROTATION:
			setOrientation(B_Orientations.DEFAULT)
		else:
			return
	setRotationDegrees(map_orientation_rotation_degrees(Orientation()))
func Orientation() -> int:
	return _orientation

func setMovementDirection(movementDirection : int) -> void:
	_movement_direction = movementDirection
func MovementDirection() -> int:
	return _movement_direction

func map_orientation_rotation_degrees(orientation : int) -> float:
	match orientation:
		B_Orientations.NONE, B_Orientations.UP:
			return 360 * .0
		B_Orientations.UPRIGHT:
			return 360 * .125
		B_Orientations.RIGHT:
			return 360 * .25
		B_Orientations.DOWNRIGHT:
			return 360 * .375
		B_Orientations.DOWN:
			return 360 * .5
		B_Orientations.DOWNLEFT:
			return 360 * .625
		B_Orientations.LEFT:
			return 360 * .75
		B_Orientations.UPLEFT:
			return 360 * .875
		B_Orientations.DEFAULT, _:
			return 360 * .5

func update_movement() -> void:
	var movementDirection = B_MovementDirections.NONE
	if Behaviour & B_Behaviours.MANUAL_CONTROL == 0:
		setMovementDirection(movementDirection)
		return
	if Input.is_action_pressed('ui_down'):
		movementDirection |= B_MovementDirections.DOWN
	if Input.is_action_pressed('ui_up'):
		movementDirection |= B_MovementDirections.UP
	if Input.is_action_pressed('ui_left'):
		movementDirection |= B_MovementDirections.LEFT
	if Input.is_action_pressed('ui_right'):
		movementDirection |= B_MovementDirections.RIGHT
	# filter contradicting directions
	#if newDirection & B_MovementDirections.RIGHT && newDirection & B_MovementDirections.LEFT:
	#	newDirection &= ~B_MovementDirections.RIGHT & ~B_MovementDirections.LEFT
	#if newDirection & B_MovementDirections.UP && newDirection & B_MovementDirections.DOWN:
	#	newDirection &= ~B_MovementDirections.UP & ~B_MovementDirections.DOWN
	#setOrientation(newDirection)
	setMovementDirection(movementDirection)

func update_flags() -> void:
	var bit = 1
	var flag = 0
	while flag <= 9:
		if Input.is_action_just_pressed('flag_' + str(flag)):
			Behaviour ^= bit
		flag += 1
		bit *= 2

func observe_world(_delta : float) -> void:
	pass
func action(_delta: float) -> void:
	pass
func physics_observe_world(_delta : float) -> void:
	pass
func physics_action(_delta: float) -> void:
	pass
