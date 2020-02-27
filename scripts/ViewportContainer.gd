"""
  This ViewportController class is a simple extension of the Godot ViewportContainer class.

  It serves as a Viewport controller to enable zoom functionality.
  It also propagates left mouse button clicks to a child entity map.

  Since it is a Godot tool, it also changes its size when drawn in the Godot Editor.
  To force such a draw update a simple visibility off-on toggle should be enough.

  During runtime a child node of type Timer is used to refresh the size every time a timeout event occurs.
"""

tool

extends ViewportContainer

class_name ViewportController

signal received_mouse_click

export var resize_in_editor : bool = true
export var shown_tile_count : int

#[override]
func _ready() -> void:
  fit_to_view()

#[override]
func _draw() -> void:
  if Engine.is_editor_hint() and resize_in_editor:
    fit_to_view()
    refresh_size()

func reference_to_map() -> EntityMap:
  for child in self.get_children():
    if not child is Viewport:
      continue
    for lower_child in child.get_children():
      if lower_child is EntityMap:
        return lower_child
  return null

func fit_to_view() -> void:
  var entity_map := reference_to_map()
  var used_size := entity_map.get_used_rect().size
  shown_tile_count = int(ceil(max(used_size.x, used_size.y)))

func resize_viewport(new_size : Vector2) -> void:
  for child in get_children():
    if not child is Viewport:
      continue
    (child as Viewport).size = new_size

func refresh_size() -> void:
  var entity_map : EntityMap = reference_to_map()
  if entity_map == null:
    return
  resize_viewport(entity_map.cell_size * shown_tile_count)

func _on_ZoomInBtn_pressed() -> void:
  shown_tile_count -= 1
  if shown_tile_count < 1:
    shown_tile_count = 1
  refresh_size()

func _on_ZoomOutBtn_pressed():
  shown_tile_count += 1
  refresh_size()

func _gui_input(event : InputEvent) -> void:
  if Engine.is_editor_hint():
    return
  if not event is InputEventMouseButton:
    return
  var mouse_btn_event : = (event as InputEventMouseButton)
  if not mouse_btn_event.pressed:
    return
  emit_signal("received_mouse_click")
  var entity_map = reference_to_map()
  if entity_map == null:
    return
  var shown_size = entity_map.cell_size * shown_tile_count
  var relative_gui = Vector2(mouse_btn_event.position.x / rect_size.x, mouse_btn_event.position.y / rect_size.y)
  var absolute_map := Vector2(shown_size.x * relative_gui.x, shown_size.y * relative_gui.y)
  entity_map.handle_click_at_world(absolute_map, mouse_btn_event.button_index)

func _on_Timer_timeout():
  if not Engine.is_editor_hint():
    refresh_size()
