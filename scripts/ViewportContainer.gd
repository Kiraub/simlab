tool

extends ViewportContainer

func _draw() -> void:
	if Engine.is_editor_hint():
		refresh()

func refresh() -> void:
	for child in self.get_children():
		if not child is Viewport:
			continue
		for lower_child in child.get_children():
			if lower_child is TileMap:
				var used_size = (lower_child as TileMap).get_used_rect().size
				used_size.x *= (lower_child as TileMap).cell_size.x
				used_size.y *= (lower_child as TileMap).cell_size.y
				#print_debug("Refreshed size: ", child.size, ";;", used_size)
				child.size = used_size

func _on_Timer_timeout():
	refresh()
