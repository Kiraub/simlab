tool

extends Viewport

func _init():
	for child in get_children():
		if child is TileMap:
			var used_size = (child as TileMap).get_used_rect().size
			used_size.x *= (child as TileMap).cell_size.x
			used_size.y *= (child as TileMap).cell_size.y
			self.size = used_size
