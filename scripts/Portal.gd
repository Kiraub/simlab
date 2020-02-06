extends Static

class_name Portal, "res://Assets/sprites/portal.png"

signal entity_spawned

""" Constants """

""" Variables """

export(PackedScene) var spawn : PackedScene

""" Initialization """

func _init(i_name : String = 'Portal').(i_name):
	pass

func _on_Timer_timeout():
	#print_debug("Timer timeout")
	emit_signal("entity_spawned", spawn, position)
