extends Node2D

class_name Entity

signal name_updated(new_name)
signal position_updated(entity, old_position, new_position)

""" Constants """

""" Variables """

""" Initialization """

#[override]
func _init(entity_name : String = 'Entity') -> void:
  name    = entity_name

#[override]
func _ready() -> void:
  set_name(name)

""" Setters / Getters """

#[override]
func set_name(new_value : String) -> void:
  .set_name(new_value)
  emit_signal("name_updated", new_value)

#[override]
func set_position(new_value : Vector2) -> void:
  var old_value = position
  .set_position(new_value)
  emit_signal("position_updated", self, old_value, new_value)

""" Methods """




