extends Entity

class_name Actor

enum B_Types {
	IDLE
	WAITER
	CUSTOMER
	CHEF
}
enum B_DistinctDirections {
	NONE	= 0
	UP		= 1
	RIGHT	= 2
	DOWN	= 4
	LEFT	= 8
}
enum B_Behaviours {
	MANUAL_CONTROL	= 1
	RESET_DIRECTION	= 2
}
export(B_Behaviours, FLAGS) var behaviour

var type : int setget set_type, get_type
var movement_direction : int setget set_movement_direction, get_movement_direction

func _init() -> void:
	behaviour |= B_Behaviours.MANUAL_CONTROL

func _ready() -> void:
	pass

func set_type(new_type : int) -> void:
	match new_type:
		B_Types.IDLE, B_Types.WAITER, B_Types.CHEF, B_Types.CUSTOMER:
			type = new_type
		_:
			type = B_Types.IDLE
func get_type() -> int:
	return type

func set_movement_direction(new_movement_direction : int) -> void:
	movement_direction = new_movement_direction
func get_movement_direction() -> int:
	return movement_direction

func detect_manual_movement() -> void:
	var new_movement_direction = B_DistinctDirections.NONE
	if behaviour & B_Behaviours.MANUAL_CONTROL == 0:
		set_movement_direction(new_movement_direction)
		return
	if Input.is_action_pressed('ui_up'):
		new_movement_direction |= B_DistinctDirections.UP
	if Input.is_action_pressed('ui_right'):
		new_movement_direction |= B_DistinctDirections.RIGHT
	if Input.is_action_pressed('ui_down'):
		new_movement_direction |= B_DistinctDirections.DOWN
	if Input.is_action_pressed('ui_left'):
		new_movement_direction |= B_DistinctDirections.LEFT
	set_movement_direction(new_movement_direction)

func detect_movement() -> void:
	pass

func update_flags() -> void:
	var bit = 1
	var flag = 0
	while flag <= 9:
		if Input.is_action_just_pressed('flag_' + str(flag)):
			behaviour ^= bit # xor/ swap
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
	if behaviour & B_Behaviours.MANUAL_CONTROL :
		detect_manual_movement()
	else:
		detect_movement()
	physics_observe_world(delta)
	physics_action(delta)