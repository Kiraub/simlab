""" This class works with rare dynamic typing to allow dynamic config GUI creation """

extends Reference

class_name ConfigWrapper

signal nested_config_changed

""" Constants """

const GETTER_METHOD		: = "get_config_wrapper"
const FIELDS			: = {
	LABEL_TEXT		= "label_text",
	DEFAULT_VALUE	= "value",
	SIGNAL_NAME		= "signal_name"
}
const HANDLED_TYPES		: = [TYPE_INT, TYPE_REAL, TYPE_STRING, TYPE_COLOR, TYPE_BOOL, TYPE_OBJECT]

""" Variables """

var wrapped_class_name	: String setget set_wrapped_class_name
var configurable		: = {}

""" Initialization """

func _init(i_wrapped_class_name : String) -> void:
	wrapped_class_name = i_wrapped_class_name

""" Setters / Getters """

func set_wrapped_class_name(new_value : String) -> void:
	wrapped_class_name = new_value

func set_entry_value(key : String, new_value):
	if configurable.has(key):
		assert(typeof(configurable[key].value) == typeof(new_value), "Trying to assign value of different type %s than configuration entry %s." % [new_value, configurable[key].value])
		configurable[key].value = new_value
func get_entry_value_or_default(key : String, default = null):
	if configurable.has(key):
		return configurable[key].value
	return default

""" Methods """

func add_config_entry(key : String, entry : Dictionary) -> void:
	assert(entry.has_all(FIELDS.values()), "Cannot add config entry with incomplete fields: %s" % entry)
	assert(typeof(entry.value) in HANDLED_TYPES, "Cannot add config entry with unhandled type: %s" % entry)
	var signal_name := String(entry.signal_name)
	if not has_user_signal(signal_name):
		add_user_signal(signal_name)
	configurable[key] = entry

func create_gui_configuration() -> Control:
	var gui_element			: = VBoxContainer.new()
	var wrapped_class_label	: = Label.new()
	var wrapped_class_hpad	: = HSeparator.new()
	var all_container		: = VBoxContainer.new()
	var all_pad				: = HSeparator.new()
	var self_container		: = GridContainer.new()
	
	gui_element.name = "%s's configuration" % wrapped_class_name
	wrapped_class_label.text = wrapped_class_name
	wrapped_class_label.name = "Label for wrapped config of %s" % wrapped_class_name
	wrapped_class_label.align = Label.ALIGN_CENTER
	all_container.name = "All configurations"
	self_container.columns = 2
	self_container.name = "Own configurations"
	
	all_container.add_child(self_container)
	gui_element.add_child(wrapped_class_label)
	gui_element.add_child(wrapped_class_hpad)
	gui_element.add_child(all_container)
	
	for config_key in configurable:
		#[dynamic type]
		var config_value		  = configurable[config_key].value
		var input				: = create_gui_input_by_value(config_key, config_value)
		var nested_element		: HSplitContainer
		var label				: Label
		var left_pad			: VSeparator
		
		if input == null:
			input = Label.new()
			(input as Label).text = "Handled type %d not yet implemented." % typeof(config_value)
		input.name = String(config_key)
		if not input is Container:
			label 		= Label.new()
			label.text	= String(configurable[config_key].label_text)
			label.name	= "Label for input of %s" % String(config_key)
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			self_container.add_child(label)
			self_container.add_child(input)
		else:
			nested_element = HSplitContainer.new()
			nested_element.dragger_visibility = SplitContainer.DRAGGER_HIDDEN
			left_pad = VSeparator.new()
			left_pad.name = "Nest padding"
			input.name += " (nested)"
			
			nested_element.add_child(left_pad)
			nested_element.add_child(input)
			all_container.add_child(nested_element)
	
	all_container.add_child(all_pad)
	return gui_element

func create_gui_input_by_value(key : String, value) -> Control:
	var input : Control = null
	match typeof(value):
		TYPE_INT:
			input = SpinBox.new()
			(input as SpinBox).max_value = 1_000_000
			(input as SpinBox).allow_greater = true
			(input as SpinBox).step = 1.0
			(input as SpinBox).value = float(value)
			input.connect("value_changed", self, "_on_config_changed", [key])
		TYPE_REAL:
			input = SpinBox.new()
			(input as SpinBox).allow_greater = true
			(input as SpinBox).max_value = 1_000_000
			(input as SpinBox).step = 0.001
			(input as SpinBox).value = float(value)
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
			assert((value as Object).has_method(GETTER_METHOD), "Config entry K:V %s:%s has no %s method!" % [key, value, GETTER_METHOD])
			var nested_config : ConfigWrapper = value.call(GETTER_METHOD)
			input = nested_config.create_gui_configuration()
			if not nested_config.is_connected("nested_config_changed", self, "_on_nested_config_changed"):
				nested_config.connect("nested_config_changed", self, "_on_nested_config_changed", [key])
	return input

""" Event Listeners """

func _on_config_changed(event_value, key : String) -> void:
	var old_value	= configurable[key].value
	var signal_name	= configurable[key].signal_name
	
	set_entry_value(key, event_value)
	assert(has_user_signal(signal_name), "%s is trying to emit nonexistent signal: %s" % [self, signal_name])
	emit_signal(configurable[key].signal_name, old_value, event_value)
	emit_signal("nested_config_changed")

func _on_nested_config_changed(key : String) -> void:
	var signal_name	= configurable[key].signal_name
	
	assert(has_user_signal(signal_name), "%s is trying to emit nonexistent signal: %s" % [self, signal_name])
	emit_signal(configurable[key].signal_name)
	emit_signal("nested_config_changed")



