extends Node

# added from tutorial
onready var nav_2d : Navigation2D = $Navigation2D
onready var line_2d : Line2D = $Line2D
onready var character : Waiter = $Waiter

func _unhandled_input(event : InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return
	#var target_position = event.global_position
	var target_position = $Navigation2D/MapExample.center_to_cell(event.global_position)
	print(target_position)
	character.position = target_position
	#var new_path : = nav_2d.get_simple_path(character.position, target_position, false)
	#line_2d.points = new_path
	#character.path = new_path