extends Entity

class_name Actor

""" Constants """

const DEFAULT_SPEED	: float	= 32.0

""" Variables """

export var speed : float setget set_speed, get_speed
export var path_visible : bool setget set_path_visible

var targets : Array setget set_targets, get_targets

onready var path : Line2D = Line2D.new()

""" Initialization """

func _init(i_name : String = 'Actor').(GLOBALS.Z_INDICIES.ACTIVE, i_name) -> void:
	set_speed(DEFAULT_SPEED)
	targets = []

func _ready():
	set_path_visible(true)
	path.width = 5
	path.name = "Path-Visual"
	path.z_index = GLOBALS.Z_INDICIES.ACTIVE
	add_child(path)
	path.set_as_toplevel(true)

""" Setters / Getters """

func set_speed(new_speed : float) -> void:
	speed = new_speed
func get_speed() -> float:
	return speed

func set_targets(new_targets : Array) -> void:
	for target in new_targets:
		if not target is Vector2:
			print_debug("trying to set non Vector2 target")
	targets = new_targets.duplicate(true)
func get_targets() -> Array:
	return targets.duplicate(true)

func set_path_visible(new_path_visible : bool) -> void:
	path_visible = new_path_visible
	path.visible = path_visible

""" Methods """

func push_target_front(additional_target : Vector2) -> void:
	targets.push_front(additional_target)

func push_targets_front(additional_targets : Array) -> void:
	for target in additional_targets:
		if target is Vector2:
			push_target_front(target)
		else:
			print_debug("trying to add non Vector2 target")

func push_target_back(additional_target : Vector2) -> void:
	targets.push_back(additional_target)

func push_targets_back(additional_targets : Array) -> void:
	for target in additional_targets:
		if target is Vector2:
			push_target_back(target)
		else:
			print_debug("trying to add non Vector2 target")

func remove_target(index : int) -> void:
	if len(targets) > index:
		targets.remove(index)











