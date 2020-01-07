extends Entity

class_name Actor

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
enum B_Behaviours {
	MANUAL_CONTROL	= 1
	RESET_ROTATION	= 2
}
export(B_Behaviours, FLAGS) var Behaviour

var type : int setget set_type, get_type
var movement_direction : int setget set_movement_direction, get_movement_direction

func _init() -> void:
	Behaviour |= B_Behaviours.MANUAL_CONTROL

func _ready() -> void:
	pass

func set_type(type : int) -> void:
	match type:
		B_Types.IDLE, B_Types.WAITER, B_Types.CHEF, B_Types.CUSTOMER:
			type = type
		_:
			type = B_Types.IDLE
func get_type() -> int:
	return type

func set_movement_direction(new_movement_direction : int) -> void:
	movement_direction = new_movement_direction
func get_movement_direction() -> int:
	return movement_direction

func update_manual_movement() -> void:
	var movementDirection = B_MovementDirections.NONE
	if Behaviour & B_Behaviours.MANUAL_CONTROL == 0:
		set_movement_direction(movementDirection)
		return
	if Input.is_action_pressed('ui_down'):
		movementDirection |= B_MovementDirections.DOWN
	if Input.is_action_pressed('ui_up'):
		movementDirection |= B_MovementDirections.UP
	if Input.is_action_pressed('ui_left'):
		movementDirection |= B_MovementDirections.LEFT
	if Input.is_action_pressed('ui_right'):
		movementDirection |= B_MovementDirections.RIGHT
	set_movement_direction(movementDirection)

func update_movement() -> void:
	pass

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

func _process(delta : float) -> void:
	update_flags()
	observe_world(delta)
	action(delta)

func physics_observe_world(_delta : float) -> void:
	pass
func physics_action(_delta: float) -> void:
	pass

func _physics_process(delta : float) -> void:
	if B_Behaviours.MANUAL_CONTROL & Behaviour:
		update_manual_movement()
	else:
		update_movement()
	physics_observe_world(delta)
	physics_action(delta)