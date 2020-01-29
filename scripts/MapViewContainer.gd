#tool

extends ViewportContainer

export(Vector2) var entity_map_size : Vector2 setget set_entity_map_size
var entity_map : EntityMap
var viewport : Viewport

func _draw() -> void:
	if entity_map == null:
		if get_child_count() > 0:
			var _r = bind_children(self)
	else:
		var used_size = entity_map.get_used_rect().size
		used_size.x *= entity_map.cell_size.x
		used_size.y *= entity_map.cell_size.y
		set_entity_map_size(used_size)

""" Setters / Getters """

func set_entity_map_size(new_value : Vector2) -> void:
	if new_value != entity_map_size:
		entity_map_size = new_value
		if viewport != null:
			viewport.size = new_value
	update()

""" Methods """

func bind_children(thing : Node) -> bool:
	if thing is EntityMap:
		self.entity_map = thing
		return true
	elif thing is Viewport:
		self.viewport = thing
	for child in thing.get_children():
		if bind_children(child):
			return true
	return false