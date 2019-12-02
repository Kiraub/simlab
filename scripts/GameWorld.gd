extends Node

# worldLayer of the game
var worldLayer
# entityLayer of the game
var entityLayer

var playerX = 1
var playerY = 1

# Called when the node enters the scene tree for the first time.
func _ready(): 
	get_node("CenterContainer/EntityLayer").set_cell(playerX, playerY, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_down"):
		pass
