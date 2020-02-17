"""
	The GLOBALS class is set as a singleton node object instanced automatically at the start of the program.
	
	Since it is instanced as a direct child of the root scene node, every other class has access to all its fields at runtime.
	The constants defined in this class would be inserted in their respective classes in usual OOP.
	However Godot has, as of writing this program at version 3.2, a bug with cyclic referencing which requires this external grouping of contants.
	For more info on this bug refer to related GitHub issue at: https://github.com/godotengine/godot/issues/21461
"""

extends Node

""" Constants """

enum Z_INDICIES {
	BACKGROUND	= -10
	STATIC		= -8
	ACTIVE		= -5
}

enum SEARCH_STRATEGIES {
	BFS			= 0
	DFS			= 1
}

enum DISTANCE_TYPES {
	MANHATTAN	= 4 # without diagonal, Von Neumann neighbourhood
	CHEBYSHEV	= 8 # with diagonal, Moore neighbourhood
}

enum TILES {
	INVALID = -1
	FLOOR	= 0
	WALL	= 1
}
"""
const TYPE_ICONS = {
	-1				: preload("res://Assets/icons/types/icon_error_sign.svg"),
	TYPE_BOOL		: preload("res://Assets/icons/types/icon_bool.svg"),
	TYPE_COLOR		: preload("res://Assets/icons/types/icon_color.svg"),
	TYPE_DICTIONARY	: preload("res://Assets/icons/types/icon_dictionary.svg"),
	TYPE_INT		: preload("res://Assets/icons/types/icon_int.svg"),
	TYPE_OBJECT		: preload("res://Assets/icons/types/icon_mini_object.svg"),
	TYPE_STRING		: preload("res://Assets/icons/types/icon_string.svg"),
	TYPE_VECTOR2	: preload("res://Assets/icons/types/icon_vector2.svg")
}
"""

""" Variables """

""" Initialization """

""" Simulation step """

""" Godot process """

""" Static Methods """

""" Setters / Getters """

""" Methods """

""" Event Listeners """







