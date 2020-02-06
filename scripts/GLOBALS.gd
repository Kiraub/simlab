extends Node

""" Constants """

enum Z_INDICIES {
	BACKGROUND	= -10
	STATIC		= 0
	ACTIVE		= 10
}

enum SEARCH_STRATEGIES {
	BFS			= 0
	DFS			= 1
}

""" Static Methods """

static func expand(path : Array, expansion_factor : float = 1.0) -> Array:
	var new_paths = []
	var expansions = [
		Vector2.UP * expansion_factor,
		Vector2.LEFT * expansion_factor,
		Vector2.DOWN * expansion_factor,
		Vector2.RIGHT * expansion_factor
	]
	if not path is Array or len(path) == 0:
		continue
	var new_path_base : Array = path.duplicate()
	var last : Vector2 = new_path_base.back()
	for expansion in expansions:
		var new_path : Array = new_path_base.duplicate()
		new_path.append(last + expansion)
		new_paths.append(new_path)
	return new_paths
