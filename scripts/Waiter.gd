extends Actor

class_name Waiter, "res://Assets/sprites/waiter.png"

""" Constants """

""" Variables """

var config : ConfigWrapper = ConfigWrapper.new("Waiter") setget, get_config_wrapper

""" Initialization """

func _init(i_name : String = 'Waiter').(i_name):
	pass

""" Setters / Getters """

func get_config_wrapper() -> ConfigWrapper:
	return config













