extends Entity

class_name Actor

""" Constants """

const DEFAULT_SPEED	: float	= 32.0

""" Variables """

export var speed : float setget set_speed, get_speed

var targets : PoolVector2Array setget set_targets

""" Initialization """

func _init(i_name : String = 'Actor').(GLOBALS.Z_INDICIES.ACTIVE, i_name) -> void:
	set_speed(DEFAULT_SPEED)

""" Setters / Getters """

func set_speed(new_speed : float) -> void:
	speed = new_speed
func get_speed() -> float:
	return speed

func set_targets(new_targets : PoolVector2Array) -> void:
	targets = new_targets
func add_targets(additional_targets : PoolVector2Array) -> void:
	targets.append_array(additional_targets)










