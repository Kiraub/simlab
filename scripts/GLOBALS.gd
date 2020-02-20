"""
  The GLOBALS class is set as a singleton node object instanced automatically at the start of the program.
  
  Since it is instanced as a direct child of the root scene node, every other class has access to all its fields at runtime.
  The constants defined in this class would be inserted in their respective classes in usual OOP.
  However Godot has, as of writing this program at version 3.2, a bug with cyclic referencing which requires this external grouping of contants.
  For more info on this bug refer to related GitHub issue at: https://github.com/godotengine/godot/issues/21461
"""

extends Node

""" Constants """

const Z_INDICIES = {
  BACKGROUND  = -10,
  STATIC      = -8,
  ACTIVE      = -5
}

const DISTANCE_TYPES = {
  MANHATTAN = 4, # without diagonal, Von Neumann neighbourhood
  CHEBYSHEV = 8 # with diagonal, Moore neighbourhood
}

const TILE_INVALID  : int = -1
const TILE_FLOOR    : int = 0
const TILE_WALL     : int = 1

const BLOCKING_TILE_IDS = [TILE_INVALID, TILE_WALL]

""" Variables """

""" Initialization """

""" Simulation step """

""" Godot process """

""" Static Methods """

""" Setters / Getters """

""" Methods """

""" Event Listeners """







