extends Actor

class_name Customer, "res://Assets/sprites/customer.png"

""" Constants """

enum E_LifeState {
	ENTER_SCENE		= 0,
	SEARCH_TABLE	= 1,
	DECIDE_ORDER	= 2,
	MAKE_ORDER		= 3,
	WAIT_ORDER		= 4,
	PROCESS_ORDER	= 5,
	PAY_ORDER		= 6,
	LEAVE_SCENE		= 7
}

""" Variables """

var life_state		: int = E_LifeState.ENTER_SCENE
var vision_range	: int = 1

""" Initialization """

func _init(i_name : String = 'Customer').(i_name) -> void:
	pass

""" Simulation step """

func step_by(amount : float) -> void:
	if len(targets) > 0:
		.step_by(amount)
		return
	match life_state:
		E_LifeState.ENTER_SCENE:
			#pass
			next_life_state()
		E_LifeState.SEARCH_TABLE:
			search_table()
			next_life_state()
			.step_by(amount)
		E_LifeState.DECIDE_ORDER:
			#pass
			next_life_state()
		E_LifeState.MAKE_ORDER:
			pass
			next_life_state()
		E_LifeState.WAIT_ORDER:
			pass
			next_life_state()
		E_LifeState.PROCESS_ORDER:
			pass
			next_life_state()
		E_LifeState.PAY_ORDER:
			pass
			next_life_state()
		E_LifeState.LEAVE_SCENE:
			queue_free()

""" Godot process """

func _ready():
	pass

""" Static Methods """

""" Setters / Getters """

""" Methods """

func next_life_state() -> void:
	life_state += 1

func search_table() -> void:
	var volatile_neighbours = get_neighbours()
	if len(volatile_neighbours) == 0:
		request_neighbour_entities()
		return
	for neighbour in volatile_neighbours:
		if neighbour is Table:
			next_life_state()

""" Events """
