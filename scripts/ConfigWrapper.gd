""" This class works with rare dynamic typing to allow dynamic config GUI creation """

extends Reference

class_name ConfigWrapper

const CONFIG_FIELDS : Array = ["label_text", "value", "signal_name"]

var wrapped_class_name : String
var configurable : Dictionary

""" Initialization """

func _init(new_wrapped_class_name : String) -> void:
	wrapped_class_name = new_wrapped_class_name

""" Setters / Getters """

func set_entry_value(key : String, new_value):
	if configurable.has(key):
		configurable[key].value = new_value
func get_entry_value_or_default(key : String, default = null):
	if configurable.has(key):
		return configurable[key].value
	return default

""" Methods """

func add_config_entry(key : String, entry : Dictionary) -> void:
	if not entry.has_all(CONFIG_FIELDS):
		printerr("Cannot add config entry with incomplete fields: ", entry)
		return
	var signal_name = entry.signal_name
	if not has_user_signal(signal_name):
		add_user_signal(signal_name)
	configurable[key] = entry

func create_gui_configuration() -> Control:
	var gui_element : VSplitContainer = VSplitContainer.new()
	var wrapped_class_label : Label = Label.new()
	var scroll  : ScrollContainer = ScrollContainer.new()
	var config_container : GridContainer = GridContainer.new()
	wrapped_class_label.text = wrapped_class_name
	config_container.columns = 2
	for config_key in configurable:
		var label = Label.new()
		var default_value = configurable[config_key].value
		var input : Control = null
		label.text = configurable[config_key].label_text
		match typeof(default_value):
			TYPE_INT:
				input = SpinBox.new()
				input.name = config_key
				input.value = default_value
				(input as SpinBox).max_value = 1_000_000
				(input as SpinBox).allow_greater = true
				input.connect("value_changed", self, "_config_changed", [config_key])
			TYPE_REAL:
				input = SpinBox.new()
				input.name = config_key
				input.step = 0.001
				input.value = default_value
				(input as SpinBox).max_value = 1_000_000
				(input as SpinBox).allow_greater = true
				input.connect("value_changed", self, "_config_changed", [config_key])
			TYPE_STRING:
				input = LineEdit.new()
				input.name = config_key
				input.text = default_value
				input.connect("text_changed", self, "_config_changed", [config_key])
			TYPE_COLOR:
				input = ColorPickerButton.new()
				input.name = config_key
				input.color = default_value
				input.connect("color_changed", self, "_config_changed", [config_key])
			TYPE_BOOL:
				input = CheckButton.new()
				input.name = config_key
				input.pressed = default_value
				input.connect("toggled", self, "_config_changed", [config_key])
			TYPE_OBJECT:
				if not (default_value as Object).has_method("get_config_wrapper"):
					printerr("Trying to make gui_element of object without config_wrapper: ", default_value, ":", (default_value as Object).get_class())
					break
				
			_:
				printerr("Trying to make gui_element of unhandled type: ", default_value, ":", typeof(default_value))
		if input == null:
			input = Label.new()
			input.text = "Error setting up element."
		config_container.add_child(label)
		config_container.add_child(input)
	scroll.add_child(config_container)
	gui_element.add_child(wrapped_class_label)
	gui_element.add_child(scroll)
	gui_element.dragger_visibility = SplitContainer.DRAGGER_HIDDEN
	return gui_element

""" Event Listeners """

func _config_changed(event_value, key : String):
	var old_value	= configurable[key].value
	var signal_name	= configurable[key].signal_name
	set_entry_value(key, event_value)
	if has_user_signal(signal_name):
		emit_signal(configurable[key].signal_name, old_value, event_value)
	else:
		printerr(self, " is trying to emit nonexistent signal: ", signal_name)
