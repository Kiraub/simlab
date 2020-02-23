"""
  This unnamed class is a simple extension of the Godot ViewportContainer class.

  It simply serves the purpose the update its own size when a child node of type TileMap is present.
  As an added feature it has a margin to hide a specified amount of outer tiles.

  Since it is a Godot tool, it also changes its size when drawn in the Godot Editor.
  To force such a draw update a simple visibility off-on toggle should be enough.

  During runtime a child node of type Timer is used to refresh the size every time a timeout event occurs.
"""

tool

extends ViewportContainer

export(bool) var auto_resize : bool = false
export(int, 0, 5) var margin_tile_count : int = 0

#[override]
func _draw() -> void:
  if Engine.is_editor_hint():
    refresh()

func refresh() -> void:
  if not auto_resize:
    return
  for child in self.get_children():
    if not child is Viewport:
      continue
    for lower_child in child.get_children():
      if lower_child is TileMap:
        var used_size = (lower_child as TileMap).get_used_rect().size
        used_size.x += margin_tile_count
        used_size.y += margin_tile_count
        used_size.x *= (lower_child as TileMap).cell_size.x
        used_size.y *= (lower_child as TileMap).cell_size.y
        child.size = used_size

func _on_Timer_timeout() -> void:
  refresh()

func _on_ZoomInBtn_pressed() -> void:
  margin_tile_count -= 1
  if margin_tile_count < 0:
    margin_tile_count = 0

func _on_ZoomOutBtn_pressed():
  margin_tile_count += 1
