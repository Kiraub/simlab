extends Control


""" Variables """

onready var simulation_list : VBoxContainer = $VSplitContainer/HSplitContainer/LeftPanel/TabContainer/Simulations/ScrollContainer/SimulationList
onready var inspector : Tabs = $VSplitContainer/HSplitContainer/RightPanel/TabContainer/Inspector

""" Initialization """

func _ready() -> void:
	for child in simulation_list.get_children():
		if not child is Simulation:
			continue
		(child as Simulation).connect("configuration_opened", self, "_on_configuration_opened")
		child.connect("tree_exiting", self, "_on_simulation_deleted")

""" Methods """

func clear_inspector() -> void:
	for child in inspector.get_children():
		inspector.remove_child(child)

func update_inspector(gui_element : Control) -> void:
	clear_inspector()
	inspector.add_child(gui_element)
	gui_element.set_anchors_and_margins_preset(Control.PRESET_WIDE, Control.PRESET_MODE_KEEP_HEIGHT)

""" Events """

func _on_configuration_opened(config_wrapper : ConfigWrapper) -> void:
	var config_gui_element = config_wrapper.create_gui_configuration()
	update_inspector(config_gui_element)

func _on_simulation_deleted() -> void:
	clear_inspector()

func _on_AddSimulationBtn_pressed():
	pass # Replace with function body.
