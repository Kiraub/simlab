extends Actor2D

const MOVEMENT_SPEED : float = 2.0

var moving : bool

func _ready():
	anchor = $Container
	setDisplayName("waiter")
	setType(Types.WAITER)

func observe_world(delta : float) -> void:
	if getOrientation() != Orientations.DEFAULT:
		moving = true
	else:
		moving = false

func action(delta : float) -> void:
	if moving:
		pass

func physics_observe_world(_delta : float) -> void:
	pass
func physics_action(_delta: float) -> void:
	if moving:
		pass