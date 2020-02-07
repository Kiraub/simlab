""" This class works with rare dynamic typing to allow dynamic config GUI creation """

extends Reference

class_name ConfigWrapper

signal nested_config_changed

""" Constants """

const CONFIG_FIELDS		: = ["label_text", "value", "signal_name"]
const HANDLED_TYPES		: = [TYPE_INT, TYPE_REAL, TYPE_STRING, TYPE_COLOR, TYPE_BOOL, TYPE_OBJECT]

""" Variables """

var wrapped_class_name	: String
var configurable		: = {}

""" Initialization """

func _init(i_wrapped_class_name : String) -> void:
	wrapped_class_name = i_wrapped_class_name

""" Setters / Getters """

func set_entry_value(key : String, new_value):
	if configurable.has(key):
		assert(typeof(configurable[key].value) == typeof(new_value), "Trying to assign value of different type than configuration entry.")
		configurable[key].value = new_value
func get_entry_value_or_default(key : String, default = null):
	if configurable.has(key):
		return configurable[key].value
	return default

""" Methods """

func add_config_entry(key : String, entry : Dictionary) -> void:
	assert(entry.has_all(CONFIG_FIELDS), "Cannot add config entry with incomplete fields: %s" % entry)
	assert(typeof(entry.value) in HANDLED_TYPES, "Cannot add config entry with unhandled type: %s" % entry)
	var signal_name := String(entry.signal_name)
	if not has_user_signal(signal_name):
		add_user_signal(signal_name)
	configurable[key] = entry

func create_gui_configuration() -> Control:
	var gui_element			: = VSplitContainer.new()
	var wrapped_class_label	: = Label.new()
	var scroll				: = ScrollContainer.new()
	var config_container	: = GridContainer.new()
	
	wrapped_class_label.text = wrapped_class_name
	config_container.columns = 2
	
	for config_key in configurable:
		var label	:			= Label.new()
		var config_value		= configurable[config_key].value
		var input	: Control	= create_gui_input_by_value(config_key, config_value)
		
		label.text = String(configurable[config_key].label_text)
		if input == null:
			input = Label.new()
			input.text = "Handled type %s not yet implemented." % typeof(config_value)
		input.name = String(config_key)
		config_container.add_child(label)
		config_container.add_child(input)
	scroll.add_child(config_container)
	gui_element.add_child(wrapped_class_label)
	gui_element.add_child(scroll)
	gui_element.dragger_visibility = SplitContainer.DRAGGER_HIDDEN
	return gui_element

func create_gui_input_by_value(key : String, value) -> Control:
	var input : Control = null
	match typeof(value):
		TYPE_INT:
			input = SpinBox.new()
			(input as SpinBox).step = 1.0
			(input as SpinBox).value = float(value)
			(input as SpinBox).max_value = 1_000_000
			(input as SpinBox).allow_greater = true
			input.connect("value_changed", self, "_on_config_changed", [key])
		TYPE_REAL:
			input = SpinBox.new()
			(input as SpinBox).step = 0.001
			(input as SpinBox).value = float(value)
			(input as SpinBox).max_value = 1_000_000
			(input as SpinBox).allow_greater = true
			input.connect("value_changed", self, "_on_config_changed", [key])
		TYPE_STRING:
			input = LineEdit.new()
			(input as LineEdit).text = String(value)
			input.connect("text_changed", self, "_on_config_changed", [key])
		TYPE_COLOR:
			input = ColorPickerButton.new()
			(input as ColorPickerButton).color = Color(value)
			input.connect("color_changed", self, "_on_config_changed", [key])
		TYPE_BOOL:
			input = CheckButton.new()
			(input as CheckButton).pressed = bool(value)
			input.connect("toggled", self, "_on_config_changed", [key])
		TYPE_OBJECT:
			assert("get_config_wrapper" in value, "Config entry K:V %s:%s has no get_config_wrapper method!" % [key, value])
			input = (value.get_config_wrapper() as ConfigWrapper).create_gui_configuration()
			# TODO connect nested_config_changed signal
	return input


""" Event Listeners """

func _on_config_changed(event_value, key : String):
	var old_value	= configurable[key].value
	var signal_name	= configurable[key].signal_name
	
	set_entry_value(key, event_value)
	assert(has_user_signal(signal_name), "%s is trying to emit nonexistent signal: %s" % [self, signal_name])
	emit_signal(configurable[key].signal_name, old_value, event_value)






