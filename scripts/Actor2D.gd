extends Entity2D

class_name Actor2D

#var WAITER_TEXTURE = load("res://Assets/sprites/waiter.png")

enum Types {
	IDLE,
	WAITER,
	CUSTOMER,
	CHEF,
}
enum MovementDirections {
	NONE	= 0
	UP		= 1,
	DOWN	= 2,
	LEFT	= 4,
	RIGHT	= 8,
}
enum Orientations {
	DEFAULT		= 0,
	UP			= 1,
	DOWN		= 2,
	LEFT		= 4,
	UPLEFT		= 5,
	DOWNLEFT	= 6,
	RIGHT		= 8,
	UPRIGHT		= 9,
	DOWNRIGHT	= 10,
}

var __type : int setget setType, getType
var __orientation : int setget setOrientation, getOrientation
#var __texture : Texture setget setTexture, getTexture
#var __sprite : Sprite

var mapO2R : Dictionary

func _init(displayName:String = "", type : int = 0) -> void:
	#__sprite = Sprite.new()
	#__sprite.name = "sprite"
	name = displayName
	setDisplayName(displayName)
	setType(type)
	__orientation = Orientations.DEFAULT
	setRotation(0.5)

func _ready() -> void:
	#anchor.add_child(__sprite, true)
	#chooseTexturebyType()
	mapO2R[Orientations.DEFAULT]	= .5
	mapO2R[Orientations.UP]			= .0
	mapO2R[Orientations.UPRIGHT]	= .125
	mapO2R[Orientations.RIGHT]		= .25
	mapO2R[Orientations.DOWNRIGHT]	= .375
	mapO2R[Orientations.DOWN]		= .5
	mapO2R[Orientations.DOWNLEFT]	= .625
	mapO2R[Orientations.LEFT]		= .75
	mapO2R[Orientations.UPLEFT]		= .875

func _process(delta : float) -> void:
	observe_world(delta)
	action(delta)

func _physics_process(delta : float) -> void:
	var newDirection = MovementDirections.NONE
	if Input.is_action_pressed("ui_down"):
		newDirection |= MovementDirections.DOWN
	if Input.is_action_pressed("ui_up"):
		newDirection |= MovementDirections.UP
	if Input.is_action_pressed("ui_left"):
		newDirection |= MovementDirections.LEFT
	if Input.is_action_pressed("ui_right"):
		newDirection |= MovementDirections.RIGHT
	# filter contradicting directions
	if newDirection & MovementDirections.RIGHT && newDirection & MovementDirections.LEFT:
		newDirection &= ~MovementDirections.RIGHT & ~MovementDirections.LEFT
	if newDirection & MovementDirections.UP && newDirection & MovementDirections.DOWN:
		newDirection &= ~MovementDirections.UP & ~MovementDirections.DOWN
	setOrientation(newDirection)
	physics_observe_world(delta)
	physics_action(delta)

func setType(newType : int) -> void:
	match newType:
		Types.IDLE, Types.WAITER, Types.CHEF, Types.CUSTOMER:
			__type = newType
		_:
			__type = Types.IDLE
func getType() -> int:
	return __type

func setOrientation(newOrientation : int) -> void:
	if __orientation != newOrientation:
		__orientation = newOrientation
		setRotation(mapO2R[__orientation])
func getOrientation() -> int:
	return __orientation
"""
func setTexture(newTexture : Texture) -> void:
	__texture = newTexture
	__sprite.texture = getTexture()
func getTexture() -> Texture:
	return __texture

func chooseTexturebyType() -> void:
	match getType():
		Types.WAITER:
			setTexture(WAITER_TEXTURE)
		_:
			setTexture(WAITER_TEXTURE)
"""
func physics_observe_world(_delta : float) -> void:
	pass
func observe_world(_delta : float) -> void:
	pass
func physics_action(_delta: float) -> void:
	pass
func action(_delta: float) -> void:
	pass