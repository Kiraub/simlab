extends Position2D

class_name Entity

signal flags_updated
signal position_updated

""" Constants """

const HIGHLIGHT_MATERIAL : Material = preload("res://Assets/shader_materials/highlight.tres")

enum E_Flags {
	Blocking	= 1
	Selectable	= 2
	Highlighted	= 4
}

""" Variables """

export (E_Flags, FLAGS) var flags

var config : ConfigWrapper

""" Initialization """

#[override]
func _init(entity_z_index : int, entity_name : String = 'Entity') -> void:
	set_name(entity_name)
	z_index = entity_z_index

#[override]
func _ready() -> void:
	emit_signal("renamed", name)
	# make child nodes use the entities shader
	for child in get_children():
		if child is CanvasItem:
			child.use_parent_material = true
	
	config = ConfigWrapper.new(name)

""" Setters / Getters """

#[override]
func set_position(new_value : Vector2) -> void:
	emit_signal("position_updated", self, position, new_value)
	.set_position(new_value)

func set_flags(new_value : int) -> void:
	emit_signal("flags_updated", self, flags, new_value)
	flags = new_value

func set_blocking(new_blocking : bool) -> void:
	if new_blocking:
		set_flags(flags | E_Flags.Blocking)
	else:
		set_flags(flags & ~E_Flags.Blocking)
func is_blocking() -> bool:
	return flags & E_Flags.Blocking

func set_highlighted(new_highlighted : bool) -> void:
	if new_highlighted:
		set_flags(flags | E_Flags.Highlighted)
		material = HIGHLIGHT_MATERIAL
	else:
		set_flags(flags & ~E_Flags.Highlighted)
		material = null
func get_highlighted() -> bool:
	return flags & E_Flags.Highlighted

""" Methods """




