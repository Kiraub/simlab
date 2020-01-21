extends Position2D

class_name Entity

""" Constants """

const HIGHLIGHT_MATERIAL : Material = preload("res://Assets/shader_materials/highlight.tres")

enum E_EntityFlags {
	Blocking	= 1
	Selectable	= 2
	Highlighted	= 4
}

""" Variables """

export (E_EntityFlags, FLAGS) var EntityFlags

""" Initialization """

#[override]
func _init(entity_zindex : int, entity_name : String = 'Entity') -> void:
	set_name(entity_name)
	z_index = entity_zindex

#[override]
func _ready() -> void:
	# make child nodes use the entities shader
	for child in get_children():
		if child is CanvasItem:
			child.use_parent_material = true

""" Setters / Getters """

func set_blocking(new_blocking : bool) -> void:
	if new_blocking:
		EntityFlags |= E_EntityFlags.Blocking
	else:
		EntityFlags &= ~E_EntityFlags.Blocking
func is_blocking() -> bool:
	return EntityFlags & E_EntityFlags.Blocking

func set_highlighted(new_highlighted : bool) -> void:
	if new_highlighted:
		EntityFlags |= E_EntityFlags.Highlighted
		material = HIGHLIGHT_MATERIAL
	else:
		EntityFlags &= ~E_EntityFlags.Highlighted
		material = null
func get_highlighted() -> bool:
	return EntityFlags & E_EntityFlags.Highlighted

""" Methods """




