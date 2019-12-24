extends Node

class_name Entity

var __displayName setget setDisplayName, getDisplayName

func setDisplayName(newDisplayName : String) -> void:
	__displayName = newDisplayName
func getDisplayName() -> String:
	return __displayName

func _ready() -> void:
	pass
