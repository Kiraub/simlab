extends Entity

class_name Actor

""" Constants """

const DEFAULT_SPEED	: float	= 100.0
const DEFAULT_TYPE	: int	= 0

enum B_Types {
	IDLE		= 0
	WAITER		= 1
	CUSTOMER	= 2
	CHEF		= 3
}

""" Variables """

var type : int setget set_type, get_type
export var speed : float setget set_speed, get_speed

var targets : PoolVector2Array setget set_targets

""" Initialization """

func _init() -> void:
	set_name('Actor')
	set_speed(DEFAULT_SPEED)
	set_type(DEFAULT_TYPE)
	z_index = GLOBALS.Z_INDICIES.ACTIVE

""" Setters / Getters """

func set_type(new_type : int) -> void:
	match new_type:
		B_Types.IDLE, B_Types.WAITER, B_Types.CHEF, B_Types.CUSTOMER:
			type = new_type
		_:
			type = DEFAULT_TYPE
func get_type() -> int:
	return type

func set_speed(new_speed : float) -> void:
	speed = new_speed
func get_speed() -> float:
	return speed

func set_targets(new_targets : PoolVector2Array) -> void:
	targets = new_targets
func add_targets(additional_targets : PoolVector2Array) -> void:
	targets.append_array(additional_targets)