"""
	A MapCell holds information about a cell on an EntityMap
	It is used for communication between Entities and the EntityMap
	
	For that purpose it extends Reference to be easily passed between functions and automatically cleaned up after usage.
	It only features a constructor and getters since its values are not to be directly modified after construction.
"""

extends Reference

class_name MapCell

""" Constants """

""" Variables """

var _entities	: Array		setget , get_entities
var _tile_id	: int		setget , get_tile_id
var _world_v	: Vector2	setget , get_world_v
var _map_v		: Vector2	setget , get_map_v

""" Initialization """

func _init(
		entities	: Array		= [],
		tile_id		: int		= -1,
		world_v		: Vector2	= Vector2.ZERO,
		map_v		: Vector2	= Vector2.ZERO
		) -> void	:
	
	self._entities	= entities
	self._tile_id	= tile_id
	self._world_v	= world_v
	self._map_v		= map_v

""" Simulation step """

""" Godot process """

""" Static Methods """

""" Setters / Getters """

func get_entities() -> Array:
	return _entities

func get_tile_id() -> int:
	return _tile_id

func get_world_v() -> Vector2:
	return _world_v

func get_map_v() -> Vector2:
	return _map_v

""" Methods """

func has_entities() -> bool:
	if _entities is Array and len(_entities) > 0:
		return true
	return false

""" Event Listeners """


