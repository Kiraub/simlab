extends Node

class_name Entity

var _display_name setget setDisplayName, DisplayName

func setDisplayName(newDisplayName : String) -> void:
	_display_name = newDisplayName
func DisplayName() -> String:
	return _display_name

func _ready() -> void:
	pass
