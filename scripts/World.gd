extends Node

#var actor2d = preload("res://scenes/Actor2D.tscn")
var waiter

func _ready():
	waiter = Actor2D.new("waiter", Actor2D.Types.WAITER)
	add_child(waiter)
	waiter.setPosition(Vector2(5,5))
	pass