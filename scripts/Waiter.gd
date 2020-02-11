extends Actor

class_name Waiter, "res://Assets/sprites/waiter.png"

""" Constants """

""" Variables """

""" Initialization """

func _init(i_name : String = 'Waiter').(i_name) -> void:
	pass

func _ready() -> void:
	config.add_config_entry("speed", {
		ConfigWrapper.FIELDS.LABEL_TEXT: "Walk speed",
		ConfigWrapper.FIELDS.DEFAULT_VALUE: speed,
		ConfigWrapper.FIELDS.SIGNAL_NAME: "speed_changed"
	})
	config.connect("speed_changed", self, "_on_speed_changed")

""" Setters / Getters """

func get_config_wrapper() -> ConfigWrapper:
	return config

""" Events """

func _on_speed_changed(_old_value : float, new_value : float) -> void:
	set_speed(new_value)











