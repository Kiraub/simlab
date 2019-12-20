extends Node

class_name Entity

export(String) var __displayName setget setDisplayName, getDisplayName
export(Vector3) var __position setget setPosition, getPosition

func setDisplayName(newDisplayName : String) -> void:
	__displayName = newDisplayName
func getDisplayName() -> String:
	return __displayName

func setPosition(newPosition : Vector3) -> void:
	__position = newPosition
func getPosition() -> Vector3:
	return __position

func _ready() -> void:
	pass
