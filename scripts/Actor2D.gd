extends Entity2D

class_name Actor2D

enum Types {
	IDLE,
	WAITER,
	CUSTOMER,
	CHEF,
}
enum MovementDirections {
	NONE	= 0
	UP		= 1,
	DOWN	= 2,
	LEFT	= 4,
	RIGHT	= 8,
}
enum Orientations {
	DEFAULT		= 0,
	UP			= 1,
	DOWN		= 2,
	LEFT		= 4,
	UPLEFT		= 5,
	DOWNLEFT	= 6,
	RIGHT		= 8,
	UPRIGHT		= 9,
	DOWNRIGHT	= 10,
}
enum Behaviours {
	MANUAL_CONTROL	= 1,
	RESET_ROTATION	= 2,
}
export(Behaviours, FLAGS) var BehaviourFlags

var __type : int setget setType, getType
var __orientation : int setget setOrientation, getOrientation

var mapO2R : Dictionary

func _init() -> void:
	__orientation = Orientations.DEFAULT
	setRotation(0.5)

func _ready() -> void:
	mapO2R[Orientations.DEFAULT]	= .5
	mapO2R[Orientations.UP]			= .0
	mapO2R[Orientations.UPRIGHT]	= .125
	mapO2R[Orientations.RIGHT]		= .25
	mapO2R[Orientations.DOWNRIGHT]	= .375
	mapO2R[Orientations.DOWN]		= .5
	mapO2R[Orientations.DOWNLEFT]	= .625
	mapO2R[Orientations.LEFT]		= .75
	mapO2R[Orientations.UPLEFT]		= .875

func _process(delta : float) -> void:
	update_flags()
	observe_world(delta)
	action(delta)

func _physics_process(delta : float) -> void:
	update_movement()
	physics_observe_world(delta)
	physics_action(delta)

func setType(newType : int) -> void:
	match newType:
		Types.IDLE, Types.WAITER, Types.CHEF, Types.CUSTOMER:
			__type = newType
		_:
			__type = Types.IDLE
func getType() -> int:
	return __type

func setOrientation(newOrientation : int) -> void:
	__orientation = newOrientation
	if getOrientation() == Orientations.DEFAULT && not BehaviourFlags & Behaviours.RESET_ROTATION:
		return
	setRotation(mapO2R[__orientation])
func getOrientation() -> int:
	return __orientation

func update_movement() -> void:
	var newDirection = MovementDirections.NONE
	if Input.is_action_pressed("ui_down"):
		newDirection |= MovementDirections.DOWN
	if Input.is_action_pressed("ui_up"):
		newDirection |= MovementDirections.UP
	if Input.is_action_pressed("ui_left"):
		newDirection |= MovementDirections.LEFT
	if Input.is_action_pressed("ui_right"):
		newDirection |= MovementDirections.RIGHT
	# filter contradicting directions
	if newDirection & MovementDirections.RIGHT && newDirection & MovementDirections.LEFT:
		newDirection &= ~MovementDirections.RIGHT & ~MovementDirections.LEFT
	if newDirection & MovementDirections.UP && newDirection & MovementDirections.DOWN:
		newDirection &= ~MovementDirections.UP & ~MovementDirections.DOWN
	setOrientation(newDirection)

func update_flags() -> void:
	var bit = 1
	var flag = 0
	while flag <= 9:
		if Input.is_action_just_pressed("flag_" + str(flag)):
			BehaviourFlags ^= bit
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