extends Position2D

class_name Entity

signal name_updated
signal position_updated

""" Constants """

""" Variables """

var config : ConfigWrapper

""" Initialization """

#[override]
func _init(entity_z_index : int, entity_name : String = 'Entity') -> void:
  name    = entity_name
  z_index = entity_z_index
  config  = ConfigWrapper.new(name)

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
  emit_signal("position_updated", self, position, new_value)
  .set_position(new_value)

""" Methods """




