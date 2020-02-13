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

enum NEIGHBOURHOOD {
	VON_NEUMANN	= 4 # without diagonal
	MOORE		= 8 # with diagonal
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







