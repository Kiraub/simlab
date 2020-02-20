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

var _tile_id    : int     setget , get_tile_id
var _absolute_v : Vector2 setget , get_absolute_v
var _center_v   : Vector2 setget , get_center_v
var _entity     : Entity  setget , get_entity
var _relative_v : Vector2 setget , get_relative_v

""" Initialization """

#[override]
func _init(
    tile_id     : int,
    absolute_v  : Vector2,
    center_v    : Vector2,
    entity      : Entity  = null,
    relative_v  : Vector2 = Vector2.ZERO
    ) -> void:
  
  self._tile_id     = tile_id
  self._absolute_v  = absolute_v
  self._center_v    = center_v
  self._entity      = entity
  self._relative_v  = relative_v

""" Simulation step """

""" Godot process """

""" Static Methods """

""" Setters / Getters """

func get_tile_id() -> int:
  return _tile_id

func get_absolute_v() -> Vector2:
  return _absolute_v

func get_center_v() -> Vector2:
  return _center_v

func get_entity() -> Entity:
  return _entity

func get_relative_v() -> Vector2:
  return _relative_v

""" Methods """

func has_entity() -> bool:
  if _entity is Entity and _entity != null:
    return true
  return false

func make_relative_to(reference_v : Vector2) -> void:
  _relative_v = _absolute_v - reference_v

func distance_to_map(other_map : Vector2, distance_type : int) -> int:
  var distance : int
  match distance_type:
    GLOBALS.DISTANCE_TYPES.MANHATTAN:
      distance = int(floor(abs(other_map.x - _absolute_v.x) + abs(other_map.y - _absolute_v.y)))
    GLOBALS.DISTANCE_TYPES.CHEBYSHEV:
      distance = int(floor(min(abs(other_map.x - _absolute_v.x), abs(other_map.y - _absolute_v.y))))
  return distance

func distance_to_mapcell(other_mapcell : MapCell, distance_type : int) -> int:
  return distance_to_map(other_mapcell.get_absolute_v(), distance_type)

""" Event Listeners """







