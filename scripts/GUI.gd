extends Control

""" Variables """

onready var simulation        : Simulation = $VSplitContainer/HSplitContainer/Simulation
onready var config_container  : Control = $VSplitContainer/HSplitContainer/Configuration/Background/ConfigContainer

""" Initialization """

#[override]
func _ready() -> void:
  var config_gui : Control = simulation.get_config_wrapper().create_gui_configuration()
  config_container.add_child(config_gui)
  config_gui.set_owner(config_container)

""" Methods """

""" Events """








