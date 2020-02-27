extends Control

""" Variables """

onready var simulation        : Simulation    = $VSplitContainer/HSplitContainer/Simulation
onready var config_container  : Control       = $VSplitContainer/HSplitContainer/Configuration/Background/ConfigContainer
onready var statistics_popup  : Popup         = $StatisticsPopupDialog
onready var statistics_label  : RichTextLabel = $StatisticsPopupDialog/StatisticsLabel
onready var help_popup        : Popup         = $HelpPopupDialog
onready var about_popup       : Popup         = $AboutPopupDialog

""" Initialization """

#[override]
func _ready() -> void:
  update_configuration_element()

""" Methods """

func update_configuration_element() -> void:
  for child in config_container.get_children():
    if child is Container:
      child.queue_free()
  var config_element : Control = simulation.get_config_wrapper().create_gui_configuration()
  config_container.add_child(config_element)
  config_element.set_owner(config_container)

func update_statistics_text() -> void:
  var statistics = simulation.get_statistics()
  var content : String = ""
  for key in statistics.keys():
    content = "%s\n%s: %s" % [content, String(key), int(statistics[key])]
  statistics_label.set_text(content)

""" Events """

func _on_config_entries_changed():
  update_configuration_element()

func _on_StatisticsBtn_pressed():
  simulation.set_paused(true)
  # using call_defered to give the simulation time to run through its remaining step after pausing it
  call_deferred("update_statistics_text")
  statistics_popup.popup_centered_minsize(Vector2.ONE)

func _on_HelpBtn_pressed():
  help_popup.popup_centered_minsize(Vector2.ONE)

func _on_AboutBtn_pressed():
  about_popup.popup_centered_minsize(Vector2.ONE)
