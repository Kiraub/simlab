extends Position2D

class_name Entity

""" Constants """

const HIGHLIGHT_MATERIAL : Material = preload("res://Assets/shader_materials/highlight.tres")

""" Variables """

export var highlighted : bool = false setget set_highlighted, get_highlighted
export (GLOBALS.GROUP_FLAGS, FLAGS) var groups

""" Initialization """

#[override]
func _init(entity_zindex : int, entity_name : String = 'Entity') -> void:
	set_name(entity_name)
	z_index = entity_zindex
func _ready() -> void:
	# make child nodes use the entities shader
	for child in get_children():
		if child is CanvasItem:
			child.use_parent_material = true
	# set groups according to in-editor scene configuration
	for flag in GLOBALS.GROUP_FLAGS.values():
		if groups & flag and GLOBALS.GROUP_NAMES.has(flag):
			var group_name = GLOBALS.GROUP_NAMES.get(flag)
			.add_to_group(group_name)

""" Setters / Getters """

#[override]
func add_to_group(group : String , persistent : bool = false ) -> void:
	if is_in_group(group):
		return
	.add_to_group(group, persistent)
	update_group_flags()
#[override]
func remove_from_group(group : String) -> void:
	if not is_in_group(group):
		return
	.remove_from_group(group)
	update_group_flags()

func set_blocking(new_blocking : bool) -> void:
	if new_blocking:
		add_to_group(GLOBALS.GROUP_NAMES.get(GLOBALS.GROUP_FLAGS.Blocking))
	else:
		remove_from_group(GLOBALS.GROUP_NAMES.get(GLOBALS.GROUP_FLAGS.Blocking))
func is_blocking() -> bool:
	return groups & GLOBALS.GROUP_FLAGS.Blocking

func set_highlighted(new_highlighted : bool) -> void:
	highlighted = new_highlighted
	if highlighted:
		material = HIGHLIGHT_MATERIAL
	else:
		material = null
func get_highlighted() -> bool:
	return highlighted

""" Methods """

func update_group_flags() -> void:
	for flag in GLOBALS.GROUP_FLAGS.values():
		if GLOBALS.GROUP_NAMES.has(flag):
			if is_in_group(GLOBALS.GROUP_NAMES.get(flag)):
				groups |= flag
			else:
				groups &= ~flag



