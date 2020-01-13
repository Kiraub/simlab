extends Node

""" Constants """

""" Variables """

""" Initialization """

# added from tutorial
onready var nav_2d : Navigation2D = $Navigation2D
onready var line_2d : Line2D = $Line2D
onready var character : Waiter = $Navigation2D/EntityMap/Actors/Waiter
onready var map : EntityMap = $Navigation2D/EntityMap

func _ready():
	map.z_index = GLOBALS.Z_INDICIES.BACKGROUND

func _unhandled_input(event : InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return
	#var target_position = event.global_position
	var target_position = map.center_to_cell(event.global_position)
	#print(target_position)
	character.position = target_position