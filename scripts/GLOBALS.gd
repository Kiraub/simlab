"""
  The GLOBALS class is set as a singleton node object instanced automatically at the start of the program.

  Since it is instanced as a direct child of the root scene node, every other class has access to all its fields at runtime.
  The constants defined in this class would be inserted in their respective classes in usual OOP.
  However Godot has, as of writing this program at version 3.2, a bug with cyclic referencing which requires this external grouping of contants.
  For more info on this bug refer to related GitHub issue at: https://github.com/godotengine/godot/issues/21461
"""

extends Node

""" Constants """

const QUEUE_FREE_LIFE_STATE : int = -1

const CUSTOMER_LIFE_STATES = {
  ENTER_SCENE   = 0,
  SEARCH_TABLE  = 1,
  DECIDE_ORDER  = 2,
  MAKE_ORDER    = 3,
  PROCESS_ORDER = 4,
  SEARCH_EXIT   = 5,
  EXIT_SCENE    = 6
}

const HAPPY_COLOR : Color = Color(0.0, 0.0, 1.0, 1.0)
const ANGRY_COLOR : Color = Color(1.0, 0.0, 0.0, 1.0)

const NORMAL_DIST_DECIDE_DELAY_MIN  : int   = 1
const NORMAL_DIST_DECIDE_DELAY_MAX  : int   = 20
const NORMAL_DIST_VARIATION_FACTOR  : float = 2.0
const EXPO_DIST_ANGRY_DELAY_MIN     : int   = 10
const EXPO_DIST_ANGRY_DELAY_MAX     : int   = 100
const EXPO_DIST_EXPECTED_VARIATION  : int   = 50

const DISTANCE_TYPES = {
  DEFAULT   = 4,
  MANHATTAN = 4,  # without diagonal, Von Neumann neighbourhood
  CHEBYSHEV = 8   # with diagonal, Moore neighbourhood
}

const DIRECTIONS_BY_DISTANCE_TYPE = {
  DISTANCE_TYPES.MANHATTAN : [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT],
  DISTANCE_TYPES.CHEBYSHEV : [
        Vector2.UP+Vector2.LEFT, Vector2.UP, Vector2.UP+Vector2.RIGHT, Vector2.RIGHT,
        Vector2.DOWN+Vector2.RIGHT, Vector2.DOWN, Vector2.DOWN+Vector2.LEFT, Vector2.LEFT
      ]
}

const TILE_UNCHANGED  : int = -2
const TILE_INVALID    : int = -1
const TILE_FLOOR      : int = 0
const TILE_WALL       : int = 1

const BLOCKING_TILE_IDS = [TILE_INVALID, TILE_WALL]

const PACKED_SCENE_CUSTOMER : PackedScene = preload("res://components/entities/Customer.tscn")
const PACKED_SCENE_PORTAL   : PackedScene = preload("res://components/entities/Portal.tscn")
const PACKED_SCENE_TABLE    : PackedScene = preload("res://components/entities/Table.tscn")
const PACKED_SCENE_WAITER   : PackedScene = preload("res://components/entities/Waiter.tscn")
