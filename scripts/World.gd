extends Node

var waiterScene = preload("res://scenes/Waiter.tscn")
var waiter

func _ready():
	waiter = waiterScene.instance()
	add_child(waiter)
	waiter.setPosition(Vector2(5,5))
	pass