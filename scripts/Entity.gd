extends Position2D

class_name Entity

""" Constants """

""" Variables """

""" Initialization """

func _init() -> void:
	set_name('Entity')

func _ready() -> void:
	pass

""" Setters / Getters """

func set_name(new_name : String) -> void:
	name = new_name
func get_name() -> String:
	return name
