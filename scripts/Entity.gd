extends Position2D

class_name Entity

""" Constants """

""" Variables """

export var blocking : bool = true setget set_blocking, is_blocking

""" Initialization """

func _init(entity_zindex : int, entity_name : String = 'Entity') -> void:
	set_name(entity_name)
	z_index = entity_zindex

""" Setters / Getters """

func set_name(new_name : String) -> void:
	name = new_name
func get_name() -> String:
	return name

func set_blocking(new_blocking : bool) -> void:
	blocking = new_blocking
func is_blocking() -> bool:
	return blocking == true










