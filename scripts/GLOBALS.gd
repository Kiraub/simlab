extends Node

""" Constants """

enum Z_INDICIES {
	BACKGROUND	= -10
	STATIC		= 0
	ACTIVE		= 10
}

enum GROUP_FLAGS {
	Acting		= 1
	Blocking	= 2
	Selectable	= 4
}

const GROUP_NAMES : Dictionary = {
	GROUP_FLAGS.Acting		: "Acting",
	GROUP_FLAGS.Blocking	: "Blocking",
	GROUP_FLAGS.Selectable	: "Selectable"
}